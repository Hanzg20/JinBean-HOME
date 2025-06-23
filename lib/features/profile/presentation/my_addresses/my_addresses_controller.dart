import 'package:get/get.dart';

class Address {
  final String id;
  final String alias;
  final String fullAddress;
  final bool isDefault;

  Address({
    required this.id,
    required this.alias,
    required this.fullAddress,
    this.isDefault = false,
  });
}

class MyAddressesController extends GetxController {
  final isLoading = false.obs;
  final addresses = <Address>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    isLoading.value = true;
    try {
      // TODO: Implement actual API call to fetch addresses
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1));
      addresses.value = [
        Address(
          id: 'a001',
          alias: 'Home',
          fullAddress: '123 Main St, Anytown, ON A1B 2C3',
          isDefault: true,
        ),
        Address(
          id: 'a002',
          alias: 'Work',
          fullAddress: '456 Business Ave, Othercity, ON C4D 5E6',
        ),
      ];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load addresses',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void addAddress(Address newAddress) {
    addresses.add(newAddress);
    // TODO: Implement API call to add address to backend
    Get.snackbar(
      'Success',
      'Address added successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void removeAddress(String id) {
    addresses.removeWhere((address) => address.id == id);
    // TODO: Implement API call to remove address from backend
    Get.snackbar(
      'Removed',
      'Address removed successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void setDefaultAddress(String id) {
    final index = addresses.indexWhere((address) => address.id == id);
    if (index != -1) {
      for (var i = 0; i < addresses.length; i++) {
        addresses[i] = Address(
          id: addresses[i].id,
          alias: addresses[i].alias,
          fullAddress: addresses[i].fullAddress,
          isDefault: (i == index), // Set the tapped address as default
        );
      }
      addresses.refresh(); // Notify GetX about changes
      // TODO: Implement API call to update default address on backend
      Get.snackbar(
        'Default Address',
        'Default address updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refreshAddresses() async {
    await loadAddresses();
  }
} 