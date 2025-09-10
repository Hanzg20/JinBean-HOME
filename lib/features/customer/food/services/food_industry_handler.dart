import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/base_models.dart';
import '../../../../core/models/order_models.dart';
import '../../../../core/models/payment_models.dart';
import '../../../../core/services/universal_order_service.dart';
import '../../../../core/services/universal_payment_service.dart';

/// 餐饮行业订单处理器
/// 
/// 实现餐饮行业特定的订单处理逻辑：
/// - 配送地址验证和费用计算
/// - 食品安全和过敏原检查
/// - 制作时间和配送时间估算
/// - 餐饮特定的状态管理
class FoodIndustryOrderHandler implements IndustryOrderHandler {
  final _supabase = Supabase.instance.client;

  @override
  Future<void> preprocessOrder(OrderRequest request) async {
    print('🍽️ 餐饮订单预处理');

    // 验证配送地址
    if (request.serviceAddress == null) {
      throw OrderException('餐饮订单必须提供配送地址');
    }

    // 检查服务区域
    final isInServiceArea = await _checkServiceArea(
      request.serviceId,
      request.serviceAddress!,
    );
    if (!isInServiceArea) {
      throw OrderException('配送地址不在服务范围内');
    }

    // 验证营业时间
    final isOpen = await _checkBusinessHours(request.providerId);
    if (!isOpen) {
      throw OrderException('当前不在营业时间内');
    }

    // 检查最小订单金额
    final minOrderAmount = await _getMinimumOrderAmount(request.serviceId);
    final orderTotal = request.estimatedTotal;
    if (orderTotal < minOrderAmount) {
      throw OrderException('订单金额不满足最低消费要求: \$${minOrderAmount.toStringAsFixed(2)}');
    }
  }

  @override
  Future<void> postprocessOrder(Order order) async {
    print('🍽️ 餐饮订单后处理');

    // 设置餐饮特定的元数据
    order.setIndustryData('food_type', 'restaurant_delivery');
    order.setIndustryData('estimated_preparation_time', 30); // 30分钟制作时间
    order.setIndustryData('estimated_delivery_time', 45); // 45分钟配送时间
    
    // 计算预计送达时间
    final estimatedDeliveryTime = DateTime.now().add(const Duration(minutes: 45));
    order.setIndustryData('estimated_delivery_time_iso', estimatedDeliveryTime.toIso8601String());

    // 发送订单确认通知
    await _sendOrderConfirmationNotification(order);
  }

  @override
  Future<ValidationResult> validateOrder(OrderRequest request) async {
    final errors = <String>[];
    final fieldErrors = <String, String>{};

    // 验证配送地址
    if (request.serviceAddress == null) {
      fieldErrors['service_address'] = '配送地址不能为空';
    }

    // 验证订单项目的餐饮特定要求
    for (int i = 0; i < request.items.length; i++) {
      final item = request.items[i];
      
      // 检查商品是否可用
      final isAvailable = await _checkItemAvailability(item.serviceDetailId);
      if (!isAvailable) {
        fieldErrors['items[$i]'] = '商品 ${item.name} 当前不可用';
      }

      // 验证定制选项
      final validationResult = await _validateCustomizations(item);
      if (!validationResult.isValid) {
        fieldErrors['items[$i].customizations'] = validationResult.firstError;
      }
    }

    // 检查过敏原冲突
    final allergenCheck = await _checkAllergenConflicts(request);
    if (!allergenCheck.isValid) {
      errors.addAll(allergenCheck.errors);
    }

    return ValidationResult(
      isValid: errors.isEmpty && fieldErrors.isEmpty,
      errors: errors,
      fieldErrors: fieldErrors,
    );
  }

