import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/services/service_management_service.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:flutter/material.dart'; // Added for Color

class ServiceManagementController extends GetxController {
  final _serviceService = ServiceManagementService();
  
  // Observable variables
  final RxList<Service> services = <Service>[].obs;
  final RxMap<String, dynamic> serviceStats = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final Rx<ServiceStatus?> selectedStatus = Rx<ServiceStatus?>(null);
  
  // Status options
  final List<ServiceStatus> statusOptions = [
    ServiceStatus.active,
    ServiceStatus.inactive,
    ServiceStatus.draft,
    ServiceStatus.archived,
  ];
  
  @override
  void onInit() {
    super.onInit();
    AppLogger.info('[ServiceManagementController] Controller initialized', tag: 'ServiceManagement');
    loadServices();
    loadServiceStats();
  }
  
  /// Load services
  Future<void> loadServices({bool refresh = false}) async {
    try {
      isLoading.value = true;
      
      List<Service> servicesList;
      if (selectedStatus.value != null) {
        servicesList = await _serviceService.getServicesByStatus(selectedStatus.value!);
      } else {
        servicesList = await _serviceService.getServices();
      }
      
      // Apply search filter
      if (searchQuery.value.isNotEmpty) {
        servicesList = servicesList.where((service) {
          final title = service.title.toLowerCase();
          final description = service.description.toLowerCase();
          final query = searchQuery.value.toLowerCase();
          return title.contains(query) || description.contains(query);
        }).toList();
      }
      
      services.value = servicesList;
      
      AppLogger.info('[ServiceManagementController] Loaded ${services.length} services', tag: 'ServiceManagement');
      
    } catch (e) {
      AppLogger.error('[ServiceManagementController] Error loading services: $e', tag: 'ServiceManagement');
      Get.snackbar(
        'Error',
        'Failed to load services. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Load service statistics
  Future<void> loadServiceStats() async {
    try {
      final stats = await _serviceService.getServiceStatistics();
      serviceStats.value = stats;
    } catch (e) {
      AppLogger.error('[ServiceManagementController] Error loading service stats: $e', tag: 'ServiceManagement');
    }
  }
  
  /// Create new service
  Future<bool> createService(Service service) async {
    try {
      isLoading.value = true;
      
      final success = await _serviceService.createService(service);
      
      if (success) {
        await loadServices(refresh: true);
        await loadServiceStats();
        
        Get.snackbar(
          'Success',
          'Service created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        AppLogger.info('[ServiceManagementController] Service created successfully', tag: 'ServiceManagement');
      } else {
        Get.snackbar(
          'Error',
          'Failed to create service. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      
      return success;
    } catch (e) {
      AppLogger.error('[ServiceManagementController] Error creating service: $e', tag: 'ServiceManagement');
      Get.snackbar(
        'Error',
        'Failed to create service. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Update service
  Future<bool> updateService(Service service) async {
    try {
      isLoading.value = true;
      
      final success = await _serviceService.updateService(service);
      
      if (success) {
        await loadServices(refresh: true);
        await loadServiceStats();
        
        Get.snackbar(
          'Success',
          'Service updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        AppLogger.info('[ServiceManagementController] Service ${service.id} updated successfully', tag: 'ServiceManagement');
      } else {
        Get.snackbar(
          'Error',
          'Failed to update service. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      
      return success;
    } catch (e) {
      AppLogger.error('[ServiceManagementController] Error updating service: $e', tag: 'ServiceManagement');
      Get.snackbar(
        'Error',
        'Failed to update service. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Delete service
  Future<bool> deleteService(String serviceId) async {
    try {
      isLoading.value = true;
      
      final success = await _serviceService.deleteService(serviceId);
      
      if (success) {
        await loadServices(refresh: true);
        await loadServiceStats();
        
        Get.snackbar(
          'Success',
          'Service deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        AppLogger.info('[ServiceManagementController] Service $serviceId deleted successfully', tag: 'ServiceManagement');
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete service. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      
      return success;
    } catch (e) {
      AppLogger.error('[ServiceManagementController] Error deleting service: $e', tag: 'ServiceManagement');
      Get.snackbar(
        'Error',
        'Failed to delete service. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Update service status
  Future<bool> updateServiceStatus(String serviceId, ServiceStatus status) async {
    try {
      final success = await _serviceService.updateServiceStatus(serviceId, status);
      
      if (success) {
        await loadServices(refresh: true);
        await loadServiceStats();
        
        AppLogger.info('[ServiceManagementController] Service $serviceId status updated to ${status.name}', tag: 'ServiceManagement');
      }
      
      return success;
    } catch (e) {
      AppLogger.error('[ServiceManagementController] Error updating service status: $e', tag: 'ServiceManagement');
      return false;
    }
  }
  
  /// Filter by status
  void filterByStatus(ServiceStatus? status) {
    selectedStatus.value = status;
    loadServices();
  }
  
  /// Search services
  void searchServices(String query) {
    searchQuery.value = query;
    loadServices();
  }
  
  /// Get service details
  Future<Service?> getServiceDetails(String serviceId) async {
    try {
      return await _serviceService.getServiceDetails(serviceId);
    } catch (e) {
      AppLogger.error('[ServiceManagementController] Error getting service details: $e', tag: 'ServiceManagement');
      return null;
    }
  }
  
  /// Refresh data
  Future<void> refreshData() async {
    await loadServices(refresh: true);
    await loadServiceStats();
  }
  
  /// Get status display text
  String getStatusDisplayText(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.active:
        return '活跃';
      case ServiceStatus.inactive:
        return '停用';
      case ServiceStatus.draft:
        return '草稿';
      case ServiceStatus.archived:
        return '已归档';
    }
  }
  
  /// Get status color
  Color getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.active:
        return const Color(0xFF4CAF50); // Green
      case ServiceStatus.inactive:
        return const Color(0xFFF44336); // Red
      case ServiceStatus.draft:
        return const Color(0xFFFF9800); // Orange
      case ServiceStatus.archived:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
} 