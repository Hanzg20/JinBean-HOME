import 'package:flutter/material.dart';

/// JinBean 颜色系统
/// 基于 My Diary 主题的现代化渐变色彩设计
class JinBeanColors {
  // 主色调 - 基于 My Diary 的蓝色到紫色渐变
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  
  // 辅助色 - 紫色渐变
  static const Color secondary = Color(0xFF9C27B0);
  static const Color secondaryLight = Color(0xFFBA68C8);
  static const Color secondaryDark = Color(0xFF7B1FA2);
  
  // My Diary 风格渐变色彩
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient lightGradient = LinearGradient(
    colors: [primaryLight, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 新增：My Diary 风格的现代化渐变
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8F9FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient headerGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, warningLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, errorLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 状态色彩
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  
  // 中性色彩 - My Diary 风格的现代化中性色
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // 新增：My Diary 风格的背景渐变
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, Color(0xFFF0F2F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // 文本色彩
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // 边框和分割线
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
  
  // 阴影色彩 - My Diary 风格的现代化阴影
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x15000000);
  static const Color shadowDark = Color(0x25000000);
  
  // 新增：My Diary 风格的阴影系统
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: shadow.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: shadow.withValues(alpha: 0.06),
      blurRadius: 6,
      offset: const Offset(0, 3),
    ),
  ];
  
  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.16),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: shadow.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  // 业务特定色彩
  static const Color serviceCard = Color(0xFFE3F2FD);
  static const Color orderCard = Color(0xFFF3E5F5);
  static const Color clientCard = Color(0xFFE8F5E8);
  static const Color notificationCard = Color(0xFFFFF3E0);
  
  // 新增：My Diary 风格的业务卡片渐变
  static const LinearGradient serviceCardGradient = LinearGradient(
    colors: [serviceCard, Color(0xFFF0F8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient orderCardGradient = LinearGradient(
    colors: [orderCard, Color(0xFFF8F0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient clientCardGradient = LinearGradient(
    colors: [clientCard, Color(0xFFF0FFF0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient notificationCardGradient = LinearGradient(
    colors: [notificationCard, Color(0xFFFFF8F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 获取主题色彩
  static ColorScheme get lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    secondary: secondary,
    onSecondary: Colors.white,
    error: error,
    onError: Colors.white,
    background: background,
    onBackground: textPrimary,
    surface: surface,
    onSurface: textPrimary,
  );
  
  static ColorScheme get darkColorScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: primaryLight,
    onPrimary: Colors.black,
    secondary: secondaryLight,
    onSecondary: Colors.black,
    error: errorLight,
    onError: Colors.black,
    background: Color(0xFF121212),
    onBackground: Colors.white,
    surface: Color(0xFF1E1E1E),
    onSurface: Colors.white,
  );
} 