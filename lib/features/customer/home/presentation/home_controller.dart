import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/services/unified_query_service.dart';
// import '../../../../core/services/provider_identity_service.dart';
import '../../../../core/plugin_management/plugin_manager.dart';
import '../../../../app/shell_app_controller.dart';
import '../../../service_booking/presentation/service_booking_controller.dart';

// Carousel Item Model
class CarouselItem {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final String? actionUrl;
  final String? actionType;

  CarouselItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    this.actionUrl,
    this.actionType,
  });
}

// Hotspot Item Model
class HotspotItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String type;
  final String? time;
  final String? actionUrl;
  final String? actionType;

  HotspotItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.type,
    this.time,
    this.actionUrl,
    this.actionType,
  });
}

// Service Recommendation Model
class ServiceRecommendation {
  final String id;
  final dynamic serviceName;
  final dynamic serviceDescription;
  final String serviceIcon;
  final String recommendationReason;

  // 基础属性
  final dynamic name;
  final String? imageUrl;
  final String? providerName;
  final double? rating;
  final String? price;
  final String? distance;
  final bool? isPopular;
  final bool? isNearby;

  // 新增属性
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
  })  : name = name ?? serviceName,
        imageUrl = imageUrl?.isNotEmpty == true &&
                Uri.tryParse(imageUrl!)?.hasScheme == true
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

  HomeServiceItem(
      {required this.id,
      required this.typeCode,
      required this.name,
      required this.icon});
}

class HomeController extends GetxController {
  final _storage = GetStorage();

  // 添加搜索控制器
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // 新增：集成统一查询服务
  final UnifiedQueryService _unifiedQueryService = UnifiedQueryService();

  // New states for Carousel
  late PageController pageController;
  final RxInt currentCarouselIndex = 0.obs;
  final RxList<CarouselItem> carouselItems = <CarouselItem>[].obs;
  final RxBool isLoadingCarousels = false.obs;

  // New list for Community Hotspots
  final RxList<HotspotItem> hotspots = <HotspotItem>[].obs;
  final RxBool isLoadingHotspots = false.obs;

  // Services Grid
  final RxList<HomeServiceItem> services = <HomeServiceItem>[].obs;
  final RxBool isLoadingServices = false.obs;

  // Recommendations
  final RxList<ServiceRecommendation> recommendations =
      <ServiceRecommendation>[].obs;
  final RxBool isLoadingRecommendations = false.obs;

  late final PluginManager _pluginManager; // Add PluginManager instance

  @override
  void onInit() {
    super.onInit();
    _pluginManager = Get.find<PluginManager>(); // Initialize PluginManager
    // 减少日志输出 - AppLogger.info('=== HomeController onInit ===');
    pageController = PageController();

    // 初始化统一查询服务
    _initializeUnifiedService();

    fetchHomeServices();
    _fetchRecommendedServices();
    _fetchCarousels();
    _fetchHotspots();

    // 立即检查并打印 provider 角色状态
    // ProviderIdentityService.getProviderStatus().then((status) {
    //   // 减少日志输出 - AppLogger.info('[HomeController] 进入首页 provider 角色状态: $status');
    // }).catchError((e) {
    //   // 减少日志输出 - AppLogger.info('[HomeController] 获取 provider 角色状态时出错: $e');
    // });
  }

  // 新增：初始化统一查询服务
  Future<void> _initializeUnifiedService() async {
    try {
      await _unifiedQueryService.initialize();
      // 减少日志输出 - AppLogger.info('统一查询服务初始化成功');
    } catch (e) {
      // 减少日志输出 - AppLogger.info('统一查询服务初始化失败: $e');
    }
  }

