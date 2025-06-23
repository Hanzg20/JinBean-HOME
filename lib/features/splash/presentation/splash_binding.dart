import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/splash/presentation/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
} 