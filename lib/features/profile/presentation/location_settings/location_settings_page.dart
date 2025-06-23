import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/profile/presentation/location_settings/location_settings_controller.dart';

class LocationSettingsPage extends GetView<LocationSettingsController> {
  const LocationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: controller.onSearchChanged,
            ),
          ),

          // Current Location
          Obx(() => controller.currentLocation.value.isNotEmpty
              ? Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListTile(
                    leading: const Icon(Icons.my_location, color: Colors.blue),
                    title: const Text('Current Location'),
                    subtitle: Text(controller.currentLocation.value),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: controller.refreshCurrentLocation,
                    ),
                  ),
                )
              : const SizedBox.shrink()),

          // Saved Locations
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: controller.savedLocations.length,
                  itemBuilder: (context, index) {
                    final location = controller.savedLocations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
                      child: ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.red),
                        title: Text(location),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => controller.removeLocation(location),
                        ),
                      ),
                    );
                  },
                )),
          ),

          // Add Location Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => controller.showAddLocationDialog(),
              icon: const Icon(Icons.add_location),
              label: const Text('Add New Location'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 