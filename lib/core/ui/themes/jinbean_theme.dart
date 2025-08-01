import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/typography.dart';

/// JinBean 主题配置
class JinBeanTheme {
  /// 浅色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: JinBeanColors.lightColorScheme,
      textTheme: JinBeanTypography.textTheme,
      fontFamily: JinBeanTypography.fontFamily,
      
      // AppBar 主题
      appBarTheme: AppBarTheme(
        backgroundColor: JinBeanColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: JinBeanTypography.h5.copyWith(
          color: Colors.white,
          fontWeight: JinBeanTypography.semiBold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      // 卡片主题
      cardTheme: CardThemeData(
        color: JinBeanColors.surface,
        elevation: 2,
        shadowColor: JinBeanColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JinBeanColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: JinBeanColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: JinBeanTypography.button,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: JinBeanColors.primary,
          side: const BorderSide(color: JinBeanColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: JinBeanTypography.button,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: JinBeanColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: JinBeanTypography.button,
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: JinBeanColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: JinBeanColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: JinBeanColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: JinBeanColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: JinBeanColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: JinBeanTypography.bodyMedium.copyWith(
          color: JinBeanColors.textSecondary,
        ),
        hintStyle: JinBeanTypography.bodyMedium.copyWith(
          color: JinBeanColors.textTertiary,
        ),
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: JinBeanColors.surface,
        selectedItemColor: JinBeanColors.primary,
        unselectedItemColor: JinBeanColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      
      // 浮动操作按钮主题
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: JinBeanColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // 对话框主题
      dialogTheme: DialogThemeData(
        backgroundColor: JinBeanColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: JinBeanTypography.h5.copyWith(
          color: JinBeanColors.textPrimary,
          fontWeight: JinBeanTypography.semiBold,
        ),
        contentTextStyle: JinBeanTypography.bodyMedium.copyWith(
          color: JinBeanColors.textSecondary,
        ),
      ),
      
      // 底部表单主题
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: JinBeanColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      
      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: JinBeanColors.divider,
        thickness: 1,
        space: 1,
      ),
      
      // 进度指示器主题
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: JinBeanColors.primary,
        linearTrackColor: JinBeanColors.surfaceVariant,
        circularTrackColor: JinBeanColors.surfaceVariant,
      ),
      
      // 开关主题
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primary;
          }
          return JinBeanColors.textTertiary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primary.withOpacity(0.5);
          }
          return JinBeanColors.surfaceVariant;
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
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // 单选按钮主题
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return JinBeanColors.primary;
          }
          return JinBeanColors.textTertiary;
        }),
      ),
      
      // 滑块主题
      sliderTheme: SliderThemeData(
        activeTrackColor: JinBeanColors.primary,
        inactiveTrackColor: JinBeanColors.surfaceVariant,
        thumbColor: JinBeanColors.primary,
        overlayColor: JinBeanColors.primary.withOpacity(0.2),
        valueIndicatorColor: JinBeanColors.primary,
        valueIndicatorTextStyle: JinBeanTypography.labelMedium.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
  
  /// 深色主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: JinBeanColors.darkColorScheme,
      textTheme: JinBeanTypography.textTheme,
      fontFamily: JinBeanTypography.fontFamily,
      
      // AppBar 主题
      appBarTheme: AppBarTheme(
        backgroundColor: JinBeanColors.primaryLight,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: JinBeanTypography.h5.copyWith(
          color: Colors.black,
          fontWeight: JinBeanTypography.semiBold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      
      // 卡片主题
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JinBeanColors.primaryLight,
          foregroundColor: Colors.black,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: JinBeanTypography.button,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: JinBeanColors.primaryLight,
          side: const BorderSide(color: JinBeanColors.primaryLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: JinBeanTypography.button,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: JinBeanColors.primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: JinBeanTypography.button,
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: JinBeanColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: JinBeanColors.errorLight),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: JinBeanTypography.bodyMedium.copyWith(
          color: Colors.grey[400],
        ),
        hintStyle: JinBeanTypography.bodyMedium.copyWith(
          color: Colors.grey[500],
        ),
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
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
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // 对话框主题
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: JinBeanTypography.h5.copyWith(
          color: Colors.white,
          fontWeight: JinBeanTypography.semiBold,
        ),
        contentTextStyle: JinBeanTypography.bodyMedium.copyWith(
          color: Colors.grey[300],
        ),
      ),
      
      // 底部表单主题
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      
      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: Color(0xFF404040),
        thickness: 1,
        space: 1,
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
            return JinBeanColors.primaryLight.withOpacity(0.5);
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
          borderRadius: BorderRadius.circular(4),
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
        overlayColor: JinBeanColors.primaryLight.withOpacity(0.2),
        valueIndicatorColor: JinBeanColors.primaryLight,
        valueIndicatorTextStyle: JinBeanTypography.labelMedium.copyWith(
          color: Colors.black,
        ),
      ),
    );
  }
} 