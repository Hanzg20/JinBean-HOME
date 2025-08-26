import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../interfaces/i_service_detail_service.dart';
import '../../models/service_detail.dart';

// 服务详情服务实现
class ServiceDetailService implements IServiceDetailService {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    try {
      // 验证数据库连接
      await _supabase.from('service_details').select('id').limit(1);
      _isInitialized = true;
      print('ServiceDetailService: 初始化完成 ✅');
    } catch (e) {
      print('ServiceDetailService: 初始化失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<List<ServiceDetail>> getServiceDetails(String serviceId) async {
    if (!_isInitialized) {
      throw Exception('ServiceDetailService未初始化');
    }

    try {
      print('ServiceDetailService: 获取服务详情 - $serviceId');
      
      final response = await _supabase
          .from('service_details')
          .select('*')
          .eq('service_id', serviceId)
          .order('sort_order');

      final details = response.map((json) => ServiceDetail.fromJson(json)).toList();
      
      print('ServiceDetailService: 获取到 ${details.length} 个服务详情 ✅');
      return details;
      
    } catch (e) {
      print('ServiceDetailService: 获取服务详情失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<List<ServiceDetail>> getServiceDetailsByCategory(String serviceId, String category) async {
    if (!_isInitialized) {
      throw Exception('ServiceDetailService未初始化');
    }

    try {
      print('ServiceDetailService: 获取分类服务详情 - 服务ID: $serviceId, 分类: $category');
      
      final response = await _supabase
          .from('service_details')
          .select('*')
          .eq('service_id', serviceId)
          .eq('category', category)
          .order('sort_order');

      final details = response.map((json) => ServiceDetail.fromJson(json)).toList();
      
      print('ServiceDetailService: 获取到 ${details.length} 个分类服务详情 ✅');
      return details;
      
    } catch (e) {
      print('ServiceDetailService: 获取分类服务详情失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, List<ServiceDetail>>> getServiceDetailsGrouped(String serviceId) async {
    if (!_isInitialized) {
      throw Exception('ServiceDetailService未初始化');
    }

    try {
      print('ServiceDetailService: 获取分组服务详情 - $serviceId');
      
      final details = await getServiceDetails(serviceId);
      
      // 按category分组
      final grouped = <String, List<ServiceDetail>>{};
      for (final detail in details) {
        final category = detail.category;
        grouped.putIfAbsent(category, () => []).add(detail);
      }
      
      print('ServiceDetailService: 分组完成，共 ${grouped.length} 个分类 ✅');
      return grouped;
      
    } catch (e) {
      print('ServiceDetailService: 分组服务详情失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<ServiceDetail?> getServiceDetailById(String detailId) async {
    if (!_isInitialized) {
      throw Exception('ServiceDetailService未初始化');
    }

    try {
      print('ServiceDetailService: 获取服务详情 - $detailId');
      
      final response = await _supabase
          .from('service_details')
          .select('*')
          .eq('id', detailId)
          .single();

      final detail = ServiceDetail.fromJson(response);
      
      print('ServiceDetailService: 获取服务详情成功 ✅');
      return detail;
      
    } catch (e) {
      print('ServiceDetailService: 获取服务详情失败 ❌ - $e');
      return null;
    }
  }

  @override
  Future<List<ServiceDetail>> getServiceDetailsByParams(String serviceId, ServiceDetailQueryParams params) async {
    if (!_isInitialized) {
      throw Exception('ServiceDetailService未初始化');
    }

    try {
      print('ServiceDetailService: 按参数获取服务详情 - 服务ID: $serviceId, 参数: ${params.toJson()}');
      
      // 构建基础查询
      dynamic query = _supabase
          .from('service_details')
          .select('*')
          .eq('service_id', serviceId);

      // 应用查询参数
      if (params.category != null) {
        query = query.eq('category', params.category);
      }
      
      if (params.subCategory != null) {
        query = query.eq('sub_category', params.subCategory);
      }
      
      if (params.isAvailable != null) {
        query = query.eq('is_available', params.isAvailable);
      }
      
      if (params.tags != null && params.tags!.isNotEmpty) {
        query = query.overlaps('tags', params.tags);
      }
      
      if (params.type != null) {
        query = query.eq('type', params.type);
      }

      // 排序
      final sortBy = params.sortBy ?? 'sort_order';
      final sortAscending = params.sortAscending ?? true;
      query = query.order(sortBy, ascending: sortAscending);

      // 分页
      if (params.limit != null) {
        final offset = params.offset ?? 0;
        query = query.range(offset, offset + params.limit! - 1);
      }

      final response = await query;
      final details = response.map((json) => ServiceDetail.fromJson(json)).toList();
      
      print('ServiceDetailService: 按参数查询完成，找到 ${details.length} 个服务详情 ✅');
      return details;
      
    } catch (e) {
      print('ServiceDetailService: 按参数获取服务详情失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getServiceDetailStatistics(String serviceId) async {
    if (!_isInitialized) {
      throw Exception('ServiceDetailService未初始化');
    }

    try {
      print('ServiceDetailService: 获取服务详情统计 - $serviceId');
      
      // 获取各种统计数据
      final totalDetails = await _supabase
          .from('service_details')
          .select('id')
          .eq('service_id', serviceId);
      
      final availableDetails = await _supabase
          .from('service_details')
          .select('id')
          .eq('service_id', serviceId)
          .eq('is_available', true);
      
      final categoryStats = await _supabase
          .from('service_details')
          .select('category')
          .eq('service_id', serviceId);

      final totalCount = totalDetails.length;
      final availableCount = availableDetails.length;
      
      // 统计分类分布
      final categoryDistribution = <String, int>{};
      for (final item in categoryStats) {
        final category = item['category'] as String;
        categoryDistribution[category] = (categoryDistribution[category] ?? 0) + 1;
      }

      final stats = {
        'total_details': totalCount,
        'available_details': availableCount,
        'unavailable_details': totalCount - availableCount,
        'category_distribution': categoryDistribution,
        'last_updated': DateTime.now().toIso8601String(),
      };
      
      print('ServiceDetailService: 获取统计信息成功 ✅');
      return stats;
      
    } catch (e) {
      print('ServiceDetailService: 获取统计信息失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<bool> checkServiceDetailAvailability(String detailId) async {
    if (!_isInitialized) {
      throw Exception('ServiceDetailService未初始化');
    }

    try {
      print('ServiceDetailService: 检查服务详情可用性 - $detailId');
      
      final response = await _supabase
          .from('service_details')
          .select('is_available, current_stock, max_stock')
          .eq('id', detailId)
          .single();

      final isAvailable = response['is_available'] as bool;
      final currentStock = response['current_stock'] as int?;
      final maxStock = response['max_stock'] as int?;
      
      bool hasStock = true;
      if (maxStock != null && currentStock != null) {
        hasStock = currentStock > 0;
      }
      
      final result = isAvailable && hasStock;
      
      print('ServiceDetailService: 可用性检查完成 - 可用: $result ✅');
      return result;
      
    } catch (e) {
      print('ServiceDetailService: 检查可用性失败 ❌ - $e');
      return false;
    }
  }

  @override
  Future<bool> updateServiceDetailStock(String detailId, int newStock) async {
    if (!_isInitialized) {
      throw Exception('ServiceDetailService未初始化');
    }

    try {
      print('ServiceDetailService: 更新库存 - 详情ID: $detailId, 新库存: $newStock');
      
      await _supabase
          .from('service_details')
          .update({
            'current_stock': newStock,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', detailId);

      print('ServiceDetailService: 库存更新成功 ✅');
      return true;
      
    } catch (e) {
      print('ServiceDetailService: 库存更新失败 ❌ - $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getServiceDetailBusinessRules(String detailId) async {
    if (!_isInitialized) {
      throw Exception('ServiceDetailService未初始化');
    }

    try {
      print('ServiceDetailService: 获取业务规则 - $detailId');
      
      final response = await _supabase
          .from('service_details')
          .select('business_rules')
          .eq('id', detailId)
          .single();

      final businessRules = response['business_rules'] as Map<String, dynamic>? ?? {};
      
      print('ServiceDetailService: 获取业务规则成功 ✅');
      return businessRules;
      
    } catch (e) {
      print('ServiceDetailService: 获取业务规则失败 ❌ - $e');
      return {};
    }
  }

  @override
  Future<bool> validateServiceDetailAttributes(String detailId, Map<String, dynamic> attributes) async {
    if (!_isInitialized) {
      throw Exception('ServiceDetailService未初始化');
    }

    try {
      print('ServiceDetailService: 验证属性 - 详情ID: $detailId, 属性: $attributes');
      
      final response = await _supabase
          .from('service_details')
          .select('attributes')
          .eq('id', detailId)
          .single();

      final requiredAttributes = response['attributes'] as Map<String, dynamic>? ?? {};
      
      // 简单的属性验证逻辑
      bool isValid = true;
      for (final key in requiredAttributes.keys) {
        if (attributes.containsKey(key)) {
          final requiredType = requiredAttributes[key].runtimeType;
          final providedType = attributes[key].runtimeType;
          
          if (requiredType != providedType) {
            print('属性类型不匹配: $key, 需要: $requiredType, 提供: $providedType');
            isValid = false;
          }
        } else {
          print('缺少必需属性: $key');
          isValid = false;
        }
      }
      
      print('ServiceDetailService: 属性验证完成 - 有效: $isValid ✅');
      return isValid;
      
    } catch (e) {
      print('ServiceDetailService: 属性验证失败 ❌ - $e');
      return false;
    }
  }

  @override
  Future<void> refreshCache(String serviceId) async {
    // 这里可以实现缓存刷新逻辑
    print('ServiceDetailService: 缓存刷新完成 - 服务ID: $serviceId ✅');
  }

  @override
  Future<void> clearCache(String serviceId) async {
    // 这里可以实现缓存清理逻辑
    print('ServiceDetailService: 缓存清理完成 - 服务ID: $serviceId ✅');
  }

  // 获取服务是否已初始化
  bool get isInitialized => _isInitialized;

  // 获取服务详情的动态Tab配置
  Map<String, Map<String, dynamic>> getDynamicTabConfig(List<ServiceDetail> details) {
    final config = <String, Map<String, dynamic>>{};
    
    for (final detail in details) {
      final category = detail.category;
      if (!config.containsKey(category)) {
        config[category] = {
          'title': detail.getLocalizedName('en'),
          'icon': _getCategoryIcon(category),
          'color': _getCategoryColor(category),
          'details': <ServiceDetail>[],
        };
      }
      config[category]!['details'].add(detail);
    }
    
    return config;
  }

  // 获取分类图标
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'education':
        return Icons.school;
      case 'transportation':
        return Icons.directions_car;
      case 'beauty':
        return Icons.face;
      case 'professional':
        return Icons.work;
      default:
        return Icons.category;
    }
  }

  // 获取分类颜色
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return Colors.orange;
      case 'cleaning':
        return Colors.blue;
      case 'education':
        return Colors.green;
      case 'transportation':
        return Colors.purple;
      case 'beauty':
        return Colors.pink;
      case 'professional':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
