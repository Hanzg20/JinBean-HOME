import 'dart:math';

import '../../features/customer/domain/entities/service.dart';
import '../models/cart_models.dart';
import '../utils/app_logger.dart';

/// 价格计算器基类
abstract class PricingCalculator {
  /// 计算服务价格
  PricingResult calculate();

  /// 获取计算器类型
  String get calculatorType;
}

/// 餐饮服务价格计算器
class RestaurantPricingCalculator extends PricingCalculator {
  final List<CartItem> items;
  final DeliveryInfo? deliveryInfo;
  final String currency;
  final Map<String, dynamic> settings;

  RestaurantPricingCalculator({
    required this.items,
    this.deliveryInfo,
    this.currency = 'CAD',
    this.settings = const {},
  });

  @override
  String get calculatorType => 'restaurant';

  @override
  PricingResult calculate() {
    try {
      AppLogger.debug(
          '[RestaurantPricing] Calculating price for ${items.length} items');

      // 1. 计算商品总价
      double itemsTotal = 0;
      for (final item in items) {
        itemsTotal += item.subtotal;
      }

      AppLogger.debug(
          '[RestaurantPricing] Items total: \$${itemsTotal.toStringAsFixed(2)}');

      // 2. 计算配送费
      final deliveryFee = _calculateDeliveryFee();

      // 3. 计算平台服务费 (5%)
      final serviceFeeRate = _getServiceFeeRate();
      final serviceFee = itemsTotal * serviceFeeRate;

      // 4. 计算小费建议 (15%)
      final suggestedTip = itemsTotal * 0.15;

      // 5. 计算小计（税前）
      final subtotal = itemsTotal + deliveryFee + serviceFee;

      // 6. 计算税费 (13% HST在安大略省)
      final taxRate = _getTaxRate();
      final taxAmount = subtotal * taxRate;

      // 7. 计算总价
      final total = subtotal + taxAmount;

      // 8. 构建费用分解
      final breakdown = _buildBreakdown(
        itemsTotal,
        deliveryFee,
        serviceFee,
        taxAmount,
        suggestedTip,
      );

      final result = PricingResult(
        itemsTotal: itemsTotal,
        deliveryFee: deliveryFee,
        serviceFee: serviceFee,
        taxAmount: taxAmount,
        subtotal: subtotal,
        total: total,
        suggestedTip: suggestedTip,
        currency: currency,
        breakdown: breakdown,
      );

      AppLogger.debug(
          '[RestaurantPricing] Final total: \$${total.toStringAsFixed(2)}');
      return result;
    } catch (e) {
      AppLogger.error('[RestaurantPricing] Calculation failed: $e');
      rethrow;
    }
  }

  /// 计算配送费
  double _calculateDeliveryFee() {
    if (deliveryInfo == null || !deliveryInfo!.isDelivery) {
      return 0.0; // 自取或堂食无配送费
    }

    // 检查是否有指定配送费
    if (deliveryInfo!.deliveryFee != null) {
      return deliveryInfo!.deliveryFee!;
    }

    // 根据订单金额计算配送费
    final itemsTotal = items.fold(0.0, (sum, item) => sum + item.subtotal);

    if (itemsTotal >= 50.0) {
      return 0.0; // 满$50免配送费
    } else if (itemsTotal >= 30.0) {
      return 2.99; // $30-49.99收$2.99
    } else {
      return 4.99; // 低于$30收$4.99
    }
  }

  /// 获取服务费率
  double _getServiceFeeRate() {
    return settings['service_fee_rate'] as double? ?? 0.05; // 默认5%
  }

  /// 获取税率
  double _getTaxRate() {
    return settings['tax_rate'] as double? ?? 0.13; // 默认13% HST
  }

  /// 构建费用分解
  Map<String, double> _buildBreakdown(
    double itemsTotal,
    double deliveryFee,
    double serviceFee,
    double taxAmount,
    double suggestedTip,
  ) {
    return {
      'items_total': itemsTotal,
      'delivery_fee': deliveryFee,
      'service_fee': serviceFee,
      'tax_amount': taxAmount,
      'suggested_tip': suggestedTip,
    };
  }
}

