import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/service_detail.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/similar_service.dart';
import '../../domain/entities/provider_profile.dart';

class ServiceDetailController extends GetxController {
  // 服务数据
  final Rx<Service?> service = Rx<Service?>(null);
  final Rx<ServiceDetail?> serviceDetail = Rx<ServiceDetail?>(null);
  
  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool isLoadingReviews = false.obs;
  final RxBool isLoadingProvider = false.obs;
  
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

  @override
  void onInit() {
    super.onInit();
    // 获取serviceId参数
    final serviceId = Get.parameters['serviceId'] ?? '';
    // 加载服务详情
    loadServiceDetail(serviceId);
    
    // 加载相似服务推荐
    loadSimilarServices();
    
    // 加载提供商信息
    loadProviderProfile();
  }

  /// 加载服务详情
  Future<void> loadServiceDetail(String serviceId) async {
    if (serviceId.isEmpty) {
      throw Exception('Service ID is required');
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // TODO: 调用真实API
      // final response = await ServiceApiService.getServiceDetail(serviceId);
      
      // 模拟数据 - 使用更可靠的图片URL
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
          'https://picsum.photos/seed/cleaning1/400/300',
          'https://picsum.photos/seed/cleaning2/400/300',
          'https://picsum.photos/seed/cleaning3/400/300',
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
        name: {
          'en': 'Professional Cleaning Service',
          'zh': '专业清洁服务'
        },
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
      
      // 加载相关数据
      await Future.wait([
        loadReviews(),
        loadSimilarServices(),
        loadProviderProfile(),
      ]);
      
    } catch (e) {
      errorMessage.value = 'Failed to load service detail: $e';
      AppLogger.error('Error loading service detail: $e', tag: 'ServiceDetailController');
    } finally {
      isLoading.value = false;
    }
  }

  /// 加载相似服务推荐
  Future<void> loadSimilarServices() async {
    try {
      final mockSimilarServices = [
        SimilarService(
          id: 'similar_1',
          title: '专业家居清洁',
          description: '深度清洁服务，包括厨房、浴室、客厅等',
          price: 45.0,
          currency: 'USD',
          categoryId: 'cleaning',
          providerId: 'provider_789',
          images: ['https://picsum.photos/seed/similar1/300/200'],
          rating: 4.8,
          reviewCount: 156,
          similarityScore: 0.92,
        ),
        SimilarService(
          id: 'similar_2',
          title: '办公室清洁服务',
          description: '专业办公室清洁，保持工作环境整洁',
          price: 60.0,
          currency: 'USD',
          categoryId: 'cleaning',
          providerId: 'provider_456',
          images: ['https://picsum.photos/seed/similar2/300/200'],
          rating: 4.6,
          reviewCount: 89,
          similarityScore: 0.85,
        ),
        SimilarService(
          id: 'similar_3',
          title: '深度清洁套餐',
          description: '全屋深度清洁，包括地毯、窗帘等',
          price: 120.0,
          currency: 'USD',
          categoryId: 'cleaning',
          providerId: 'provider_123',
          images: ['https://picsum.photos/seed/similar3/300/200'],
          rating: 4.9,
          reviewCount: 234,
          similarityScore: 0.78,
        ),
      ];
      
      similarServices.value = mockSimilarServices;
    } catch (e) {
      AppLogger.error('Error loading similar services: $e', tag: 'ServiceDetailController');
      similarServices.clear();
    }
  }

  /// 加载服务提供商信息
  Future<void> loadProviderProfile() async {
    try {
      final mockProvider = ProviderProfile(
        id: 'provider_123',
        name: '专业清洁服务公司',
        description: '提供专业的家居清洁服务，拥有多年经验和专业团队',
        avatar: 'https://picsum.photos/200/200?random=10',
        phone: '+1 (555) 123-4567',
        email: 'contact@cleaningpro.com',
        address: '123 Main Street, San Francisco, CA 94102',
        rating: 4.8,
        reviewCount: 156,
        completedOrders: 342,
        isVerified: true,
        businessLicense: 'CA123456789',
      );
      
      providerProfile.value = mockProvider;
    } catch (e) {
      AppLogger.error('Error loading provider profile: $e', tag: 'ServiceDetailController');
      providerProfile.value = null;
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
    if (service?.value?.id == null) return;
    
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
        'serviceId': service!.value!.id,
        'providerId': service!.value!.providerId,
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
      AppLogger.error('Error submitting quote request: $e', tag: 'ServiceDetailController');
    } finally {
      isLoadingQuote.value = false;
      update();
    }
  }

  /// 获取报价详情
  Future<void> getQuoteDetails() async {
    if (service?.value?.id == null) return;
    
    try {
      // TODO: 调用API获取报价详情
      // receivedQuote = await QuoteApiService.getQuoteDetails(service!.value!.id);
      
      // 模拟数据
      receivedQuote.value = {
        'id': 'quote_123',
        'serviceId': service!.value!.id,
        'providerId': service!.value!.providerId,
        'amount': 150.0,
        'currency': 'USD',
        'description': 'Detailed service description based on your requirements',
        'timeline': '2-3 days',
        'terms': 'Payment 50% upfront, 50% upon completion',
        'validUntil': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'status': 'active',
      };
      
    } catch (e) {
      AppLogger.error('Error getting quote details: $e', tag: 'ServiceDetailController');
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
      AppLogger.error('Error accepting quote: $e', tag: 'ServiceDetailController');
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
      AppLogger.error('Error declining quote: $e', tag: 'ServiceDetailController');
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

  /// 加载评价
  Future<void> loadReviews() async {
    try {
      isLoadingReviews.value = true;
      
      // 模拟加载评价数据
      
      final mockReviews = [
        Review(
          id: 'review_1',
          serviceId: service?.value?.id ?? '',
          userId: 'user_1',
          userName: '张先生',
          userAvatar: 'https://picsum.photos/50/50?random=1',
          rating: 5,
          comment: '服务非常好，清洁得很彻底，价格也很合理。',
          images: ['https://picsum.photos/200/200?random=10'],
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          isVerified: true,
        ),
        Review(
          id: 'review_2',
          serviceId: service?.value?.id ?? '',
          userId: 'user_2',
          userName: '李女士',
          userAvatar: 'https://picsum.photos/50/50?random=2',
          rating: 4,
          comment: '整体满意，工作人员很专业，只是时间稍微晚了一点。',
          images: [],
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          isVerified: true,
        ),
        Review(
          id: 'review_3',
          serviceId: service?.value?.id ?? '',
          userId: 'user_3',
          userName: '王先生',
          userAvatar: 'https://picsum.photos/50/50?random=3',
          rating: 5,
          comment: '第二次使用这个服务了，一如既往的好。推荐！',
          images: ['https://picsum.photos/200/200?random=11', 'https://picsum.photos/200/200?random=12'],
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          isVerified: false,
        ),
      ];
      
      reviews.value = mockReviews;
    } catch (e) {
      AppLogger.error('Error loading reviews: $e', tag: 'ServiceDetailController');
      reviews.clear();
    } finally {
      isLoadingReviews.value = false;
    }
  }

  /// 计算路线到提供商
  void calculateRouteToProvider() {
    AppLogger.debug('[ServiceDetailController] calculateRouteToProvider called', tag: 'ServiceDetailController');
    // TODO: 实现路线计算逻辑
  }
}
