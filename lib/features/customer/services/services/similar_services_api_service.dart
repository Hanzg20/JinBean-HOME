import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/features/customer/domain/entities/similar_service.dart';

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
  static SimilarService _parseSimilarService(Map<String, dynamic> data) {
    return SimilarService(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: data['price']?.toDouble(),
      currency: data['currency'],
      pricingType: data['pricingType'],
      categoryId: data['categoryId'],
      providerId: data['providerId'],
      images: data['images'] != null ? List<String>.from(data['images']) : null,
      rating: data['rating']?.toDouble(),
      reviewCount: data['reviewCount'],
      similarityScore: data['similarityScore']?.toDouble(),
      metadata: data['metadata'],
    );
  }
  
  /// 获取模拟相似服务数据
  static List<SimilarService> _getMockSimilarServices(String serviceId, int limit) {
    final mockServices = [
      SimilarService(
        id: 'similar_1',
        title: 'Professional Home Cleaning',
        description: 'Comprehensive home cleaning service with professional equipment',
        providerId: 'provider_789',
        price: 42.0,
        currency: 'USD',
        rating: 4.7,
        reviewCount: 89,
        similarityScore: 0.92,
        images: ['https://picsum.photos/80/80?random=1'],
        metadata: {
          'providerName': 'CleanMaster Pro',
          'advantages': ['Lower price', 'Faster response'],
          'disadvantages': ['Smaller service area'],
        },
      ),
      SimilarService(
        id: 'similar_2',
        title: 'Complete Home Cleaning Service',
        description: 'Full-service home cleaning with attention to detail',
        providerId: 'provider_101',
        price: 48.0,
        currency: 'USD',
        rating: 4.9,
        reviewCount: 156,
        similarityScore: 0.88,
        images: ['https://picsum.photos/80/80?random=2'],
        metadata: {
          'providerName': 'Sparkle & Shine',
          'advantages': ['Higher rating', 'More reviews'],
          'disadvantages': ['Higher price'],
        },
      ),
      SimilarService(
        id: 'similar_3',
        title: 'Eco-Friendly Home Cleaning',
        description: 'Environmentally conscious cleaning service',
        providerId: 'provider_202',
        price: 45.0,
        currency: 'USD',
        rating: 4.6,
        reviewCount: 67,
        similarityScore: 0.85,
        images: ['https://picsum.photos/80/80?random=3'],
        metadata: {
          'providerName': 'EcoClean Solutions',
          'advantages': ['Eco-friendly', 'Same price'],
          'disadvantages': ['Fewer reviews'],
        },
      ),
      SimilarService(
        id: 'similar_4',
        title: 'Fast & Efficient Cleaning',
        description: 'Quick and efficient cleaning service',
        providerId: 'provider_303',
        price: 38.0,
        currency: 'USD',
        rating: 4.4,
        reviewCount: 45,
        similarityScore: 0.82,
        images: ['https://picsum.photos/80/80?random=4'],
        metadata: {
          'providerName': 'QuickClean Express',
          'advantages': ['Lowest price', 'Quick service'],
          'disadvantages': ['Lower rating'],
        },
      ),
      SimilarService(
        id: 'similar_5',
        title: 'Luxury Home Cleaning',
        description: 'Premium cleaning service for luxury homes',
        providerId: 'provider_404',
        price: 55.0,
        currency: 'USD',
        rating: 4.8,
        reviewCount: 203,
        similarityScore: 0.80,
        images: ['https://picsum.photos/80/80?random=5'],
        metadata: {
          'providerName': 'Premium Clean Co',
          'advantages': ['Premium service', 'High rating'],
          'disadvantages': ['Higher price'],
        },
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
          title: 'Home Cooking Service',
          description: 'Professional home cooking service with fresh ingredients',
          providerId: 'provider_food_1',
          price: 25.0,
          currency: 'USD',
          rating: 4.8,
          reviewCount: 120,
          similarityScore: 0.90,
          images: ['https://picsum.photos/80/80?random=10'],
          metadata: {
            'providerName': 'Tasty Delights',
            'advantages': ['Fresh ingredients', 'Customizable menu'],
            'disadvantages': ['Limited delivery area'],
          },
        ),
        SimilarService(
          id: 'food_2',
          title: 'Professional Catering',
          description: 'Professional catering service for events',
          providerId: 'provider_food_2',
          price: 35.0,
          currency: 'USD',
          rating: 4.9,
          reviewCount: 89,
          similarityScore: 0.87,
          images: ['https://picsum.photos/80/80?random=11'],
          metadata: {
            'providerName': 'Chef\'s Table',
            'advantages': ['Professional chef', 'Event planning'],
            'disadvantages': ['Higher price'],
          },
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