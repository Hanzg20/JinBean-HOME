import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/orders/presentation/orders_controller.dart';
import 'package:jinbeanpod_83904710/features/customer/orders/presentation/create_order_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersController>(() => OrdersController());
    Get.lazyPut<CreateOrderController>(() => CreateOrderController());
  }
} 