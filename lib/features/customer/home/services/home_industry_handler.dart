import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/base_models.dart';
import '../../../../core/models/order_models.dart';
import '../../../../core/models/payment_models.dart';
import '../../../../core/services/universal_order_service.dart';
import '../../../../core/services/universal_payment_service.dart';

/// 家居服务行业订单处理器
/// 
/// 实现家居服务行业特定的订单处理逻辑：
/// - 上门服务时间预约和确认
/// - 服务人员资质验证
/// - 服务工具和材料管理
/// - 现场评估和报价
/// - 服务质量跟踪和评价
class HomeIndustryOrderHandler implements IndustryOrderHandler {
  final _supabase = Supabase.instance.client;

  @override
  Future<void> preprocessOrder(OrderRequest request) async {
    print('🏠 家居服务订单预处理');

    // 验证服务地址（家居服务必须有地址）
    if (request.serviceAddress == null) {
      throw OrderException('家居服务必须提供服务地址');
    }

    // 验证服务时间（大多数家居服务需要预约）
    if (request.orderType == 'scheduled' && request.scheduledTime == null) {
      throw OrderException('预约服务必须选择服务时间');
    }

    // 检查服务区域覆盖
    final isInServiceArea = await _checkServiceCoverage(
      request.serviceId,
      request.serviceAddress!,
    );
    if (!isInServiceArea) {
      throw OrderException('抱歉，该地区暂不提供服务');
    }

    // 验证服务商可用性
    final isProviderAvailable = await _checkProviderAvailability(
      request.providerId,
      request.scheduledTime,
    );
    if (!isProviderAvailable) {
      throw OrderException('服务商在选定时间不可用，请选择其他时间');
    }

    // 检查特殊服务要求
    await _validateSpecialRequirements(request);
  }

  @override
  Future<void> postprocessOrder(Order order) async {
    print('🏠 家居服务订单后处理');

    // 设置家居服务特定的元数据
    order.setIndustryData('service_category', _getServiceCategory(order.serviceId));
    order.setIndustryData('requires_tools', await _checkToolsRequired(order.serviceId));
    order.setIndustryData('estimated_duration', await _getEstimatedDuration(order.serviceId));
    order.setIndustryData('skill_level_required', await _getRequiredSkillLevel(order.serviceId));
    
    // 设置默认服务窗口
    if (order.orderType == 'scheduled') {
      final serviceWindow = await _calculateServiceWindow(order);
      order.setIndustryData('service_window', serviceWindow);
    }

    // 创建服务准备清单
    await _createServicePreparationList(order);

    // 发送预约确认通知
    await _sendAppointmentConfirmation(order);
  }

  @override
  Future<ValidationResult> validateOrder(OrderRequest request) async {
    final errors = <String>[];
    final fieldErrors = <String, String>{};

    // 验证服务地址
    if (request.serviceAddress == null) {
      fieldErrors['service_address'] = '请提供服务地址';
    } else {
      // 验证地址格式和可达性
      final addressValidation = await _validateServiceAddress(request.serviceAddress!);
      if (!addressValidation.isValid) {
        fieldErrors['service_address'] = addressValidation.firstError;
      }
    }

    // 验证服务时间
    if (request.orderType == 'scheduled') {
      if (request.scheduledTime == null) {
        fieldErrors['scheduled_time'] = '请选择服务时间';
      } else {
        final timeValidation = await _validateServiceTime(request.scheduledTime!);
        if (!timeValidation.isValid) {
          fieldErrors['scheduled_time'] = timeValidation.firstError;
        }
      }
    }

    // 验证服务项目
    for (int i = 0; i < request.items.length; i++) {
      final item = request.items[i];
      
      // 检查服务可用性
      final serviceValidation = await _validateServiceItem(item);
      if (!serviceValidation.isValid) {
        fieldErrors['items[$i]'] = serviceValidation.firstError;
      }
    }

    // 验证特殊要求
    final specialRequirements = request.industrySpecificData.get<Map<String, dynamic>>('special_requirements');
    if (specialRequirements != null) {
      final requirementValidation = await _validateSpecialRequirements(request);
      if (!requirementValidation.isValid) {
        errors.addAll(requirementValidation.errors);
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
    print('🧮 家居服务定价调整');

    final adjustedFees = List<PricingFee>.from(fees);
    final adjustedDiscounts = List<PricingDiscount>.from(discounts);

    // 添加家居服务特定费用
    await _addTransportationFee(adjustedFees, request.serviceAddress!, baseAmount);
    await _addToolsAndMaterialsFee(adjustedFees, request.items);
    await _addUrgencyFee(adjustedFees, request);
    await _addComplexityFee(adjustedFees, request.items, baseAmount);

    // 检查家居服务促销
    await _checkHomeServicePromotions(adjustedDiscounts, baseAmount, request);

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
        'service_base_price': baseAmount.amount,
        'transportation_fee': _getFeeAmount(adjustedFees, 'transportation'),
        'tools_materials_fee': _getFeeAmount(adjustedFees, 'tools_materials'),
        'urgency_fee': _getFeeAmount(adjustedFees, 'urgency'),
        'complexity_fee': _getFeeAmount(adjustedFees, 'complexity'),
        'service_tax': _getFeeAmount(adjustedFees, 'tax'),
        'total_discounts': discountsTotal.amount,
        'final_total': totalAmount.amount,
      },
    );
  }