  Future<void> fetchHomeServices() async {
    // 减少日志输出 - AppLogger.info('=== Fetching Home Services ===');
    isLoadingServices.value = true;
    try {
      // 减少日志输出 - AppLogger.info('开始查询ref_codes表...');

      // 首先测试数据库连接
      final testQuery = await Supabase.instance.client
          .from('ref_codes')
          .select('count')
          .limit(1);
      // 减少日志输出 - AppLogger.info('数据库连接测试成功，返回数据: $testQuery');

      // 查询一级服务分类
      final data = await Supabase.instance.client
          .from('ref_codes')
          .select('id, type_code, name, extra_data, level, status, sort_order')
          .eq('type_code', 'SERVICE_TYPE')
          .eq('level', 1)
          .eq('status', 1)
          .order('sort_order', ascending: true);

      // 减少日志输出 - AppLogger.info('查询完成，原始数据: $data');
      // 减少日志输出 - AppLogger.info('数据长度: ${data.length}');

      final List<HomeServiceItem> fetchedServices = [];

      for (var item in data as List) {
        // 减少日志输出 - AppLogger.info('处理项目: $item');
        final nameData = Map<String, dynamic>.from(item['name']);
        final extraData = Map<String, dynamic>.from(item['extra_data'] ?? {});
        final id = item['id'] as int;

        // 减少日志输出 - AppLogger.info('处理服务: ID=$id, name=$nameData, extraData=$extraData');

        final serviceName = nameData[Get.locale?.languageCode ?? 'zh'] ??
            nameData['zh'] ??
            nameData['en'] ??
            '';
        // 减少日志输出 - AppLogger.info('解析后的服务名称: $serviceName');

        fetchedServices.add(HomeServiceItem(
          id: id,
          typeCode: 'SERVICE_TYPE',
          name: serviceName,
          icon: _getIconData(extraData['icon'] ?? 'category'),
        ));
      }

      // Add function entries after service categories
      fetchedServices.addAll([
        HomeServiceItem(
            id: -1, typeCode: 'FUNCTION', name: '求助', icon: Icons.help_outline),
        HomeServiceItem(
            id: -2,
            typeCode: 'FUNCTION',
            name: '服务地图',
            icon: Icons.location_on),
      ]);

      // 减少日志输出 - AppLogger.info('最终服务列表: ${fetchedServices.map((s) => '${s.id}: ${s.name}').join(', ')}');
      services.assignAll(fetchedServices);
    } catch (e) {
      // 减少日志输出 - AppLogger.info('Error fetching home services: $e');
      // 减少日志输出 - AppLogger.info('错误详情: ${e.toString()}');
      Get.snackbar(
        '加载失败',
        '未能加载服务分类，请稍后再试。错误: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingServices.value = false;
      // 减少日志输出 - AppLogger.info('Home services fetch finished. isLoadingServices: ${isLoadingServices.value}'); // Added print
    }
  }

  String getServiceMapRoute() {
    final serviceMapPluginMetadata =
        _pluginManager.enabledPluginsMetadata.firstWhereOrNull(
      (meta) => meta.id == 'service_map',
    );
    return serviceMapPluginMetadata?.routeName ?? '/service_map';
  }

  IconData _getIconData(String iconName) {
    // 减少日志输出 - AppLogger.info('Getting icon for: $iconName');
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'home':
        return Icons.home;
      case 'directions_car':
        return Icons.directions_car;
      case 'share':
        return Icons.share;
      case 'school':
        return Icons.school;
      case 'work':
        return Icons.work;
      case 'help_outline':
        return Icons.help_outline;
      case 'location_on':
        return Icons.location_on;
      case 'apps':
        return Icons.apps;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'grass':
        return Icons.grass;
      case 'ramen_dining':
        return Icons.ramen_dining;
      case 'miscellaneous_services':
        return Icons.miscellaneous_services;
      case 'newspaper':
        return Icons.newspaper;
      case 'card_giftcard':
        return Icons.card_giftcard;
      default:
        // 减少日志输出 - AppLogger.info('Using default icon for: $iconName');
        return Icons.category;
    }
  }

  void onCarouselPageChanged(int index) {
    currentCarouselIndex.value = index;
  }

