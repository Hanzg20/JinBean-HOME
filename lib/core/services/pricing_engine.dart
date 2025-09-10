import '../models/base_models.dart';

/// 通用定价引擎 - 支持所有行业的定价计算
class PricingEngine {
  
  /// 计算服务价格
  static Price calculateServicePrice({
    required double basePrice,
    required PricingType pricingType,
    Map<String, dynamic> metadata = const {},
    String currency = 'CAD',
  }) {
    double finalPrice = basePrice;
    
    switch (pricingType) {
      case PricingType.fixedPrice:
        // 固定价格，不做调整
        break;
      case PricingType.hourlyRate:
        final hours = metadata['hours'] as double? ?? 1.0;
        finalPrice = basePrice * hours;
        break;
      case PricingType.perItem:
        final quantity = metadata['quantity'] as int? ?? 1;
        finalPrice = basePrice * quantity;
        break;
      case PricingType.tieredPricing:
        // 阶梯定价逻辑
        finalPrice = _calculateTieredPrice(basePrice, metadata);
        break;
      case PricingType.dynamicPricing:
        // 动态定价逻辑
        finalPrice = _calculateDynamicPrice(basePrice, metadata);
        break;
      case PricingType.packageDeal:
        // 套餐价格逻辑
        finalPrice = _calculatePackagePrice(basePrice, metadata);
        break;
      case PricingType.customQuote:
        // 自定义报价，使用提供的价格
        finalPrice = metadata['quotedPrice'] as double? ?? basePrice;
        break;
    }
    
    return Price(
      amount: finalPrice,
      currency: currency,
    );
  }
  
  /// 阶梯定价计算
  static double _calculateTieredPrice(double basePrice, Map<String, dynamic> metadata) {
    final quantity = metadata['quantity'] as int? ?? 1;
    
    if (quantity <= 5) {
      return basePrice * quantity;
    } else if (quantity <= 10) {
      return basePrice * quantity * 0.9; // 10% 折扣
    } else {
      return basePrice * quantity * 0.8; // 20% 折扣
    }
  }
  
  /// 动态定价计算
  static double _calculateDynamicPrice(double basePrice, Map<String, dynamic> metadata) {
    double multiplier = 1.0;
    
    // 根据需求调整价格
    final demandLevel = metadata['demandLevel'] as String? ?? 'normal';
    switch (demandLevel) {
      case 'low':
        multiplier = 0.8;
        break;
      case 'high':
        multiplier = 1.2;
        break;
      case 'peak':
        multiplier = 1.5;
        break;
      default:
        multiplier = 1.0;
    }
    
    return basePrice * multiplier;
  }
  
  /// 套餐价格计算
  static double _calculatePackagePrice(double basePrice, Map<String, dynamic> metadata) {
    final packageSize = metadata['packageSize'] as int? ?? 1;
    final discountRate = metadata['discountRate'] as double? ?? 0.1;
    
    return basePrice * packageSize * (1 - discountRate);
  }
}
