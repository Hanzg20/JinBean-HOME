import 'package:flutter/material.dart';
import '../../design_system/colors.dart';

/// JinBean 卡片组件
/// 支持 My Diary 风格的现代化设计
class JinBeanCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final LinearGradient? gradient;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool enableShadow;
  final bool enableGradient;

  const JinBeanCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.gradient,
    this.boxShadow,
    this.onTap,
    this.enableShadow = true,
    this.enableGradient = false,
  });

  /// 创建默认的 My Diary 风格卡片
  factory JinBeanCard.myDiary({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return JinBeanCard(
      key: key,
      child: child,
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(20),
      enableGradient: true,
      enableShadow: true,
      onTap: onTap,
    );
  }

  /// 创建统计卡片
  factory JinBeanCard.stats({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return JinBeanCard(
      key: key,
      child: child,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: BorderRadius.circular(16),
      gradient: JinBeanColors.cardGradient,
      enableShadow: true,
      onTap: onTap,
    );
  }

  /// 创建操作卡片
  factory JinBeanCard.action({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return JinBeanCard(
      key: key,
      child: child,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: BorderRadius.circular(16),
      backgroundColor: Colors.white,
      enableShadow: true,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 默认样式
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(20);
    final defaultPadding = padding ?? const EdgeInsets.all(20);
    final defaultMargin = margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    final defaultBackgroundColor = backgroundColor ?? Colors.white;
    final defaultShadow = boxShadow ?? (enableShadow ? JinBeanColors.cardShadow : null);
    final defaultGradient = gradient ?? (enableGradient ? JinBeanColors.cardGradient : null);

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: defaultGradient != null ? null : defaultBackgroundColor,
        gradient: defaultGradient,
        borderRadius: defaultBorderRadius,
        boxShadow: defaultShadow,
      ),
      child: Padding(
        padding: defaultPadding,
        child: child,
      ),
    );

    // 如果有点击事件，添加手势检测
    if (onTap != null) {
      cardContent = GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    // 如果有边距，包装在 Container 中
    if (defaultMargin != EdgeInsets.zero) {
      cardContent = Container(
        margin: defaultMargin,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

/// JinBean 渐变卡片组件
/// 专门用于需要渐变效果的卡片
class JinBeanGradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final LinearGradient? gradient;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const JinBeanGradientCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.gradient,
    this.boxShadow,
    this.onTap,
  });

  /// 创建主色调渐变卡片
  factory JinBeanGradientCard.primary({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return JinBeanGradientCard(
      key: key,
      child: child,
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(20),
      gradient: JinBeanColors.primaryGradient,
      boxShadow: JinBeanColors.buttonShadow,
      onTap: onTap,
    );
  }

  /// 创建成功状态渐变卡片
  factory JinBeanGradientCard.success({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return JinBeanGradientCard(
      key: key,
      child: child,
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(20),
      gradient: JinBeanColors.successGradient,
      boxShadow: JinBeanColors.cardShadow,
      onTap: onTap,
    );
  }

  /// 创建警告状态渐变卡片
  factory JinBeanGradientCard.warning({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return JinBeanGradientCard(
      key: key,
      child: child,
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(20),
      gradient: JinBeanColors.warningGradient,
      boxShadow: JinBeanColors.cardShadow,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(20);
    final defaultPadding = padding ?? const EdgeInsets.all(20);
    final defaultMargin = margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    final defaultGradient = gradient ?? JinBeanColors.cardGradient;
    final defaultShadow = boxShadow ?? JinBeanColors.cardShadow;

    Widget cardContent = Container(
      decoration: BoxDecoration(
        gradient: defaultGradient,
        borderRadius: defaultBorderRadius,
        boxShadow: defaultShadow,
      ),
      child: Padding(
        padding: defaultPadding,
        child: child,
      ),
    );

    if (onTap != null) {
      cardContent = GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    if (defaultMargin != EdgeInsets.zero) {
      cardContent = Container(
        margin: defaultMargin,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

/// JinBean 统计卡片组件
class JinBeanStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  const JinBeanStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? JinBeanColors.primary;

    return JinBeanCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      backgroundColor: cardColor.withOpacity(0.1),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Row(
              children: [
                Icon(icon, color: cardColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: JinBeanColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ] else ...[
            Text(
              title,
              style: TextStyle(
                color: JinBeanColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            value,
            style: TextStyle(
              color: cardColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: JinBeanColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// JinBean 服务卡片组件
class JinBeanServiceCard extends StatelessWidget {
  final String title;
  final String? description;
  final String? price;
  final String? rating;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Color? accentColor;

  const JinBeanServiceCard({
    super.key,
    required this.title,
    this.description,
    this.price,
    this.rating,
    this.imageUrl,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? JinBeanColors.primary;

    return JinBeanCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null) ...[
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            title,
            style: TextStyle(
              color: JinBeanColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: TextStyle(
                color: JinBeanColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (price != null) ...[
                Text(
                  price!,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
              ],
              if (rating != null) ...[
                Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  rating!,
                  style: TextStyle(
                    color: JinBeanColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
} 