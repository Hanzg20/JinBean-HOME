import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../../core/utils/app_logger.dart';

/// 服务详情页面加载状态设计
/// 包含骨架屏、渐进式加载、离线支持和错误恢复机制

// ==================== 1. 骨架屏设计 ====================

/// 基础骨架屏组件
class ShimmerSkeleton extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerSkeleton({
    Key? key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1000), // 减少动画时长
  }) : super(key: key);

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.baseColor ?? theme.colorScheme.surfaceVariant;
    final highlightColor = widget.highlightColor ?? theme.colorScheme.surface;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// 服务详情页面骨架屏
class ServiceDetailSkeleton extends StatelessWidget {
  const ServiceDetailSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero区域骨架屏
          _buildHeroSkeleton(),
          const SizedBox(height: 16),
          
          // 操作按钮骨架屏
          _buildActionButtonsSkeleton(),
          const SizedBox(height: 24),
          
          // Tab栏骨架屏
          _buildTabBarSkeleton(),
          const SizedBox(height: 16),
          
          // 内容区域骨架屏
          _buildContentSkeleton(),
        ],
      ),
    );
  }

  Widget _buildHeroSkeleton() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // 图片骨架屏
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          // 信息骨架屏
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerSkeleton(
                    child: Container(
                      height: 24,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ShimmerSkeleton(
                    child: Container(
                      height: 16,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsSkeleton() {
    return Row(
      children: [
        Expanded(
          child: ShimmerSkeleton(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ShimmerSkeleton(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBarSkeleton() {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ShimmerSkeleton(
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContentSkeleton() {
    return Column(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ShimmerSkeleton(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ==================== 2. 渐进式加载组件 ====================

/// 渐进式加载组件
class ProgressiveLoadingWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Curve curve;
  final bool enabled;

  const ProgressiveLoadingWidget({
    Key? key,
    required this.child,
    this.delay = Duration.zero,
    this.curve = Curves.easeInOut,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ProgressiveLoadingWidget> createState() => _ProgressiveLoadingWidgetState();
}

class _ProgressiveLoadingWidgetState extends State<ProgressiveLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300), // 减少动画时长
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (widget.enabled) {
      _startAnimation();
    } else {
      _isVisible = true;
      _controller.value = 1.0;
    }
  }

  void _startAnimation() async {
    await Future.delayed(widget.delay);
    if (mounted) {
      setState(() => _isVisible = true);
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _animation.value)),
            child: widget.child,
          ),
        );
      },
    );
  }
}

// ==================== 3. 离线支持组件 ====================

/// 离线状态组件
class OfflineSupportWidget extends StatelessWidget {
  final Widget child;
  final bool isOnline;
  final VoidCallback? onRetry;
  final String? offlineMessage;

  const OfflineSupportWidget({
    Key? key,
    required this.child,
    required this.isOnline,
    this.onRetry,
    this.offlineMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isOnline) {
      return child;
    }

    return Column(
      children: [
        // 离线提示条
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.orange.withOpacity(0.1),
          child: Row(
            children: [
              Icon(
                Icons.wifi_off,
                size: 16,
                color: Colors.orange[700],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  offlineMessage ?? '当前处于离线状态，部分功能可能受限',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                  ),
                ),
              ),
              if (onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  child: Text(
                    '重试',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
            ],
          ),
        ),
        // 离线内容（使用缓存数据）
        Expanded(child: child),
      ],
    );
  }
}

// ==================== 4. 错误恢复组件 ====================

/// 错误状态组件
class ServiceDetailError extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const ServiceDetailError({
    Key? key,
    required this.message,
    this.title,
    this.icon,
    this.onRetry,
    this.onBack,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 错误图标
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 40,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),

            // 错误标题
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],

            // 错误消息
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 操作按钮
            if (onRetry != null || onBack != null || actions != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onBack != null) ...[
                    OutlinedButton(
                      onPressed: onBack,
                      child: const Text('返回'),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (onRetry != null)
                    ElevatedButton(
                      onPressed: onRetry,
                      child: const Text('重试'),
                    ),
                ],
              ),
              if (actions != null) ...[
                const SizedBox(height: 16),
                ...actions!,
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// 网络错误组件
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onBack;

  const NetworkErrorWidget({
    Key? key,
    this.onRetry,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ServiceDetailError(
      title: '网络连接失败',
      message: '无法连接到服务器，请检查网络连接后重试',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      onBack: onBack,
    );
  }
}

/// 数据加载错误组件
class DataLoadErrorWidget extends StatelessWidget {
  final String serviceName;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;

  const DataLoadErrorWidget({
    Key? key,
    required this.serviceName,
    this.onRetry,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ServiceDetailError(
      title: '加载失败',
      message: '无法加载 $serviceName 的详细信息，请稍后重试',
      icon: Icons.broken_image,
      onRetry: onRetry,
      onBack: onBack,
    );
  }
}

// ==================== 5. 加载状态管理器 ====================

/// 加载状态枚举
enum LoadingState {
  initial,
  loading,
  success,
  error,
  offline,
}

/// 加载状态管理器
class LoadingStateManager extends ChangeNotifier {
  LoadingState _state = LoadingState.initial;
  String _errorMessage = '';
  bool _isOnline = true;
  Timer? _retryTimer;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  LoadingState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isOnline => _isOnline;
  int get retryCount => _retryCount;

  void setLoading() {
    AppLogger.debug('LoadingStateManager.setLoading() called');
    _state = LoadingState.loading;
    _errorMessage = '';
    notifyListeners();
  }

  void setSuccess() {
    AppLogger.debug('LoadingStateManager.setSuccess() called');
    _state = LoadingState.success;
    _errorMessage = '';
    _retryCount = 0;
    AppLogger.debug('LoadingStateManager.setSuccess() - notifying listeners');
    notifyListeners();
    AppLogger.debug('LoadingStateManager.setSuccess() - listeners notified');
  }

  void setError(String message) {
    AppLogger.debug('LoadingStateManager.setError() called with message: $message');
    _state = LoadingState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void setOffline() {
    AppLogger.debug('LoadingStateManager.setOffline() called');
    _state = LoadingState.offline;
    _isOnline = false;
    notifyListeners();
  }

  void setOnline() {
    AppLogger.debug('LoadingStateManager.setOnline() called');
    _isOnline = true;
    if (_state == LoadingState.offline) {
      _state = LoadingState.initial;
    }
    notifyListeners();
  }

  Future<void> retry(Future<void> Function() operation) async {
    AppLogger.debug('LoadingStateManager.retry() called, retryCount: $_retryCount');
    if (_retryCount >= _maxRetries) {
      AppLogger.debug('Max retries reached, setting error');
      setError('重试次数已达上限，请稍后重试');
      return;
    }

    _retryCount++;
    setLoading();

    try {
      AppLogger.debug('Executing operation...');
      await operation();
      AppLogger.debug('Operation completed successfully, setting success');
      setSuccess();
    } catch (e) {
      AppLogger.debug('Operation failed with error: $e');
      setError(e.toString());
      
      // 自动重试
      if (_retryCount < _maxRetries) {
        _retryTimer?.cancel();
        _retryTimer = Timer(
          Duration(seconds: _retryCount * 2), // 递增延迟
          () => retry(operation),
        );
      }
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }
}

// ==================== 6. 主加载组件 ====================

/// 服务详情页面主加载组件
class ServiceDetailLoading extends StatelessWidget {
  final LoadingState state;
  final Widget? child;
  final String? loadingMessage;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;
  final bool showSkeleton;

  const ServiceDetailLoading({
    Key? key,
    required this.state,
    this.child,
    this.loadingMessage,
    this.errorMessage,
    this.onRetry,
    this.onBack,
    this.showSkeleton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('ServiceDetailLoading.build() called with state: $state');
    AppLogger.debug('ServiceDetailLoading - child is null: ${child == null}');
    AppLogger.debug('ServiceDetailLoading - showSkeleton: $showSkeleton');
    
    switch (state) {
      case LoadingState.initial:
        AppLogger.debug('ServiceDetailLoading - showing initial state (loading)');
        return showSkeleton 
            ? const ServiceDetailSkeleton()
            : _buildLoadingIndicator(context);
      
      case LoadingState.loading:
        AppLogger.debug('ServiceDetailLoading - showing loading state');
        return showSkeleton 
            ? const ServiceDetailSkeleton()
            : _buildLoadingIndicator(context);
      
      case LoadingState.success:
        AppLogger.debug('ServiceDetailLoading - showing success state with child: ${child != null ? 'has child' : 'no child'}');
        return child ?? const SizedBox.shrink();
      
      case LoadingState.error:
        AppLogger.debug('ServiceDetailLoading - showing error state');
        return ServiceDetailError(
          message: errorMessage ?? '加载失败，请重试',
          onRetry: onRetry,
          onBack: onBack,
        );
      
      case LoadingState.offline:
        AppLogger.debug('ServiceDetailLoading - showing offline state');
        return OfflineSupportWidget(
          isOnline: false,
          onRetry: onRetry,
            child: child ?? const SizedBox.shrink(),
        );
    }
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (loadingMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              loadingMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
