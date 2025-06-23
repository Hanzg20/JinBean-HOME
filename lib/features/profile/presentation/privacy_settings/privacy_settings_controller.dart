import 'package:get/get.dart';

class PrivacySettingsController extends GetxController {
  final profileVisibility = 'public'.obs;
  final dataSharingEnabled = true.obs;
  final personalizedAdsEnabled = true.obs;


  void setProfileVisibility(String? visibility) {
    if (visibility != null) {
      profileVisibility.value = visibility;
      // TODO: Save setting to storage/backend
      Get.snackbar(
        'Privacy Settings',
        'Profile visibility set to $visibility',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void toggleDataSharing(bool value) {
    dataSharingEnabled.value = value;
    // TODO: Save setting to storage/backend
    Get.snackbar(
      'Privacy Settings',
      'Data sharing ${value ? "Enabled" : "Disabled"}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void togglePersonalizedAds(bool value) {
    personalizedAdsEnabled.value = value;
    // TODO: Save setting to storage/backend
    Get.snackbar(
      'Privacy Settings',
      'Personalized ads ${value ? "Enabled" : "Disabled"}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
} 