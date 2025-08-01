import 'package:flutter/material.dart';

/// JinBean 字体系统
/// 基于现代化设计规范的字体层级
class JinBeanTypography {
  // 字体族
  static const String fontFamily = 'Roboto';
  static const String fontFamilyFallback = 'SF Pro Display';
  
  // 字体权重
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  
  // 标题字体
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: bold,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: bold,
    letterSpacing: -0.25,
    height: 1.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: semiBold,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: semiBold,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    fontWeight: medium,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static const TextStyle h6 = TextStyle(
    fontSize: 16,
    fontWeight: medium,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  // 正文字体
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: regular,
    letterSpacing: 0.5,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    letterSpacing: 0.25,
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    letterSpacing: 0.4,
    height: 1.3,
  );
  
  // 标签字体
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 0.5,
    height: 1.3,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: medium,
    letterSpacing: 0.5,
    height: 1.2,
  );
  
  // 按钮字体
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  // 获取主题文本样式
  static TextTheme get textTheme => const TextTheme(
    displayLarge: h1,
    displayMedium: h2,
    displaySmall: h3,
    headlineLarge: h4,
    headlineMedium: h5,
    headlineSmall: h6,
    titleLarge: h6,
    titleMedium: labelLarge,
    titleSmall: labelMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
  
  // 获取带颜色的文本样式
  static TextStyle getColoredTextStyle(TextStyle baseStyle, Color color) {
    return baseStyle.copyWith(color: color);
  }
  
  // 获取带字重的文本样式
  static TextStyle getWeightedTextStyle(TextStyle baseStyle, FontWeight weight) {
    return baseStyle.copyWith(fontWeight: weight);
  }
  
  // 获取带大小的文本样式
  static TextStyle getSizedTextStyle(TextStyle baseStyle, double size) {
    return baseStyle.copyWith(fontSize: size);
  }
} 