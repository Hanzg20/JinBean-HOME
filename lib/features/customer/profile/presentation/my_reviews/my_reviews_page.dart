import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './my_reviews_controller.dart';

class MyReviewsPage extends GetView<MyReviewsController> {
  const MyReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reviews'),
      ),
      body: const Center(
        child: Text('My Reviews Page Content'),
      ),
    );
  }
} 