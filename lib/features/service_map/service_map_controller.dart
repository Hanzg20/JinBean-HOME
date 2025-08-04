import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'service_marker_model.dart';
import '../../core/controllers/location_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:math';

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
  final RxDouble serviceRadiusKm = 5000.0.obs; // 增加到5000km，确保有服务点显示

  // 新增：地图控制相关属性
  final Rx<MapType> currentMapType = MapType.normal.obs;
  final RxBool isMapFullScreen = false.obs;
  final RxBool isLoadingMapData = false.obs;
  final RxString mapError = ''.obs;

  // 新增：路线导航相关属性
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxSet<Polyline> routePolylines = <Polyline>{}.obs;
  final Rx<Map<String, dynamic>?> currentRoute = Rx<Map<String, dynamic>?>(null);
  final RxList<Map<String, dynamic>> availableRoutes = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingRoute = false.obs;
  final RxString routeError = ''.obs;
  final RxString selectedTransportMode = 'car'.obs; // 'car', 'transit', 'walking', 'bicycle'

  // 新增：服务区域相关属性
  final RxSet<Circle> serviceAreaCircles = <Circle>{}.obs;
  final Rx<Map<String, dynamic>?> serviceAreaInfo = Rx<Map<String, dynamic>?>(null);

  // 新增：性能优化相关属性
  final RxBool isMapInitialized = false.obs;
  final RxMap<String, dynamic> _routeCache = <String, dynamic>{}.obs;
  final RxBool _isLoadingCachedData = false.obs;

  // 新增：地图状态持久化
  static const String _mapPreferencesKey = 'map_preferences';
  final GetStorage _storage = GetStorage();

  // 新增：性能监控
  final RxInt _mapRenderCount = 0.obs;
  final RxDouble _lastRenderTime = 0.0.obs;
  final RxBool _isPerformanceMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCustomMarker();
    // 延迟调用fetchMarkers，避免在构建过程中调用dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchMarkers();
    });
  }

  Future<void> _loadCustomMarker() async {
    customMarkerIcon.value = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/jinbean_marker-0.png',
    );
    print('[ServiceMapController] 金豆marker图标已加载');
  }

  // 新增：地图类型切换
  void toggleMapType() {
    switch (currentMapType.value) {
      case MapType.normal:
        currentMapType.value = MapType.satellite;
        break;
      case MapType.satellite:
        currentMapType.value = MapType.terrain;
        break;
      case MapType.terrain:
        currentMapType.value = MapType.normal;
        break;
      default:
        currentMapType.value = MapType.normal;
    }
  }

  // 新增：切换地图全屏模式
  void toggleMapFullScreen() {
    isMapFullScreen.value = !isMapFullScreen.value;
  }

  // 新增：加载服务区域信息
  Future<void> loadServiceAreaInfo() async {
    isLoadingMapData.value = true;
    mapError.value = '';
    
    try {
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 500));
      
      serviceAreaInfo.value = {
        'radius': 5000.0, // 增加到5000公里
        'responseTime': '2-4 hours',
        'arrivalTime': '15-30 minutes',
        'coverageArea': 'Greater Toronto Area, Hamilton, Mississauga, Brampton',
        'availability': 'Available 24/7',
        'serviceHours': 'Monday - Sunday: 8:00 AM - 10:00 PM',
      };
      
      serviceRadiusKm.value = serviceAreaInfo.value!['radius'];
      
    } catch (e) {
      mapError.value = 'Failed to load service area info: $e';
      print('[ServiceMapController] Error loading service area info: $e');
    } finally {
      isLoadingMapData.value = false;
    }
  }

  // 新增：计算从起点到终点的路线
  Future<void> calculateRoute({
    required LatLng start,
    required LatLng end,
    String? routeId,
    bool useCache = true,
  }) async {
    if (start == null || end == null) {
      routeError.value = 'Start or end location not available';
      return;
    }

    print('[ServiceMapController] Calculating route from ${start.latitude},${start.longitude} to ${end.latitude},${end.longitude}');

    // 检查缓存
    if (useCache) {
      final cachedRoute = getCachedRoute(start, end, selectedTransportMode.value);
      if (cachedRoute != null) {
        currentRoute.value = cachedRoute;
        _updateRoutePolyline(routeId);
        print('[ServiceMapController] Using cached route');
        return;
      }
    }

    isLoadingRoute.value = true;
    routeError.value = '';

    try {
      // 模拟API调用获取路线
      await Future.delayed(const Duration(milliseconds: 1000));

      // 计算直线距离
      final directDistance = _calculateDistance(start, end);
      print('[ServiceMapController] Direct distance: ${directDistance.toStringAsFixed(2)} km');

      // 生成不同交通方式的路线
      final routes = [
        {
          'mode': 'car',
          'duration': '8 min',
          'distance': '${(directDistance * 1.2).toStringAsFixed(1)} km',
          'traffic': 'Light',
          'route': 'via Queen St E',
          'points': _generateRoutePoints(start, end),
          'color': Colors.blue,
          'timestamp': DateTime.now(),
        },
        {
          'mode': 'transit',
          'duration': '15 min',
          'distance': '${(directDistance * 1.3).toStringAsFixed(1)} km',
          'traffic': 'N/A',
          'route': 'via TTC Bus 501',
          'points': _generateTransitRoutePoints(start, end),
          'color': Colors.green,
          'timestamp': DateTime.now(),
        },
        {
          'mode': 'walking',
          'duration': '45 min',
          'distance': '${directDistance.toStringAsFixed(1)} km',
          'traffic': 'N/A',
          'route': 'via pedestrian paths',
          'points': _generateWalkingRoutePoints(start, end),
          'color': Colors.orange,
          'timestamp': DateTime.now(),
        },
        {
          'mode': 'bicycle',
          'duration': '20 min',
          'distance': '${(directDistance * 1.1).toStringAsFixed(1)} km',
          'traffic': 'N/A',
          'route': 'via bike lanes',
          'points': _generateBicycleRoutePoints(start, end),
          'color': Colors.purple,
          'timestamp': DateTime.now(),
        },
      ];

      availableRoutes.value = routes;
      print('[ServiceMapController] Generated ${routes.length} routes');

      // 设置默认路线
      currentRoute.value = availableRoutes.first;
      _updateRoutePolyline(routeId);
      print('[ServiceMapController] Set current route: ${currentRoute.value?['mode']}');

      // 缓存所有路线
      for (final route in routes) {
        final mode = route['mode'] as String;
        _cacheRoute(start, end, mode, route);
      }

    } catch (e) {
      routeError.value = 'Failed to calculate route: $e';
      print('[ServiceMapController] Error calculating route: $e');
    } finally {
      isLoadingRoute.value = false;
    }
  }

  // 新增：计算两点间距离
  double _calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    ) / 1000; // 转换为公里
  }

  // 新增：生成路线点（模拟）
  List<LatLng> _generateRoutePoints(LatLng start, LatLng end) {
    final points = <LatLng>[start];
    
    // 生成中间点（实际应用中应该使用Google Directions API）
    final steps = 10;
    for (int i = 1; i < steps; i++) {
      final progress = i / steps;
      final lat = start.latitude + (end.latitude - start.latitude) * progress;
      final lng = start.longitude + (end.longitude - start.longitude) * progress;
      
      // 添加一些随机偏移来模拟真实路线
      final offset = 0.001 * (i % 3 - 1);
      points.add(LatLng(lat + offset, lng + offset));
    }
    
    points.add(end);
    return points;
  }

  // 新增：生成公交路线点
  List<LatLng> _generateTransitRoutePoints(LatLng start, LatLng end) {
    final points = <LatLng>[start];
    
    // 模拟公交路线（包含步行到车站、乘车、步行到目的地）
    final steps = 15;
    for (int i = 1; i < steps; i++) {
      final progress = i / steps;
      final lat = start.latitude + (end.latitude - start.latitude) * progress;
      final lng = start.longitude + (end.longitude - start.longitude) * progress;
      
      // 公交路线通常更直接
      points.add(LatLng(lat, lng));
    }
    
    points.add(end);
    return points;
  }

  // 新增：生成步行路线点
  List<LatLng> _generateWalkingRoutePoints(LatLng start, LatLng end) {
    final points = <LatLng>[start];
    
    // 步行路线通常更直接，但可能避开某些区域
    final steps = 20;
    for (int i = 1; i < steps; i++) {
      final progress = i / steps;
      final lat = start.latitude + (end.latitude - start.latitude) * progress;
      final lng = start.longitude + (end.longitude - start.longitude) * progress;
      
      // 步行路线更接近直线
      points.add(LatLng(lat, lng));
    }
    
    points.add(end);
    return points;
  }

  // 新增：生成自行车路线点
  List<LatLng> _generateBicycleRoutePoints(LatLng start, LatLng end) {
    final points = <LatLng>[start];
    
    // 自行车路线可能使用专用车道
    final steps = 12;
    for (int i = 1; i < steps; i++) {
      final progress = i / steps;
      final lat = start.latitude + (end.latitude - start.latitude) * progress;
      final lng = start.longitude + (end.longitude - start.longitude) * progress;
      
      // 自行车路线可能有轻微偏移
      final offset = 0.0005 * (i % 2 == 0 ? 1 : -1);
      points.add(LatLng(lat + offset, lng + offset));
    }
    
    points.add(end);
    return points;
  }

  // 新增：更新路线折线
  void _updateRoutePolyline(String? routeId) {
    routePolylines.clear();
    
    if (currentRoute.value != null && currentRoute.value!['points'] != null) {
      final points = currentRoute.value!['points'] as List<LatLng>;
      final color = currentRoute.value!['color'] as Color;
      final polylineId = routeId ?? 'route_${DateTime.now().millisecondsSinceEpoch}';
      
      print('[ServiceMapController] Updating route polyline with ${points.length} points');
      
      routePolylines.add(Polyline(
        polylineId: PolylineId(polylineId),
        points: points,
        color: color,
        width: 4,
        geodesic: true,
      ));
      
      print('[ServiceMapController] Route polyline updated successfully');
    } else {
      print('[ServiceMapController] No route data available for polyline update');
    }
  }

  // 新增：选择交通方式
  void selectTransportMode(String mode) {
    selectedTransportMode.value = mode;
    currentRoute.value = availableRoutes.firstWhereOrNull((route) => route['mode'] == mode);
    _updateRoutePolyline(null);
  }

  // 新增：获取当前路线信息
  Map<String, dynamic>? getCurrentRouteInfo() {
    return currentRoute.value;
  }

  // 新增：获取所有可用路线
  List<Map<String, dynamic>> getAllRoutes() {
    return availableRoutes;
  }

  // 新增：清除路线
  void clearRoute() {
    routePolylines.clear();
    currentRoute.value = null;
    availableRoutes.clear();
  }

  // 新增：添加服务区域圆形
  void addServiceAreaCircle({
    required LatLng center,
    required double radiusKm,
    String? circleId,
  }) {
    final id = circleId ?? 'service_area_${DateTime.now().millisecondsSinceEpoch}';
    
    serviceAreaCircles.add(Circle(
      circleId: CircleId(id),
      center: center,
      radius: radiusKm * 1000, // 转换为米
      strokeWidth: 2,
      strokeColor: Colors.blue.withOpacity(0.5),
      fillColor: Colors.blue.withOpacity(0.1),
    ));
  }

  // 新增：清除服务区域
  void clearServiceAreas() {
    serviceAreaCircles.clear();
  }

  // 新增：获取交通方式图标
  IconData getTransportIcon(String mode) {
    switch (mode) {
      case 'car':
        return Icons.directions_car;
      case 'transit':
        return Icons.directions_bus;
      case 'walking':
        return Icons.directions_walk;
      case 'bicycle':
        return Icons.directions_bike;
      default:
        return Icons.directions;
    }
  }

  // 新增：获取导航信息
  Map<String, dynamic> getNavigationInfo() {
    // 模拟导航信息
    return {
      'distance': '3.2 km',
      'duration': '8 minutes',
      'traffic': 'Light',
      'route': 'via Queen St E',
      'transportation': [
        {'type': 'car', 'duration': '8 min', 'distance': '3.2 km'},
        {'type': 'transit', 'duration': '15 min', 'distance': '3.5 km'},
        {'type': 'walking', 'duration': '45 min', 'distance': '3.2 km'},
      ],
    };
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
        // 延迟显示dialog，避免在构建过程中调用
        WidgetsBinding.instance.addPostFrameCallback((_) {
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
        });
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
          imageUrl: _getSafeImageUrl(e['images_url']),
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
        print('[ServiceMapController] ⚠️ 当前范围内无服务点，显示所有服务点');
        // 如果没有服务点，显示所有服务点
        markers.value = allMarkers;
      } else {
        // 后续聚合逻辑用 filteredMarkers 替换 markers
        markers.value = filteredMarkers;
      }

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

  // 新增：地图初始化优化
  Future<void> initializeMap() async {
    if (isMapInitialized.value) return;
    
    try {
      // 预加载服务区域信息
      await loadServiceAreaInfo();
      
      // 预加载markers
      await fetchMarkers();
      
      isMapInitialized.value = true;
    } catch (e) {
      print('[ServiceMapController] Error initializing map: $e');
    }
  }

  // 新增：路线缓存机制
  String _generateRouteCacheKey(LatLng start, LatLng end, String mode) {
    return '${start.latitude}_${start.longitude}_${end.latitude}_${end.longitude}_$mode';
  }

  // 新增：获取缓存的路线
  Map<String, dynamic>? getCachedRoute(LatLng start, LatLng end, String mode) {
    final cacheKey = _generateRouteCacheKey(start, end, mode);
    return _routeCache[cacheKey];
  }

  // 新增：缓存路线
  void _cacheRoute(LatLng start, LatLng end, String mode, Map<String, dynamic> routeData) {
    final cacheKey = _generateRouteCacheKey(start, end, mode);
    _routeCache[cacheKey] = routeData;
  }

  // 新增：清除过期缓存
  void clearExpiredCache() {
    final now = DateTime.now();
    _routeCache.removeWhere((key, value) {
      final timestamp = value['timestamp'] as DateTime?;
      if (timestamp == null) return true;
      return now.difference(timestamp).inHours > 24; // 24小时过期
    });
  }

  // 新增：性能优化方法
  void enablePerformanceMode() {
    _isPerformanceMode.value = true;
    // 减少marker数量，简化渲染
    if (markers.length > 20) {
      markers.value = markers.take(20).toList();
    }
  }

  void disablePerformanceMode() {
    _isPerformanceMode.value = false;
  }

  // 新增：记录渲染性能
  void _recordRenderPerformance() {
    _mapRenderCount.value++;
    _lastRenderTime.value = DateTime.now().millisecondsSinceEpoch.toDouble();
    
    // 如果渲染次数过多，启用性能模式
    if (_mapRenderCount.value > 100 && !_isPerformanceMode.value) {
      enablePerformanceMode();
    }
  }

  // 新增：获取性能统计
  Map<String, dynamic> getPerformanceStats() {
    return {
      'renderCount': _mapRenderCount.value,
      'lastRenderTime': _lastRenderTime.value,
      'isPerformanceMode': _isPerformanceMode.value,
      'cacheSize': _routeCache.length,
      'markerCount': markers.length,
    };
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

  String _getSafeImageUrl(List<dynamic>? imageUrls) {
    if (imageUrls == null || imageUrls.isEmpty) {
      return 'assets/images/jinbean_marker-0.png'; // 本地占位符
    }
    final firstImageUrl = imageUrls.first as String?;
    if (firstImageUrl == null || firstImageUrl.isEmpty) {
      return 'assets/images/jinbean_marker-0.png'; // 本地占位符
    }
    return firstImageUrl;
  }

  // 新增：智能地图缩放和定位
  void autoFitMapToMarkers() {
    if (markers.isEmpty) return;
    
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;
    
    for (final marker in markers) {
      minLat = min(minLat, marker.latitude);
      maxLat = max(maxLat, marker.latitude);
      minLng = min(minLng, marker.longitude);
      maxLng = max(maxLng, marker.longitude);
    }
    
    // 计算中心点
    final centerLatValue = (minLat + maxLat) / 2;
    final centerLngValue = (minLng + maxLng) / 2;
    
    // 计算合适的缩放级别
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = max(latDiff, lngDiff);
    
    double zoomLevel = 15.0;
    if (maxDiff > 10) zoomLevel = 8.0;
    else if (maxDiff > 5) zoomLevel = 10.0;
    else if (maxDiff > 1) zoomLevel = 12.0;
    else if (maxDiff > 0.1) zoomLevel = 14.0;
    
    // 更新地图中心点和缩放级别
    centerLat.value = centerLatValue;
    centerLng.value = centerLngValue;
    zoom.value = zoomLevel;
  }

  // 新增：智能定位到用户位置
  Future<void> centerOnUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      centerLat.value = position.latitude;
      centerLng.value = position.longitude;
      zoom.value = 15.0;
      
      // 重新获取markers
      await fetchMarkers();
    } catch (e) {
      print('[ServiceMapController] Error centering on user location: $e');
    }
  }

  // 新增：智能搜索附近服务
  Future<void> searchNearbyServices({double radiusKm = 50.0}) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // 计算搜索范围
      final latRange = radiusKm / 111.0; // 大约1度纬度 = 111km
      final lngRange = radiusKm / (111.0 * cos(position.latitude * pi / 180));
      
      await fetchMarkers(
        latMin: position.latitude - latRange,
        latMax: position.latitude + latRange,
        lngMin: position.longitude - lngRange,
        lngMax: position.longitude + lngRange,
      );
      
      // 自动调整地图视图
      autoFitMapToMarkers();
    } catch (e) {
      print('[ServiceMapController] Error searching nearby services: $e');
    }
  }
}
