import 'package:get/get.dart';
import 'theme_settings_controller.dart';

class ProviderThemeSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProviderThemeSettingsController>(() => ProviderThemeSettingsController());
  }
} 