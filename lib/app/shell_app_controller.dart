import 'package:get/get.dart';

class ShellAppController extends GetxController {
  final RxInt _currentIndex = 0.obs;

  int get currentIndex => _currentIndex.value;

  void changeTab(int index) {
    _currentIndex.value = index;
    print('ShellAppController: Changed tab to index: $index');
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
    print('ShellAppController: setTabSafe to index: \\${_currentIndex.value} (maxTabs: \\${maxTabs})');
  }

  @override
  void onInit() {
    super.onInit();
    print('ShellAppController initialized');
  }

  @override
  void onClose() {
    print('ShellAppController disposed');
    _currentIndex.close();
    super.onClose();
  }
} 