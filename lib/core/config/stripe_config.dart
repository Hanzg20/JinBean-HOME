import '../services/payment_providers/stripe_payment_handler.dart';

/// Stripe配置类
/// 
/// 管理Stripe SDK的初始化和配置
class StripeConfig {
  // Stripe测试环境密钥
  static const String _testPublishableKey = 'pk_test_51HdSGU2eZvKYlo2CEiX5PkIyL1WI8m3Xl4Q8DuXGJGN2OqBgF5Dv8RtILGNFIwFjWMq5Z8E5YZ8F5F5Z8F5Z8F';
  
  // Stripe生产环境密钥（实际部署时需要替换）
  static const String _livePublishableKey = 'pk_live_your_live_publishable_key_here';
  
  // 商户标识符（Apple Pay需要）
  static const String _merchantIdentifier = 'merchant.com.jinbean.app';
  
  /// 是否为开发环境
  static bool get isDevelopment => const bool.fromEnvironment('dart.vm.product') == false;
  
  /// 获取当前环境的Publishable Key
  static String get publishableKey => isDevelopment ? _testPublishableKey : _livePublishableKey;
  
  /// 初始化Stripe SDK
  static Future<void> initialize() async {
    try {
      await StripePaymentHandler.initialize(
        publishableKey: publishableKey,
        merchantIdentifier: _merchantIdentifier,
      );
      
      print('✅ Stripe SDK initialized successfully');
      print('🔧 Environment: ${isDevelopment ? 'Development' : 'Production'}');
      
    } catch (e) {
      print('❌ Failed to initialize Stripe SDK: $e');
      rethrow;
    }
  }
  
  /// 验证配置
  static bool validateConfig() {
    if (publishableKey.startsWith('pk_test_') && !isDevelopment) {
      print('⚠️ Warning: Using test key in production environment');
      return false;
    }
    
    if (publishableKey.startsWith('pk_live_') && isDevelopment) {
      print('⚠️ Warning: Using live key in development environment');
      return false;
    }
    
    if (publishableKey == 'pk_live_your_live_publishable_key_here') {
      print('❌ Error: Please replace with actual live publishable key');
      return false;
    }
    
    return true;
  }
  
  /// 获取Stripe配置信息
  static Map<String, dynamic> getConfigInfo() {
    return {
      'environment': isDevelopment ? 'development' : 'production',
      'publishable_key_prefix': publishableKey.substring(0, 12) + '...',
      'merchant_identifier': _merchantIdentifier,
      'sdk_initialized': true, // 在实际应用中应该检查实际状态
    };
  }
}

/// Stripe相关常量
class StripeConstants {
  // 支付方式类型
  static const List<String> supportedPaymentMethods = [
    'card',
    'apple_pay',
    'google_pay',
  ];
  
  // 支持的货币
  static const List<String> supportedCurrencies = [
    'CAD', 'USD',
  ];
  
  // 最小支付金额（以分为单位）
  static const Map<String, int> minimumAmounts = {
    'CAD': 50,  // $0.50 CAD
    'USD': 50,  // $0.50 USD
  };
  
  // 最大支付金额（以分为单位）
  static const Map<String, int> maximumAmounts = {
    'CAD': 100000, // $1,000.00 CAD
    'USD': 100000, // $1,000.00 USD
  };
  
  /// 验证支付金额
  static bool isValidAmount(double amount, String currency) {
    final amountInCents = (amount * 100).round();
    final min = minimumAmounts[currency] ?? 50;
    final max = maximumAmounts[currency] ?? 100000;
    
    return amountInCents >= min && amountInCents <= max;
  }
  
  /// 格式化金额用于Stripe（转换为分）
  static int formatAmountForStripe(double amount) {
    return (amount * 100).round();
  }
  
  /// 从Stripe格式转换为金额（分转换为元）
  static double formatAmountFromStripe(int amountInCents) {
    return amountInCents / 100.0;
  }
}
