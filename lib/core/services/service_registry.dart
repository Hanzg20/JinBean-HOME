import 'package:get/get.dart';
import '../models/base_models.dart';
import 'universal_order_service.dart';
import 'universal_payment_service.dart';
import '../controllers/universal_order_controller.dart';
import '../../features/customer/food/services/food_industry_handler.dart';
import '../../features/customer/home/services/home_industry_handler.dart';
import '../../features/customer/transport/services/transport_industry_handler.dart';
import '../../features/customer/rental/services/rental_industry_handler.dart';
import '../../features/customer/learning/services/learning_industry_handler.dart';
import '../../features/customer/professional/services/professional_industry_handler.dart';
import 'payment_providers/stripe_payment_handler.dart';

/// 服务注册器
/// 
/// 负责初始化和注册所有通用服务、行业处理器等
/// 确保依赖注入和服务生命周期的正确管理
class ServiceRegistry {
  static bool _isInitialized = false;

  /// 初始化所有核心服务
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('⚠️ 服务已经初始化过了');
      return;
    }

    print('🚀 开始初始化通用服务系统...');

    try {
      // 1. 注册核心服务
      await _registerCoreServices();

      // 2. 注册支付提供商处理器
      await _registerPaymentProviders();

      // 3. 注册行业处理器
      await _registerIndustryHandlers();

      // 4. 注册控制器
      await _registerControllers();

      _isInitialized = true;
      print('✅ 通用服务系统初始化完成');

    } catch (e) {
      print('❌ 服务系统初始化失败: $e');
      rethrow;
    }
  }

  /// 注册核心服务
  static Future<void> _registerCoreServices() async {
    print('📋 注册核心服务...');

    // 注册订单服务
    Get.put(UniversalOrderService(), permanent: true);
    print('✅ 通用订单服务已注册');

    // 注册支付服务
    Get.put(UniversalPaymentService(), permanent: true);
    print('✅ 通用支付服务已注册');

    // 等待服务初始化完成
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// 注册支付提供商处理器
  static Future<void> _registerPaymentProviders() async {
    print('💳 注册支付提供商处理器...');

    final paymentService = Get.find<UniversalPaymentService>();

    // 注册Stripe处理器
    paymentService.registerProviderHandler('Stripe', StripePaymentHandler());
    print('✅ Stripe支付处理器已注册');

    // TODO: 添加其他支付提供商
    // paymentService.registerProviderHandler('Square', SquarePaymentHandler());
    // paymentService.registerProviderHandler('PayPal', PayPalPaymentHandler());
  }

  /// 注册行业处理器
  static Future<void> _registerIndustryHandlers() async {
    print('🏭 注册行业处理器...');

    final orderService = Get.find<UniversalOrderService>();
    final paymentService = Get.find<UniversalPaymentService>();

    // 注册餐饮行业处理器
    final foodOrderHandler = FoodIndustryOrderHandler();
    final foodPaymentHandler = FoodIndustryPaymentHandler();
    
    orderService.registerIndustryHandler(IndustryType.food, foodOrderHandler);
    paymentService.registerIndustryHandler(IndustryType.food, foodPaymentHandler);
    print('✅ 餐饮行业处理器已注册');

    // 注册家居服务行业处理器
    final homeOrderHandler = HomeIndustryOrderHandler();
    final homePaymentHandler = HomeIndustryPaymentHandler();
    
    orderService.registerIndustryHandler(IndustryType.home, homeOrderHandler);
    paymentService.registerIndustryHandler(IndustryType.home, homePaymentHandler);
    print('✅ 家居服务行业处理器已注册');

    // 注册出行交通行业处理器
    final transportOrderHandler = TransportIndustryOrderHandler();
    final transportPaymentHandler = TransportIndustryPaymentHandler();
    
    orderService.registerIndustryHandler(IndustryType.transport, transportOrderHandler);
    paymentService.registerIndustryHandler(IndustryType.transport, transportPaymentHandler);
    print('✅ 出行交通行业处理器已注册');

    // 注册租赁共享行业处理器
    final rentalOrderHandler = RentalIndustryOrderHandler();
    final rentalPaymentHandler = RentalIndustryPaymentHandler();
    
    orderService.registerIndustryHandler(IndustryType.rental, rentalOrderHandler);
    paymentService.registerIndustryHandler(IndustryType.rental, rentalPaymentHandler);
    print('✅ 租赁共享行业处理器已注册');

    // 注册学习成长行业处理器
    final learningOrderHandler = LearningIndustryOrderHandler();
    final learningPaymentHandler = LearningIndustryPaymentHandler();
    
    orderService.registerIndustryHandler(IndustryType.learning, learningOrderHandler);
    paymentService.registerIndustryHandler(IndustryType.learning, learningPaymentHandler);
    print('✅ 学习成长行业处理器已注册');

    // 注册专业速帮行业处理器
    final professionalOrderHandler = ProfessionalIndustryOrderHandler();
    final professionalPaymentHandler = ProfessionalIndustryPaymentHandler();
    
    orderService.registerIndustryHandler(IndustryType.professional, professionalOrderHandler);
    paymentService.registerIndustryHandler(IndustryType.professional, professionalPaymentHandler);
    print('✅ 专业速帮行业处理器已注册');
  }

  /// 注册控制器
  static Future<void> _registerControllers() async {
    print('🎮 注册控制器...');

    // 注册通用订单控制器
    Get.put(UniversalOrderController(), permanent: true);
    print('✅ 通用订单控制器已注册');

    // TODO: 根据需要注册其他控制器
    // Get.put(UniversalPaymentController(), permanent: true);
    // Get.put(UniversalServiceController(), permanent: true);
  }

  /// 检查服务是否已初始化
  static bool get isInitialized => _isInitialized;

  /// 获取服务状态
  static Map<String, bool> getServiceStatus() {
    return {
      'initialized': _isInitialized,
      'order_service': Get.isRegistered<UniversalOrderService>(),
      'payment_service': Get.isRegistered<UniversalPaymentService>(),
      'order_controller': Get.isRegistered<UniversalOrderController>(),
    };
  }

  /// 重置服务（用于测试）
  static Future<void> reset() async {
    print('🔄 重置服务系统...');

    // 删除所有注册的服务
    if (Get.isRegistered<UniversalOrderController>()) {
      Get.delete<UniversalOrderController>();
    }
    if (Get.isRegistered<UniversalPaymentService>()) {
      Get.delete<UniversalPaymentService>();
    }
    if (Get.isRegistered<UniversalOrderService>()) {
      Get.delete<UniversalOrderService>();
    }

    _isInitialized = false;
    print('✅ 服务系统已重置');
  }

  /// 获取调试信息
  static Map<String, dynamic> getDebugInfo() {
    return {
      'initialized': _isInitialized,
      'registered_services': {
        'UniversalOrderService': Get.isRegistered<UniversalOrderService>(),
        'UniversalPaymentService': Get.isRegistered<UniversalPaymentService>(),
        'UniversalOrderController': Get.isRegistered<UniversalOrderController>(),
      },
      'service_instances': {
        'order_service_hashCode': Get.isRegistered<UniversalOrderService>() 
            ? Get.find<UniversalOrderService>().hashCode 
            : null,
        'payment_service_hashCode': Get.isRegistered<UniversalPaymentService>() 
            ? Get.find<UniversalPaymentService>().hashCode 
            : null,
        'order_controller_hashCode': Get.isRegistered<UniversalOrderController>() 
            ? Get.find<UniversalOrderController>().hashCode 
            : null,
      },
    };
  }
}

/// 服务扩展方法
extension ServiceRegistryExtensions on ServiceRegistry {
  /// 快速访问订单服务
  static UniversalOrderService get orderService => Get.find<UniversalOrderService>();
  
  /// 快速访问支付服务
  static UniversalPaymentService get paymentService => Get.find<UniversalPaymentService>();
  
  /// 快速访问订单控制器
  static UniversalOrderController get orderController => Get.find<UniversalOrderController>();
}
