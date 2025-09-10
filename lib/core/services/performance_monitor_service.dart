import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../utils/app_logger.dart';

/// 性能监控服务
/// 
/// 提供应用性能监控功能，包括：
/// - API请求性能监控
/// - UI渲染性能监控
/// - 内存使用监控
/// - 网络请求监控
/// - 数据库查询性能监控
class PerformanceMonitorService extends GetxService {
  // 性能指标存储
  final Queue<PerformanceMetric> _metrics = Queue<PerformanceMetric>();
  final Map<String, Timer> _activeTimers = {};
  final Map<String, DateTime> _startTimes = {};
  
  // 配置
  final int _maxMetricsCount = 1000;
  final Duration _reportInterval = const Duration(minutes: 5);
  
  // 统计数据
  final RxMap<String, PerformanceStats> _stats = <String, PerformanceStats>{}.obs;
  final RxBool _isMonitoring = true.obs;
  
  // 定时器
  Timer? _reportTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  @override
  void onClose() {
    _reportTimer?.cancel();
    _activeTimers.values.forEach((timer) => timer.cancel());
    super.onClose();
  }

  void _initializeService() {
    AppLogger.info('[PerformanceMonitorService] Initializing performance monitoring');
    
    // 启动定期报告
    _startPeriodicReporting();
    
    // 监听应用生命周期
    _setupLifecycleMonitoring();
  }

  /// 开始性能计时
  void startTiming(String operationName, {Map<String, dynamic>? metadata}) {
    if (!_isMonitoring.value) return;
    
    final startTime = DateTime.now();
    _startTimes[operationName] = startTime;
    
    AppLogger.debug('[PerformanceMonitor] Started timing: $operationName');
  }

  /// 结束性能计时
  void endTiming(String operationName, {
    bool success = true,
    String? errorMessage,
    Map<String, dynamic>? additionalData,
  }) {
    if (!_isMonitoring.value) return;
    
    final endTime = DateTime.now();
    final startTime = _startTimes.remove(operationName);
    
    if (startTime == null) {
      AppLogger.warning('[PerformanceMonitor] No start time found for: $operationName');
      return;
    }
    
    final duration = endTime.difference(startTime);
    
    final metric = PerformanceMetric(
      operationName: operationName,
      duration: duration,
      timestamp: endTime,
      success: success,
      errorMessage: errorMessage,
      metadata: additionalData ?? {},
    );
    
    _addMetric(metric);
    _updateStats(metric);
    
    AppLogger.debug('[PerformanceMonitor] Completed timing: $operationName (${duration.inMilliseconds}ms)');
  }

  /// 记录API请求性能
  void recordApiRequest({
    required String endpoint,
    required String method,
    required Duration duration,
    required int statusCode,
    int? responseSize,
    String? errorMessage,
  }) {
    final metric = PerformanceMetric(
      operationName: 'api_request',
      duration: duration,
      timestamp: DateTime.now(),
      success: statusCode >= 200 && statusCode < 300,
      errorMessage: errorMessage,
      metadata: {
        'endpoint': endpoint,
        'method': method,
        'status_code': statusCode,
        'response_size': responseSize,
      },
    );
    
    _addMetric(metric);
    _updateStats(metric);
  }

  /// 记录数据库查询性能
  void recordDatabaseQuery({
    required String table,
    required String operation,
    required Duration duration,
    required bool success,
    int? resultCount,
    String? errorMessage,
  }) {
    final metric = PerformanceMetric(
      operationName: 'database_query',
      duration: duration,
      timestamp: DateTime.now(),
      success: success,
      errorMessage: errorMessage,
      metadata: {
        'table': table,
        'operation': operation,
        'result_count': resultCount,
      },
    );
    
    _addMetric(metric);
    _updateStats(metric);
  }

  /// 记录UI渲染性能
  void recordUIRender({
    required String widgetName,
    required Duration buildTime,
    bool? hadRebuild,
  }) {
    final metric = PerformanceMetric(
      operationName: 'ui_render',
      duration: buildTime,
      timestamp: DateTime.now(),
      success: true,
      metadata: {
        'widget_name': widgetName,
        'had_rebuild': hadRebuild,
      },
    );
    
    _addMetric(metric);
    _updateStats(metric);
  }

  /// 记录内存使用情况
  void recordMemoryUsage({
    required int usedMemoryMB,
    required int totalMemoryMB,
    String? context,
  }) {
    final metric = PerformanceMetric(
      operationName: 'memory_usage',
      duration: Duration.zero,
      timestamp: DateTime.now(),
      success: true,
      metadata: {
        'used_memory_mb': usedMemoryMB,
        'total_memory_mb': totalMemoryMB,
        'usage_percentage': (usedMemoryMB / totalMemoryMB * 100).round(),
        'context': context,
      },
    );
    
    _addMetric(metric);
  }

  /// 添加性能指标
  void _addMetric(PerformanceMetric metric) {
    _metrics.add(metric);
    
    // 限制指标数量
    while (_metrics.length > _maxMetricsCount) {
      _metrics.removeFirst();
    }
  }

