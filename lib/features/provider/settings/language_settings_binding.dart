import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/language_settings/language_settings_controller.dart';

class ProviderLanguageSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageSettingsController>(() => LanguageSettingsController());
  }
} 