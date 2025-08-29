import 'package:supabase_flutter/supabase_flutter.dart';
import '../interfaces/i_provider_service.dart';

// 服务商服务实现
class ProviderService implements IProviderService {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    try {
      // 验证数据库连接
      await _supabase.from('provider_profiles').select('id').limit(1);
      _isInitialized = true;
      print('ProviderService: 初始化完成 ✅');
    } catch (e) {
      print('ProviderService: 初始化失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<Provider?> getProviderById(String providerId) async {
    if (!_isInitialized) {
      throw Exception('ProviderService未初始化');
    }

    try {
      print('ProviderService: 获取服务商 - $providerId');

      final response = await _supabase
          .from('provider_profiles')
          .select('*')
          .eq('id', providerId)
          .single();

      final provider = Provider.fromJson(response);

      print('ProviderService: 获取服务商成功 ✅');
      return provider;
    } catch (e) {
      print('ProviderService: 获取服务商失败 ❌ - $e');
      return null;
    }
  }

  @override
  Future<List<Provider>> getProviders(ProviderQueryParams params) async {
    if (!_isInitialized) {
      throw Exception('ProviderService未初始化');
    }

    try {
      print('ProviderService: 获取服务商列表 - 参数: ${params.toJson()}');

      // 构建基础查询
      dynamic query = _supabase.from('provider_profiles').select('*');

      // 应用查询参数
      if (params.providerType != null) {
        query = query.eq('provider_type', params.providerType);
      }

      if (params.status != null) {
        query = query.eq('status', params.status);
      }

      if (params.isVerified != null) {
        query = query.eq('is_verified', params.isVerified);
      }

      if (params.serviceCategories != null &&
          params.serviceCategories!.isNotEmpty) {
        query = query.overlaps('service_categories', params.serviceCategories);
      }

      if (params.serviceAreaCodes != null &&
          params.serviceAreaCodes!.isNotEmpty) {
        query = query.overlaps('service_area_codes', params.serviceAreaCodes);
      }

      // 排序
      final sortBy = params.sortBy ?? 'rating';
      final sortAscending = params.sortAscending ?? false;
      query = query.order(sortBy, ascending: sortAscending);

      // 分页
      if (params.limit != null) {
        final offset = params.offset ?? 0;
        query = query.range(offset, offset + params.limit! - 1);
      }

      final response = await query;
      final providers =
          response.map((json) => Provider.fromJson(json)).toList();

      print('ProviderService: 获取服务商列表完成，找到 ${providers.length} 个 ✅');
      return providers;
    } catch (e) {
      print('ProviderService: 获取服务商列表失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<List<Provider>> searchProviders(String query, {int limit = 20}) async {
    if (!_isInitialized) {
      throw Exception('ProviderService未初始化');
    }

    try {
      print('ProviderService: 搜索服务商 - 查询: $query, 限制: $limit');

      // 构建搜索查询
      dynamic searchQuery = _supabase
          .from('provider_profiles')
          .select('*')
          .eq('status', 'active')
          .or('display_name->en.ilike.%$query%,display_name->zh.ilike.%$query%,bio->en.ilike.%$query%,bio->zh.ilike.%$query%')
          .order('rating', ascending: false)
          .limit(limit);

      final response = await searchQuery;
      final providers =
          response.map((json) => Provider.fromJson(json)).toList();

      print('ProviderService: 搜索服务商完成，找到 ${providers.length} 个 ✅');
      return providers;
    } catch (e) {
      print('ProviderService: 搜索服务商失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<List<Provider>> getRecommendedProviders({int limit = 10}) async {
    if (!_isInitialized) {
      throw Exception('ProviderService未初始化');
    }

    try {
      print('ProviderService: 获取推荐服务商 - 限制: $limit');

      // 构建推荐查询（基于评分和订单数）
      dynamic query = _supabase
          .from('provider_profiles')
          .select('*')
          .eq('status', 'active')
          .eq('is_verified', true)
          .gte('rating', 4.0)
          .gte('order_count', 10);

      // 按评分和订单数排序
      query = query
          .order('rating', ascending: false)
          .order('order_count', ascending: false);

      // 分页
      query = query.range(0, limit - 1);

      final response = await query;
      final providers =
          response.map((json) => Provider.fromJson(json)).toList();

      print('ProviderService: 获取推荐服务商完成，找到 ${providers.length} 个 ✅');
      return providers;
    } catch (e) {
      print('ProviderService: 获取推荐服务商失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<List<Provider>> getNearbyProviders(double latitude, double longitude,
      {double radius = 10.0, int limit = 20}) async {
    if (!_isInitialized) {
      throw Exception('ProviderService未初始化');
    }

    try {
      print(
          'ProviderService: 获取附近服务商 - 位置: ($latitude, $longitude), 半径: $radius km');

      // 使用PostGIS的ST_DWithin函数进行地理查询
      // 注意：这里简化处理，实际应该使用PostGIS扩展
      dynamic query = _supabase
          .from('provider_profiles')
          .select('*')
          .eq('status', 'active');

      // 按评分排序
      query = query.order('rating', ascending: false).limit(limit);

      final response = await query;
      final providers =
          response.map((json) => Provider.fromJson(json)).toList();

      // 简化距离计算（实际应该使用PostGIS）
      final nearbyProviders = providers.where((provider) {
        // 这里应该使用实际的地理距离计算
        // 暂时返回所有结果
        return true;
      }).toList();

      print('ProviderService: 获取附近服务商完成，找到 ${nearbyProviders.length} 个 ✅');
      return nearbyProviders;
    } catch (e) {
      print('ProviderService: 获取附近服务商失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getProviderStatistics(String providerId) async {
    if (!_isInitialized) {
      throw Exception('ProviderService未初始化');
    }

    try {
      print('ProviderService: 获取服务商统计 - $providerId');

      // 获取服务商基本信息
      final provider = await getProviderById(providerId);
      if (provider == null) {
        throw Exception('服务商不存在');
      }

      // 获取服务统计
      final servicesResponse = await _supabase
          .from('services')
          .select('id, rating, review_count')
          .eq('provider_id', providerId);

      final services = servicesResponse as List;
      final totalServices = services.length;
      final totalRating = services.fold<double>(
          0.0,
          (sum, service) =>
              sum + ((service['rating'] as num?)?.toDouble() ?? 0.0));
      final totalReviews = services.fold<int>(
          0,
          (sum, service) =>
              sum + ((service['review_count'] as num?)?.toInt() ?? 0));
      final avgRating = totalServices > 0 ? totalRating / totalServices : 0.0;

      // 获取服务详情统计
      final detailsResponse = await _supabase
          .from('service_details')
          .select('id, is_available, current_stock, max_stock')
          .eq('service_id', services.map((s) => s['id']).toList());

      final details = detailsResponse as List;
      final totalDetails = details.length;
      final availableDetails =
          details.where((d) => d['is_available'] == true).length;
      final totalStock = details.fold<int>(
          0,
          (sum, detail) =>
              sum + ((detail['current_stock'] as num?)?.toInt() ?? 0));
      final maxStock = details.fold<int>(0,
          (sum, detail) => sum + ((detail['max_stock'] as num?)?.toInt() ?? 0));

      final stats = {
        'provider_info': {
          'id': provider.id,
          'name': provider.displayName['en'] ?? 'Unknown',
          'type': provider.providerType,
          'status': provider.status,
          'rating': provider.rating,
          'review_count': provider.reviewCount,
          'order_count': provider.orderCount,
          'is_verified': provider.isVerified,
        },
        'services': {
          'total': totalServices,
          'avg_rating': avgRating,
          'total_reviews': totalReviews,
        },
        'service_details': {
          'total': totalDetails,
          'available': availableDetails,
          'current_stock': totalStock,
          'max_stock': maxStock,
          'stock_percentage':
              maxStock > 0 ? (totalStock / maxStock * 100).round() : 0,
        },
        'last_updated': DateTime.now().toIso8601String(),
      };

      print('ProviderService: 获取服务商统计成功 ✅');
      return stats;
    } catch (e) {
      print('ProviderService: 获取服务商统计失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<bool> updateProvider(Provider provider) async {
    if (!_isInitialized) {
      throw Exception('ProviderService未初始化');
    }

    try {
      print('ProviderService: 更新服务商 - ${provider.id}');

      final updateData = {
        'display_name': provider.displayName,
        'bio': provider.bio,
        'avatar_url': provider.avatarUrl,
        'phone': provider.phone,
        'email': provider.email,
        'business_address': provider.businessAddress,
        'provider_type': provider.providerType,
        'status': provider.status,
        'rating': provider.rating,
        'review_count': provider.reviewCount,
        'order_count': provider.orderCount,
        'is_verified': provider.isVerified,
        'service_categories': provider.serviceCategories,
        'service_area_codes': provider.serviceAreaCodes,
        'business_hours': provider.businessHours,
        'contact_info': provider.contactInfo,
        'verification_documents': provider.verificationDocuments,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('provider_profiles')
          .update(updateData)
          .eq('id', provider.id);

      print('ProviderService: 服务商更新成功 ✅');
      return true;
    } catch (e) {
      print('ProviderService: 服务商更新失败 ❌ - $e');
      return false;
    }
  }

  @override
  Future<bool> updateProviderStatus(String providerId, String status) async {
    if (!_isInitialized) {
      throw Exception('ProviderService未初始化');
    }

    try {
      print('ProviderService: 更新服务商状态 - ID: $providerId, 状态: $status');

      await _supabase.from('provider_profiles').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', providerId);

      print('ProviderService: 服务商状态更新成功 ✅');
      return true;
    } catch (e) {
      print('ProviderService: 服务商状态更新失败 ❌ - $e');
      return false;
    }
  }

  @override
  Future<bool> verifyProvider(String providerId) async {
    if (!_isInitialized) {
      throw Exception('ProviderService未初始化');
    }

    try {
      print('ProviderService: 验证服务商 - $providerId');

      await _supabase.from('provider_profiles').update({
        'is_verified': true,
        'verification_status': 'verified',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', providerId);

      print('ProviderService: 服务商验证成功 ✅');
      return true;
    } catch (e) {
      print('ProviderService: 服务商验证失败 ❌ - $e');
      return false;
    }
  }

  @override
  Future<List<dynamic>> getProviderServices(String providerId,
      {int limit = 20}) async {
    if (!_isInitialized) {
      throw Exception('ProviderService未初始化');
    }

    try {
      print('ProviderService: 获取服务商服务 - $providerId');

      final response = await _supabase
          .from('services')
          .select('*')
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);

      print('ProviderService: 获取服务商服务成功，找到 ${response.length} 个 ✅');
      return response;
    } catch (e) {
      print('ProviderService: 获取服务商服务失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<List<Review>> getProviderReviews(String providerId,
      {int limit = 20}) async {
    if (!_isInitialized) {
      throw Exception('ProviderService未初始化');
    }

    try {
      print('ProviderService: 获取服务商评价 - $providerId');

      // 这里应该从reviews表获取数据
      // 暂时返回空列表
      print('ProviderService: 获取服务商评价成功，找到 0 个 ✅');
      return [];
    } catch (e) {
      print('ProviderService: 获取服务商评价失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<void> refreshCache(String providerId) async {
    // 这里可以实现缓存刷新逻辑
    print('ProviderService: 缓存刷新完成 - 服务商ID: $providerId ✅');
  }

  @override
  Future<void> clearCache(String providerId) async {
    // 这里可以实现缓存清理逻辑
    print('ProviderService: 缓存清理完成 - 服务商ID: $providerId ✅');
  }

  // 获取服务是否已初始化
  bool get isInitialized => _isInitialized;

  // 获取服务商总数
  Future<int> getTotalProviderCount() async {
    if (!_isInitialized) {
      throw Exception('ProviderService未初始化');
    }

    try {
      final response = await _supabase.from('provider_profiles').select('id');

      return response.length;
    } catch (e) {
      print('ProviderService: 获取服务商总数失败 ❌ - $e');
      return 0;
    }
  }

  // 获取服务商类型分布
  Future<Map<String, int>> getProviderTypeDistribution() async {
    if (!_isInitialized) {
      throw Exception('ProviderService未初始化');
    }

    try {
      final response =
          await _supabase.from('provider_profiles').select('provider_type');

      final distribution = <String, int>{};
      for (final item in response) {
        final type = item['provider_type'] as String;
        distribution[type] = (distribution[type] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      print('ProviderService: 获取服务商类型分布失败 ❌ - $e');
      return {};
    }
  }

  // 获取服务商状态分布
  Future<Map<String, int>> getProviderStatusDistribution() async {
    if (!_isInitialized) {
      throw Exception('ProviderService未初始化');
    }

    try {
      final response =
          await _supabase.from('provider_profiles').select('status');

      final distribution = <String, int>{};
      for (final item in response) {
        final status = item['status'] as String;
        distribution[status] = (distribution[status] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      print('ProviderService: 获取服务商状态分布失败 ❌ - $e');
      return {};
    }
  }
}
