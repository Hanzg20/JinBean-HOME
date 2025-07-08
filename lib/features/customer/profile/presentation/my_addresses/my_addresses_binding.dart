import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/my_addresses/my_addresses_controller.dart';

class MyAddressesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyAddressesController>(
      () => MyAddressesController(),
    );
  }
} 