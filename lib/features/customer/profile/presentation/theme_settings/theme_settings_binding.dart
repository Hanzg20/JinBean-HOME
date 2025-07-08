import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/theme_settings/theme_settings_controller.dart';

class ThemeSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ThemeSettingsController>(
      () => ThemeSettingsController(),
    );
  }
} 