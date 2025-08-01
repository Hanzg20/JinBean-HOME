import 'package:flutter/material.dart';

/// JinBean 间距系统
/// 基于 8px 网格系统的现代化间距规范
class JinBeanSpacing {
  // 基础间距单位 (8px)
  static const double unit = 8.0;
  
  // 小间距
  static const double xs = 4.0;   // 0.5 * unit
  static const double sm = 8.0;   // 1 * unit
  static const double md = 16.0;  // 2 * unit
  static const double lg = 24.0;  // 3 * unit
  static const double xl = 32.0;  // 4 * unit
  static const double xxl = 48.0; // 6 * unit
  static const double xxxl = 64.0; // 8 * unit
  
  // 特殊间距
  static const double pagePadding = 16.0;
  static const double cardPadding = 16.0;
  static const double buttonPadding = 12.0;
  static const double inputPadding = 12.0;
  static const double iconPadding = 8.0;
  
  // 组件间距
  static const double componentGap = 16.0;
  static const double sectionGap = 24.0;
  static const double pageGap = 32.0;
  
  // 边距
  static const EdgeInsets pageMargin = EdgeInsets.all(pagePadding);
  static const EdgeInsets cardMargin = EdgeInsets.all(cardPadding);
  static const EdgeInsets buttonMargin = EdgeInsets.all(buttonPadding);
  
  // 内边距
  static const EdgeInsets pagePaddingInsets = EdgeInsets.all(JinBeanSpacing.pagePadding);
  static const EdgeInsets cardPaddingInsets = EdgeInsets.all(JinBeanSpacing.cardPadding);
  static const EdgeInsets buttonPaddingInsets = EdgeInsets.all(JinBeanSpacing.buttonPadding);
  static const EdgeInsets inputPaddingInsets = EdgeInsets.all(JinBeanSpacing.inputPadding);
  
  // 水平间距
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(horizontal: pagePadding);
  static const EdgeInsets horizontalCardPadding = EdgeInsets.symmetric(horizontal: cardPadding);
  
  // 垂直间距
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: pagePadding);
  static const EdgeInsets verticalCardPadding = EdgeInsets.symmetric(vertical: cardPadding);
  
  // 获取自定义间距
  static EdgeInsets custom({
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    if (all != null) {
      return EdgeInsets.all(all);
    }
    if (horizontal != null || vertical != null) {
      return EdgeInsets.symmetric(
        horizontal: horizontal ?? 0,
        vertical: vertical ?? 0,
      );
    }
    return EdgeInsets.only(
      left: left ?? 0,
      top: top ?? 0,
      right: right ?? 0,
      bottom: bottom ?? 0,
    );
  }
  
  // 获取组件间距
  static EdgeInsets getComponentSpacing({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return EdgeInsets.only(
      top: top ?? componentGap,
      bottom: bottom ?? componentGap,
      left: left ?? componentGap,
      right: right ?? componentGap,
    );
  }
  
  // 获取卡片间距
  static EdgeInsets getCardSpacing({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return EdgeInsets.only(
      top: top ?? cardPadding,
      bottom: bottom ?? cardPadding,
      left: left ?? cardPadding,
      right: right ?? cardPadding,
    );
  }
} 