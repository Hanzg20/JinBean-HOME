import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/home/presentation/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    AppLogger.info('HomeBinding: dependencies called');
    Get.put<HomeController>(HomeController(), permanent: true);
  }
}
