import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/features/customer/domain/entities/service.dart';
import 'package:jinbeanpod_83904710/features/customer/domain/entities/service_detail.dart';
import 'package:jinbeanpod_83904710/features/customer/domain/entities/provider_profile.dart';
import 'package:jinbeanpod_83904710/core/models/review_models.dart';
import '../../../../core/services/provider_query_manager.dart';

class ServiceDetailApiService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// 获取服务数据
  static Future<Service> getService(String serviceId) async {
    try {
      AppLogger.info('Fetching service with ID: $serviceId');

      final response = await _supabase.from('services').select('''
            *,
            service_details(*),
            provider_profiles!services_provider_id_fkey(*)
          ''').eq('id', serviceId).single();

      AppLogger.info('Service data fetched successfully: ${response.keys}');
      return Service.fromJson(response);
    } catch (e) {
      AppLogger.error('Error fetching service: $e');
      // 直接抛出错误，不返回Mock数据
      rethrow;
    }
  }

  /// 获取服务详情数据（单个）
  static Future<ServiceDetail> getServiceDetail(String serviceId) async {
    try {
      AppLogger.info('Fetching service detail for service ID: $serviceId');

      final response = await _supabase
          .from('service_details')
          .select('*')
          .eq('service_id', serviceId)
          .limit(1)
          .single();

      AppLogger.info(
          'Service detail data fetched successfully: ${response.keys}');
      return ServiceDetail.fromJson(response);
    } catch (e) {
      AppLogger.error('Error fetching service detail: $e');
      // 直接抛出错误，不返回Mock数据
      rethrow;
    }
  }

  /// 获取所有服务详情数据（多个）
  static Future<List<ServiceDetail>> getAllServiceDetails(
      String serviceId) async {
    try {
      AppLogger.info('🔄 开始从API获取服务详情数据，serviceId: $serviceId');

      final response = await _supabase
          .from('service_details')
          .select('''
            id,
            service_id,
            pricing_type,
            price,
            currency,
            negotiation_details,
            duration_type,
            duration,
            images_url,
            videos_url,
            tags,
            service_area_codes,
            platform_service_fee_rate,
            min_platform_service_fee,
            service_details_json,
            extra_data,
            promotion_start,
            promotion_end,
            view_count,
            favorite_count,
            order_count,
            verification_status,
            verification_documents,
            created_at,
            updated_at,
            category,
            name,
            sub_category,
            is_available,
            sort_order,
            current_stock,
            max_stock,
            attributes,
            business_rules
          ''')
          .eq('service_id', serviceId)
          .eq('is_available', true)
          .order('sort_order', ascending: true)
          .order('category', ascending: true);

      AppLogger.info('✅ 成功从API获取到 ${response.length} 个服务详情数据');

      if (response.isEmpty) {
        AppLogger.warning('⚠️ API没有返回数据，serviceId: $serviceId');
        return [];
      }

      // 记录获取到的数据详情
      for (var item in response.take(3)) {
        // 只记录前3个，避免日志过长
        AppLogger.info(
            '📋 服务详情: ${item['name']} - ${item['price']} ${item['currency']} - 分类: ${item['category']}');
      }
      if (response.length > 3) {
        AppLogger.info('... 还有 ${response.length - 3} 个服务详情');
      }

      return response.map((json) => ServiceDetail.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('❌ 从API获取服务详情数据失败: $e');
      // 返回空列表而不是Mock数据，让UI显示"暂无数据"
      return [];
    }
  }

  /// 获取提供商资料 - 使用全局ProviderQueryManager
  static Future<ProviderProfile> getProviderProfile(String providerId) async {
    AppLogger.info('🔍 ServiceDetailApiService调用全局Provider查询: $providerId');
    
    final providerProfile = await ProviderQueryManager.getProviderProfile(providerId);
    
    if (providerProfile == null) {
      throw Exception('Provider not found: $providerId');
    }
    
    AppLogger.info('✅ ServiceDetailApiService获取Provider成功: $providerId');
    return providerProfile;
  }

  /// 获取服务评价
  static Future<List<Review>> getServiceReviews(String serviceId) async {
    try {
      AppLogger.info('🔍 开始获取服务评价 - serviceId: $serviceId');
      
      final response = await _supabase
          .from('reviews')
          .select('''
            id,
            order_id,
            reviewer_id,
            reviewee_id,
            service_id,
            review_type,
            source_description,
            overall_rating,
            quality_rating,
            service_rating,
            value_rating,
            atmosphere_rating,
            title,
            content,
            images,
            videos,
            tags,
            categories,
            status,
            is_anonymous,
            is_verified,
            helpful_count,
            total_votes,
            report_count,
            provider_response,
            provider_response_at,
            created_at,
            updated_at,
            published_at
          ''')
          .eq('service_id', serviceId)
          .eq('status', 'published')
          .order('created_at', ascending: false);

      AppLogger.info('📊 评价查询结果: ${response.length} 条记录');
      
      if (response.isEmpty) {
        AppLogger.info('📝 该服务暂无评价');
        return [];
      }

      // 为每个review获取reviewer信息
      final reviews = <Review>[];
      for (final json in response) {
        try {
          // 获取reviewer信息 - reviewer_id引用的是auth.users表
          final reviewerId = json['reviewer_id'];
          Map<String, dynamic>? reviewerResponse;
          
          try {
            // 先尝试从user_profiles表获取信息
            reviewerResponse = await _supabase
                .from('user_profiles')
                .select('display_name, avatar_url')
                .eq('id', reviewerId)
                .maybeSingle();
          } catch (e) {
            AppLogger.warning('从user_profiles获取reviewer信息失败: $e');
            // 如果失败，使用默认信息
            reviewerResponse = {
              'display_name': 'Anonymous User',
              'avatar_url': null,
            };
          }
          
          // 将reviewer信息添加到json中
          json['reviewer'] = reviewerResponse;
          
          final review = Review.fromJson(json);
          reviews.add(review);
        } catch (e) {
          AppLogger.error('获取reviewer信息失败: $e');
          // 即使获取reviewer信息失败，也创建review对象
          final review = Review.fromJson(json);
          reviews.add(review);
        }
      }
      
      AppLogger.info('✅ 成功获取 ${reviews.length} 条评价');
      return reviews;
      
    } catch (e) {
      AppLogger.error('❌ 获取服务评价失败: $e');
      // 返回空列表而不是抛出错误，因为评价不是必需的
      return [];
    }
  }

  /// 获取相似服务
  static Future<List<Service>> getSimilarServices(
      String serviceId, String categoryId) async {
    try {
      final response = await _supabase
          .from('services')
          .select('''
            *,
            provider_profiles!services_provider_id_fkey(
              id,
              display_name,
              avatar_url,
              rating,
              review_count
            )
          ''')
          .eq('category_level1_id', categoryId)
          .neq('id', serviceId)
          .eq('status', 'active')
          .order('average_rating', ascending: false)
          .limit(6);

      return response.map((json) => Service.fromJson(json)).toList();
    } catch (e) {
      AppLogger.info('Error fetching similar services: $e');
      return [];
    }
  }

  /// 获取服务统计数据
  static Future<Map<String, dynamic>> getServiceStats(String serviceId) async {
    try {
      // 获取服务详情统计
      final detailsResponse = await _supabase
          .from('service_details')
          .select('id, category, is_available')
          .eq('service_id', serviceId);

      // 获取评价统计
      final reviewsResponse = await _supabase
          .from('reviews')
          .select('rating')
          .eq('service_id', serviceId);

      // 计算统计数据
      final totalDetails = detailsResponse.length;
      final availableDetails =
          detailsResponse.where((d) => d['is_available'] == true).length;
      final totalReviews = reviewsResponse.length;

      double averageRating = 0.0;
      if (reviewsResponse.isNotEmpty) {
        final totalRating = reviewsResponse.fold<double>(
            0.0, (sum, review) => sum + (review['rating'] as num));
        averageRating = totalRating / totalReviews;
      }

      return {
        'totalDetails': totalDetails,
        'availableDetails': availableDetails,
        'totalReviews': totalReviews,
        'averageRating': averageRating,
        'categories':
            detailsResponse.map((d) => d['category']).toSet().toList(),
      };
    } catch (e) {
      AppLogger.error('Error fetching service stats: $e');
      return {
        'totalDetails': 0,
        'availableDetails': 0,
        'totalReviews': 0,
        'averageRating': 0.0,
        'categories': [],
      };
    }
  }

  /// 根据category获取服务详情（通用方法）
  /// 用于获取特定类别的服务详情，如菜单项、服务套餐、库存项等
  static Future<List<ServiceDetail>> fetchServiceDetailsByCategory({
    required String serviceId,
    required String category,
  }) async {
    try {
      AppLogger.info('🔄 开始获取服务详情 - serviceId: $serviceId, category: $category');

      final response = await _supabase
          .from('service_details')
          .select('''
            id,
            service_id,
            category,
            sub_category,
            name,
            price,
            currency,
            pricing_type,
            duration,
            is_available,
            sort_order,
            current_stock,
            max_stock,
            images_url,
            videos_url,
            tags,
            service_area_codes,
            attributes,
            business_rules,
            platform_service_fee_rate,
            min_platform_service_fee,
            extra_data,
            promotion_start,
            promotion_end,
            view_count,
            favorite_count,
            order_count,
            verification_status,
            verification_documents,
            created_at,
            updated_at
          ''')
          .eq('service_id', serviceId)
          .eq('category', category)
          .eq('is_available', true)
          .order('sort_order', ascending: true);

      AppLogger.info('✅ 成功获取 ${response.length} 个 $category 数据');

      if (response.isEmpty) {
        AppLogger.warning('⚠️  没有找到 category=$category 的数据');
        return [];
      }

      // 记录前3条数据的详情
      for (var item in response.take(3)) {
        AppLogger.info(
            '📋 详情: ${item['name']} - ${item['price']} ${item['currency']}');
      }
      if (response.length > 3) {
        AppLogger.info('... 还有 ${response.length - 3} 条数据');
      }

      return response.map((json) => ServiceDetail.fromJson(json)).toList();

    } catch (e) {
      AppLogger.error('❌ 获取服务详情失败 - category: $category, error: $e');
      // 返回空列表而不是抛出错误，让UI显示"暂无数据"
      return [];
    }
  }
}

// 用户资料模型（用于评价）
class UserProfile {
  final String id;
  final String displayName;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.displayName,
    this.avatarUrl,
  });
}
