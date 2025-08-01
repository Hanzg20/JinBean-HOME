import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class ShellAppController extends GetxController {
  final RxInt _currentIndex = 0.obs;

  int get currentIndex => _currentIndex.value;

  void changeTab(int index) {
    _currentIndex.value = index;
    AppLogger.info('ShellAppController: Changed tab to index: $index', tag: 'ShellAppController');
  }

  // 安全设置tab index，防止越界
  void setTabSafe(int index, int maxTabs) {
    if (maxTabs <= 0) {
      _currentIndex.value = 0;
    } else if (index < 0) {
      _currentIndex.value = 0;
    } else if (index >= maxTabs) {
      _currentIndex.value = 0;
    } else {
      _currentIndex.value = index;
    }
    AppLogger.info('ShellAppController: setTabSafe to index: \\${_currentIndex.value} (maxTabs: \\$maxTabs)', tag: 'ShellAppController');
  }

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('ShellAppController initialized', tag: 'ShellAppController');
  }

  @override
  void onClose() {
    AppLogger.info('ShellAppController disposed', tag: 'ShellAppController');
    _currentIndex.close();
    super.onClose();
  }
} 