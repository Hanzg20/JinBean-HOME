import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:uuid/uuid.dart';

/// 评价数据创建服务
class ReviewDataCreationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 基于最新订单创建评价数据
  Future<void> createReviewsFromLatestOrder() async {
    try {
      AppLogger.info('[ReviewDataCreationService] 开始创建基于最新订单的评价数据');

      // 1. 获取最新订单信息
      final orderResponse = await _supabase
          .from('orders')
          .select('''
            id,
            user_id,
            provider_id,
            service_id,
            order_status,
            created_at
          ''')
          .inFilter('order_status', ['completed', 'delivered', 'confirmed'])
          .order('created_at', ascending: false)
          .limit(1);

      if (orderResponse.isEmpty) {
        AppLogger.warning('[ReviewDataCreationService] 没有找到符合条件的订单');
        return;
      }

      final order = orderResponse.first;
      AppLogger.info('[ReviewDataCreationService] 找到最新订单: ${order['id']}');

      // 2. 检查是否已存在基于订单的评价
      final existingOrderReview = await _supabase
          .from('reviews')
          .select('id')
          .eq('order_id', order['id'])
          .maybeSingle();

      if (existingOrderReview != null) {
        AppLogger.info('[ReviewDataCreationService] 订单 ${order['id']} 已有评价，跳过');
      } else {
        // 创建基于订单的评价
        await _createOrderBasedReview(order);
      }

      // 3. 检查是否已存在基于服务的评价
      final existingServiceReview = await _supabase
          .from('reviews')
          .select('id')
          .eq('reviewer_id', order['user_id'])
          .eq('service_id', order['service_id'])
          .isFilter('order_id', null)
          .maybeSingle();

      if (existingServiceReview != null) {
        AppLogger.info('[ReviewDataCreationService] 服务 ${order['service_id']} 已有非订单评价，跳过');
      } else {
        // 创建基于服务的评价
        await _createServiceBasedReview(order);
      }

      // 4. 创建一些额外的评价数据
      await _createAdditionalReviews(order);

      AppLogger.info('[ReviewDataCreationService] 评价数据创建完成');

    } catch (e) {
      AppLogger.error('[ReviewDataCreationService] 创建评价数据失败: $e');
      rethrow;
    }
  }

  /// 创建基于订单的评价
  Future<void> _createOrderBasedReview(Map<String, dynamic> order) async {
    try {
      final reviewData = {
        'id': const Uuid().v4(),
        'order_id': order['id'],
        'reviewer_id': order['user_id'],
        'reviewee_id': order['provider_id'],
        'service_id': order['service_id'],
        'review_type': 'order_based',
        'overall_rating': 5,
        'service_rating': 5,
        'content': '服务非常棒！超出了我的期望，强烈推荐！',
        'images': [],
        'tags': ['服务热情', '专业细致', '性价比高'],
        'is_verified': true,
        'is_anonymous': false,
        'status': 'published',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('reviews').insert(reviewData);
      AppLogger.info('[ReviewDataCreationService] 创建基于订单的评价成功');

    } catch (e) {
      AppLogger.error('[ReviewDataCreationService] 创建基于订单的评价失败: $e');
      rethrow;
    }
  }

  /// 创建基于服务的评价（非订单评价）
  Future<void> _createServiceBasedReview(Map<String, dynamic> order) async {
    try {
      final reviewData = {
        'id': const Uuid().v4(),
        'order_id': null,
        'reviewer_id': order['user_id'],
        'reviewee_id': order['provider_id'],
        'service_id': order['service_id'],
        'review_type': 'visit_based',
        'overall_rating': 4,
        'service_rating': 4,
        'content': '虽然没有下单，但体验了服务咨询，服务态度很好，环境也不错。',
        'images': [],
        'tags': ['环境优雅', '服务热情'],
        'is_verified': false,
        'is_anonymous': false,
        'status': 'published',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('reviews').insert(reviewData);
      AppLogger.info('[ReviewDataCreationService] 创建基于服务的评价成功');

    } catch (e) {
      AppLogger.error('[ReviewDataCreationService] 创建基于服务的评价失败: $e');
      rethrow;
    }
  }

  /// 创建额外的评价数据
  Future<void> _createAdditionalReviews(Map<String, dynamic> order) async {
    try {
      // 获取同一服务商的其他服务
      final servicesResponse = await _supabase
          .from('services')
          .select('id, title')
          .eq('provider_id', order['provider_id'])
          .neq('id', order['service_id'])
          .limit(3);

      // 获取其他用户
      final usersResponse = await _supabase
          .from('user_profiles')
          .select('user_id')
          .neq('user_id', order['user_id'])
          .limit(3);

      if (servicesResponse.isNotEmpty && usersResponse.isNotEmpty) {
        for (int i = 0; i < servicesResponse.length && i < usersResponse.length; i++) {
          final service = servicesResponse[i];
          final user = usersResponse[i];

          // 检查是否已存在评价
          final existingReview = await _supabase
              .from('reviews')
              .select('id')
              .eq('reviewer_id', user['user_id'])
              .eq('service_id', service['id'])
              .maybeSingle();

          if (existingReview == null) {
            final reviewData = {
              'id': const Uuid().v4(),
              'order_id': null,
              'reviewer_id': user['user_id'],
              'reviewee_id': order['provider_id'],
              'service_id': service['id'],
              'review_type': 'consultation',
              'overall_rating': 4,
              'service_rating': 4,
              'content': '服务很棒，推荐！',
              'images': [],
              'tags': ['服务热情', '专业细致'],
              'is_verified': false,
              'is_anonymous': false,
              'status': 'published',
              'created_at': DateTime.now().subtract(Duration(days: i + 1)).toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            };

            await _supabase.from('reviews').insert(reviewData);
            AppLogger.info('[ReviewDataCreationService] 创建额外评价成功: ${service['id']}');
          }
        }
      }

    } catch (e) {
      AppLogger.error('[ReviewDataCreationService] 创建额外评价失败: $e');
      rethrow;
    }
  }

  /// 获取评价统计信息
  Future<Map<String, int>> getReviewStats() async {
    try {
      final orderBasedCount = await _supabase
          .from('reviews')
          .select('id')
          .not('order_id', 'is', null);

      final serviceBasedCount = await _supabase
          .from('reviews')
          .select('id')
          .isFilter('order_id', null);

      final totalCount = await _supabase
          .from('reviews')
          .select('id');

      return {
        'orderBased': orderBasedCount.length,
        'serviceBased': serviceBasedCount.length,
        'total': totalCount.length,
      };

    } catch (e) {
      AppLogger.error('[ReviewDataCreationService] 获取评价统计失败: $e');
      return {'orderBased': 0, 'serviceBased': 0, 'total': 0};
    }
  }
}
