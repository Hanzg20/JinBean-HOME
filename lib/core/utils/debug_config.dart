/// 调试配置管理
class DebugConfig {
  // 是否开启调试模式
  static const bool isDebugMode = false; // 生产环境设为 false

  // 各模块的日志开关
  static const bool enableCartLogs = false;
  static const bool enableServiceLogs = false;
  static const bool enableTabLogs = false;
  static const bool enableDataLogs = false;
  static const bool enableUILogs = false;
  static const bool enableNetworkLogs = false;

  /// 条件性调试打印
  static void debugPrint(String message, {String? tag}) {
    if (isDebugMode) {
      print(tag != null ? '[$tag] $message' : message);
    }
  }

  /// 购物车相关日志
  static void cartLog(String message) {
    if (isDebugMode && enableCartLogs) {
      print('🛒 [Cart] $message');
    }
  }

  /// 服务相关日志
  static void serviceLog(String message) {
    if (isDebugMode && enableServiceLogs) {
      print('🔧 [Service] $message');
    }
  }

  /// Tab相关日志
  static void tabLog(String message) {
    if (isDebugMode && enableTabLogs) {
      print('📋 [Tab] $message');
    }
  }

  /// 数据相关日志
  static void dataLog(String message) {
    if (isDebugMode && enableDataLogs) {
      print('📊 [Data] $message');
    }
  }

  /// UI相关日志
  static void uiLog(String message) {
    if (isDebugMode && enableUILogs) {
      print('🎨 [UI] $message');
    }
  }

  /// 网络相关日志
  static void networkLog(String message) {
    if (isDebugMode && enableNetworkLogs) {
      print('🌐 [Network] $message');
    }
  }
}
