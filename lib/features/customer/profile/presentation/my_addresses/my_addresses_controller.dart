import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:jinbeanpod_83904710/core/services/address_service.dart';
import 'package:jinbeanpod_83904710/core/models/base_models.dart';

class MyAddressesController extends GetxController {
  final isLoading = false.obs;
  final addresses = <Address>[].obs;
  
  late final AddressService _addressService;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
    AppLogger.info('MyAddressesController initialized',
        tag: 'MyAddressesController');
    loadAddresses();
  }
  
  void _initializeService() {
    try {
      _addressService = Get.find<AddressService>();
    } catch (e) {
      _addressService = Get.put(AddressService());
    }
  }

  Future<void> loadAddresses() async {
    AppLogger.info('MyAddressesController: loadAddresses called',
        tag: 'MyAddressesController');
    isLoading.value = true;
    try {
      final userAddresses = await _addressService.getUserAddresses();
      addresses.value = userAddresses;
      AppLogger.info('MyAddressesController: Loaded ${userAddresses.length} addresses',
          tag: 'MyAddressesController');
    } catch (e, stack) {
      AppLogger.error('MyAddressesController: Failed to load addresses',
          error: e, stackTrace: stack, tag: 'MyAddressesController');
      // 显示错误提示
      Get.snackbar(
        'Error',
        'Failed to load addresses: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAddress(Address newAddress) async {
    AppLogger.info('MyAddressesController: addAddress called',
        tag: 'MyAddressesController');
    try {
      final addedAddress = await _addressService.addAddress(
        addressType: newAddress.addressType,
        country: newAddress.country,
        province: newAddress.province,
        city: newAddress.city,
        district: newAddress.district,
        streetNumber: newAddress.streetNumber,
        streetName: newAddress.streetName,
        streetType: newAddress.streetType,
        streetDirection: newAddress.streetDirection,
        suiteUnit: newAddress.suiteUnit,
        postalCode: newAddress.postalCode,
        latitude: newAddress.latitude,
        longitude: newAddress.longitude,
        setAsDefault: newAddress.isDefault,
      );
      
      if (addedAddress != null) {
        addresses.add(addedAddress);
        Get.snackbar(
          'Success',
          'Address added successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      AppLogger.error('MyAddressesController: Failed to add address',
          error: e, tag: 'MyAddressesController');
      Get.snackbar(
        'Error',
        'Failed to add address: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeAddress(String id) async {
    AppLogger.info('MyAddressesController: removeAddress called',
        tag: 'MyAddressesController');
    try {
      await _addressService.deleteAddress(id);
      addresses.removeWhere((address) => address.id == id);
      Get.snackbar(
        'Removed',
        'Address removed successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      AppLogger.error('MyAddressesController: Failed to remove address',
          error: e, tag: 'MyAddressesController');
      Get.snackbar(
        'Error',
        'Failed to remove address: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> setDefaultAddress(String id) async {
    AppLogger.info('MyAddressesController: setDefaultAddress called',
        tag: 'MyAddressesController');
    try {
      await _addressService.setDefaultAddress(id);
      
      // 更新本地状态
      final index = addresses.indexWhere((address) => address.id == id);
      if (index != -1) {
        for (var i = 0; i < addresses.length; i++) {
          addresses[i] = Address(
            id: addresses[i].id,
            standardAddressId: addresses[i].standardAddressId,
            country: addresses[i].country,
            province: addresses[i].province,
            city: addresses[i].city,
            district: addresses[i].district,
            streetNumber: addresses[i].streetNumber,
            streetName: addresses[i].streetName,
            streetType: addresses[i].streetType,
            streetDirection: addresses[i].streetDirection,
            suiteUnit: addresses[i].suiteUnit,
            postalCode: addresses[i].postalCode,
            latitude: addresses[i].latitude,
            longitude: addresses[i].longitude,
            geonamesId: addresses[i].geonamesId,
            extra: addresses[i].extra,
            createdAt: addresses[i].createdAt,
            updatedAt: addresses[i].updatedAt,
            userId: addresses[i].userId,
            addressType: addresses[i].addressType,
            isDefault: (i == index),
          );
        }
        addresses.refresh();
        
        Get.snackbar(
          'Default Address',
          'Default address updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      AppLogger.error('MyAddressesController: Failed to set default address',
          error: e, tag: 'MyAddressesController');
      Get.snackbar(
        'Error',
        'Failed to set default address: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refreshAddresses() async {
    await loadAddresses();
  }
}
