import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';
import 'jinbean_theme.dart';

/// JinBean 服务商主题
/// 针对服务提供者优化的主题设计，融入 My Diary 风格
class JinBeanProviderTheme {
  /// 服务商浅色主题
  static ThemeData get lightTheme {
    final baseTheme = JinBeanTheme.lightTheme;
    
    return baseTheme.copyWith(
      // 服务商特有的颜色调整
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: JinBeanColors.primaryDark, // 更深的蓝色，显得更专业
        secondary: JinBeanColors.secondaryDark, // 更深的紫色
        // 服务商更偏向专业色调
        tertiary: const Color(0xFF2E7D32), // 深绿色，增加专业感
        surface: const Color(0xFFF5F7FA), // 更专业的背景色
        surfaceVariant: const Color(0xFFE8EAED), // 更专业的变体背景
      ),
      
      // AppBar 主题 - My Diary 风格的现代化设计
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: Colors.transparent, // 透明背景，支持渐变
        elevation: 0, // 无阴影，更现代化
        centerTitle: true,
        titleTextStyle: JinBeanTypography.h5.copyWith(
          color: JinBeanColors.textPrimary,
          fontWeight: JinBeanTypography.bold,
        ),
        iconTheme: const IconThemeData(color: JinBeanColors.textPrimary),
        actionsIconTheme: const IconThemeData(color: JinBeanColors.textPrimary),
      ),
      
      // 卡片主题 - My Diary 风格的现代化卡片
      cardTheme: baseTheme.cardTheme.copyWith(
        color: Colors.white,
        elevation: 8, // 增强阴影，更立体
        shadowColor: JinBeanColors.shadow.withValues(alpha: 0.15), // 更柔和的阴影
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // 更大的圆角，更现代化
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 更宽松的边距
      ),
      
