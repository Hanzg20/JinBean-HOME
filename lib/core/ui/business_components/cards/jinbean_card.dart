import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';

/// JinBean 基础卡片组件
class JinBeanCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  const JinBeanCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget card = Card(
      margin: margin ?? JinBeanSpacing.cardMargin,
      elevation: elevation ?? theme.cardTheme.elevation,
      color: backgroundColor ?? theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        side: border?.top ?? BorderSide.none,
      ),
      child: Padding(
        padding: padding ?? JinBeanSpacing.cardPaddingInsets,
        child: child,
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: card,
      );
    }

    return card;
  }
}

/// JinBean 可点击卡片组件
class JinBeanClickableCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  const JinBeanClickableCard({
    super.key,
    required this.child,
    required this.onTap,
    this.margin,
    this.padding,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return JinBeanCard(
      onTap: onTap,
      margin: margin,
      padding: padding,
      elevation: elevation,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      border: border,
      child: child,
    );
  }
}

/// JinBean 信息卡片组件
class JinBeanInfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const JinBeanInfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return JinBeanCard(
      onTap: onTap,
      margin: margin,
      padding: padding,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: JinBeanSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: JinBeanSpacing.sm),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: JinBeanColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: JinBeanSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// JinBean 统计卡片组件
class JinBeanStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  const JinBeanStatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;
    
    return JinBeanCard(
      onTap: onTap,
      backgroundColor: cardColor.withOpacity(0.1),
      border: Border.all(color: cardColor.withOpacity(0.3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: cardColor,
                  size: 20,
                ),
                SizedBox(width: JinBeanSpacing.sm),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cardColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: JinBeanSpacing.sm),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: cardColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 