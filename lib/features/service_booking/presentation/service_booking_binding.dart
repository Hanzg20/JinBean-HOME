import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/service_booking/presentation/service_booking_controller.dart';

class ServiceBookingBinding extends Bindings {
  @override
  void dependencies() {
    print('ServiceBookingBinding: dependencies called');
    Get.put<ServiceBookingController>(ServiceBookingController(), permanent: true);
  }
} 