import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
// import 'package:jinbeanpod_83904710/features/auth/presentation/auth_controller.dart'; // No longer needed if logout is removed

// New model for Carousel items (Ads/Hot Events)
class CarouselItem {
  final String title;
  final String description;
  final String imageUrl;

  CarouselItem({required this.title, required this.description, required this.imageUrl});
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
  final String serviceId; // Changed to String for UUID
  final Map<String, dynamic> serviceName;
  final Map<String, dynamic> serviceDescription;
  final String serviceIcon; // 对应ref_codes的extra_data['icon']
  final String recommendationReason; // 推荐理由，如"根据您的地理位置"

  ServiceRecommendation({
    required this.serviceId,
    required this.serviceName,
    required this.serviceDescription,
    required this.serviceIcon,
    required this.recommendationReason,
  });
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

  @override
  void onInit() {
    super.onInit();
    print('=== HomeController onInit ===');
    pageController = PageController();
    fetchHomeServices();
    _fetchRecommendedServices();
  }

  Future<void> fetchHomeServices() async {
    print('=== Fetching Home Services ===');
    isLoadingServices.value = true;
    try {
      final data = await Supabase.instance.client
          .from('ref_codes')
          .select('id, name, extra_data')
          .eq('type_code', 'SERVICE_TYPE')
          .eq('level', 1)
          .eq('status', 1)
          .order('sort_order', ascending: true);

      print('Fetched services data: ${data.length} items');
      
      final List<HomeServiceItem> fetchedServices = [];
      
      for (var item in data as List) {
        final nameData = Map<String, dynamic>.from(item['name']);
        final extraData = Map<String, dynamic>.from(item['extra_data'] ?? {});
        final id = item['id'] as int;
        
        print('Processing service: ID=$id, name=$nameData, extraData=$extraData');
        
        fetchedServices.add(HomeServiceItem(
          id: id,
          typeCode: 'SERVICE_TYPE',
          name: nameData[Get.locale?.languageCode ?? 'zh'] ?? nameData['zh'] ?? nameData['en'] ?? '',
          icon: _getIconData(extraData['icon'] ?? 'category'),
        ));
      }

      // Add function entries after service categories
      fetchedServices.addAll([
        HomeServiceItem(id: -1, typeCode: 'FUNCTION', name: '求助', icon: Icons.help_outline),
        HomeServiceItem(id: -2, typeCode: 'FUNCTION', name: '服务地图', icon: Icons.location_on),
      ]);

      print('Final services list: ${fetchedServices.map((s) => '${s.id}: ${s.name}').join(', ')}');
      services.assignAll(fetchedServices);
    } catch (e) {
      print('Error fetching home services: $e');
      Get.snackbar(
        '加载失败',
        '未能加载服务分类，请稍后再试。',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingServices.value = false;
    }
  }

  IconData _getIconData(String iconName) {
    print('Getting icon for: $iconName');
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
        print('Using default icon for: $iconName');
        return Icons.category;
    }
  }

  void onCarouselPageChanged(int index) {
    currentCarouselIndex.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
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

  Future<void> _fetchRecommendedServices() async {
    isLoadingRecommendations.value = true;
    try {
      // Step 1: Fetch services data without joining ref_codes
      final List<Map<String, dynamic>> servicesData = await Supabase.instance.client
          .from('services')
          .select('id, title, description, average_rating, review_count, created_at, category_level1_id')
          .order('created_at', ascending: false)
          .limit(8);

      // Step 2: Fetch ref_codes data for all relevant category_level1_ids
      final List<int> categoryIds = servicesData.map((e) => e['category_level1_id'] as int).toList();
      final List<Map<String, dynamic>> refCodesData = await Supabase.instance.client
          .from('ref_codes')
          .select('id, extra_data')
          .inFilter('id', categoryIds);

      // Create a map for quick lookup of ref_codes extra_data
      final Map<int, Map<String, dynamic>> refCodesMap = {
        for (var refCode in refCodesData) refCode['id'] as int: refCode['extra_data'] as Map<String, dynamic>,
      };

      recommendations.clear();
      for (var service in servicesData) {
        final Map<String, dynamic>? titleMap = service['title'] as Map<String, dynamic>?;
        final Map<String, dynamic>? descriptionMap = service['description'] as Map<String, dynamic>?;
        final int categoryLevel1Id = service['category_level1_id'] as int;
        final Map<String, dynamic>? categoryExtraData = refCodesMap[categoryLevel1Id];
        final String iconName = categoryExtraData?['icon'] as String? ?? 'category';

        if (titleMap != null && descriptionMap != null) {
          recommendations.add(
            ServiceRecommendation(
              serviceId: service['id'] as String,
              serviceName: titleMap,
              serviceDescription: descriptionMap,
              serviceIcon: iconName,
              recommendationReason: '最新服务',
            ),
          );
        }
      }
    } catch (e) {
      print('Error fetching recommended services: $e');
      Get.snackbar(
        '加载失败',
        '未能加载推荐服务，请稍后再试。',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingRecommendations.value = false;
    }
  }
} 