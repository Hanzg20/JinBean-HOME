import 'package:flutter/foundation.dart';

/// 生产环境优化的日志管理器
class Logger {
  // 日志级别
  static const int _ERROR = 0;
  static const int _WARNING = 1;
  static const int _INFO = 2;
  static const int _DEBUG = 3;

  // 生产环境日志级别 (只显示错误和警告)
  static const int _productionLevel = kDebugMode ? _DEBUG : _WARNING;

  /// 错误日志 (生产环境显示)
  static void error(String message, [String? tag]) {
    if (_productionLevel >= _ERROR) {
      if (kDebugMode) {
        print('❌ [ERROR]${tag != null ? '[$tag]' : ''} $message');
      }
    }
  }

  /// 警告日志 (生产环境显示)
  static void warning(String message, [String? tag]) {
    if (_productionLevel >= _WARNING) {
      if (kDebugMode) {
        print('⚠️ [WARNING]${tag != null ? '[$tag]' : ''} $message');
      }
    }
  }

  /// 信息日志 (仅调试模式)
  static void info(String message, [String? tag]) {
    if (kDebugMode && _productionLevel >= _INFO) {
      print('ℹ️ [INFO]${tag != null ? '[$tag]' : ''} $message');
    }
  }

  /// 调试日志 (仅调试模式)
  static void debug(String message, [String? tag]) {
    if (kDebugMode && _productionLevel >= _DEBUG) {
      print('🔧 [DEBUG]${tag != null ? '[$tag]' : ''} $message');
    }
  }

  /// 购物车专用日志
  static void cart(String message) {
    debug(message, 'Cart');
  }

  /// 服务专用日志
  static void service(String message) {
    debug(message, 'Service');
  }

  /// UI专用日志
  static void ui(String message) {
    debug(message, 'UI');
  }

  /// 网络专用日志
  static void network(String message) {
    debug(message, 'Network');
  }
}