      // 按钮主题 - My Diary 风格的现代化按钮
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JinBeanColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 6, // 增强阴影
          shadowColor: JinBeanColors.shadow.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // 更大的圆角
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // 更宽松的内边距
          textStyle: JinBeanTypography.button.copyWith(
            fontSize: 16, // 更大的字体
            fontWeight: JinBeanTypography.semiBold, // 更粗的字体
          ),
        ),
      ),
      
      // 输入框主题 - My Diary 风格的现代化输入框
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: const Color(0xFFF8F9FA), // 更柔和的背景色
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // 更大的圆角
          borderSide: BorderSide.none, // 无边框，更现代化
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: JinBeanColors.primaryDark, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // 更宽松的内边距
        labelStyle: JinBeanTypography.bodyMedium.copyWith(
          color: JinBeanColors.textSecondary,
          fontSize: 16, // 更大的标签字体
        ),
        hintStyle: JinBeanTypography.bodyMedium.copyWith(
          color: JinBeanColors.textTertiary,
          fontSize: 16,
        ),
      ),
      
      // 底部导航栏主题 - My Diary 风格的现代化导航栏
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: JinBeanColors.primaryDark,
        unselectedItemColor: JinBeanColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 12, // 增强阴影
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      
      // 浮动操作按钮主题 - My Diary 风格的现代化 FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: JinBeanColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 8, // 增强阴影
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)), // 更大的圆角
        ),
      ),
      
      // 对话框主题 - My Diary 风格的现代化对话框
      dialogTheme: baseTheme.dialogTheme.copyWith(
        backgroundColor: Colors.white,
        elevation: 16, // 增强阴影
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // 更大的圆角
        ),
        titleTextStyle: JinBeanTypography.h5.copyWith(
          color: JinBeanColors.textPrimary,
          fontWeight: JinBeanTypography.bold,
        ),
        contentTextStyle: JinBeanTypography.bodyMedium.copyWith(
          color: JinBeanColors.textSecondary,
          fontSize: 16, // 更大的内容字体
        ),
      ),
      
      // 底部表单主题 - My Diary 风格的现代化底部表单
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // 更大的圆角
        ),
      ),
      
      // 进度指示器主题 - My Diary 风格的现代化进度指示器
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: JinBeanColors.primaryDark,
        linearTrackColor: Color(0xFFE8EAED),
        circularTrackColor: Color(0xFFE8EAED),
      ),
      
      // 开关主题 - My Diary 风格的现代化开关
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primaryDark;
          }
          return JinBeanColors.textTertiary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primaryDark.withValues(alpha: 0.3); // 更柔和的选中色
          }
          return const Color(0xFFE8EAED);
        }),
      ),
      
      // 复选框主题 - My Diary 风格的现代化复选框
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primaryDark;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6), // 适中的圆角
        ),
      ),
      
      // 单选按钮主题 - My Diary 风格的现代化单选按钮
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primaryDark;
          }
          return JinBeanColors.textTertiary;
        }),
      ),
      
      // 滑块主题 - My Diary 风格的现代化滑块
      sliderTheme: SliderThemeData(
        activeTrackColor: JinBeanColors.primaryDark,
        inactiveTrackColor: const Color(0xFFE8EAED),
        thumbColor: JinBeanColors.primaryDark,
        overlayColor: JinBeanColors.primaryDark.withValues(alpha: 0.2),
        valueIndicatorColor: JinBeanColors.primaryDark,
        valueIndicatorTextStyle: JinBeanTypography.labelMedium.copyWith(
          color: Colors.white,
          fontSize: 14, // 更大的字体
        ),
      ),
    );
  }
  
  /// 服务商深色主题
  static ThemeData get darkTheme {
    final baseTheme = JinBeanTheme.darkTheme;
    
    return baseTheme.copyWith(
      // 服务商深色主题的颜色调整
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: JinBeanColors.primary, // 保持原有的蓝色
        secondary: JinBeanColors.secondary, // 保持原有的紫色
        tertiary: const Color(0xFF4CAF50), // 深色模式下的绿色
        surface: const Color(0xFF121212), // 标准的深色背景
        surfaceVariant: const Color(0xFF1E1E1E), // 标准的变体背景
      ),
      
      // AppBar 主题
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: Colors.transparent, // 透明背景
        elevation: 0,
        centerTitle: true,
        titleTextStyle: JinBeanTypography.h5.copyWith(
          color: Colors.white,
          fontWeight: JinBeanTypography.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      // 卡片主题
      cardTheme: baseTheme.cardTheme.copyWith(
        color: const Color(0xFF1E1E1E),
        elevation: 12, // 增强阴影
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // 更大的圆角
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JinBeanColors.primary,
          foregroundColor: Colors.white,
          elevation: 8, // 增强阴影
          shadowColor: Colors.black.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // 更大的圆角
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
          borderRadius: BorderRadius.circular(16), // 更大的圆角
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: JinBeanColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: JinBeanTypography.bodyMedium.copyWith(
          color: Colors.grey[400],
          fontSize: 16,
        ),
        hintStyle: JinBeanTypography.bodyMedium.copyWith(
          color: Colors.grey[500],
          fontSize: 16,
        ),
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF121212),
        selectedItemColor: JinBeanColors.primary,
        unselectedItemColor: Color(0xFF9E9E9E),
        type: BottomNavigationBarType.fixed,
        elevation: 12, // 增强阴影
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      
      // 浮动操作按钮主题
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: JinBeanColors.primary,
        foregroundColor: Colors.white,
        elevation: 8, // 增强阴影
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)), // 更大的圆角
        ),
      ),
      
      // 对话框主题
      dialogTheme: baseTheme.dialogTheme.copyWith(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 16, // 增强阴影
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // 更大的圆角
        ),
        titleTextStyle: JinBeanTypography.h5.copyWith(
          color: Colors.white,
          fontWeight: JinBeanTypography.bold,
        ),
        contentTextStyle: JinBeanTypography.bodyMedium.copyWith(
          color: Colors.grey[300],
          fontSize: 16,
        ),
      ),
      
      // 底部表单主题
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // 更大的圆角
        ),
      ),
      
      // 进度指示器主题
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: JinBeanColors.primary,
        linearTrackColor: Color(0xFF2A2A2A),
        circularTrackColor: Color(0xFF2A2A2A),
      ),
      
      // 开关主题
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primary;
          }
          return Colors.grey[500];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primary.withValues(alpha: 0.3);
          }
          return const Color(0xFF2A2A2A);
        }),
      ),
      
      // 复选框主题
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      
      // 单选按钮主题
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primary;
          }
          return Colors.grey[500];
        }),
      ),
      
      // 滑块主题
      sliderTheme: SliderThemeData(
        activeTrackColor: JinBeanColors.primary,
        inactiveTrackColor: const Color(0xFF2A2A2A),
        thumbColor: JinBeanColors.primary,
        overlayColor: JinBeanColors.primary.withValues(alpha: 0.2),
        valueIndicatorColor: JinBeanColors.primary,
        valueIndicatorTextStyle: JinBeanTypography.labelMedium.copyWith(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }
} 