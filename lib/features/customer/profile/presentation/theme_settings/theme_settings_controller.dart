import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/app/theme/app_theme_service.dart';

class ThemeSettingsController extends GetxController {
  final AppThemeService _themeService = Get.find<AppThemeService>();

  // Observable for the currently selected theme name (e.g., 'dark_teal', 'golden')
  final RxString selectedThemeName = 'dark_teal'.obs; // Default to dark_teal

  @override
  void onInit() {
    super.onInit();
    // Initialize selectedThemeName based on the current theme in AppThemeService
    // This assumes AppThemeService has a way to get the current theme's identifier
    // For simplicity, we'll assume a method or direct access is available.
    // A more robust solution might pass the current theme name from AppThemeService.
    // For now, we'll derive it from the current theme object itself or rely on default.
    if (_themeService.currentTheme.value == _themeService.goldenTheme) {
      selectedThemeName.value = 'golden';
    } else {
      selectedThemeName.value = 'dark_teal';
    }
  }

  // Method to switch themes
  void selectTheme(String themeName) {
    _themeService.setThemeByName(themeName);
    selectedThemeName.value = themeName;
    Get.snackbar(
      'Theme Changed',
      'Theme set to ${themeName == 'golden' ? 'Golden' : 'Dark Teal'}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
} 