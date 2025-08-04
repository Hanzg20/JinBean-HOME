import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/features/customer/services/services/similar_services_api_service.dart';
import 'package:jinbeanpod_83904710/features/customer/services/services/similarity_calculator_service.dart';
import 'package:jinbeanpod_83904710/features/customer/services/services/service_detail_api_service.dart';
import 'package:jinbeanpod_83904710/features/customer/services/services/chat_service.dart';
import 'package:jinbeanpod_83904710/features/customer/services/services/personalization_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jinbeanpod_83904710/features/service_map/service_map_controller.dart';
import 'package:jinbeanpod_83904710/features/service_map/service_marker_model.dart';
import 'package:jinbeanpod_83904710/core/controllers/location_controller.dart';

class Service {
  final String id;
  final String title;
  final String description;
  final double averageRating;
  final int reviewCount;
  final String providerId;
  final String categoryLevel1Id;
  final String? categoryLevel2Id;
  final String status;
  final String serviceDeliveryMethod;
  final DateTime createdAt;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.averageRating,
    required this.reviewCount,
    required this.providerId,
    required this.categoryLevel1Id,
    this.categoryLevel2Id,
    required this.status,
    required this.serviceDeliveryMethod,
    required this.createdAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      title: json['title']?['en'] ?? 'Unknown Service',
      description: json['description']?['en'] ?? '',
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      providerId: json['provider_id'],
      categoryLevel1Id: json['category_level1_id'].toString(),
      categoryLevel2Id: json['category_level2_id']?.toString(),
      status: json['status'],
      serviceDeliveryMethod: json['service_delivery_method'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ServiceDetail {
  final String serviceId;
  final String pricingType;
  final double? price;
  final String? currency;
  final String? negotiationDetails;
  final String durationType;
  final Duration? duration;
  final List<String> images;
  final List<String> tags;
  final List<String> serviceAreaCodes;
  final Map<String, dynamic>? serviceDetailsJson;

  ServiceDetail({
    required this.serviceId,
    required this.pricingType,
    this.price,
    this.currency,
    this.negotiationDetails,
    required this.durationType,
    this.duration,
    required this.images,
    required this.tags,
    required this.serviceAreaCodes,
    this.serviceDetailsJson,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      serviceId: json['service_id'],
      pricingType: json['pricing_type'],
      price: json['price']?.toDouble(),
      currency: json['currency'],
      negotiationDetails: json['negotiation_details'],
      durationType: json['duration_type'],
      duration: json['duration'] != null 
          ? Duration(minutes: int.parse(json['duration'].toString().split(':')[0]) * 60 + 
                     int.parse(json['duration'].toString().split(':')[1]))
          : null,
      images: List<String>.from(json['images_url'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      serviceAreaCodes: List<String>.from(json['service_area_codes'] ?? []),
      serviceDetailsJson: json['service_details_json'],
    );
  }
}

class ProviderProfile {
  final String id;
  final String companyName;
  final String contactPhone;
  final String contactEmail;
  final String? companyDescription;
  final double ratingsAvg;
  final int reviewCount;
  final String? businessLicense;
  final String? insuranceInfo;
  final List<String> serviceCategories;
  final String? profileImageUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProviderProfile({
    required this.id,
    required this.companyName,
    required this.contactPhone,
    required this.contactEmail,
    this.companyDescription,
    required this.ratingsAvg,
    required this.reviewCount,
    this.businessLicense,
    this.insuranceInfo,
    required this.serviceCategories,
    this.profileImageUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['id'],
      companyName: json['company_name'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      companyDescription: json['company_description'],
      ratingsAvg: (json['ratings_avg'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      businessLicense: json['business_license'],
      insuranceInfo: json['insurance_info'],
      serviceCategories: List<String>.from(json['service_categories'] ?? []),
      profileImageUrl: json['profile_image_url'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class ServiceDetailController extends GetxController {
  Service? service;
  ServiceDetail? serviceDetail;
  ProviderProfile? provider;
  bool isLoading = false;
  String errorMessage = '';
  
  // 新增相似服务相关属性
  List<dynamic> similarServices = [];
  bool isLoadingSimilarServices = false;
  String similarServicesError = '';
  
  // 新增评价相关属性
  bool isLoadingReviewStats = false;
  
  // 新增聊天相关属性
  ChatSession? currentChatSession;
  List<ChatMessage> chatMessages = [];
  bool isLoadingChat = false;
  String chatError = '';
  
  // 新增位置和可用性相关属性
  Map<String, dynamic>? serviceLocation;
  Map<String, dynamic>? serviceAvailability;
  Map<String, dynamic>? trustAndSecurityInfo;
  List<Map<String, dynamic>> providerPortfolio = [];
  
  // 个性化数据
  Map<String, dynamic>? userPreferences;
  List<Map<String, dynamic>> historyBasedRecommendations = [];
  List<Map<String, dynamic>> similarUserRecommendations = [];
  List<Map<String, dynamic>> personalizedOffers = [];
  bool isLoadingPersonalization = false;
  String personalizationError = '';

  // 报价相关数据
  String quoteError = '';
  
  // 聊天服务实例
  late ChatService _chatService;
  
  // 新增：地图功能增强相关属性
  // 移除重复的地图控制属性，使用ServiceMapController的公共方法
  double? serviceRadiusKm;
  Map<String, dynamic>? serviceAreaInfo;
  
  // 复用ServiceMapController的功能
  late ServiceMapController _serviceMapController;
  
  // 添加公共getter来访问ServiceMapController
  ServiceMapController get serviceMapController => _serviceMapController;
  
  List<ServiceMarkerModel> nearbyServices = [];
  ServiceMarkerModel? currentServiceMarker;
  bool isLoadingNearbyServices = false;
  
  // 地图控制相关
  GoogleMapController? mapController;
  LatLng? currentServiceLocation;
  
  // 移除重复的路线导航相关属性，使用ServiceMapController的公共方法
  
  // 新增：评价系统优化相关属性
  Map<String, bool> reviewFilters = {
    'all': true,
    '5star': false,
    '4star': false,
    '3star': false,
    '2star': false,
    '1star': false,
    'withPhotos': false,
    'verified': false,
  };
  List<Review> filteredReviews = [];
  Map<String, int> ratingDistribution = {};
  
  // 评价系统数据 - 响应式变量
  final RxList<Review> reviews = <Review>[].obs;
  final RxList<Review> filteredReviews = <Review>[].obs;
  final RxBool isLoadingReviews = false.obs;
  final RxString reviewsError = ''.obs;
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
  final RxString currentReviewSort = 'newest'.obs;
  final RxMap<String, int> ratingDistribution = <String, int>{}.obs;

  // 报价系统相关数据
  final RxMap<String, dynamic> quoteDetails = <String, dynamic>{}.obs;
  final RxString quoteRequestStatus = ''.obs;
  final RxMap<String, dynamic> receivedQuote = <String, dynamic>{}.obs;
  final RxBool isLoadingQuote = false.obs;

  // 预订系统相关数据
  final RxMap<String, dynamic> bookingDetails = <String, dynamic>{}.obs;
  final RxBool isLoadingBooking = false.obs;

  // 收藏和分享相关数据
  final RxBool isFavorite = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _chatService = MsgNexusService('demo_api_key');
    
    // 初始化地图控制器
    _serviceMapController = Get.put(ServiceMapController());
    
    // 获取serviceId参数
    final serviceId = Get.parameters['serviceId'];
    if (serviceId != null && serviceId.isNotEmpty) {
      // 分阶段加载数据，先加载核心数据
      _loadCoreData(serviceId);
    } else {
      // 如果没有serviceId，使用mock数据
      _setMockData();
      loadSimilarServices();
      loadPersonalizationData();
    }
    
    // 初始化评价系统
    _initializeReviewSystem();
    
    // 初始化地图功能
    _initializeMapFeatures();
  }

  void _loadCoreData(String serviceId) async {
    isLoading = true;
    update();
    
    try {
      // 并行加载核心数据
      await Future.wait([
        _loadServiceData(serviceId),
        _loadServiceDetailData(serviceId),
        _loadProviderData(serviceId),
      ]);
      
      // 核心数据加载完成后，异步加载次要数据
      _loadSecondaryData(serviceId);
      
    } catch (e) {
      print('Error loading core data: $e');
      errorMessage = 'Failed to load service details';
      // 使用mock数据作为fallback
      _setMockData();
      loadSimilarServices();
      loadPersonalizationData();
    } finally {
      isLoading = false;
      update();
    }
  }

  void _loadSecondaryData(String serviceId) async {
    // 异步加载次要数据，不阻塞UI
    Future.wait([
      _loadReviewsData(serviceId),
      _loadLocationData(serviceId),
      _loadAvailabilityData(serviceId),
      _loadTrustAndSecurityData(serviceId),
      _loadPortfolioData(serviceId),
      _loadFavoriteStatus(serviceId),
      loadSimilarServices(),
      loadPersonalizationData(),
    ]).then((_) {
      update(); // 更新UI
    }).catchError((e) {
      print('Error loading secondary data: $e');
      // 次要数据加载失败不影响核心功能
    });
  }
  
  Future<void> _loadServiceData(String serviceId) async {
    try {
      service = await ServiceDetailApiService.getService(serviceId);
    } catch (e) {
      print('Error loading service data: $e');
    }
  }
  
  Future<void> _loadServiceDetailData(String serviceId) async {
    try {
      serviceDetail = await ServiceDetailApiService.getServiceDetail(serviceId);
    } catch (e) {
      print('Error loading service detail data: $e');
    }
  }
  
  Future<void> _loadProviderData(String serviceId) async {
    try {
      if (service?.providerId != null) {
        provider = await ServiceDetailApiService.getProviderProfile(service!.providerId);
      }
    } catch (e) {
      print('Error loading provider data: $e');
    }
  }
  
  Future<void> _loadReviewsData(String serviceId) async {
    try {
      isLoadingReviews = true;
      update();
      
      reviews = await ServiceDetailApiService.getServiceReviews(serviceId, limit: 10);
      
    } catch (e) {
      reviewsError = e.toString();
    } finally {
      isLoadingReviews = false;
      update();
    }
  }
  
  Future<void> _loadLocationData(String serviceId) async {
    try {
      serviceLocation = await ServiceDetailApiService.getServiceLocation(serviceId);
    } catch (e) {
      print('Error loading location data: $e');
    }
  }
  
  Future<void> _loadAvailabilityData(String serviceId) async {
    try {
      serviceAvailability = await ServiceDetailApiService.getServiceAvailability(serviceId);
    } catch (e) {
      print('Error loading availability data: $e');
    }
  }
  
  Future<void> _loadTrustAndSecurityData(String serviceId) async {
    try {
      if (service?.providerId != null) {
        trustAndSecurityInfo = await ServiceDetailApiService.getTrustAndSecurityInfo(service!.providerId);
      }
    } catch (e) {
      print('Error loading trust and security data: $e');
    }
  }
  
  Future<void> _loadPortfolioData(String serviceId) async {
    try {
      if (service?.providerId != null) {
        providerPortfolio = await ServiceDetailApiService.getProviderPortfolio(service!.providerId);
      }
    } catch (e) {
      print('Error loading portfolio data: $e');
    }
  }
  
  Future<void> _loadFavoriteStatus(String serviceId) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        isFavorite = await ServiceDetailApiService.checkFavoriteStatus(serviceId, userId);
      }
    } catch (e) {
      print('Error loading favorite status: $e');
    }
  }
  
  Future<void> _logServiceView(String serviceId) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await ServiceDetailApiService.logServiceView(serviceId, userId);
      }
    } catch (e) {
      print('Error logging service view: $e');
    }
  }

  // 新增相似服务模型
  Future<void> loadSimilarServices() async {
    try {
      isLoadingSimilarServices = true;
      update();
      
      // 使用API服务获取相似服务
      final services = await SimilarServicesApiService.getSimilarServices(
        service?.id ?? '',
        limit: 5,
        minSimilarityScore: 0.7,
      );
      
      similarServices = services;
      
    } catch (e) {
      similarServicesError = e.toString();
    } finally {
      isLoadingSimilarServices = false;
      update();
    }
  }

  void navigateToSimilarService(String serviceId) {
    // 记录用户交互
    SimilarServicesApiService.logSimilarServiceInteraction(
      service?.id ?? '',
      serviceId,
      'click',
    );
    
    Get.toNamed('/service_detail', parameters: {'serviceId': serviceId});
  }

  void viewAllSimilarServices() {
    // 记录用户交互
    SimilarServicesApiService.logSimilarServiceInteraction(
      service?.id ?? '',
      '',
      'view_all',
    );
    
    // 导航到相似服务列表页面
    Get.toNamed('/similar_services', parameters: {
      'currentServiceId': service?.id ?? '',
      'categoryId': service?.categoryLevel1Id ?? '',
    });
  }

  void toggleFavorite() async {
    if (service == null) return;
    
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        Get.snackbar(
          'Error',
          'Please login to add favorites',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      isFavorite = !isFavorite;
      update();
      
      await ServiceDetailApiService.toggleFavorite(service!.id, userId, isFavorite);
      
      Get.snackbar(
        'Favorite',
        isFavorite ? 'Added to favorites' : 'Removed from favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // 恢复状态
      isFavorite = !isFavorite;
      update();
      
      Get.snackbar(
        'Error',
        'Failed to update favorite status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void shareService() {
    Get.snackbar(
      'Share',
      'Sharing service...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void contactProvider() {
    if (provider?.contactPhone == null && provider?.contactEmail == null) {
      Get.snackbar(
        'Error',
        'No contact information available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text('Contact Provider'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (provider?.contactPhone != null)
              ListTile(
                leading: Icon(Icons.phone),
                title: Text('Call'),
                subtitle: Text(provider!.contactPhone),
                onTap: () {
                  Get.back();
                  // 这里可以添加拨打电话的逻辑
                  Get.snackbar('Call', 'Calling ${provider!.contactPhone}...');
                },
              ),
            if (provider?.contactEmail != null)
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Email'),
                subtitle: Text(provider!.contactEmail),
                onTap: () {
                  Get.back();
                  // 这里可以添加发送邮件的逻辑
                  Get.snackbar('Email', 'Opening email app...');
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void bookService() {
    Get.dialog(
      AlertDialog(
        title: Text('Book Service'),
        content: Text('Are you sure you want to book this service?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Service booked successfully!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  /// 开始聊天
  Future<void> startChat() async {
    if (service == null || provider == null) return;
    
    try {
      isLoadingChat = true;
      update();
      
      // 创建或获取聊天会话
      currentChatSession = await _chatService.createChatSession(
        provider!.id,
        service!.id,
      );
      
      // 加载聊天消息
      await loadChatMessages();
      
      // 导航到聊天页面
      Get.toNamed('/chat', parameters: {
        'sessionId': currentChatSession!.id,
        'providerName': provider!.companyName,
      });
      
    } catch (e) {
      chatError = e.toString();
      Get.snackbar(
        'Error',
        'Failed to start chat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingChat = false;
      update();
    }
  }
  
  /// 加载聊天消息
  Future<void> loadChatMessages() async {
    if (currentChatSession == null) return;
    
    try {
      chatMessages = await _chatService.getMessages(currentChatSession!.id);
      update();
    } catch (e) {
      chatError = e.toString();
      update();
    }
  }
  
  /// 发送消息
  Future<void> sendMessage(String message) async {
    if (currentChatSession == null) return;
    
    try {
      final content = MessageContent(type: 'text', content: message);
      final newMessage = await _chatService.sendMessage(currentChatSession!.id, content);
      
      chatMessages.add(newMessage);
      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send message',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// 加载个性化推荐数据
  Future<void> loadPersonalizationData() async {
    if (service?.id == null) return;
    
    isLoadingPersonalization = true;
    personalizationError = '';
    update();

    try {
      // 记录用户查看行为 - 添加错误处理
      try {
        await PersonalizationService.logUserBehavior(
          userId: GetStorage().read('userId') ?? '',
          serviceId: service!.id,
          behaviorType: UserBehaviorType.view,
        );
      } catch (e) {
        print('[ServiceDetailController] Error logging user behavior: $e');
        // 不阻塞其他功能，继续执行
      }

      // 并行加载个性化数据，每个都有独立的错误处理
      await Future.wait([
        _loadUserPreferences().catchError((e) {
          print('[ServiceDetailController] Error loading user preferences: $e');
          return null;
        }),
        _loadHistoryBasedRecommendations().catchError((e) {
          print('[ServiceDetailController] Error loading history-based recommendations: $e');
          return null;
        }),
        _loadSimilarUserRecommendations().catchError((e) {
          print('[ServiceDetailController] Error loading similar user recommendations: $e');
          return null;
        }),
        _loadPersonalizedOffers().catchError((e) {
          print('[ServiceDetailController] Error loading personalized offers: $e');
          return null;
        }),
      ]);
    } catch (e) {
      personalizationError = 'Failed to load personalized recommendations: $e';
      print('[ServiceDetailController] Error loading personalization data: $e');
    } finally {
      isLoadingPersonalization = false;
      update();
    }
  }

  Future<void> _loadUserPreferences() async {
    try {
      final userId = GetStorage().read('userId') ?? '';
      userPreferences = await PersonalizationService.getUserPreferences(userId);
    } catch (e) {
      print('Error loading user preferences: $e');
    }
  }

  Future<void> _loadHistoryBasedRecommendations() async {
    try {
      final userId = GetStorage().read('userId') ?? '';
      historyBasedRecommendations = await PersonalizationService.getHistoryBasedRecommendations(
        userId,
        service!.id,
      );
    } catch (e) {
      print('Error loading history-based recommendations: $e');
    }
  }

  Future<void> _loadSimilarUserRecommendations() async {
    try {
      final userId = GetStorage().read('userId') ?? '';
      similarUserRecommendations = await PersonalizationService.getSimilarUserRecommendations(
        userId,
        service!.id,
      );
    } catch (e) {
      print('Error loading similar user recommendations: $e');
    }
  }

  Future<void> _loadPersonalizedOffers() async {
    try {
      final userId = GetStorage().read('userId') ?? '';
      personalizedOffers = await PersonalizationService.getPersonalizedOffers(userId);
    } catch (e) {
      print('Error loading personalized offers: $e');
    }
  }

  /// 更新报价详情
  void updateQuoteDetails(String key, dynamic value) {
    quoteDetails[key] = value;
    update();
  }

  /// 更新报价状态
  void updateQuoteStatus(String status) {
    quoteRequestStatus = status;
    update();
  }

  /// 提交报价请求
  Future<void> submitQuoteRequest() async {
    if (service?.id == null) return;
    
    isLoadingQuote = true;
    quoteError = '';
    update();

    try {
      // 验证必要字段
      if (quoteDetails['requirements']?.isEmpty ?? true) {
        throw Exception('Service requirements are required');
      }

      // 构建报价请求数据
      final quoteRequest = {
        'serviceId': service!.id,
        'providerId': service!.providerId,
        'customerId': GetStorage().read('userId') ?? '',
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
      await Future.delayed(const Duration(seconds: 2));
      
      // 更新状态
      quoteRequestStatus = 'pending';
      
      // 记录用户行为
      await PersonalizationService.logUserBehavior(
        userId: GetStorage().read('userId') ?? '',
        serviceId: service!.id,
        behaviorType: UserBehaviorType.quoteRequest,
      );

    } catch (e) {
      quoteError = e.toString();
      print('Error submitting quote request: $e');
    } finally {
      isLoadingQuote = false;
      update();
    }
  }

  /// 获取报价详情
  Future<void> getQuoteDetails() async {
    if (service?.id == null) return;
    
    try {
      // TODO: 调用API获取报价详情
      // receivedQuote = await QuoteApiService.getQuoteDetails(service!.id);
      
      // 模拟数据
      await Future.delayed(const Duration(seconds: 1));
      receivedQuote = {
        'id': 'quote_123',
        'serviceId': service!.id,
        'providerId': service!.providerId,
        'amount': 150.0,
        'currency': 'USD',
        'description': 'Detailed service description based on your requirements',
        'timeline': '2-3 days',
        'terms': 'Payment 50% upfront, 50% upon completion',
        'validUntil': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'status': 'active',
      };
      
    } catch (e) {
      print('Error getting quote details: $e');
    }
  }

  /// 接受报价
  Future<void> acceptQuote() async {
    if (receivedQuote == null) return;
    
    try {
      // TODO: 调用API接受报价
      // await QuoteApiService.acceptQuote(receivedQuote!['id']);
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      // 更新状态
      quoteRequestStatus = 'accepted';
      
      Get.snackbar(
        'Quote Accepted',
        'You have accepted the quote. The provider will contact you soon.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } catch (e) {
      print('Error accepting quote: $e');
      Get.snackbar(
        'Error',
        'Failed to accept quote. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// 拒绝报价
  Future<void> declineQuote() async {
    if (receivedQuote == null) return;
    
    try {
      // TODO: 调用API拒绝报价
      // await QuoteApiService.declineQuote(receivedQuote!['id']);
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      // 更新状态
      quoteRequestStatus = 'declined';
      
      Get.snackbar(
        'Quote Declined',
        'You have declined the quote.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      
    } catch (e) {
      print('Error declining quote: $e');
    }
  }

  // 新增：初始化评价系统
  void _initializeReviewSystem() {
    // 加载评价数据
    loadReviews();
    // 计算评分分布
    _calculateRatingDistribution();
    // 应用当前筛选和排序
    _applyReviewFilters();
  }

  // 新增：加载评价数据
  Future<void> loadReviews() async {
    isLoadingReviews = true;
    reviewsError = '';
    update();
    
    try {
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 800));
      
      // 使用mock数据
      reviews = [
        Review(
          id: '1',
          serviceId: 'service1',
          userId: 'user1',
          userName: 'John D.',
          rating: 5,
          content: 'Excellent service! The provider was very professional and completed the work on time. Highly recommended!',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          images: ['assets/images/review_placeholder_1.jpg'],
          isVerified: true,
          helpfulCount: 12,
        ),
        Review(
          id: '2',
          serviceId: 'service1',
          userId: 'user2',
          userName: 'Sarah M.',
          rating: 4,
          content: 'Good quality work, but took a bit longer than expected. Still satisfied with the result.',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          images: [],
          isVerified: true,
          helpfulCount: 8,
        ),
        Review(
          id: '3',
          serviceId: 'service1',
          userId: 'user3',
          userName: 'Mike R.',
          rating: 5,
          content: 'Amazing experience! The provider went above and beyond my expectations. Will definitely use again.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          images: ['assets/images/review_placeholder_2.jpg', 'assets/images/review_placeholder_3.jpg'],
          isVerified: false,
          helpfulCount: 15,
        ),
        Review(
          id: '4',
          serviceId: 'service1',
          userId: 'user4',
          userName: 'Lisa K.',
          rating: 3,
          content: 'Service was okay, but communication could have been better. The work quality was acceptable.',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          images: [],
          isVerified: true,
          helpfulCount: 3,
        ),
        Review(
          id: '5',
          serviceId: 'service1',
          userId: 'user5',
          userName: 'David W.',
          rating: 5,
          content: 'Perfect service from start to finish. Very responsive and professional. Highly recommend!',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          images: ['assets/images/review_placeholder_4.jpg'],
          isVerified: true,
          helpfulCount: 20,
        ),
      ];
      
      _calculateRatingDistribution();
      _applyReviewFilters();
      
    } catch (e) {
      reviewsError = 'Failed to load reviews: $e';
      print('[ServiceDetailController] Error loading reviews: $e');
    } finally {
      isLoadingReviews = false;
      update();
    }
  }

  // 新增：计算评分分布
  void _calculateRatingDistribution() {
    ratingDistribution.clear();
    for (int i = 1; i <= 5; i++) {
      ratingDistribution[i.toString()] = reviews.where((r) => r.rating == i).length;
    }
  }

  // 新增：应用评价筛选和排序
  void _applyReviewFilters() {
    filteredReviews = List.from(reviews);
    
    // 应用星级筛选
    if (!reviewFilters['all']!) {
      List<int> selectedRatings = [];
      for (int i = 1; i <= 5; i++) {
        if (reviewFilters['${i}star']!) {
          selectedRatings.add(i);
        }
      }
      if (selectedRatings.isNotEmpty) {
        filteredReviews = filteredReviews.where((r) => selectedRatings.contains(r.rating)).toList();
      }
    }
    
    // 应用其他筛选
    if (reviewFilters['withPhotos']!) {
      filteredReviews = filteredReviews.where((r) => r.images?.isNotEmpty == true).toList();
    }
    
    if (reviewFilters['verified']!) {
      filteredReviews = filteredReviews.where((r) => r.isVerified).toList();
    }
    
    // 应用排序
    sortReviews(currentReviewSort);
  }

  // 新增：排序评价
  void sortReviews(String sortType) {
    currentReviewSort = sortType;
    
    switch (sortType) {
      case 'newest':
        filteredReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        filteredReviews.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'highest':
        filteredReviews.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'lowest':
        filteredReviews.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }
    update();
  }

  // 新增：更新评价筛选
  void updateReviewFilter(String filterKey, bool value) {
    if (filterKey == 'all') {
      // 如果选择"全部"，清除其他筛选
      reviewFilters.forEach((key, _) {
        reviewFilters[key] = key == 'all';
      });
    } else {
      // 如果选择其他筛选，取消"全部"
      reviewFilters['all'] = false;
      reviewFilters[filterKey] = value;
      
      // 如果没有选中任何星级筛选，自动选中"全部"
      bool hasStarFilter = false;
      for (int i = 1; i <= 5; i++) {
        if (reviewFilters['${i}star']!) {
          hasStarFilter = true;
          break;
        }
      }
      if (!hasStarFilter) {
        reviewFilters['all'] = true;
      }
    }
    
    _applyReviewFilters();
  }

  // 新增：重置评价筛选
  void resetReviewFilters() {
    reviewFilters.forEach((key, _) {
      reviewFilters[key] = key == 'all';
    });
    currentReviewSort = 'newest';
    _applyReviewFilters();
  }

  // 新增：地图功能增强方法 - 使用ServiceMapController的公共方法
  void toggleMapType() {
    _serviceMapController.toggleMapType();
  }

  // 新增：切换地图全屏模式
  void toggleMapFullScreen() {
    print('[ServiceDetailController] toggleMapFullScreen called');
    _serviceMapController.toggleMapFullScreen();
    print('[ServiceDetailController] Fullscreen mode: ${_serviceMapController.isMapFullScreen.value}');
  }

  // 新增：加载服务区域信息
  Future<void> loadServiceAreaInfo() async {
    await _serviceMapController.loadServiceAreaInfo();
    serviceAreaInfo = _serviceMapController.serviceAreaInfo.value;
    serviceRadiusKm = _serviceMapController.serviceRadiusKm.value;
  }

  // 新增：获取导航信息
  Map<String, dynamic> getNavigationInfo() {
    return _serviceMapController.getNavigationInfo();
  }

  // 新增：计算从客户地址到提供商地址的路线
  Future<void> calculateRouteToProvider() async {
    print('[ServiceDetailController] calculateRouteToProvider called');
    
    if (currentServiceLocation == null) {
      print('[ServiceDetailController] No service location available');
      return;
    }

    final userLocation = LocationController.instance.effectiveLocation;
    if (userLocation == null) {
      print('[ServiceDetailController] No user location available');
      return;
    }

    print('[ServiceDetailController] Calculating route from user location to service location');
    print('[ServiceDetailController] User location: ${userLocation.latitude}, ${userLocation.longitude}');
    print('[ServiceDetailController] Service location: ${currentServiceLocation!.latitude}, ${currentServiceLocation!.longitude}');

    await _serviceMapController.calculateRoute(
      start: LatLng(userLocation.latitude, userLocation.longitude),
      end: currentServiceLocation!,
      routeId: 'route_to_provider',
    );
    
    print('[ServiceDetailController] Route calculation completed');
  }

  // 新增：选择交通方式
  void selectTransportMode(String mode) {
    _serviceMapController.selectTransportMode(mode);
  }

  // 新增：获取当前路线信息
  Map<String, dynamic>? getCurrentRouteInfo() {
    return _serviceMapController.getCurrentRouteInfo();
  }

  // 新增：获取所有可用路线
  List<Map<String, dynamic>> getAllRoutes() {
    return _serviceMapController.getAllRoutes();
  }

  // 新增：导航到服务位置（增强版）
  void navigateToService() {
    if (currentServiceLocation == null) {
      Get.snackbar(
        'Error',
        'Service location not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final userLocation = LocationController.instance.effectiveLocation;
    if (userLocation == null) {
      Get.snackbar(
        'Error',
        'Please set your location first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 显示路线选择对话框
    showRouteSelectionDialog();
  }

  // 新增：显示路线选择对话框
  void showRouteSelectionDialog() {
    final availableRoutes = _serviceMapController.getAllRoutes();
    final currentRoute = _serviceMapController.getCurrentRouteInfo();
    final selectedTransportMode = _serviceMapController.selectedTransportMode.value;

    if (availableRoutes.isEmpty) {
      // 如果没有路线，先计算路线
      calculateRouteToProvider().then((_) {
        final routes = _serviceMapController.getAllRoutes();
        if (routes.isNotEmpty) {
          showRouteSelectionDialog();
        }
      });
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Choose Route'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 路线概览
              if (currentRoute != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${currentRoute['duration']} • ${currentRoute['distance']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentRoute['route'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // 交通方式选择
              ...availableRoutes.map((route) {
                final isSelected = route['mode'] == selectedTransportMode;
                return ListTile(
                  leading: Icon(
                    _serviceMapController.getTransportIcon(route['mode']),
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  title: Text(
                    '${route['duration']} • ${route['distance']}',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(route['route']),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () {
                    selectTransportMode(route['mode']);
                    Get.back();
                    _showNavigationOptions();
                  },
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // 新增：显示导航选项
  void _showNavigationOptions() {
    final currentRoute = _serviceMapController.getCurrentRouteInfo();
    if (currentRoute == null) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Navigation Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Open in Maps App'),
              subtitle: Text('${currentRoute['duration']} • ${currentRoute['distance']}'),
              onTap: () {
                Get.back();
                _openInMapsApp();
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Address'),
              subtitle: const Text('Copy provider address to clipboard'),
              onTap: () {
                Get.back();
                copyServiceAddress();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Route'),
              subtitle: const Text('Share route with others'),
              onTap: () {
                Get.back();
                _shareRoute();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // 新增：在地图应用中打开
  void _openInMapsApp() {
    if (currentServiceLocation == null) return;

    final selectedTransportMode = _serviceMapController.selectedTransportMode.value;
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${currentServiceLocation!.latitude},${currentServiceLocation!.longitude}&travelmode=$selectedTransportMode';
    
    // 这里应该使用url_launcher包来打开外部地图应用
    Get.snackbar(
      'Navigation',
      'Opening navigation app...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // 新增：分享路线
  void _shareRoute() {
    final currentRoute = _serviceMapController.getCurrentRouteInfo();
    if (currentRoute == null) return;

    final routeInfo = '''
Route to ${service?.title ?? 'Service Provider'}:
${currentRoute['duration']} • ${currentRoute['distance']}
${currentRoute['route']}
    ''';

    // 这里应该使用share包来分享路线信息
    Get.snackbar(
      'Share Route',
      'Route information copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // 新增：复制服务地址
  void copyServiceAddress() {
    if (serviceLocation == null) {
      Get.snackbar(
        'Error',
        'Service address not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    // 这里可以复制地址到剪贴板
    Get.snackbar(
      'Address Copied',
      'Service address copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _setMockData() {
    service = Service(
      id: 'service_123',
      title: 'Professional Home Cleaning Service',
      description: 'Comprehensive home cleaning service including kitchen, bathroom, living areas, and bedrooms. Our professional team uses eco-friendly products and follows strict hygiene protocols.',
      averageRating: 4.8,
      reviewCount: 127,
      providerId: 'provider_456',
      categoryLevel1Id: '1020000',
      categoryLevel2Id: '1020100',
      status: 'active',
      serviceDeliveryMethod: 'on_site',
      createdAt: DateTime.now(),
    );

    serviceDetail = ServiceDetail(
      serviceId: 'service_123',
      pricingType: 'hourly',
      price: 45.0,
      currency: 'USD',
      negotiationDetails: 'Price may vary based on home size and specific requirements',
      durationType: 'fixed',
      duration: Duration(hours: 3),
      images: [
        'assets/images/service_placeholder_1.jpg',
        'assets/images/service_placeholder_2.jpg',
        'assets/images/service_placeholder_3.jpg',
      ],
      tags: ['cleaning', 'professional', 'eco-friendly', 'residential'],
      serviceAreaCodes: ['10001', '10002', '10003'],
      serviceDetailsJson: {
        'equipment': ['vacuum', 'mop', 'cleaning supplies'],
        'materials': ['eco-friendly', 'non-toxic'],
        'included_services': ['dusting', 'vacuuming', 'mopping', 'bathroom cleaning'],
      },
    );

    provider = ProviderProfile(
      id: 'provider_456',
      companyName: 'CleanPro Services',
      contactPhone: '+1 (555) 123-4567',
      contactEmail: 'contact@cleanproservices.com',
      companyDescription: 'Leading professional cleaning service with over 10 years of experience in residential and commercial cleaning. We pride ourselves on using eco-friendly products and providing exceptional customer service.',
      ratingsAvg: 4.9,
      reviewCount: 342,
      businessLicense: 'LIC-2024-001234',
      insuranceInfo: 'Fully insured and bonded for your peace of mind',
      serviceCategories: ['cleaning', 'maintenance', 'sanitization'],
      profileImageUrl: 'https://picsum.photos/100/100?random=4',
      status: 'approved',
      createdAt: DateTime.now().subtract(Duration(days: 365)),
      updatedAt: DateTime.now(),
    );
  }

  // 新增：初始化地图功能
  void _initializeMapFeatures() {
    // 使用优化的地图初始化
    _serviceMapController.initializeMap();
    
    // 设置当前服务位置
    if (serviceLocation != null) {
      currentServiceLocation = LatLng(
        serviceLocation!['latitude'] ?? 43.6532,
        serviceLocation!['longitude'] ?? -79.3832,
      );
    } else {
      currentServiceLocation = const LatLng(43.6532, -79.3832); // 默认多伦多
    }
    
    // 更新ServiceMapController的中心点
    _serviceMapController.centerLat.value = currentServiceLocation!.latitude;
    _serviceMapController.centerLng.value = currentServiceLocation!.longitude;
    _serviceMapController.zoom.value = 15.0;
    
    // 设置服务半径
    if (serviceRadiusKm != null) {
      _serviceMapController.serviceRadiusKm.value = serviceRadiusKm!;
    }
  }

  // 新增：获取当前服务的marker
  ServiceMarkerModel? getCurrentServiceMarker() {
    return _serviceMapController.markers.firstWhereOrNull(
      (marker) => marker.id == service?.id,
    );
  }

  // 新增：收藏和分享方法
  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
    Get.snackbar(
      isFavorite.value ? 'Added to Favorites' : 'Removed from Favorites',
      '',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void shareService() {
    final serviceDetail = service;
    if (serviceDetail != null) {
      Get.snackbar(
        'Share',
        'Sharing service: ${serviceDetail.title}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 新增：联系系统方法
  void callProvider() {
    final serviceDetail = service;
    if (serviceDetail != null && provider?.contactPhone != null) {
      Get.snackbar(
        'Calling',
        'Calling ${provider!.contactPhone}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        'Phone number not available',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void emailProvider() {
    final serviceDetail = service;
    if (serviceDetail != null && provider?.contactEmail != null) {
      Get.snackbar(
        'Email',
        'Opening email client for ${provider!.contactEmail}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        'Email address not available',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void visitWebsite() {
    final serviceDetail = service;
    if (serviceDetail != null && provider?.website != null) {
      Get.snackbar(
        'Website',
        'Opening ${provider!.website}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        'Website not available',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void startChat() {
    final serviceDetail = service;
    if (serviceDetail != null) {
      Get.snackbar(
        'Chat',
        'Starting chat with ${provider?.companyName ?? 'Provider'}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 新增：报价系统方法
  void updateQuoteDetails(String key, dynamic value) {
    quoteDetails[key] = value;
  }

  Future<void> submitQuoteRequest() async {
    if (quoteDetails['requirements']?.toString().isEmpty ?? true) {
      Get.snackbar(
        'Error',
        'Please describe your service requirements',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoadingQuote.value = true;
    try {
      await Future.delayed(const Duration(seconds: 2));
      quoteRequestStatus.value = 'pending';
      Get.snackbar(
        'Success',
        'Quote request submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit quote request: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingQuote.value = false;
    }
  }

  void acceptQuote() {
    Get.snackbar(
      'Success',
      'Quote accepted successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void declineQuote() {
    Get.snackbar(
      'Info',
      'Quote declined',
      snackPosition: SnackPosition.BOTTOM,
    );
    receivedQuote.clear();
  }

  // 新增：预订系统方法
  void updateBookingDetails(String key, dynamic value) {
    bookingDetails[key] = value;
  }

  Future<void> submitBooking() async {
    if (bookingDetails['serviceDate']?.toString().isEmpty ?? true) {
      Get.snackbar(
        'Error',
        'Please select a service date',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (bookingDetails['serviceTime']?.toString().isEmpty ?? true) {
      Get.snackbar(
        'Error',
        'Please select a service time',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoadingBooking.value = true;
    try {
      await Future.delayed(const Duration(seconds: 2));
      Get.snackbar(
        'Success',
        'Booking submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit booking: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingBooking.value = false;
    }
  }

  // 新增：评价系统方法
  void sortReviews(String sortType) {
    currentReviewSort.value = sortType;
    
    switch (sortType) {
      case 'newest':
        filteredReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        filteredReviews.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'highest':
        filteredReviews.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'lowest':
        filteredReviews.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }
  }

  void updateReviewFilter(String filterKey, bool value) {
    if (filterKey == 'all') {
      reviewFilters.forEach((key, _) {
        reviewFilters[key] = key == 'all';
      });
    } else {
      reviewFilters['all'] = false;
      reviewFilters[filterKey] = value;
      
      bool hasStarFilter = false;
      for (int i = 1; i <= 5; i++) {
        if (reviewFilters['${i}star']!) {
          hasStarFilter = true;
          break;
        }
      }
      if (!hasStarFilter) {
        reviewFilters['all'] = true;
      }
    }
    
    _applyReviewFilters();
  }

  // 新增：应用评价筛选
  void _applyReviewFilters() {
    filteredReviews.value = List.from(reviews);
    
    // 应用星级筛选
    if (!reviewFilters['all']!) {
      List<int> selectedRatings = [];
      for (int i = 1; i <= 5; i++) {
        if (reviewFilters['${i}star']!) {
          selectedRatings.add(i);
        }
      }
      if (selectedRatings.isNotEmpty) {
        filteredReviews.value = filteredReviews.where((r) => selectedRatings.contains(r.rating)).toList();
      }
    }
    
    // 应用其他筛选
    if (reviewFilters['withPhotos']!) {
      filteredReviews.value = filteredReviews.where((r) => r.images?.isNotEmpty == true).toList();
    }
    
    if (reviewFilters['verified']!) {
      filteredReviews.value = filteredReviews.where((r) => r.isVerified).toList();
    }
    
    // 应用排序
    sortReviews(currentReviewSort.value);
  }
}

// 新增相似服务模型
class SimilarService {
  final String id;
  final String providerId;
  final String providerName;
  final String serviceTitle;
  final double price;
  final double rating;
  final int reviewCount;
  final double similarityScore;
  final String providerAvatar;
  final List<String> advantages;
  final List<String> disadvantages;

  SimilarService({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.serviceTitle,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.similarityScore,
    required this.providerAvatar,
    this.advantages = const [],
    this.disadvantages = const [],
  });
}
