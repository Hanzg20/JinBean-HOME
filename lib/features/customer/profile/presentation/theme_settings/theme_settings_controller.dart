import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jinbeanpod_83904710/app/theme/app_theme_service.dart';

class ThemeSettingsController extends GetxController {
  final AppThemeService _themeService = Get.find<AppThemeService>();
  final Rx<ThemeMode> selectedMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    selectedMode.value = _themeService.themeMode;
  }

  void selectMode(ThemeMode mode) {
    _themeService.setThemeMode(mode);
    selectedMode.value = mode;
    Get.snackbar(
      'Appearance Updated',
      mode == ThemeMode.system ? 'Follow system appearance' : mode == ThemeMode.light ? 'Light mode enabled' : 'Dark mode enabled',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
} 