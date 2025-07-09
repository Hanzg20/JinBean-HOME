import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme_settings_controller.dart';

class ProviderThemeSettingsPage extends GetView<ProviderThemeSettingsController> {
  const ProviderThemeSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题设置'),
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
              '请选择服务商端主题：',
              style: TextStyle(color: onSurface),
            ),
            Obx(() => RadioListTile<String>(
                  title: Text('深青色主题', style: TextStyle(color: onSurface)),
                  value: 'dark_teal',
                  groupValue: controller.selectedThemeName.value,
                  onChanged: (value) => controller.selectTheme(value!),
                )),
            Obx(() => RadioListTile<String>(
                  title: Text('金色主题', style: TextStyle(color: onSurface)),
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