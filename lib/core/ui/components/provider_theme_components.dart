import 'package:flutter/material.dart';
import '../themes/provider_theme_utils.dart';

/// Provider主题化的通用组件库
/// 提供基于Provider_theme的常用UI组件，提高复用率

/// 主题化卡片组件
class ProviderCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool showShadow;

  const ProviderCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: showShadow ? [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: cardContent,
      );
    }

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: cardContent,
    );
  }
}

/// 主题化图标容器组件
class ProviderIconContainer extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const ProviderIconContainer({
    super.key,
    required this.icon,
    this.size = 40,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: iconColor ?? colorScheme.primary,
      ),
    );
  }
}

/// 主题化按钮组件
class ProviderButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final ProviderButtonType type;
  final bool isLoading;
  final double? width;

  const ProviderButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.type = ProviderButtonType.primary,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    ButtonStyle buttonStyle;
    Color textColor;
    
    switch (type) {
      case ProviderButtonType.primary:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 4,
          shadowColor: colorScheme.shadow.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        );
        textColor = colorScheme.onPrimary;
        break;
      case ProviderButtonType.secondary:
        buttonStyle = OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        );
        textColor = colorScheme.primary;
        break;
      case ProviderButtonType.error:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: colorScheme.error,
          foregroundColor: colorScheme.onError,
          elevation: 4,
          shadowColor: colorScheme.shadow.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        );
        textColor = colorScheme.onError;
        break;
    }

    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          )
        else if (icon != null)
          Icon(icon, size: 18),
        if ((icon != null || isLoading) && text.isNotEmpty)
          const SizedBox(width: 8),
        if (text.isNotEmpty)
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: textColor,
            ),
          ),
      ],
    );

    Widget button = type == ProviderButtonType.secondary
        ? OutlinedButton(
            style: buttonStyle,
            onPressed: isLoading ? null : onPressed,
            child: buttonContent,
          )
        : ElevatedButton(
            style: buttonStyle,
            onPressed: isLoading ? null : onPressed,
            child: buttonContent,
          );

    if (width != null) {
      button = SizedBox(width: width, child: button);
    }

    return button;
  }
}

/// 按钮类型枚举
enum ProviderButtonType {
  primary,
  secondary,
  error,
}

/// 主题化列表项组件
class ProviderListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const ProviderListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: leadingIcon != null
              ? ProviderIconContainer(
                  icon: leadingIcon!,
                  size: 36,
                )
              : null,
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
          trailing: trailing ?? (onTap != null
              ? Icon(
                  Icons.arrow_forward_ios,
                  color: colorScheme.onSurfaceVariant,
                  size: 16,
                )
              : null),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: colorScheme.outline.withOpacity(0.1),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}

/// 主题化徽章组件
class ProviderBadge extends StatelessWidget {
  final String text;
  final ProviderBadgeType type;
  final double? fontSize;

  const ProviderBadge({
    super.key,
    required this.text,
    this.type = ProviderBadgeType.primary,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color backgroundColor;
    Color textColor;
    
    switch (type) {
      case ProviderBadgeType.primary:
        backgroundColor = colorScheme.primary;
        textColor = colorScheme.onPrimary;
        break;
      case ProviderBadgeType.secondary:
        backgroundColor = colorScheme.secondary;
        textColor = colorScheme.onSecondary;
        break;
      case ProviderBadgeType.error:
        backgroundColor = colorScheme.error;
        textColor = colorScheme.onError;
        break;
      case ProviderBadgeType.warning:
        backgroundColor = colorScheme.tertiary;
        textColor = colorScheme.onTertiary;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize ?? 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

/// 徽章类型枚举
enum ProviderBadgeType {
  primary,
  secondary,
  error,
  warning,
}

/// 主题化区块标题组件
class ProviderSectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  const ProviderSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
                fontSize: 14,
              ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// 主题化统计卡片组件
class ProviderStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? valueColor;
  final VoidCallback? onTap;

  const ProviderStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ProviderCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ProviderIconContainer(
            icon: icon,
            size: 40,
            iconColor: iconColor ?? colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 主题化加载状态组件
class ProviderLoadingState extends StatelessWidget {
  final String message;
  final double size;

  const ProviderLoadingState({
    super.key,
    this.message = '加载中...',
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// 主题化空状态组件
class ProviderEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const ProviderEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProviderIconContainer(
              icon: icon,
              size: 64,
              iconColor: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ProviderButton(
                onPressed: onAction,
                text: actionText!,
                type: ProviderButtonType.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 主题化错误状态组件
class ProviderErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ProviderErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProviderIconContainer(
              icon: Icons.error_outline,
              size: 64,
              iconColor: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ProviderButton(
                onPressed: onRetry,
                text: '重试',
                type: ProviderButtonType.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
} 