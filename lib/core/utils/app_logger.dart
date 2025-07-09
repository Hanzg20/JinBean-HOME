/// 全局日志管理组件，所有日志写入和打印都应调用此类
class AppLogger {
  static bool debugEnabled = true;
  static bool infoEnabled = true;
  static bool warningEnabled = true;
  static bool errorEnabled = true;

  static void debug(String msg, {String? tag}) {
    if (debugEnabled) print(_format('DEBUG', msg, tag));
  }

  static void info(String msg, {String? tag}) {
    if (infoEnabled) print(_format('INFO', msg, tag));
  }

  static void warning(String msg, {String? tag}) {
    if (warningEnabled) print(_format('WARNING', msg, tag));
  }

  static void error(String msg, {String? tag, dynamic error, StackTrace? stackTrace}) {
    if (errorEnabled) {
      var out = _format('ERROR', msg, tag);
      if (error != null) out += '\nError: $error';
      if (stackTrace != null) out += '\nStack: $stackTrace';
      print(out);
    }
  }

  static String _format(String level, String msg, String? tag) {
    final now = DateTime.now().toIso8601String();
    final tagStr = tag != null ? '[$tag]' : '';
    return '[$level]$tagStr $now $msg';
  }
} 