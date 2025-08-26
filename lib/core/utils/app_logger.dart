import 'package:flutter/foundation.dart';

/// 全局日志管理组件，所有日志写入和打印都应调用此类
class AppLogger {
  static bool debugEnabled = true;
  static bool infoEnabled = true;
  static bool warningEnabled = true;
  static bool errorEnabled = true;

  static void debug(String msg, {String? tag}) {
    if (debugEnabled) {
      final formatted = _format('DEBUG', msg, tag);
      if (kDebugMode) print(formatted);
    }
  }

  static void info(String msg, {String? tag}) {
    if (infoEnabled) {
      final formatted = _format('INFO', msg, tag);
      if (kDebugMode) print(formatted);
    }
  }

  static void warning(String msg, {String? tag}) {
    if (warningEnabled) {
      final formatted = _format('WARNING', msg, tag);
      if (kDebugMode) print(formatted);
    }
  }

  static void error(String msg, {String? tag, dynamic error, StackTrace? stackTrace}) {
    if (errorEnabled) {
      var out = _format('ERROR', msg, tag);
      if (error != null) out += '\nError: $error';
      if (stackTrace != null) out += '\nStack: $stackTrace';
      if (kDebugMode) print(out);
    }
  }

  static String _format(String level, String msg, String? tag) {
    final now = DateTime.now().toIso8601String();
    final tagStr = tag != null ? '[$tag]' : '';
    return '[$level]$tagStr $now $msg';
  }
} 