  @override
  Future<PricingResult?> adjustPricing({
    required Price baseAmount,
    required List<PricingFee> fees,
    required List<PricingDiscount> discounts,
    required OrderRequest request,
  }) async {
    print('🧮 餐饮定价调整');

    final adjustedFees = List<PricingFee>.from(fees);
    final adjustedDiscounts = List<PricingDiscount>.from(discounts);

    // 添加餐饮特定费用
    await _addDeliveryFee(adjustedFees, baseAmount, request);
    await _addPackagingFee(adjustedFees, request.items);
    await _addServiceFee(adjustedFees, baseAmount);

    // 检查是否有餐饮特定折扣
    await _checkFoodPromotions(adjustedDiscounts, baseAmount, request);

    // 重新计算总金额
    final feesTotal = adjustedFees.fold(
      Price(amount: 0.0, currency: baseAmount.currency),
      (sum, fee) => sum + fee.amount,
    );

    final discountsTotal = adjustedDiscounts.fold(
      Price(amount: 0.0, currency: baseAmount.currency),
      (sum, discount) => sum + discount.amount,
    );

    final totalAmount = baseAmount + feesTotal - discountsTotal;

    return PricingResult(
      baseAmount: baseAmount,
      fees: adjustedFees,
      discounts: adjustedDiscounts,
      totalAmount: totalAmount,
      currency: baseAmount.currency,
      breakdown: {
        'food_items_total': baseAmount.amount,
        'delivery_fee': _getFeeAmount(adjustedFees, 'delivery'),
        'packaging_fee': _getFeeAmount(adjustedFees, 'packaging'),
        'service_fee': _getFeeAmount(adjustedFees, 'service'),
        'tax_amount': _getFeeAmount(adjustedFees, 'tax'),
        'total_discounts': discountsTotal.amount,
        'final_total': totalAmount.amount,
      },
    );
  }

  @override
  Future<void> onStatusChange(Order order, OrderStatus newStatus, String? reason) async {
    print('🔄 餐饮订单状态变更: ${order.status.label} -> ${newStatus.label}');

    switch (newStatus) {
      case OrderStatus.accepted:
        await _onOrderAccepted(order);
        break;
      case OrderStatus.inProgress:
        await _onOrderInProgress(order);
        break;
      case OrderStatus.completed:
        await _onOrderCompleted(order);
        break;
      case OrderStatus.cancelled:
        await _onOrderCancelled(order, reason);
        break;
      default:
        break;
    }

    // 发送状态变更通知
    await _sendStatusChangeNotification(order, newStatus, reason);
  }

  @override
  Future<void> onOrderCancellation(Order order, String reason) async {
    print('❌ 餐饮订单取消处理');

    // 检查是否可以取消
    final canCancel = await _checkCancellationPolicy(order);
    if (!canCancel) {
      throw OrderException('订单已开始制作，无法取消');
    }

    // 计算取消费用
    final cancellationFee = await _calculateCancellationFee(order, reason);
    if (cancellationFee.amount > 0) {
      // 更新订单取消费用
      // 这里可以通过其他方式更新，因为Order是不可变的
      print('💰 取消费用: ${cancellationFee.formatted}');
    }

    // 恢复库存（如果适用）
    await _restoreInventory(order);

    // 通知餐厅
    await _notifyRestaurantCancellation(order, reason);
  }

  // ========================================
  // 私有方法 - 验证逻辑
  // ========================================

  /// 检查服务区域
  Future<bool> _checkServiceArea(String serviceId, Address address) async {
    try {
      final response = await _supabase
          .from('food_delivery_zones')
          .select()
          .eq('service_id', serviceId)
          .eq('is_active', true);

      for (final zone in response) {
        final zoneType = zone['zone_type'];
        final zoneConfig = zone['zone_config'] as Map<String, dynamic>;

        switch (zoneType) {
          case 'postal_code':
            final postalCodes = (zoneConfig['postal_codes'] as List).cast<String>();
            if (postalCodes.contains(address.postalCode)) {
              return true;
            }
            break;
          case 'radius':
            // TODO: 实现基于半径的区域检查
            return true;
          case 'polygon':
            // TODO: 实现基于多边形的区域检查
            return true;
        }
      }

      return false;
    } catch (e) {
      print('⚠️ 服务区域检查失败: $e');
      return true; // 默认允许
    }
  }

  /// 检查营业时间
  Future<bool> _checkBusinessHours(String providerId) async {
    try {
      final now = DateTime.now();
      final dayOfWeek = now.weekday % 7; // 转换为0-6格式

      final response = await _supabase
          .from('provider_schedules')
          .select()
          .eq('provider_id', providerId)
          .eq('day_of_week', dayOfWeek)
          .eq('is_available', true)
          .maybeSingle();

      if (response == null) return false;

      final startTime = _parseTime(response['start_time']);
      final endTime = _parseTime(response['end_time']);
      final currentTime = Duration(hours: now.hour, minutes: now.minute);

      return currentTime >= startTime && currentTime <= endTime;
    } catch (e) {
      print('⚠️ 营业时间检查失败: $e');
      return true; // 默认允许
    }
  }

