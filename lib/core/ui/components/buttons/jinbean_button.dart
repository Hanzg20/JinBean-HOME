import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../design_system/typography.dart';

/// JinBean 按钮类型
enum JinBeanButtonType {
  primary,
  secondary,
  outline,
  text,
  gradient,
}

/// JinBean 按钮大小
enum JinBeanButtonSize {
  small,
  medium,
  large,
}

/// JinBean 标准按钮组件
class JinBeanButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final JinBeanButtonType type;
  final JinBeanButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? color;
  final Color? textColor;

  const JinBeanButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = JinBeanButtonType.primary,
    this.size = JinBeanButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidget = _buildButtonWidget();
    
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: buttonWidget,
      );
    }
    
    return buttonWidget;
  }

  Widget _buildButtonWidget() {
    switch (type) {
      case JinBeanButtonType.primary:
        return _buildPrimaryButton();
      case JinBeanButtonType.secondary:
        return _buildSecondaryButton();
      case JinBeanButtonType.outline:
        return _buildOutlineButton();
      case JinBeanButtonType.text:
        return _buildTextButton();
      case JinBeanButtonType.gradient:
        return _buildGradientButton();
    }
  }

  Widget _buildPrimaryButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? JinBeanColors.primary,
        foregroundColor: textColor ?? Colors.white,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        ),
        elevation: 2,
        shadowColor: JinBeanColors.shadow,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildSecondaryButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? JinBeanColors.surface,
        foregroundColor: textColor ?? JinBeanColors.primary,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        ),
        elevation: 0,
        side: BorderSide(color: JinBeanColors.border),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlineButton() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color ?? JinBeanColors.primary,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        ),
        side: BorderSide(color: color ?? JinBeanColors.primary),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildTextButton() {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? JinBeanColors.primary,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildGradientButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: color != null 
            ? LinearGradient(
                colors: [color!, color!.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : JinBeanColors.primaryGradient,
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        boxShadow: [
          BoxShadow(
            color: JinBeanColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: textColor ?? Colors.white,
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
          ),
          elevation: 0,
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == JinBeanButtonType.primary || type == JinBeanButtonType.gradient
                ? Colors.white
                : JinBeanColors.primary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          Text(
            text,
            style: _getTextStyle(),
          ),
        ],
      );
    }

    return Text(
      text,
      style: _getTextStyle(),
    );
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case JinBeanButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case JinBeanButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case JinBeanButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case JinBeanButtonSize.small:
        return 8;
      case JinBeanButtonSize.medium:
        return 12;
      case JinBeanButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case JinBeanButtonSize.small:
        return 16;
      case JinBeanButtonSize.medium:
        return 20;
      case JinBeanButtonSize.large:
        return 24;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case JinBeanButtonSize.small:
        return JinBeanTypography.labelMedium;
      case JinBeanButtonSize.medium:
        return JinBeanTypography.button;
      case JinBeanButtonSize.large:
        return JinBeanTypography.labelLarge;
    }
  }
}

/// JinBean 图标按钮组件
class JinBeanIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final JinBeanButtonSize size;
  final Color? color;
  final Color? backgroundColor;
  final bool isLoading;

  const JinBeanIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = JinBeanButtonSize.medium,
    this.color,
    this.backgroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? JinBeanColors.surface,
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        boxShadow: [
          BoxShadow(
            color: JinBeanColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: _getIconSize(),
                height: _getIconSize(),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    color ?? JinBeanColors.primary,
                  ),
                ),
              )
            : Icon(
                icon,
                size: _getIconSize(),
                color: color ?? JinBeanColors.primary,
              ),
        padding: EdgeInsets.all(_getPadding()),
      ),
    );
  }

  double _getBorderRadius() {
    switch (size) {
      case JinBeanButtonSize.small:
        return 8;
      case JinBeanButtonSize.medium:
        return 12;
      case JinBeanButtonSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case JinBeanButtonSize.small:
        return 16;
      case JinBeanButtonSize.medium:
        return 20;
      case JinBeanButtonSize.large:
        return 24;
    }
  }

  double _getPadding() {
    switch (size) {
      case JinBeanButtonSize.small:
        return 8;
      case JinBeanButtonSize.medium:
        return 12;
      case JinBeanButtonSize.large:
        return 16;
    }
  }
} 