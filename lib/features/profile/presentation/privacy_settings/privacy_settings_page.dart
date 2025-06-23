import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './privacy_settings_controller.dart';

class PrivacySettingsPage extends GetView<PrivacySettingsController> {
  const PrivacySettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: const Center(
        child: Text('Privacy Settings Page Content'),
      ),
    );
  }
} 