  /// 获取最小订单金额
  Future<double> _getMinimumOrderAmount(String serviceId) async {
    try {
      final response = await _supabase
          .from('services')
          .select('minimum_order_amount')
          .eq('id', serviceId)
          .single();

      return (response['minimum_order_amount'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      print('⚠️ 获取最小订单金额失败: $e');
      return 0.0;
    }
  }

  /// 检查商品可用性
  Future<bool> _checkItemAvailability(String serviceDetailId) async {
    try {
      final response = await _supabase
          .from('service_details')
          .select('is_available, current_stock, max_stock')
          .eq('id', serviceDetailId)
          .single();

      final isAvailable = response['is_available'] ?? true;
      final currentStock = response['current_stock'] as int?;
      final maxStock = response['max_stock'] as int?;

      if (!isAvailable) return false;
      if (currentStock != null && maxStock != null) {
        return currentStock > 0;
      }

      return true;
    } catch (e) {
      print('⚠️ 商品可用性检查失败: $e');
      return true; // 默认可用
    }
  }

  /// 验证定制选项
  Future<ValidationResult> _validateCustomizations(OrderItemRequest item) async {
    // TODO: 实现定制选项验证逻辑
    // 例如：检查辣度级别是否有效、配菜选择是否合理等
    return ValidationResult.valid();
  }

  /// 检查过敏原冲突
  Future<ValidationResult> _checkAllergenConflicts(OrderRequest request) async {
    // TODO: 实现过敏原冲突检查
    // 如果用户设置了过敏原信息，检查订单中是否包含冲突的食材
    return ValidationResult.valid();
  }

  // ========================================
  // 私有方法 - 定价逻辑
  // ========================================

  /// 添加配送费
  Future<void> _addDeliveryFee(
    List<PricingFee> fees,
    Price baseAmount,
    OrderRequest request,
  ) async {
    try {
      final response = await _supabase
          .from('food_delivery_zones')
          .select('base_delivery_fee, free_delivery_threshold')
          .eq('service_id', request.serviceId)
          .eq('is_active', true)
          .limit(1)
          .maybeSingle();

      if (response == null) return;

      final baseFee = (response['base_delivery_fee'] as num?)?.toDouble() ?? 3.50;
      final freeThreshold = (response['free_delivery_threshold'] as num?)?.toDouble();

      // 检查是否满足免配送费条件
      if (freeThreshold != null && baseAmount.amount >= freeThreshold) {
        fees.add(PricingFee(
          type: 'delivery',
          name: '配送费（满额免费）',
          amount: Price(amount: 0.0, currency: baseAmount.currency),
          description: '满\$${freeThreshold.toStringAsFixed(2)}免配送费',
        ));
      } else {
        fees.add(PricingFee(
          type: 'delivery',
          name: '配送费',
          amount: Price(amount: baseFee, currency: baseAmount.currency),
        ));
      }
    } catch (e) {
      print('⚠️ 配送费计算失败: $e');
      // 添加默认配送费
      fees.add(PricingFee(
        type: 'delivery',
        name: '配送费',
        amount: Price(amount: 3.50, currency: baseAmount.currency),
      ));
    }
  }

  /// 添加包装费
  Future<void> _addPackagingFee(List<PricingFee> fees, List<OrderItemRequest> items) async {
    const feePerItem = 0.50;
    const maxFee = 3.00;

    final totalItems = items.fold<int>(0, (sum, item) => sum + item.quantity);
    final calculatedFee = totalItems * feePerItem;
    final finalFee = calculatedFee > maxFee ? maxFee : calculatedFee;

    if (finalFee > 0) {
      fees.add(PricingFee(
        type: 'packaging',
        name: '环保包装费',
        amount: Price(amount: finalFee),
        description: '每件商品\$${feePerItem.toStringAsFixed(2)}，最高\$${maxFee.toStringAsFixed(2)}',
      ));
    }
  }

  /// 添加服务费
  Future<void> _addServiceFee(List<PricingFee> fees, Price baseAmount) async {
    const feeRate = 0.08; // 8%
    final feeAmount = baseAmount.amount * feeRate;

    fees.add(PricingFee(
      type: 'service',
      name: '平台服务费',
      amount: Price(amount: feeAmount, currency: baseAmount.currency),
      description: '8%平台服务费',
    ));

    // 添加税费 (HST 13%)
    const taxRate = 0.13;
    final subtotal = baseAmount.amount + feeAmount + _getFeesTotalAmount(fees);
    final taxAmount = subtotal * taxRate;

    fees.add(PricingFee(
      type: 'tax',
      name: 'HST (13%)',
      amount: Price(amount: taxAmount, currency: baseAmount.currency),
      description: '商品及服务税',
    ));
  }

  /// 检查餐饮促销
  Future<void> _checkFoodPromotions(
    List<PricingDiscount> discounts,
    Price baseAmount,
    OrderRequest request,
  ) async {
    // TODO: 检查餐饮特定的促销活动
    // 例如：首次订餐折扣、满减活动、会员专享等
  }

  // ========================================
  // 私有方法 - 状态处理
  // ========================================

  /// 订单被接受时的处理
  Future<void> _onOrderAccepted(Order order) async {
    print('✅ 餐饮订单已接受');
    
    // 设置预计制作完成时间
    final preparationTime = order.getIndustryData<int>('estimated_preparation_time', 30) ?? 30;
    final estimatedReadyTime = DateTime.now().add(Duration(minutes: preparationTime));
    order.setIndustryData('estimated_ready_time', estimatedReadyTime.toIso8601String());

    // 减少库存（如果适用）
    await _decreaseInventory(order);

    // 通知配送系统
    await _notifyDeliverySystem(order);
  }

  /// 订单进行中时的处理
  Future<void> _onOrderInProgress(Order order) async {
    print('🍳 餐饮订单制作中');
    
    // 发送制作开始通知
    await _sendCookingNotification(order);
  }

  /// 订单完成时的处理
  Future<void> _onOrderCompleted(Order order) async {
    print('🎉 餐饮订单已完成');
    
    // 记录实际完成时间
    order.setIndustryData('actual_completion_time', DateTime.now().toIso8601String());

    // 发送完成通知和评价邀请
    await _sendCompletionNotification(order);
    await _inviteReview(order);
  }

  /// 订单取消时的处理
  Future<void> _onOrderCancelled(Order order, String? reason) async {
    print('❌ 餐饮订单已取消: $reason');
    
    // 记录取消原因和时间
    order.setIndustryData('cancellation_time', DateTime.now().toIso8601String());
    order.setIndustryData('cancellation_category', _categorizeCancellationReason(reason));
  }

  // ========================================
  // 私有方法 - 通知
  // ========================================

  /// 发送订单确认通知
  Future<void> _sendOrderConfirmationNotification(Order order) async {
    // TODO: 实现通知发送逻辑
    print('📧 发送订单确认通知: ${order.orderNumber}');
  }

  /// 发送状态变更通知
  Future<void> _sendStatusChangeNotification(
    Order order,
    OrderStatus newStatus,
    String? reason,
  ) async {
    // TODO: 实现通知发送逻辑
    print('📧 发送状态变更通知: ${order.orderNumber} -> ${newStatus.label}');
  }

  /// 发送制作通知
  Future<void> _sendCookingNotification(Order order) async {
    // TODO: 实现通知发送逻辑
    print('📧 发送制作开始通知: ${order.orderNumber}');
  }

  /// 发送完成通知
  Future<void> _sendCompletionNotification(Order order) async {
    // TODO: 实现通知发送逻辑
    print('📧 发送订单完成通知: ${order.orderNumber}');
  }

  /// 邀请评价
  Future<void> _inviteReview(Order order) async {
    // TODO: 实现评价邀请逻辑
    print('⭐ 邀请用户评价: ${order.orderNumber}');
  }

  /// 通知餐厅取消
  Future<void> _notifyRestaurantCancellation(Order order, String reason) async {
    // TODO: 实现餐厅通知逻辑
    print('📧 通知餐厅订单取消: ${order.orderNumber}');
  }

  /// 通知配送系统
  Future<void> _notifyDeliverySystem(Order order) async {
    // TODO: 实现配送系统通知逻辑
    print('🚚 通知配送系统: ${order.orderNumber}');
  }

  // ========================================
  // 私有方法 - 库存管理
  // ========================================

  /// 减少库存
  Future<void> _decreaseInventory(Order order) async {
    try {
      for (final item in order.items) {
        if (item.serviceDetailId != null) {
          await _supabase
              .rpc('decrease_item_stock', params: {
                'service_detail_id': item.serviceDetailId,
                'quantity': item.quantity,
              });
        }
      }
    } catch (e) {
      print('⚠️ 库存减少失败: $e');
    }
  }

  /// 恢复库存
  Future<void> _restoreInventory(Order order) async {
    try {
      for (final item in order.items) {
        if (item.serviceDetailId != null) {
          await _supabase
              .rpc('increase_item_stock', params: {
                'service_detail_id': item.serviceDetailId,
                'quantity': item.quantity,
              });
        }
      }
    } catch (e) {
      print('⚠️ 库存恢复失败: $e');
    }
  }

  // ========================================
  // 私有方法 - 取消政策
  // ========================================

  /// 检查取消政策
  Future<bool> _checkCancellationPolicy(Order order) async {
    final createdTime = order.createdAt;
    final now = DateTime.now();
    final timeDiff = now.difference(createdTime);

    // 如果订单创建不到5分钟，允许免费取消
    if (timeDiff.inMinutes < 5) {
      return true;
    }

    // 检查订单状态
    if (order.status == OrderStatus.inProgress) {
      return false; // 制作中不允许取消
    }

    return true;
  }

  /// 计算取消费用
  Future<Price> _calculateCancellationFee(Order order, String reason) async {
    final createdTime = order.createdAt;
    final now = DateTime.now();
    final timeDiff = now.difference(createdTime);

    // 免费取消期内
    if (timeDiff.inMinutes < 5) {
      return Price(amount: 0.0, currency: order.totalAmount.currency);
    }

    // 根据取消原因计算费用
    if (reason.contains('customer_request')) {
      // 客户主动取消，收取一定费用
      final feeAmount = order.totalAmount.amount * 0.1; // 10%取消费
      return Price(amount: feeAmount, currency: order.totalAmount.currency);
    }

    return Price(amount: 0.0, currency: order.totalAmount.currency);
  }

  // ========================================
  // 工具方法
  // ========================================

  /// 解析时间字符串
  Duration _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return Duration(hours: hours, minutes: minutes);
  }

  /// 获取指定类型费用的金额
  double _getFeeAmount(List<PricingFee> fees, String type) {
    final fee = fees.firstWhereOrNull((f) => f.type == type);
    return fee?.amount.amount ?? 0.0;
  }

  /// 获取费用总金额（不包括税费）
  double _getFeesTotalAmount(List<PricingFee> fees) {
    return fees
        .where((fee) => fee.type != 'tax')
        .fold(0.0, (sum, fee) => sum + fee.amount.amount);
  }

  /// 分类取消原因
  String _categorizeCancellationReason(String? reason) {
    if (reason == null) return 'unknown';
    
    if (reason.contains('customer_request')) return 'customer_initiated';
    if (reason.contains('restaurant_busy')) return 'restaurant_capacity';
    if (reason.contains('ingredient_unavailable')) return 'inventory_issue';
    if (reason.contains('delivery_issue')) return 'logistics_issue';
    
    return 'other';
  }
}

/// 餐饮行业支付处理器
class FoodIndustryPaymentHandler implements IndustryPaymentHandler {
  @override
  Future<void> preprocessPayment(Order order, PaymentMethod paymentMethod) async {
    print('🍽️💳 餐饮支付预处理');
    
    // 验证支付金额
    if (order.totalAmount.amount <= 0) {
      throw PaymentException('订单金额无效');
    }

    // 检查是否支持该支付方式
    if (paymentMethod.type == PaymentMethodType.cash) {
      throw PaymentException('餐饮外卖不支持现金支付');
    }
  }

