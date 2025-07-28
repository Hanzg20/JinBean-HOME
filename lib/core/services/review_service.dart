// 点评系统服务层
// 处理所有点评相关的API调用和业务逻辑

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review_models.dart';

class ReviewService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ========================================
  // 1. 点评CRUD操作
  // ========================================

  /// 创建点评
  Future<Review> createReview(CreateReviewRequest request) async {
    try {
      final response = await _supabase
          .from('reviews')
          .insert(request.toJson())
          .select()
          .single();

      return Review.fromJson(response);
    } catch (e) {
      print('Error creating review: $e');
      throw Exception('Failed to create review: $e');
    }
  }

  /// 获取服务点评列表
  Future<List<Review>> getServiceReviews(
    String serviceId, {
    ReviewFilterOptions? filterOptions,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      dynamic query = _supabase
          .from('user_reviews_view')
          .select('*')
          .eq('service_id', serviceId)
          .eq('status', 'active');

      // 应用筛选条件
      if (filterOptions != null) {
        if (filterOptions.minRating != null) {
          query = query.gte('overall_rating', filterOptions.minRating!);
        }
        if (filterOptions.maxRating != null) {
          query = query.lte('overall_rating', filterOptions.maxRating!);
        }
        if (filterOptions.tags.isNotEmpty) {
          query = query.overlaps('tags', filterOptions.tags);
        }
        if (filterOptions.hasImages == true) {
          query = query.not('images', 'eq', '[]');
        }
        if (filterOptions.hasReplies == true) {
          // 需要检查是否有回复
          // TODO: 实现回复检查逻辑
        }
      }

      // 应用排序
      switch (filterOptions?.sortBy) {
        case 'newest':
          query = query.order('created_at', ascending: false);
          break;
        case 'oldest':
          query = query.order('created_at', ascending: true);
          break;
        case 'rating':
          query = query.order('overall_rating', ascending: false);
          break;
        case 'helpful':
          query = query.order('helpful_count', ascending: false);
          break;
        default:
          query = query.order('created_at', ascending: false);
      }

      // 分页
      final offset = (page - 1) * limit;
      final response = await query.range(offset, offset + limit - 1);

      return (response as List).map((json) => Review.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching service reviews: $e');
      throw Exception('Failed to fetch service reviews: $e');
    }
  }

  /// 获取用户点评列表
  Future<List<Review>> getUserReviews(String userId, {int page = 1, int limit = 10}) async {
    try {
      final response = await _supabase
          .from('user_reviews_view')
          .select('*')
          .eq('user_id', userId)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      return (response as List).map((json) => Review.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching user reviews: $e');
      throw Exception('Failed to fetch user reviews: $e');
    }
  }

  /// 获取单个点评详情
  Future<Review> getReview(String reviewId) async {
    try {
      final response = await _supabase
          .from('user_reviews_view')
          .select('*')
          .eq('id', reviewId)
          .eq('status', 'active')
          .single();

      return Review.fromJson(response);
    } catch (e) {
      print('Error fetching review: $e');
      throw Exception('Failed to fetch review: $e');
    }
  }

  /// 更新点评
  Future<Review> updateReview(String reviewId, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from('reviews')
          .update(updates)
          .eq('id', reviewId)
          .select()
          .single();

      return Review.fromJson(response);
    } catch (e) {
      print('Error updating review: $e');
      throw Exception('Failed to update review: $e');
    }
  }

  /// 删除点评
  Future<void> deleteReview(String reviewId) async {
    try {
      await _supabase
          .from('reviews')
          .update({'status': 'deleted'})
          .eq('id', reviewId);
    } catch (e) {
      print('Error deleting review: $e');
      throw Exception('Failed to delete review: $e');
    }
  }

  // ========================================
  // 2. 点评回复操作
  // ========================================

  /// 创建点评回复
  Future<ReviewReply> createReviewReply(CreateReviewReplyRequest request) async {
    try {
      final response = await _supabase
          .from('review_replies')
          .insert(request.toJson())
          .select()
          .single();

      return ReviewReply.fromJson(response);
    } catch (e) {
      print('Error creating review reply: $e');
      throw Exception('Failed to create review reply: $e');
    }
  }

  /// 获取点评回复列表
  Future<List<ReviewReply>> getReviewReplies(String reviewId) async {
    try {
      final response = await _supabase
          .from('review_replies')
          .select('*')
          .eq('review_id', reviewId)
          .eq('status', 'active')
          .order('created_at', ascending: true);

      return (response as List).map((json) => ReviewReply.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching review replies: $e');
      throw Exception('Failed to fetch review replies: $e');
    }
  }

  // ========================================
  // 3. 点评投票操作
  // ========================================

  /// 投票点评有用性
  Future<void> voteReview(ReviewVoteRequest request) async {
    try {
      // 检查是否已经投票
      final existingVote = await _supabase
          .from('review_helpful_votes')
          .select('id, is_helpful')
          .eq('review_id', request.reviewId)
          .eq('user_id', _supabase.auth.currentUser!.id)
          .maybeSingle();

      if (existingVote != null) {
        // 更新现有投票
        if (existingVote['is_helpful'] != request.isHelpful) {
          await _supabase
              .from('review_helpful_votes')
              .update({'is_helpful': request.isHelpful})
              .eq('id', existingVote['id']);
        }
      } else {
        // 创建新投票
        await _supabase
            .from('review_helpful_votes')
            .insert(request.toJson());
      }
    } catch (e) {
      print('Error voting review: $e');
      throw Exception('Failed to vote review: $e');
    }
  }

  /// 获取用户投票状态
  Future<bool?> getUserVoteStatus(String reviewId) async {
    try {
      final response = await _supabase
          .from('review_helpful_votes')
          .select('is_helpful')
          .eq('review_id', reviewId)
          .eq('user_id', _supabase.auth.currentUser!.id)
          .maybeSingle();

      return response?['is_helpful'] as bool?;
    } catch (e) {
      print('Error fetching user vote status: $e');
      return null;
    }
  }

  // ========================================
  // 4. 点评举报操作
  // ========================================

  /// 举报点评
  Future<void> reportReview(ReviewReportRequest request) async {
    try {
      await _supabase
          .from('review_reports')
          .insert(request.toJson());
    } catch (e) {
      print('Error reporting review: $e');
      throw Exception('Failed to report review: $e');
    }
  }

  // ========================================
  // 5. 点评标签操作
  // ========================================

  /// 获取所有点评标签
  Future<List<ReviewTag>> getReviewTags() async {
    try {
      final response = await _supabase
          .from('review_tags')
          .select('*')
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (response as List).map((json) => ReviewTag.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching review tags: $e');
      throw Exception('Failed to fetch review tags: $e');
    }
  }

  /// 按分类获取点评标签
  Future<List<ReviewTag>> getReviewTagsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('review_tags')
          .select('*')
          .eq('category', category)
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (response as List).map((json) => ReviewTag.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching review tags by category: $e');
      throw Exception('Failed to fetch review tags by category: $e');
    }
  }

  // ========================================
  // 6. 评分统计操作
  // ========================================

  /// 获取服务评分统计
  Future<ServiceRatingStats?> getServiceRatingStats(String serviceId) async {
    try {
      final response = await _supabase
          .from('service_rating_stats')
          .select('*')
          .eq('service_id', serviceId)
          .maybeSingle();

      if (response != null) {
        return ServiceRatingStats.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching service rating stats: $e');
      return null;
    }
  }

  // ========================================
  // 7. 检查用户是否可以评价
  // ========================================

  /// 检查用户是否已经评价过该服务
  Future<bool> hasUserReviewedService(String serviceId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('id')
          .eq('service_id', serviceId)
          .eq('user_id', _supabase.auth.currentUser!.id)
          .eq('status', 'active')
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking if user has reviewed service: $e');
      return false;
    }
  }

  /// 检查用户是否有订单可以评价
  Future<List<Map<String, dynamic>>> getUserReviewableOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            id, order_number, total_price, order_status, created_at,
            services!inner(id, title, provider_profiles!inner(id, display_name))
          ''')
          .eq('user_id', _supabase.auth.currentUser!.id)
          .eq('order_status', 'completed')
          .order('created_at', ascending: false);

      return (response as List).map((order) {
        final service = order['services'];
        final provider = service['provider_profiles'];
        return {
          'order_id': order['id'],
          'order_number': order['order_number'],
          'total_price': order['total_price'],
          'created_at': order['created_at'],
          'service_id': service['id'],
          'service_title': service['title'],
          'provider_id': provider['id'],
          'provider_name': provider['display_name'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching user reviewable orders: $e');
      return [];
    }
  }

  // ========================================
  // 8. 工具方法
  // ========================================

  /// 格式化评分显示
  String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  /// 获取评分等级
  String getRatingLevel(double rating) {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 4.0) return 'Very Good';
    if (rating >= 3.5) return 'Good';
    if (rating >= 3.0) return 'Fair';
    return 'Poor';
  }

  /// 获取评分颜色
  int getRatingColor(double rating) {
    if (rating >= 4.0) return 0xFF4CAF50; // Green
    if (rating >= 3.0) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Red
  }

  /// 验证评分范围
  bool isValidRating(double rating) {
    return rating >= 1.0 && rating <= 5.0;
  }

  /// 验证点评内容长度
  bool isValidContentLength(String content) {
    return content.length >= 10 && content.length <= 1000;
  }
} 