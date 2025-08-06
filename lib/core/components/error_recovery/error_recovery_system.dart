import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../utils/app_logger.dart';

/// 平台级错误恢复系统
class PlatformErrorRecovery {
  /// 错误恢复配置
  static const ErrorRecoveryConfig defaultConfig = ErrorRecoveryConfig(
    maxRetries: 3,
    retryDelay: Duration(seconds: 2),
    exponentialBackoff: true,
    enableAutoRecovery: true,
    recoveryTimeout: Duration(seconds: 30),
  );

  /// 创建错误恢复组件
  static Widget create({
    required ErrorRecoveryType type,
    ErrorRecoveryConfig? config,
    required Widget Function(BuildContext) contentBuilder,
    required Future<void> Function() recoveryFunction,
    Widget? errorWidget,
    Widget? recoveryWidget,
  }) {
    return ErrorRecoveryWidget(
      type: type,
      config: config ?? defaultConfig,
      contentBuilder: contentBuilder,
      recoveryFunction: recoveryFunction,
      errorWidget: errorWidget,
      recoveryWidget: recoveryWidget,
    );
  }
}

/// 错误恢复类型
enum ErrorRecoveryType {
  automatic,   // 自动恢复
  manual,      // 手动恢复
  hybrid,      // 混合恢复
  intelligent, // 智能恢复
}

/// 错误恢复配置
class ErrorRecoveryConfig {
  final int maxRetries;
  final Duration retryDelay;
  final bool exponentialBackoff;
  final bool enableAutoRecovery;
  final Duration recoveryTimeout;
  
  const ErrorRecoveryConfig({
    required this.maxRetries,
    required this.retryDelay,
    required this.exponentialBackoff,
    required this.enableAutoRecovery,
    required this.recoveryTimeout,
  });
}

/// 错误状态枚举
enum ErrorState {
  normal,
  error,
  recovering,
}

/// 错误恢复组件
class ErrorRecoveryWidget extends StatefulWidget {
  final ErrorRecoveryType type;
  final ErrorRecoveryConfig config;
  final Widget Function(BuildContext) contentBuilder;
  final Future<void> Function() recoveryFunction;
  final Widget? errorWidget;
  final Widget? recoveryWidget;

  const ErrorRecoveryWidget({
    Key? key,
    required this.type,
    required this.config,
    required this.contentBuilder,
    required this.recoveryFunction,
    this.errorWidget,
    this.recoveryWidget,
  }) : super(key: key);

  @override
  State<ErrorRecoveryWidget> createState() => _ErrorRecoveryWidgetState();
}

class _ErrorRecoveryWidgetState extends State<ErrorRecoveryWidget> {
  ErrorState _errorState = ErrorState.normal;
  int _retryCount = 0;
  String? _errorMessage;
  Timer? _recoveryTimer;

  @override
  void initState() {
    super.initState();
    if (widget.config.enableAutoRecovery) {
      _startAutoRecovery();
    }
  }

  void _startAutoRecovery() {
    _recoveryTimer = Timer.periodic(widget.config.recoveryTimeout, (timer) {
      if (_errorState == ErrorState.error && _retryCount < widget.config.maxRetries) {
        _attemptRecovery();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _attemptRecovery() async {
    if (_errorState == ErrorState.recovering) return;
    
    setState(() {
      _errorState = ErrorState.recovering;
    });

    try {
      await widget.recoveryFunction();
      
      setState(() {
        _errorState = ErrorState.normal;
        _errorMessage = null;
        _retryCount = 0;
      });
      
      AppLogger.info('错误恢复成功');
    } catch (e) {
      _handleRecoveryError(e);
    }
  }

  void _handleRecoveryError(dynamic error) {
    _retryCount++;
    AppLogger.error('错误恢复失败: $error');
    
    if (_retryCount >= widget.config.maxRetries) {
      setState(() {
        _errorState = ErrorState.error;
        _errorMessage = error.toString();
      });
    } else {
      final delay = widget.config.exponentialBackoff
          ? widget.config.retryDelay * pow(2, _retryCount - 1)
          : widget.config.retryDelay;
      
      AppLogger.info('将在 ${delay.inSeconds} 秒后重试');
      Future.delayed(delay, _attemptRecovery);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_errorState) {
      case ErrorState.normal:
        return widget.contentBuilder(context);
      
      case ErrorState.recovering:
        return widget.recoveryWidget ?? 
               _buildRecoveryWidget();
      
      case ErrorState.error:
        return widget.errorWidget ?? 
               _buildErrorWidget();
    }
  }

  Widget _buildRecoveryWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Recovering...', style: TextStyle(fontSize: 16)), // 英文默认
          const SizedBox(height: 8),
          Text('Please wait, system is trying to recover', style: TextStyle(fontSize: 14)), // 英文默认
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error occurred', style: TextStyle(fontSize: 16)), // 英文默认
          const SizedBox(height: 8),
          Text(_errorMessage ?? 'Unknown error', style: TextStyle(fontSize: 14)), // 英文默认
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _retryCount = 0;
              _attemptRecovery();
            },
            child: Text('Retry'), // 英文默认
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _errorState = ErrorState.normal;
                _errorMessage = null;
                _retryCount = 0;
              });
            },
            child: Text('Ignore error'), // 英文默认
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _recoveryTimer?.cancel();
    super.dispose();
  }
}

/// 错误恢复管理器
class ErrorRecoveryManager {
  static final Map<String, ErrorRecoveryWidget> _errorWidgets = {};
  static final List<String> _errorHistory = [];
  
  /// 注册错误恢复组件
  static void register(String key, ErrorRecoveryWidget widget) {
    _errorWidgets[key] = widget;
  }
  
  /// 获取错误恢复组件
  static ErrorRecoveryWidget? get(String key) {
    return _errorWidgets[key];
  }
  
  /// 移除错误恢复组件
  static void remove(String key) {
    _errorWidgets.remove(key);
  }
  
  /// 清理所有错误恢复组件
  static void clear() {
    _errorWidgets.clear();
  }
  
  /// 记录错误
  static void recordError(String error) {
    _errorHistory.add(error);
    if (_errorHistory.length > 100) {
      _errorHistory.removeAt(0);
    }
  }
  
  /// 获取错误历史
  static List<String> get errorHistory => List.unmodifiable(_errorHistory);
  
  /// 清理错误历史
  static void clearErrorHistory() {
    _errorHistory.clear();
  }
} 