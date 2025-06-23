import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfilePage extends GetView {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: const Center(
        child: Text('Edit Profile Page Content'),
      ),
    );
  }
} 