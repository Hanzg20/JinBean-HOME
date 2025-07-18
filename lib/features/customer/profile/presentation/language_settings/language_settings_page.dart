import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './language_settings_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations_en.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class LanguageSettingsPage extends GetView<LanguageSettingsController> {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final getLocale = Get.locale;
    final systemLocale = Localizations.localeOf(context);
    final currentLocale = getLocale ?? systemLocale;
    debugPrint('[LanguageSettingsPage] Get.locale: \\$getLocale, System locale: \\$systemLocale, Using: \\$currentLocale');
    Locale? selectedLocale = currentLocale;
    return Scaffold(
      appBar: AppBar(
        title: Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).languageSettings),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text((AppLocalizations.of(context) ?? AppLocalizationsEn()).languageSettingsPageContent),
            const SizedBox(height: 32),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<Locale>(
                value: selectedLocale,
                decoration: const InputDecoration(
                  labelText: '选择语言 / Select Language',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: Locale('en'),
                    child: Text('English (EN)'),
                  ),
                  DropdownMenuItem(
                    value: Locale('zh'),
                    child: Text('简体中文 (ZH)'),
                  ),
                ],
                onChanged: (locale) async {
                  if (locale != null && locale != Get.locale) {
                    controller.changeLanguage(locale);
                    // SnackBar 贴底显示，避免被页面内容遮挡
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('切换语言将在重新进入页面后生效', style: TextStyle(fontSize: 15, color: Colors.black)),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.fixed,
                        backgroundColor: Colors.white,
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 32), // 保证提示文字与底部 SnackBar 有安全距离
            Text(
              '切换后需重新进入页面才能生效',
              style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
} 