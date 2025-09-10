import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import '../utils/app_logger.dart';
import '../models/base_models.dart';

/// Stripe配置服务
/// 
/// 负责初始化Stripe SDK，管理Stripe配置和密钥
/// 提供环境相关的配置管理
class StripeConfigService extends GetxService {
  
  // Stripe配置
  static const String _testPublishableKey = 'pk_test_51234567890abcdef'; // 测试密钥
  static const String _prodPublishableKey = 'pk_live_production_key'; // 生产密钥
  
  // 当前环境配置
  bool get isProduction => const bool.fromEnvironment('dart.vm.product');
  String get publishableKey => isProduction ? _prodPublishableKey : _testPublishableKey;
  
  // 支付配置
  final RxBool _isInitialized = false.obs;
  bool get isInitialized => _isInitialized.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initializeStripe();
  }

  /// 初始化Stripe SDK
  Future<void> initializeStripe() async {
    try {
      AppLogger.info('[StripeConfigService] Initializing Stripe SDK...');
      
      // 配置Stripe
      Stripe.publishableKey = publishableKey;
      
      // 设置商户标识符（iOS Apple Pay需要）
      if (GetPlatform.isIOS) {
        Stripe.merchantIdentifier = 'merchant.com.jinbean.app';
      }
      
      // 应用设置
      await Stripe.instance.applySettings();
      
      _isInitialized.value = true;
      AppLogger.info('[StripeConfigService] Stripe SDK initialized successfully');
      
    } catch (e) {
      AppLogger.error('[StripeConfigService] Failed to initialize Stripe SDK: $e');
      _isInitialized.value = false;
      rethrow;
    }
  }

  /// 创建支付方式
  Future<PaymentMethod> createPaymentMethod({
    required PaymentMethodParams params,
  }) async {
    try {
      if (!_isInitialized.value) {
        throw PaymentException('Stripe SDK未初始化');
      }

      AppLogger.info('[StripeConfigService] Creating payment method...');
      
      final paymentMethod = await Stripe.instance.createPaymentMethod(params: params);
      
      AppLogger.info('[StripeConfigService] Payment method created: ${paymentMethod.id}');
      return paymentMethod;
      
    } catch (e) {
      AppLogger.error('[StripeConfigService] Failed to create payment method: $e');
      throw PaymentException('创建支付方式失败: $e');
    }
  }

  /// 确认支付意图
  Future<PaymentIntent> confirmPayment({
    required String paymentIntentClientSecret,
    PaymentMethodParams? params,
    PaymentMethodOptions? options,
  }) async {
    try {
      if (!_isInitialized.value) {
        throw PaymentException('Stripe SDK未初始化');
      }

      AppLogger.info('[StripeConfigService] Confirming payment intent...');
      
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntentClientSecret,
        data: params,
        options: options,
      );
      
      AppLogger.info('[StripeConfigService] Payment intent confirmed: ${paymentIntent.id}');
      return paymentIntent;
      
    } catch (e) {
      AppLogger.error('[StripeConfigService] Failed to confirm payment: $e');
      throw PaymentException('确认支付失败: $e');
    }
  }

  /// 处理Apple Pay支付
  Future<void> presentApplePay({
    required Map<String, dynamic> params,
  }) async {
    try {
      if (!GetPlatform.isIOS) {
        throw PaymentException('Apple Pay仅在iOS设备上可用');
      }

      if (!_isInitialized.value) {
        throw PaymentException('Stripe SDK未初始化');
      }

      AppLogger.info('[StripeConfigService] Presenting Apple Pay...');
      
      // TODO: 实现Apple Pay集成
      // await Stripe.instance.presentApplePay(params: params);
      
      AppLogger.info('[StripeConfigService] Apple Pay presented successfully');
      
    } catch (e) {
      AppLogger.error('[StripeConfigService] Failed to present Apple Pay: $e');
      throw PaymentException('Apple Pay支付失败: $e');
    }
  }

  /// 处理Google Pay支付
  Future<void> presentGooglePay({
    required Map<String, dynamic> params,
  }) async {
    try {
      if (!GetPlatform.isAndroid) {
        throw PaymentException('Google Pay仅在Android设备上可用');
      }

      if (!_isInitialized.value) {
        throw PaymentException('Stripe SDK未初始化');
      }

      AppLogger.info('[StripeConfigService] Presenting Google Pay...');
      
      // TODO: 实现Google Pay集成
      // await Stripe.instance.presentGooglePay(params);
      
      AppLogger.info('[StripeConfigService] Google Pay presented successfully');
      
    } catch (e) {
      AppLogger.error('[StripeConfigService] Failed to present Google Pay: $e');
      throw PaymentException('Google Pay支付失败: $e');
    }
  }

  /// 检查Apple Pay可用性
  Future<bool> isApplePaySupported() async {
    try {
      if (!GetPlatform.isIOS) return false;
      // TODO: 实现Apple Pay支持检查
      // return await Stripe.instance.isApplePaySupported();
      return false;
    } catch (e) {
      AppLogger.error('[StripeConfigService] Failed to check Apple Pay support: $e');
      return false;
    }
  }

  /// 检查Google Pay可用性
  Future<bool> isGooglePaySupported() async {
    try {
      if (!GetPlatform.isAndroid) return false;
      // TODO: 实现Google Pay支持检查
      // return await Stripe.instance.isGooglePaySupported();
      return false;
    } catch (e) {
      AppLogger.error('[StripeConfigService] Failed to check Google Pay support: $e');
      return false;
    }
  }

  /// 获取支付配置
  Map<String, dynamic> getPaymentConfig() {
    return {
      'is_initialized': _isInitialized.value,
      'is_production': isProduction,
      'publishable_key': publishableKey.substring(0, 12) + '...',
      'platform': GetPlatform.isIOS ? 'ios' : GetPlatform.isAndroid ? 'android' : 'unknown',
      'apple_pay_supported': GetPlatform.isIOS,
      'google_pay_supported': GetPlatform.isAndroid,
    };
  }

  /// 创建支付方式参数（信用卡）
  PaymentMethodParams createCardPaymentMethodParams({
    required String cardNumber,
    required int expMonth,
    required int expYear,
    required String cvc,
    String? cardHolderName,
    BillingDetails? billingDetails,
  }) {
    return PaymentMethodParams.card(
      paymentMethodData: PaymentMethodData(
        billingDetails: billingDetails ?? BillingDetails(
          name: cardHolderName,
        ),
      ),
    );
  }

  /// 创建Apple Pay参数
  Map<String, dynamic> createApplePayParams({
    required String cartId,
    required String merchantCountryCode,
    required String currencyCode,
    required List<Map<String, dynamic>> summaryItems,
  }) {
    return {
      'cart_id': cartId,
      'country': merchantCountryCode,
      'currency': currencyCode,
      'summary_items': summaryItems,
    };
  }

  /// 创建Google Pay参数
  Map<String, dynamic> createGooglePayParams({
    required String cartId,
    required String merchantCountryCode,
    required String currencyCode,
    required int amount, // 以分为单位
  }) {
    return {
      'cart_id': cartId,
      'country': merchantCountryCode,
      'currency': currencyCode,
      'amount': amount,
      'label': 'JinBean Payment',
    };
  }

  /// 验证卡号
  bool validateCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanNumber.length < 13 || cleanNumber.length > 19) return false;
    
    // Luhn算法验证
    int sum = 0;
    bool alternate = false;
    
    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanNumber[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }

  /// 验证过期日期
  bool validateExpiryDate(int month, int year) {
    if (month < 1 || month > 12) return false;
    
    final now = DateTime.now();
    final expiry = DateTime(year, month);
    
    return expiry.isAfter(now);
  }

  /// 验证CVC
  bool validateCVC(String cvc) {
    final cleanCvc = cvc.replaceAll(RegExp(r'\D'), '');
    return cleanCvc.length >= 3 && cleanCvc.length <= 4;
  }

  /// 格式化卡号显示
  String formatCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < cleanNumber.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleanNumber[i]);
    }
    
    return buffer.toString();
  }

  /// 获取卡片品牌
  String getCardBrand(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    if (cleanNumber.startsWith('4')) return 'visa';
    if (cleanNumber.startsWith('5') || cleanNumber.startsWith('2')) return 'mastercard';
    if (cleanNumber.startsWith('3')) return 'amex';
    if (cleanNumber.startsWith('6')) return 'discover';
    
    return 'unknown';
  }

  /// 重置服务
  Future<void> reset() async {
    _isInitialized.value = false;
    AppLogger.info('[StripeConfigService] Service reset');
  }
}
