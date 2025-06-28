import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './saved_services_controller.dart';

class SavedServicesPage extends GetView<SavedServicesController> {
  const SavedServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Saved Services'),
      ),
      body: const Center(
        child: Text('My Saved Services Page Content'),
      ),
    );
  }
} 