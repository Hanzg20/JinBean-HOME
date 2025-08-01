import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/theme_settings/theme_settings_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations_en.dart';

class ThemeSettingsPage extends GetView<ThemeSettingsController> {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
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
            Text('Choose App Appearance', style: TextStyle(color: onSurface)),
            Obx(() => RadioListTile<ThemeMode>(
                  title: Text('Follow System', style: TextStyle(color: onSurface)),
                  value: ThemeMode.system,
                  groupValue: controller.selectedMode.value,
                  onChanged: (value) => controller.selectMode(value!),
                )),
            Obx(() => RadioListTile<ThemeMode>(
                  title: Text('Light', style: TextStyle(color: onSurface)),
                  value: ThemeMode.light,
                  groupValue: controller.selectedMode.value,
                  onChanged: (value) => controller.selectMode(value!),
                )),
            Obx(() => RadioListTile<ThemeMode>(
                  title: Text('Dark', style: TextStyle(color: onSurface)),
                  value: ThemeMode.dark,
                  groupValue: controller.selectedMode.value,
                  onChanged: (value) => controller.selectMode(value!),
                )),
          ],
        ),
      ),
    );
  }
} 