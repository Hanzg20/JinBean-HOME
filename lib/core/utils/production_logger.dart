import 'package:flutter/foundation.dart';

/// 生产环境日志控制器
/// 在生产环境中大幅减少日志输出，提高性能
class ProductionLogger {
  // 是否开启详细日志（仅在调试模式下）
  static const bool _enableVerboseLogging = kDebugMode;

  // 生产环境下是否显示关键信息
  static const bool _showCriticalInfo = true;

  /// 错误日志 - 总是显示
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
      if (error != null) print('   Details: $error');
      if (stackTrace != null) print('   Stack: $stackTrace');
    }
  }

  /// 警告日志 - 总是显示
  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ WARNING: $message');
    }
  }

  /// 关键信息 - 生产环境显示重要信息
  static void critical(String message) {
    if (_showCriticalInfo || kDebugMode) {
      print('🔥 CRITICAL: $message');
    }
  }

  /// 信息日志 - 仅调试模式
  static void info(String message) {
    if (_enableVerboseLogging) {
      print('ℹ️ INFO: $message');
    }
  }

  /// 调试日志 - 仅调试模式且精简
  static void debug(String message, {bool forceShow = false}) {
    if (_enableVerboseLogging && forceShow) {
      print('🔧 DEBUG: $message');
    }
  }

  /// 网络日志 - 仅在必要时显示
  static void network(String message, {bool isError = false}) {
    if (isError || _enableVerboseLogging) {
      print('🌐 NETWORK: $message');
    }
  }

  /// 用户操作日志 - 关键操作记录
  static void userAction(String action, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      print('👤 USER: $action${data != null ? ' - $data' : ''}');
    }
  }

  /// 性能日志 - 仅在调试时显示
  static void performance(String message) {
    if (_enableVerboseLogging) {
      print('⚡ PERF: $message');
    }
  }

  /// 购物车操作 - 简化日志
  static void cart(String operation, {String? itemId, int? quantity}) {
    if (_enableVerboseLogging) {
      print(
          '🛒 CART: $operation${itemId != null ? ' ($itemId${quantity != null ? ' x$quantity' : ''})' : ''}');
    }
  }

  /// 服务操作 - 关键操作记录
  static void service(String operation, {String? serviceId}) {
    if (kDebugMode) {
      print(
          '🔧 SERVICE: $operation${serviceId != null ? ' ($serviceId)' : ''}');
    }
  }
}