  // 新增：Banner点击处理（保持向后兼容）
  void onBannerTap(int index) {
    onCarouselTap(index);
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

  // 搜索相关方法
  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  // New method to fetch recommended services
  Future<void> _fetchRecommendedServices() async {
    // 减少日志输出 - AppLogger.info('=== Fetching Recommended Services ===');
    isLoadingRecommendations.value = true;

    try {
      // 首先尝试使用统一查询服务
      if (_unifiedQueryService.isInitialized) {
        // 减少日志输出 - AppLogger.info('使用统一查询服务获取推荐服务');
        final services =
            await _unifiedQueryService.getRecommendedServices(limit: 6);

        final List<ServiceRecommendation> processedServices = [];
        for (var service in services) {
          processedServices.add(ServiceRecommendation(
            id: service.id,
            serviceName: service.title,
            serviceDescription: service.description,
            serviceIcon: 'restaurant', // 默认图标
            recommendationReason: '为您推荐',
            name: service.title,
            imageUrl: service.imagesUrl?.isNotEmpty == true
                ? service.imagesUrl![0]
                : null,
            providerName: 'Service Provider', // 需要从provider_profiles获取
            rating: service.rating,
            price: '50', // 需要从service_details获取
            distance: '2.5 km',
            isPopular: service.reviewCount > 100,
            isNearby: true,
            subCategory: null, // 需要从service_details获取
            isAvailable: true,
            attributes: null, // 需要从service_details获取
            businessRules: null, // 需要从service_details获取
            currentStock: null, // 需要从service_details获取
            maxStock: null, // 需要从service_details获取
            pricingType: service.pricingType,
            currency: service.currency,
          ));
        }

        recommendations.assignAll(processedServices);
        // 减少日志输出 - AppLogger.info('使用统一查询服务获取推荐服务成功，数量: ${processedServices.length}');
        return;
      }

      // 回退到旧的查询方式，优先查询固定ID的测试服务
      // 减少日志输出 - AppLogger.info('回退到旧的查询方式，优先查询固定ID测试服务');
      final data = await Supabase.instance.client
          .from('services')
          .select('*, ref_codes!services_category_level1_id_fkey(extra_data)')
          .inFilter('id', [
        '550e8400-e29b-41d4-a716-446655440101',
        '550e8400-e29b-41d4-a716-446655440102',
        '550e8400-e29b-41d4-a716-446655440103'
      ]).limit(8);

      // 减少日志输出 - AppLogger.info('services数据: $data');

      final List<ServiceRecommendation> fallbackServices = [];
      final Set<int> categoryIdsToFetch = {};
      for (var service in data as List) {
        categoryIdsToFetch.add(service['category_level1_id'] as int);
      }
      // 减少日志输出 - AppLogger.info('需要查询的分类ID: $categoryIdsToFetch');

      final refCodesData = await Supabase.instance.client
          .from('ref_codes')
          .select('id, extra_data')
          .filter('id', 'in', categoryIdsToFetch.toList());

      // 减少日志输出 - AppLogger.info('ref_codes查询完成，数据: $refCodesData');
      final Map<int, Map<String, dynamic>> refCodesMap = {};
      for (var refCode in refCodesData as List) {
        refCodesMap[refCode['id']] = refCode['extra_data'];
      }
      // 减少日志输出 - AppLogger.info('ref_codes映射: $refCodesMap');

      for (var service in data) {
        // 减少日志输出 - AppLogger.info('处理服务: $service');
        final serviceTitle = service['title'];
        final safeServiceTitle = serviceTitle is Map<String, dynamic>
            ? serviceTitle
            : {'zh': serviceTitle ?? ''};
        final serviceDescription = service['description'];
        final safeServiceDescription =
            serviceDescription is Map<String, dynamic>
                ? serviceDescription
                : {'zh': serviceDescription ?? ''};
        final categoryLevel1Id = service['category_level1_id'] as int;
        final iconData = refCodesMap[categoryLevel1Id]?['icon'] ?? 'category';

        // 减少日志输出 - AppLogger.info('服务标题: $serviceTitle');
        // 减少日志输出 - AppLogger.info('服务描述: $serviceDescription');
        // 减少日志输出 - AppLogger.info('分类ID: $categoryLevel1Id');
        // 减少日志输出 - AppLogger.info('图标名称: $iconData');
        // 减少日志输出 - AppLogger.info('DEBUG: service id: ${service['id']}, type: ${service['id'].runtimeType}');

        fallbackServices.add(ServiceRecommendation(
          id: service['id'].toString(),
          serviceName: safeServiceTitle,
          serviceDescription: safeServiceDescription,
          serviceIcon: iconData,
          recommendationReason: '为您推荐',
        ));
        // 减少日志输出 - AppLogger.info('添加推荐服务成功');
      }
      // 减少日志输出 - AppLogger.info('最终推荐服务数量: ${fallbackServices.length}');
      recommendations.assignAll(fallbackServices);
      // 减少日志输出 - AppLogger.info('Recommendations assigned to RxList.');
    } catch (e) {
      // 减少日志输出 - AppLogger.info('Error fetching recommended services: $e');
      Get.snackbar(
        '加载失败',
        '未能加载推荐服务，请稍后再试。错误: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingRecommendations.value = false;
    }
  }

  // New method to fetch carousels
  Future<void> _fetchCarousels() async {
    // 减少日志输出 - AppLogger.info('=== Fetching Carousels ===');
    isLoadingCarousels.value = true;

    try {
      // 模拟数据，实际应该从API获取
      final List<CarouselItem> mockCarousels = [
        CarouselItem(
          id: '1',
          title: '欢迎使用JinBean',
          subtitle: '发现更多优质服务',
          description: '探索我们平台上的各种优质服务，从美食到专业服务，应有尽有',
          imageUrl: 'https://picsum.photos/id/1/800/400',
          actionUrl: '/services',
          actionType: 'navigation',
        ),
        CarouselItem(
          id: '2',
          title: '美食天地',
          subtitle: '品尝正宗川菜',
          description: '体验正宗的川菜美食，从宫保鸡丁到麻婆豆腐，满足您的味蕾',
          imageUrl: 'https://picsum.photos/id/2/800/400',
          actionUrl: '/services?category=food',
          actionType: 'navigation',
        ),
        CarouselItem(
          id: '3',
          title: '专业服务',
          subtitle: '找到最合适的服务商',
          description: '连接专业的服务提供商，享受高质量的服务体验',
          imageUrl: 'https://picsum.photos/id/3/800/400',
          actionUrl: '/services?category=professional',
          actionType: 'navigation',
        ),
      ];

      carouselItems.assignAll(mockCarousels);
      // 减少日志输出 - AppLogger.info('Carousels loaded: ${mockCarousels.length} items');
    } catch (e) {
      // 减少日志输出 - AppLogger.info('Error fetching carousels: $e');
    } finally {
      isLoadingCarousels.value = false;
    }
  }

  // New method to fetch hotspots
  Future<void> _fetchHotspots() async {
    // 减少日志输出 - AppLogger.info('=== Fetching Hotspots ===');
    isLoadingHotspots.value = true;

    try {
      // 模拟数据，实际应该从API获取
      final List<HotspotItem> mockHotspots = [
        HotspotItem(
          id: '1',
          title: '社区活动',
          subtitle: '本周社区美食节',
          imageUrl: 'https://picsum.photos/id/10/300/200',
          type: 'event',
          time: '2小时前',
          actionUrl: '/events/1',
          actionType: 'navigation',
        ),
        HotspotItem(
          id: '2',
          title: '新服务上线',
          subtitle: '专业清洁服务',
          imageUrl: 'https://picsum.photos/id/11/300/200',
          type: 'service',
          time: '1天前',
          actionUrl: '/services/cleaning',
          actionType: 'navigation',
        ),
        HotspotItem(
          id: '3',
          title: '用户评价',
          subtitle: '看看大家的反馈',
          imageUrl: 'https://picsum.photos/id/12/300/200',
          type: 'review',
          time: '3小时前',
          actionUrl: '/reviews',
          actionType: 'navigation',
        ),
      ];

      hotspots.assignAll(mockHotspots);
      // 减少日志输出 - AppLogger.info('Hotspots loaded: ${mockHotspots.length} items');
    } catch (e) {
      // 减少日志输出 - AppLogger.info('Error fetching hotspots: $e');
    } finally {
      isLoadingHotspots.value = false;
    }
  }

  // New method to handle carousel tap
  void onCarouselTap(int index) {
    if (index < carouselItems.length) {
      final carousel = carouselItems[index];
      // 减少日志输出 - AppLogger.info('Carousel tapped: ${carousel.title}');

      if (carousel.actionUrl != null) {
        switch (carousel.actionType) {
          case 'navigation':
            Get.toNamed(carousel.actionUrl!);
            break;
          case 'url':
            // 处理外部链接
            break;
          default:
            Get.snackbar(
              'Carousel',
              carousel.title,
              snackPosition: SnackPosition.BOTTOM,
            );
        }
      }
    }
  }

  // New method to handle hotspot tap
  void onHotspotTap(int index) {
    if (index < hotspots.length) {
      final hotspot = hotspots[index];
      // 减少日志输出 - AppLogger.info('Hotspot tapped: ${hotspot.title}');

      if (hotspot.actionUrl != null) {
        switch (hotspot.actionType) {
          case 'navigation':
            Get.toNamed(hotspot.actionUrl!);
            break;
          case 'url':
            // 处理外部链接
            break;
          default:
            Get.snackbar(
              'Community News',
              hotspot.title,
              snackPosition: SnackPosition.BOTTOM,
            );
        }
      }
    }
  }
}
