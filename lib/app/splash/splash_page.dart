import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('SplashPage: build method called');
    // Explicitly find the controller here
    final SplashController controller = Get.find<SplashController>();

    return Obx(() {
      if (controller.isReadyToNavigate.value) {
        // Schedule navigation after the current frame is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.navigateToNextScreen();
        });
        return const SizedBox.shrink(); // Hide splash page immediately after navigation
      }
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    });
  }
} 