/// 预约服务价格计算器
class AppointmentPricingCalculator extends PricingCalculator {
  final Service service;
  final AppointmentDetails appointmentDetails;
  final String currency;
  final Map<String, dynamic> settings;

  AppointmentPricingCalculator({
    required this.service,
    required this.appointmentDetails,
    this.currency = 'CAD',
    this.settings = const {},
  });

  @override
  String get calculatorType => 'appointment';

  @override
  PricingResult calculate() {
    try {
      AppLogger.debug(
          '[AppointmentPricing] Calculating price for service: ${service.id}');

      // 1. 获取基础价格
      double basePrice = service.price ?? 0;

      // 2. 时间段调整（高峰期+20%）
      final timeMultiplier = _getTimeMultiplier();
      basePrice *= timeMultiplier;

      // 3. 计算距离费用
      final distanceFee = _calculateDistanceFee();

      // 4. 计算紧急服务费（+20%）
      final urgencyFee = appointmentDetails.isUrgent ? basePrice * 0.2 : 0;

      // 5. 计算平台服务费（10%）
      final serviceFeeRate = _getServiceFeeRate();
      final serviceFee =
          (basePrice + distanceFee + urgencyFee) * serviceFeeRate;

      // 6. 计算小计（税前）
      final subtotal = basePrice + distanceFee + urgencyFee + serviceFee;

      // 7. 计算税费（13% HST）
      final taxRate = _getTaxRate();
      final taxAmount = subtotal * taxRate;

      // 8. 计算总价
      final total = subtotal + taxAmount;

      // 9. 构建费用分解
      final breakdown = _buildBreakdown(
        basePrice,
        distanceFee,
        urgencyFee,
        serviceFee,
        taxAmount,
      );

      final result = PricingResult(
        basePrice: basePrice,
        itemsTotal: basePrice,
        distanceFee: distanceFee,
        urgencyFee: urgencyFee,
        serviceFee: serviceFee,
        taxAmount: taxAmount,
        subtotal: subtotal,
        total: total,
        currency: currency,
        breakdown: breakdown,
      );

      AppLogger.debug(
          '[AppointmentPricing] Final total: \$${total.toStringAsFixed(2)}');
      return result;
    } catch (e) {
      AppLogger.error('[AppointmentPricing] Calculation failed: $e');
      rethrow;
    }
  }

  /// 获取时间段调整系数
  double _getTimeMultiplier() {
    final scheduledTime = appointmentDetails.scheduledTime;
    final hour = scheduledTime.hour;
    final dayOfWeek = scheduledTime.weekday;

    // 周末加价10%
    bool isWeekend =
        dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday;

    // 高峰时段：工作日18-21点，周末10-16点
    bool isPeakHour = false;
    if (isWeekend) {
      isPeakHour = hour >= 10 && hour <= 16;
    } else {
      isPeakHour = hour >= 18 && hour <= 21;
    }

    double multiplier = 1.0;
    if (isWeekend) multiplier += 0.1;
    if (isPeakHour) multiplier += 0.2;

    return multiplier;
  }

  /// 计算距离费用
  double _calculateDistanceFee() {
    // 从appointmentDetails中获取服务地址
    final serviceAddress = appointmentDetails.serviceAddress;

    // 简化的距离计算（实际应该使用地理位置API）
    // 这里假设距离在5-50公里之间，每公里$0.5
    final estimatedDistance = _estimateDistance(serviceAddress);

    if (estimatedDistance <= 5) {
      return 0.0; // 5公里内免费
    } else if (estimatedDistance <= 20) {
      return (estimatedDistance - 5) * 0.5; // 超出部分每公里$0.5
    } else {
      return 15.0 + (estimatedDistance - 20) * 1.0; // 超出20公里每公里$1.0
    }
  }

  /// 估算距离（简化版本）
  double _estimateDistance(Map<String, dynamic> serviceAddress) {
    // 这里应该使用真实的地理位置计算
    // 暂时返回一个随机值用于演示
    return 5.0 + Random().nextDouble() * 15.0; // 5-20公里
  }

