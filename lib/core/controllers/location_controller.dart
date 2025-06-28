import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

enum LocationSource {
  gps,
  manual,
  defaultLocation
}

class UserLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String district;
  final LocationSource source;
  final DateTime lastUpdated;

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.district,
    required this.source,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'district': district,
      'source': source.toString(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      source: LocationSource.values.firstWhere(
        (e) => e.toString() == json['source'],
        orElse: () => LocationSource.defaultLocation,
      ),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  // 计算到另一个位置的距离（公里）
  double distanceTo(UserLocation other) {
    return Geolocator.distanceBetween(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    ) / 1000; // 转换为公里
  }

  // 计算到指定坐标的距离（公里）
  double distanceToCoordinates(double lat, double lng) {
    return Geolocator.distanceBetween(
      latitude,
      longitude,
      lat,
      lng,
    ) / 1000; // 转换为公里
  }
}

class LocationController extends GetxController {
  static LocationController get instance => Get.find<LocationController>();

  final _storage = GetStorage();
  final _storageKey = 'user_location';

  // 响应式状态
  final currentLocation = Rxn<UserLocation>();
  final selectedLocation = Rxn<UserLocation>();
  final locationPermission = LocationPermission.denied.obs;
  final isLocationServiceEnabled = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // 默认位置（可以设置为应用默认城市）
  static final UserLocation _defaultLocation = UserLocation(
    latitude: 39.9042, // 北京天安门
    longitude: 116.4074,
    address: '北京市东城区天安门广场',
    city: '北京市',
    district: '东城区',
    source: LocationSource.defaultLocation,
    lastUpdated: DateTime.now(),
  );

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocation();
    _checkLocationServices();
  }

  // 检查位置服务是否启用
  Future<void> _checkLocationServices() async {
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      isLocationServiceEnabled.value = isEnabled;
      
      if (isEnabled) {
        await _checkLocationPermission();
      }
    } catch (e) {
      debugPrint('Error checking location services: $e');
    }
  }

  // 检查位置权限
  Future<void> _checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      locationPermission.value = permission;
      
      if (permission == LocationPermission.denied) {
        final requestedPermission = await Geolocator.requestPermission();
        locationPermission.value = requestedPermission;
      }
    } catch (e) {
      debugPrint('Error checking location permission: $e');
    }
  }

  // 加载保存的位置
  void _loadSavedLocation() {
    try {
      final savedLocationJson = _storage.read(_storageKey);
      if (savedLocationJson != null) {
        final savedLocation = UserLocation.fromJson(
          Map<String, dynamic>.from(savedLocationJson),
        );
        selectedLocation.value = savedLocation;
        currentLocation.value = savedLocation;
      }
    } catch (e) {
      debugPrint('Error loading saved location: $e');
    }
  }

  // 保存位置到本地存储
  Future<void> _saveLocation(UserLocation location) async {
    try {
      await _storage.write(_storageKey, location.toJson());
    } catch (e) {
      debugPrint('Error saving location: $e');
    }
  }

  // 获取当前位置
  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 检查位置服务是否启用
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) {
        errorMessage.value = 'Location services are disabled';
        return;
      }

      // 检查权限
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestedPermission = await Geolocator.requestPermission();
        if (requestedPermission == LocationPermission.denied ||
            requestedPermission == LocationPermission.deniedForever) {
          errorMessage.value = 'Location permission denied';
          return;
        }
      }

      // 获取位置
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // 反向地理编码获取地址
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final location = UserLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          address: _formatAddress(placemark),
          city: placemark.locality ?? '',
          district: placemark.subLocality ?? '',
          source: LocationSource.gps,
          lastUpdated: DateTime.now(),
        );

        currentLocation.value = location;
        selectedLocation.value = location;
        await _saveLocation(location);
      }
    } catch (e) {
      errorMessage.value = 'Failed to get current location: ${e.toString()}';
      debugPrint('Error getting current location: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 手动选择位置
  Future<void> selectLocation(UserLocation location) async {
    try {
      selectedLocation.value = location;
      await _saveLocation(location);
    } catch (e) {
      errorMessage.value = 'Failed to select location: ${e.toString()}';
      debugPrint('Error selecting location: $e');
    }
  }

  // 通过地址搜索位置
  Future<UserLocation?> searchLocationByAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          return UserLocation(
            latitude: location.latitude,
            longitude: location.longitude,
            address: _formatAddress(placemark),
            city: placemark.locality ?? '',
            district: placemark.subLocality ?? '',
            source: LocationSource.manual,
            lastUpdated: DateTime.now(),
          );
        }
      }
    } catch (e) {
      debugPrint('Error searching location by address: $e');
    }
    return null;
  }

  // 格式化地址
  String _formatAddress(Placemark placemark) {
    final parts = <String>[];
    
    if (placemark.street?.isNotEmpty == true) {
      parts.add(placemark.street!);
    }
    if (placemark.subLocality?.isNotEmpty == true) {
      parts.add(placemark.subLocality!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true) {
      parts.add(placemark.administrativeArea!);
    }
    
    return parts.join(', ');
  }

  // 获取当前选中的位置（如果没有则返回默认位置）
  UserLocation get effectiveLocation {
    return selectedLocation.value ?? currentLocation.value ?? _defaultLocation;
  }

  // 计算到指定坐标的距离
  double calculateDistance(double lat, double lng) {
    final location = effectiveLocation;
    return location.distanceToCoordinates(lat, lng);
  }

  // 格式化距离显示
  String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()}m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceInKm.round()}km';
    }
  }

  // 检查位置是否在服务区域内
  bool isLocationInServiceArea(
    UserLocation userLocation,
    Map<String, dynamic> serviceArea,
  ) {
    try {
      final serviceLat = serviceArea['latitude']?.toDouble();
      final serviceLng = serviceArea['longitude']?.toDouble();
      final radius = serviceArea['radius']?.toDouble() ?? 50.0; // 默认50公里

      if (serviceLat == null || serviceLng == null) {
        return false;
      }

      final distance = userLocation.distanceToCoordinates(serviceLat, serviceLng);
      return distance <= radius;
    } catch (e) {
      debugPrint('Error checking service area: $e');
      return false;
    }
  }

  // 清除错误信息
  void clearError() {
    errorMessage.value = '';
  }

  // 重置为默认位置
  void resetToDefault() {
    selectedLocation.value = _defaultLocation;
    _saveLocation(_defaultLocation);
  }
} 