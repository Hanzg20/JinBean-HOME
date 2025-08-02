import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

/// 服务状态枚举 - 根据设计文档定义
enum ServiceStatus {
  active,      // Available for booking
  inactive,    // Temporarily unavailable
  draft,       // Under development
  archived     // No longer offered
}

/// 服务模型 - 根据设计文档定义
class Service {
  final String id;
  final String providerId;
  final String title;
  final String description;
  final String categoryLevel1Id;
  final String categoryLevel2Id;
  final ServiceStatus status;
  final double averageRating;
  final int reviewCount;
  final double price;
  final String? location;
  final List<String> imagesUrl;
  final Map<String, dynamic>? extraData;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.providerId,
    required this.title,
    required this.description,
    required this.categoryLevel1Id,
    required this.categoryLevel2Id,
    required this.status,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.price = 0.0,
    this.location,
    this.imagesUrl = const [],
    this.extraData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] ?? '',
      providerId: map['provider_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      categoryLevel1Id: map['category_level1_id'] ?? '',
      categoryLevel2Id: map['category_level2_id'] ?? '',
      status: _parseServiceStatus(map['status']),
      averageRating: (map['average_rating'] ?? 0.0).toDouble(),
      reviewCount: map['review_count'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
      location: map['location'],
      imagesUrl: List<String>.from(map['images_url'] ?? []),
      extraData: map['extra_data'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'provider_id': providerId,
      'title': title,
      'description': description,
      'category_level1_id': categoryLevel1Id,
      'category_level2_id': categoryLevel2Id,
      'status': status.name,
      'average_rating': averageRating,
      'review_count': reviewCount,
      'price': price,
      'location': location,
      'images_url': imagesUrl,
      'extra_data': extraData,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static ServiceStatus _parseServiceStatus(String? status) {
    switch (status) {
      case 'active':
        return ServiceStatus.active;
      case 'inactive':
        return ServiceStatus.inactive;
      case 'draft':
        return ServiceStatus.draft;
      case 'archived':
        return ServiceStatus.archived;
      default:
        return ServiceStatus.draft;
    }
  }
}

class ServiceManagementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 获取Provider的所有服务
  Future<List<Service>> getServices({int limit = 50}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ServiceManagementService] No user ID available');
        return [];
      }

      final response = await _supabase
          .from('services')
          .select('*')
          .eq('provider_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map<Service>((map) => Service.fromMap(map)).toList();
    } catch (e) {
      AppLogger.error('[ServiceManagementService] Error getting services: $e');
      return [];
    }
  }

  /// 根据状态获取服务
  Future<List<Service>> getServicesByStatus(ServiceStatus status, {int limit = 50}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ServiceManagementService] No user ID available');
        return [];
      }

      final response = await _supabase
          .from('services')
          .select('*')
          .eq('provider_id', userId)
          .eq('status', status.name)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map<Service>((map) => Service.fromMap(map)).toList();
    } catch (e) {
      AppLogger.error('[ServiceManagementService] Error getting services by status: $e');
      return [];
    }
  }

  /// 创建新服务
  Future<bool> createService(Service service) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ServiceManagementService] No user ID available');
        return false;
      }

      await _supabase
          .from('services')
          .insert(service.toMap());

      AppLogger.info('[ServiceManagementService] Service created successfully');
      return true;
    } catch (e) {
      AppLogger.error('[ServiceManagementService] Error creating service: $e');
      return false;
    }
  }

  /// 更新服务
  Future<bool> updateService(Service service) async {
    try {
      await _supabase
          .from('services')
          .update(service.toMap())
          .eq('id', service.id);

      AppLogger.info('[ServiceManagementService] Service ${service.id} updated successfully');
      return true;
    } catch (e) {
      AppLogger.error('[ServiceManagementService] Error updating service: $e');
      return false;
    }
  }

  /// 删除服务
  Future<bool> deleteService(String serviceId) async {
    try {
      await _supabase
          .from('services')
          .delete()
          .eq('id', serviceId);

      AppLogger.info('[ServiceManagementService] Service $serviceId deleted successfully');
      return true;
    } catch (e) {
      AppLogger.error('[ServiceManagementService] Error deleting service: $e');
      return false;
    }
  }

  /// 获取服务统计信息
  Future<Map<String, dynamic>> getServiceStatistics() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ServiceManagementService] No user ID available');
        return {};
      }

      // 获取所有服务
      final allServicesResponse = await _supabase
          .from('services')
          .select('id, status, review_count, average_rating')
          .eq('provider_id', userId);

      // 计算统计信息
      final totalServices = allServicesResponse.length;
      final activeServices = allServicesResponse.where((s) => s['status'] == 'active').length;
      final inactiveServices = allServicesResponse.where((s) => s['status'] == 'inactive').length;
      final draftServices = allServicesResponse.where((s) => s['status'] == 'draft').length;
      
      // 计算平均评分
      final totalRating = allServicesResponse.fold<double>(0.0, (sum, s) => sum + (s['average_rating'] ?? 0.0));
      final averageRating = totalServices > 0 ? totalRating / totalServices : 0.0;
      
      // 计算总评论数
      final totalReviews = allServicesResponse.fold<int>(0, (sum, s) => sum + (s['review_count'] as int? ?? 0));
      
      // 获取热门服务（按评论数排序）
      final topServices = allServicesResponse
          .where((s) => s['status'] == 'active')
          .toList()
        ..sort((a, b) => (b['review_count'] ?? 0).compareTo(a['review_count'] ?? 0));

      return {
        'total_services': totalServices,
        'active_services': activeServices,
        'inactive_services': inactiveServices,
        'draft_services': draftServices,
        'average_rating': averageRating,
        'total_reviews': totalReviews,
        'top_services': topServices.take(5).toList(),
      };
    } catch (e) {
      AppLogger.error('[ServiceManagementService] Error getting service statistics: $e');
      return {};
    }
  }

  /// 更新服务状态
  Future<bool> updateServiceStatus(String serviceId, ServiceStatus status) async {
    try {
      await _supabase
          .from('services')
          .update({
            'status': status.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', serviceId);

      AppLogger.info('[ServiceManagementService] Service $serviceId status updated to ${status.name}');
      return true;
    } catch (e) {
      AppLogger.error('[ServiceManagementService] Error updating service status: $e');
      return false;
    }
  }

  /// 获取服务详情
  Future<Service?> getServiceDetails(String serviceId) async {
    try {
      final response = await _supabase
          .from('services')
          .select('*')
          .eq('id', serviceId)
          .single();

      return Service.fromMap(response);
    } catch (e) {
      AppLogger.error('[ServiceManagementService] Error getting service details: $e');
      return null;
    }
  }

  /// 搜索服务
  Future<List<Service>> searchServices(String query, {int limit = 50}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ServiceManagementService] No user ID available');
        return [];
      }

      final response = await _supabase
          .from('services')
          .select('*')
          .eq('provider_id', userId)
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map<Service>((map) => Service.fromMap(map)).toList();
    } catch (e) {
      AppLogger.error('[ServiceManagementService] Error searching services: $e');
      return [];
    }
  }

  /// 获取服务分类统计
  Future<Map<String, int>> getServiceCategoryStatistics() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ServiceManagementService] No user ID available');
        return {};
      }

      final response = await _supabase
          .from('services')
          .select('category_level1_id')
          .eq('provider_id', userId)
          .eq('status', 'active');

      final Map<String, int> categoryStats = {};
      for (final service in response) {
        final categoryId = service['category_level1_id'] ?? 'unknown';
        categoryStats[categoryId] = (categoryStats[categoryId] ?? 0) + 1;
      }

      return categoryStats;
    } catch (e) {
      AppLogger.error('[ServiceManagementService] Error getting category statistics: $e');
      return {};
    }
  }
} 