  /// 更新统计数据
  void _updateStats(PerformanceMetric metric) {
    final key = metric.operationName;
    final existing = _stats[key];
    
    if (existing == null) {
      _stats[key] = PerformanceStats(
        operationName: key,
        totalCount: 1,
        successCount: metric.success ? 1 : 0,
        failureCount: metric.success ? 0 : 1,
        totalDuration: metric.duration,
        minDuration: metric.duration,
        maxDuration: metric.duration,
        avgDuration: metric.duration,
        lastUpdated: metric.timestamp,
      );
    } else {
      final newTotalCount = existing.totalCount + 1;
      final newSuccessCount = existing.successCount + (metric.success ? 1 : 0);
      final newFailureCount = existing.failureCount + (metric.success ? 0 : 1);
      final newTotalDuration = existing.totalDuration + metric.duration;
      final newMinDuration = Duration(
        microseconds: [existing.minDuration.inMicroseconds, metric.duration.inMicroseconds].reduce((a, b) => a < b ? a : b),
      );
      final newMaxDuration = Duration(
        microseconds: [existing.maxDuration.inMicroseconds, metric.duration.inMicroseconds].reduce((a, b) => a > b ? a : b),
      );
      final newAvgDuration = Duration(
        microseconds: (newTotalDuration.inMicroseconds / newTotalCount).round(),
      );
      
      _stats[key] = PerformanceStats(
        operationName: key,
        totalCount: newTotalCount,
        successCount: newSuccessCount,
        failureCount: newFailureCount,
        totalDuration: newTotalDuration,
        minDuration: newMinDuration,
        maxDuration: newMaxDuration,
        avgDuration: newAvgDuration,
        lastUpdated: metric.timestamp,
      );
    }
  }

  /// 启动定期报告
  void _startPeriodicReporting() {
    _reportTimer = Timer.periodic(_reportInterval, (timer) {
      _generatePerformanceReport();
    });
  }

  /// 生成性能报告
  void _generatePerformanceReport() {
    if (_metrics.isEmpty) return;
    
    final report = PerformanceReport(
      generatedAt: DateTime.now(),
      totalMetrics: _metrics.length,
      stats: Map.from(_stats),
      topSlowOperations: _getTopSlowOperations(),
      errorSummary: _getErrorSummary(),
      recommendations: _generateRecommendations(),
    );
    
    AppLogger.info('[PerformanceMonitor] Performance Report Generated:');
    AppLogger.info('  Total Metrics: ${report.totalMetrics}');
    AppLogger.info('  Operations Tracked: ${report.stats.length}');
    AppLogger.info('  Top Slow Operations: ${report.topSlowOperations.length}');
    
    // 在调试模式下打印详细报告
    if (kDebugMode) {
      _printDetailedReport(report);
    }
  }

  /// 获取最慢的操作
  List<PerformanceStats> _getTopSlowOperations({int limit = 5}) {
    final statsList = _stats.values.toList();
    statsList.sort((a, b) => b.avgDuration.compareTo(a.avgDuration));
    return statsList.take(limit).toList();
  }

  /// 获取错误摘要
  Map<String, int> _getErrorSummary() {
    final errorCounts = <String, int>{};
    
    for (final metric in _metrics) {
      if (!metric.success && metric.errorMessage != null) {
        final error = metric.errorMessage!;
        errorCounts[error] = (errorCounts[error] ?? 0) + 1;
      }
    }
    
    return errorCounts;
  }

  /// 生成性能优化建议
  List<String> _generateRecommendations() {
    final recommendations = <String>[];
    
    // 检查慢操作
    final slowOperations = _getTopSlowOperations(limit: 3);
    for (final op in slowOperations) {
      if (op.avgDuration.inMilliseconds > 1000) {
        recommendations.add('${op.operationName} 平均耗时 ${op.avgDuration.inMilliseconds}ms，建议优化');
      }
    }
    
    // 检查错误率
    for (final stats in _stats.values) {
      final errorRate = stats.failureCount / stats.totalCount;
      if (errorRate > 0.1) {
        recommendations.add('${stats.operationName} 错误率 ${(errorRate * 100).toStringAsFixed(1)}%，需要关注');
      }
    }
    
    // 检查API请求
    final apiStats = _stats['api_request'];
    if (apiStats != null && apiStats.avgDuration.inMilliseconds > 2000) {
      recommendations.add('API请求平均响应时间过长，建议优化网络请求或后端性能');
    }
    
    // 检查数据库查询
    final dbStats = _stats['database_query'];
    if (dbStats != null && dbStats.avgDuration.inMilliseconds > 500) {
      recommendations.add('数据库查询平均耗时过长，建议优化查询语句或添加索引');
    }
    
    return recommendations;
  }

