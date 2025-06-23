import 'package:get/get.dart';

class NotificationSettingsController extends GetxController {
  final pushNotificationsEnabled = true.obs;
  final emailNotificationsEnabled = true.obs;
  final smsNotificationsEnabled = false.obs;


  void togglePushNotifications(bool value) {
    pushNotificationsEnabled.value = value;
    // TODO: Save setting to storage/backend
    Get.snackbar(
      'Notification Settings',
      'Push Notifications ${value ? "Enabled" : "Disabled"}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void toggleEmailNotifications(bool value) {
    emailNotificationsEnabled.value = value;
    // TODO: Save setting to storage/backend
    Get.snackbar(
      'Notification Settings',
      'Email Notifications ${value ? "Enabled" : "Disabled"}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void toggleSmsNotifications(bool value) {
    smsNotificationsEnabled.value = value;
    // TODO: Save setting to storage/backend
    Get.snackbar(
      'Notification Settings',
      'SMS Notifications ${value ? "Enabled" : "Disabled"}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
} 