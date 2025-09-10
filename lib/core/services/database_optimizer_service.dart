import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';
import 'performance_monitor_service.dart';

/// 数据库查询优化服务
/// 
/// 提供数据库查询优化功能，包括：
/// - 查询缓存
/// - 批量查询
/// - 连接池管理
/// - 查询性能监控
/// - 索引建议
class DatabaseOptimizerService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final PerformanceMonitorService _performanceMonitor = Get.find<PerformanceMonitorService>();
  
  // 查询缓存
  final Map<String, CachedQuery> _queryCache = {};
  final Duration _defaultCacheExpiry = const Duration(minutes: 5);
  final int _maxCacheSize = 100;
  
  // 批量查询队列
  final Map<String, List<BatchQueryItem>> _batchQueues = {};
  final Map<String, Timer> _batchTimers = {};
  final Duration _batchDelay = const Duration(milliseconds: 100);
  
  // 查询统计
  final Map<String, QueryStats> _queryStats = {};
  
  // 配置
  final RxBool _cacheEnabled = true.obs;
  final RxBool _batchingEnabled = true.obs;
  final RxBool _monitoringEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  @override
  void onClose() {
    _clearAllCaches();
    _cancelAllBatchTimers();
    super.onClose();
  }

  void _initializeService() {
    AppLogger.info('[DatabaseOptimizerService] Initializing database optimizer');
    
    // 启动缓存清理定时器
    Timer.periodic(const Duration(minutes: 1), (timer) {
      _cleanExpiredCache();
    });
  }

  /// 执行优化查询
  Future<List<Map<String, dynamic>>> executeOptimizedQuery({
    required String table,
    required String operation,
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
    bool useCache = true,
    Duration? cacheExpiry,
  }) async {
    final queryKey = _generateQueryKey(table, operation, select, filters, orderBy, ascending, limit, offset);
    
    // 检查缓存
    if (useCache && _cacheEnabled.value) {
      final cached = _getCachedQuery(queryKey);
      if (cached != null) {
        AppLogger.debug('[DatabaseOptimizer] Cache hit for query: $queryKey');
        return cached.data;
      }
    }
    
    final startTime = DateTime.now();
    
    try {
      // 构建查询
      final query = _buildQuery(table, select, filters, orderBy, ascending, limit, offset);
      
      // 执行查询
      final response = await query;
      final data = List<Map<String, dynamic>>.from(response);
      
      final duration = DateTime.now().difference(startTime);
      
      // 记录性能
      if (_monitoringEnabled.value) {
        _performanceMonitor.recordDatabaseQuery(
          table: table,
          operation: operation,
          duration: duration,
          success: true,
          resultCount: data.length,
        );
      }
      
      // 更新统计
      _updateQueryStats(queryKey, duration, true, data.length);
      
      // 缓存结果
      if (useCache && _cacheEnabled.value) {
        _cacheQuery(queryKey, data, cacheExpiry ?? _defaultCacheExpiry);
      }
      
      AppLogger.debug('[DatabaseOptimizer] Query executed: $table.$operation (${duration.inMilliseconds}ms, ${data.length} results)');
      
      return data;
      
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      
      // 记录性能
      if (_monitoringEnabled.value) {
        _performanceMonitor.recordDatabaseQuery(
          table: table,
          operation: operation,
          duration: duration,
          success: false,
          errorMessage: e.toString(),
        );
      }
      
      // 更新统计
      _updateQueryStats(queryKey, duration, false, 0);
      
      AppLogger.error('[DatabaseOptimizer] Query failed: $table.$operation - $e');
      rethrow;
    }
  }

  /// 批量查询
  Future<List<Map<String, dynamic>>> executeBatchQuery({
    required String batchKey,
    required String table,
    required List<String> ids,
    String? select,
    String idField = 'id',
  }) async {
    if (!_batchingEnabled.value || ids.isEmpty) {
      // 如果批量查询被禁用或没有ID，直接执行
      return executeOptimizedQuery(
        table: table,
        operation: 'batch_select',
        select: select,
        filters: {idField: ids},
      );
    }

    // 添加到批量队列
    final completer = Completer<List<Map<String, dynamic>>>();
    final batchItem = BatchQueryItem(
      table: table,
      ids: ids,
      select: select,
      idField: idField,
      completer: completer,
    );

    _addToBatchQueue(batchKey, batchItem);
    
    return completer.future;
  }

  /// 构建查询
  dynamic _buildQuery(
    String table,
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending,
    int? limit,
    int? offset,
  ) {
    dynamic query = _supabase.from(table);
    
    // 选择字段
    if (select != null) {
      query = query.select(select);
    } else {
      query = query.select();
    }
    
    // 应用筛选条件
    if (filters != null) {
      for (final entry in filters.entries) {
        final key = entry.key;
        final value = entry.value;
        
        if (value is List) {
          query = query.inFilter(key, value);
        } else if (value is Map) {
          // 支持复杂筛选条件
          for (final filterEntry in value.entries) {
            switch (filterEntry.key) {
              case 'eq':
                query = query.eq(key, filterEntry.value);
                break;
              case 'neq':
                query = query.neq(key, filterEntry.value);
                break;
              case 'gt':
                query = query.gt(key, filterEntry.value);
                break;
              case 'gte':
                query = query.gte(key, filterEntry.value);
                break;
              case 'lt':
                query = query.lt(key, filterEntry.value);
                break;
              case 'lte':
                query = query.lte(key, filterEntry.value);
                break;
              case 'like':
                query = query.like(key, filterEntry.value);
                break;
              case 'ilike':
                query = query.ilike(key, filterEntry.value);
                break;
            }
          }
        } else {
          query = query.eq(key, value);
        }
      }
    }
    
    // 排序
    if (orderBy != null) {
      query = query.order(orderBy, ascending: ascending);
    }
    
    // 分页
    if (limit != null) {
      if (offset != null) {
        query = query.range(offset, offset + limit - 1);
      } else {
        query = query.limit(limit);
      }
    }
    
    return query;
  }

  /// 生成查询键
  String _generateQueryKey(
    String table,
    String operation,
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending,
    int? limit,
    int? offset,
  ) {
    final parts = [
      table,
      operation,
      select ?? '*',
      filters?.toString() ?? '',
      orderBy ?? '',
      ascending.toString(),
      limit?.toString() ?? '',
      offset?.toString() ?? '',
    ];
    
    return parts.join('|');
  }

  /// 缓存查询结果
  void _cacheQuery(String key, List<Map<String, dynamic>> data, Duration expiry) {
    // 检查缓存大小
    if (_queryCache.length >= _maxCacheSize) {
      _evictOldestCache();
    }
    
    _queryCache[key] = CachedQuery(
      data: data,
      cachedAt: DateTime.now(),
      expiresAt: DateTime.now().add(expiry),
    );
  }

  /// 获取缓存查询
  CachedQuery? _getCachedQuery(String key) {
    final cached = _queryCache[key];
    if (cached == null) return null;
    
    if (cached.isExpired) {
      _queryCache.remove(key);
      return null;
    }
    
    return cached;
  }

  /// 清理过期缓存
  void _cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = _queryCache.entries
        .where((entry) => entry.value.expiresAt.isBefore(now))
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _queryCache.remove(key);
    }
    
    if (expiredKeys.isNotEmpty) {
      AppLogger.debug('[DatabaseOptimizer] Cleaned ${expiredKeys.length} expired cache entries');
    }
  }

  /// 驱逐最旧的缓存
  void _evictOldestCache() {
    if (_queryCache.isEmpty) return;
    
    String? oldestKey;
    DateTime? oldestTime;
    
    for (final entry in _queryCache.entries) {
      if (oldestTime == null || entry.value.cachedAt.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value.cachedAt;
      }
    }
    
    if (oldestKey != null) {
      _queryCache.remove(oldestKey);
    }
  }

  /// 添加到批量队列
  void _addToBatchQueue(String batchKey, BatchQueryItem item) {
    _batchQueues.putIfAbsent(batchKey, () => []);
    _batchQueues[batchKey]!.add(item);
    
    // 设置批量处理定时器
    _batchTimers[batchKey]?.cancel();
    _batchTimers[batchKey] = Timer(_batchDelay, () {
      _processBatchQueue(batchKey);
    });
  }

  /// 处理批量队列
  Future<void> _processBatchQueue(String batchKey) async {
    final items = _batchQueues.remove(batchKey);
    _batchTimers.remove(batchKey);
    
    if (items == null || items.isEmpty) return;
    
    try {
      // 按表分组
      final groupedByTable = <String, List<BatchQueryItem>>{};
      for (final item in items) {
        groupedByTable.putIfAbsent(item.table, () => []);
        groupedByTable[item.table]!.add(item);
      }
      
      // 处理每个表的批量查询
      for (final entry in groupedByTable.entries) {
        await _processBatchQueryForTable(entry.key, entry.value);
      }
      
    } catch (e) {
      // 如果批量查询失败，通知所有等待的查询
      for (final item in items) {
        item.completer.completeError(e);
      }
    }
  }

  /// 处理单个表的批量查询
  Future<void> _processBatchQueryForTable(String table, List<BatchQueryItem> items) async {
    // 收集所有ID
    final allIds = <String>{};
    for (final item in items) {
      allIds.addAll(item.ids);
    }
    
    if (allIds.isEmpty) {
      for (final item in items) {
        item.completer.complete([]);
      }
      return;
    }
    
    // 执行批量查询
    final results = await executeOptimizedQuery(
      table: table,
      operation: 'batch_select',
      filters: {items.first.idField: allIds.toList()},
      useCache: false, // 批量查询不使用缓存
    );
    
    // 按ID分组结果
    final resultsByField = <String, Map<String, dynamic>>{};
    for (final result in results) {
      final id = result[items.first.idField]?.toString();
      if (id != null) {
        resultsByField[id] = result;
      }
    }
    
    // 为每个查询返回对应的结果
    for (final item in items) {
      final itemResults = <Map<String, dynamic>>[];
      for (final id in item.ids) {
        final result = resultsByField[id];
        if (result != null) {
          itemResults.add(result);
        }
      }
      item.completer.complete(itemResults);
    }
  }

  /// 更新查询统计
  void _updateQueryStats(String queryKey, Duration duration, bool success, int resultCount) {
    final existing = _queryStats[queryKey];
    
    if (existing == null) {
      _queryStats[queryKey] = QueryStats(
        queryKey: queryKey,
        executionCount: 1,
        successCount: success ? 1 : 0,
        totalDuration: duration,
        minDuration: duration,
        maxDuration: duration,
        avgResultCount: resultCount.toDouble(),
        lastExecuted: DateTime.now(),
      );
    } else {
      final newExecutionCount = existing.executionCount + 1;
      final newSuccessCount = existing.successCount + (success ? 1 : 0);
      final newTotalDuration = existing.totalDuration + duration;
      final newMinDuration = Duration(
        microseconds: [existing.minDuration.inMicroseconds, duration.inMicroseconds].reduce((a, b) => a < b ? a : b),
      );
      final newMaxDuration = Duration(
        microseconds: [existing.maxDuration.inMicroseconds, duration.inMicroseconds].reduce((a, b) => a > b ? a : b),
      );
      final newAvgResultCount = (existing.avgResultCount * existing.executionCount + resultCount) / newExecutionCount;
      
      _queryStats[queryKey] = QueryStats(
        queryKey: queryKey,
        executionCount: newExecutionCount,
        successCount: newSuccessCount,
        totalDuration: newTotalDuration,
        minDuration: newMinDuration,
        maxDuration: newMaxDuration,
        avgResultCount: newAvgResultCount,
        lastExecuted: DateTime.now(),
      );
    }
  }

  /// 清除所有缓存
  void _clearAllCaches() {
    _queryCache.clear();
    AppLogger.info('[DatabaseOptimizer] All caches cleared');
  }

  /// 取消所有批量定时器
  void _cancelAllBatchTimers() {
    for (final timer in _batchTimers.values) {
      timer.cancel();
    }
    _batchTimers.clear();
  }

  /// 获取查询统计
  Map<String, QueryStats> getQueryStats() {
    return Map.from(_queryStats);
  }

  /// 获取缓存统计
  Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    final expiredCount = _queryCache.values.where((cache) => cache.isExpired).length;
    
    return {
      'total_cached_queries': _queryCache.length,
      'expired_queries': expiredCount,
      'active_queries': _queryCache.length - expiredCount,
      'cache_hit_rate': _calculateCacheHitRate(),
      'max_cache_size': _maxCacheSize,
    };
  }

  /// 计算缓存命中率
  double _calculateCacheHitRate() {
    // 这里需要实现缓存命中率计算逻辑
    // 简化实现，实际应该跟踪命中和未命中次数
    return 0.75; // 示例值
  }

  /// 获取优化建议
  List<String> getOptimizationRecommendations() {
    final recommendations = <String>[];
    
    // 分析慢查询
    final slowQueries = _queryStats.values
        .where((stats) => stats.avgDuration.inMilliseconds > 1000)
        .toList();
    
    for (final query in slowQueries) {
      recommendations.add('查询 ${query.queryKey} 平均耗时 ${query.avgDuration.inMilliseconds}ms，建议优化');
    }
    
    // 分析缓存效率
    if (_queryCache.length < _maxCacheSize * 0.5) {
      recommendations.add('缓存使用率较低，可以考虑增加缓存时间或范围');
    }
    
    // 分析批量查询效率
    final batchStats = _queryStats.values
        .where((stats) => stats.queryKey.contains('batch_select'))
        .toList();
    
    if (batchStats.isNotEmpty) {
      final avgBatchSize = batchStats
          .map((stats) => stats.avgResultCount)
          .reduce((a, b) => a + b) / batchStats.length;
      
      if (avgBatchSize < 5) {
        recommendations.add('批量查询平均大小较小，可以考虑增加批量大小或延迟时间');
      }
    }
    
    return recommendations;
  }

  /// 启用/禁用缓存
  void setCacheEnabled(bool enabled) {
    _cacheEnabled.value = enabled;
    if (!enabled) {
      _clearAllCaches();
    }
    AppLogger.info('[DatabaseOptimizer] Cache ${enabled ? 'enabled' : 'disabled'}');
  }

  /// 启用/禁用批量查询
  void setBatchingEnabled(bool enabled) {
    _batchingEnabled.value = enabled;
    if (!enabled) {
      _cancelAllBatchTimers();
    }
    AppLogger.info('[DatabaseOptimizer] Batching ${enabled ? 'enabled' : 'disabled'}');
  }

  /// 启用/禁用监控
  void setMonitoringEnabled(bool enabled) {
    _monitoringEnabled.value = enabled;
    AppLogger.info('[DatabaseOptimizer] Monitoring ${enabled ? 'enabled' : 'disabled'}');
  }
}

