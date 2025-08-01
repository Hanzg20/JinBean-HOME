import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jinbeanpod_83904710/app/theme/app_colors.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/jinbean_theme.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/provider_theme.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/customer_theme.dart';

class AppThemeService extends GetxService {
  final _box = GetStorage();
  final String _themeKey = 'currentTheme';
  final String _themeModeKey = 'themeMode';

  // Observable for the current theme
  Rx<ThemeData> currentTheme = ThemeData.light().obs; // Default to light theme

  // 获取当前主题名
  String get currentThemeName => _box.read(_themeKey) ?? 'dark_teal';

  // 获取当前ThemeMode
  ThemeMode get themeMode {
    final mode = _box.read(_themeModeKey);
    if (mode == 'light') return ThemeMode.light;
    if (mode == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  @override
  void onInit() {
    super.onInit();
    loadTheme();
    // 设置ThemeMode
    Get.changeThemeMode(themeMode);
  }

  // Load saved theme preference
  void loadTheme() {
    final savedThemeName = _box.read(_themeKey) ?? 'dark_teal'; // Default to dark_teal
    setThemeByName(savedThemeName);
  }

  // Set theme by name and update observable
  void setThemeByName(String themeName) {
    if (themeName == 'golden') {
      currentTheme.value = goldenTheme;
    } else if (themeName == 'jinbean_provider') {
      currentTheme.value = JinBeanProviderTheme.lightTheme;
    } else if (themeName == 'jinbean_customer') {
      currentTheme.value = JinBeanCustomerTheme.lightTheme;
    } else if (themeName == 'jinbean_base') {
      currentTheme.value = JinBeanTheme.lightTheme;
    } else {
      currentTheme.value = darkTealTheme; // Default or fallback
    }
    _box.write(_themeKey, themeName);
    Get.changeTheme(currentTheme.value); // Apply theme to GetX
  }

  // Define the Dark Teal Theme
  ThemeData get darkTealTheme {
    const colorScheme = ColorScheme(
      primary: AppColors.primaryColor,
      onPrimary: AppColors.cardColor,
      secondary: AppColors.accentColor,
      onSecondary: AppColors.cardColor,
      error: AppColors.errorColor,
      onError: AppColors.cardColor,
      surface: AppColors.cardColor,
      onSurface: AppColors.textColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      primaryColor: colorScheme.primary,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardColor: colorScheme.surface,
      dividerColor: AppColors.dividerColor,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: colorScheme.onSurface),
        bodyMedium: TextStyle(color: colorScheme.onSurface),
        titleLarge: TextStyle(color: colorScheme.onSurface),
        titleMedium: TextStyle(color: colorScheme.onSurface),
        titleSmall: TextStyle(color: colorScheme.onSurface),
        displayLarge: TextStyle(color: colorScheme.onSurface),
        displayMedium: TextStyle(color: colorScheme.onSurface),
        displaySmall: TextStyle(color: colorScheme.onSurface),
        headlineLarge: TextStyle(color: colorScheme.onSurface),
        headlineMedium: TextStyle(color: colorScheme.onSurface),
        headlineSmall: TextStyle(color: colorScheme.onSurface),
        labelLarge: TextStyle(color: colorScheme.onSurface),
        labelMedium: TextStyle(color: colorScheme.onSurface),
        labelSmall: TextStyle(color: colorScheme.onSurface),
      ).apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        color: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: colorScheme.primary,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dividerColor),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurface),
        hintStyle: TextStyle(color: colorScheme.onSurface),
        prefixIconColor: colorScheme.primary,
        suffixIconColor: colorScheme.primary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 8,
      ),
    );
  }

  // Define the Golden Theme
  ThemeData get goldenTheme {
    const colorScheme = ColorScheme(
      primary: Color(0xFFFFA000), // 更深金色
      onPrimary: Colors.black,    // 文字更黑
      secondary: Color(0xFFFFB300),
      onSecondary: Colors.black,
      error: AppColors.errorColor,
      onError: Colors.black,
      surface: Color(0xFFFFFDE7), // 更浅背景
      onSurface: Colors.black,    // 文字更黑
      brightness: Brightness.light,
    );

    return ThemeData(
      primaryColor: colorScheme.primary,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardColor: colorScheme.surface,
      dividerColor: AppColors.dividerColor,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: colorScheme.onSurface),
        bodyMedium: TextStyle(color: colorScheme.onSurface),
        titleLarge: TextStyle(color: colorScheme.onSurface),
        titleMedium: TextStyle(color: colorScheme.onSurface),
        titleSmall: TextStyle(color: colorScheme.onSurface),
        displayLarge: TextStyle(color: colorScheme.onSurface),
        displayMedium: TextStyle(color: colorScheme.onSurface),
        displaySmall: TextStyle(color: colorScheme.onSurface),
        headlineLarge: TextStyle(color: colorScheme.onSurface),
        headlineMedium: TextStyle(color: colorScheme.onSurface),
        headlineSmall: TextStyle(color: colorScheme.onSurface),
        labelLarge: TextStyle(color: colorScheme.onSurface),
        labelMedium: TextStyle(color: colorScheme.onSurface),
        labelSmall: TextStyle(color: colorScheme.onSurface),
      ).apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        color: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: colorScheme.primary,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dividerColor),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurface),
        hintStyle: TextStyle(color: colorScheme.onSurface),
        prefixIconColor: colorScheme.primary,
        suffixIconColor: colorScheme.primary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFDE7),
        selectedItemColor: Color(0xFFFFA000),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 8,
      ),
    );
  }

  // 新增：为指定角色保存主题名
  void setThemeForRole(String role, String themeName) {
    final key = 'theme_$role';
    _box.write(key, themeName);
  }

  // 新增：获取指定角色的主题名，若无则 provider 返回 jinbean_provider，customer 返回 dark_teal
  String? getThemeForRole(String role) {
    final key = 'theme_$role';
    final theme = _box.read(key);
    if (theme != null) return theme;
    if (role == 'provider') return 'jinbean_provider';
    return 'dark_teal';
  }

  // 新增：根据角色获取主题
  ThemeData getThemeDataForRole(String role) {
    final themeName = getThemeForRole(role) ?? 'dark_teal';
    return getThemeByName(themeName);
  }

  // 新增：根据主题名获取主题数据
  ThemeData getThemeByName(String themeName) {
    switch (themeName) {
      case 'golden':
        return goldenTheme;
      case 'jinbean_provider':
        return JinBeanProviderTheme.lightTheme;
      case 'jinbean_customer':
        return JinBeanCustomerTheme.lightTheme;
      case 'jinbean_base':
        return JinBeanTheme.lightTheme;
      case 'dark_teal':
      default:
        return darkTealTheme;
    }
  }

  // 新增：根据角色和主题模式获取主题
  ThemeData getThemeForRoleAndMode(String role, ThemeMode mode) {
    final themeName = getThemeForRole(role) ?? 'dark_teal';
    final baseTheme = getThemeByName(themeName);
    
    if (mode == ThemeMode.dark) {
      switch (role) {
        case 'provider':
          return JinBeanProviderTheme.darkTheme;
        case 'customer':
          return JinBeanCustomerTheme.darkTheme;
        default:
          return JinBeanTheme.darkTheme;
      }
    }
    
    return baseTheme;
  }

  // 设置ThemeMode
  void setThemeMode(ThemeMode mode) {
    String modeStr = 'system';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.dark) modeStr = 'dark';
    _box.write(_themeModeKey, modeStr);
    Get.changeThemeMode(mode);
  }
} 