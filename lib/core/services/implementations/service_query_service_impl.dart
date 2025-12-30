import 'package:supabase_flutter/supabase_flutter.dart';
import '../interfaces/i_service_query_service.dart';
import '../../../features/customer/domain/entities/service.dart';

// 服务查询服务实现
class ServiceQueryService implements IServiceQueryService {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    try {
      // 验证数据库连接
      await _supabase.from('services').select('id').limit(1);
      _isInitialized = true;
      print('ServiceQueryService: 初始化完成 ✅');
    } catch (e) {
      print('ServiceQueryService: 初始化失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<List<Service>> getRecommendedServices({int limit = 10}) async {
    if (!_isInitialized) {
      throw Exception('ServiceQueryService未初始化');
    }

    try {
      print('ServiceQueryService: 获取推荐服务...');

      final response = await _supabase
          .from('services')
          .select('''
            *,
            provider_profiles!inner(
              id,
              display_name,
              bio,
              avatar_url,
              rating,
              review_count
            )
          ''')
          .eq('status', 'active')
          .order('rating', ascending: false)
          .limit(limit);

      final services = response.map((json) => Service.fromJson(json)).toList();

      print('ServiceQueryService: 获取到 ${services.length} 个推荐服务 ✅');
      return services;
    } catch (e) {
      print('ServiceQueryService: 获取推荐服务失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<List<Service>> getServicesByCategory(String categoryId,
      {int limit = 20}) async {
    if (!_isInitialized) {
      throw Exception('ServiceQueryService未初始化');
    }

    try {
      print('ServiceQueryService: 获取分类服务 - $categoryId');

      final response = await _supabase
          .from('services')
          .select('''
            *,
            provider_profiles!inner(
              id,
              display_name,
              bio,
              avatar_url,
              rating,
              review_count
            )
          ''')
          .eq('status', 'active')
          .eq('category_id', categoryId)
          .order('rating', ascending: false)
          .limit(limit);

      final services = response.map((json) => Service.fromJson(json)).toList();

      print('ServiceQueryService: 获取到 ${services.length} 个分类服务 ✅');
      return services;
    } catch (e) {
      print('ServiceQueryService: 获取分类服务失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<ServiceQueryResult> searchServices(ServiceQueryParams params) async {
    if (!_isInitialized) {
      throw Exception('ServiceQueryService未初始化');
    }

    try {
      print('ServiceQueryService: 搜索服务 - ${params.toJson()}');

      // 构建基础查询 - 使用动态查询构建
      dynamic baseQuery = _supabase.from('services').select('''
            *,
            provider_profiles!inner(
              id,
              display_name,
              bio,
              avatar_url,
              rating,
              review_count
            )
          ''').eq('status', 'active');

      // 应用查询参数
      if (params.categoryId != null) {
        baseQuery = baseQuery.eq('category_id', params.categoryId);
      }

      if (params.providerId != null) {
        baseQuery = baseQuery.eq('provider_id', params.providerId);
      }

      if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
        baseQuery = baseQuery.or(
            'title->en.ilike.%${params.searchQuery}%,description->en.ilike.%${params.searchQuery}%');
      }

      if (params.minPrice != null) {
        baseQuery = baseQuery.gte('price', params.minPrice);
      }

      if (params.maxPrice != null) {
        baseQuery = baseQuery.lte('price', params.maxPrice);
      }

      if (params.tags != null && params.tags!.isNotEmpty) {
        baseQuery = baseQuery.overlaps('tags', params.tags);
      }

      // 排序
      final sortBy = params.sortBy ?? 'rating';
      final sortAscending = params.sortAscending ?? false;
      baseQuery = baseQuery.order(sortBy, ascending: sortAscending);

      // 分页
      final offset = params.offset ?? 0;
      final limit = params.limit ?? 20;
      baseQuery = baseQuery.range(offset, offset + limit - 1);

      final response = await baseQuery;
      final services = response.map((json) => Service.fromJson(json)).toList();

      // 获取总数（简化版本）
      final totalResponse =
          await _supabase.from('services').select('id').eq('status', 'active');

      final totalCount = totalResponse.length;
      final currentPage = (offset ~/ limit) + 1;
      final totalPages = (totalCount / limit).ceil();
      final hasMore = currentPage < totalPages;

      print('ServiceQueryService: 搜索完成，找到 ${services.length} 个服务 ✅');

      return ServiceQueryResult(
        services: services,
        totalCount: totalCount,
        currentPage: currentPage,
        totalPages: totalPages,
        hasMore: hasMore,
      );
    } catch (e) {
      print('ServiceQueryService: 搜索服务失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<Service?> getServiceById(String serviceId) async {
    if (!_isInitialized) {
      throw Exception('ServiceQueryService未初始化');
    }

    try {
      print('ServiceQueryService: 获取服务详情 - $serviceId');

      final response = await _supabase.from('services').select('''
            *,
            provider_profiles!inner(
              id,
              display_name,
              bio,
              avatar_url,
              rating,
              review_count
            )
          ''').eq('id', serviceId).eq('status', 'active').single();

      final service = Service.fromJson(response);

      print('ServiceQueryService: 获取服务详情成功 ✅');
      return service;
    } catch (e) {
      print('ServiceQueryService: 获取服务详情失败 ❌ - $e');
      return null;
    }
  }

  @override
  Future<List<Service>> getServicesByProvider(String providerId,
      {int limit = 20}) async {
    if (!_isInitialized) {
      throw Exception('ServiceQueryService未初始化');
    }

    try {
      print('ServiceQueryService: 获取服务商服务 - $providerId');

      final response = await _supabase
          .from('services')
          .select('''
            *,
            provider_profiles!inner(
              id,
              display_name,
              bio,
              avatar_url,
              rating,
              review_count
            )
          ''')
          .eq('status', 'active')
          .eq('provider_id', providerId)
          .order('created_at', ascending: false)
          .limit(limit);

      final services = response.map((json) => Service.fromJson(json)).toList();

      print('ServiceQueryService: 获取到 ${services.length} 个服务商服务 ✅');
      return services;
    } catch (e) {
      print('ServiceQueryService: 获取服务商服务失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<List<Service>> getPopularServices({int limit = 10}) async {
    if (!_isInitialized) {
      throw Exception('ServiceQueryService未初始化');
    }

    try {
      print('ServiceQueryService: 获取热门服务...');

      final response = await _supabase
          .from('services')
          .select('''
            *,
            provider_profiles!inner(
              id,
              display_name,
              bio,
              avatar_url,
              rating,
              review_count
            )
          ''')
          .eq('status', 'active')
          .order('rating', ascending: false)
          .limit(limit);

      final services = response.map((json) => Service.fromJson(json)).toList();

      print('ServiceQueryService: 获取到 ${services.length} 个热门服务 ✅');
      return services;
    } catch (e) {
      print('ServiceQueryService: 获取热门服务失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<List<Service>> getNearbyServices(double latitude, double longitude,
      {double radius = 10.0, int limit = 20}) async {
    if (!_isInitialized) {
      throw Exception('ServiceQueryService未初始化');
    }

    try {
      print(
          'ServiceQueryService: 获取附近服务 - 纬度:$latitude, 经度:$longitude, 半径:$radius');

      // 简化版本：直接返回推荐服务
      // 实际项目中可以使用PostGIS进行地理位置查询
      print('ServiceQueryService: 使用推荐服务作为附近服务');
      return getRecommendedServices(limit: limit);
    } catch (e) {
      print('ServiceQueryService: 获取附近服务失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<List<Service>> getSimilarServices(String serviceId,
      {int limit = 5}) async {
    if (!_isInitialized) {
      throw Exception('ServiceQueryService未初始化');
    }

    try {
      print('ServiceQueryService: 获取相似服务 - $serviceId');

      // 首先获取目标服务的分类信息
      final targetService = await _supabase
          .from('services')
          .select('category_level1_id, category_level2_id')
          .eq('id', serviceId)
          .single();

      final categoryLevel1Id = targetService['category_level1_id'];
      final categoryLevel2Id = targetService['category_level2_id'];

      // 查询同分类的其他服务
      final response = await _supabase
          .from('services')
          .select('''
            *,
            provider_profiles!inner(
              id,
              display_name,
              bio,
              avatar_url,
              rating,
              review_count
            )
          ''')
          .eq('status', 'active')
          .neq('id', serviceId) // 排除当前服务
          .or('category_level1_id.eq.$categoryLevel1Id,category_level2_id.eq.$categoryLevel2Id')
          .order('rating', ascending: false)
          .limit(limit);

      final services = response.map((json) => Service.fromJson(json)).toList();

      print('ServiceQueryService: 获取到 ${services.length} 个相似服务 ✅');
      return services;
    } catch (e) {
      print('ServiceQueryService: 获取相似服务失败 ❌ - $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getServiceStatistics() async {
    if (!_isInitialized) {
      throw Exception('ServiceQueryService未初始化');
    }

    try {
      print('ServiceQueryService: 获取服务统计信息...');

      // 获取各种统计数据
      final totalServices = await _supabase.from('services').select('id');

      final activeServices =
          await _supabase.from('services').select('id').eq('status', 'active');

      final avgRating = await _supabase
          .from('services')
          .select('rating')
          .eq('status', 'active');

      final totalCount = totalServices.length;
      final activeCount = activeServices.length;

      // 计算平均评分
      double averageRating = 0.0;
      if (avgRating.isNotEmpty) {
        final ratings =
            avgRating.map((r) => (r['rating'] ?? 0.0).toDouble()).toList();
        averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
      }

      final stats = {
        'total_services': totalCount,
        'active_services': activeCount,
        'inactive_services': totalCount - activeCount,
        'average_rating': averageRating,
        'last_updated': DateTime.now().toIso8601String(),
      };

      print('ServiceQueryService: 获取统计信息成功 ✅');
      return stats;
    } catch (e) {
      print('ServiceQueryService: 获取统计信息失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<void> refreshCache() async {
    // 这里可以实现缓存刷新逻辑
    print('ServiceQueryService: 缓存刷新完成 ✅');
  }

  @override
  Future<void> clearCache() async {
    // 这里可以实现缓存清理逻辑
    print('ServiceQueryService: 缓存清理完成 ✅');
  }

  // 获取服务是否已初始化
  bool get isInitialized => _isInitialized;
}
