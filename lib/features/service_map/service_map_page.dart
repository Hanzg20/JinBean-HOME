// 依赖: google_maps_flutter
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'service_map_controller.dart';
import 'service_marker_model.dart';
import '../../core/controllers/location_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';

class ServiceMapPage extends StatefulWidget {
  const ServiceMapPage({super.key});

  @override
  State<ServiceMapPage> createState() => _ServiceMapPageState();
}

class _ServiceMapPageState extends State<ServiceMapPage> {
  final controller = Get.put(ServiceMapController());
  ServiceMarkerModel? selectedMarker;
  GoogleMapController? mapController;

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.languageCode ?? 'zh';
    // 检查定位信息是否可用
    final userLocation = LocationController.instance.selectedLocation.value;
    if (userLocation == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.serviceMap)),
        body: Center(child: Text(AppLocalizations.of(context)!.locationMissing)),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('服务地图'),
        actions: [
          Obx(() => PopupMenuButton<double>(
            icon: const Icon(Icons.tune),
            initialValue: controller.serviceRadiusKm.value,
            onSelected: (value) {
              controller.serviceRadiusKm.value = value;
              controller.fetchMarkers();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 10.0, child: Text('10公里内')),
              PopupMenuItem(value: 20.0, child: Text('20公里内')),
              PopupMenuItem(value: 50.0, child: Text('50公里内')),
              PopupMenuItem(value: 100.0, child: Text('100公里内')),
              PopupMenuItem(value: 5000.0, child: Text('5000公里内')),
            ],
          )),
        ],
      ),
      body: Obx(() => Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(controller.centerLat.value, controller.centerLng.value),
              zoom: controller.zoom.value,
            ),
            myLocationEnabled: true,
            markers: controller.markers.map((m) => Marker(
              markerId: MarkerId(m.id),
              position: LatLng(m.latitude, m.longitude),
              icon: controller.customMarkerIcon.value ?? BitmapDescriptor.defaultMarker,
              onTap: () {
                setState(() {
                  selectedMarker = m;
                });
              },
            )).toSet(),
            onTap: (_) {
              setState(() {
                selectedMarker = null;
              });
            },
            onCameraIdle: () {
              controller.fetchMarkers();
            },
            onCameraMove: (pos) {
              controller.centerLat.value = pos.target.latitude;
              controller.centerLng.value = pos.target.longitude;
              controller.zoom.value = pos.zoom;
            },
            onMapCreated: (c) {
              mapController = c;
            },
          ),
          if (controller.isLoading.value)
            const Center(child: CircularProgressIndicator()),
          if (selectedMarker != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 32,
              child: _buildServiceCard(context, selectedMarker!),
            ),
          // 右下角地图操作按钮
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  child: const Icon(Icons.add),
                  onPressed: () async {
                    if (mapController != null) {
                      final newZoom = (controller.zoom.value + 1).clamp(1.0, 21.0);
                      await mapController!.moveCamera(CameraUpdate.zoomTo(newZoom));
                    }
                  },
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  child: const Icon(Icons.remove),
                  onPressed: () async {
                    if (mapController != null) {
                      final newZoom = (controller.zoom.value - 1).clamp(1.0, 21.0);
                      await mapController!.moveCamera(CameraUpdate.zoomTo(newZoom));
                    }
                  },
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'my_location',
                  mini: true,
                  child: const Icon(Icons.my_location),
                  onPressed: () async {
                    // 跳转到定位点
                    final loc = LocationController.instance.selectedLocation.value;
                    if (loc != null && mapController != null) {
                      await mapController!.animateCamera(CameraUpdate.newLatLngZoom(
                        LatLng(loc.latitude, loc.longitude),
                        controller.zoom.value,
                      ));
                      controller.centerLat.value = loc.latitude;
                      controller.centerLng.value = loc.longitude;
                      controller.fetchMarkers();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceMarkerModel marker) {
    final locale = Get.locale?.languageCode ?? 'zh';
    String name = marker.titleMap?[locale] ?? marker.titleMap?['zh'] ?? marker.titleMap?['en'] ?? marker.name;
    String desc = marker.descriptionMap?[locale] ?? marker.descriptionMap?['zh'] ?? marker.descriptionMap?['en'] ?? marker.description;
    String distanceText = '';
    if (marker.distanceInKm != null) {
      if (marker.distanceInKm! < 1) {
        distanceText = '${(marker.distanceInKm! * 1000).round()}m';
      } else if (marker.distanceInKm! < 10) {
        distanceText = '${marker.distanceInKm!.toStringAsFixed(1)}km';
      } else {
        distanceText = '${marker.distanceInKm!.round()}km';
      }
    }
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Get.toNamed('/service_detail', parameters: {'serviceId': marker.id});
      },
      child: Card(
        elevation: 12,
        color: theme.cardColor,
        shadowColor: theme.shadowColor.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  marker.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(marker.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 8),
                        Text('(${marker.reviewCount})', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        if (distanceText.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.location_on, size: 15, color: theme.colorScheme.primary),
                          Text(distanceText, style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed('/service_booking', arguments: {'serviceId': marker.id});
                },
                child: const Text('预约'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 