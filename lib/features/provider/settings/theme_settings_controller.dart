import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/app/theme/app_theme_service.dart';

class ProviderThemeSettingsController extends GetxController {
  final AppThemeService _themeService = Get.find<AppThemeService>();

  // Observable for the currently selected theme name (e.g., 'dark_teal', 'golden')
  final RxString selectedThemeName = 'golden'.obs; // Provider 默认金色

  @override
  void onInit() {
    super.onInit();
    // 初始化时读取 provider 端记忆的主题
    final saved = _themeService.getThemeForRole('provider');
    if (saved != null) {
      selectedThemeName.value = saved;
    }
  }

  // 切换主题
  void selectTheme(String themeName) {
    _themeService.setThemeForRole('provider', themeName); // 只影响provider端
    _themeService.setThemeByName(themeName); // 立即切换主题
    selectedThemeName.value = themeName;
    Get.snackbar(
      '主题已切换',
      themeName == 'golden' ? '已切换为金色主题' : '已切换为深青色主题',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
} 