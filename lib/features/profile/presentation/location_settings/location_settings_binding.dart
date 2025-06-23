import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/location_settings/location_settings_controller.dart';

class LocationSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationSettingsController>(
      () => LocationSettingsController(),
    );
  }
} 