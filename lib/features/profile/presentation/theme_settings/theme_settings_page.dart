import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './theme_settings_controller.dart';

class ThemeSettingsPage extends GetView<ThemeSettingsController> {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
      ),
      body: const Center(
        child: Text('Theme Settings Page Content'),
      ),
    );
  }
} 