  /// 获取服务费率
  double _getServiceFeeRate() {
    return settings['service_fee_rate'] as double? ?? 0.1; // 默认10%
  }

  /// 获取税率
  double _getTaxRate() {
    return settings['tax_rate'] as double? ?? 0.13; // 默认13% HST
  }

  /// 构建费用分解
  Map<String, double> _buildBreakdown(
    double basePrice,
    double distanceFee,
    double urgencyFee,
    double serviceFee,
    double taxAmount,
  ) {
    return {
      'base_price': basePrice,
      'distance_fee': distanceFee,
      'urgency_fee': urgencyFee,
      'service_fee': serviceFee,
      'tax_amount': taxAmount,
    };
  }
}

/// 询价服务价格计算器
class QuotePricingCalculator extends PricingCalculator {
  final Service service;
  final double quotedPrice;
  final String currency;
  final Map<String, dynamic> settings;
  final Map<String, dynamic>? quoteBreakdown;

  QuotePricingCalculator({
    required this.service,
    required this.quotedPrice,
    this.currency = 'CAD',
    this.settings = const {},
    this.quoteBreakdown,
  });

  @override
  String get calculatorType => 'quote';

  @override
  PricingResult calculate() {
    try {
      AppLogger.debug(
          '[QuotePricing] Calculating price for quoted service: ${service.id}');

      // 1. 使用报价作为基础价格
      final basePrice = quotedPrice;

      // 2. 从报价明细中提取各项费用（如果有）
      final breakdown = quoteBreakdown ?? <String, dynamic>{};
      final laborCost = breakdown['labor_cost'] as double? ?? basePrice * 0.7;
      final materialCost =
          breakdown['material_cost'] as double? ?? basePrice * 0.2;
      final equipmentCost =
          breakdown['equipment_cost'] as double? ?? basePrice * 0.1;

      // 3. 计算平台服务费（询价服务通常较低，5%）
      final serviceFeeRate = _getServiceFeeRate();
      final serviceFee = basePrice * serviceFeeRate;

      // 4. 计算小计（税前）
      final subtotal = basePrice + serviceFee;

      // 5. 计算税费（13% HST）
      final taxRate = _getTaxRate();
      final taxAmount = subtotal * taxRate;

      // 6. 计算总价
      final total = subtotal + taxAmount;

      // 7. 构建详细费用分解
      final detailedBreakdown = _buildBreakdown(
        basePrice,
        laborCost,
        materialCost,
        equipmentCost,
        serviceFee,
        taxAmount,
      );

      final result = PricingResult(
        basePrice: basePrice,
        itemsTotal: basePrice,
        serviceFee: serviceFee,
        taxAmount: taxAmount,
        subtotal: subtotal,
        total: total,
        currency: currency,
        breakdown: detailedBreakdown,
      );

      AppLogger.debug(
          '[QuotePricing] Final total: \$${total.toStringAsFixed(2)}');
      return result;
    } catch (e) {
      AppLogger.error('[QuotePricing] Calculation failed: $e');
      rethrow;
    }
  }

  /// 获取服务费率
  double _getServiceFeeRate() {
    return settings['service_fee_rate'] as double? ?? 0.05; // 默认5%
  }

  /// 获取税率
  double _getTaxRate() {
    return settings['tax_rate'] as double? ?? 0.13; // 默认13% HST
  }

  /// 构建费用分解
  Map<String, double> _buildBreakdown(
    double basePrice,
    double laborCost,
    double materialCost,
    double equipmentCost,
    double serviceFee,
    double taxAmount,
  ) {
    return {
      'base_price': basePrice,
      'labor_cost': laborCost,
      'material_cost': materialCost,
      'equipment_cost': equipmentCost,
      'service_fee': serviceFee,
      'tax_amount': taxAmount,
    };
  }
}

/// 价格计算器工厂类
class PricingCalculatorFactory {
  /// 创建餐饮服务价格计算器
  static RestaurantPricingCalculator createRestaurantCalculator({
    required List<CartItem> items,
    DeliveryInfo? deliveryInfo,
    String currency = 'CAD',
    Map<String, dynamic> settings = const {},
  }) {
    return RestaurantPricingCalculator(
      items: items,
      deliveryInfo: deliveryInfo,
      currency: currency,
      settings: settings,
    );
  }

