import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/theme_settings/theme_settings_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations_en.dart';

class ThemeSettingsPage extends GetView<ThemeSettingsController> {
  const ThemeSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(
        title: Text(((AppLocalizations.of(context) ?? AppLocalizationsEn()) as AppLocalizations).themeSettings),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () => Get.back(),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ((AppLocalizations.of(context) ?? AppLocalizationsEn()) as AppLocalizations).chooseAppTheme,
              style: TextStyle(color: onSurface),
            ),
            Obx(() => RadioListTile<String>(
                  title: Text(((AppLocalizations.of(context) ?? AppLocalizationsEn()) as AppLocalizations).deepTealTheme, style: TextStyle(color: onSurface)),
                  value: 'dark_teal',
                  groupValue: controller.selectedThemeName.value,
                  onChanged: (value) => controller.selectTheme(value!),
                )),
            Obx(() => RadioListTile<String>(
                  title: Text(((AppLocalizations.of(context) ?? AppLocalizationsEn()) as AppLocalizations).goldenJinBeanTheme, style: TextStyle(color: onSurface)),
                  value: 'golden',
                  groupValue: controller.selectedThemeName.value,
                  onChanged: (value) => controller.selectTheme(value!),
                )),
          ],
        ),
      ),
    );
  }
} 