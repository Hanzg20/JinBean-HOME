import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 引导类型枚举
enum GuideType {
  /// Overview Tab引导（引导用户去Menu Tab购买）
  overviewToMenu,

  /// Tab Bar布局引导（介绍覆盖模式）
  tabBarLayout,

  /// 购物车操作引导
  cartOperation,

  /// 服务详情引导
  serviceDetails,
}

/// 引导配置
class GuideConfig {
  /// 引导类型
  final GuideType type;

  /// 最大显示次数
  final int maxShowCount;

  /// 标题
  final String title;

  /// 内容
  final String content;

  /// 图标
  final IconData? icon;

  /// 主要颜色
  final Color? primaryColor;

  /// 是否可关闭
  final bool canDismiss;

  /// 自动隐藏延迟（秒）
  final int? autoHideDelay;

  const GuideConfig({
    required this.type,
    this.maxShowCount = 3,
    required this.title,
    required this.content,
    this.icon,
    this.primaryColor,
    this.canDismiss = true,
    this.autoHideDelay,
  });
}

/// 用户引导管理器
class UserGuideManager {
  static final UserGuideManager _instance = UserGuideManager._internal();
  factory UserGuideManager() => _instance;
  UserGuideManager._internal();

  static UserGuideManager get instance => _instance;

  /// 预定义的引导配置
  static const Map<GuideType, GuideConfig> _guideConfigs = {
    GuideType.overviewToMenu: GuideConfig(
      type: GuideType.overviewToMenu,
      maxShowCount: 3,
      title: '💡 购买提示',
      content: '如需选择具体菜品并加入购物车，请前往"Menu"标签',
      icon: Icons.restaurant_menu,
      primaryColor: Colors.blue,
      canDismiss: true,
      autoHideDelay: 5,
    ),
    GuideType.tabBarLayout: GuideConfig(
      type: GuideType.tabBarLayout,
      maxShowCount: 2,
      title: '🎨 布局切换',
      content: 'Tab栏可以覆盖在轮播图上方，点击右上角切换按钮尝试',
      icon: Icons.layers,
      primaryColor: Colors.green,
      canDismiss: true,
    ),
    GuideType.cartOperation: GuideConfig(
      type: GuideType.cartOperation,
      maxShowCount: 2,
      title: '🛒 购物车',
      content: '点击右上角购物车图标查看已添加的商品',
      icon: Icons.shopping_cart,
      primaryColor: Colors.orange,
      canDismiss: true,
    ),
    GuideType.serviceDetails: GuideConfig(
      type: GuideType.serviceDetails,
      maxShowCount: 2,
      title: '📋 服务详情',
      content: '点击菜品卡片查看详细信息和价格',
      icon: Icons.info_outline,
      primaryColor: Colors.purple,
      canDismiss: true,
    ),
  };

  /// 检查引导是否应该显示
  Future<bool> shouldShowGuide(GuideType type) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'guide_${type.name}';

    // 检查是否被用户手动关闭
    final isDismissed = prefs.getBool('${key}_dismissed') ?? false;
    if (isDismissed) return false;

    // 检查显示次数
    final showCount = prefs.getInt('${key}_count') ?? 0;
    final config = _guideConfigs[type];
    if (config == null) return false;

    return showCount < config.maxShowCount;
  }

  /// 记录引导显示
  Future<void> recordGuideShown(GuideType type) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'guide_${type.name}';
    final currentCount = prefs.getInt('${key}_count') ?? 0;
    await prefs.setInt('${key}_count', currentCount + 1);
  }

  /// 用户手动关闭引导
  Future<void> dismissGuide(GuideType type) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'guide_${type.name}';
    await prefs.setBool('${key}_dismissed', true);
  }

  /// 重置引导状态（开发调试用）
  Future<void> resetGuide(GuideType type) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'guide_${type.name}';
    await prefs.remove('${key}_count');
    await prefs.remove('${key}_dismissed');
  }

  /// 重置所有引导状态
  Future<void> resetAllGuides() async {
    for (final type in GuideType.values) {
      await resetGuide(type);
    }
  }

  /// 获取引导配置
  GuideConfig? getGuideConfig(GuideType type) {
    return _guideConfigs[type];
  }
}

