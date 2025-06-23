import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/my_reviews/my_reviews_controller.dart';

class MyReviewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyReviewsController>(
      () => MyReviewsController(),
    );
  }
} 