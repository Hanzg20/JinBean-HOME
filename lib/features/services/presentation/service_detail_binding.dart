import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/services/presentation/service_detail_controller.dart';

class ServiceDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceDetailController>(() => ServiceDetailController());
  }
} 