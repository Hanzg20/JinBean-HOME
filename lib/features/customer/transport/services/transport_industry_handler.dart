import 'dart:async';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/base_models.dart';
import '../../../../core/models/order_models.dart';
import '../../../../core/models/payment_models.dart';
import '../../../../core/services/universal_order_service.dart';
import '../../../../core/services/universal_payment_service.dart';

/// 出行交通行业订单处理器
/// 
/// 实现出行交通行业特定的订单处理逻辑：
/// - 实时定位和路线规划
/// - 动态定价和高峰时段加价
/// - 司机匹配和调度算法
/// - 行程跟踪和安全监控
/// - 多种出行方式支持（打车、货运、租车）
class TransportIndustryOrderHandler implements IndustryOrderHandler {
  final _supabase = Supabase.instance.client;

  @override
  Future<void> preprocessOrder(OrderRequest request) async {
    print('🚗 出行交通订单预处理');

    // 验证起始和目的地
    final pickupLocation = request.industrySpecificData.get<Map<String, dynamic>>('pickup_location');
    final destination = request.industrySpecificData.get<Map<String, dynamic>>('destination');
    
    if (pickupLocation == null) {
      throw OrderException('请设置上车地点');
    }

    // 货运和租车服务需要目的地
    final transportType = request.industrySpecificData.get<String>('transport_type', 'ride') ?? 'ride';
    if (['freight', 'rental'].contains(transportType) && destination == null) {
      throw OrderException('${_getTransportTypeName(transportType)}服务需要设置目的地');
    }

    // 检查服务覆盖区域
    final isInServiceArea = await _checkServiceCoverage(pickupLocation, destination);
    if (!isInServiceArea) {
      throw OrderException('该区域暂不提供${_getTransportTypeName(transportType)}服务');
    }

    // 验证车辆类型和特殊需求
    await _validateVehicleRequirements(request);

    // 检查司机/车辆可用性
    final hasAvailableDrivers = await _checkDriverAvailability(pickupLocation, transportType);
    if (!hasAvailableDrivers) {
      throw OrderException('当前区域暂无可用司机，请稍后再试');
    }
  }

  @override
  Future<void> postprocessOrder(Order order) async {
    print('🚗 出行交通订单后处理');

    final transportType = order.getIndustryData<String>('transport_type', 'ride');
    
    // 设置出行交通特定的元数据
    order.setIndustryData('vehicle_type', await _getRecommendedVehicleType(order));
    order.setIndustryData('estimated_duration', await _calculateEstimatedDuration(order));
    order.setIndustryData('estimated_distance', await _calculateEstimatedDistance(order));
    order.setIndustryData('route_info', await _calculateOptimalRoute(order));
    
    // 设置行程特定信息
    switch (transportType) {
      case 'ride':
        await _setupRideSpecificData(order);
        break;
      case 'freight':
        await _setupFreightSpecificData(order);
        break;
      case 'rental':
        await _setupRentalSpecificData(order);
        break;
    }

    // 开始司机匹配
    await _startDriverMatching(order);

    // 发送订单确认通知
    await _sendOrderConfirmationNotification(order);
  }

