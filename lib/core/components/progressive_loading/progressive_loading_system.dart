import 'package:flutter/material.dart';
import 'dart:async';
import '../../utils/app_logger.dart';

/// 平台级渐进式加载系统
class PlatformProgressiveLoading {
  /// 渐进式加载配置
  static const ProgressiveConfig defaultConfig = ProgressiveConfig(
    initialLoadDelay: Duration(milliseconds: 300),
    progressiveDelay: Duration(milliseconds: 200),
    maxRetries: 3,
    retryDelay: Duration(seconds: 2),
  );

  /// 创建渐进式加载组件
  static Widget create({
    required ProgressiveType type,
    ProgressiveConfig? config,
    required Future<void> Function() loadFunction,
    required Widget Function(BuildContext) contentBuilder,
    Widget? loadingWidget,
    Widget? errorWidget,
  }) {
    return ProgressiveLoadingWidget(
      type: type,
      config: config ?? defaultConfig,
      loadFunction: loadFunction,
      contentBuilder: contentBuilder,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
    );
  }
}

/// 渐进式加载类型
enum ProgressiveType {
  sequential,  // 顺序加载
  parallel,    // 并行加载
  priority,    // 优先级加载
  lazy,        // 懒加载
}

/// 渐进式加载配置
class ProgressiveConfig {
  final Duration initialLoadDelay;
  final Duration progressiveDelay;
  final int maxRetries;
  final Duration retryDelay;
  
  const ProgressiveConfig({
    required this.initialLoadDelay,
    required this.progressiveDelay,
    required this.maxRetries,
    required this.retryDelay,
  });
}

/// 加载状态枚举
enum LoadingState {
  initial,
  loading,
  success,
  error,
  offline,
}

/// 渐进式加载组件
class ProgressiveLoadingWidget extends StatefulWidget {
  final ProgressiveType type;
  final ProgressiveConfig config;
  final Future<void> Function() loadFunction;
  final Widget Function(BuildContext) contentBuilder;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const ProgressiveLoadingWidget({
    Key? key,
    required this.type,
    required this.config,
    required this.loadFunction,
    required this.contentBuilder,
    this.loadingWidget,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<ProgressiveLoadingWidget> createState() => _ProgressiveLoadingWidgetState();
}

class _ProgressiveLoadingWidgetState extends State<ProgressiveLoadingWidget> {
  LoadingState _loadingState = LoadingState.initial;
  int _retryCount = 0;
  String? _errorMessage;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  Future<void> _startLoading() async {
    if (_loadingState == LoadingState.loading) return;
    
    setState(() {
      _loadingState = LoadingState.loading;
      _errorMessage = null;
      _progress = 0.0;
    });

    try {
      // 初始延迟
      await Future.delayed(widget.config.initialLoadDelay);
      
      // 根据类型执行不同的加载策略
      switch (widget.type) {
        case ProgressiveType.sequential:
          await _sequentialLoading();
          break;
        case ProgressiveType.parallel:
          await _parallelLoading();
          break;
        case ProgressiveType.priority:
          await _priorityLoading();
          break;
        case ProgressiveType.lazy:
          await _lazyLoading();
          break;
      }
      
      setState(() {
        _loadingState = LoadingState.success;
        _progress = 1.0;
      });
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _sequentialLoading() async {
    // 顺序加载：逐步加载数据
    final steps = ['初始化', '加载基础数据', '加载详细信息', '加载相关数据'];
    
    for (int i = 0; i < steps.length; i++) {
      if (!mounted) return;
      
      setState(() {
        _progress = (i + 1) / steps.length;
      });
      
      AppLogger.debug('执行步骤: ${steps[i]}');
      
      // 模拟每个步骤的加载时间
      await Future.delayed(widget.config.progressiveDelay);
    }
    
    // 执行实际的加载函数
    await widget.loadFunction();
  }

  Future<void> _parallelLoading() async {
    // 并行加载：同时加载多个数据源
    final futures = [
      _loadData('数据源1'),
      _loadData('数据源2'),
      _loadData('数据源3'),
    ];
    
    await Future.wait(futures);
    await widget.loadFunction();
  }

  Future<void> _priorityLoading() async {
    // 优先级加载：先加载重要数据，再加载次要数据
    // 高优先级数据
    await _loadData('高优先级数据');
    setState(() => _progress = 0.3);
    
    // 中优先级数据
    await _loadData('中优先级数据');
    setState(() => _progress = 0.6);
    
    // 低优先级数据
    await _loadData('低优先级数据');
    setState(() => _progress = 0.9);
    
    await widget.loadFunction();
  }

  Future<void> _lazyLoading() async {
    // 懒加载：按需加载数据
    await widget.loadFunction();
  }

  Future<void> _loadData(String dataSource) async {
    // 模拟数据加载
    await Future.delayed(Duration(milliseconds: 200 + (dataSource.length * 10)));
    AppLogger.debug('加载完成: $dataSource');
  }

  void _handleError(dynamic error) {
    AppLogger.error('加载失败: $error');
    
    if (_retryCount < widget.config.maxRetries) {
      _retryCount++;
      AppLogger.info('重试第 $_retryCount 次');
      
      Future.delayed(widget.config.retryDelay, _startLoading);
    } else {
      setState(() {
        _loadingState = LoadingState.error;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_loadingState) {
      case LoadingState.initial:
      case LoadingState.loading:
        return widget.loadingWidget ?? 
               _buildDefaultLoadingWidget();
      
      case LoadingState.success:
        return widget.contentBuilder(context);
      
      case LoadingState.error:
        return widget.errorWidget ?? 
               _buildErrorWidget();
      
      case LoadingState.offline:
        return _buildOfflineWidget();
    }
  }

  Widget _buildDefaultLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            value: _progress,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            '加载中... ${(_progress * 100).toInt()}%',
            style: const TextStyle(fontSize: 16),
          ),
          if (_progress > 0 && _progress < 1)
            Padding(
              padding: const EdgeInsets.all(16),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
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
          Text('Loading failed', style: TextStyle(fontSize: 16)), // 英文默认
          const SizedBox(height: 8),
          Text(_errorMessage ?? 'Unknown error', style: TextStyle(fontSize: 14)), // 英文默认
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _retryCount = 0;
              _startLoading();
            },
            child: Text('Retry'), // 英文默认
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text('Offline mode', style: TextStyle(fontSize: 16)), // 英文默认
          const SizedBox(height: 8),
          Text('Currently offline, some features may not be available', style: TextStyle(fontSize: 14)), // 英文默认
        ],
      ),
    );
  }
}

/// 渐进式加载管理器
class ProgressiveLoadingManager {
  static final Map<String, ProgressiveLoadingWidget> _loadingWidgets = {};
  
  /// 注册加载组件
  static void register(String key, ProgressiveLoadingWidget widget) {
    _loadingWidgets[key] = widget;
  }
  
  /// 获取加载组件
  static ProgressiveLoadingWidget? get(String key) {
    return _loadingWidgets[key];
  }
  
  /// 移除加载组件
  static void remove(String key) {
    _loadingWidgets.remove(key);
  }
  
  /// 清理所有加载组件
  static void clear() {
    _loadingWidgets.clear();
  }
} 