import 'package:get/get.dart';

class PaymentMethod {
  final String id;
  final String type;
  final String lastFourDigits;
  final String expiryDate;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.lastFourDigits,
    required this.expiryDate,
    this.isDefault = false,
  });
}

class PaymentMethodsController extends GetxController {
  final isLoading = false.obs;
  final paymentMethods = <PaymentMethod>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPaymentMethods();
  }

  Future<void> loadPaymentMethods() async {
    isLoading.value = true;
    try {
      // TODO: Implement actual API call to fetch payment methods
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1));
      paymentMethods.value = [
        PaymentMethod(
          id: 'pm001',
          type: 'Visa',
          lastFourDigits: '1234',
          expiryDate: '12/25',
          isDefault: true,
        ),
        PaymentMethod(
          id: 'pm002',
          type: 'Mastercard',
          lastFourDigits: '5678',
          expiryDate: '06/27',
        ),
        PaymentMethod(
          id: 'pm003',
          type: 'Amex',
          lastFourDigits: '9012',
          expiryDate: '09/24',
        ),
      ];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payment methods',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void addPaymentMethod(PaymentMethod newMethod) {
    paymentMethods.add(newMethod);
    // TODO: Implement API call to add payment method to backend
    Get.snackbar(
      'Success',
      'Payment method added successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void removePaymentMethod(String id) {
    paymentMethods.removeWhere((method) => method.id == id);
    // TODO: Implement API call to remove payment method from backend
    Get.snackbar(
      'Removed',
      'Payment method removed successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void setDefaultPaymentMethod(String id) {
    final index = paymentMethods.indexWhere((method) => method.id == id);
    if (index != -1) {
      for (var i = 0; i < paymentMethods.length; i++) {
        paymentMethods[i] = PaymentMethod(
          id: paymentMethods[i].id,
          type: paymentMethods[i].type,
          lastFourDigits: paymentMethods[i].lastFourDigits,
          expiryDate: paymentMethods[i].expiryDate,
          isDefault: (i == index), // Set the tapped method as default
        );
      }
      paymentMethods.refresh(); // Notify GetX about changes
      // TODO: Implement API call to update default payment method on backend
      Get.snackbar(
        'Default Payment Method',
        'Default payment method updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refreshPaymentMethods() async {
    await loadPaymentMethods();
  }
} 