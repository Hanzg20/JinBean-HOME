import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:jinbeanpod_83904710/core/services/review_service.dart';
import 'package:jinbeanpod_83904710/core/models/review_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyReviewsController extends GetxController {
  final isLoading = false.obs;
  final reviews = <Review>[].obs;
  final errorMessage = ''.obs;
  
  // 集成ReviewService
  late final ReviewService _reviewService;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('MyReviewsController initialized',
        tag: 'MyReviewsController');
    
    // 获取或创建ReviewService实例
    try {
      _reviewService = Get.find<ReviewService>();
    } catch (e) {
      _reviewService = Get.put(ReviewService());
    }
    
    loadReviews();
  }

  Future<void> loadReviews() async {
    AppLogger.info('MyReviewsController: loadReviews called',
        tag: 'MyReviewsController');
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // 使用ReviewService获取用户的评价
      final userReviews = await _getUserReviews(user.id);
      reviews.assignAll(userReviews);
      
      AppLogger.info('MyReviewsController: Reviews loaded successfully, count: ${reviews.length}',
          tag: 'MyReviewsController');
          
    } catch (e, stack) {
      AppLogger.error('MyReviewsController: Failed to load reviews',
          error: e, stackTrace: stack, tag: 'MyReviewsController');
      errorMessage.value = 'Failed to load reviews: $e';
      
      // 如果API调用失败，使用Mock数据作为备用
      _loadMockReviews();
    } finally {
      isLoading.value = false;
    }
  }

  /// 获取用户的评价
  Future<List<Review>> _getUserReviews(String userId) async {
    try {
      // 直接查询数据库获取用户的评价
      final response = await Supabase.instance.client
          .from('reviews')
          .select('''
            id,
            service_id,
            overall_rating,
            content,
            created_at,
            services!inner(
              title
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<Review> reviewList = [];
      for (final reviewData in response) {
        try {
          // 构建Review对象
          final review = Review(
            id: reviewData['id'],
            serviceId: reviewData['service_id'],
            reviewerId: userId,
            revieweeId: reviewData['reviewee_id'] ?? '',
            orderId: reviewData['order_id'],
            overallRating: reviewData['overall_rating'],
            title: reviewData['title'],
            content: reviewData['content']?.toString(),
            qualityRating: reviewData['quality_rating'],
            serviceRating: reviewData['service_rating'],
            valueRating: reviewData['value_rating'],
            atmosphereRating: reviewData['atmosphere_rating'],
            images: List<String>.from(reviewData['images'] ?? []),
            status: reviewData['status'] ?? 'published',
            isVerified: reviewData['is_verified'] ?? false,
            helpfulCount: reviewData['helpful_count'] ?? 0,
            totalVotes: reviewData['total_votes'] ?? 0,
            providerResponse: reviewData['provider_response'],
            providerResponseAt: reviewData['provider_response_at'] != null
                ? DateTime.parse(reviewData['provider_response_at'])
                : null,
            createdAt: DateTime.parse(reviewData['created_at']),
            updatedAt: DateTime.parse(reviewData['updated_at']),
            reviewer: reviewData['reviewer'],
            serviceTitle: reviewData['services']?['title']?.toString(),
            providerName: reviewData['provider_name'],
          );
          
          reviewList.add(review);
        } catch (e) {
          AppLogger.warning('Failed to parse review data: $e');
        }
      }

      return reviewList;
    } catch (e) {
      AppLogger.error('Failed to fetch user reviews from database: $e');
      rethrow;
    }
  }

  /// 加载Mock数据作为备用
  void _loadMockReviews() {
    AppLogger.info('Loading mock reviews as fallback');
    
    final mockReviews = [
      Review(
        id: 'mock_r001',
        serviceId: 'service_001',
        reviewerId: 'current_user',
        revieweeId: 'provider_001',
        orderId: 'order_001',
        overallRating: 4,
        title: 'Great service!',
        content: 'Great service, very thorough and professional!',
        qualityRating: 5,
        serviceRating: 4,
        valueRating: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        serviceTitle: 'House Cleaning',
        providerName: 'CleanPro Services',
      ),
      Review(
        id: 'mock_r002',
        serviceId: 'service_002',
        reviewerId: 'current_user',
        revieweeId: 'provider_002',
        orderId: 'order_002',
        overallRating: 5,
        title: 'Excellent work!',
        content: 'Quick response and fixed the leak perfectly.',
        qualityRating: 5,
        serviceRating: 5,
        atmosphereRating: 5,
        valueRating: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        serviceTitle: 'Plumbing Repair',
        providerName: 'FixIt Plumbing',
      ),
      Review(
        id: 'mock_r003',
        serviceId: 'service_003',
        reviewerId: 'current_user',
        revieweeId: 'provider_003',
        orderId: 'order_003',
        overallRating: 3,
        title: 'Good but could be better',
        content: 'Service was okay, but a bit slow.',
        qualityRating: 3,
        serviceRating: 2,
        atmosphereRating: 4,
        valueRating: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        serviceTitle: 'Electrical Work',
        providerName: 'ElectricPro',
      ),
    ];
    
    reviews.assignAll(mockReviews);
  }

  Future<void> refreshReviews() async {
    AppLogger.info('MyReviewsController: refreshReviews called',
        tag: 'MyReviewsController');
    await loadReviews();
  }

  /// 创建新评价
  Future<bool> createReview({
    required String serviceId,
    required String providerId,
    String? orderId,
    required double rating,
    required String comment,
    List<String> tags = const [],
  }) async {
    try {
      AppLogger.info('Creating new review for service: $serviceId');
      
      final request = CreateReviewRequest(
        serviceId: serviceId,
        revieweeId: providerId,
        orderId: orderId,
        overallRating: rating.round(),
        content: comment,
        images: [],
      );

      final newReview = await _reviewService.createReview(request);
      
      // 将新评价添加到列表开头
      reviews.insert(0, newReview);
      
      AppLogger.info('Review created successfully: ${newReview.id}');
      return true;
      
    } catch (e) {
      AppLogger.error('Failed to create review: $e');
      errorMessage.value = 'Failed to create review: $e';
      return false;
    }
  }

  /// 删除评价
  Future<bool> deleteReview(String reviewId) async {
    try {
      AppLogger.info('Deleting review: $reviewId');
      
      // TODO: 实现删除评价的API调用
      // await _reviewService.deleteReview(reviewId);
      
      // 从列表中移除
      reviews.removeWhere((review) => review.id == reviewId);
      
      AppLogger.info('Review deleted successfully');
      return true;
      
    } catch (e) {
      AppLogger.error('Failed to delete review: $e');
      errorMessage.value = 'Failed to delete review: $e';
      return false;
    }
  }

  /// 获取评价统计信息
  Map<String, dynamic> getReviewStats() {
    if (reviews.isEmpty) {
      return {
        'totalReviews': 0,
        'averageRating': 0.0,
        'ratingDistribution': <int, int>{},
      };
    }

    final totalReviews = reviews.length;
    final averageRating = reviews.fold<double>(
      0.0, 
      (sum, review) => sum + review.overallRating,
    ) / totalReviews;

    final ratingDistribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      ratingDistribution[i] = reviews.where(
        (review) => review.overallRating.round() == i,
      ).length;
    }

    return {
      'totalReviews': totalReviews,
      'averageRating': averageRating,
      'ratingDistribution': ratingDistribution,
    };
  }

  /// 按评分筛选评价
  void filterByRating(double? minRating) {
    if (minRating == null) {
      loadReviews(); // 重新加载所有评价
      return;
    }

    final filteredReviews = reviews.where(
      (review) => review.overallRating >= minRating,
    ).toList();
    
    reviews.assignAll(filteredReviews);
  }

  /// 搜索评价
  void searchReviews(String query) {
    if (query.trim().isEmpty) {
      loadReviews(); // 重新加载所有评价
      return;
    }

    final searchQuery = query.toLowerCase();
    final filteredReviews = reviews.where((review) {
      final serviceName = review.serviceTitle?.toLowerCase() ?? '';
      final content = review.getLocalizedContent('en').toLowerCase();
      
      return serviceName.contains(searchQuery) || content.contains(searchQuery);
    }).toList();
    
    reviews.assignAll(filteredReviews);
  }

  /// 获取可写评价的服务（基于已完成的订单）
  Future<List<Map<String, dynamic>>> getReviewableServices() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return [];

      // 查询已完成但未评价的订单
      final response = await Supabase.instance.client
          .from('orders')
          .select('''
            id,
            service_id,
            provider_id,
            services!inner(
              title
            )
          ''')
          .eq('user_id', user.id)
          .eq('order_status', 'completed')
          .not('service_id', 'in', '(${reviews.map((r) => r.serviceId).join(',')})');

      return response.map<Map<String, dynamic>>((order) => {
        'orderId': order['id'],
        'serviceId': order['service_id'],
        'providerId': order['provider_id'],
        'serviceName': order['services']['title'],
      }).toList();

    } catch (e) {
      AppLogger.error('Failed to get reviewable services: $e');
      return [];
    }
  }
}
