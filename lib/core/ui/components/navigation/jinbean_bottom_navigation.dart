import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';

/// JinBean 底部导航栏项目
class JinBeanBottomNavItem {
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String? badge;
  final VoidCallback? onTap;

  const JinBeanBottomNavItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
    this.onTap,
  });
}

/// JinBean 底部导航栏组件
/// 真正的 My Diary 风格现代化底部导航栏
class JinBeanBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final List<JinBeanBottomNavItem> items;
  final ValueChanged<int>? onTap;
  final bool showLabels;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double elevation;
  final bool enableGradient;
  final Widget? centerButton;
  final VoidCallback? onCenterButtonTap;

  const JinBeanBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.items,
    this.onTap,
    this.showLabels = true,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation = 16.0,
    this.enableGradient = true,
    this.centerButton,
    this.onCenterButtonTap,
  });

  @override
  State<JinBeanBottomNavigation> createState() => _JinBeanBottomNavigationState();
}

class _JinBeanBottomNavigationState extends State<JinBeanBottomNavigation>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    animationController?.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        AnimatedBuilder(
          animation: animationController!,
          builder: (BuildContext context, Widget? child) {
            return Transform(
              transform: Matrix4.translationValues(0.0, 0.0, 0.0),
              child: PhysicalShape(
                color: widget.backgroundColor ?? JinBeanColors.surface,
                elevation: widget.elevation,
                clipper: JinBeanTabClipper(
                  radius: Tween<double>(begin: 0.0, end: 1.0)
                          .animate(CurvedAnimation(
                              parent: animationController!,
                              curve: Curves.fastOutSlowIn))
                          .value *
                      38.0,
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 62,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: _buildTabIcon(
                                item: widget.items[0],
                                index: 0,
                                isSelected: widget.currentIndex == 0,
                              ),
                            ),
                            Expanded(
                              child: _buildTabIcon(
                                item: widget.items[1],
                                index: 1,
                                isSelected: widget.currentIndex == 1,
                              ),
                            ),
                            SizedBox(
                              width: Tween<double>(begin: 0.0, end: 1.0)
                                      .animate(CurvedAnimation(
                                          parent: animationController!,
                                          curve: Curves.fastOutSlowIn))
                                      .value *
                                  64.0,
                            ),
                            Expanded(
                              child: _buildTabIcon(
                                item: widget.items[2],
                                index: 2,
                                isSelected: widget.currentIndex == 2,
                              ),
                            ),
                            Expanded(
                              child: _buildTabIcon(
                                item: widget.items[3],
                                index: 3,
                                isSelected: widget.currentIndex == 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom,
                    )
                  ],
                ),
              ),
            );
          },
        ),
        // 中央浮动按钮
        if (widget.centerButton != null) ...[
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: SizedBox(
              width: 38 * 2.0,
              height: 38 + 62.0,
              child: Container(
                alignment: Alignment.topCenter,
                color: Colors.transparent,
                child: SizedBox(
                  width: 38 * 2.0,
                  height: 38 * 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ScaleTransition(
                      alignment: Alignment.center,
                      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                              parent: animationController!,
                              curve: Curves.fastOutSlowIn)),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              JinBeanColors.primary,
                              JinBeanColors.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: JinBeanColors.primary.withOpacity(0.4),
                              offset: const Offset(8.0, 16.0),
                              blurRadius: 16.0,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.white.withOpacity(0.1),
                            highlightColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            onTap: widget.onCenterButtonTap,
                            child: widget.centerButton,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTabIcon({
    required JinBeanBottomNavItem item,
    required int index,
    required bool isSelected,
  }) {
    return AspectRatio(
      aspectRatio: 1,
      child: Center(
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: () {
            widget.onTap?.call(index);
          },
          child: IgnorePointer(
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                ScaleTransition(
                  alignment: Alignment.center,
                  scale: Tween<double>(begin: 0.88, end: 1.0).animate(
                      CurvedAnimation(
                          parent: animationController!,
                          curve: Interval(0.1, 1.0, curve: Curves.fastOutSlowIn))),
                  child: Icon(
                    isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
                    color: isSelected 
                        ? (widget.selectedItemColor ?? JinBeanColors.primary)
                        : (widget.unselectedItemColor ?? JinBeanColors.textSecondary),
                    size: 24,
                  ),
                ),
                if (isSelected) ...[
                  Positioned(
                    top: 4,
                    left: 6,
                    right: 0,
                    child: ScaleTransition(
                      alignment: Alignment.center,
                      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                              parent: animationController!,
                              curve: Interval(0.2, 1.0, curve: Curves.fastOutSlowIn))),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: JinBeanColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 6,
                    bottom: 8,
                    child: ScaleTransition(
                      alignment: Alignment.center,
                      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                              parent: animationController!,
                              curve: Interval(0.5, 0.8, curve: Curves.fastOutSlowIn))),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: JinBeanColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 8,
                    bottom: 0,
                    child: ScaleTransition(
                      alignment: Alignment.center,
                      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                              parent: animationController!,
                              curve: Interval(0.5, 0.6, curve: Curves.fastOutSlowIn))),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: JinBeanColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
                if (item.badge != null && item.badge!.isNotEmpty) ...[
                  Positioned(
                    right: 8,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: JinBeanColors.error,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        item.badge!,
                        style: JinBeanTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: JinBeanTypography.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// JinBean 底部导航栏弧形裁剪器
class JinBeanTabClipper extends CustomClipper<Path> {
  JinBeanTabClipper({this.radius = 38.0});

  final double radius;

  @override
  Path getClip(Size size) {
    final Path path = Path();

    final double v = radius * 2;
    path.lineTo(0, 0);
    path.arcTo(Rect.fromLTWH(0, 0, radius, radius), degreeToRadians(180),
        degreeToRadians(90), false);
    path.arcTo(
        Rect.fromLTWH(
            ((size.width / 2) - v / 2) - radius + v * 0.04, 0, radius, radius),
        degreeToRadians(270),
        degreeToRadians(70),
        false);

    path.arcTo(Rect.fromLTWH((size.width / 2) - v / 2, -v / 2, v, v),
        degreeToRadians(160), degreeToRadians(-140), false);

    path.arcTo(
        Rect.fromLTWH((size.width - ((size.width / 2) - v / 2)) - v * 0.04, 0,
            radius, radius),
        degreeToRadians(200),
        degreeToRadians(70),
        false);
    path.arcTo(Rect.fromLTWH(size.width - radius, 0, radius, radius),
        degreeToRadians(270), degreeToRadians(90), false);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(JinBeanTabClipper oldClipper) => true;

  double degreeToRadians(double degree) {
    final double redian = (math.pi / 180) * degree;
    return redian;
  }
}

/// JinBean 浮动操作按钮底部导航栏
/// 类似 My Diary 的中央浮动按钮设计
class JinBeanFloatingBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final List<JinBeanBottomNavItem> items;
  final ValueChanged<int>? onTap;
  final Widget? floatingActionButton;
  final VoidCallback? onFloatingActionTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const JinBeanFloatingBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.items,
    this.onTap,
    this.floatingActionButton,
    this.onFloatingActionTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: JinBeanColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: JinBeanColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 90,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Stack(
            children: [
              // 底部导航项
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == currentIndex;
                  
                  // 为中央浮动按钮留出空间
                  if (index == items.length ~/ 2) {
                    return const SizedBox(width: 60);
                  }
                  
                  return _buildNavItem(
                    item: item,
                    index: index,
                    isSelected: isSelected,
                  );
                }).toList(),
              ),
              
              // 中央浮动按钮
              if (floatingActionButton != null) ...[
                Positioned(
                  top: -20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: onFloatingActionTap,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: JinBeanColors.lightGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: JinBeanColors.shadow,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: floatingActionButton,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required JinBeanBottomNavItem item,
    required int index,
    required bool isSelected,
  }) {
    final color = isSelected 
        ? (selectedItemColor ?? Colors.white)
        : (unselectedItemColor ?? Colors.white.withValues(alpha: 0.7));
    
    return GestureDetector(
      onTap: () {
        item.onTap?.call();
        onTap?.call(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标和徽章
            Stack(
              children: [
                Icon(
                  isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
                  size: 24,
                  color: color,
                ),
                if (item.badge != null && item.badge!.isNotEmpty) ...[
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: JinBeanColors.error,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        item.badge!,
                        style: JinBeanTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: JinBeanTypography.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: JinBeanTypography.labelSmall.copyWith(
                color: color,
                fontWeight: isSelected 
                    ? JinBeanTypography.semiBold 
                    : JinBeanTypography.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// JinBean 底部导航栏包装器
/// 提供完整的底部导航栏体验
class JinBeanBottomNavigationWrapper extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final List<JinBeanBottomNavItem> items;
  final ValueChanged<int>? onTap;
  final bool showLabels;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double elevation;
  final bool enableGradient;
  final bool useFloatingAction;
  final Widget? floatingActionButton;
  final VoidCallback? onFloatingActionTap;

  const JinBeanBottomNavigationWrapper({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.items,
    this.onTap,
    this.showLabels = true,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation = 8.0,
    this.enableGradient = true,
    this.useFloatingAction = false,
    this.floatingActionButton,
    this.onFloatingActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: useFloatingAction
          ? JinBeanFloatingBottomNavigation(
              currentIndex: currentIndex,
              items: items,
              onTap: onTap,
              floatingActionButton: floatingActionButton,
              onFloatingActionTap: onFloatingActionTap,
              backgroundColor: backgroundColor,
              selectedItemColor: selectedItemColor,
              unselectedItemColor: unselectedItemColor,
            )
          : JinBeanBottomNavigation(
              currentIndex: currentIndex,
              items: items,
              onTap: onTap,
              showLabels: showLabels,
              backgroundColor: backgroundColor,
              selectedItemColor: selectedItemColor,
              unselectedItemColor: unselectedItemColor,
              elevation: elevation,
              enableGradient: enableGradient,
            ),
    );
  }
} 