import 'package:flutter/foundation.dart';

/// 应用配置管理
class AppConfig {
  // 应用版本
  static const String version = '1.0.0';
  static const int buildNumber = 1;

  // 环境配置
  static const bool isProduction = kReleaseMode;
  static const bool isDevelopment = kDebugMode;

  // 日志配置
  static const bool enableDetailedLogs = kDebugMode;
  static const bool enableNetworkLogs = kDebugMode;
  static const bool enablePerformanceLogs = false; // 默认关闭性能日志

  // 功能开关
  static const bool enableExperimentalFeatures = kDebugMode;
  static const bool enableDebugPanels = kDebugMode;

  // 性能配置
  static const int maxLogEntries = 100; // 最大日志条数
  static const Duration logRetentionDuration = Duration(hours: 1); // 日志保留时间

  // API配置
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;

  // 缓存配置
  static const Duration cacheExpiration = Duration(minutes: 15);
  static const int maxCacheSize = 50; // MB

  /// 获取当前环境名称
  static String get environmentName {
    if (kReleaseMode) return 'Production';
    if (kProfileMode) return 'Profile';
    return 'Debug';
  }

  /// 是否显示调试信息
  static bool get showDebugInfo => !kReleaseMode;

  /// 是否启用详细错误报告
  static bool get enableDetailedErrors => !kReleaseMode;
}