  @override
  Future<ValidationResult> validateOrder(OrderRequest request) async {
    final errors = <String>[];
    final fieldErrors = <String, String>{};

    // 验证上车地点
    final pickupLocation = request.industrySpecificData.get<Map<String, dynamic>>('pickup_location');
    if (pickupLocation == null) {
      fieldErrors['pickup_location'] = '请设置上车地点';
    }

    // 验证出行类型
    final transportType = request.industrySpecificData.get<String>('transport_type');
    if (transportType == null || !['ride', 'freight', 'rental'].contains(transportType)) {
      fieldErrors['transport_type'] = '请选择有效的出行类型';
    }

    // 验证车辆类型
    final vehicleType = request.industrySpecificData.get<String>('vehicle_type');
    if (vehicleType != null) {
      final vehicleValidation = await _validateVehicleType(transportType!, vehicleType);
      if (!vehicleValidation.isValid) {
        fieldErrors['vehicle_type'] = vehicleValidation.firstError;
      }
    }

    // 验证特殊需求
    final specialRequirements = request.industrySpecificData.get<Map<String, dynamic>>('special_requirements');
    if (specialRequirements != null) {
      final requirementValidation = await _validateSpecialRequirements(specialRequirements, transportType!);
      if (!requirementValidation.isValid) {
        errors.addAll(requirementValidation.errors);
      }
    }

    // 验证预约时间（如果是预约出行）
    if (request.orderType == 'scheduled' && request.scheduledTime != null) {
      final timeValidation = await _validateScheduledTime(request.scheduledTime!);
      if (!timeValidation.isValid) {
        fieldErrors['scheduled_time'] = timeValidation.firstError;
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
    print('🧮 出行交通定价调整');

    final adjustedFees = List<PricingFee>.from(fees);
    final adjustedDiscounts = List<PricingDiscount>.from(discounts);

    final transportType = request.industrySpecificData.get<String>('transport_type', 'ride');
    final pickupLocation = request.industrySpecificData.get<Map<String, dynamic>>('pickup_location')!;
    final destination = request.industrySpecificData.get<Map<String, dynamic>>('destination');

    // 计算距离和时间相关费用
    await _addDistanceBasedFees(adjustedFees, pickupLocation, destination, transportType ?? 'ride', baseAmount);
    
    // 添加高峰时段加价
    await _addSurgeAndPeakFees(adjustedFees, pickupLocation, baseAmount);
    
    // 添加特殊服务费用
    await _addSpecialServiceFees(adjustedFees, request);
    
    // 添加平台服务费
    await _addPlatformFees(adjustedFees, baseAmount, transportType ?? 'ride');

    // 检查出行优惠
    await _checkTransportPromotions(adjustedDiscounts, baseAmount, request);

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
        'base_fare': baseAmount.amount,
        'distance_fee': _getFeeAmount(adjustedFees, 'distance'),
        'time_fee': _getFeeAmount(adjustedFees, 'time'),
        'surge_fee': _getFeeAmount(adjustedFees, 'surge'),
        'peak_hour_fee': _getFeeAmount(adjustedFees, 'peak_hour'),
        'platform_fee': _getFeeAmount(adjustedFees, 'platform'),
        'special_service_fee': _getFeeAmount(adjustedFees, 'special_service'),
        'total_discounts': discountsTotal.amount,
        'final_total': totalAmount.amount,
      },
    );
  }

  @override
  Future<void> onStatusChange(Order order, OrderStatus newStatus, String? reason) async {
    print('🔄 出行交通订单状态变更: ${order.status.label} -> ${newStatus.label}');

    switch (newStatus) {
      case OrderStatus.accepted:
        await _onRideAccepted(order);
        break;
      case OrderStatus.inProgress:
        await _onRideStarted(order);
        break;
      case OrderStatus.completed:
        await _onRideCompleted(order);
        break;
      case OrderStatus.cancelled:
        await _onRideCancelled(order, reason);
        break;
      default:
        break;
    }

    // 发送状态更新通知
    await _sendStatusUpdateNotification(order, newStatus, reason);
  }

  @override
  Future<void> onOrderCancellation(Order order, String reason) async {
    print('❌ 出行交通订单取消处理');

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

    // 释放司机分配
    await _releaseDriverAssignment(order);

    // 通知相关方
    await _notifyRideCancellation(order, reason);
  }

  // ========================================
  // 私有方法 - 验证逻辑
  // ========================================