  @override
  Future<void> onStatusChange(Order order, OrderStatus newStatus, String? reason) async {
    print('🔄 家居服务订单状态变更: ${order.status.label} -> ${newStatus.label}');

    switch (newStatus) {
      case OrderStatus.accepted:
        await _onServiceAccepted(order);
        break;
      case OrderStatus.inProgress:
        await _onServiceStarted(order);
        break;
      case OrderStatus.completed:
        await _onServiceCompleted(order);
        break;
      case OrderStatus.cancelled:
        await _onServiceCancelled(order, reason);
        break;
      default:
        break;
    }

    // 发送状态更新通知
    await _sendStatusUpdateNotification(order, newStatus, reason);
  }

  @override
  Future<void> onOrderCancellation(Order order, String reason) async {
    print('❌ 家居服务订单取消处理');

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

    // 释放服务商时间
    await _releaseProviderSchedule(order);

    // 通知相关方
    await _notifyServiceCancellation(order, reason);
  }

  // ========================================
  // 私有方法 - 验证逻辑
  // ========================================

  /// 检查服务覆盖范围
  Future<bool> _checkServiceCoverage(String serviceId, Address address) async {
    try {
      final response = await _supabase
          .from('home_service_areas')
          .select('coverage_type, coverage_config')
          .eq('service_id', serviceId)
          .eq('is_active', true);

      if (response.isEmpty) return false;

      for (final area in response) {
        final coverageType = area['coverage_type'];
        final config = area['coverage_config'] as Map<String, dynamic>;

        switch (coverageType) {
          case 'postal_codes':
            final codes = (config['postal_codes'] as List).cast<String>();
            if (address.postalCode != null && codes.contains(address.postalCode!)) return true;
            break;
          case 'city_coverage':
            final cities = (config['cities'] as List).cast<String>();
            if (address.city != null && cities.contains(address.city!.toLowerCase())) return true;
            break;
          case 'radius_coverage':
            // TODO: 实现基于半径的覆盖检查
            return true;
        }
      }

      return false;
    } catch (e) {
      print('⚠️ 服务覆盖检查失败: $e');
      return true; // 默认允许
    }
  }

  /// 检查服务商可用性
  Future<bool> _checkProviderAvailability(String providerId, TimeRange? scheduledTime) async {
    if (scheduledTime == null) return true;

    try {
      final conflicts = await _supabase
          .from('provider_schedules')
          .select('start_time, end_time')
          .eq('provider_id', providerId)
          .eq('is_booked', true)
          .gte('start_time', scheduledTime.start.toIso8601String())
          .lte('end_time', scheduledTime.end.toIso8601String());

      return conflicts.isEmpty;
    } catch (e) {
      print('⚠️ 服务商可用性检查失败: $e');
      return true;
    }
  }

