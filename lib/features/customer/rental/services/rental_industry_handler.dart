import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/base_models.dart';
import '../../../../core/models/order_models.dart';
import '../../../../core/models/payment_models.dart';
import '../../../../core/services/universal_order_service.dart';
import '../../../../core/services/universal_payment_service.dart';

/// 租赁共享行业订单处理器
/// 
/// 实现租赁共享行业特定的订单处理逻辑：
/// - 物品可用性和状态管理
/// - 租赁时间计算和定价
/// - 押金和保险处理
/// - 物品交付和归还流程
/// - 损坏评估和赔偿处理
class RentalIndustryOrderHandler implements IndustryOrderHandler {
  final _supabase = Supabase.instance.client;

  @override
  Future<void> preprocessOrder(OrderRequest request) async {
    print('🏠 租赁共享订单预处理');

    // 验证租赁时间
    if (request.scheduledTime == null) {
      throw OrderException('租赁服务必须指定租赁时间');
    }

    final rentalType = request.industrySpecificData.get<String>('rental_type', 'equipment');
    final rentalDuration = request.scheduledTime!.duration;

    // 验证租赁时长限制
    await _validateRentalDuration(rentalType ?? 'equipment', rentalDuration);

    // 检查物品可用性
    for (final item in request.items) {
      final isAvailable = await _checkItemAvailability(
        item.serviceDetailId,
        request.scheduledTime!,
      );
      if (!isAvailable) {
        throw OrderException('商品 ${item.name} 在选定时间不可用');
      }
    }

    // 验证取货地址
    if (request.serviceAddress == null) {
      throw OrderException('请设置取货地址');
    }

    // 检查服务覆盖范围
    final isInServiceArea = await _checkDeliveryRange(request.serviceAddress!);
    if (!isInServiceArea) {
      throw OrderException('该地址不在配送范围内');
    }

    // 验证用户资质
    await _validateUserQualifications(request);
  }

  @override
  Future<void> postprocessOrder(Order order) async {
    print('🏠 租赁共享订单后处理');

    final rentalType = order.getIndustryData<String>('rental_type', 'equipment');
    
    // 设置租赁特定的元数据
    order.setIndustryData('rental_category', await _getRentalCategory(order.serviceId));
    order.setIndustryData('deposit_amount', await _calculateDepositAmount(order));
    order.setIndustryData('insurance_fee', await _calculateInsuranceFee(order));
    order.setIndustryData('delivery_method', await _determineDeliveryMethod(order));
    
    // 设置租赁期限和关键时间点
    final scheduledTime = order.scheduledTime!;
    order.setIndustryData('rental_start_time', scheduledTime.start.toIso8601String());
    order.setIndustryData('rental_end_time', scheduledTime.end.toIso8601String());
    order.setIndustryData('pickup_deadline', _calculatePickupDeadline(scheduledTime.start));
    order.setIndustryData('return_deadline', _calculateReturnDeadline(scheduledTime.end));

    // 预留库存
    await _reserveInventory(order);

    // 根据租赁类型设置特定流程
    switch (rentalType) {
      case 'housing':
        await _setupHousingRental(order);
        break;
      case 'vehicle':
        await _setupVehicleRental(order);
        break;
      case 'equipment':
        await _setupEquipmentRental(order);
        break;
      case 'space':
        await _setupSpaceRental(order);
        break;
    }

    // 发送租赁确认通知
    await _sendRentalConfirmationNotification(order);
  }

