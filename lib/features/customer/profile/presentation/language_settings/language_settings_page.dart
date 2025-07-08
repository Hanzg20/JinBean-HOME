import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './language_settings_controller.dart';

class LanguageSettingsPage extends GetView<LanguageSettingsController> {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Settings'),
      ),
      body: const Center(
        child: Text('Language Settings Page Content'),
      ),
    );
  }
} 