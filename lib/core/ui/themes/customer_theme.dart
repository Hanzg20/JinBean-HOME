import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';
import 'jinbean_theme.dart';

/// JinBean 客户端主题
/// 针对服务消费者优化的主题设计
class JinBeanCustomerTheme {
  /// 客户端浅色主题
  static ThemeData get lightTheme {
    final baseTheme = JinBeanTheme.lightTheme;
    
    return baseTheme.copyWith(
      // 客户端特有的颜色调整
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: JinBeanColors.primary,
        secondary: JinBeanColors.secondary,
        // 客户端更偏向温暖色调
        tertiary: const Color(0xFFFF6B35), // 橙色，增加温暖感
        surface: const Color(0xFFFAFBFC), // 更浅的背景色
        surfaceVariant: const Color(0xFFF8F9FA), // 更浅的变体背景
      ),
      
      // AppBar 主题 - 客户端更注重品牌展示
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: JinBeanColors.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: JinBeanTypography.h5.copyWith(
          color: Colors.white,
          fontWeight: JinBeanTypography.semiBold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        // 客户端AppBar更注重品牌感
        actionsIconTheme: const IconThemeData(color: Colors.white),
      ),
      
      // 卡片主题 - 客户端卡片更注重视觉吸引力
      cardTheme: baseTheme.cardTheme.copyWith(
        color: Colors.white,
        elevation: 4, // 稍微增加阴影
        shadowColor: JinBeanColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // 更大的圆角
        ),
        margin: const EdgeInsets.all(12), // 更大的边距
      ),
      
