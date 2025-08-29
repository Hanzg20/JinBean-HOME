import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/customer/splash/presentation/splash_controller.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.info('SplashPage: build method called');
    // Explicitly find the controller here
    final SplashController controller = Get.find<SplashController>();

    return Obx(() {
      if (controller.isReadyToNavigate.value) {
        // Schedule navigation after the current frame is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.navigateToLogin();
        });
        return const SizedBox
            .shrink(); // Hide splash page immediately after navigation
      }
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    });
  }
}