  /// 检查服务覆盖范围
  Future<bool> _checkServiceCoverage(
    Map<String, dynamic> pickupLocation,
    Map<String, dynamic>? destination,
  ) async {
    try {
      // 检查起点覆盖
      final pickupLat = pickupLocation['latitude'] as double;
      final pickupLng = pickupLocation['longitude'] as double;
      
      final coverageAreas = await _supabase
          .from('transport_service_areas')
          .select('area_type, area_config')
          .eq('is_active', true);

      bool pickupCovered = false;
      bool destinationCovered = destination == null ? true : false;

      for (final area in coverageAreas) {
        final areaType = area['area_type'];
        final config = area['area_config'] as Map<String, dynamic>;

        switch (areaType) {
          case 'city_boundary':
            final cities = (config['cities'] as List).cast<String>();
            final pickupCity = pickupLocation['city'] as String?;
            if (cities.contains(pickupCity?.toLowerCase())) {
              pickupCovered = true;
            }
            
            if (destination != null) {
              final destCity = destination['city'] as String?;
              if (cities.contains(destCity?.toLowerCase())) {
                destinationCovered = true;
              }
            }
            break;
            
          case 'radius_coverage':
            final centerLat = config['center_latitude'] as double;
            final centerLng = config['center_longitude'] as double;
            final radius = config['radius_km'] as double;
            
            final pickupDistance = _calculateDistance(pickupLat, pickupLng, centerLat, centerLng);
            if (pickupDistance <= radius) {
              pickupCovered = true;
            }
            
            if (destination != null) {
              final destLat = destination['latitude'] as double;
              final destLng = destination['longitude'] as double;
              final destDistance = _calculateDistance(destLat, destLng, centerLat, centerLng);
              if (destDistance <= radius) {
                destinationCovered = true;
              }
            }
            break;
        }
      }

      return pickupCovered && destinationCovered;
    } catch (e) {
      print('⚠️ 服务覆盖检查失败: $e');
      return true; // 默认允许
    }
  }

  /// 验证车辆要求
  Future<void> _validateVehicleRequirements(OrderRequest request) async {
    final transportType = request.industrySpecificData.get<String>('transport_type');
    final vehicleType = request.industrySpecificData.get<String>('vehicle_type');
    final passengerCount = request.industrySpecificData.get<int>('passenger_count', 1) ?? 1;

    // 验证乘客数量与车型匹配
    if (vehicleType != null) {
      final maxCapacity = await _getVehicleCapacity(vehicleType);
      if (passengerCount > maxCapacity) {
        throw OrderException('选择的车型最多只能载${maxCapacity}人');
      }
    }

    // 验证货运特殊要求
    if (transportType == 'freight') {
      final cargoWeight = request.industrySpecificData.get<double>('cargo_weight');
      final cargoVolume = request.industrySpecificData.get<double>('cargo_volume');
      
      if (cargoWeight == null || cargoWeight <= 0) {
        throw OrderException('货运服务请填写货物重量');
      }
      
      if (vehicleType != null) {
        final validation = await _validateFreightCapacity(vehicleType, cargoWeight, cargoVolume);
        if (!validation.isValid) {
          throw OrderException(validation.firstError);
        }
      }
    }
  }

