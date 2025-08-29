import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/service_detail.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/similar_service.dart';
import '../../domain/entities/provider_profile.dart';
import '../services/service_detail_api_service.dart' as api;
import '../../../../core/services/services.dart' as core_services;

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

  // 报价相关
  final RxMap<String, dynamic> quoteDetails = <String, dynamic>{}.obs;
  final RxBool isLoadingQuote = false.obs;
  final RxString quoteError = ''.obs;
  final RxMap<String, dynamic> receivedQuote = <String, dynamic>{}.obs;

  // 新增：集成新的服务查询服务
  core_services.IServiceQueryService? _serviceQueryService;
  core_services.IServiceDetailService? _serviceDetailService;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('ServiceDetailController initialized',
        tag: 'ServiceDetailController');

    // 初始化新的服务查询服务
    _initializeNewServices();

    // 获取serviceId参数
    final serviceId = Get.parameters['serviceId'] ?? '';
    if (serviceId.isNotEmpty) {
      // 加载服务详情
      loadServiceDetail(serviceId);

      // 加载相似服务推荐
      loadSimilarServices(serviceId);

      // 加载提供商信息
      loadProviderProfile(serviceId);

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
          // 转换为旧版本Service对象
          final legacyService = Service(
            id: serviceData.id,
            title: serviceData.title is String
                ? serviceData.title
                : (serviceData.title as Map<String, dynamic>?)?['en'] ??
                    'Service',
            description: serviceData.description is String
                ? serviceData.description
                : (serviceData.description as Map<String, dynamic>?)?['en'] ??
                    'Service description',
            price: serviceData.price ?? 0.0,
            currency: serviceData.currency ?? 'USD',
            pricingType: serviceData.pricingType ?? 'fixed',
            categoryId: serviceData.categoryId?.toString() ?? '',
            categoryLevel2Id: serviceData.categoryLevel2Id?.toString() ?? '',
            providerId: serviceData.providerId ?? '',
            serviceDeliveryMethod:
                serviceData.serviceDeliveryMethod ?? 'on_site',
            createdAt: serviceData.createdAt ?? DateTime.now(),
            images: serviceData.images ?? [],
            rating: serviceData.rating ?? 0.0,
            reviewCount: serviceData.reviewCount ?? 0,
            isActive: serviceData.isActive ?? true,
            latitude: serviceData.latitude,
            longitude: serviceData.longitude,
          );
          service.value = legacyService;

          // 获取服务详情
          final serviceDetails =
              await _serviceDetailService!.getServiceDetails(serviceId);
          if (serviceDetails.isNotEmpty) {
            final mainDetail = serviceDetails.firstWhere(
              (detail) => detail.category == 'main',
              orElse: () => serviceDetails.first,
            );

            // 转换为旧版本ServiceDetail对象
            final legacyServiceDetail = ServiceDetail(
              id: mainDetail.id,
              serviceId: mainDetail.serviceId,
              name: mainDetail.name,
              category: mainDetail.category,
              pricingType: mainDetail.pricingType,
              price: mainDetail.price,
              currency: mainDetail.currency,
              negotiationDetails: null, // core_services.ServiceDetail没有此字段
              durationType: null, // core_services.ServiceDetail没有此字段
              duration: mainDetail.duration != null
                  ? int.tryParse(mainDetail.duration!)
                  : null,
              images: mainDetail.images,
              tags: mainDetail.tags,
              serviceAreaCodes: mainDetail.serviceAreaCodes,
            );
            serviceDetail.value = legacyServiceDetail;
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
    } catch (e) {
      errorMessage.value = 'Failed to load service detail: $e';
      AppLogger.error('Error loading service detail: $e',
          tag: 'ServiceDetailController');

      // 如果真实数据加载失败，使用Mock数据作为备用
      _loadMockData(serviceId);
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载Mock数据作为备用
  void _loadMockData(String serviceId) {
    AppLogger.info('Loading mock data as fallback for service: $serviceId');

    final mockService = Service(
      id: serviceId,
      title: '专业清洁服务',
      description: '提供高质量的家庭清洁服务，包括深度清洁、定期维护等。我们的专业团队使用环保清洁产品，确保您的家居环境既清洁又健康。',
      price: 120.0,
      currency: 'USD',
      pricingType: 'fixed',
      categoryId: '1020000',
      categoryLevel2Id: '1020100',
      providerId: 'provider_123',
      serviceDeliveryMethod: 'on_site',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      images: [
        'https://picsum.photos/seed/service1/400/300',
        'https://picsum.photos/seed/service2/400/300',
        'https://picsum.photos/seed/service3/400/300',
      ],
      rating: 4.8,
      reviewCount: 156,
      isActive: true,
      latitude: 43.6532,
      longitude: -79.3832,
    );

    final mockServiceDetail = ServiceDetail(
      id: 'detail_123',
      serviceId: serviceId,
      name: {'en': 'Professional Cleaning Service', 'zh': '专业清洁服务'},
      category: 'main',
      pricingType: 'fixed',
      price: 120.0,
      currency: 'USD',
      negotiationDetails: '价格可根据服务范围和频率进行调整',
      durationType: 'hours',
      duration: 3,
      images: [
        'https://picsum.photos/seed/detail1/400/300',
        'https://picsum.photos/seed/detail2/400/300',
      ],
      tags: ['深度清洁', '环保产品', '专业团队', '定期维护'],
      serviceAreaCodes: ['M5V', 'M5X', 'M6G', 'M6J'],
    );

    service.value = mockService;
    serviceDetail.value = mockServiceDetail;
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
        reviews.value = reviewsData.cast<Review>();
      } else {
        reviews.addAll(reviewsData.cast<Review>());
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

    isLoadingProvider.value = true;

    try {
      AppLogger.info('Loading provider profile for ID: $providerId',
          tag: 'ServiceDetailController');

      // 调用真实API服务
      final providerData =
          await api.ServiceDetailApiService.getProviderProfile(providerId);
      providerProfile.value = providerData;

      AppLogger.info('Provider profile loaded successfully',
          tag: 'ServiceDetailController');
    } catch (e, stack) {
      AppLogger.error('Failed to load provider profile',
          error: e, stackTrace: stack, tag: 'ServiceDetailController');
      // 不设置错误状态，因为提供商信息不是必需的
    } finally {
      isLoadingProvider.value = false;
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
}
