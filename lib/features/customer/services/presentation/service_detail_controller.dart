import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/service_detail.dart';
import '../../../../core/models/review_models.dart';
import '../../domain/entities/similar_service.dart';
import '../../domain/entities/provider_profile.dart';
import '../services/service_detail_api_service.dart' as api;
import '../../../../core/services/services.dart' as core_services;
import '../../../../core/services/intelligent_routing_engine.dart';
import '../../../../core/services/service_booking_type_resolver.dart';
import '../../../../core/models/base_models.dart';
import '../../../../core/services/cart_service.dart';

class ServiceDetailController extends GetxController {
  // 服务数据
  final Rx<Service?> service = Rx<Service?>(null);
  final Rx<ServiceDetail?> serviceDetail = Rx<ServiceDetail?>(null);

  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool isLoadingReviews = false.obs;
  final RxBool isLoadingProvider = false.obs;
  final RxBool isLoadingSimilar = false.obs;

  // 错误状态
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  // 用户交互状态
  final RxBool isFavorite = false.obs;
  final RxString quoteRequestStatus = ''.obs;
  final RxBool isBooking = false.obs;

  // 评价相关
  final RxList<Review> reviews = <Review>[].obs;
  final RxString currentReviewSort = 'newest'.obs;
  final RxMap<String, bool> reviewFilters = <String, bool>{
    'all': true,
    '5star': false,
    '4star': false,
    '3star': false,
    '2star': false,
    '1star': false,
    'withPhotos': false,
    'verified': false,
  }.obs;

  // 预订详情
  final RxMap<String, dynamic> bookingDetails = <String, dynamic>{}.obs;

  // 相似服务推荐
  final RxList<SimilarService> similarServices = <SimilarService>[].obs;

  // 服务提供商信息
  final Rx<ProviderProfile?> providerProfile = Rx<ProviderProfile?>(null);

  // ========================================
  // 行业特定数据 (Industry-Specific Data)
  // ========================================

  // 菜单项 (Food - 1010000)
  final RxList<ServiceDetail> menuItems = <ServiceDetail>[].obs;
  final RxBool isLoadingMenuItems = false.obs;

  // 服务套餐 (Home Services - 1020000)
  final RxList<ServiceDetail> servicePackages = <ServiceDetail>[].obs;
  final RxBool isLoadingServicePackages = false.obs;

  // 库存项 (Rental - 1040000)
  final RxList<ServiceDetail> inventoryItems = <ServiceDetail>[].obs;
  final RxBool isLoadingInventoryItems = false.obs;

  // 课程 (Education - 1050000)
  final RxList<ServiceDetail> courses = <ServiceDetail>[].obs;
  final RxBool isLoadingCourses = false.obs;

  // 治疗项目 (Life Help - 1060000)
  final RxList<ServiceDetail> treatments = <ServiceDetail>[].obs;
  final RxBool isLoadingTreatments = false.obs;

  // 报价相关
  final RxMap<String, dynamic> quoteDetails = <String, dynamic>{}.obs;
  final RxBool isLoadingQuote = false.obs;
  final RxString quoteError = ''.obs;
  final RxMap<String, dynamic> receivedQuote = <String, dynamic>{}.obs;

  // 新增：集成新的服务查询服务
  core_services.IServiceQueryService? _serviceQueryService;
  core_services.IServiceDetailService? _serviceDetailService;

  // 智能操作按钮相关
  late final ContextManager _contextManager;
  late final CartService _cartService;
  final Rx<ServiceBookingType?> bookingType = Rx<ServiceBookingType?>(null);
  final RxBool canAddToCart = false.obs;
  final RxBool canDirectBook = false.obs;
  final RxString primaryActionText = '加载中...'.obs;
  final RxString secondaryActionText = ''.obs;
  final RxBool showSecondaryAction = false.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('ServiceDetailController initialized',
        tag: 'ServiceDetailController');

    // 初始化智能操作按钮
    _initializeIntelligentActions();

    // 初始化新的服务查询服务
    _initializeNewServices();

