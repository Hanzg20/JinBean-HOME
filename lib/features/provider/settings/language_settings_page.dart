import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/language_settings/language_settings_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations_en.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class ProviderLanguageSettingsPage extends GetView<LanguageSettingsController> {
  const ProviderLanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = Get.locale ?? const Locale('zh');
    Locale? selectedLocale = currentLocale;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
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
                    await Future.delayed(const Duration(milliseconds: 300));
                    // 强制刷新整个App，确保所有界面语言生效
                    Phoenix.rebirth(context);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '切换后将自动刷新后台界面',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
} 