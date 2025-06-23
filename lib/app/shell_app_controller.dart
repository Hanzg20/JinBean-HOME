import 'package:get/get.dart';

class ShellAppController extends GetxController {
  final RxInt _currentIndex = 0.obs;

  int get currentIndex => _currentIndex.value;

  void changeTab(int index) {
    _currentIndex.value = index;
    print('ShellAppController: Changed tab to index: $index');
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