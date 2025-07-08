import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/auth/presentation/auth_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
} 