  /// 创建预约服务价格计算器
  static AppointmentPricingCalculator createAppointmentCalculator({
    required Service service,
    required AppointmentDetails appointmentDetails,
    String currency = 'CAD',
    Map<String, dynamic> settings = const {},
  }) {
    return AppointmentPricingCalculator(
      service: service,
      appointmentDetails: appointmentDetails,
      currency: currency,
      settings: settings,
    );
  }

  /// 创建询价服务价格计算器
  static QuotePricingCalculator createQuoteCalculator({
    required Service service,
    required double quotedPrice,
    String currency = 'CAD',
    Map<String, dynamic> settings = const {},
    Map<String, dynamic>? quoteBreakdown,
  }) {
    return QuotePricingCalculator(
      service: service,
      quotedPrice: quotedPrice,
      currency: currency,
      settings: settings,
      quoteBreakdown: quoteBreakdown,
    );
  }

  /// 根据服务类型自动创建价格计算器
  static PricingCalculator createCalculator({
    required Service service,
    List<CartItem>? cartItems,
    AppointmentDetails? appointmentDetails,
    DeliveryInfo? deliveryInfo,
    double? quotedPrice,
    Map<String, dynamic>? quoteBreakdown,
    String currency = 'CAD',
    Map<String, dynamic> settings = const {},
  }) {
    final categoryId = service.categoryLevel1Id;

    // 餐饮服务
    if (categoryId == '1010000') {
      if (cartItems == null || cartItems.isEmpty) {
        throw ArgumentError('Restaurant service requires cart items');
      }
      return createRestaurantCalculator(
        items: cartItems,
        deliveryInfo: deliveryInfo,
        currency: currency,
        settings: settings,
      );
    }

    // 询价服务
    if (quotedPrice != null) {
      return createQuoteCalculator(
        service: service,
        quotedPrice: quotedPrice,
        currency: currency,
        settings: settings,
        quoteBreakdown: quoteBreakdown,
      );
    }

    // 预约服务
    if (appointmentDetails != null) {
      return createAppointmentCalculator(
        service: service,
        appointmentDetails: appointmentDetails,
        currency: currency,
        settings: settings,
      );
    }

    // 默认使用预约计算器
    final defaultAppointmentDetails = AppointmentDetails(
      scheduledTime: DateTime.now().add(Duration(hours: 24)),
      serviceAddress: {'type': 'default'},
    );

    return createAppointmentCalculator(
      service: service,
      appointmentDetails: defaultAppointmentDetails,
      currency: currency,
      settings: settings,
    );
  }
}

/// 价格计算服务类
class PricingService {
  static final Map<String, dynamic> _defaultSettings = {
    'tax_rate': 0.13, // 13% HST
    'service_fee_rate_restaurant': 0.05, // 餐饮服务费5%
    'service_fee_rate_appointment': 0.10, // 预约服务费10%
    'service_fee_rate_quote': 0.05, // 询价服务费5%
    'tip_suggestion_rate': 0.15, // 建议小费15%
    'free_delivery_threshold': 50.0, // 免配送费门槛$50
    'peak_hour_multiplier': 1.2, // 高峰时段加价20%
    'weekend_multiplier': 1.1, // 周末加价10%
    'urgency_multiplier': 1.2, // 紧急服务加价20%
  };

  /// 计算餐饮服务价格
  static PricingResult calculateRestaurantPrice({
    required List<CartItem> items,
    DeliveryInfo? deliveryInfo,
    String currency = 'CAD',
    Map<String, dynamic>? customSettings,
  }) {
    final settings = {..._defaultSettings, ...?customSettings};
    settings['service_fee_rate'] = settings['service_fee_rate_restaurant'];

    final calculator = PricingCalculatorFactory.createRestaurantCalculator(
      items: items,
      deliveryInfo: deliveryInfo,
      currency: currency,
      settings: settings,
    );

    return calculator.calculate();
  }

