import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/app/shell_app_controller.dart';

class ShellAppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ShellAppController>(ShellAppController(), permanent: true);
    AppLogger.info('ShellAppBinding: ShellAppController put');
  }
} 