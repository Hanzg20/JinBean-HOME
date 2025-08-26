import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/community/presentation/community_controller.dart';

class CommunityBinding extends Bindings {
  @override
  void dependencies() {
    AppLogger.info('CommunityBinding: dependencies called');
    Get.put<CommunityController>(CommunityController(), permanent: true);
  }
} 