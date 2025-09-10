import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';
import '../models/base_models.dart';
import '../controllers/location_controller.dart';

/// 地址管理服务
/// 
/// 提供完整的地址管理功能，包括：
/// - 地址CRUD操作
/// - 默认地址管理
/// - 地址验证和格式化
/// - 地址搜索和建议
class AddressService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  late final LocationController _locationController;

  // 响应式状态
  final RxList<Address> addresses = <Address>[].obs;
  final Rx<Address?> defaultAddress = Rx<Address?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    
    // 获取LocationController实例
    try {
      _locationController = Get.find<LocationController>();
    } catch (e) {
      _locationController = Get.put(LocationController());
    }

    AppLogger.info('AddressService initialized');
  }

  // ========================================
  // 地址CRUD操作
  // ========================================

  /// 获取用户所有地址
  Future<List<Address>> getUserAddresses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', user.id)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      final List<Address> addressList = [];
      for (final addressData in response) {
        final address = Address.fromJson(addressData);
        addressList.add(address);
        
        // 设置默认地址
        if (address.isDefault) {
          defaultAddress.value = address;
        }
      }

      addresses.assignAll(addressList);
      AppLogger.info('获取用户地址成功: ${addressList.length} 个地址');
      
      return addressList;

    } catch (e) {
      errorMessage.value = '获取地址失败: $e';
      AppLogger.error('获取用户地址失败: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// 添加新地址
  Future<Address?> addAddress({
    required AddressType addressType,
    String? country,
    String? province,
    String? city,
    String? district,
    String? streetNumber,
    String? streetName,
    String? streetType,
    String? streetDirection,
    String? suiteUnit,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool setAsDefault = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // 如果设置为默认地址，先清除其他默认地址
      if (setAsDefault) {
        await _clearDefaultAddress(user.id);
      }

      // 构建完整地址用于地理编码
      final fullAddress = _buildFullAddress(
        streetNumber: streetNumber,
        streetName: streetName,
        streetType: streetType,
        streetDirection: streetDirection,
        suiteUnit: suiteUnit,
        city: city,
        province: province,
        country: country ?? 'Canada',
      );

      // 如果没有提供坐标，尝试通过地址获取
      if (latitude == null || longitude == null && fullAddress.isNotEmpty) {
        final location = await _locationController.searchLocationByAddress(fullAddress);
        if (location != null) {
          latitude = location.latitude;
          longitude = location.longitude;
        }
      }

      final addressData = {
        'user_id': user.id,
        'country': country ?? 'Canada',
        'province': province,
        'city': city,
        'district': district,
        'street_number': streetNumber,
        'street_name': streetName,
        'street_type': streetType,
        'street_direction': streetDirection,
        'suite_unit': suiteUnit,
        'postal_code': postalCode,
        'latitude': latitude,
        'longitude': longitude,
        'address_type': addressType.value,
        'is_default': setAsDefault,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('addresses')
          .insert(addressData)
          .select()
          .single();

      final newAddress = Address.fromJson(response);
      
      // 更新本地状态
      addresses.add(newAddress);
      if (setAsDefault) {
        defaultAddress.value = newAddress;
      }

      AppLogger.info('添加地址成功: ${newAddress.addressType.displayName}');
      return newAddress;

    } catch (e) {
      errorMessage.value = '添加地址失败: $e';
      AppLogger.error('添加地址失败: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 更新地址
  Future<Address?> updateAddress({
    required String addressId,
    AddressType? addressType,
    String? country,
    String? province,
    String? city,
    String? district,
    String? streetNumber,
    String? streetName,
    String? streetType,
    String? streetDirection,
    String? suiteUnit,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool? setAsDefault,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // 如果设置为默认地址，先清除其他默认地址
      if (setAsDefault == true) {
        await _clearDefaultAddress(user.id);
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      // 只更新提供的字段
      if (addressType != null) updateData['address_type'] = addressType.value;
      if (country != null) updateData['country'] = country;
      if (province != null) updateData['province'] = province;
      if (city != null) updateData['city'] = city;
      if (district != null) updateData['district'] = district;
      if (streetNumber != null) updateData['street_number'] = streetNumber;
      if (streetName != null) updateData['street_name'] = streetName;
      if (streetType != null) updateData['street_type'] = streetType;
      if (streetDirection != null) updateData['street_direction'] = streetDirection;
      if (suiteUnit != null) updateData['suite_unit'] = suiteUnit;
      if (postalCode != null) updateData['postal_code'] = postalCode;
      if (latitude != null) updateData['latitude'] = latitude;
      if (longitude != null) updateData['longitude'] = longitude;
      if (setAsDefault != null) updateData['is_default'] = setAsDefault;

      final response = await _supabase
          .from('addresses')
          .update(updateData)
          .eq('id', addressId)
          .eq('user_id', user.id)
          .select()
          .single();

      final updatedAddress = Address.fromJson(response);
      
      // 更新本地状态
      final index = addresses.indexWhere((addr) => addr.id == addressId);
      if (index != -1) {
        addresses[index] = updatedAddress;
      }
      
      if (setAsDefault == true) {
        defaultAddress.value = updatedAddress;
      }

      AppLogger.info('更新地址成功: ${updatedAddress.addressType.displayName}');
      return updatedAddress;

    } catch (e) {
      errorMessage.value = '更新地址失败: $e';
      AppLogger.error('更新地址失败: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 删除地址
  Future<bool> deleteAddress(String addressId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('addresses')
          .delete()
          .eq('id', addressId)
          .eq('user_id', user.id);

      // 更新本地状态
      final deletedAddress = addresses.firstWhereOrNull((addr) => addr.id == addressId);
      addresses.removeWhere((addr) => addr.id == addressId);
      
      // 如果删除的是默认地址，清除默认地址状态
      if (deletedAddress?.isDefault == true) {
        defaultAddress.value = null;
        
        // 如果还有其他地址，将第一个设为默认
        if (addresses.isNotEmpty) {
          await setDefaultAddress(addresses.first.id);
        }
      }

      AppLogger.info('删除地址成功: $addressId');
      return true;

    } catch (e) {
      errorMessage.value = '删除地址失败: $e';
      AppLogger.error('删除地址失败: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // 默认地址管理
  // ========================================

  /// 设置默认地址
  Future<bool> setDefaultAddress(String addressId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // 清除其他默认地址
      await _clearDefaultAddress(user.id);

      // 设置新的默认地址
      await _supabase
          .from('addresses')
          .update({
            'is_default': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', addressId)
          .eq('user_id', user.id);

      // 更新本地状态
      for (int i = 0; i < addresses.length; i++) {
        if (addresses[i].id == addressId) {
          addresses[i] = addresses[i].copyWith(isDefault: true);
          defaultAddress.value = addresses[i];
        } else {
          addresses[i] = addresses[i].copyWith(isDefault: false);
        }
      }

      AppLogger.info('设置默认地址成功: $addressId');
      return true;

    } catch (e) {
      AppLogger.error('设置默认地址失败: $e');
      return false;
    }
  }

  /// 清除所有默认地址
  Future<void> _clearDefaultAddress(String userId) async {
    await _supabase
        .from('addresses')
        .update({
          'is_default': false,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('is_default', true);
  }

  /// 获取默认地址
  Address? getDefaultAddress() {
    return defaultAddress.value ?? addresses.firstWhereOrNull((addr) => addr.isDefault);
  }

  // ========================================
  // 地址验证和格式化
  // ========================================

  /// 验证地址格式
  bool validateAddress(Address address) {
    // 基本字段验证
    if (address.fullAddress.trim().isEmpty) return false;
    if (address.city?.trim().isEmpty != false) return false;

    return true;
  }



  /// 格式化地址显示
  String formatAddressDisplay(Address address) {
    return address.fullAddress;
  }

  /// 获取地址简短描述
  String getAddressShortDescription(Address address) {
    return address.shortAddress;
  }

  // ========================================
  // 地址搜索和建议
  // ========================================

  /// 搜索地址建议
  Future<List<AddressSuggestion>> searchAddressSuggestions(String query) async {
    if (query.trim().length < 2) return [];

    try {
      // 使用LocationController进行地址搜索
      final location = await _locationController.searchLocationByAddress(query);
      
      if (location != null) {
        return [
          AddressSuggestion(
            id: 'search_result_1',
            title: location.address,
            subtitle: '${location.city} ${location.district}',
            fullAddress: location.address,
            city: location.city,
            district: location.district,
            latitude: location.latitude,
            longitude: location.longitude,
          ),
        ];
      }

      return [];

    } catch (e) {
      AppLogger.error('搜索地址建议失败: $e');
      return [];
    }
  }

  /// 获取附近的已保存地址
  List<Address> getNearbyAddresses(double latitude, double longitude, {double radiusKm = 5.0}) {
    return addresses.where((address) {
      if (address.latitude == null || address.longitude == null) return false;
      
      final distance = _locationController.calculateDistance(
        address.latitude!,
        address.longitude!,
      );
      
      return distance <= radiusKm;
    }).toList();
  }

  // ========================================
  // 实用方法
  // ========================================

  /// 获取地址数量
  int get addressCount => addresses.length;

  /// 检查是否有默认地址
  bool get hasDefaultAddress => defaultAddress.value != null;

  /// 获取地址标签建议
  List<String> getAddressLabelSuggestions() {
    return [
      '家',
      '公司',
      '学校',
      '朋友家',
      '父母家',
      '其他',
    ];
  }

  /// 构建完整地址字符串
  String _buildFullAddress({
    String? streetNumber,
    String? streetName,
    String? streetType,
    String? streetDirection,
    String? suiteUnit,
    String? city,
    String? province,
    String? country,
  }) {
    final parts = <String>[];
    
    // 构建街道地址
    final streetParts = [
      streetNumber,
      streetName,
      streetType,
      streetDirection,
    ].where((part) => part?.isNotEmpty == true).join(' ');
    
    if (streetParts.isNotEmpty) parts.add(streetParts);
    if (suiteUnit?.isNotEmpty == true) parts.add('Unit $suiteUnit');
    if (city?.isNotEmpty == true) parts.add(city!);
    if (province?.isNotEmpty == true) parts.add(province!);
    if (country?.isNotEmpty == true) parts.add(country!);
    
    return parts.join(', ');
  }

  /// 清除所有缓存数据
  void clearCache() {
    addresses.clear();
    defaultAddress.value = null;
    errorMessage.value = '';
  }

  /// 刷新地址列表
  Future<void> refreshAddresses() async {
    await getUserAddresses();
  }

  /// 获取地址统计信息
  Map<String, dynamic> getAddressStats() {
    return {
      'totalAddresses': addresses.length,
      'hasDefault': hasDefaultAddress,
      'addressTypes': addresses.map((addr) => addr.addressType.displayName).toSet().toList(),
      'citiesCount': addresses.map((addr) => addr.city).where((city) => city != null).toSet().length,
    };
  }
}

/// 地址搜索建议模型
class AddressSuggestion {
  final String id;
  final String title;
  final String subtitle;
  final String fullAddress;
  final String city;
  final String district;
  final double? latitude;
  final double? longitude;

  AddressSuggestion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.fullAddress,
    required this.city,
    required this.district,
    this.latitude,
    this.longitude,
  });
}
