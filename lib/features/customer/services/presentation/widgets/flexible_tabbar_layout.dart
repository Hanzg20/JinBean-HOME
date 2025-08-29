import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Tab Bar布局模式
enum TabBarLayoutMode {
  /// 展开模式：Tab Bar在轮播图下方
  expanded,

  /// 覆盖模式：Tab Bar覆盖在轮播图上方
  overlay,

  /// 紧凑模式：Tab Bar置顶，轮播图缩小
  compact,
}

/// Tab Bar布局配置
class TabBarLayoutConfig {
  final TabBarLayoutMode mode;
  final double overlayOpacity;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool enableGestures;

  const TabBarLayoutConfig({
    this.mode = TabBarLayoutMode.expanded,
    this.overlayOpacity = 1.0, // 完全不透明
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.enableGestures = true,
  });

  static const defaultConfig = TabBarLayoutConfig();

  TabBarLayoutConfig copyWith({
    TabBarLayoutMode? mode,
    double? overlayOpacity,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? enableGestures,
  }) {
    return TabBarLayoutConfig(
      mode: mode ?? this.mode,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      enableGestures: enableGestures ?? this.enableGestures,
    );
  }
}

/// 灵活的Tab Bar布局组件
class FlexibleTabBarLayout extends StatefulWidget {
  final Widget imageCarousel;
  final TabBar tabBar;
  final Widget tabBarView;
  final TabBarLayoutConfig config;
  final Function(TabBarLayoutMode)? onModeChanged;

  const FlexibleTabBarLayout({
    super.key,
    required this.imageCarousel,
    required this.tabBar,
    required this.tabBarView,
    this.config = TabBarLayoutConfig.defaultConfig,
    this.onModeChanged,
  });

  @override
  State<FlexibleTabBarLayout> createState() => _FlexibleTabBarLayoutState();
}

