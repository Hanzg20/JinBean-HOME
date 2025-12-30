import 'package:jinbeanpod_83904710/core/utils/app_logger.dart'; // 点评系统服务层
// 处理所有点评相关的API调用和业务逻辑

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review_models.dart';
import 'content_moderation_service.dart';

class ReviewService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  late final ContentModerationService _moderationService;

  @override
  void onInit() {
    super.onInit();
    _moderationService = Get.find<ContentModerationService>();
  }

  // ========================================
  // 1. 点评CRUD操作
  // ========================================

  /// 创建点评
  /// 创建点评 (支持非订单评价)
  Future<Review> createReview(CreateReviewRequest request) async {
    try {
      // 获取当前用户ID
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // ========== 内容审核 ==========
      final moderationResult = await _moderationService.moderateReviewContent(
        title: request.title,
        content: request.content,
        overallRating: request.overallRating,
        serviceRating: request.serviceRating,
        valueRating: request.valueRating,
        atmosphereRating: request.atmosphereRating,
      );

      // 如果审核不通过，抛出异常
      if (!moderationResult.isApproved) {
        AppLogger.info('Review moderation failed: ${moderationResult.details}');
        throw Exception(moderationResult.details ?? '评价内容不符合规范');
      }

      // 检查是否已经评价过该服务
      final existingReview = await _supabase
          .from('reviews')
          .select('id')
          .eq('reviewer_id', currentUser.id)
          .eq('service_id', request.serviceId)
          .maybeSingle();

      if (existingReview != null) {
        throw Exception('您已经评价过该服务，无法重复评价');
      }

      // 准备插入数据
      final reviewData = request.toJson();
      reviewData['reviewer_id'] = currentUser.id;

      // 设置发布时间
      reviewData['published_at'] = DateTime.now().toIso8601String();

      // 如果需要人工审核，设置状态为pending
      if (moderationResult.requiresManualReview) {
        reviewData['status'] = 'pending';
        reviewData['moderation_status'] = 'pending_manual_review';
      } else {
        reviewData['status'] = 'published';
        reviewData['moderation_status'] = 'approved';
      }

      // 如果是非订单评价，设置is_verified为false
      if (request.orderId == null) {
        reviewData['is_verified'] = false;
      }

      final response = await _supabase
          .from('reviews')
          .insert(reviewData)
          .select()
          .single();

      final review = Review.fromJson(response);

      // 记录审核日志
      await _moderationService.logModerationResult(
        contentType: 'review',
        contentId: review.id,
        result: moderationResult,
        userId: currentUser.id,
      );

      return review;
    } catch (e) {
      AppLogger.info('Error creating review: $e');
      throw Exception('Failed to create review: $e');
    }
  }

  /// 创建非订单评价 (便捷方法)
  Future<Review> createNonOrderReview({
    required String serviceId,
    required String providerId,
    required ReviewType reviewType,
    required int overallRating,
    String? title,
    String? content,
    String? sourceDescription,
    int? serviceRating,
    int? valueRating,
    int? atmosphereRating,
    List<String> tags = const [],
    bool isAnonymous = false,
  }) async {
    final request = CreateReviewRequest(
      serviceId: serviceId,
      revieweeId: providerId,
      orderId: null, // 非订单评价
      reviewType: reviewType,
      sourceDescription: sourceDescription,
      overallRating: overallRating,
      title: title,
      content: content,
      serviceRating: serviceRating,
      valueRating: valueRating,
      atmosphereRating: atmosphereRating,
      tags: tags,
      isAnonymous: isAnonymous,
    );
    
    return await createReview(request);
  }

  /// 服务商回复评价
  Future<void> replyToReview(String reviewId, String replyContent) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // ========== 回复内容审核 ==========
      final moderationResult = await _moderationService.moderateReplyContent(replyContent);

      if (!moderationResult.isApproved) {
        AppLogger.info('Reply moderation failed: ${moderationResult.details}');
        throw Exception(moderationResult.details ?? '回复内容不符合规范');
      }

      // 验证是否为服务商
      final review = await _supabase
          .from('reviews')
          .select('reviewee_id, service_id')
          .eq('id', reviewId)
          .single();

      if (review['reviewee_id'] != currentUser.id) {
        // 检查是否为该服务的提供者
        final service = await _supabase
            .from('services')
            .select('provider_id')
            .eq('id', review['service_id'])
            .single();

        if (service['provider_id'] != currentUser.id) {
          throw Exception('只有服务商可以回复评价');
        }
      }

      // 更新评价的回复
      await _supabase
          .from('reviews')
          .update({
            'provider_response': replyContent,
            'provider_response_at': DateTime.now().toIso8601String(),
            'provider_response_status': moderationResult.requiresManualReview
                ? 'pending_review'
                : 'published',
          })
          .eq('id', reviewId);

      // 记录审核日志
      await _moderationService.logModerationResult(
        contentType: 'reply',
        contentId: reviewId,
        result: moderationResult,
        userId: currentUser.id,
      );

      AppLogger.info('Successfully replied to review: $reviewId');
    } catch (e) {
      AppLogger.info('Error replying to review: $e');
      throw Exception('Failed to reply to review: $e');
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
          .from('reviews')
          .select('*')
          .eq('service_id', serviceId)
          .eq('status', 'published');

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
      AppLogger.info('Error fetching service reviews: $e');
      throw Exception('Failed to fetch service reviews: $e');
    }
  }

  /// 获取用户点评列表
  Future<List<Review>> getUserReviews(String userId,
      {int page = 1, int limit = 10}) async {
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
      AppLogger.info('Error fetching user reviews: $e');
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
      AppLogger.info('Error fetching review: $e');
      throw Exception('Failed to fetch review: $e');
    }
  }

  /// 更新点评
  Future<Review> updateReview(
      String reviewId, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from('reviews')
          .update(updates)
          .eq('id', reviewId)
          .select()
          .single();

      return Review.fromJson(response);
    } catch (e) {
      AppLogger.info('Error updating review: $e');
      throw Exception('Failed to update review: $e');
    }
  }

  /// 删除点评
  Future<void> deleteReview(String reviewId) async {
    try {
      await _supabase
          .from('reviews')
          .update({'status': 'deleted'}).eq('id', reviewId);
    } catch (e) {
      AppLogger.info('Error deleting review: $e');
      throw Exception('Failed to delete review: $e');
    }
  }

  // ========================================
  // 2. 点评回复操作
  // ========================================

  /// 创建点评回复
  Future<ReviewReply> createReviewReply(
      CreateReviewReplyRequest request) async {
    try {
      final response = await _supabase
          .from('review_replies')
          .insert(request.toJson())
          .select()
          .single();

      return ReviewReply.fromJson(response);
    } catch (e) {
      AppLogger.info('Error creating review reply: $e');
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

      return (response as List)
          .map((json) => ReviewReply.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.info('Error fetching review replies: $e');
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
          await _supabase.from('review_helpful_votes').update(
              {'is_helpful': request.isHelpful}).eq('id', existingVote['id']);
        }
      } else {
        // 创建新投票
        await _supabase.from('review_helpful_votes').insert(request.toJson());
      }
    } catch (e) {
      AppLogger.info('Error voting review: $e');
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
      AppLogger.info('Error fetching user vote status: $e');
      return null;
    }
  }

  // ========================================
  // 4. 点评举报操作
  // ========================================

  /// 举报点评
  Future<void> reportReview(ReviewReportRequest request) async {
    try {
      await _supabase.from('review_reports').insert(request.toJson());
    } catch (e) {
      AppLogger.info('Error reporting review: $e');
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

      return (response as List)
          .map((json) => ReviewTag.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.info('Error fetching review tags: $e');
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

      return (response as List)
          .map((json) => ReviewTag.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.info('Error fetching review tags by category: $e');
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
      AppLogger.info('Error fetching service rating stats: $e');
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
      AppLogger.info('Error checking if user has reviewed service: $e');
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
      AppLogger.info('Error fetching user reviewable orders: $e');
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
