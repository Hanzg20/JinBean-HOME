import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';

// New model for Level 1 Service Categories
class ServiceCategoryLevel1 {
  final int id;
  final Map<String, dynamic> name;
  final Map<String, dynamic> extraData;

  ServiceCategoryLevel1({
    required this.id,
    required this.name,
    required this.extraData,
  });

  String displayName([String? locale]) => name[locale ?? Get.locale?.languageCode ?? 'zh'] ?? name['zh'] ?? name['en'] ?? '';
  IconData get icon => ServiceBookingController.iconFromString(extraData['icon']);
}

// New model for Level 2 Service Categories
class ServiceCategoryLevel2 {
  final int id;
  final int parentId;
  final Map<String, dynamic> name;
  final Map<String, dynamic> extraData;

  ServiceCategoryLevel2({
    required this.id,
    required this.parentId,
    required this.name,
    required this.extraData,
  });

  String displayName([String? locale]) => name[locale ?? Get.locale?.languageCode ?? 'zh'] ?? name['zh'] ?? name['en'] ?? '';
  IconData get icon => ServiceBookingController.iconFromString(extraData['icon']);
}

// New model for actual Service Items (Level 3 or direct services)
class ServiceItem {
  final String id;
  final int parentId; // category_level2_id
  final dynamic name; // 支持 String 或 Map<String, dynamic>
  final dynamic description;
  final String price;
  final String imageUrl;
  final double rating;
  final int reviews;
  final double? latitude;
  final double? longitude;

  ServiceItem({
    required this.id,
    required this.parentId,
    required this.name,
    required this.description,
    required this.price,
    String? imageUrl,
    required this.rating,
    required this.reviews,
    this.latitude,
    this.longitude,
  }) : imageUrl = imageUrl?.isNotEmpty == true && Uri.tryParse(imageUrl!)?.hasScheme == true
          ? imageUrl
          : 'https://via.placeholder.com/80x80?text=No+Image';
}

// Updated model for Recommended Services
class RecommendedService {
  final String id;
  final dynamic name;
  final dynamic description;
  final String price;
  final String imageUrl;
  final double rating;
  final int reviews;
  final String recommendationReason;
  final double? latitude;
  final double? longitude;

  RecommendedService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    String? imageUrl,
    required this.rating,
    required this.reviews,
    required this.recommendationReason,
    this.latitude,
    this.longitude,
  }) : imageUrl = imageUrl?.isNotEmpty == true && Uri.tryParse(imageUrl!)?.hasScheme == true
          ? imageUrl
          : 'https://via.placeholder.com/80x80?text=No+Image';
}

class ServiceBookingController extends GetxController {
  // 添加搜索相关属性
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxList<String> searchHistory = <String>[].obs;
  final RxList<String> hotSearches = <String>['Cleaning', 'Plumbing', 'Electrician', 'Gardening'].obs;
  final RxBool isLoadingSearch = false.obs;
  
  // 添加GetStorage实例
  final _storage = GetStorage();

  // New states for service categorization
  final RxList<ServiceCategoryLevel1> level1Categories = <ServiceCategoryLevel1>[].obs;
  final RxList<ServiceCategoryLevel2> level2Categories = <ServiceCategoryLevel2>[].obs; // Filtered by level 1 selection
  final RxList<ServiceItem> services = <ServiceItem>[].obs; // Filtered by level 2 selection
  final RxList<RecommendedService> recommendedServices = <RecommendedService>[].obs;

  final RxnInt selectedLevel1CategoryId = RxnInt(null); // Nullable for no selection initially
  final RxnInt selectedLevel2CategoryId = RxnInt(null);
  
  // Add loading states
  final RxBool isLoadingLevel1 = false.obs;
  final RxBool isLoadingLevel2 = false.obs;
  final RxBool isLoadingServices = false.obs;

