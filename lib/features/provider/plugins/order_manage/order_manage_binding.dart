import 'package:get/get.dart';
import 'order_manage_controller.dart';

class OrderManageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderManageController>(() => OrderManageController());
  }
} 