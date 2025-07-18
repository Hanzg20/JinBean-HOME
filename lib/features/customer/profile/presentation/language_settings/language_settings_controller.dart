import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class LanguageSettingsController extends GetxController {
  final currentLocale = Get.locale.obs;

  void changeLanguage(Locale locale) {
    Get.updateLocale(locale);
    currentLocale.value = locale;
    // 持久化用户选择的语言
    final box = GetStorage();
    box.write('preferredLocale', locale.languageCode);
    // TODO: Save preferred language to persistent storage
    Get.snackbar(
      AppLocalizations.of(Get.context!)?.languageChanged ?? '',
      AppLocalizations.of(Get.context!)?.languageChangedTo(locale.languageCode) ?? '',
      snackPosition: SnackPosition.BOTTOM,
    );
    // 切换语言后自动重启App，立即生效
    Future.delayed(const Duration(milliseconds: 500), () {
      // 避免与snackbar冲突，延迟重启
      if (Get.context != null) {
        Phoenix.rebirth(Get.context!);
      }
    });
  }
} 