  static IconData iconFromString(String? iconName) {
    switch (iconName) {
      case 'home_outlined': return Icons.home_outlined;
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'share': return Icons.share;
      case 'school': return Icons.school;
      case 'work': return Icons.work;
      case 'cleaning_services': return Icons.cleaning_services;
      case 'plumbing': return Icons.plumbing;
      case 'electrical_services': return Icons.electrical_services;
      case 'ramen_dining': return Icons.ramen_dining;
      case 'cake': return Icons.cake;
      case 'newspaper': return Icons.newspaper;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'miscellaneous_services': return Icons.miscellaneous_services;
      default: return Icons.category;
    }
  }

  @override
  void onInit() {
    super.onInit();
    print('=== ServiceBookingController onInit ===');
    
    // 加载搜索历史
    _loadSearchHistory();
    
    // 处理从首页传来的参数
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      // 处理level1CategoryId参数（已有功能）
      if (arguments.containsKey('level1CategoryId')) {
        final categoryId = arguments['level1CategoryId'] as int?;
        if (categoryId != null) {
          selectedLevel1CategoryId.value = categoryId;
          print('=== Auto-selecting Level 1 Category: $categoryId ===');
        }
      }
      
      // 处理搜索查询参数（新增功能）
      if (arguments.containsKey('searchQuery')) {
        final query = arguments['searchQuery'] as String?;
        if (query != null && query.isNotEmpty) {
          searchController.text = query;
          searchQuery.value = query;
          print('=== Auto-filling search query: $query ===');
          // 自动执行搜索
          Future.delayed(Duration(milliseconds: 500), () {
            performSearch(query);
          });
        }
      }
    }
    
