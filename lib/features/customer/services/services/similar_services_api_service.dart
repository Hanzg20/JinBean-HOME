import 'package:jinbeanpod_83904710/features/customer/services/presentation/service_detail_controller.dart';

class SimilarServicesApiService {
  /// 获取指定服务的相似服务列表
  static Future<List<SimilarService>> getSimilarServices(
    String serviceId, {
    int limit = 5,
    double minSimilarityScore = 0.7,
  }) async {
    try {
      // 模拟网络延迟
      await Future.delayed(Duration(milliseconds: 500));
      
      // 返回模拟数据
      return _getMockSimilarServices(serviceId, limit);
    } catch (e) {
      // 如果API调用失败，返回模拟数据
      return _getMockSimilarServices(serviceId, limit);
    }
  }
  
  /// 根据分类获取相似服务
  static Future<List<SimilarService>> getSimilarServicesByCategory(
    String categoryId, {
    String? location,
    String? priceRange,
    double? rating,
    int limit = 10,
  }) async {
    try {
      // 模拟网络延迟
      await Future.delayed(Duration(milliseconds: 500));
      
      // 返回模拟数据
      return _getMockSimilarServicesByCategory(categoryId, limit);
    } catch (e) {
      // 如果API调用失败，返回模拟数据
      return _getMockSimilarServicesByCategory(categoryId, limit);
    }
  }
  
  /// 解析API响应中的相似服务数据
  static SimilarService _parseSimilarService(Map<String, dynamic> json) {
    return SimilarService(
      id: json['id'],
      providerId: json['provider_id'],
      providerName: json['provider_name'],
      serviceTitle: json['service_title'],
      price: (json['price'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      similarityScore: (json['similarity_score'] ?? 0).toDouble(),
      providerAvatar: json['provider_avatar'] ?? '',
      advantages: List<String>.from(json['advantages'] ?? []),
      disadvantages: List<String>.from(json['disadvantages'] ?? []),
    );
  }
  
  /// 获取模拟相似服务数据
  static List<SimilarService> _getMockSimilarServices(String serviceId, int limit) {
    final mockServices = [
      SimilarService(
        id: 'similar_1',
        providerId: 'provider_789',
        providerName: 'CleanMaster Pro',
        serviceTitle: 'Professional Home Cleaning',
        price: 42.0,
        rating: 4.7,
        reviewCount: 89,
        similarityScore: 0.92,
        providerAvatar: 'https://picsum.photos/80/80?random=1',
        advantages: ['Lower price', 'Faster response'],
        disadvantages: ['Smaller service area'],
      ),
      SimilarService(
        id: 'similar_2',
        providerId: 'provider_101',
        providerName: 'Sparkle & Shine',
        serviceTitle: 'Complete Home Cleaning Service',
        price: 48.0,
        rating: 4.9,
        reviewCount: 156,
        similarityScore: 0.88,
        providerAvatar: 'https://picsum.photos/80/80?random=2',
        advantages: ['Higher rating', 'More reviews'],
        disadvantages: ['Higher price'],
      ),
      SimilarService(
        id: 'similar_3',
        providerId: 'provider_202',
        providerName: 'EcoClean Solutions',
        serviceTitle: 'Eco-Friendly Home Cleaning',
        price: 45.0,
        rating: 4.6,
        reviewCount: 67,
        similarityScore: 0.85,
        providerAvatar: 'https://picsum.photos/80/80?random=3',
        advantages: ['Eco-friendly', 'Same price'],
        disadvantages: ['Fewer reviews'],
      ),
      SimilarService(
        id: 'similar_4',
        providerId: 'provider_303',
        providerName: 'QuickClean Express',
        serviceTitle: 'Fast & Efficient Cleaning',
        price: 38.0,
        rating: 4.4,
        reviewCount: 45,
        similarityScore: 0.82,
        providerAvatar: 'https://picsum.photos/80/80?random=4',
        advantages: ['Lowest price', 'Quick service'],
        disadvantages: ['Lower rating'],
      ),
      SimilarService(
        id: 'similar_5',
        providerId: 'provider_404',
        providerName: 'Premium Clean Co',
        serviceTitle: 'Luxury Home Cleaning',
        price: 55.0,
        rating: 4.8,
        reviewCount: 203,
        similarityScore: 0.80,
        providerAvatar: 'https://picsum.photos/80/80?random=5',
        advantages: ['Premium service', 'High rating'],
        disadvantages: ['Higher price'],
      ),
    ];
    
    return mockServices.take(limit).toList();
  }
  
  /// 根据分类获取模拟相似服务数据
  static List<SimilarService> _getMockSimilarServicesByCategory(String categoryId, int limit) {
    // 根据分类ID返回不同的模拟数据
    final mockServices = _getMockSimilarServices('', limit);
    
    // 这里可以根据categoryId调整数据
    if (categoryId == '1020000') { // Home Services
      return mockServices;
    } else if (categoryId == '1010000') { // Food & Dining
      return [
        SimilarService(
          id: 'food_1',
          providerId: 'provider_food_1',
          providerName: 'Tasty Delights',
          serviceTitle: 'Home Cooking Service',
          price: 25.0,
          rating: 4.8,
          reviewCount: 120,
          similarityScore: 0.90,
          providerAvatar: 'https://picsum.photos/80/80?random=10',
          advantages: ['Fresh ingredients', 'Customizable menu'],
          disadvantages: ['Limited delivery area'],
        ),
        SimilarService(
          id: 'food_2',
          providerId: 'provider_food_2',
          providerName: 'Chef\'s Table',
          serviceTitle: 'Professional Catering',
          price: 35.0,
          rating: 4.9,
          reviewCount: 89,
          similarityScore: 0.87,
          providerAvatar: 'https://picsum.photos/80/80?random=11',
          advantages: ['Professional chef', 'Event planning'],
          disadvantages: ['Higher price'],
        ),
      ];
    }
    
    return mockServices;
  }
  
  /// 记录用户对相似服务的交互
  static Future<void> logSimilarServiceInteraction(
    String currentServiceId,
    String similarServiceId,
    String interactionType, // 'view', 'click', 'book'
  ) async {
    try {
      // 模拟网络延迟
      await Future.delayed(Duration(milliseconds: 500));
      
      // 模拟成功
      print('Logged similar service interaction: $currentServiceId -> $similarServiceId, type: $interactionType');
    } catch (e) {
      // 静默处理错误，不影响用户体验
      print('Failed to log similar service interaction: $e');
    }
  }
} 