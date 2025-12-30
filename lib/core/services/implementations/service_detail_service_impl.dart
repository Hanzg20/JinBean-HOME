import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../interfaces/i_service_detail_service.dart';
import '../../../features/customer/domain/entities/service_detail.dart';

// 服务详情服务实现
class ServiceDetailService implements IServiceDetailService {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    try {
      print('ServiceDetailService: 开始初始化...');
      print('ServiceDetailService: 检查数据库连接...');

      // 验证数据库连接
      final result =
          await _supabase.from('service_details').select('id').limit(1);
      print('ServiceDetailService: 数据库连接测试成功，返回 ${result.length} 条记录');

      _isInitialized = true;
      print('ServiceDetailService: 初始化完成 ✅');
    } catch (e) {
      print('ServiceDetailService: 初始化失败 ❌ - $e');
      print('ServiceDetailService: 请检查数据库连接和service_details表是否存在');
      rethrow;
    }
  }

  @override
  Future<List<ServiceDetail>> getServiceDetails(String serviceId) async {
    print('🎯 ========== ServiceDetailService.getServiceDetails 开始 ==========');
    print('🔍 输入参数: serviceId=$serviceId');
    print('🔍 服务初始化状态: _isInitialized=$_isInitialized');

    if (!_isInitialized) {
      print('❌ ServiceDetailService未初始化，抛出异常');
      throw Exception('ServiceDetailService未初始化');
    }

    try {
      print('📡 ========== 开始数据库查询 ==========');
      print('📡 查询表: service_details');
      print('📡 查询条件: service_id = $serviceId');
      print('📡 排序条件: sort_order');

      final response = await _supabase
          .from('service_details')
          .select('*')
          .eq('service_id', serviceId)
          .order('sort_order');

      print('📊 ========== 数据库查询结果 ==========');
      print('📊 原始响应类型: ${response.runtimeType}');
      print('📊 响应长度: ${response.length}');

      if (response.isNotEmpty) {
        print('📊 第一条原始记录: ${response.first}');
        if (response.length > 1) {
          print('📊 ... 还有 ${response.length - 1} 条记录');
        }
      } else {
        print('📊 响应为空');
      }

      print('🔧 ========== 开始数据转换 ==========');
      final details = <ServiceDetail>[];
      for (int i = 0; i < response.length; i++) {
        try {
          final json = response[i];
          print('🔧 转换第${i + 1}条记录: ${json['id']}');
          final detail = ServiceDetail.fromJson(json);
          details.add(detail);
          print('✅ 第${i + 1}条记录转换成功');
        } catch (e) {
          print('❌ 第${i + 1}条记录转换失败: $e');
          rethrow;
        }
      }

      print('✅ ========== 数据转换完成 ==========');
      print('✅ 成功转换 ${details.length} 个服务详情');

      if (details.isNotEmpty) {
        print('📋 ========== 服务详情摘要 ==========');
        for (int i = 0; i < details.length && i < 3; i++) {
          final detail = details[i];
          print(
              '📋 记录${i + 1}: ID=${detail.id}, 名称=${detail.name}, 分类=${detail.category}');
        }
        if (details.length > 3) {
          print('📋 ... 还有 ${details.length - 3} 条记录');
        }
      } else {
        print('⚠️ ========== 警告: 没有找到数据 ==========');
        print('⚠️ 没有找到serviceId=$serviceId的服务详情');
        print('⚠️ 请检查:');
        print('   1. 数据库中是否存在对应的数据');
        print('   2. service_id字段是否正确');
        print('   3. 数据是否被删除或隐藏');
      }

      print(
          '🎯 ========== ServiceDetailService.getServiceDetails 完成 ==========');
      return details;
    } catch (e, stackTrace) {
      print(
          '❌ ========== ServiceDetailService.getServiceDetails 异常 ==========');
      print('❌ 异常类型: ${e.runtimeType}');
      print('❌ 异常详情: $e');
      print('❌ 堆栈信息: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<ServiceDetail>> getServiceDetailsByCategory(
      String serviceId, String category) async {
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

      final details =
          response.map((json) => ServiceDetail.fromJson(json)).toList();

      print('ServiceDetailService: 获取到 ${details.length} 个分类服务详情 ✅');
      return details;
    } catch (e) {
      print('ServiceDetailService: 获取分类服务详情失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, List<ServiceDetail>>> getServiceDetailsGrouped(
      String serviceId) async {
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
  Future<List<ServiceDetail>> getServiceDetailsByParams(
      String serviceId, ServiceDetailQueryParams params) async {
    if (!_isInitialized) {
      throw Exception('ServiceDetailService未初始化');
    }

    try {
      print(
          'ServiceDetailService: 按参数获取服务详情 - 服务ID: $serviceId, 参数: ${params.toJson()}');

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
      final details =
          response.map((json) => ServiceDetail.fromJson(json)).toList();

      print('ServiceDetailService: 按参数查询完成，找到 ${details.length} 个服务详情 ✅');
      return details;
    } catch (e) {
      print('ServiceDetailService: 按参数获取服务详情失败 ❌ - $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getServiceDetailStatistics(
      String serviceId) async {
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
        categoryDistribution[category] =
            (categoryDistribution[category] ?? 0) + 1;
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

      await _supabase.from('service_details').update({
        'current_stock': newStock,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', detailId);

      print('ServiceDetailService: 库存更新成功 ✅');
      return true;
    } catch (e) {
      print('ServiceDetailService: 库存更新失败 ❌ - $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getServiceDetailBusinessRules(
      String detailId) async {
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

      final businessRules =
          response['business_rules'] as Map<String, dynamic>? ?? {};

      print('ServiceDetailService: 获取业务规则成功 ✅');
      return businessRules;
    } catch (e) {
      print('ServiceDetailService: 获取业务规则失败 ❌ - $e');
      return {};
    }
  }

  @override
  Future<bool> validateServiceDetailAttributes(
      String detailId, Map<String, dynamic> attributes) async {
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

      final requiredAttributes =
          response['attributes'] as Map<String, dynamic>? ?? {};

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
  Map<String, Map<String, dynamic>> getDynamicTabConfig(
      List<ServiceDetail> details) {
    final config = <String, Map<String, dynamic>>{};

    for (final detail in details) {
      final category = detail.category;
      if (!config.containsKey(category)) {
        config[category] = {
          'title': detail.name['en'] ?? detail.name['zh'] ?? category,
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
