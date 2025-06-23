import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/community/presentation/community_controller.dart';

class CommunityBinding extends Bindings {
  @override
  void dependencies() {
    print('CommunityBinding: dependencies called');
    Get.put<CommunityController>(CommunityController(), permanent: true);
  }
} 