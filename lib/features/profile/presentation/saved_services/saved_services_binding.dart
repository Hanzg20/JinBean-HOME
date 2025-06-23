import 'package:get/get.dart';
import './saved_services_controller.dart';

class SavedServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SavedServicesController>(() => SavedServicesController());
  }
} 