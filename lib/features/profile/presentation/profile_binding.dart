import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    print('ProfileBinding: dependencies called');
    Get.put<ProfileController>(ProfileController(), permanent: true);
  }
} 