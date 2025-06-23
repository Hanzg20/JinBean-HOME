import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/privacy_settings/privacy_settings_controller.dart';

class PrivacySettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrivacySettingsController>(
      () => PrivacySettingsController(),
    );
  }
} 