import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LanguageSettingsController extends GetxController {
  final currentLocale = Get.locale.obs;

  void changeLanguage(Locale locale) {
    Get.updateLocale(locale);
    currentLocale.value = locale;
    // TODO: Save preferred language to persistent storage
    Get.snackbar(
      'Language Changed',
      'App language changed to ${locale.languageCode}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
} 