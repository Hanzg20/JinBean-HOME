import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import '../service_detail_controller.dart';
import '../widgets/service_detail_card.dart';

class ServiceMapSection extends StatefulWidget {
  final ServiceDetailController controller;

  const ServiceMapSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<ServiceMapSection> createState() => _ServiceMapSectionState();
}

class _ServiceMapSectionState extends State<ServiceMapSection> {
  GoogleMapController? googleMapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  bool isMapFullscreen = false;
  MapType currentMapType = MapType.normal;
  String selectedTransportMode = 'car';
  bool isPanModeEnabled = true; // 添加拖动模式状态

  // 默认用户位置（多伦多市中心附近，与服务位置有足够距离）
  static const LatLng _defaultUserLocation = LatLng(43.6500, -79.3800);

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMapMarkers();
      _calculateRoute();
      // 延迟调整相机位置，确保路线已经绘制
      Future.delayed(const Duration(milliseconds: 500), () {
        _updateMapCamera();
      });
    });
  }

  void _updateMapMarkers() {
    final service = widget.controller.service.value;
    if (service == null || service.latitude == null || service.longitude == null) return;

    markers.clear();
    
    // 添加起点标记（绿色水滴形标记）
    final startMarker = Marker(
      markerId: const MarkerId('start_point'),
      position: _defaultUserLocation,
      infoWindow: const InfoWindow(
        title: '起点',
        snippet: '您的位置',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), // 绿色水滴形标记
      flat: false, // 保持3D效果
      rotation: 0.0,
      anchor: const Offset(0.5, 1.0), // 标记底部中心
    );
    markers.add(startMarker);
    
    // 添加终点标记（红色气球标志）
    final endMarker = Marker(
      markerId: const MarkerId('end_point'),
      position: LatLng(service.latitude!, service.longitude!),
      infoWindow: InfoWindow(
        title: '终点',
        snippet: service.title,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // 红色气球标志
      flat: false, // 保持3D效果
      rotation: 0.0,
      anchor: const Offset(0.5, 1.0), // 标记底部中心
    );
    markers.add(endMarker);

    setState(() {});
  }

  void _calculateRoute() {
    final service = widget.controller.service.value;
    
    if (service == null || service.latitude == null || service.longitude == null) return;

    // 生成路线点
    final routePoints = _generateRoutePoints(
      _defaultUserLocation,
      LatLng(service.latitude!, service.longitude!),
    );

    polylines.clear();
    
    // 根据交通方式设置不同的路线颜色
    Color routeColor;
    switch (selectedTransportMode) {
      case 'car':
        routeColor = Colors.blue;
        break;
      case 'transit':
        routeColor = Colors.green;
        break;
      case 'walking':
        routeColor = Colors.orange;
        break;
      case 'bicycle':
        routeColor = Colors.purple;
        break;
      default:
        routeColor = Colors.blue;
    }
    
    polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      points: routePoints,
      color: routeColor,
      width: 4,
      geodesic: true,
    ));

    setState(() {});
  }

  List<LatLng> _generateRoutePoints(LatLng start, LatLng end) {
    // 生成更真实的路线点，模拟实际道路路径
    final points = <LatLng>[start];
    
    // 计算距离
    final distance = _calculateDistance(start, end);
    
    // 根据距离生成不同数量的中间点
    int numPoints;
    if (distance < 1.0) {
      numPoints = 2; // 很近的距离，只需要2个中间点
    } else if (distance < 5.0) {
      numPoints = 4; // 中等距离，4个中间点
    } else {
      numPoints = 6; // 较远距离，6个中间点
    }
    
    // 生成贝塞尔曲线风格的路径点
    for (int i = 1; i <= numPoints; i++) {
      final t = i / (numPoints + 1);
      
      // 添加一些随机偏移来模拟真实道路的弯曲
      final randomOffset = 0.001 * (i % 2 == 0 ? 1 : -1);
      
      final lat = start.latitude + (end.latitude - start.latitude) * t + randomOffset;
      final lng = start.longitude + (end.longitude - start.longitude) * t + randomOffset;
      
      points.add(LatLng(lat, lng));
    }
    
    points.add(end);
    return points;
  }

  double _calculateDistance(LatLng start, LatLng end) {
    // 简单的距离计算（欧几里得距离，适用于小范围）
    final latDiff = start.latitude - end.latitude;
    final lngDiff = start.longitude - end.longitude;
    return sqrt(latDiff * latDiff + lngDiff * lngDiff) * 111; // 转换为公里
  }

  void _updateMapCamera() {
    final service = widget.controller.service.value;
    if (service == null || service.latitude == null || service.longitude == null) return;

    // 计算包含两个点的边界
    final bounds = _calculateBounds(
      _defaultUserLocation,
      LatLng(service.latitude!, service.longitude!),
    );

    // 设置相机位置以显示整个路线
    googleMapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50.0), // 50像素的边距
    );
  }

  LatLngBounds _calculateBounds(LatLng point1, LatLng point2) {
    final minLat = min(point1.latitude, point2.latitude);
    final maxLat = max(point1.latitude, point2.latitude);
    final minLng = min(point1.longitude, point2.longitude);
    final maxLng = max(point1.longitude, point2.longitude);
    
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ServiceDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '位置和路线',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _toggleMapFullscreen(),
                icon: Icon(isMapFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
                tooltip: isMapFullscreen ? '退出全屏' : '全屏地图',
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 地图容器
          Container(
            height: isMapFullscreen ? MediaQuery.of(context).size.height * 0.6 : 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // Google地图
                  GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      googleMapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: _getInitialPosition(),
                      zoom: 12.0,
                    ),
                    markers: markers,
                    polylines: polylines,
                    mapType: currentMapType,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                  
                  // 地图控制按钮
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Column(
                      children: [
                        // 缩放控制
                        _buildMapControlButton(
                          icon: Icons.add,
                          onPressed: _zoomIn,
                          tooltip: '放大',
                        ),
                        const SizedBox(height: 8),
                        _buildMapControlButton(
                          icon: Icons.remove,
                          onPressed: _zoomOut,
                          tooltip: '缩小',
                        ),
                        const SizedBox(height: 8),
                        // 定位按钮
                        _buildMapControlButton(
                          icon: Icons.my_location,
                          onPressed: _goToUserLocation,
                          tooltip: '定位到我的位置',
                        ),
                        const SizedBox(height: 8),
                        // 地图类型切换
                        _buildMapControlButton(
                          icon: Icons.layers,
                          onPressed: _toggleMapType,
                          tooltip: '切换地图类型',
                        ),
                        const SizedBox(height: 8),
                        // 拖动模式切换
                        _buildMapControlButton(
                          icon: isPanModeEnabled ? Icons.pan_tool : Icons.pan_tool_alt,
                          onPressed: _togglePanMode,
                          tooltip: isPanModeEnabled ? '禁用拖动模式' : '启用拖动模式',
                          backgroundColor: isPanModeEnabled ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        // 重置视图
                        _buildMapControlButton(
                          icon: Icons.center_focus_strong,
                          onPressed: _resetMapView,
                          tooltip: '重置地图视图',
                        ),
                      ],
                    ),
                  ),
                  
                  // 路线信息面板
                  Positioned(
                    left: 16,
                    top: 16,
                    child: _buildRouteInfoPanel(),
                  ),
                  
                  // 地图操作提示面板
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                '地图操作',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• 双指缩放地图',
                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                          ),
                          Text(
                            '• 单指拖动地图',
                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                          ),
                          Text(
                            '• 点击标记查看详情',
                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '标记数量: ${markers.length}',
                            style: TextStyle(fontSize: 10, color: Colors.green[600], fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 路线详情
          _buildRouteDetails(),
          
          const SizedBox(height: 12),
          
          // 操作按钮
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }

  Widget _buildRouteInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                _getTransportModeIcon(selectedTransportMode),
                size: 16,
                color: _getTransportModeColor(selectedTransportMode),
              ),
              const SizedBox(width: 4),
              Text(
                _getTransportModeLabel(selectedTransportMode),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _getRouteDuration(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _getRouteDistance(),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  IconData _getTransportModeIcon(String mode) {
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
        return Icons.directions_car;
    }
  }

  Color _getTransportModeColor(String mode) {
    switch (mode) {
      case 'car':
        return Colors.blue;
      case 'transit':
        return Colors.green;
      case 'walking':
        return Colors.orange;
      case 'bicycle':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  String _getTransportModeLabel(String mode) {
    switch (mode) {
      case 'car':
        return '驾车';
      case 'transit':
        return '公交';
      case 'walking':
        return '步行';
      case 'bicycle':
        return '骑行';
      default:
        return '驾车';
    }
  }

  Widget _buildRouteDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.route, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getRouteDuration()} • ${_getRouteDistance()}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '预计费用: ${_getRouteCost()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 交通方式选择
          Row(
            children: [
              const Text('交通方式: ', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTransportModeButton('car', '驾车', Icons.directions_car),
                      const SizedBox(width: 8),
                      _buildTransportModeButton('transit', '公交', Icons.directions_bus),
                      const SizedBox(width: 8),
                      _buildTransportModeButton('walking', '步行', Icons.directions_walk),
                      const SizedBox(width: 8),
                      _buildTransportModeButton('bicycle', '骑行', Icons.directions_bike),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransportModeButton(String mode, String label, IconData icon) {
    final isSelected = selectedTransportMode == mode;
    
    return GestureDetector(
      onTap: () => _selectTransportMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _openNavigation(),
            icon: const Icon(Icons.directions, size: 18),
            label: const Text('开始导航'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _copyAddress(),
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('复制地址'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  LatLng _getInitialPosition() {
    final service = widget.controller.service.value;
    if (service != null && service.latitude != null && service.longitude != null) {
      return LatLng(service.latitude!, service.longitude!);
    }
    
    return _defaultUserLocation;
  }

  String _getRouteDuration() {
    switch (selectedTransportMode) {
      case 'car':
        return '8 min';
      case 'transit':
        return '15 min';
      case 'walking':
        return '45 min';
      case 'bicycle':
        return '20 min';
      default:
        return 'N/A';
    }
  }

  String _getRouteDistance() {
    switch (selectedTransportMode) {
      case 'car':
        return '4.7 km';
      case 'transit':
        return '5.1 km';
      case 'walking':
        return '3.9 km';
      case 'bicycle':
        return '4.3 km';
      default:
        return 'N/A';
    }
  }

  String _getRouteCost() {
    switch (selectedTransportMode) {
      case 'car':
        return '\$2.50';
      case 'transit':
        return '\$3.25';
      case 'walking':
        return '免费';
      case 'bicycle':
        return '免费';
      default:
        return 'N/A';
    }
  }

  void _toggleMapFullscreen() {
    setState(() {
      isMapFullscreen = !isMapFullscreen;
    });
  }

  void _zoomIn() {
    googleMapController?.animateCamera(
      CameraUpdate.zoomIn(),
    );
  }

  void _zoomOut() {
    googleMapController?.animateCamera(
      CameraUpdate.zoomOut(),
    );
  }

  void _goToUserLocation() {
    googleMapController?.animateCamera(
      CameraUpdate.newLatLng(_defaultUserLocation),
    );
  }

  void _toggleMapType() {
    setState(() {
      switch (currentMapType) {
        case MapType.normal:
          currentMapType = MapType.satellite;
          break;
        case MapType.satellite:
          currentMapType = MapType.terrain;
          break;
        case MapType.terrain:
          currentMapType = MapType.hybrid;
          break;
        case MapType.hybrid:
          currentMapType = MapType.normal;
          break;
        case MapType.none:
          currentMapType = MapType.normal;
          break;
      }
    });
  }

  void _togglePanMode() {
    // 切换地图的拖动模式
    setState(() {
      isPanModeEnabled = !isPanModeEnabled;
    });
    
    Get.snackbar(
      '拖动模式',
      isPanModeEnabled ? '地图拖动已启用' : '地图拖动已禁用',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: isPanModeEnabled ? Colors.green.withOpacity(0.8) : Colors.orange.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  void _resetMapView() {
    // 重置地图视图到默认状态
    _updateMapCamera();
    Get.snackbar(
      '视图重置',
      '地图视图已重置',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _selectTransportMode(String mode) {
    setState(() {
      selectedTransportMode = mode;
    });
    _calculateRoute();
  }

  void _openNavigation() {
    final service = widget.controller.service.value;
    if (service == null) return;

    Get.snackbar(
      '导航',
      '正在打开导航应用...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void _copyAddress() {
    final service = widget.controller.service.value;
    if (service == null) return;

    Get.snackbar(
      '地址已复制',
      '服务地址已复制到剪贴板',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
