import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/payment_methods/payment_methods_controller.dart';

class PaymentMethodsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentMethodsController>(
      () => PaymentMethodsController(),
    );
  }
} 