  @override
  Future<void> postprocessPayment(Order order, Payment payment, bool success) async {
    if (success) {
      print('✅ 餐饮订单支付成功');
      
      // 发送支付成功通知
      // TODO: 实现通知逻辑
      
      // 自动接受订单（如果配置允许）
      // TODO: 实现自动接单逻辑
    } else {
      print('❌ 餐饮订单支付失败');
      
      // 恢复库存
      // TODO: 实现库存恢复逻辑
    }
  }

  @override
  Future<ValidationResult> validateRefund(Order order, Price amount, String reason) async {
    // 餐饮订单退款验证
    if (order.status == OrderStatus.completed) {
      final completedTime = order.getIndustryData<String>('actual_completion_time');
      if (completedTime != null) {
        final completed = DateTime.parse(completedTime);
        final now = DateTime.now();
        final timeDiff = now.difference(completed);
        
        // 完成后超过24小时不允许退款
        if (timeDiff.inHours > 24) {
          return ValidationResult.invalid(['订单完成超过24小时，不支持退款']);
        }
      }
    }

    return ValidationResult.valid();
  }

  @override
  Future<void> postprocessRefund(Order order, Payment refund, bool success) async {
    if (success) {
      print('✅ 餐饮订单退款成功');
      
      // 发送退款成功通知
      // TODO: 实现通知逻辑
    } else {
      print('❌ 餐饮订单退款失败');
      
      // 记录退款失败原因
      // TODO: 实现失败记录逻辑
    }
  }
}
