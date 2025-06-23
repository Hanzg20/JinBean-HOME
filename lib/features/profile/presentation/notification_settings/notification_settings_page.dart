import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './notification_settings_controller.dart';

class NotificationSettingsPage extends GetView<NotificationSettingsController> {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: const Center(
        child: Text('Notification Settings Page Content'),
      ),
    );
  }
} 