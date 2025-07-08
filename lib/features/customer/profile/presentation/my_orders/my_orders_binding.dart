import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/profile/presentation/my_orders/my_orders_controller.dart';

class MyOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyOrdersController>(
      () => MyOrdersController(),
    );
  }
} 