      // 按钮主题 - 客户端按钮更注重友好性
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JinBeanColors.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: JinBeanColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // 更大的圆角
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // 更大的内边距
          textStyle: JinBeanTypography.button.copyWith(
            fontSize: 16, // 稍大的字体
            fontWeight: JinBeanTypography.semiBold,
          ),
        ),
      ),
      
      // 输入框主题 - 客户端输入框更注重易用性
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // 更大的圆角
          borderSide: const BorderSide(color: JinBeanColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: JinBeanColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: JinBeanColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // 更大的内边距
        labelStyle: JinBeanTypography.bodyMedium.copyWith(
          color: JinBeanColors.textSecondary,
          fontSize: 15, // 稍大的标签字体
        ),
        hintStyle: JinBeanTypography.bodyMedium.copyWith(
          color: JinBeanColors.textTertiary,
          fontSize: 15,
        ),
      ),
      
      // 底部导航栏主题 - 客户端更注重易用性
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: JinBeanColors.primary,
        unselectedItemColor: JinBeanColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      
      // 浮动操作按钮主题 - 客户端更注重可见性
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: JinBeanColors.primary,
        foregroundColor: Colors.white,
        elevation: 8, // 更大的阴影
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)), // 更大的圆角
        ),
      ),
      
      // 对话框主题 - 客户端更注重友好性
      dialogTheme: baseTheme.dialogTheme.copyWith(
        backgroundColor: Colors.white,
        elevation: 12, // 更大的阴影
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // 更大的圆角
        ),
        titleTextStyle: JinBeanTypography.h5.copyWith(
          color: JinBeanColors.textPrimary,
          fontWeight: JinBeanTypography.semiBold,
        ),
        contentTextStyle: JinBeanTypography.bodyMedium.copyWith(
          color: JinBeanColors.textSecondary,
          fontSize: 15, // 稍大的内容字体
        ),
      ),
      
      // 底部表单主题 - 客户端更注重易用性
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // 更大的圆角
        ),
      ),
      
      // 进度指示器主题 - 客户端更注重可见性
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: JinBeanColors.primary,
        linearTrackColor: Color(0xFFF0F0F0),
        circularTrackColor: Color(0xFFF0F0F0),
      ),
      
      // 开关主题 - 客户端更注重友好性
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primary;
          }
          return JinBeanColors.textTertiary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primary.withValues(alpha: 0.3); // 更淡的选中色
          }
          return const Color(0xFFF0F0F0);
        }),
      ),
      
      // 复选框主题 - 客户端更注重可见性
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6), // 稍大的圆角
        ),
      ),
      
      // 单选按钮主题 - 客户端更注重可见性
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primary;
          }
          return JinBeanColors.textTertiary;
        }),
      ),
      
      // 滑块主题 - 客户端更注重可见性
      sliderTheme: SliderThemeData(
        activeTrackColor: JinBeanColors.primary,
        inactiveTrackColor: const Color(0xFFF0F0F0),
        thumbColor: JinBeanColors.primary,
        overlayColor: JinBeanColors.primary.withValues(alpha: 0.2),
        valueIndicatorColor: JinBeanColors.primary,
        valueIndicatorTextStyle: JinBeanTypography.labelMedium.copyWith(
          color: Colors.white,
          fontSize: 14, // 稍大的字体
        ),
      ),
    );
  }
  
  /// 客户端深色主题
  static ThemeData get darkTheme {
    final baseTheme = JinBeanTheme.darkTheme;
    
    return baseTheme.copyWith(
      // 客户端深色主题的颜色调整
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: JinBeanColors.primaryLight,
        secondary: JinBeanColors.secondaryLight,
        tertiary: const Color(0xFFFF8A65), // 深色模式下的橙色
        surface: const Color(0xFF1A1A1A), // 稍亮的深色背景
        surfaceVariant: const Color(0xFF2A2A2A), // 稍亮的变体背景
      ),
      
      // AppBar 主题
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: JinBeanColors.primaryLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: JinBeanTypography.h5.copyWith(
          color: Colors.black,
          fontWeight: JinBeanTypography.semiBold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      
      // 卡片主题
      cardTheme: baseTheme.cardTheme.copyWith(
        color: const Color(0xFF1E1E1E),
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(12),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JinBeanColors.primaryLight,
          foregroundColor: Colors.black,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: JinBeanTypography.button.copyWith(
            fontSize: 16,
            fontWeight: JinBeanTypography.semiBold,
          ),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: JinBeanColors.primaryLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: JinBeanTypography.bodyMedium.copyWith(
          color: Colors.grey[400],
          fontSize: 15,
        ),
        hintStyle: JinBeanTypography.bodyMedium.copyWith(
          color: Colors.grey[500],
          fontSize: 15,
        ),
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        selectedItemColor: JinBeanColors.primaryLight,
        unselectedItemColor: Color(0xFF9E9E9E), // 修复：使用常量颜色替代Colors.grey[500]
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      
      // 浮动操作按钮主题
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: JinBeanColors.primaryLight,
        foregroundColor: Colors.black,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      
      // 对话框主题
      dialogTheme: baseTheme.dialogTheme.copyWith(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: JinBeanTypography.h5.copyWith(
          color: Colors.white,
          fontWeight: JinBeanTypography.semiBold,
        ),
        contentTextStyle: JinBeanTypography.bodyMedium.copyWith(
          color: Colors.grey[300],
          fontSize: 15,
        ),
      ),
      
      // 底部表单主题
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      
      // 进度指示器主题
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: JinBeanColors.primaryLight,
        linearTrackColor: Color(0xFF2A2A2A),
        circularTrackColor: Color(0xFF2A2A2A),
      ),
      
      // 开关主题
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primaryLight;
          }
          return Colors.grey[500];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primaryLight.withValues(alpha: 0.3);
          }
          return const Color(0xFF2A2A2A);
        }),
      ),
      
      // 复选框主题
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primaryLight;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      
      // 单选按钮主题
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primaryLight;
          }
          return Colors.grey[500];
        }),
      ),
      
      // 滑块主题
      sliderTheme: SliderThemeData(
        activeTrackColor: JinBeanColors.primaryLight,
        inactiveTrackColor: const Color(0xFF2A2A2A),
        thumbColor: JinBeanColors.primaryLight,
        overlayColor: JinBeanColors.primaryLight.withValues(alpha: 0.2),
        valueIndicatorColor: JinBeanColors.primaryLight,
        valueIndicatorTextStyle: JinBeanTypography.labelMedium.copyWith(
          color: Colors.black,
          fontSize: 14,
        ),
      ),
    );
  }
} 