/// 智能引导组件
class SmartGuideWidget extends StatefulWidget {
  /// 引导类型
  final GuideType guideType;

  /// 子组件
  final Widget child;

  /// 是否自动显示
  final bool autoShow;

  /// 自定义引导配置
  final GuideConfig? customConfig;

  const SmartGuideWidget({
    super.key,
    required this.guideType,
    required this.child,
    this.autoShow = true,
    this.customConfig,
  });

  @override
  State<SmartGuideWidget> createState() => _SmartGuideWidgetState();
}

class _SmartGuideWidgetState extends State<SmartGuideWidget> {
  bool _showGuide = false;
  bool _isVisible = true;
  late GuideConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.customConfig ??
        UserGuideManager.instance.getGuideConfig(widget.guideType) ??
        const GuideConfig(
          type: GuideType.overviewToMenu,
          title: '提示',
          content: '这是一个引导提示',
        );

    if (widget.autoShow) {
      _checkAndShowGuide();
    }
  }

  Future<void> _checkAndShowGuide() async {
    final shouldShow =
        await UserGuideManager.instance.shouldShowGuide(widget.guideType);
    if (shouldShow && mounted) {
      setState(() {
        _showGuide = true;
      });

      // 记录显示
      await UserGuideManager.instance.recordGuideShown(widget.guideType);

      // 自动隐藏
      if (_config.autoHideDelay != null) {
        Future.delayed(Duration(seconds: _config.autoHideDelay!), () {
          if (mounted && _showGuide) {
            _hideGuide();
          }
        });
      }
    }
  }

  void _hideGuide() {
    setState(() {
      _isVisible = false;
    });

    // 动画结束后隐藏
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showGuide = false;
          _isVisible = true; // 重置为下次显示做准备
        });
      }
    });
  }

  void _dismissGuide() {
    UserGuideManager.instance.dismissGuide(widget.guideType);
    _hideGuide();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showGuide) _buildGuideOverlay(),
      ],
    );
  }

  Widget _buildGuideOverlay() {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (_config.primaryColor ?? Colors.blue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _config.primaryColor ?? Colors.blue,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (_config.icon != null) ...[
              Icon(
                _config.icon,
                color: _config.primaryColor ?? Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _config.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _config.primaryColor ?? Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _config.content,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (_config.canDismiss) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _dismissGuide,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 引导气泡组件
class GuideBubble extends StatelessWidget {
  /// 引导类型
  final GuideType guideType;

  /// 是否紧凑模式
  final bool isCompact;

  /// 点击回调
  final VoidCallback? onTap;

  /// 关闭回调
  final VoidCallback? onDismiss;

  const GuideBubble({
    super.key,
    required this.guideType,
    this.isCompact = false,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final config = UserGuideManager.instance.getGuideConfig(guideType);
    if (config == null) return const SizedBox.shrink();

    return FutureBuilder<bool>(
      future: UserGuideManager.instance.shouldShowGuide(guideType),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!) {
          return const SizedBox.shrink();
        }

        // 记录显示
        UserGuideManager.instance.recordGuideShown(guideType);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(isCompact ? 8 : 12),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: (config.primaryColor ?? Colors.blue).withOpacity(0.05),
              borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
              border: Border.all(
                color: (config.primaryColor ?? Colors.blue).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (config.icon != null && !isCompact) ...[
                  Icon(
                    config.icon,
                    color: config.primaryColor ?? Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isCompact) ...[
                        Text(
                          config.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: config.primaryColor ?? Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        config.content,
                        style: TextStyle(
                          fontSize: isCompact ? 11 : 12,
                          color: Colors.grey[700],
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (config.canDismiss) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      UserGuideManager.instance.dismissGuide(guideType);
                      onDismiss?.call();
                    },
                    child: Icon(
                      Icons.close,
                      size: isCompact ? 14 : 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
