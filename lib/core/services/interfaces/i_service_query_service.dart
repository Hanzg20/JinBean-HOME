import 'package:get/get.dart';
import '../../models/service.dart';

// 服务查询参数
class ServiceQueryParams {
  final String? categoryId;
  final String? providerId;
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final String? location;
  final double? radius;
  final List<String>? tags;
  final bool? isActive;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final bool? sortAscending;

  ServiceQueryParams({
    this.categoryId,
    this.providerId,
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.location,
    this.radius,
    this.tags,
    this.isActive,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortAscending,
  });

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'provider_id': providerId,
      'search_query': searchQuery,
      'min_price': minPrice,
      'max_price': maxPrice,
      'location': location,
      'radius': radius,
      'tags': tags,
      'is_active': isActive,
      'limit': limit,
      'offset': offset,
      'sort_by': sortBy,
      'sort_ascending': sortAscending,
    };
  }
}

// 服务查询结果
class ServiceQueryResult {
  final List<Service> services;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  ServiceQueryResult({
    required this.services,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
  });
}

// 服务查询服务接口
abstract class IServiceQueryService {
  /// 初始化服务
  Future<void> initialize();
  
  /// 获取推荐服务
  Future<List<Service>> getRecommendedServices({int limit = 10});
  
  /// 根据分类获取服务
  Future<List<Service>> getServicesByCategory(String categoryId, {int limit = 20});
  
  /// 搜索服务
  Future<ServiceQueryResult> searchServices(ServiceQueryParams params);
  
  /// 根据ID获取服务
  Future<Service?> getServiceById(String serviceId);
  
  /// 根据服务商获取服务
  Future<List<Service>> getServicesByProvider(String providerId, {int limit = 20});
  
  /// 获取热门服务
  Future<List<Service>> getPopularServices({int limit = 10});
  
  /// 获取附近服务
  Future<List<Service>> getNearbyServices(double latitude, double longitude, {double radius = 10.0, int limit = 20});
  
  /// 获取服务统计信息
  Future<Map<String, dynamic>> getServiceStatistics();
  
  /// 刷新服务缓存
  Future<void> refreshCache();
  
  /// 清除服务缓存
  Future<void> clearCache();
}