  /// 打印详细报告
  void _printDetailedReport(PerformanceReport report) {
    print('\n=== 性能监控报告 ===');
    print('生成时间: ${report.generatedAt}');
    print('总指标数: ${report.totalMetrics}');
    print('');
    
    print('=== 操作统计 ===');
    for (final stats in report.stats.values) {
      print('${stats.operationName}:');
      print('  总次数: ${stats.totalCount}');
      print('  成功率: ${(stats.successCount / stats.totalCount * 100).toStringAsFixed(1)}%');
      print('  平均耗时: ${stats.avgDuration.inMilliseconds}ms');
      print('  最小耗时: ${stats.minDuration.inMilliseconds}ms');
      print('  最大耗时: ${stats.maxDuration.inMilliseconds}ms');
      print('');
    }
    
    if (report.topSlowOperations.isNotEmpty) {
      print('=== 最慢操作 ===');
      for (final op in report.topSlowOperations) {
        print('${op.operationName}: ${op.avgDuration.inMilliseconds}ms');
      }
      print('');
    }
    
    if (report.errorSummary.isNotEmpty) {
      print('=== 错误摘要 ===');
      for (final entry in report.errorSummary.entries) {
        print('${entry.key}: ${entry.value} 次');
      }
      print('');
    }
    
    if (report.recommendations.isNotEmpty) {
      print('=== 优化建议 ===');
      for (final recommendation in report.recommendations) {
        print('• $recommendation');
      }
      print('');
    }
    
    print('===================\n');
  }

  /// 设置生命周期监控
  void _setupLifecycleMonitoring() {
    // TODO: 实现应用生命周期监控
  }

  /// 获取当前性能统计
  Map<String, PerformanceStats> getPerformanceStats() {
    return Map.from(_stats);
  }

  /// 获取最近的性能指标
  List<PerformanceMetric> getRecentMetrics({int limit = 100}) {
    final metrics = _metrics.toList();
    return metrics.reversed.take(limit).toList();
  }

  /// 清除性能数据
  void clearPerformanceData() {
    _metrics.clear();
    _stats.clear();
    _startTimes.clear();
    AppLogger.info('[PerformanceMonitor] Performance data cleared');
  }

  /// 启用/禁用监控
  void setMonitoringEnabled(bool enabled) {
    _isMonitoring.value = enabled;
    AppLogger.info('[PerformanceMonitor] Monitoring ${enabled ? 'enabled' : 'disabled'}');
  }

  /// 获取监控状态
  bool get isMonitoringEnabled => _isMonitoring.value;

  /// 获取服务状态
  Map<String, dynamic> getServiceStatus() {
    return {
      'is_monitoring': _isMonitoring.value,
      'metrics_count': _metrics.length,
      'stats_count': _stats.length,
      'active_timers': _activeTimers.length,
      'report_interval_minutes': _reportInterval.inMinutes,
    };
  }
}

/// 性能指标模型
class PerformanceMetric {
  final String operationName;
  final Duration duration;
  final DateTime timestamp;
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  PerformanceMetric({
    required this.operationName,
    required this.duration,
    required this.timestamp,
    required this.success,
    this.errorMessage,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'operation_name': operationName,
      'duration_ms': duration.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'error_message': errorMessage,
      'metadata': metadata,
    };
  }
}

/// 性能统计模型
class PerformanceStats {
  final String operationName;
  final int totalCount;
  final int successCount;
  final int failureCount;
  final Duration totalDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final Duration avgDuration;
  final DateTime lastUpdated;

  PerformanceStats({
    required this.operationName,
    required this.totalCount,
    required this.successCount,
    required this.failureCount,
    required this.totalDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.avgDuration,
    required this.lastUpdated,
  });

  double get successRate => totalCount > 0 ? successCount / totalCount : 0.0;
  double get failureRate => totalCount > 0 ? failureCount / totalCount : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'operation_name': operationName,
      'total_count': totalCount,
      'success_count': successCount,
      'failure_count': failureCount,
      'success_rate': successRate,
      'failure_rate': failureRate,
      'total_duration_ms': totalDuration.inMilliseconds,
      'min_duration_ms': minDuration.inMilliseconds,
      'max_duration_ms': maxDuration.inMilliseconds,
      'avg_duration_ms': avgDuration.inMilliseconds,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

/// 性能报告模型
class PerformanceReport {
  final DateTime generatedAt;
  final int totalMetrics;
  final Map<String, PerformanceStats> stats;
  final List<PerformanceStats> topSlowOperations;
  final Map<String, int> errorSummary;
  final List<String> recommendations;

  PerformanceReport({
    required this.generatedAt,
    required this.totalMetrics,
    required this.stats,
    required this.topSlowOperations,
    required this.errorSummary,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() {
    return {
      'generated_at': generatedAt.toIso8601String(),
      'total_metrics': totalMetrics,
      'stats': stats.map((key, value) => MapEntry(key, value.toJson())),
      'top_slow_operations': topSlowOperations.map((e) => e.toJson()).toList(),
      'error_summary': errorSummary,
      'recommendations': recommendations,
    };
  }
}

