import 'package:flutter/material.dart';
import '../themes/customer_theme_utils.dart';

/// Customer主题化的通用组件库
/// 提供基于Customer_theme的常用UI组件，提高复用率
/// 参考Provider_theme的设计模式，但针对Customer端特点优化

/// 主题化卡片组件 - Customer端更注重视觉吸引力
class CustomerCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool showShadow;
  final bool useGradient;

  const CustomerCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.showShadow = true,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: useGradient
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface,
                  colorScheme.surfaceVariant.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: showShadow ? [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            )
          : CustomerThemeUtils.getCardDecoration(context),
      child: child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: cardContent,
      );
    }

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: cardContent,
    );
  }
}

/// 主题化图标容器组件 - Customer端更注重品牌感
class CustomerIconContainer extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool useGradient;

  const CustomerIconContainer({
    super.key,
    required this.icon,
    this.size = 40,
    this.backgroundColor,
    this.iconColor,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: size,
      height: size,
      decoration: useGradient
          ? CustomerThemeUtils.getIconContainerDecoration(context)
          : BoxDecoration(
              color: backgroundColor ?? colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(size / 2),
            ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: iconColor ?? (useGradient ? Colors.white : colorScheme.primary),
      ),
    );
  }
}

/// 主题化按钮组件 - Customer端更注重友好性
class CustomerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final bool useGradient;

  const CustomerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
    this.width,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Widget buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isPrimary ? colorScheme.onPrimary : colorScheme.primary,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    if (isPrimary) {
      return SizedBox(
        width: width,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: useGradient
              ? ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 3,
                  shadowColor: colorScheme.shadow.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                )
              : CustomerThemeUtils.getPrimaryButtonStyle(context),
          child: buttonChild,
        ),
      );
    } else {
      return SizedBox(
        width: width,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: CustomerThemeUtils.getSecondaryButtonStyle(context),
          child: buttonChild,
        ),
      );
    }
  }
}

/// 主题化输入框组件 - Customer端更注重易用性
class CustomerTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final VoidCallback? onSuffixIconTap;

  const CustomerTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onSuffixIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: CustomerThemeUtils.getInputDecoration(
        context,
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon),
                onPressed: onSuffixIconTap,
              )
            : null,
      ),
    );
  }
}

/// 主题化搜索框组件 - Customer端特有
class CustomerSearchField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool showClear;

  const CustomerSearchField({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onClear,
    this.showClear = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: CustomerThemeUtils.getSearchInputDecoration(
        context,
        hintText: hintText,
        onClear: onClear,
        showClear: showClear,
      ),
    );
  }
}

/// 主题化列表项组件 - Customer端更注重易用性
class CustomerListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool useGradient;

  const CustomerListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.useGradient = false,
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
              ? CustomerIconContainer(
                  icon: leadingIcon!,
                  size: 40,
                  useGradient: useGradient,
                )
              : null,
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
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
          trailing: trailing ??
              (onTap != null
                  ? Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    )
                  : null),
          onTap: onTap,
        ),
        if (showDivider) CustomerThemeUtils.getDivider(context),
      ],
    );
  }
}

/// 主题化服务卡片组件 - Customer端特有
class CustomerServiceCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPopular;
  final bool isNearby;

  const CustomerServiceCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.isPopular = false,
    this.isNearby = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return CustomerCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomerIconContainer(
                icon: icon,
                size: 48,
                useGradient: true,
              ),
              const Spacer(),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Popular',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (isNearby)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Nearby',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 主题化推荐卡片组件 - Customer端特有
class CustomerRecommendationCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final double? rating;
  final double? price;
  final double? distance;
  final VoidCallback? onTap;
  final bool isPopular;
  final bool isNearby;

  const CustomerRecommendationCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.rating,
    this.price,
    this.distance,
    this.onTap,
    this.isPopular = false,
    this.isNearby = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with badges
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: colorScheme.surfaceVariant,
                                  child: Icon(
                                    Icons.image,
                                    size: 40,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: colorScheme.surfaceVariant,
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),
                  if (isPopular)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Popular',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (isNearby)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Nearby',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const Spacer(),
                      // Rating and distance
                      if (rating != null || distance != null)
                        Row(
                          children: [
                            if (rating != null) ...[
                              Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                rating!.toString(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const Spacer(),
                            if (distance != null)
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: colorScheme.onSurfaceVariant, size: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${distance!.toStringAsFixed(1)}km',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      const SizedBox(height: 6),
                      // Price and action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (price != null)
                            Text(
                              '\$${price!.toStringAsFixed(2)}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 主题化加载状态组件 - Customer端更注重可见性
class CustomerLoadingState extends StatelessWidget {
  final String? message;

  const CustomerLoadingState({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomerThemeUtils.getLoadingIndicator(context),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 主题化空状态组件 - Customer端更注重友好性
class CustomerEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionText;

  const CustomerEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomerThemeUtils.getEmptyState(
      context,
      icon: icon,
      title: title,
      subtitle: subtitle,
      onAction: onAction,
      actionText: actionText,
    );
  }
}

/// 主题化错误状态组件 - Customer端更注重友好性
class CustomerErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CustomerErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomerThemeUtils.getErrorState(
      context,
      message: message,
      onRetry: onRetry,
    );
  }
} 