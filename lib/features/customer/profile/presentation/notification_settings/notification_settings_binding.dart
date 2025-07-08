import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/notification_settings/notification_settings_controller.dart';

class NotificationSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationSettingsController>(
      () => NotificationSettingsController(),
    );
  }
} 