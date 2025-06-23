import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/home/presentation/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    print('HomeBinding: dependencies called');
    Get.put<HomeController>(HomeController(), permanent: true);
  }
} 