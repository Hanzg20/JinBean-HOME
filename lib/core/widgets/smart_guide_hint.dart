import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 智能提示组件
/// 会在显示几次后自动隐藏，节省界面空间
class SmartGuideHint extends StatefulWidget {
  /// 提示的唯一标识符
  final String hintId;

  /// 提示内容
  final String content;

  /// 图标
  final IconData? icon;

  /// 主题色
  final Color? primaryColor;

  /// 最大显示次数（默认3次）
  final int maxShowCount;

  /// 自动隐藏延迟（秒，null表示不自动隐藏）
  final int? autoHideDelay;

  /// 是否显示关闭按钮
  final bool showCloseButton;

  /// 是否紧凑模式
  final bool isCompact;

  const SmartGuideHint({
    super.key,
    required this.hintId,
    required this.content,
    this.icon,
    this.primaryColor = Colors.blue,
    this.maxShowCount = 3,
    this.autoHideDelay = 5,
    this.showCloseButton = true,
    this.isCompact = false,
  });

  @override
  State<SmartGuideHint> createState() => _SmartGuideHintState();
}

class _SmartGuideHintState extends State<SmartGuideHint>
    with SingleTickerProviderStateMixin {
  bool _shouldShow = false;
  bool _isVisible = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _checkAndShow();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAndShow() async {
    final prefs = await SharedPreferences.getInstance();
    final countKey = 'hint_${widget.hintId}_count';
    final dismissedKey = 'hint_${widget.hintId}_dismissed';

    // 检查是否被用户手动关闭
    final isDismissed = prefs.getBool(dismissedKey) ?? false;
    if (isDismissed) return;

    // 检查显示次数
    final showCount = prefs.getInt(countKey) ?? 0;
    if (showCount >= widget.maxShowCount) return;

    // 记录本次显示
    await prefs.setInt(countKey, showCount + 1);

    if (mounted) {
      setState(() {
        _shouldShow = true;
      });

      _animationController.forward();

      // 自动隐藏
      if (widget.autoHideDelay != null) {
        Future.delayed(Duration(seconds: widget.autoHideDelay!), () {
          if (mounted && _shouldShow) {
            _hide();
          }
        });
      }
    }
  }

  void _hide() {
    if (!mounted) return;

    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _shouldShow = false;
        });
      }
    });
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedKey = 'hint_${widget.hintId}_dismissed';
    await prefs.setBool(dismissedKey, true);
    _hide();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.all(widget.isCompact ? 8 : 12),
        padding: EdgeInsets.all(widget.isCompact ? 10 : 16),
        decoration: BoxDecoration(
          color: (widget.primaryColor ?? Colors.blue).withOpacity(0.08),
          borderRadius: BorderRadius.circular(widget.isCompact ? 8 : 12),
          border: Border.all(
            color: (widget.primaryColor ?? Colors.blue).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (widget.icon != null && !widget.isCompact) ...[
              Icon(
                widget.icon,
                color: widget.primaryColor ?? Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                widget.content,
                style: TextStyle(
                  fontSize: widget.isCompact ? 12 : 13,
                  color: Colors.grey[700],
                  height: 1.3,
                ),
              ),
            ),
            if (widget.showCloseButton) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _dismiss,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.close,
                    size: widget.isCompact ? 14 : 16,
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

/// 智能引导按钮
/// 显示一个小按钮，点击后展示完整引导信息
class SmartGuideButton extends StatelessWidget {
  /// 引导标识符
  final String guideId;

  /// 按钮文本
  final String buttonText;

  /// 引导标题
  final String guideTitle;

  /// 引导内容
  final String guideContent;

  /// 图标
  final IconData? icon;

  const SmartGuideButton({
    super.key,
    required this.guideId,
    required this.buttonText,
    required this.guideTitle,
    required this.guideContent,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _shouldShowButton(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: OutlinedButton.icon(
            onPressed: () => _showGuideDialog(context),
            icon: Icon(icon ?? Icons.help_outline, size: 16),
            label: Text(
              buttonText,
              style: const TextStyle(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(0, 32),
              side: BorderSide(color: Colors.blue[300]!),
              foregroundColor: Colors.blue[700],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _shouldShowButton() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedKey = 'guide_${guideId}_dismissed';
    return !(prefs.getBool(dismissedKey) ?? false);
  }

  void _showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(guideTitle)),
          ],
        ),
        content: Text(guideContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('guide_${guideId}_dismissed', true);
              Navigator.of(context).pop();
            },
            child: const Text('不再显示'),
          ),
        ],
      ),
    );
  }
}

/// 便捷的预定义引导组件
class MenuGuideHint extends StatelessWidget {
  const MenuGuideHint({super.key});

  @override
  Widget build(BuildContext context) {
    return const SmartGuideHint(
      hintId: 'overview_to_menu',
      content: '💡 如需选择具体菜品并加入购物车，请前往"Menu"标签',
      icon: Icons.restaurant_menu,
      primaryColor: Colors.blue,
      maxShowCount: 3,
      autoHideDelay: 5,
    );
  }
}

class TabLayoutGuideHint extends StatelessWidget {
  const TabLayoutGuideHint({super.key});

  @override
  Widget build(BuildContext context) {
    return const SmartGuideHint(
      hintId: 'tab_layout_switch',
      content: '🎨 Tab栏可以覆盖在轮播图上方，点击右上角切换按钮尝试',
      icon: Icons.layers,
      primaryColor: Colors.green,
      maxShowCount: 2,
      isCompact: true,
    );
  }
}

class CartGuideHint extends StatelessWidget {
  const CartGuideHint({super.key});

  @override
  Widget build(BuildContext context) {
    return const SmartGuideHint(
      hintId: 'cart_operation',
      content: '🛒 点击右上角购物车图标查看已添加的商品',
      icon: Icons.shopping_cart,
      primaryColor: Colors.orange,
      maxShowCount: 2,
      isCompact: true,
    );
  }
}
