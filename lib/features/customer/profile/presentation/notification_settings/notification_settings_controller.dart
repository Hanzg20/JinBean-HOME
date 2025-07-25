import 'package:get/get.dart';

class NotificationSettingsController extends GetxController {
  final isLoading = false.obs;
  final pushNotificationsEnabled = true.obs;
  final emailNotificationsEnabled = true.obs;
  final smsNotificationsEnabled = false.obs;
  final quietHoursEnabled = false.obs;
  final quietHoursStart = '22:00'.obs;
  final quietHoursEnd = '08:00'.obs;

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

  void toggleQuietHours(bool value) {
    quietHoursEnabled.value = value;
    // TODO: Save setting to storage/backend
    Get.snackbar(
      'Notification Settings',
      'Quiet Hours ${value ? "Enabled" : "Disabled"}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void setQuietHoursStart(String time) {
    quietHoursStart.value = time;
    // TODO: Save setting to storage/backend
  }

  void setQuietHoursEnd(String time) {
    quietHoursEnd.value = time;
    // TODO: Save setting to storage/backend
  }
} 