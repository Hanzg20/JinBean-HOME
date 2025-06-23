import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocationSettingsController extends GetxController {
  final searchController = TextEditingController();
  final currentLocation = ''.obs;
  final savedLocations = <String>[].obs;
  final filteredLocations = <String>[].obs;
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadSavedLocations();
    refreshCurrentLocation();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void loadSavedLocations() {
    final locations = storage.read<List<String>>('savedLocations') ?? [];
    savedLocations.value = locations;
    filteredLocations.value = locations;
  }

  void saveLocations() {
    storage.write('savedLocations', savedLocations);
  }

  void onSearchChanged(String query) {
    if (query.isEmpty) {
      filteredLocations.value = savedLocations;
    } else {
      filteredLocations.value = savedLocations
          .where((location) =>
              location.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<void> refreshCurrentLocation() async {
    // TODO: Implement actual location detection
    currentLocation.value = 'Toronto, ON';
  }

  void showAddLocationDialog() {
    final TextEditingController locationController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add New Location'),
        content: TextField(
          controller: locationController,
          decoration: const InputDecoration(
            hintText: 'Enter location name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (locationController.text.isNotEmpty) {
                addLocation(locationController.text);
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void addLocation(String location) {
    if (!savedLocations.contains(location)) {
      savedLocations.add(location);
      filteredLocations.value = savedLocations;
      saveLocations();
    }
  }

  void removeLocation(String location) {
    savedLocations.remove(location);
    filteredLocations.value = savedLocations;
    saveLocations();
  }
} 