import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'service_marker_model.dart';
import '../../core/controllers/location_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class ServiceMapController extends GetxController {
  final RxList<ServiceMarkerModel> markers = <ServiceMarkerModel>[].obs;
  final RxBool isLoading = false.obs;

  // 地图当前中心点和缩放级别
  final RxDouble centerLat = RxDouble(45.4215);
  final RxDouble centerLng = RxDouble(-75.6997);
  final RxDouble zoom = RxDouble(12.0);

  // 服务类型筛选
  final RxString selectedCategory = ''.obs;

  Rx<BitmapDescriptor?> customMarkerIcon = Rx<BitmapDescriptor?>(null);

  // 新增：服务显示半径（单位：公里）
  final RxDouble serviceRadiusKm = 50.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCustomMarker();
    fetchMarkers();
  }

  Future<void> _loadCustomMarker() async {
    customMarkerIcon.value = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/jinbean_marker-0.png',
    );
    print('[ServiceMapController] 金豆marker图标已加载');
  }

  Future<void> fetchMarkers(
      {double? latMin,
      double? latMax,
      double? lngMin,
      double? lngMax,
      String? category}) async {
    isLoading.value = true;
    try {
      final userLocation = LocationController.instance.selectedLocation.value;
      if (userLocation == null) {
        isLoading.value = false;
        Get.dialog(
          AlertDialog(
            title: const Text('定位信息缺失'),
            content: const Text('请先选择或允许定位后再使用服务地图。'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('确定'),
              ),
            ],
          ),
        );
        return;
      }
      var query = Supabase.instance.client
          .from('services')
          .select(
              'id, title, description, latitude, longitude, category_level1_id, average_rating, review_count, images_url')
          .eq('status', 'active');
      print(
          '[ServiceMapController] 当前定位点: lat=${userLocation.latitude}, lng=${userLocation.longitude}');
      if (latMin != null &&
          latMax != null &&
          lngMin != null &&
          lngMax != null) {
        query = query
            .gte('latitude', latMin)
            .lte('latitude', latMax)
            .gte('longitude', lngMin)
            .lte('longitude', lngMax);
      }
      if (category != null && category.isNotEmpty) {
        query = query.eq('category_level1_id', category);
      }
      final data = await query;
      print('[ServiceMapController] 查询结果:');
      print(data);
      if ((data.isEmpty)) {
        print('[ServiceMapController] 查询结果为空，无服务点可显示');
      }
      List<ServiceMarkerModel> allMarkers = (data as List).map((e) {
        final lat = (e['latitude'] as num?)?.toDouble() ?? 0.0;
        final lng = (e['longitude'] as num?)?.toDouble() ?? 0.0;
        double? distance;
        distance = userLocation.distanceToCoordinates(lat, lng);
        final titleMap =
            (e['title'] is Map) ? Map<String, dynamic>.from(e['title']) : null;
        final descMap = (e['description'] is Map)
            ? Map<String, dynamic>.from(e['description'])
            : null;
        print(
            '[ServiceMapController] 服务点: id=${e['id']} lat=$lat lng=$lng 距离=${distance.toStringAsFixed(2) ?? '未知'}km');
        return ServiceMarkerModel(
          id: e['id'],
          name: titleMap?['zh'] ?? titleMap?['en'] ?? '',
          description: descMap?['zh'] ?? descMap?['en'] ?? '',
          latitude: lat,
          longitude: lng,
          category: e['category_level1_id']?.toString() ?? '',
          rating: (e['average_rating'] as num?)?.toDouble() ?? 0.0,
          reviewCount: e['review_count'] ?? 0,
          imageUrl:
              (e['images_url'] is List && (e['images_url'] as List).isNotEmpty)
                  ? e['images_url'][0]
                  : 'https://via.placeholder.com/80x80?text=No+Image',
          titleMap: titleMap,
          descriptionMap: descMap,
          distanceInKm: distance,
        );
      }).toList();
      print('[ServiceMapController] 原始 marker 数量: ${allMarkers.length}');
      final filteredMarkers = allMarkers
          .where((m) =>
              m.distanceInKm == null ||
              m.distanceInKm! <= serviceRadiusKm.value)
          .toList();
      print(
          '[ServiceMapController] 距离筛选后 marker 数量: ${filteredMarkers.length} (半径: ${serviceRadiusKm.value}km)');
      if (filteredMarkers.isEmpty) {
        print('[ServiceMapController] ⚠️ 当前范围内无服务点，请调整定位或扩大搜索半径');
      }
      // 后续聚合逻辑用 filteredMarkers 替换 markers
      markers.value = filteredMarkers;

      // ===== Dart 层 marker 聚合分组逻辑（网格聚合） =====
      final double currentZoom = zoom.value;
      final int gridSize = _getGridSizeForZoom(currentZoom);
      final Map<String, List<ServiceMarkerModel>> gridMap = {};
      for (final marker in markers) {
        final int latGrid = (marker.latitude * gridSize).floor();
        final int lngGrid = (marker.longitude * gridSize).floor();
        final String key = '$latGrid:$lngGrid';
        gridMap.putIfAbsent(key, () => []).add(marker);
      }
      final List<ServiceMarkerModel> clusteredMarkers = [];
      gridMap.forEach((key, list) {
        print(
            '[ServiceMapController] 分组 $key 数量: ${list.length}，包含id: ${list.map((m) => m.id).join(',')}');
        if (list.length == 1) {
          clusteredMarkers.add(list.first);
        } else {
          // 取第一个 marker，修改 name/description 显示聚合数量
          final m = list.first;
          clusteredMarkers.add(ServiceMarkerModel(
            id: m.id,
            name: '${m.name} 等${list.length}个服务',
            description: m.description,
            latitude: m.latitude,
            longitude: m.longitude,
            category: m.category,
            rating: m.rating,
            reviewCount: m.reviewCount,
            imageUrl: m.imageUrl,
            titleMap: m.titleMap,
            descriptionMap: m.descriptionMap,
            distanceInKm: m.distanceInKm,
          ));
        }
      });
      markers.value = clusteredMarkers;
      // ===== end 聚合分组 =====
      print(
          '[ServiceMapController] 聚合前 marker 数量: ${gridMap.values.fold<int>(0, (p, e) => p + e.length)}');
      print('[ServiceMapController] 聚合后 marker 数量: ${clusteredMarkers.length}');
      print('[ServiceMapController] 聚合分组数: ${gridMap.length}');

      print('[ServiceMapController] 最终 marker 数量: ${markers.value.length}');
    } catch (e, stack) {
      print('[ServiceMapController] 加载服务点异常: $e');
      print(stack);
    } finally {
      isLoading.value = false;
    }
  }

  // 新增：根据 zoom 级别动态调整聚合粒度（高 zoom 基本不聚合）
  int _getGridSizeForZoom(double zoom) {
    if (zoom >= 17) return 100000; // 完全不聚合
    if (zoom >= 16) return 10000;
    if (zoom >= 15) return 1000;
    if (zoom >= 14) return 100;
    if (zoom >= 12) return 20;
    if (zoom >= 10) return 10;
    return 5;
  }
}