    fetchLevel1Categories();
  }

  @override
  void onReady() {
    super.onReady();
    print('=== ServiceBookingController onReady ===');
  }

  Future<void> fetchLevel1Categories() async {
    print('=== Fetching Level 1 Categories ===');
    isLoadingLevel1.value = true;
    try {
      final data = await Supabase.instance.client
          .from('ref_codes')
          .select('id, name, extra_data')
          .eq('type_code', 'SERVICE_TYPE')
          .eq('level', 1)
          .eq('status', 1)
          .order('sort_order', ascending: true);

      level1Categories.value = (data as List).map((e) => ServiceCategoryLevel1(
        id: e['id'],
        name: Map<String, dynamic>.from(e['name']),
        extraData: Map<String, dynamic>.from(e['extra_data'] ?? {}),
      )).toList();
      print('Processed categories: ${level1Categories.length} items');

      // After categories are loaded, determine which one to select.
      if (level1Categories.isNotEmpty) {
        int? categoryIdToSelect;

        // Check for an ID passed via arguments
        if (Get.arguments is Map && Get.arguments.containsKey('level1CategoryId')) {
          final initialId = Get.arguments['level1CategoryId'];
          // Ensure the passed ID is valid and exists in our list
          if (level1Categories.any((c) => c.id == initialId)) {
            categoryIdToSelect = initialId;
            print('Found valid initial category ID from arguments: $initialId');
          } else {
            print('Warning: Invalid category ID passed from arguments: $initialId');
          }
        }

        // If no valid ID was passed, select the first category by default.
        if (categoryIdToSelect == null) {
          categoryIdToSelect = level1Categories.first.id;
          print('Auto-selecting first category: $categoryIdToSelect');
        }
        
        selectLevel1Category(categoryIdToSelect);
      }
    } catch (e) {
      print('Error fetching level 1 categories: $e');
      Get.snackbar(
        '加载失败',
        '未能加载服务分类，请稍后再试。',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingLevel1.value = false;
    }
  }

  Future<void> fetchLevel2Categories(int parentId) async {
    isLoadingLevel2.value = true;
    try {
      final data = await Supabase.instance.client
          .from('ref_codes')
          .select('id, name, extra_data, parent_id')
          .eq('type_code', 'SERVICE_TYPE')
          .eq('level', 2)
          .eq('parent_id', parentId)
          .eq('status', 1)
          .order('sort_order', ascending: true);
      level2Categories.value = (data as List).map((e) => ServiceCategoryLevel2(
        id: e['id'],
        parentId: e['parent_id'],
        name: Map<String, dynamic>.from(e['name']),
        extraData: Map<String, dynamic>.from(e['extra_data'] ?? {}),
      )).toList();
      if (level2Categories.isNotEmpty) {
        selectLevel2Category(level2Categories.first.id);
      } else {
        services.clear();
      }
    } catch (e) {
      print('Error fetching level 2 categories: $e');
      Get.snackbar(
        '加载失败',
        '未能加载子分类，请稍后再试。',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingLevel2.value = false;
    }
  }

  // 类型安全解析工具
  double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is bool) return value ? 1.0 : 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
  int parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> fetchServices(int level2Id) async {
    isLoadingServices.value = true;
    try {
      final data = await Supabase.instance.client
          .from('services')
          .select('id, title, description, average_rating, review_count, category_level2_id, status, latitude, longitude')
          .eq('category_level2_id', level2Id)
          .eq('status', 'active');
      final ids = (data as List).map((e) => e['id'] as String).toList();
      // 批量查详情
      final details = ids.isEmpty ? [] : await Supabase.instance.client
          .from('service_details')
          .select('service_id, price, currency, images_url')
          .inFilter('service_id', ids);
      final detailsMap = {for (var d in details) d['service_id']: d};
      services.value = (data as List).map((e) {
        final detail = detailsMap[e['id']];
        final title = e['title'];
        final desc = e['description'];
        final price = detail != null && detail['price'] != null ? '${detail['price']}${detail['currency'] ?? ''}' : '';
        final imageUrl = (detail != null && detail['images_url'] != null && (detail['images_url'] as List).isNotEmpty)
          ? detail['images_url'][0] : '';
        return ServiceItem(
          id: e['id'],
          parentId: e['category_level2_id'],
          name: title,
          description: desc,
          price: price,
          imageUrl: imageUrl,
          rating: parseDouble(e['average_rating']),
          reviews: parseInt(e['review_count']),
          latitude: parseDouble(e['latitude']),
          longitude: parseDouble(e['longitude']),
        );
      }).toList();
    } catch (e) {
      print('Error fetching services: $e');
      Get.snackbar(
        '加载失败',
        '未能加载服务，请稍后再试。',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingServices.value = false;
    }
  }

  Future<void> fetchRecommendedServices() async {
    final data = await Supabase.instance.client
        .from('services')
        .select('id, title, description, average_rating, review_count, status, latitude, longitude')
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(5);
    final ids = (data as List).map((e) => e['id'] as String).toList();
    final details = ids.isEmpty ? [] : await Supabase.instance.client
        .from('service_details')
        .select('service_id, price, currency, images_url')
        .inFilter('service_id', ids);
    final detailsMap = {for (var d in details) d['service_id']: d};
    recommendedServices.value = (data as List).map((e) {
      final detail = detailsMap[e['id']];
      final title = e['title'];
      final desc = e['description'];
      final price = detail != null && detail['price'] != null ? '${detail['price']}${detail['currency'] ?? ''}' : '';
      final imageUrl = (detail != null && detail['images_url'] != null && (detail['images_url'] as List).isNotEmpty)
        ? detail['images_url'][0] : '';
      return RecommendedService(
        id: e['id'],
        name: title,
        description: desc,
        price: price,
        imageUrl: imageUrl,
        rating: parseDouble(e['average_rating']),
        reviews: parseInt(e['review_count']),
        recommendationReason: '最新服务',
        latitude: parseDouble(e['latitude']),
        longitude: parseDouble(e['longitude']),
      );
    }).toList();
  }

  void selectLevel1Category(int categoryId) {
    print('=== Category Selection Debug ===');
    print('Selecting category ID: $categoryId');
    print('Previous selected ID: ${selectedLevel1CategoryId.value}');
    
    if (selectedLevel1CategoryId.value == categoryId) {
      print('Category already selected, skipping');
      return;
    }
    
    selectedLevel1CategoryId.value = categoryId;
    print('New selected ID: ${selectedLevel1CategoryId.value}');
    
    // 先清空二级分类和服务，避免UI残留
    level2Categories.clear();
    services.clear();
    selectedLevel2CategoryId.value = null;
    
    // UI update is handled by Obx, no need for manual refresh
    // level1Categories.refresh(); 
    
    // 获取二级分类
    fetchLevel2Categories(categoryId);
  }

  void selectLevel2Category(int categoryId) {
    selectedLevel2CategoryId.value = categoryId;
    fetchServices(categoryId);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
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

  // 新增：加载搜索历史
  void _loadSearchHistory() {
    try {
      final history = _storage.read<List<String>>('search_history') ?? [];
      searchHistory.assignAll(history);
      print('=== Loaded search history: ${searchHistory.length} items ===');
    } catch (e) {
      print('=== Error loading search history: $e ===');
    }
  }

  // 新增：保存搜索历史
  void _saveSearchHistory() {
    try {
      _storage.write('search_history', searchHistory.toList());
      print('=== Saved search history: ${searchHistory.length} items ===');
    } catch (e) {
      print('=== Error saving search history: $e ===');
    }
  }

  // 新增：搜索功能
  void onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;
    
    // 添加到搜索历史
    final trimmedQuery = query.trim();
    if (!searchHistory.contains(trimmedQuery)) {
      searchHistory.insert(0, trimmedQuery);
      if (searchHistory.length > 10) {
        searchHistory.removeLast();
      }
      // 保存到本地存储
      _saveSearchHistory();
    }
    
    performSearch(trimmedQuery);
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    // 清除搜索结果，显示所有服务
    if (selectedLevel1CategoryId.value != null) {
      fetchLevel2Categories(selectedLevel1CategoryId.value!);
    }
  }

  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    print('=== Performing search for: $query ===');
    isLoadingSearch.value = true;
    
    try {
      // 搜索服务
      final searchResults = await Supabase.instance.client
          .from('services')
          .select('''
            id, title, description, price_range, 
            category_level1_id, category_level2_id,
            service_details, images
          ''')
          .or('title->>en.ilike.%$query%,title->>zh.ilike.%$query%,description->>en.ilike.%$query%,description->>zh.ilike.%$query%')
          .eq('status', 'ACTIVE')
          .limit(20);

      print('Search results: ${searchResults.length} services found');

      // 转换为ServiceItem对象
      final searchServiceItems = searchResults.map((data) {
        return ServiceItem(
          id: data['id'],
          parentId: data['category_level2_id'] ?? 0,
          name: data['title'] ?? {'en': 'Service', 'zh': '服务'},
          description: data['description'] ?? {'en': 'Description', 'zh': '描述'},
          price: data['price_range']?['min']?.toString() ?? '0',
          imageUrl: (data['images'] as List?)?.isNotEmpty == true 
              ? data['images'][0] 
              : 'https://via.placeholder.com/80x80?text=Service',
          rating: 4.5, // TODO: 从reviews表获取真实评分
          reviews: 0,  // TODO: 从reviews表获取真实评论数
        );
      }).toList();

      services.assignAll(searchServiceItems);
      
      Get.snackbar(
        'Search Results',
        'Found ${searchServiceItems.length} services for "$query"',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
      
    } catch (e) {
      print('Search error: $e');
      Get.snackbar(
        'Search Error',
        'Failed to search services. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoadingSearch.value = false;
    }
  }

  void selectHotSearch(String query) {
    searchController.text = query;
    searchQuery.value = query;
    performSearch(query);
  }

  void selectSearchHistory(String query) {
    searchController.text = query;
    searchQuery.value = query;
    performSearch(query);
  }
}