  @override
  Future<ValidationResult> validateOrder(OrderRequest request) async {
    final errors = <String>[];
    final fieldErrors = <String, String>{};

    // 验证租赁时间
    if (request.scheduledTime == null) {
      fieldErrors['scheduled_time'] = '请选择租赁时间';
    } else {
      final timeValidation = await _validateRentalTime(request.scheduledTime!);
      if (!timeValidation.isValid) {
        fieldErrors['scheduled_time'] = timeValidation.firstError;
      }
    }

    // 验证租赁类型
    final rentalType = request.industrySpecificData.get<String>('rental_type');
    if (rentalType == null || !['housing', 'vehicle', 'equipment', 'space'].contains(rentalType)) {
      fieldErrors['rental_type'] = '请选择有效的租赁类型';
    }

    // 验证取货地址
    if (request.serviceAddress == null) {
      fieldErrors['delivery_address'] = '请设置取货地址';
    }

    // 验证租赁物品
    for (int i = 0; i < request.items.length; i++) {
      final item = request.items[i];
      final itemValidation = await _validateRentalItem(item, rentalType!);
      if (!itemValidation.isValid) {
        fieldErrors['items[$i]'] = itemValidation.firstError;
      }
    }

    // 验证用户资格
    if (rentalType != null) {
      final qualificationValidation = await _validateUserQualifications(request);
      if (!qualificationValidation.isValid) {
        errors.addAll(qualificationValidation.errors);
      }
    }

    // 验证特殊要求
    final specialRequirements = request.industrySpecificData.get<Map<String, dynamic>>('special_requirements');
    if (specialRequirements != null) {
      final reqValidation = await _validateSpecialRequirements(specialRequirements, rentalType!);
      if (!reqValidation.isValid) {
        errors.addAll(reqValidation.errors);
      }
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
    print('🧮 租赁共享定价调整');

    final adjustedFees = List<PricingFee>.from(fees);
    final adjustedDiscounts = List<PricingDiscount>.from(discounts);

    final rentalType = request.industrySpecificData.get<String>('rental_type', 'equipment');
    final rentalDuration = request.scheduledTime!.duration;

    // 添加租赁特定费用
    await _addRentalDurationFees(adjustedFees, rentalDuration, rentalType ?? 'equipment', baseAmount);
    await _addDepositFee(adjustedFees, request, baseAmount);
    await _addInsuranceFee(adjustedFees, request, baseAmount);
    await _addDeliveryFees(adjustedFees, request.serviceAddress!, baseAmount);
    await _addSeasonalFees(adjustedFees, request.scheduledTime!.start, baseAmount);

    // 检查租赁优惠
    await _checkRentalPromotions(adjustedDiscounts, baseAmount, request);

    // 计算最终价格
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
        'base_rental_fee': baseAmount.amount,
        'duration_fee': _getFeeAmount(adjustedFees, 'duration'),
        'deposit_fee': _getFeeAmount(adjustedFees, 'deposit'),
        'insurance_fee': _getFeeAmount(adjustedFees, 'insurance'),
        'delivery_fee': _getFeeAmount(adjustedFees, 'delivery'),
        'seasonal_fee': _getFeeAmount(adjustedFees, 'seasonal'),
        'cleaning_fee': _getFeeAmount(adjustedFees, 'cleaning'),
        'total_discounts': discountsTotal.amount,
        'final_total': totalAmount.amount,
      },
    );
  }

  @override
  Future<void> onStatusChange(Order order, OrderStatus newStatus, String? reason) async {
    print('🔄 租赁共享订单状态变更: ${order.status.label} -> ${newStatus.label}');

    switch (newStatus) {
      case OrderStatus.accepted:
        await _onRentalAccepted(order);
        break;
      case OrderStatus.inProgress:
        await _onRentalStarted(order);
        break;
      case OrderStatus.completed:
        await _onRentalCompleted(order);
        break;
      case OrderStatus.cancelled:
        await _onRentalCancelled(order, reason);
        break;
      default:
        break;
    }

    // 发送状态更新通知
    await _sendStatusUpdateNotification(order, newStatus, reason);
  }

  @override
  Future<void> onOrderCancellation(Order order, String reason) async {
    print('❌ 租赁共享订单取消处理');

    // 检查取消政策
    final cancellationPolicy = await _checkCancellationPolicy(order);
    if (!cancellationPolicy.canCancel) {
      throw OrderException(cancellationPolicy.reason ?? '订单无法取消');
    }

    // 计算取消费用
    final cancellationFee = await _calculateCancellationFee(order, reason);
    if (cancellationFee.amount > 0) {
      print('💰 取消费用: ${cancellationFee.formatted}');
    }

    // 释放库存预留
    await _releaseInventoryReservation(order);

    // 通知相关方
    await _notifyRentalCancellation(order, reason);
  }

  // ========================================
  // 私有方法 - 验证逻辑
  // ========================================

  /// 验证租赁时长
  Future<void> _validateRentalDuration(String rentalType, Duration duration) async {
    final limits = await _getRentalDurationLimits(rentalType);
    
    if (duration < limits.minimum) {
      throw OrderException('${_getRentalTypeName(rentalType)}最短租赁时间为${_formatDuration(limits.minimum)}');
    }
    
    if (duration > limits.maximum) {
      throw OrderException('${_getRentalTypeName(rentalType)}最长租赁时间为${_formatDuration(limits.maximum)}');
    }
  }

  /// 检查物品可用性
  Future<bool> _checkItemAvailability(String itemId, TimeRange rentalTime) async {
    try {
      // 检查物品是否在租赁时间段内已被预订
      final conflicts = await _supabase
          .from('rental_bookings')
          .select('id')
          .eq('item_id', itemId)
          .neq('status', 'cancelled')
          .gte('start_time', rentalTime.start.toIso8601String())
          .lte('end_time', rentalTime.end.toIso8601String());

      return conflicts.isEmpty;
    } catch (e) {
      print('⚠️ 物品可用性检查失败: $e');
      return false;
    }
  }

  /// 检查配送范围
  Future<bool> _checkDeliveryRange(Address address) async {
    try {
      final deliveryZones = await _supabase
          .from('rental_delivery_zones')
          .select('zone_type, zone_config')
          .eq('is_active', true);

      for (final zone in deliveryZones) {
        final zoneType = zone['zone_type'];
        final config = zone['zone_config'] as Map<String, dynamic>;

        switch (zoneType) {
          case 'postal_codes':
            final codes = (config['postal_codes'] as List).cast<String>();
            if (codes.contains(address.postalCode)) return true;
            break;
          case 'city_coverage':
            final cities = (config['cities'] as List).cast<String>();
            if (cities.contains(address.city?.toLowerCase() ?? '')) return true;
            break;
        }
      }

      return false;
    } catch (e) {
      print('⚠️ 配送范围检查失败: $e');
      return true; // 默认允许
    }
  }

  /// 验证用户资质
  Future<ValidationResult> _validateUserQualifications(OrderRequest request) async {
    final errors = <String>[];
    final rentalType = request.industrySpecificData.get<String>('rental_type');

    // 年龄验证
    final userAge = request.industrySpecificData.get<int>('user_age');
    if (userAge != null) {
      final minAge = await _getMinimumAge(rentalType!);
      if (userAge < minAge) {
        errors.add('租赁${_getRentalTypeName(rentalType)}需要年满${minAge}岁');
      }
    }

    // 驾照验证（车辆租赁）
    if (rentalType == 'vehicle') {
      final hasValidLicense = request.industrySpecificData.get<bool>('has_valid_license', false) ?? false;
      if (!hasValidLicense) {
        errors.add('车辆租赁需要有效的驾驶证');
      }
    }

    // 信用验证
    final creditScore = request.industrySpecificData.get<int>('credit_score');
    if (creditScore != null) {
      final minCreditScore = await _getMinimumCreditScore(rentalType!);
      if (creditScore < minCreditScore) {
        errors.add('信用评分不满足租赁要求');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 验证租赁时间
  Future<ValidationResult> _validateRentalTime(TimeRange rentalTime) async {
    final errors = <String>[];

    // 检查开始时间不能是过去
    if (rentalTime.start.isBefore(DateTime.now())) {
      errors.add('租赁开始时间不能是过去时间');
    }

    // 检查最小提前预订时间
    final minAdvanceHours = 2;
    if (rentalTime.start.isBefore(DateTime.now().add(Duration(hours: minAdvanceHours)))) {
      errors.add('请至少提前${minAdvanceHours}小时预订');
    }

    // 检查最大提前预订时间
    final maxAdvanceDays = 90;
    if (rentalTime.start.isAfter(DateTime.now().add(Duration(days: maxAdvanceDays)))) {
      errors.add('最多只能提前${maxAdvanceDays}天预订');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 验证租赁物品
  Future<ValidationResult> _validateRentalItem(OrderItemRequest item, String rentalType) async {
    try {
      final itemDetails = await _supabase
          .from('rental_items')
          .select('is_available, rental_config, condition_status')
          .eq('id', item.serviceDetailId)
          .single();

      if (!itemDetails['is_available']) {
        return ValidationResult.invalid(['物品当前不可租赁']);
      }

      final condition = itemDetails['condition_status'] as String?;
      if (condition != null && !['excellent', 'good'].contains(condition)) {
        return ValidationResult.invalid(['物品状态不适合租赁']);
      }

      final config = itemDetails['rental_config'] as Map<String, dynamic>?;
      if (config != null) {
        // 检查数量限制
        final maxQuantity = config['max_quantity_per_order'] as int?;
        if (maxQuantity != null && item.quantity > maxQuantity) {
          return ValidationResult.invalid(['单次租赁数量不能超过${maxQuantity}件']);
        }
      }

      return ValidationResult.valid();
    } catch (e) {
      return ValidationResult.invalid(['物品验证失败']);
    }
  }

  /// 验证特殊要求
  Future<ValidationResult> _validateSpecialRequirements(
    Map<String, dynamic> requirements,
    String rentalType,
  ) async {
    final errors = <String>[];

    // 验证配送要求
    if (requirements['requires_assembly'] == true) {
      final hasAssemblyService = await _checkAssemblyService();
      if (!hasAssemblyService) {
        errors.add('当前不提供组装服务');
      }
    }

    // 验证特殊装备要求
    if (requirements['requires_training'] == true) {
      final hasTraining = await _checkTrainingAvailability();
      if (!hasTraining) {
        errors.add('当前不提供使用培训服务');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // ========================================
  // 私有方法 - 定价逻辑
  // ========================================

  /// 添加租赁时长费用
  Future<void> _addRentalDurationFees(
    List<PricingFee> fees,
    Duration duration,
    String rentalType,
    Price baseAmount,
  ) async {
    // 超出基础时长的额外费用
    final baseHours = await _getBaseDuration(rentalType);
    if (duration.inHours > baseHours) {
      final extraHours = duration.inHours - baseHours;
      final hourlyRate = await _getHourlyRate(rentalType);
      final extraFee = extraHours * hourlyRate;

      fees.add(PricingFee(
        type: 'duration',
        name: '超时费用',
        amount: Price(amount: extraFee, currency: baseAmount.currency),
        description: '超出${baseHours}小时，额外${extraHours}小时 × \$${hourlyRate.toStringAsFixed(2)}/小时',
      ));
    }
  }

  /// 添加押金费用
  Future<void> _addDepositFee(
    List<PricingFee> fees,
    OrderRequest request,
    Price baseAmount,
  ) async {
    final depositAmount = await _calculateDepositAmount2(request);
    
    if (depositAmount > 0) {
      fees.add(PricingFee(
        type: 'deposit',
        name: '安全押金',
        amount: Price(amount: depositAmount, currency: baseAmount.currency),
        description: '租赁安全押金（归还时退还）',
      ));
    }
  }

  /// 添加保险费用
  Future<void> _addInsuranceFee(
    List<PricingFee> fees,
    OrderRequest request,
    Price baseAmount,
  ) async {
    final needsInsurance = request.industrySpecificData.get<bool>('needs_insurance', true) ?? true;
    if (!needsInsurance) return;

    final insuranceFee = await _calculateInsuranceFee2(request);
    
    if (insuranceFee > 0) {
      fees.add(PricingFee(
        type: 'insurance',
        name: '租赁保险',
        amount: Price(amount: insuranceFee, currency: baseAmount.currency),
        description: '物品损坏和意外保险',
      ));
    }
  }

  /// 添加配送费用
  Future<void> _addDeliveryFees(
    List<PricingFee> fees,
    Address address,
    Price baseAmount,
  ) async {
    final deliveryMethod = await _getDeliveryMethod(address);
    
    switch (deliveryMethod) {
      case 'standard':
        fees.add(PricingFee(
          type: 'delivery',
          name: '标准配送',
          amount: Price(amount: 25.0, currency: baseAmount.currency),
          description: '2-3个工作日配送',
        ));
        break;
      case 'express':
        fees.add(PricingFee(
          type: 'delivery',
          name: '快速配送',
          amount: Price(amount: 50.0, currency: baseAmount.currency),
          description: '当日或次日配送',
        ));
        break;
      case 'pickup':
        // 自取无配送费
        break;
    }

    // 清洁费
    fees.add(PricingFee(
      type: 'cleaning',
      name: '清洁费',
      amount: Price(amount: 15.0, currency: baseAmount.currency),
      description: '物品清洁和消毒费用',
    ));
  }

  /// 添加季节性费用
  Future<void> _addSeasonalFees(
    List<PricingFee> fees,
    DateTime rentalStart,
    Price baseAmount,
  ) async {
    final seasonalMultiplier = await _getSeasonalMultiplier(rentalStart);
    
    if (seasonalMultiplier > 1.0) {
      final seasonalFee = baseAmount.amount * (seasonalMultiplier - 1.0);
      
      fees.add(PricingFee(
        type: 'seasonal',
        name: '季节性加价',
        amount: Price(amount: seasonalFee, currency: baseAmount.currency),
        description: '高需求季节加价（${seasonalMultiplier.toStringAsFixed(1)}x）',
      ));
    }
  }

  /// 检查租赁优惠
  Future<void> _checkRentalPromotions(
    List<PricingDiscount> discounts,
    Price baseAmount,
    OrderRequest request,
  ) async {
    // 长期租赁折扣
    final duration = request.scheduledTime!.duration;
    if (duration.inDays >= 7) {
      final discountRate = duration.inDays >= 30 ? 0.2 : 0.1;
      discounts.add(PricingDiscount(
        type: 'long_term',
        name: '长期租赁优惠',
        amount: Price(amount: baseAmount.amount * discountRate, currency: baseAmount.currency),
        description: '${duration.inDays >= 30 ? "月租" : "周租"}享受${(discountRate * 100).toInt()}%折扣',
      ));
    }

    // 首次租赁优惠
    final isFirstTime = request.industrySpecificData.get<bool>('is_first_time_renter', false) ?? false;
    if (isFirstTime) {
      discounts.add(PricingDiscount(
        type: 'first_time',
        name: '首次租赁优惠',
        amount: Price(amount: 30.0, currency: baseAmount.currency),
        description: '首次使用租赁服务优惠',
      ));
    }

    // 多物品打包优惠
    if (request.items.length >= 3) {
      final packageDiscount = baseAmount.amount * 0.15;
      discounts.add(PricingDiscount(
        type: 'package',
        name: '多物品打包优惠',
        amount: Price(amount: packageDiscount, currency: baseAmount.currency),
        description: '3件及以上物品享受15%折扣',
      ));
    }
  }

  // ========================================
  // 私有方法 - 状态处理
  // ========================================

  /// 租赁被接受时的处理
  Future<void> _onRentalAccepted(Order order) async {
    print('✅ 租赁订单已接受');

    // 确认库存预留
    await _confirmInventoryReservation(order);

    // 安排物品准备
    await _scheduleItemPreparation(order);

    // 安排配送
    await _scheduleDelivery(order);

    // 发送准备通知
    await _sendPreparationNotification(order);
  }

  /// 租赁开始时的处理
  Future<void> _onRentalStarted(Order order) async {
    print('🏠 租赁开始');

    // 记录租赁开始时间
    order.setIndustryData('actual_start_time', DateTime.now().toIso8601String());

    // 更新物品状态为已租出
    await _updateItemStatusToRented(order);

    // 发送租赁开始通知
    await _sendRentalStartNotification(order);

    // 设置归还提醒
    await _scheduleReturnReminders(order);
  }

  /// 租赁完成时的处理
  Future<void> _onRentalCompleted(Order order) async {
    print('🎉 租赁完成');

    // 记录租赁结束时间
    order.setIndustryData('actual_end_time', DateTime.now().toIso8601String());

    // 进行物品检查和损坏评估
    await _conductItemInspection(order);

    // 处理押金退还
    await _processDepositReturn(order);

    // 更新物品状态
    await _updateItemStatusToAvailable(order);

    // 发送完成通知和评价邀请
    await _sendRentalCompletionNotification(order);
    await _inviteRentalReview(order);
  }

  /// 租赁取消时的处理
  Future<void> _onRentalCancelled(Order order, String? reason) async {
    print('❌ 租赁已取消: $reason');

    // 记录取消信息
    order.setIndustryData('cancellation_time', DateTime.now().toIso8601String());
    order.setIndustryData('cancellation_category', _categorizeCancellationReason(reason));

    // 释放库存预留
    await _releaseInventoryReservation(order);

    // 取消配送安排
    await _cancelDeliveryArrangement(order);
  }

  // ========================================
  // 私有方法 - 辅助功能
  // ========================================

  /// 获取租赁类型名称
  String _getRentalTypeName(String type) {
    switch (type) {
      case 'housing':
        return '房屋';
      case 'vehicle':
        return '车辆';
      case 'equipment':
        return '设备';
      case 'space':
        return '场地';
      default:
        return '物品';
    }
  }

  /// 格式化时长
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}天';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}小时';
    } else {
      return '${duration.inMinutes}分钟';
    }
  }

  /// 计算取货截止时间
  String _calculatePickupDeadline(DateTime startTime) {
    return startTime.add(const Duration(hours: 2)).toIso8601String();
  }

  /// 计算归还截止时间
  String _calculateReturnDeadline(DateTime endTime) {
    return endTime.add(const Duration(hours: 4)).toIso8601String();
  }

  /// 工具方法
  double _getFeeAmount(List<PricingFee> fees, String type) {
    final fee = fees.firstWhereOrNull((f) => f.type == type);
    return fee?.amount.amount ?? 0.0;
  }

  String _categorizeCancellationReason(String? reason) {
    if (reason == null) return 'unknown';
    
    if (reason.contains('item_unavailable')) return 'inventory_issue';
    if (reason.contains('customer_request')) return 'customer_initiated';
    if (reason.contains('payment_failed')) return 'payment_issue';
    if (reason.contains('weather')) return 'weather_related';
    
    return 'other';
  }

  // ========================================
  // 私有方法 - 占位符实现
  // ========================================

  Future<({Duration minimum, Duration maximum})> _getRentalDurationLimits(String rentalType) async {
    // TODO: 从配置获取租赁时长限制
    switch (rentalType) {
      case 'housing':
        return (minimum: const Duration(days: 1), maximum: const Duration(days: 365));
      case 'vehicle':
        return (minimum: const Duration(hours: 1), maximum: const Duration(days: 30));
      case 'equipment':
        return (minimum: const Duration(hours: 4), maximum: const Duration(days: 90));
      case 'space':
        return (minimum: const Duration(hours: 1), maximum: const Duration(days: 7));
      default:
        return (minimum: const Duration(hours: 1), maximum: const Duration(days: 30));
    }
  }

  Future<int> _getMinimumAge(String rentalType) async {
    // TODO: 从配置获取最小年龄要求
    switch (rentalType) {
      case 'vehicle':
        return 25;
      case 'housing':
        return 18;
      default:
        return 16;
    }
  }

  Future<int> _getMinimumCreditScore(String rentalType) async {
    // TODO: 从配置获取最小信用评分
    switch (rentalType) {
      case 'housing':
        return 650;
      case 'vehicle':
        return 600;
      default:
        return 550;
    }
  }

  Future<bool> _checkAssemblyService() async {
    // TODO: 检查组装服务可用性
    return true;
  }

  Future<bool> _checkTrainingAvailability() async {
    // TODO: 检查培训服务可用性
    return true;
  }

  Future<int> _getBaseDuration(String rentalType) async {
    // TODO: 获取基础租赁时长
    switch (rentalType) {
      case 'vehicle':
        return 24; // 24小时
      case 'equipment':
        return 8; // 8小时
      default:
        return 4; // 4小时
    }
  }

  Future<double> _getHourlyRate(String rentalType) async {
    // TODO: 获取小时费率
    switch (rentalType) {
      case 'vehicle':
        return 15.0;
      case 'equipment':
        return 8.0;
      default:
        return 5.0;
    }
  }

  Future<double> _calculateDepositAmount(Order order) async {
    // TODO: 计算押金金额
    return order.totalAmount.amount * 0.3; // 30%押金
  }

  Future<double> _calculateDepositAmount2(OrderRequest request) async {
    // TODO: 计算押金金额
    return request.estimatedTotal * 0.3; // 30%押金
  }

  Future<double> _calculateInsuranceFee(Order order) async {
    // TODO: 计算保险费
    return order.totalAmount.amount * 0.05; // 5%保险费
  }

  Future<double> _calculateInsuranceFee2(OrderRequest request) async {
    // TODO: 计算保险费
    return request.estimatedTotal * 0.05; // 5%保险费
  }

  Future<String> _determineDeliveryMethod(Order order) async {
    // TODO: 确定配送方式
    return 'standard';
  }

  Future<String> _getDeliveryMethod(Address address) async {
    // TODO: 根据地址确定配送方式
    return 'standard';
  }

  Future<double> _getSeasonalMultiplier(DateTime date) async {
    // TODO: 获取季节性倍数
    return 1.0; // 无季节性加价
  }

  Future<String> _getRentalCategory(String serviceId) async {
    // TODO: 获取租赁分类
    return 'general';
  }

  Future<void> _reserveInventory(Order order) async {
    // TODO: 预留库存
    print('📦 预留库存');
  }

  Future<void> _setupHousingRental(Order order) async {
    // TODO: 设置房屋租赁特定流程
    print('🏠 设置房屋租赁流程');
  }

  Future<void> _setupVehicleRental(Order order) async {
    // TODO: 设置车辆租赁特定流程
    print('🚗 设置车辆租赁流程');
  }

  Future<void> _setupEquipmentRental(Order order) async {
    // TODO: 设置设备租赁特定流程
    print('🔧 设置设备租赁流程');
  }

  Future<void> _setupSpaceRental(Order order) async {
    // TODO: 设置场地租赁特定流程
    print('🏢 设置场地租赁流程');
  }

  Future<void> _sendRentalConfirmationNotification(Order order) async {
    // TODO: 发送租赁确认通知
    print('📧 发送租赁确认通知');
  }

  Future<void> _sendStatusUpdateNotification(Order order, OrderStatus status, String? reason) async {
    // TODO: 发送状态更新通知
    print('📧 发送状态更新通知: ${status.label}');
  }

  Future<({bool canCancel, String? reason})> _checkCancellationPolicy(Order order) async {
    // TODO: 检查取消政策
    return (canCancel: true, reason: null);
  }

  Future<Price> _calculateCancellationFee(Order order, String reason) async {
    // TODO: 计算取消费用
    return Price(amount: 0.0, currency: order.totalAmount.currency);
  }

  Future<void> _releaseInventoryReservation(Order order) async {
    // TODO: 释放库存预留
    print('🔓 释放库存预留');
  }

  Future<void> _notifyRentalCancellation(Order order, String reason) async {
    // TODO: 通知租赁取消
    print('📧 通知租赁取消');
  }

  Future<void> _confirmInventoryReservation(Order order) async {
    // TODO: 确认库存预留
    print('✅ 确认库存预留');
  }

  Future<void> _scheduleItemPreparation(Order order) async {
    // TODO: 安排物品准备
    print('📋 安排物品准备');
  }

  Future<void> _scheduleDelivery(Order order) async {
    // TODO: 安排配送
    print('🚚 安排配送');
  }

  Future<void> _sendPreparationNotification(Order order) async {
    // TODO: 发送准备通知
    print('📧 发送准备通知');
  }

  Future<void> _updateItemStatusToRented(Order order) async {
    // TODO: 更新物品状态为已租出
    print('📊 更新物品状态为已租出');
  }

  Future<void> _sendRentalStartNotification(Order order) async {
    // TODO: 发送租赁开始通知
    print('📧 发送租赁开始通知');
  }

  Future<void> _scheduleReturnReminders(Order order) async {
    // TODO: 设置归还提醒
    print('⏰ 设置归还提醒');
  }

  Future<void> _conductItemInspection(Order order) async {
    // TODO: 进行物品检查
    print('🔍 进行物品检查');
  }

  Future<void> _processDepositReturn(Order order) async {
    // TODO: 处理押金退还
    print('💰 处理押金退还');
  }

  Future<void> _updateItemStatusToAvailable(Order order) async {
    // TODO: 更新物品状态为可用
    print('📊 更新物品状态为可用');
  }

  Future<void> _sendRentalCompletionNotification(Order order) async {
    // TODO: 发送完成通知
    print('📧 发送租赁完成通知');
  }

  Future<void> _inviteRentalReview(Order order) async {
    // TODO: 邀请租赁评价
    print('⭐ 邀请租赁评价');
  }

  Future<void> _cancelDeliveryArrangement(Order order) async {
    // TODO: 取消配送安排
    print('❌ 取消配送安排');
  }
}

/// 租赁共享行业支付处理器
class RentalIndustryPaymentHandler implements IndustryPaymentHandler {
  @override
  Future<void> preprocessPayment(Order order, PaymentMethod paymentMethod) async {
    print('🏠💳 租赁共享支付预处理');
    
    // 验证支付金额
    if (order.totalAmount.amount <= 0) {
      throw PaymentException('订单金额无效');
    }

    // 租赁服务通常需要信用卡支付（用于押金授权）
    final rentalType = order.getIndustryData<String>('rental_type', 'equipment');
    if (['vehicle', 'housing'].contains(rentalType) && !paymentMethod.type.isCard) {
      throw PaymentException('${rentalType == "vehicle" ? "车辆" : "房屋"}租赁需要使用信用卡支付');
    }

    // 检查押金授权
    final depositAmount = order.getIndustryData<double>('deposit_amount', 0.0) ?? 0.0;
    if (depositAmount > 0) {
      // TODO: 验证信用卡额度是否足够支付押金
    }
  }

  @override
  Future<void> postprocessPayment(Order order, Payment payment, bool success) async {
    if (success) {
      print('✅ 租赁共享支付成功');
      
      // 进行押金预授权
      final depositAmount = order.getIndustryData<double>('deposit_amount', 0.0) ?? 0.0;
      if (depositAmount > 0) {
        // TODO: 实现押金预授权逻辑
      }
      
      // 发送支付确认和租赁准备通知
      // TODO: 实现通知逻辑
    } else {
      print('❌ 租赁共享支付失败');
      
      // 释放库存预留
      // TODO: 实现库存释放逻辑
    }
  }

  @override
  Future<ValidationResult> validateRefund(Order order, Price amount, String reason) async {
    // 租赁共享退款验证
    final actualStartTime = order.getIndustryData<String>('actual_start_time');
    if (actualStartTime != null) {
      // 租赁已开始的退款政策
      final started = DateTime.parse(actualStartTime);
      final now = DateTime.now();
      final rentalDuration = now.difference(started);
      
      // 根据已使用时间计算可退款金额
      final totalDuration = order.scheduledTime?.duration ?? Duration.zero;
      if (rentalDuration >= totalDuration) {
        return ValidationResult.invalid(['租赁期已满，无法申请退款']);
      }
      
      // 计算最大可退款比例
      final usedRatio = rentalDuration.inMinutes / totalDuration.inMinutes;
      final maxRefundRatio = 1.0 - usedRatio - 0.1; // 扣除10%手续费
      
      if (maxRefundRatio <= 0) {
        return ValidationResult.invalid(['已使用时间过长，无法申请退款']);
      }
      
      final maxRefundAmount = order.totalAmount.amount * maxRefundRatio;
      if (amount.amount > maxRefundAmount) {
        return ValidationResult.invalid(['退款金额超过可退额度：\$${maxRefundAmount.toStringAsFixed(2)}']);
      }
    } else {
      // 租赁未开始的退款政策
      final scheduledStart = order.scheduledTime?.start;
      if (scheduledStart != null) {
        final timeToStart = scheduledStart.difference(DateTime.now());
        
        // 24小时内开始的租赁收取取消费
        if (timeToStart.inHours < 24) {
          final cancellationFee = order.totalAmount.amount * 0.2; // 20%取消费
          final maxRefund = order.totalAmount.amount - cancellationFee;
          
          if (amount.amount > maxRefund) {
            return ValidationResult.invalid(['24小时内取消需收取20%取消费']);
          }
        }
      }
    }

    return ValidationResult.valid();
  }

  @override
  Future<void> postprocessRefund(Order order, Payment refund, bool success) async {
    if (success) {
      print('✅ 租赁共享退款成功');
      
      // 处理押金释放
      final depositAmount = order.getIndustryData<double>('deposit_amount', 0.0) ?? 0.0;
      if (depositAmount > 0) {
        // TODO: 实现押金释放逻辑
      }
      
      // 发送退款通知
      // TODO: 实现退款通知逻辑
      
      // 释放库存
      // TODO: 实现库存释放逻辑
    } else {
      print('❌ 租赁共享退款失败');
      
      // 记录退款失败原因
      // TODO: 实现失败记录逻辑
    }
  }
}