    // 获取serviceId参数
    final serviceId = Get.parameters['serviceId'] ?? '';
    if (serviceId.isNotEmpty) {
      // 加载服务详情
      loadServiceDetail(serviceId);

      // 加载相似服务推荐
      loadSimilarServices(serviceId);

      // 注意：不在这里加载Provider信息，因为此时还没有providerId
      // loadProviderProfile会在loadServiceDetail完成后调用

      // 加载评价
      loadReviews(serviceId);
    }
  }

  // 新增：初始化新的服务查询服务
  Future<void> _initializeNewServices() async {
    try {
      final serviceManager = core_services.ServiceManager.instance;
      if (!serviceManager.isInitialized) {
        await serviceManager.initializeServices();
      }

      _serviceQueryService = serviceManager.serviceQueryService;
      _serviceDetailService = serviceManager.serviceDetailService;

      AppLogger.info('ServiceDetailController: 新服务查询服务初始化成功');
    } catch (e) {
      AppLogger.info('ServiceDetailController: 新服务查询服务初始化失败: $e');
    }
  }

  /// 加载服务详情
  Future<void> loadServiceDetail(String serviceId) async {
    if (serviceId.isEmpty) {
      throw Exception('Service ID is required');
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      AppLogger.info('Loading service detail for ID: $serviceId',
          tag: 'ServiceDetailController');

      // 优先使用新的服务查询服务
      if (_serviceQueryService != null && _serviceDetailService != null) {
        AppLogger.info('使用新的服务查询服务获取服务详情');

        // 获取服务基础信息
        final serviceData =
            await _serviceQueryService!.getServiceById(serviceId);
        if (serviceData != null) {
          // ServiceQueryService now returns Domain entity directly - no conversion needed!
          service.value = serviceData;

          // 获取服务详情
          final serviceDetails =
              await _serviceDetailService!.getServiceDetails(serviceId);
          if (serviceDetails.isNotEmpty) {
            // ServiceDetailService now returns Domain entity directly - no conversion needed!
            serviceDetail.value = serviceDetails.firstWhere(
              (detail) => detail.category == 'main',
              orElse: () => serviceDetails.first,
            );
          }

          AppLogger.info('使用新服务获取服务详情成功');
        } else {
          throw Exception('Service not found');
        }
      } else {
        // 回退到旧的API服务
        AppLogger.info('回退到旧的API服务');
        final serviceData =
            await api.ServiceDetailApiService.getService(serviceId);
        service.value = serviceData;

        // 获取服务详情
        final serviceDetailData =
            await api.ServiceDetailApiService.getServiceDetail(serviceId);
        serviceDetail.value = serviceDetailData;
      }

      // 加载相关数据
      await Future.wait([
        loadReviews(serviceId),
        loadSimilarServices(serviceId),
        loadProviderProfile(service.value?.providerId ?? ''),
      ]);

      // 分析服务并更新智能操作按钮
      _analyzeServiceAndUpdateActions();
    } catch (e) {
      errorMessage.value = 'Failed to load service detail: $e';
      AppLogger.error('Error loading service detail: $e',
          tag: 'ServiceDetailController');
      
      // 直接抛出错误，不使用Mock数据
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }



  /// 加载评价列表
  Future<void> loadReviews(String serviceId, {bool refresh = false}) async {
    if (serviceId.isEmpty) return;

    if (refresh) {
      reviews.clear();
    }

    isLoadingReviews.value = true;

    try {
      AppLogger.info('Loading reviews for service ID: $serviceId',
          tag: 'ServiceDetailController');

      // 调用真实API服务
      final reviewsData =
          await api.ServiceDetailApiService.getServiceReviews(serviceId);

      if (refresh) {
        reviews.value = reviewsData;
      } else {
        reviews.addAll(reviewsData);
      }

      AppLogger.info('Reviews loaded successfully: ${reviewsData.length}',
          tag: 'ServiceDetailController');
    } catch (e, stack) {
      AppLogger.error('Failed to load reviews',
          error: e, stackTrace: stack, tag: 'ServiceDetailController');
      // 不设置错误状态，因为评价不是必需的
    } finally {
      isLoadingReviews.value = false;
    }
  }

  /// 加载相似服务推荐
  Future<void> loadSimilarServices(String serviceId) async {
    if (serviceId.isEmpty) return;

    isLoadingSimilar.value = true;

    try {
      AppLogger.info('Loading similar services for ID: $serviceId',
          tag: 'ServiceDetailController');

      // 调用真实API服务
      final similarData = await api.ServiceDetailApiService.getSimilarServices(
          serviceId, service.value?.categoryId ?? '1010000');
      // TODO: 将API返回的数据转换为SimilarService对象
      // similarServices.value = similarData.map((data) => SimilarService.fromJson(data)).toList();
      similarServices.value = []; // 暂时使用空列表，等待数据转换实现

      AppLogger.info(
          'Similar services loaded successfully: ${similarData.length}',
          tag: 'ServiceDetailController');
    } catch (e, stack) {
      AppLogger.error('Failed to load similar services',
          error: e, stackTrace: stack, tag: 'ServiceDetailController');
      // 不设置错误状态，因为相似服务不是必需的
    } finally {
      isLoadingSimilar.value = false;
    }
  }

  /// 加载服务提供商信息
  Future<void> loadProviderProfile(String providerId) async {
    if (providerId.isEmpty) return;

    // 防止重复调用
    if (isLoadingProvider.value) {
      AppLogger.info('[Provider] ⚠️ Provider正在加载中，跳过重复请求 - ID: $providerId');
      return;
    }

    AppLogger.info('[Provider] 🚀 开始加载Provider信息 - ID: $providerId');
    isLoadingProvider.value = true;
    AppLogger.info('[Provider] ⏳ isLoadingProvider设置为true，当前值: ${isLoadingProvider.value}');

    try {
      AppLogger.info('Loading provider profile for ID: $providerId',
          tag: 'ServiceDetailController');

      // 调用真实API服务
      final providerData =
          await api.ServiceDetailApiService.getProviderProfile(providerId);
      providerProfile.value = providerData;
      AppLogger.info('[Provider] ✅ Provider数据加载成功，设置到providerProfile');

      AppLogger.info('Provider profile loaded successfully',
          tag: 'ServiceDetailController');
    } catch (e, stack) {
      AppLogger.error('Failed to load provider profile',
          error: e, stackTrace: stack, tag: 'ServiceDetailController');
      AppLogger.info('[Provider] ❌ Provider加载失败，但继续执行finally');
      // 不设置错误状态，因为提供商信息不是必需的
    } finally {
      AppLogger.info('[Provider] 🔄 进入finally块，准备重置loading状态');
      AppLogger.info('[Provider] 🔄 当前isLoadingProvider值: ${isLoadingProvider.value}');
      isLoadingProvider.value = false;
      AppLogger.info('[Provider] ✅ isLoadingProvider设置为false，当前值: ${isLoadingProvider.value}');
      
      // 延迟检查，确保UI有时间响应
      Future.delayed(Duration(milliseconds: 100), () {
        AppLogger.info('[Provider] 🔍 100ms后检查 - isLoadingProvider: ${isLoadingProvider.value}');
      });
      Future.delayed(Duration(milliseconds: 500), () {
        AppLogger.info('[Provider] 🔍 500ms后检查 - isLoadingProvider: ${isLoadingProvider.value}');
      });
    }
  }

  /// 更新报价详情
  void updateQuoteDetails(String key, dynamic value) {
    quoteDetails[key] = value;
    update();
  }

  /// 更新报价状态
  void updateQuoteStatus(String status) {
    quoteRequestStatus.value = status;
    update();
  }

  /// 提交报价请求
  Future<void> submitQuoteRequest() async {
    if (service.value?.id == null) return;

    isLoadingQuote.value = true;
    quoteError.value = '';
    update();

    try {
      // 验证必要字段
      if (quoteDetails['requirements']?.isEmpty ?? true) {
        throw Exception('Service requirements are required');
      }

      // 构建报价请求数据
      final quoteRequest = {
        'serviceId': service.value!.id,
        'providerId': service.value!.providerId,
        'customerId': 'user_123', // TODO: 从用户认证获取
        'requirements': quoteDetails['requirements'],
        'serviceDate': quoteDetails['serviceDate'],
        'serviceTime': quoteDetails['serviceTime'],
        'budget': quoteDetails['budget'],
        'urgencyLevel': quoteDetails['urgencyLevel'],
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      };

      // TODO: 调用API提交报价请求
      // await QuoteApiService.submitQuoteRequest(quoteRequest);

      // 模拟API调用

      // 更新状态
      quoteRequestStatus.value = 'pending';

      // 记录用户行为
      // await PersonalizationService.logUserBehavior(
      //   userId: 'user_123',
      //   serviceId: service!.value!.id,
      //   behaviorType: 'quote_request',
      // );
    } catch (e) {
      quoteError.value = e.toString();
      AppLogger.error('Error submitting quote request: $e',
          tag: 'ServiceDetailController');
    } finally {
      isLoadingQuote.value = false;
      update();
    }
  }

  /// 获取报价详情
  Future<void> getQuoteDetails() async {
    if (service.value?.id == null) return;

    try {
      // TODO: 调用API获取报价详情
      // receivedQuote = await QuoteApiService.getQuoteDetails(service!.value!.id);

      // 模拟数据
      receivedQuote.value = {
        'id': 'quote_123',
        'serviceId': service.value!.id,
        'providerId': service.value!.providerId,
        'amount': 150.0,
        'currency': 'USD',
        'description':
            'Detailed service description based on your requirements',
        'timeline': '2-3 days',
        'terms': 'Payment 50% upfront, 50% upon completion',
        'validUntil':
            DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'status': 'active',
      };
    } catch (e) {
      AppLogger.error('Error getting quote details: $e',
          tag: 'ServiceDetailController');
    }
  }

  /// 接受报价
  Future<void> acceptQuote() async {
    if (receivedQuote.value.isEmpty) return;

    try {
      // TODO: 调用API接受报价
      // await QuoteApiService.acceptQuote(receivedQuote.value['id']);

      // 模拟API调用

      // 更新状态
      quoteRequestStatus.value = 'accepted';

      Get.snackbar(
        '报价已接受',
        '您已接受报价。提供商将很快联系您。',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      AppLogger.error('Error accepting quote: $e',
          tag: 'ServiceDetailController');
      Get.snackbar(
        '错误',
        '接受报价失败，请重试',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 拒绝报价
  Future<void> declineQuote() async {
    if (receivedQuote.value.isEmpty) return;

    try {
      // TODO: 调用API拒绝报价
      // await QuoteApiService.declineQuote(receivedQuote.value['id']);

      // 模拟API调用

      // 更新状态
      quoteRequestStatus.value = 'declined';

      Get.snackbar(
        '报价已拒绝',
        '您已拒绝报价。',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      AppLogger.error('Error declining quote: $e',
          tag: 'ServiceDetailController');
      Get.snackbar(
        '错误',
        '拒绝报价失败，请重试',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 切换收藏状态
  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
    // TODO: 调用API更新收藏状态
  }

  /// 更新评价排序
  void updateReviewSort(String sortType) {
    currentReviewSort.value = sortType;
    AppLogger.info('Review sort updated to: $sortType',
        tag: 'ServiceDetailController');

    // 重新加载评价
    if (service.value != null) {
      loadReviews(service.value!.id, refresh: true);
    }
  }

  /// 更新评价筛选
  void updateReviewFilter(String filterKey, bool value) {
    reviewFilters[filterKey] = value;
    AppLogger.info('Review filter updated: $filterKey = $value',
        tag: 'ServiceDetailController');

    // 重新加载评价
    if (service.value != null) {
      loadReviews(service.value!.id, refresh: true);
    }
  }

  /// 计算路线到提供商
  void calculateRouteToProvider() {
    AppLogger.debug('[ServiceDetailController] calculateRouteToProvider called',
        tag: 'ServiceDetailController');
    // TODO: 实现路线计算逻辑
  }

  // ========================================
  // 智能操作按钮功能
  // ========================================

  /// 初始化智能操作按钮
  void _initializeIntelligentActions() {
    try {
      // 获取或创建ContextManager实例
      try {
        _contextManager = Get.find<ContextManager>();
      } catch (e) {
        _contextManager = Get.put(ContextManager());
      }

      // 获取或创建CartService实例
      try {
        _cartService = Get.find<CartService>();
      } catch (e) {
        _cartService = Get.put(CartService());
      }

      AppLogger.info('服务详情页智能操作按钮初始化成功');
    } catch (e) {
      AppLogger.error('服务详情页智能操作按钮初始化失败: $e');
    }
  }

  /// 分析服务并更新智能操作按钮
  void _analyzeServiceAndUpdateActions() {
    final currentService = service.value;
    if (currentService == null) return;

    try {
      AppLogger.info('🔍 分析服务并更新智能操作按钮: ${currentService.title}');

      // 使用ServiceBookingTypeResolver分析服务类型
      final serviceBookingType = ServiceBookingTypeResolver.resolve(currentService);
      bookingType.value = serviceBookingType;

      // 更新操作能力
      canAddToCart.value = serviceBookingType.supportsCart;
      canDirectBook.value = serviceBookingType.supportsDirectBooking;

      // 更新按钮文本和显示逻辑
      _updateActionButtonsText(serviceBookingType);

      AppLogger.info('🔍 服务分析完成:');
      AppLogger.info('   预订类型: ${serviceBookingType.displayName}');
      AppLogger.info('   支持购物车: ${canAddToCart.value}');
      AppLogger.info('   支持直接预订: ${canDirectBook.value}');

    } catch (e) {
      AppLogger.error('🔍 服务分析失败: $e');
      _setDefaultActions();
    }
  }

  /// 更新操作按钮文本
  void _updateActionButtonsText(ServiceBookingType type) {
    switch (type) {
      case ServiceBookingType.cartOnly:
        primaryActionText.value = '添加到购物车';
        secondaryActionText.value = '';
        showSecondaryAction.value = false;
        break;

      case ServiceBookingType.directBooking:
        primaryActionText.value = '立即预订';
        secondaryActionText.value = '';
        showSecondaryAction.value = false;
        break;

      case ServiceBookingType.hybrid:
        primaryActionText.value = '立即预订';
        secondaryActionText.value = '添加到购物车';
        showSecondaryAction.value = true;
        break;
    }
  }

  /// 设置默认操作
  void _setDefaultActions() {
    primaryActionText.value = '立即预订';
    secondaryActionText.value = '添加到购物车';
    showSecondaryAction.value = true;
    canAddToCart.value = true;
    canDirectBook.value = true;
  }

  /// 主要操作按钮点击处理
  Future<void> onPrimaryActionTap() async {
    final currentService = service.value;
    if (currentService == null) {
      _showError('服务信息未加载');
      return;
    }

    try {
      AppLogger.info('🎯 主要操作按钮点击: ${primaryActionText.value}');

      switch (bookingType.value) {
        case ServiceBookingType.cartOnly:
          await _addToCart();
          break;

        case ServiceBookingType.directBooking:
        case ServiceBookingType.hybrid:
          await _directBooking();
          break;

        default:
          await _directBooking(); // 默认行为
      }

    } catch (e) {
      AppLogger.error('🎯 主要操作失败: $e');
      _showError('操作失败，请稍后重试');
    }
  }

  /// 次要操作按钮点击处理
  Future<void> onSecondaryActionTap() async {
    final currentService = service.value;
    if (currentService == null) {
      _showError('服务信息未加载');
      return;
    }

    try {
      AppLogger.info('🎯 次要操作按钮点击: ${secondaryActionText.value}');

      // 次要操作通常是添加到购物车
      await _addToCart();

    } catch (e) {
      AppLogger.error('🎯 次要操作失败: $e');
      _showError('操作失败，请稍后重试');
    }
  }

  /// 添加到购物车
  Future<void> _addToCart() async {
    final currentService = service.value;
    if (currentService == null) return;

    try {
      AppLogger.info('🛒 添加到购物车: ${currentService.title}');

      // 保存操作上下文
      _contextManager.saveNavigationContext(
        sourcePageId: 'service_detail',
        searchFilters: {
          'serviceId': currentService.id,
          'action': 'add_to_cart',
        },
      );

      // 使用CartService添加到购物车
      await _cartService.addServiceToCart(
        serviceId: currentService.id,
        serviceDetailId: serviceDetail.value?.id ?? 'main_service',
        quantity: 1,
        customizations: {},
        specialInstructions: null,
      );

      _showSuccess('已添加到购物车');

    } catch (e) {
      AppLogger.error('🛒 添加到购物车失败: $e');
      _showError('添加到购物车失败');
    }
  }

  /// 直接预订
  Future<void> _directBooking() async {
    final currentService = service.value;
    if (currentService == null) return;

    try {
      AppLogger.info('📅 直接预订: ${currentService.title}');

      // 保存操作上下文
      _contextManager.saveNavigationContext(
        sourcePageId: 'service_detail',
        searchFilters: {
          'serviceId': currentService.id,
          'action': 'direct_booking',
        },
      );

      // 识别行业类型并导航到相应页面
      final industry = IndustryIdentifier.identifyFromService(currentService);
      
      switch (industry) {
        case IndustryType.food:
          // 餐饮行业 - 导航到FoodOrderPage
          AppLogger.info('🍽️ 导航到餐饮订单页面');
          Get.toNamed('/food_order', parameters: {
            'serviceId': currentService.id,
            'source': 'service_detail_direct_booking',
          });
          break;

        default:
          // 其他行业 - 显示预订表单或导航到通用预订页面
          AppLogger.info('📋 显示通用预订表单');
          _showBookingForm();
      }

    } catch (e) {
      AppLogger.error('📅 直接预订失败: $e');
      _showError('预订失败，请稍后重试');
    }
  }

  /// 显示预订表单
  void _showBookingForm() {
    // TODO: 实现预订表单弹窗
    Get.snackbar(
      '预订功能',
      '预订表单正在开发中，敬请期待！',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.1),
      colorText: Colors.blue,
      duration: const Duration(seconds: 3),
    );
  }

  /// 智能价格计算
  Future<void> calculateIntelligentPrice({
    int quantity = 1,
    Map<String, dynamic>? customizations,
    DateTime? scheduledTime,
  }) async {
    final currentService = service.value;
    if (currentService == null) return;

    try {
      AppLogger.info('💰 智能价格计算开始');

      // TODO: 集成PricingEngine进行动态价格计算
      // final pricingResult = await _pricingEngine.calculatePrice(
      //   service: currentService,
      //   quantity: quantity,
      //   customizations: customizations,
      //   scheduledTime: scheduledTime,
      // );

      // 暂时使用模拟价格计算
      final basePrice = serviceDetail.value?.price ?? 0.0;
      final totalPrice = basePrice * quantity;

      AppLogger.info('💰 价格计算完成: \$${totalPrice.toStringAsFixed(2)}');

      // 更新UI显示价格
      // TODO: 添加价格显示相关的响应式变量

    } catch (e) {
      AppLogger.error('💰 价格计算失败: $e');
    }
  }

  /// 显示成功消息
  void _showSuccess(String message) {
    Get.snackbar(
      '成功',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
      icon: const Icon(Icons.check_circle, color: Colors.green),
      duration: const Duration(seconds: 2),
    );
  }

  /// 显示错误消息
  void _showError(String message) {
    Get.snackbar(
      '错误',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
      icon: const Icon(Icons.error, color: Colors.red),
      duration: const Duration(seconds: 3),
    );
  }

  /// 获取推荐操作文本
  String getRecommendedActionText() {
    final type = bookingType.value;
    if (type == null) return '立即预订';
    
    return ServiceBookingTypeResolver.getRecommendedAction(type);
  }

  /// 检查是否可以执行某个操作
  bool canPerformAction(String action) {
    switch (action.toLowerCase()) {
      case 'add_to_cart':
        return canAddToCart.value;
      case 'direct_booking':
        return canDirectBook.value;
      default:
        return false;
    }
  }

  /// 获取操作按钮配置
  Map<String, dynamic> getActionButtonConfig() {
    return {
      'primaryText': primaryActionText.value,
      'secondaryText': secondaryActionText.value,
      'showSecondary': showSecondaryAction.value,
      'canAddToCart': canAddToCart.value,
      'canDirectBook': canDirectBook.value,
      'bookingType': bookingType.value?.displayName ?? '未知',
    };
  }

  // ========================================
  // 行业特定数据加载方法
  // ========================================

  /// 加载菜单项 (Food - 1010000)
  Future<void> loadMenuItems(String serviceId) async {
    if (serviceId.isEmpty) return;

    isLoadingMenuItems.value = true;

    try {
      AppLogger.info('[MenuItems] 开始加载菜单项 - Service ID: $serviceId');

      final items = await api.ServiceDetailApiService.fetchServiceDetailsByCategory(
        serviceId: serviceId,
        category: 'menu_item',
      );

      menuItems.value = items;
      AppLogger.info('[MenuItems] 菜单项加载成功 - 数量: ${items.length}');

    } catch (e) {
      AppLogger.error('[MenuItems] 菜单项加载失败: $e');
      Get.snackbar('Error', 'Failed to load menu items');
    } finally {
      isLoadingMenuItems.value = false;
    }
  }

  /// 加载服务套餐 (Home Services - 1020000)
  Future<void> loadServicePackages(String serviceId) async {
    if (serviceId.isEmpty) return;

    isLoadingServicePackages.value = true;

    try {
      AppLogger.info('[ServicePackages] 开始加载服务套餐 - Service ID: $serviceId');

      final packages = await api.ServiceDetailApiService.fetchServiceDetailsByCategory(
        serviceId: serviceId,
        category: 'service_package',
      );

      servicePackages.value = packages;
      AppLogger.info('[ServicePackages] 服务套餐加载成功 - 数量: ${packages.length}');

    } catch (e) {
      AppLogger.error('[ServicePackages] 服务套餐加载失败: $e');
      Get.snackbar('Error', 'Failed to load service packages');
    } finally {
      isLoadingServicePackages.value = false;
    }
  }

  /// 加载库存项 (Rental - 1040000)
  Future<void> loadInventoryItems(String serviceId) async {
    if (serviceId.isEmpty) return;

    isLoadingInventoryItems.value = true;

    try {
      AppLogger.info('[Inventory] 开始加载库存项 - Service ID: $serviceId');

      final items = await api.ServiceDetailApiService.fetchServiceDetailsByCategory(
        serviceId: serviceId,
        category: 'rental_item',
      );

      inventoryItems.value = items;
      AppLogger.info('[Inventory] 库存项加载成功 - 数量: ${items.length}');

    } catch (e) {
      AppLogger.error('[Inventory] 库存项加载失败: $e');
      Get.snackbar('Error', 'Failed to load inventory items');
    } finally {
      isLoadingInventoryItems.value = false;
    }
  }

  /// 加载课程 (Education - 1050000)
  Future<void> loadCourses(String serviceId) async {
    if (serviceId.isEmpty) return;

    isLoadingCourses.value = true;

    try {
      AppLogger.info('[Courses] 开始加载课程 - Service ID: $serviceId');

      final items = await api.ServiceDetailApiService.fetchServiceDetailsByCategory(
        serviceId: serviceId,
        category: 'course',
      );

      courses.value = items;
      AppLogger.info('[Courses] 课程加载成功 - 数量: ${items.length}');

    } catch (e) {
      AppLogger.error('[Courses] 课程加载失败: $e');
      Get.snackbar('Error', 'Failed to load courses');
    } finally {
      isLoadingCourses.value = false;
    }
  }

  /// 加载治疗项目 (Life Help - 1060000)
  Future<void> loadTreatments(String serviceId) async {
    if (serviceId.isEmpty) return;

    isLoadingTreatments.value = true;

    try {
      AppLogger.info('[Treatments] 开始加载治疗项目 - Service ID: $serviceId');

      final items = await api.ServiceDetailApiService.fetchServiceDetailsByCategory(
        serviceId: serviceId,
        category: 'treatment',
      );

      treatments.value = items;
      AppLogger.info('[Treatments] 治疗项目加载成功 - 数量: ${items.length}');

    } catch (e) {
      AppLogger.error('[Treatments] 治疗项目加载失败: $e');
      Get.snackbar('Error', 'Failed to load treatments');
    } finally {
      isLoadingTreatments.value = false;
    }
  }
}