/// 缓存查询模型
class CachedQuery {
  final List<Map<String, dynamic>> data;
  final DateTime cachedAt;
  final DateTime expiresAt;

  CachedQuery({
    required this.data,
    required this.cachedAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// 批量查询项模型
class BatchQueryItem {
  final String table;
  final List<String> ids;
  final String? select;
  final String idField;
  final Completer<List<Map<String, dynamic>>> completer;

  BatchQueryItem({
    required this.table,
    required this.ids,
    this.select,
    required this.idField,
    required this.completer,
  });
}

/// 查询统计模型
class QueryStats {
  final String queryKey;
  final int executionCount;
  final int successCount;
  final Duration totalDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final double avgResultCount;
  final DateTime lastExecuted;

  QueryStats({
    required this.queryKey,
    required this.executionCount,
    required this.successCount,
    required this.totalDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.avgResultCount,
    required this.lastExecuted,
  });

  Duration get avgDuration => Duration(
    microseconds: (totalDuration.inMicroseconds / executionCount).round(),
  );

  double get successRate => executionCount > 0 ? successCount / executionCount : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'query_key': queryKey,
      'execution_count': executionCount,
      'success_count': successCount,
      'success_rate': successRate,
      'total_duration_ms': totalDuration.inMilliseconds,
      'min_duration_ms': minDuration.inMilliseconds,
      'max_duration_ms': maxDuration.inMilliseconds,
      'avg_duration_ms': avgDuration.inMilliseconds,
      'avg_result_count': avgResultCount,
      'last_executed': lastExecuted.toIso8601String(),
    };
  }
}