class _FlexibleTabBarLayoutState extends State<FlexibleTabBarLayout>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _tabBarAnimation;
  late Animation<double> _carouselAnimation;

  late TabBarLayoutMode _currentMode;
  double _gestureStartY = 0;
  bool _isGestureActive = false;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.config.mode;

    _animationController = AnimationController(
      duration: widget.config.animationDuration,
      vsync: this,
    );

    _tabBarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.config.animationCurve,
    ));

    _carouselAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.config.animationCurve,
    ));

    // 设置初始动画状态
    if (_currentMode == TabBarLayoutMode.overlay ||
        _currentMode == TabBarLayoutMode.compact) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 切换到指定模式
  void switchToMode(TabBarLayoutMode mode) {
    if (_currentMode == mode) return;

    if (!mounted) return; // 确保组件仍然挂载

    try {
      setState(() {
        _currentMode = mode;
      });

      switch (mode) {
        case TabBarLayoutMode.expanded:
          _animationController.reverse();
          break;
        case TabBarLayoutMode.overlay:
        case TabBarLayoutMode.compact:
          _animationController.forward();
          break;
      }

      if (mounted) {
        widget.onModeChanged?.call(mode);
      }
    } catch (e) {
      // 捕获状态更新错误
      if (kDebugMode) {
        print('TabBar layout error: $e');
      }
    }
  }

  /// 处理垂直拖拽手势
  void _handleVerticalDrag(DragUpdateDetails details) {
    if (!widget.config.enableGestures) return;
    if (!mounted) return; // 防止状态错误

    final deltaY = details.delta.dy;

    // 上滑切换到覆盖模式，下滑切换到展开模式
    if (deltaY < -10 && _currentMode == TabBarLayoutMode.expanded) {
      // 上滑 -> 覆盖模式
      switchToMode(TabBarLayoutMode.overlay);
    } else if (deltaY > 10 && _currentMode == TabBarLayoutMode.overlay) {
      // 下滑 -> 展开模式
      switchToMode(TabBarLayoutMode.expanded);
    }
  }

  /// 构建展开布局
  Widget _buildExpandedLayout(BuildContext context) {
    return Column(
      children: [
        // 轮播图区域
        SizedBox(
          height: 300,
          child: widget.imageCarousel,
        ),
        // Tab Bar
        widget.tabBar,
        // Tab 内容
        Expanded(
          child: widget.tabBarView,
        ),
      ],
    );
  }

  /// 构建覆盖布局
  Widget _buildOverlayLayout(BuildContext context) {
    return Stack(
      children: [
        // 轮播图背景
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _carouselAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _carouselAnimation.value,
                child: widget.imageCarousel,
              );
            },
          ),
        ),

        // Tab Bar 覆盖层
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: _tabBarAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -50 * (1 - _tabBarAnimation.value)),
                child: Opacity(
                  opacity:
                      _tabBarAnimation.value * widget.config.overlayOpacity,
                  child: Container(
                    decoration: BoxDecoration(
                      // 使用渐变背景确保完全遮盖
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.surface,
                          Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.98),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    // 添加内边距确保内容不被遮挡
                    padding: const EdgeInsets.only(bottom: 8),
                    child: widget.tabBar,
                  ),
                ),
              );
            },
          ),
        ),

        // Tab 内容区域
        Positioned(
          top: 80, // Tab Bar 高度
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface, // 添加不透明背景
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16), // 圆角设计
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: widget.tabBarView,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建紧凑布局
  Widget _buildCompactLayout(BuildContext context) {
    return Column(
      children: [
        // Tab Bar 置顶
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.tabBar,
        ),

        // 缩小的轮播图和Tab内容
        Expanded(
          child: Stack(
            children: [
              // 缩小的轮播图
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 200, // 缩小后的高度
                child: AnimatedBuilder(
                  animation: _carouselAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _carouselAnimation.value,
                      child: widget.imageCarousel,
                    );
                  },
                ),
              ),

              // Tab 内容
              Positioned(
                top: 200,
                left: 0,
                right: 0,
                bottom: 0,
                child: widget.tabBarView,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget layout;

    switch (_currentMode) {
      case TabBarLayoutMode.expanded:
        layout = _buildExpandedLayout(context);
        break;
      case TabBarLayoutMode.overlay:
        layout = _buildOverlayLayout(context);
        break;
      case TabBarLayoutMode.compact:
        layout = _buildCompactLayout(context);
        break;
    }

    return GestureDetector(
      onPanUpdate: widget.config.enableGestures ? _handleVerticalDrag : null,
      child: layout,
    );
  }
}

/// Tab Bar布局切换器
class TabBarLayoutSwitcher extends StatelessWidget {
  final TabBarLayoutConfig config;
  final Function(TabBarLayoutMode) onModeChanged;

  const TabBarLayoutSwitcher({
    super.key,
    required this.config,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TabBarLayoutMode>(
      icon: _getLayoutIcon(config.mode),
      tooltip: 'Tab布局选项',
      onSelected: onModeChanged,
      itemBuilder: (context) => [
        _buildMenuItem(
          TabBarLayoutMode.expanded,
          Icons.expand_more,
          '展开模式',
          'Tab Bar在轮播图下方',
          config.mode,
        ),
        _buildMenuItem(
          TabBarLayoutMode.overlay,
          Icons.layers,
          '覆盖模式',
          'Tab Bar覆盖轮播图',
          config.mode,
        ),
        _buildMenuItem(
          TabBarLayoutMode.compact,
          Icons.compress,
          '紧凑模式',
          'Tab Bar置顶，图片缩小',
          config.mode,
        ),
      ],
    );
  }

  Icon _getLayoutIcon(TabBarLayoutMode mode) {
    switch (mode) {
      case TabBarLayoutMode.expanded:
        return const Icon(Icons.expand_more, size: 22);
      case TabBarLayoutMode.overlay:
        return const Icon(Icons.layers, size: 22);
      case TabBarLayoutMode.compact:
        return const Icon(Icons.compress, size: 22);
    }
  }

  PopupMenuItem<TabBarLayoutMode> _buildMenuItem(
    TabBarLayoutMode mode,
    IconData icon,
    String title,
    String subtitle,
    TabBarLayoutMode currentMode,
  ) {
    final isSelected = mode == currentMode;

    return PopupMenuItem<TabBarLayoutMode>(
      value: mode,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.blue : null,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing:
            isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
        dense: true,
      ),
    );
  }
}
