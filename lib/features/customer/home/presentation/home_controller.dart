import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:jinbeanpod_83904710/core/plugin_management/plugin_manager.dart'; // Import PluginManager
import 'package:jinbeanpod_83904710/features/provider/plugins/provider_identity/provider_identity_service.dart';
import 'package:jinbeanpod_83904710/core/services/services.dart' as core_services;
// import 'package:jinbeanpod_83904710/features/auth/presentation/auth_controller.dart'; // No longer needed if logout is removed

// New model for Carousel items (Ads/Hot Events)
class CarouselItem {
  final String title;
  final String description;
  final String imageUrl;
  final String? actionType; // 'service', 'category', 'url'
  final String? serviceId;
  final String? categoryId;
  final String? url;

  CarouselItem({
    required this.title, 
    required this.description, 
    required this.imageUrl,
    this.actionType,
    this.serviceId,
    this.categoryId,
    this.url,
  });
}

// New model for Community Hotspot items
class HotspotItem {
  final String type; // e.g., 'NEWS', 'JOB', 'BENEFIT'
  final String title;
  final String? time;
  final String? publisher;

  HotspotItem({required this.type, required this.title, this.time, this.publisher});
}

// New model for Service Recommendation items
class ServiceRecommendation {
  final String id;
  final dynamic serviceName;
  final dynamic serviceDescription;
  final String serviceIcon;
  final String recommendationReason;
  
  // 基础属性
  final dynamic name;
  final String imageUrl;
  final String providerName;
  final double rating;
  final String price;
  final double? distance;
  final bool isPopular;
  final bool isNearby;
  
  // 新增：service_details 相关字段
  final String? subCategory;
  final bool isAvailable;
  final Map<String, dynamic>? attributes;
  final Map<String, dynamic>? businessRules;
  final int? currentStock;
  final int? maxStock;
  final String? pricingType;
  final String? currency;

  ServiceRecommendation({
    required this.id,
    required this.serviceName,
    required this.serviceDescription,
    required this.serviceIcon,
    required this.recommendationReason,
    // 基础属性初始化
    dynamic name,
    String? imageUrl,
    String? providerName,
    double? rating,
    String? price,
    this.distance,
    bool? isPopular,
    bool? isNearby,
    // 新增属性初始化
    this.subCategory,
    this.isAvailable = true,
    this.attributes,
    this.businessRules,
    this.currentStock,
    this.maxStock,
    this.pricingType,
    this.currency,
  }) : name = name ?? serviceName,
       imageUrl = imageUrl?.isNotEmpty == true && Uri.tryParse(imageUrl!)?.hasScheme == true
          ? imageUrl
          : 'https://picsum.photos/seed/service$id/200/120',
       providerName = providerName ?? 'Service Provider',
       rating = rating ?? 4.5,
       price = price ?? '50',
       isPopular = isPopular ?? false,
       isNearby = isNearby ?? false;
}

// Existing model for Home Service Items (updated to include id and typeCode for grid)
class HomeServiceItem {
  final int id; // Added for unique identification and navigation
  final String typeCode; // e.g., 'SERVICE_TYPE', 'FUNCTION'
  final String name;
  final IconData icon;

  HomeServiceItem({required this.id, required this.typeCode, required this.name, required this.icon});
}

class HomeController extends GetxController {
  final _storage = GetStorage();
  
  // 添加搜索控制器
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  
  // 新增：集成新的服务查询服务
  core_services.IServiceQueryService? _serviceQueryService;
  core_services.IServiceDetailService? _serviceDetailService;

  // New states for Carousel
  late PageController pageController;
  final RxInt currentCarouselIndex = 0.obs;
  final RxList<CarouselItem> carouselItems = <CarouselItem>[
    CarouselItem(
      title: 'Summer Service Discount!',
      description: 'Get 20% off all cleaning services this July.',
      imageUrl: 'https://picsum.photos/id/237/800/450',
    ),
    CarouselItem(
      title: 'New Electrician Onboard',
      description: 'Certified electricians now available 24/7.',
      imageUrl: 'https://picsum.photos/id/1015/800/450',
    ),
    CarouselItem(
      title: 'Refer a Friend, Get \$10!',
      description: 'Invite friends to JinBean and earn rewards.',
      imageUrl: 'https://picsum.photos/id/1016/800/450',
    ),
  ].obs;

