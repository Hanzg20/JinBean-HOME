import 'package:get/get.dart';
import 'theme_settings_controller.dart';

class ThemeSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ThemeSettingsController>(() => ThemeSettingsController());
  }
} 