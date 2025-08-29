import 'package:get/get.dart';
import '../../models/service_detail.dart';

// 服务详情查询参数
class ServiceDetailQueryParams {
  final String? category;
  final String? subCategory;
  final bool? isAvailable;
  final List<String>? tags;
  final String? type;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final bool? sortAscending;

  ServiceDetailQueryParams({
    this.category,
    this.subCategory,
    this.isAvailable,
    this.tags,
    this.type,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortAscending,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'sub_category': subCategory,
      'is_available': isAvailable,
      'tags': tags,
      'type': type,
      'limit': limit,
      'offset': offset,
      'sort_by': sortBy,
      'sort_ascending': sortAscending,
    };
  }
}

// 服务详情服务接口
abstract class IServiceDetailService {
  /// 初始化服务
  Future<void> initialize();

  /// 获取服务的所有详情
  Future<List<ServiceDetail>> getServiceDetails(String serviceId);

  /// 根据分类获取服务详情
  Future<List<ServiceDetail>> getServiceDetailsByCategory(
      String serviceId, String category);

  /// 获取分组后的服务详情
  Future<Map<String, List<ServiceDetail>>> getServiceDetailsGrouped(
      String serviceId);

  /// 根据ID获取服务详情
  Future<ServiceDetail?> getServiceDetailById(String detailId);

  /// 根据查询参数获取服务详情
  Future<List<ServiceDetail>> getServiceDetailsByParams(
      String serviceId, ServiceDetailQueryParams params);

  /// 获取服务详情统计信息
  Future<Map<String, dynamic>> getServiceDetailStatistics(String serviceId);

  /// 检查服务详情可用性
  Future<bool> checkServiceDetailAvailability(String detailId);

  /// 更新服务详情库存
  Future<bool> updateServiceDetailStock(String detailId, int newStock);

  /// 获取服务详情业务规则
  Future<Map<String, dynamic>> getServiceDetailBusinessRules(String detailId);

  /// 验证服务详情属性
  Future<bool> validateServiceDetailAttributes(
      String detailId, Map<String, dynamic> attributes);

  /// 刷新服务详情缓存
  Future<void> refreshCache(String serviceId);

  /// 清除服务详情缓存
  Future<void> clearCache(String serviceId);
}