  /// 检查司机可用性
  Future<bool> _checkDriverAvailability(Map<String, dynamic> location, String transportType) async {
    try {
      final lat = location['latitude'] as double;
      final lng = location['longitude'] as double;
      
      // 查找附近的在线司机
      final availableDrivers = await _supabase
          .from('driver_locations')
          .select('driver_id, latitude, longitude')
          .eq('is_online', true)
          .eq('is_available', true)
          .eq('transport_type', transportType);

      // 检查是否有司机在5km范围内
      for (final driver in availableDrivers) {
        final driverLat = driver['latitude'] as double;
        final driverLng = driver['longitude'] as double;
        final distance = _calculateDistance(lat, lng, driverLat, driverLng);
        
        if (distance <= 5.0) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('⚠️ 司机可用性检查失败: $e');
      return true; // 默认认为有司机可用
    }
  }

  /// 验证车辆类型
  Future<ValidationResult> _validateVehicleType(String transportType, String vehicleType) async {
    try {
      final validTypes = await _supabase
          .from('vehicle_types')
          .select('type_code')
          .eq('transport_type', transportType)
          .eq('is_active', true);

      final validTypeCodes = validTypes.map((t) => t['type_code'] as String).toList();
      
      if (!validTypeCodes.contains(vehicleType)) {
        return ValidationResult.invalid(['该出行类型不支持选择的车辆类型']);
      }

      return ValidationResult.valid();
    } catch (e) {
      return ValidationResult.invalid(['车辆类型验证失败']);
    }
  }

  /// 验证特殊需求
  Future<ValidationResult> _validateSpecialRequirements(
    Map<String, dynamic> requirements,
    String transportType,
  ) async {
    final errors = <String>[];

    // 验证无障碍需求
    if (requirements['wheelchair_accessible'] == true) {
      final hasAccessibleVehicles = await _checkAccessibleVehicles(transportType);
      if (!hasAccessibleVehicles) {
        errors.add('当前区域暂无无障碍车辆');
      }
    }

    // 验证宠物携带
    if (requirements['pet_friendly'] == true && transportType == 'ride') {
      final allowsPets = await _checkPetFriendlyDrivers();
      if (!allowsPets) {
        errors.add('当前区域暂无支持携带宠物的司机');
      }
    }

    // 验证儿童座椅
    if (requirements['child_seat'] == true) {
      final hasChildSeats = await _checkChildSeatAvailability();
      if (!hasChildSeats) {
        errors.add('当前区域暂无提供儿童座椅的车辆');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 验证预约时间
  Future<ValidationResult> _validateScheduledTime(TimeRange scheduledTime) async {
    final errors = <String>[];

    // 检查最小提前时间
    final minAdvanceMinutes = 30;
    if (scheduledTime.start.isBefore(DateTime.now().add(Duration(minutes: minAdvanceMinutes)))) {
      errors.add('预约出行请至少提前${minAdvanceMinutes}分钟');
    }

    // 检查最大提前时间
    final maxAdvanceDays = 7;
    if (scheduledTime.start.isAfter(DateTime.now().add(Duration(days: maxAdvanceDays)))) {
      errors.add('预约出行最多只能提前${maxAdvanceDays}天');
    }

    // 检查营业时间
    final isBusinessHours = await _checkBusinessHours(scheduledTime.start);
    if (!isBusinessHours) {
      errors.add('预约时间必须在营业时间内');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // ========================================
  // 私有方法 - 定价逻辑
  // ========================================

  /// 添加距离相关费用
  Future<void> _addDistanceBasedFees(
    List<PricingFee> fees,
    Map<String, dynamic> pickupLocation,
    Map<String, dynamic>? destination,
    String transportType,
    Price baseAmount,
  ) async {
    if (destination == null) return;

    final distance = await _calculateRouteDistance(pickupLocation, destination);
    final duration = await _calculateRouteDuration(pickupLocation, destination);

    // 距离费用
    final distanceRate = await _getDistanceRate(transportType);
    final distanceFee = distance * distanceRate;
    
    if (distanceFee > 0) {
      fees.add(PricingFee(
        type: 'distance',
        name: '里程费',
        amount: Price(amount: distanceFee, currency: baseAmount.currency),
        description: '${distance.toStringAsFixed(1)}km × \$${distanceRate.toStringAsFixed(2)}/km',
      ));
    }

    // 时间费用
    final timeRate = await _getTimeRate(transportType);
    final timeFee = duration * timeRate;
    
    if (timeFee > 0) {
      fees.add(PricingFee(
        type: 'time',
        name: '时长费',
        amount: Price(amount: timeFee, currency: baseAmount.currency),
        description: '${duration.toStringAsFixed(0)}分钟 × \$${timeRate.toStringAsFixed(2)}/分钟',
      ));
    }
  }

  /// 添加高峰和动态加价
  Future<void> _addSurgeAndPeakFees(
    List<PricingFee> fees,
    Map<String, dynamic> pickupLocation,
    Price baseAmount,
  ) async {
    final now = DateTime.now();
    
    // 检查高峰时段
    final isPeakHour = await _checkPeakHours(now);
    if (isPeakHour) {
      final peakMultiplier = await _getPeakHourMultiplier(now);
      final peakFee = baseAmount.amount * peakMultiplier;
      
      fees.add(PricingFee(
        type: 'peak_hour',
        name: '高峰时段费',
        amount: Price(amount: peakFee, currency: baseAmount.currency),
        description: '高峰时段加价（${(peakMultiplier * 100).toInt()}%）',
      ));
    }

    // 检查动态加价
    final surgeMultiplier = await _calculateSurgeMultiplier(pickupLocation, now);
    if (surgeMultiplier > 1.0) {
      final surgeFee = baseAmount.amount * (surgeMultiplier - 1.0);
      
      fees.add(PricingFee(
        type: 'surge',
        name: '动态加价',
        amount: Price(amount: surgeFee, currency: baseAmount.currency),
        description: '需求高峰加价（${surgeMultiplier.toStringAsFixed(1)}x）',
      ));
    }
  }

  /// 添加特殊服务费用
  Future<void> _addSpecialServiceFees(
    List<PricingFee> fees,
    OrderRequest request,
  ) async {
    final requirements = request.industrySpecificData.get<Map<String, dynamic>>('special_requirements');
    if (requirements == null) return;

    double specialServiceFee = 0.0;
    final services = <String>[];

    // 无障碍服务费
    if (requirements['wheelchair_accessible'] == true) {
      specialServiceFee += 5.0;
      services.add('无障碍服务');
    }

    // 儿童座椅费
    if (requirements['child_seat'] == true) {
      specialServiceFee += 3.0;
      services.add('儿童座椅');
    }

    // 宠物携带费
    if (requirements['pet_friendly'] == true) {
      specialServiceFee += 2.0;
      services.add('宠物友好');
    }

    // 额外停靠费
    final extraStops = requirements['extra_stops'] as List?;
    if (extraStops?.isNotEmpty == true) {
      specialServiceFee += extraStops!.length * 2.0;
      services.add('额外停靠(${extraStops.length}次)');
    }

    if (specialServiceFee > 0) {
      fees.add(PricingFee(
        type: 'special_service',
        name: '特殊服务费',
        amount: Price(amount: specialServiceFee),
        description: services.join('、'),
      ));
    }
  }

  /// 添加平台费用
  Future<void> _addPlatformFees(
    List<PricingFee> fees,
    Price baseAmount,
    String transportType,
  ) async {
    // 平台服务费
    final platformRate = await _getPlatformFeeRate(transportType);
    final platformFee = baseAmount.amount * platformRate;
    
    fees.add(PricingFee(
      type: 'platform',
      name: '平台服务费',
      amount: Price(amount: platformFee, currency: baseAmount.currency),
      description: '${(platformRate * 100).toInt()}%平台服务费',
    ));

    // 税费
    const taxRate = 0.05; // 5% GST
    final taxAmount = baseAmount.amount * taxRate;
    
    fees.add(PricingFee(
      type: 'tax',
      name: 'GST (5%)',
      amount: Price(amount: taxAmount, currency: baseAmount.currency),
      description: '商品及服务税',
    ));
  }

  /// 检查出行优惠
  Future<void> _checkTransportPromotions(
    List<PricingDiscount> discounts,
    Price baseAmount,
    OrderRequest request,
  ) async {
    final transportType = request.industrySpecificData.get<String>('transport_type');
    
    // 新用户优惠
    final isNewUser = request.industrySpecificData.get<bool>('is_new_user', false) ?? false;
    if (isNewUser) {
      discounts.add(PricingDiscount(
        type: 'new_user',
        name: '新用户优惠',
        amount: Price(amount: 10.0, currency: baseAmount.currency),
        description: '首次使用出行服务优惠',
      ));
    }

    // 预约出行折扣
    if (request.orderType == 'scheduled') {
      discounts.add(PricingDiscount(
        type: 'scheduled',
        name: '预约出行优惠',
        amount: Price(amount: baseAmount.amount * 0.05, currency: baseAmount.currency),
        description: '预约出行享受5%折扣',
      ));
    }

    // 货运多次优惠
    if (transportType == 'freight') {
      final frequentUser = request.industrySpecificData.get<bool>('frequent_freight_user', false) ?? false;
      if (frequentUser) {
        discounts.add(PricingDiscount(
          type: 'frequent_freight',
          name: '货运常客优惠',
          amount: Price(amount: baseAmount.amount * 0.1, currency: baseAmount.currency),
          description: '货运常客享受10%折扣',
        ));
      }
    }
  }

  // ========================================
  // 私有方法 - 状态处理
  // ========================================

  /// 出行被接受时的处理
  Future<void> _onRideAccepted(Order order) async {
    print('✅ 出行订单已接受');

    // 分配司机
    await _assignDriver(order);

    // 发送司机信息给乘客
    await _sendDriverInfoToPassenger(order);

    // 开始实时跟踪
    await _startRealTimeTracking(order);
  }

  /// 出行开始时的处理
  Future<void> _onRideStarted(Order order) async {
    print('🚗 出行开始');

    // 记录出行开始时间和位置
    order.setIndustryData('actual_start_time', DateTime.now().toIso8601String());
    
    // 发送出行开始通知
    await _sendRideStartNotification(order);

    // 启动行程监控
    await _startTripMonitoring(order);
  }

  /// 出行完成时的处理
  Future<void> _onRideCompleted(Order order) async {
    print('🎉 出行完成');

    // 记录出行结束时间和位置
    order.setIndustryData('actual_end_time', DateTime.now().toIso8601String());

    // 计算实际费用（如果有等待时间等）
    await _calculateFinalFare(order);

    // 释放司机
    await _releaseDriver(order);

    // 发送完成通知和评价邀请
    await _sendRideCompletionNotification(order);
    await _inviteRideReview(order);

    // 生成行程报告
    await _generateTripReport(order);
  }

  /// 出行取消时的处理
  Future<void> _onRideCancelled(Order order, String? reason) async {
    print('❌ 出行已取消: $reason');

    // 记录取消信息
    order.setIndustryData('cancellation_time', DateTime.now().toIso8601String());
    order.setIndustryData('cancellation_category', _categorizeCancellationReason(reason));

    // 释放司机分配
    await _releaseDriverAssignment(order);

    // 停止跟踪
    await _stopRealTimeTracking(order);
  }

  // ========================================
  // 私有方法 - 辅助功能
  // ========================================

  /// 计算两点间距离（km）
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371.0; // 地球半径（km）
    
    final double dLat = (lat2 - lat1) * (math.pi / 180.0);
    final double dLng = (lng2 - lng1) * (math.pi / 180.0);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180.0)) * math.cos(lat2 * (math.pi / 180.0)) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// 获取出行类型名称
  String _getTransportTypeName(String type) {
    switch (type) {
      case 'ride':
        return '打车';
      case 'freight':
        return '货运';
      case 'rental':
        return '租车';
      default:
        return '出行';
    }
  }

  /// 工具方法
  double _getFeeAmount(List<PricingFee> fees, String type) {
    final fee = fees.firstWhereOrNull((f) => f.type == type);
    return fee?.amount.amount ?? 0.0;
  }

  String _categorizeCancellationReason(String? reason) {
    if (reason == null) return 'unknown';
    
    if (reason.contains('driver')) return 'driver_related';
    if (reason.contains('passenger')) return 'passenger_related';
    if (reason.contains('weather')) return 'weather_related';
    if (reason.contains('traffic')) return 'traffic_related';
    
    return 'other';
  }

  // ========================================
  // 私有方法 - 占位符实现
  // ========================================

  Future<int> _getVehicleCapacity(String vehicleType) async {
    // TODO: 从数据库获取车型载客量
    switch (vehicleType) {
      case 'economy':
      case 'standard':
        return 4;
      case 'premium':
        return 4;
      case 'suv':
        return 6;
      case 'van':
        return 8;
      default:
        return 4;
    }
  }

  Future<ValidationResult> _validateFreightCapacity(String vehicleType, double weight, double? volume) async {
    // TODO: 实现货运载重验证
    return ValidationResult.valid();
  }

  Future<bool> _checkAccessibleVehicles(String transportType) async {
    // TODO: 检查无障碍车辆可用性
    return true;
  }

  Future<bool> _checkPetFriendlyDrivers() async {
    // TODO: 检查宠物友好司机
    return true;
  }

  Future<bool> _checkChildSeatAvailability() async {
    // TODO: 检查儿童座椅可用性
    return true;
  }

  Future<bool> _checkBusinessHours(DateTime time) async {
    // TODO: 检查营业时间
    return true;
  }

  Future<double> _calculateRouteDistance(Map<String, dynamic> pickup, Map<String, dynamic> destination) async {
    // TODO: 实现路线距离计算
    return 10.0; // 模拟10公里
  }

  Future<double> _calculateRouteDuration(Map<String, dynamic> pickup, Map<String, dynamic> destination) async {
    // TODO: 实现路线时长计算
    return 25.0; // 模拟25分钟
  }

  Future<double> _getDistanceRate(String transportType) async {
    // TODO: 从配置获取里程费率
    switch (transportType) {
      case 'ride':
        return 1.2;
      case 'freight':
        return 2.0;
      case 'rental':
        return 0.8;
      default:
        return 1.0;
    }
  }

  Future<double> _getTimeRate(String transportType) async {
    // TODO: 从配置获取时间费率
    switch (transportType) {
      case 'ride':
        return 0.3;
      case 'freight':
        return 0.5;
      default:
        return 0.25;
    }
  }

  Future<bool> _checkPeakHours(DateTime time) async {
    // TODO: 实现高峰时段检查
    final hour = time.hour;
    return (hour >= 7 && hour <= 9) || (hour >= 17 && hour <= 19);
  }

  Future<double> _getPeakHourMultiplier(DateTime time) async {
    // TODO: 获取高峰时段倍数
    return 0.2; // 20%加价
  }

  Future<double> _calculateSurgeMultiplier(Map<String, dynamic> location, DateTime time) async {
    // TODO: 实现动态加价计算
    return 1.0; // 无加价
  }

  Future<double> _getPlatformFeeRate(String transportType) async {
    // TODO: 获取平台费率
    return 0.15; // 15%平台费
  }

  Future<String> _getRecommendedVehicleType(Order order) async {
    // TODO: 根据订单推荐车型
    return 'standard';
  }

  Future<int> _calculateEstimatedDuration(Order order) async {
    // TODO: 计算预估时长
    return 30; // 30分钟
  }

  Future<double> _calculateEstimatedDistance(Order order) async {
    // TODO: 计算预估距离
    return 15.0; // 15公里
  }

  Future<Map<String, dynamic>> _calculateOptimalRoute(Order order) async {
    // TODO: 计算最优路线
    return {'route_type': 'fastest', 'waypoints': []};
  }

  Future<void> _setupRideSpecificData(Order order) async {
    // TODO: 设置打车特定数据
    order.setIndustryData('ride_type', 'standard');
  }

  Future<void> _setupFreightSpecificData(Order order) async {
    // TODO: 设置货运特定数据
    order.setIndustryData('cargo_type', 'general');
  }

  Future<void> _setupRentalSpecificData(Order order) async {
    // TODO: 设置租车特定数据
    order.setIndustryData('rental_type', 'hourly');
  }

  Future<void> _startDriverMatching(Order order) async {
    // TODO: 开始司机匹配
    print('🔍 开始司机匹配');
  }

  Future<void> _sendOrderConfirmationNotification(Order order) async {
    // TODO: 发送订单确认通知
    print('📧 发送订单确认通知');
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

  Future<void> _releaseDriverAssignment(Order order) async {
    // TODO: 释放司机分配
    print('🔓 释放司机分配');
  }

  Future<void> _notifyRideCancellation(Order order, String reason) async {
    // TODO: 通知出行取消
    print('📧 通知出行取消');
  }

  Future<void> _assignDriver(Order order) async {
    // TODO: 分配司机
    print('👨‍💼 分配司机');
  }

  Future<void> _sendDriverInfoToPassenger(Order order) async {
    // TODO: 发送司机信息
    print('📧 发送司机信息');
  }

  Future<void> _startRealTimeTracking(Order order) async {
    // TODO: 开始实时跟踪
    print('📍 开始实时跟踪');
  }

  Future<void> _sendRideStartNotification(Order order) async {
    // TODO: 发送出行开始通知
    print('📧 发送出行开始通知');
  }

  Future<void> _startTripMonitoring(Order order) async {
    // TODO: 启动行程监控
    print('📊 启动行程监控');
  }

  Future<void> _calculateFinalFare(Order order) async {
    // TODO: 计算最终费用
    print('🧮 计算最终费用');
  }

  Future<void> _releaseDriver(Order order) async {
    // TODO: 释放司机
    print('🔓 释放司机');
  }

  Future<void> _sendRideCompletionNotification(Order order) async {
    // TODO: 发送完成通知
    print('📧 发送完成通知');
  }

  Future<void> _inviteRideReview(Order order) async {
    // TODO: 邀请评价
    print('⭐ 邀请行程评价');
  }

  Future<void> _generateTripReport(Order order) async {
    // TODO: 生成行程报告
    print('📊 生成行程报告');
  }

  Future<void> _stopRealTimeTracking(Order order) async {
    // TODO: 停止实时跟踪
    print('🛑 停止实时跟踪');
  }
}

/// 出行交通行业支付处理器
class TransportIndustryPaymentHandler implements IndustryPaymentHandler {
  @override
  Future<void> preprocessPayment(Order order, PaymentMethod paymentMethod) async {
    print('🚗💳 出行交通支付预处理');
    
    // 验证支付金额
    if (order.totalAmount.amount <= 0) {
      throw PaymentException('订单金额无效');
    }

    // 出行服务支持多种支付方式
    final transportType = order.getIndustryData<String>('transport_type', 'ride');
    
    // 货运服务可能需要预付款
    if (transportType == 'freight') {
      final requiresDeposit = order.getIndustryData<bool>('requires_deposit', false) ?? false;
      if (requiresDeposit && order.depositAmount == null) {
        throw PaymentException('大额货运订单需要支付预付款');
      }
    }

    // 租车服务需要信用卡验证
    if (transportType == 'rental' && !paymentMethod.type.isCard) {
      throw PaymentException('租车服务需要使用信用卡支付');
    }
  }

  @override
  Future<void> postprocessPayment(Order order, Payment payment, bool success) async {
    if (success) {
      print('✅ 出行交通支付成功');
      
      // 发送支付确认
      // TODO: 实现支付确认逻辑
      
      // 如果是预约出行，发送预约确认
      if (order.orderType == 'scheduled') {
        // TODO: 发送预约确认
      }
    } else {
      print('❌ 出行交通支付失败');
      
      // 取消司机分配
      // TODO: 实现司机分配取消逻辑
    }
  }

  @override
  Future<ValidationResult> validateRefund(Order order, Price amount, String reason) async {
    // 出行交通退款验证
    final transportType = order.getIndustryData<String>('transport_type', 'ride');
    
    // 检查出行是否已开始
    final actualStartTime = order.getIndustryData<String>('actual_start_time');
    if (actualStartTime != null) {
      return ValidationResult.invalid(['出行已开始，无法申请退款']);
    }

    // 预约出行的退款政策
    if (order.orderType == 'scheduled') {
      final scheduledTime = order.scheduledTime?.start;
      if (scheduledTime != null) {
        final timeToTrip = scheduledTime.difference(DateTime.now());
        
        // 根据出行类型设置不同的退款政策
        switch (transportType) {
          case 'ride':
            if (timeToTrip.inHours < 1) {
              return ValidationResult.invalid(['出行开始前1小时内不支持退款']);
            }
            break;
          case 'freight':
            if (timeToTrip.inHours < 4) {
              return ValidationResult.invalid(['货运服务开始前4小时内不支持退款']);
            }
            break;
          case 'rental':
            if (timeToTrip.inHours < 24) {
              return ValidationResult.invalid(['租车服务开始前24小时内不支持退款']);
            }
            break;
        }
      }
    }

    return ValidationResult.valid();
  }

  @override
  Future<void> postprocessRefund(Order order, Payment refund, bool success) async {
    if (success) {
      print('✅ 出行交通退款成功');
      
      // 发送退款通知
      // TODO: 实现退款通知逻辑
      
      // 释放司机分配
      // TODO: 实现司机释放逻辑
    } else {
      print('❌ 出行交通退款失败');
      
      // 记录退款失败原因
      // TODO: 实现失败记录逻辑
    }
  }
}