  /// 验证特殊要求
  Future<ValidationResult> _validateSpecialRequirements(OrderRequest request) async {
    final requirements = request.industrySpecificData.get<Map<String, dynamic>>('special_requirements');
    if (requirements == null) return ValidationResult.valid();

    final errors = <String>[];

    // 检查宠物友好要求
    if (requirements['pet_friendly'] == true) {
      final hasPetFriendlyProvider = await _checkPetFriendlyProvider(request.providerId);
      if (!hasPetFriendlyProvider) {
        errors.add('该服务商不提供宠物友好服务');
      }
    }

    // 检查特殊工具要求
    final specialTools = requirements['special_tools'] as List?;
    if (specialTools?.isNotEmpty == true) {
      final toolsAvailable = await _checkSpecialToolsAvailability(request.providerId, specialTools!);
      if (!toolsAvailable) {
        errors.add('服务商无法提供所需的特殊工具');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 验证服务地址
  Future<ValidationResult> _validateServiceAddress(Address address) async {
    final errors = <String>[];

    // 检查地址完整性
    if (address.streetName?.isEmpty ?? true) {
      errors.add('街道地址不能为空');
    }

    // 检查邮政编码格式
    final postalCodeRegex = RegExp(r'^[A-Za-z]\d[A-Za-z] ?\d[A-Za-z]\d$');
    if (address.postalCode == null || !postalCodeRegex.hasMatch(address.postalCode!)) {
      errors.add('邮政编码格式不正确');
    }

    // 检查危险区域
    final isDangerousArea = await _checkDangerousArea(address);
    if (isDangerousArea) {
      errors.add('该地区存在安全风险，无法提供服务');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 验证服务时间
  Future<ValidationResult> _validateServiceTime(TimeRange scheduledTime) async {
    final errors = <String>[];

    // 检查是否在营业时间内
    final isBusinessHours = await _checkBusinessHours(scheduledTime);
    if (!isBusinessHours) {
      errors.add('请选择营业时间内的服务时间');
    }

    // 检查提前预约时间
    final minAdvanceHours = 2;
    if (scheduledTime.start.isBefore(DateTime.now().add(Duration(hours: minAdvanceHours)))) {
      errors.add('请至少提前${minAdvanceHours}小时预约');
    }

    // 检查服务时长是否合理
    if (scheduledTime.duration.inMinutes < 30) {
      errors.add('服务时间不能少于30分钟');
    }

    if (scheduledTime.duration.inHours > 8) {
      errors.add('单次服务时间不能超过8小时');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 验证服务项目
  Future<ValidationResult> _validateServiceItem(OrderItemRequest item) async {
    try {
      final serviceDetails = await _supabase
          .from('service_details')
          .select('is_available, home_service_config')
          .eq('id', item.serviceDetailId)
          .single();

      if (!serviceDetails['is_available']) {
        return ValidationResult.invalid(['服务项目暂不可用']);
      }

      final config = serviceDetails['home_service_config'] as Map<String, dynamic>?;
      if (config != null) {
        // 检查最小服务时间
        final minDuration = config['min_duration_minutes'] as int?;
        if (minDuration != null && item.quantity * 60 < minDuration) {
          return ValidationResult.invalid(['服务时间不能少于${minDuration}分钟']);
        }

        // 检查最大服务时间
        final maxDuration = config['max_duration_minutes'] as int?;
        if (maxDuration != null && item.quantity * 60 > maxDuration) {
          return ValidationResult.invalid(['服务时间不能超过${maxDuration}分钟']);
        }
      }

      return ValidationResult.valid();
    } catch (e) {
      return ValidationResult.invalid(['服务项目验证失败']);
    }
  }

  // ========================================
  // 私有方法 - 定价逻辑
  // ========================================

  /// 添加交通费
  Future<void> _addTransportationFee(
    List<PricingFee> fees,
    Address serviceAddress,
    Price baseAmount,
  ) async {
    try {
      // 基于距离计算交通费
      const baseFee = 15.0; // 基础交通费
      const perKmRate = 1.5; // 每公里费用

      // TODO: 实现真实的距离计算
      final estimatedDistance = 10.0; // 模拟距离
      final transportFee = baseFee + (estimatedDistance * perKmRate);

      fees.add(PricingFee(
        type: 'transportation',
        name: '交通费',
        amount: Price(amount: transportFee, currency: baseAmount.currency),
        description: '基础费用\$${baseFee.toStringAsFixed(2)} + ${estimatedDistance}km × \$${perKmRate.toStringAsFixed(2)}/km',
      ));
    } catch (e) {
      print('⚠️ 交通费计算失败: $e');
    }
  }

  /// 添加工具材料费
  Future<void> _addToolsAndMaterialsFee(
    List<PricingFee> fees,
    List<OrderItemRequest> items,
  ) async {
    double totalToolsFee = 0.0;

    for (final item in items) {
      try {
        final serviceDetails = await _supabase
            .from('service_details')
            .select('home_service_config')
            .eq('id', item.serviceDetailId)
            .single();

        final config = serviceDetails['home_service_config'] as Map<String, dynamic>?;
        if (config != null) {
          final toolsFee = (config['tools_fee'] as num?)?.toDouble() ?? 0.0;
          final materialsFee = (config['materials_fee'] as num?)?.toDouble() ?? 0.0;
          totalToolsFee += (toolsFee + materialsFee) * item.quantity;
        }
      } catch (e) {
        print('⚠️ 工具材料费计算失败: $e');
      }
    }

    if (totalToolsFee > 0) {
      fees.add(PricingFee(
        type: 'tools_materials',
        name: '工具材料费',
        amount: Price(amount: totalToolsFee),
        description: '专业工具和材料使用费',
      ));
    }
  }

  /// 添加紧急服务费
  Future<void> _addUrgencyFee(
    List<PricingFee> fees,
    OrderRequest request,
  ) async {
    final isUrgent = request.industrySpecificData.get<bool>('is_urgent', false) ?? false;
    if (!isUrgent) return;

    final urgencyMultiplier = 0.5; // 50% 加急费
    final baseAmount = request.estimatedTotal;
    final urgencyFee = baseAmount * urgencyMultiplier;

    fees.add(PricingFee(
      type: 'urgency',
      name: '加急服务费',
      amount: Price(amount: urgencyFee),
      description: '24小时内加急服务费（${(urgencyMultiplier * 100).toInt()}%）',
    ));
  }

  /// 添加复杂度费用
  Future<void> _addComplexityFee(
    List<PricingFee> fees,
    List<OrderItemRequest> items,
    Price baseAmount,
  ) async {
    double complexityMultiplier = 0.0;

    for (final item in items) {
      final complexity = item.customizations['complexity'] as String?;
      switch (complexity) {
        case 'high':
          complexityMultiplier += 0.3;
          break;
        case 'medium':
          complexityMultiplier += 0.15;
          break;
        default:
          break;
      }
    }

    if (complexityMultiplier > 0) {
      final complexityFee = baseAmount.amount * complexityMultiplier;
      fees.add(PricingFee(
        type: 'complexity',
        name: '复杂度费用',
        amount: Price(amount: complexityFee, currency: baseAmount.currency),
        description: '高难度服务附加费（${(complexityMultiplier * 100).toInt()}%）',
      ));
    }
  }

  /// 检查家居服务促销
  Future<void> _checkHomeServicePromotions(
    List<PricingDiscount> discounts,
    Price baseAmount,
    OrderRequest request,
  ) async {
    // 首次用户折扣
    final isFirstTime = request.industrySpecificData.get<bool>('is_first_time_user', false) ?? false;
    if (isFirstTime) {
      discounts.add(PricingDiscount(
        type: 'first_time',
        name: '首次用户优惠',
        amount: Price(amount: 20.0, currency: baseAmount.currency),
        description: '首次使用家居服务优惠',
      ));
    }

    // 多服务打包折扣
    if (request.items.length >= 3) {
      final packageDiscount = baseAmount.amount * 0.1;
      discounts.add(PricingDiscount(
        type: 'package',
        name: '多服务打包优惠',
        amount: Price(amount: packageDiscount, currency: baseAmount.currency),
        description: '3项及以上服务享受10%折扣',
      ));
    }
  }

  // ========================================
  // 私有方法 - 状态处理
  // ========================================

  /// 服务被接受时的处理
  Future<void> _onServiceAccepted(Order order) async {
    print('✅ 家居服务已接受');

    // 锁定服务商时间
    await _lockProviderSchedule(order);

    // 发送服务准备通知
    await _sendServicePreparationNotification(order);

    // 创建服务检查清单
    await _createServiceChecklist(order);
  }

  /// 服务开始时的处理
  Future<void> _onServiceStarted(Order order) async {
    print('🔧 家居服务开始');

    // 记录服务开始时间
    order.setIndustryData('actual_start_time', DateTime.now().toIso8601String());

    // 发送服务开始通知
    await _sendServiceStartNotification(order);

    // 启动服务跟踪
    await _startServiceTracking(order);
  }

  /// 服务完成时的处理
  Future<void> _onServiceCompleted(Order order) async {
    print('🎉 家居服务完成');

    // 记录服务完成时间
    order.setIndustryData('actual_end_time', DateTime.now().toIso8601String());

    // 释放服务商时间
    await _releaseProviderSchedule(order);

    // 发送完成通知和评价邀请
    await _sendServiceCompletionNotification(order);
    await _inviteServiceReview(order);

    // 生成服务报告
    await _generateServiceReport(order);
  }

  /// 服务取消时的处理
  Future<void> _onServiceCancelled(Order order, String? reason) async {
    print('❌ 家居服务已取消: $reason');

    // 记录取消信息
    order.setIndustryData('cancellation_time', DateTime.now().toIso8601String());
    order.setIndustryData('cancellation_category', _categorizeCancellationReason(reason));

    // 释放服务商时间
    await _releaseProviderSchedule(order);
  }

  // ========================================
  // 私有方法 - 辅助功能
  // ========================================

  /// 获取服务分类
  String _getServiceCategory(String serviceId) {
    // TODO: 根据服务ID获取具体分类
    return 'general_home_service';
  }

  /// 检查是否需要工具
  Future<bool> _checkToolsRequired(String serviceId) async {
    try {
      final response = await _supabase
          .from('service_details')
          .select('home_service_config')
          .eq('service_id', serviceId)
          .single();

      final config = response['home_service_config'] as Map<String, dynamic>?;
      return config?['requires_tools'] ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 获取估计服务时长
  Future<int> _getEstimatedDuration(String serviceId) async {
    try {
      final response = await _supabase
          .from('service_details')
          .select('home_service_config')
          .eq('service_id', serviceId)
          .single();

      final config = response['home_service_config'] as Map<String, dynamic>?;
      return config?['estimated_duration_minutes'] ?? 120;
    } catch (e) {
      return 120; // 默认2小时
    }
  }

  /// 获取所需技能等级
  Future<String> _getRequiredSkillLevel(String serviceId) async {
    try {
      final response = await _supabase
          .from('service_details')
          .select('home_service_config')
          .eq('service_id', serviceId)
          .single();

      final config = response['home_service_config'] as Map<String, dynamic>?;
      return config?['skill_level'] ?? 'intermediate';
    } catch (e) {
      return 'intermediate';
    }
  }

  /// 计算服务窗口
  Future<Map<String, String>> _calculateServiceWindow(Order order) async {
    final scheduledTime = order.scheduledTime;
    if (scheduledTime == null) return {};

    // 给予30分钟的服务窗口
    final windowStart = scheduledTime.start.subtract(const Duration(minutes: 15));
    final windowEnd = scheduledTime.end.add(const Duration(minutes: 15));

    return {
      'window_start': windowStart.toIso8601String(),
      'window_end': windowEnd.toIso8601String(),
    };
  }

  /// 工具方法
  double _getFeeAmount(List<PricingFee> fees, String type) {
    final fee = fees.firstWhereOrNull((f) => f.type == type);
    return fee?.amount.amount ?? 0.0;
  }

  String _categorizeCancellationReason(String? reason) {
    if (reason == null) return 'unknown';
    
    if (reason.contains('weather')) return 'weather_related';
    if (reason.contains('emergency')) return 'emergency';
    if (reason.contains('reschedule')) return 'reschedule_request';
    if (reason.contains('provider')) return 'provider_unavailable';
    
    return 'other';
  }

  // ========================================
  // 私有方法 - 占位符实现
  // ========================================

  Future<void> _createServicePreparationList(Order order) async {
    // TODO: 实现服务准备清单创建
    print('📋 创建服务准备清单');
  }

  Future<void> _sendAppointmentConfirmation(Order order) async {
    // TODO: 实现预约确认通知
    print('📧 发送预约确认通知');
  }

  Future<void> _sendStatusUpdateNotification(Order order, OrderStatus status, String? reason) async {
    // TODO: 实现状态更新通知
    print('📧 发送状态更新通知: ${status.label}');
  }

  Future<({bool canCancel, String? reason})> _checkCancellationPolicy(Order order) async {
    // TODO: 实现取消政策检查
    return (canCancel: true, reason: null);
  }

  Future<Price> _calculateCancellationFee(Order order, String reason) async {
    // TODO: 实现取消费用计算
    return Price(amount: 0.0, currency: order.totalAmount.currency);
  }

  Future<void> _releaseProviderSchedule(Order order) async {
    // TODO: 实现服务商时间释放
    print('🔓 释放服务商时间');
  }

  Future<void> _notifyServiceCancellation(Order order, String reason) async {
    // TODO: 实现取消通知
    print('📧 发送取消通知');
  }

  Future<bool> _checkPetFriendlyProvider(String providerId) async {
    // TODO: 实现宠物友好检查
    return true;
  }

  Future<bool> _checkSpecialToolsAvailability(String providerId, List tools) async {
    // TODO: 实现特殊工具可用性检查
    return true;
  }

  Future<bool> _checkDangerousArea(Address address) async {
    // TODO: 实现危险区域检查
    return false;
  }

  Future<bool> _checkBusinessHours(TimeRange time) async {
    // TODO: 实现营业时间检查
    return true;
  }

  Future<void> _lockProviderSchedule(Order order) async {
    // TODO: 实现服务商时间锁定
    print('🔒 锁定服务商时间');
  }

  Future<void> _sendServicePreparationNotification(Order order) async {
    // TODO: 实现服务准备通知
    print('📧 发送服务准备通知');
  }

  Future<void> _createServiceChecklist(Order order) async {
    // TODO: 实现服务检查清单创建
    print('📋 创建服务检查清单');
  }

  Future<void> _sendServiceStartNotification(Order order) async {
    // TODO: 实现服务开始通知
    print('📧 发送服务开始通知');
  }

  Future<void> _startServiceTracking(Order order) async {
    // TODO: 实现服务跟踪
    print('📍 启动服务跟踪');
  }

  Future<void> _sendServiceCompletionNotification(Order order) async {
    // TODO: 实现完成通知
    print('📧 发送服务完成通知');
  }

  Future<void> _inviteServiceReview(Order order) async {
    // TODO: 实现评价邀请
    print('⭐ 邀请服务评价');
  }

  Future<void> _generateServiceReport(Order order) async {
    // TODO: 实现服务报告生成
    print('📊 生成服务报告');
  }
}

/// 家居服务行业支付处理器
class HomeIndustryPaymentHandler implements IndustryPaymentHandler {
  @override
  Future<void> preprocessPayment(Order order, PaymentMethod paymentMethod) async {
    print('🏠💳 家居服务支付预处理');
    
    // 验证支付金额
    if (order.totalAmount.amount <= 0) {
      throw PaymentException('订单金额无效');
    }

    // 家居服务通常需要预付款
    final requiresDeposit = order.getIndustryData<bool>('requires_deposit', true) ?? true;
    if (requiresDeposit && order.depositAmount == null) {
      throw PaymentException('家居服务需要支付预付款');
    }

    // 检查支付方式限制
    if (paymentMethod.type == PaymentMethodType.cash) {
      final allowsCash = order.getIndustryData<bool>('allows_cash_payment', false) ?? false;
      if (!allowsCash) {
        throw PaymentException('该服务不支持现金支付');
      }
    }
  }

  @override
  Future<void> postprocessPayment(Order order, Payment payment, bool success) async {
    if (success) {
      print('✅ 家居服务支付成功');
      
      // 如果是预付款，更新订单状态
      if (payment.paymentType == 'deposit') {
        // TODO: 实现预付款后续处理
      }
      
      // 发送支付确认和服务准备通知
      // TODO: 实现通知逻辑
    } else {
      print('❌ 家居服务支付失败');
      
      // 释放预约时间
      // TODO: 实现时间释放逻辑
    }
  }

  @override
  Future<ValidationResult> validateRefund(Order order, Price amount, String reason) async {
    // 家居服务退款验证
    final serviceStartTime = order.getIndustryData<String>('actual_start_time');
    if (serviceStartTime != null) {
      final started = DateTime.parse(serviceStartTime);
      final now = DateTime.now();
      
      // 服务开始后2小时内可以申请退款
      if (now.difference(started).inHours > 2) {
        return ValidationResult.invalid(['服务开始超过2小时后不支持退款']);
      }
    }

    // 检查是否为预付款退款
    if (reason.contains('deposit') && order.status == OrderStatus.accepted) {
      // 预付款在服务开始前24小时可以退款
      final scheduledTime = order.scheduledTime?.start;
      if (scheduledTime != null) {
        final timeToService = scheduledTime.difference(DateTime.now());
        if (timeToService.inHours < 24) {
          return ValidationResult.invalid(['服务开始前24小时内预付款不可退款']);
        }
      }
    }

    return ValidationResult.valid();
  }

  @override
  Future<void> postprocessRefund(Order order, Payment refund, bool success) async {
    if (success) {
      print('✅ 家居服务退款成功');
      
      // 发送退款通知
      // TODO: 实现退款通知逻辑
      
      // 如果是全额退款，释放服务商时间
      if (refund.amount.amount >= order.totalAmount.amount) {
        // TODO: 实现时间释放逻辑
      }
    } else {
      print('❌ 家居服务退款失败');
      
      // 记录退款失败原因
      // TODO: 实现失败记录逻辑
    }
  }
}