  /// 计算预约服务价格
  static PricingResult calculateAppointmentPrice({
    required Service service,
    required AppointmentDetails appointmentDetails,
    String currency = 'CAD',
    Map<String, dynamic>? customSettings,
  }) {
    final settings = {..._defaultSettings, ...?customSettings};
    settings['service_fee_rate'] = settings['service_fee_rate_appointment'];

    final calculator = PricingCalculatorFactory.createAppointmentCalculator(
      service: service,
      appointmentDetails: appointmentDetails,
      currency: currency,
      settings: settings,
    );

    return calculator.calculate();
  }

  /// 计算询价服务价格
  static PricingResult calculateQuotePrice({
    required Service service,
    required double quotedPrice,
    String currency = 'CAD',
    Map<String, dynamic>? customSettings,
    Map<String, dynamic>? quoteBreakdown,
  }) {
    final settings = {..._defaultSettings, ...?customSettings};
    settings['service_fee_rate'] = settings['service_fee_rate_quote'];

    final calculator = PricingCalculatorFactory.createQuoteCalculator(
      service: service,
      quotedPrice: quotedPrice,
      currency: currency,
      settings: settings,
      quoteBreakdown: quoteBreakdown,
    );

    return calculator.calculate();
  }

  /// 获取价格估算（无需详细信息）
  static double estimatePrice({
    required Service service,
    int quantity = 1,
    bool isUrgent = false,
    bool isWeekend = false,
    bool isPeakHour = false,
  }) {
    double basePrice = service.price ?? 50.0; // 默认价格$50

    // 数量调整
    basePrice *= quantity;

    // 时间调整
    if (isWeekend) basePrice *= _defaultSettings['weekend_multiplier'];
    if (isPeakHour) basePrice *= _defaultSettings['peak_hour_multiplier'];
    if (isUrgent) basePrice *= _defaultSettings['urgency_multiplier'];

    // 加上服务费和税费
    final serviceFee = basePrice * 0.1;
    final subtotal = basePrice + serviceFee;
    final tax = subtotal * _defaultSettings['tax_rate'];

    return subtotal + tax;
  }

  /// 比较不同时间段的价格
  static Map<String, double> comparePricesByTime({
    required Service service,
    required List<DateTime> timeSlots,
    AppointmentDetails? baseDetails,
  }) {
    final result = <String, double>{};

    for (final timeSlot in timeSlots) {
      final details = AppointmentDetails(
        scheduledTime: timeSlot,
        serviceAddress: baseDetails?.serviceAddress ?? {'type': 'default'},
        isUrgent: baseDetails?.isUrgent ?? false,
        specialRequirements: baseDetails?.specialRequirements,
        customizations: baseDetails?.customizations,
      );

      final pricing = calculateAppointmentPrice(
        service: service,
        appointmentDetails: details,
      );

      final timeKey = '${timeSlot.month}/${timeSlot.day} ${timeSlot.hour}:00';
      result[timeKey] = pricing.total;
    }

    return result;
  }

  /// 获取省钱建议
  static List<String> getMoneySavingTips({
    required Service service,
    required PricingResult currentPricing,
  }) {
    final tips = <String>[];

    // 配送费建议
    if (currentPricing.deliveryFee > 0) {
      final freeDeliveryThreshold =
          _defaultSettings['free_delivery_threshold'] as double;
      final remaining = freeDeliveryThreshold - currentPricing.itemsTotal;
      if (remaining > 0 && remaining <= 20) {
        tips.add('再消费\$${remaining.toStringAsFixed(2)}即可免配送费');
      }
    }

    // 时间段建议
    final now = DateTime.now();
    if (now.hour >= 18 && now.hour <= 21) {
      tips.add('避开高峰时段(18-21点)可节省20%费用');
    }

    // 周末建议
    if (now.weekday >= DateTime.saturday) {
      tips.add('工作日预订可节省10%费用');
    }

    // 紧急服务建议
    if (currentPricing.urgencyFee > 0) {
      tips.add('提前预订可节省\$${currentPricing.urgencyFee.toStringAsFixed(2)}紧急费用');
    }

    return tips;
  }
}