  // New list for Community Hotspots
  final RxList<HotspotItem> hotspots = <HotspotItem>[
    HotspotItem(type: 'NEWS', title: 'XXX社区：本周末举行亲子活动', time: '2小时前'),
    HotspotItem(type: 'JOB', title: '急聘！社区保安，待遇从优', time: '昨天'),
    HotspotItem(type: 'BENEFIT', title: '长者免费体检活动即将开始', time: '3天前'),
    HotspotItem(type: 'NEWS', title: '社区图书馆扩建通知', time: '1周前'),
  ].obs;

  // Services Grid
  final RxList<HomeServiceItem> services = <HomeServiceItem>[].obs;
  final RxBool isLoadingServices = false.obs;

  // Recommendations
  final RxList<ServiceRecommendation> recommendations = <ServiceRecommendation>[].obs;
  final RxBool isLoadingRecommendations = false.obs;

  late final PluginManager _pluginManager; // Add PluginManager instance

  @override
  void onInit() {
    super.onInit();
    _pluginManager = Get.find<PluginManager>(); // Initialize PluginManager
    AppLogger.info('=== HomeController onInit ===');
    pageController = PageController();
    
    // 初始化新的服务查询服务
    _initializeNewServices();
    
    fetchHomeServices();
    _fetchRecommendedServices();
    
    // 立即检查并打印 provider 角色状态
    ProviderIdentityService.getProviderStatus().then((status) {
      AppLogger.info('[HomeController] 进入首页 provider 角色状态: $status');
    }).catchError((e) {
      AppLogger.info('[HomeController] 获取 provider 角色状态时出错: $e');
    });
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
      
      AppLogger.info('新服务查询服务初始化成功');
    } catch (e) {
      AppLogger.info('新服务查询服务初始化失败: $e');
    }
  }

  Future<void> fetchHomeServices() async {
    AppLogger.info('=== Fetching Home Services ===');
    isLoadingServices.value = true;
    try {
      AppLogger.info('开始查询ref_codes表...');
      
      // 首先测试数据库连接
      final testQuery = await Supabase.instance.client
          .from('ref_codes')
          .select('count')
          .limit(1);
      AppLogger.info('数据库连接测试成功，返回数据: $testQuery');
      
      // 查询一级服务分类
      final data = await Supabase.instance.client
          .from('ref_codes')
          .select('id, type_code, name, extra_data, level, status, sort_order')
          .eq('type_code', 'SERVICE_TYPE')
          .eq('level', 1)
          .eq('status', 1)
          .order('sort_order', ascending: true);

      AppLogger.info('查询完成，原始数据: $data');
      AppLogger.info('数据长度: ${data.length}');
      
      final List<HomeServiceItem> fetchedServices = [];
      
      for (var item in data as List) {
        AppLogger.info('处理项目: $item');
        final nameData = Map<String, dynamic>.from(item['name']);
        final extraData = Map<String, dynamic>.from(item['extra_data'] ?? {});
        final id = item['id'] as int;
        
        AppLogger.info('处理服务: ID=$id, name=$nameData, extraData=$extraData');
        
        final serviceName = nameData[Get.locale?.languageCode ?? 'zh'] ?? nameData['zh'] ?? nameData['en'] ?? '';
        AppLogger.info('解析后的服务名称: $serviceName');
        
        fetchedServices.add(HomeServiceItem(
          id: id,
          typeCode: 'SERVICE_TYPE',
          name: serviceName,
          icon: _getIconData(extraData['icon'] ?? 'category'),
        ));
      }

      // Add function entries after service categories
      fetchedServices.addAll([
        HomeServiceItem(id: -1, typeCode: 'FUNCTION', name: '求助', icon: Icons.help_outline),
        HomeServiceItem(id: -2, typeCode: 'FUNCTION', name: '服务地图', icon: Icons.location_on),
      ]);

      AppLogger.info('最终服务列表: ${fetchedServices.map((s) => '${s.id}: ${s.name}').join(', ')}');
      services.assignAll(fetchedServices);
    } catch (e) {
      AppLogger.info('Error fetching home services: $e');
      AppLogger.info('错误详情: ${e.toString()}');
      Get.snackbar(
        '加载失败',
        '未能加载服务分类，请稍后再试。错误: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingServices.value = false;
      AppLogger.info('Home services fetch finished. isLoadingServices: ${isLoadingServices.value}'); // Added print
    }
  }

  String getServiceMapRoute() {
    final serviceMapPluginMetadata = _pluginManager.enabledPluginsMetadata.firstWhereOrNull(
      (meta) => meta.id == 'service_map',
    );
    return serviceMapPluginMetadata?.routeName ?? '/service_map';
  }

  IconData _getIconData(String iconName) {
    AppLogger.info('Getting icon for: $iconName');
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'home': return Icons.home;
      case 'directions_car': return Icons.directions_car;
      case 'share': return Icons.share;
      case 'school': return Icons.school;
      case 'work': return Icons.work;
      case 'help_outline': return Icons.help_outline;
      case 'location_on': return Icons.location_on;
      case 'apps': return Icons.apps;
      case 'cleaning_services': return Icons.cleaning_services;
      case 'grass': return Icons.grass;
      case 'ramen_dining': return Icons.ramen_dining;
      case 'miscellaneous_services': return Icons.miscellaneous_services;
      case 'newspaper': return Icons.newspaper;
      case 'card_giftcard': return Icons.card_giftcard;
      default: 
        AppLogger.info('Using default icon for: $iconName');
        return Icons.category;
    }
  }

  void onCarouselPageChanged(int index) {
    currentCarouselIndex.value = index;
  }

  // 新增：Banner点击处理
  void onBannerTap(int index) {
    final banner = carouselItems[index];
    if (banner.actionType == 'service') {
      // 跳转到服务详情页
      Get.toNamed('/service_detail', parameters: {
        'serviceId': banner.serviceId ?? '',
        'serviceName': banner.title,
      });
    } else if (banner.actionType == 'category') {
      // 跳转到服务预订页并高亮对应分类
      Get.toNamed('/service_booking', arguments: {
        'level1CategoryId': banner.categoryId,
        'highlightCategory': true,
      });
    } else if (banner.actionType == 'url') {
      // 打开外部链接
      if (banner.url != null) {
        // TODO: 使用url_launcher打开外部链接
        Get.snackbar(
          'External Link',
          'Opening: ${banner.url}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    searchController.dispose();
    super.onClose();
  }

  String getLocalizedText(Map<String, dynamic> jsonbText) {
    final String? currentLangCode = Get.locale?.languageCode;
    if (currentLangCode != null && jsonbText.containsKey(currentLangCode)) {
      return jsonbText[currentLangCode]!;
    } else if (jsonbText.containsKey('en')) {
      return jsonbText['en']!;
    } else if (jsonbText.containsKey('zh')) {
      return jsonbText['zh']!;
    }
    return '';
  }

  // 新增：兼容 Map 和 String 的多语言安全取值方法
  String getSafeLocalizedText(dynamic value) {
    if (value is Map<String, dynamic>) {
      final lang = Get.locale?.languageCode ?? 'zh';
      return value[lang] ?? value['zh'] ?? value['en'] ?? '';
    } else if (value is String) {
      return value;
    }
    return '';
  }

  // New method to fetch recommended services
  Future<void> _fetchRecommendedServices() async {
    AppLogger.info('=== Fetching Recommended Services ===');
    isLoadingRecommendations.value = true;
    
    try {
      // 优先使用新的服务查询服务
      if (_serviceQueryService != null) {
        AppLogger.info('使用新的服务查询服务获取推荐服务');
        final result = await _serviceQueryService!.getRecommendedServices(limit: 8);
        
        final List<ServiceRecommendation> processedServices = [];
        for (var service in result) {
          processedServices.add(ServiceRecommendation(
            id: service.id,
            serviceName: service.title,
            serviceDescription: service.description,
            serviceIcon: 'category', // 默认图标
            recommendationReason: '为您推荐',
            // 新增字段
            name: service.title,
            imageUrl: service.mainImage,
            providerName: 'Service Provider', // 需要从provider_profiles获取
            rating: service.rating ?? 4.5,
            price: service.priceDisplay,
            distance: null, // 需要计算
            isPopular: service.reviewCount != null && service.reviewCount! > 10,
            isNearby: false, // 需要根据位置计算
            subCategory: null, // 需要从service_details获取
            isAvailable: service.isActive ?? true,
            attributes: null, // 需要从service_details获取
            businessRules: null, // 需要从service_details获取
            currentStock: null, // 需要从service_details获取
            maxStock: null, // 需要从service_details获取
            pricingType: service.pricingType,
            currency: service.currency,
          ));
        }
        
        recommendations.assignAll(processedServices);
        AppLogger.info('使用新服务获取推荐服务成功，数量: ${processedServices.length}');
        return;
      }
      
      // 回退到旧的查询方式
      AppLogger.info('回退到旧的查询方式');
      final data = await Supabase.instance.client
          .from('services')
          .select('*, ref_codes!services_category_level1_id_fkey(extra_data)')
          .limit(8);

      AppLogger.info('services数据: $data');

      final List<ServiceRecommendation> processedServices = [];
      final Set<int> categoryIdsToFetch = {};
      for (var service in data as List) {
        categoryIdsToFetch.add(service['category_level1_id'] as int);
      }
      AppLogger.info('需要查询的分类ID: $categoryIdsToFetch');

      final refCodesData = await Supabase.instance.client
          .from('ref_codes')
          .select('id, extra_data')
          .filter('id', 'in', categoryIdsToFetch.toList());

      AppLogger.info('ref_codes查询完成，数据: $refCodesData');
      final Map<int, Map<String, dynamic>> refCodesMap = {};
      for (var refCode in refCodesData as List) {
        refCodesMap[refCode['id']] = refCode['extra_data'];
      }
      AppLogger.info('ref_codes映射: $refCodesMap');

      for (var service in data) {
        AppLogger.info('处理服务: $service');
        final serviceTitle = service['title'];
        final safeServiceTitle = serviceTitle is Map<String, dynamic> ? serviceTitle : {'zh': serviceTitle ?? ''};
        final serviceDescription = service['description'];
        final safeServiceDescription = serviceDescription is Map<String, dynamic> ? serviceDescription : {'zh': serviceDescription ?? ''};
        final categoryLevel1Id = service['category_level1_id'] as int;
        final iconData = refCodesMap[categoryLevel1Id]?['icon'] ?? 'category';

        AppLogger.info('服务标题: $serviceTitle');
        AppLogger.info('服务描述: $serviceDescription');
        AppLogger.info('分类ID: $categoryLevel1Id');
        AppLogger.info('图标名称: $iconData');
        AppLogger.info('DEBUG: service id: ${service['id']}, type: ${service['id'].runtimeType}');

        processedServices.add(ServiceRecommendation(
          id: service['id'].toString(),
          serviceName: safeServiceTitle,
          serviceDescription: safeServiceDescription,
          serviceIcon: iconData,
          recommendationReason: '为您推荐',
        ));
        AppLogger.info('添加推荐服务成功');
      }
      AppLogger.info('最终推荐服务数量: ${processedServices.length}');
      recommendations.assignAll(processedServices);
      AppLogger.info('Recommendations assigned to RxList.');
    } catch (e) {
      AppLogger.info('Error fetching recommended services: $e');
      Get.snackbar(
        '加载失败',
        '未能加载推荐服务，请稍后再试。错误: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingRecommendations.value = false;
      AppLogger.info('Recommended services fetch finished. isLoadingRecommendations: ${isLoadingRecommendations.value}');
    }
  }

  // 新增：搜索功能
  void onSearchSubmitted(String query) {
    if (query.trim().isEmpty) {
      Get.snackbar(
        'Search',
        'Please enter a search term',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    // 跳转到Service Booking页并传递搜索关键词
    Get.toNamed('/service_booking', arguments: {
      'searchQuery': query.trim(),
    });
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }
} 