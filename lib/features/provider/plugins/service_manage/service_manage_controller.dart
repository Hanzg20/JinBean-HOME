import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class ServiceManageController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  // Observable variables
  final RxList<Map<String, dynamic>> services = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'all'.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;
  
  // Categories
  final List<String> categories = ['all', 'active', 'inactive', 'draft'];
  
  // Pagination
  static const int pageSize = 20;
  
  @override
  void onInit() {
    super.onInit();
    AppLogger.info('[ServiceManageController] Controller initialized', tag: 'ServiceManage');
    loadServices();
  }
  
  /// Load services with pagination and filtering
  Future<void> loadServices({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        services.clear();
        hasMoreData.value = true;
      }
      
      if (!hasMoreData.value || isLoading.value) return;
      
      isLoading.value = true;
      
      // Build query
      var query = _supabase
          .from('services')
          .select('''
            *,
            service_details:service_details(*),
            category:ref_codes!services_category_id_fkey(
              code_value,
              code_description
            )
          ''')
          .eq('provider_id', _supabase.auth.currentUser?.id)
          .order('created_at', ascending: false)
          .range((currentPage.value - 1) * pageSize, currentPage.value * pageSize - 1);
      
      // Apply category filter
      if (selectedCategory.value != 'all') {
        query = query.eq('status', selectedCategory.value);
      }
      
      // Apply search filter
      if (searchQuery.value.isNotEmpty) {
        query = query.or('name.ilike.%${searchQuery.value}%,description.ilike.%${searchQuery.value}%');
      }
      
      final response = await query;
      
      if (refresh) {
        services.value = List<Map<String, dynamic>>.from(response);
      } else {
        services.addAll(List<Map<String, dynamic>>.from(response));
      }
      
      // Check if there's more data
      hasMoreData.value = response.length == pageSize;
      currentPage.value++;
      
      AppLogger.info('[ServiceManageController] Loaded ${services.length} services', tag: 'ServiceManage');
      
    } catch (e) {
      AppLogger.error('[ServiceManageController] Error loading services: $e', tag: 'ServiceManage');
      Get.snackbar(
        'Error',
        'Failed to load services. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Create new service
  Future<void> createService(Map<String, dynamic> serviceData) async {
    try {
      isLoading.value = true;
      
      // Create service
      final serviceResponse = await _supabase
          .from('services')
          .insert({
            'provider_id': _supabase.auth.currentUser?.id,
            'name': serviceData['name'],
            'description': serviceData['description'],
            'category_id': serviceData['category_id'],
            'base_price': serviceData['base_price'],
            'duration_minutes': serviceData['duration_minutes'],
            'status': serviceData['status'] ?? 'draft',
            'is_available': serviceData['is_available'] ?? true,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      
      // Create service details if provided
      if (serviceData['details'] != null) {
        await _supabase
            .from('service_details')
            .insert({
              'service_id': serviceResponse['id'],
              'detail_type': serviceData['details']['type'],
              'detail_value': serviceData['details']['value'],
              'created_at': DateTime.now().toIso8601String(),
            });
      }
      
      // Refresh services list
      await loadServices(refresh: true);
      
      Get.snackbar(
        'Success',
        'Service created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      AppLogger.info('[ServiceManageController] Service created: ${serviceResponse['id']}', tag: 'ServiceManage');
      
    } catch (e) {
      AppLogger.error('[ServiceManageController] Error creating service: $e', tag: 'ServiceManage');
      Get.snackbar(
        'Error',
        'Failed to create service. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Update service
  Future<void> updateService(String serviceId, Map<String, dynamic> serviceData) async {
    try {
      isLoading.value = true;
      
      await _supabase
          .from('services')
          .update({
            'name': serviceData['name'],
            'description': serviceData['description'],
            'category_id': serviceData['category_id'],
            'base_price': serviceData['base_price'],
            'duration_minutes': serviceData['duration_minutes'],
            'status': serviceData['status'],
            'is_available': serviceData['is_available'],
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', serviceId);
      
      // Refresh services list
      await loadServices(refresh: true);
      
      Get.snackbar(
        'Success',
        'Service updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      AppLogger.info('[ServiceManageController] Service updated: $serviceId', tag: 'ServiceManage');
      
    } catch (e) {
      AppLogger.error('[ServiceManageController] Error updating service: $e', tag: 'ServiceManage');
      Get.snackbar(
        'Error',
        'Failed to update service. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Delete service
  Future<void> deleteService(String serviceId) async {
    try {
      isLoading.value = true;
      
      // Check if service has active orders
      final ordersResponse = await _supabase
          .from('orders')
          .select('id')
          .eq('service_id', serviceId)
          .in_('status', ['pending', 'accepted', 'in_progress']);
      
      if (ordersResponse.isNotEmpty) {
        Get.snackbar(
          'Error',
          'Cannot delete service with active orders',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      // Delete service details first
      await _supabase
          .from('service_details')
          .delete()
          .eq('service_id', serviceId);
      
      // Delete service
      await _supabase
          .from('services')
          .delete()
          .eq('id', serviceId);
      
      // Refresh services list
      await loadServices(refresh: true);
      
      Get.snackbar(
        'Success',
        'Service deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      AppLogger.info('[ServiceManageController] Service deleted: $serviceId', tag: 'ServiceManage');
      
    } catch (e) {
      AppLogger.error('[ServiceManageController] Error deleting service: $e', tag: 'ServiceManage');
      Get.snackbar(
        'Error',
        'Failed to delete service. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Toggle service availability
  Future<void> toggleServiceAvailability(String serviceId, bool isAvailable) async {
    try {
      await _supabase
          .from('services')
          .update({
            'is_available': isAvailable,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', serviceId);
      
      // Refresh services list
      await loadServices(refresh: true);
      
      Get.snackbar(
        'Success',
        'Service availability updated',
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } catch (e) {
      AppLogger.error('[ServiceManageController] Error toggling availability: $e', tag: 'ServiceManage');
      Get.snackbar(
        'Error',
        'Failed to update service availability',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Get service categories
  Future<List<Map<String, dynamic>>> getServiceCategories() async {
    try {
      final response = await _supabase
          .from('ref_codes')
          .select('*')
          .eq('code_type', 'service_category')
          .order('code_description');
      
      return List<Map<String, dynamic>>.from(response);
      
    } catch (e) {
      AppLogger.error('[ServiceManageController] Error getting categories: $e', tag: 'ServiceManage');
      return [];
    }
  }
  
  /// Get service statistics
  Future<Map<String, dynamic>> getServiceStatistics() async {
    try {
      final response = await _supabase
          .from('services')
          .select('status, is_available')
          .eq('provider_id', _supabase.auth.currentUser?.id);
      
      final Map<String, int> stats = {
        'total': response.length,
        'active': 0,
        'inactive': 0,
        'draft': 0,
        'available': 0,
        'unavailable': 0,
      };
      
      for (final service in response) {
        final status = service['status'] as String;
        final isAvailable = service['is_available'] as bool;
        
        if (stats.containsKey(status)) {
          stats[status] = (stats[status] ?? 0) + 1;
        }
        
        if (isAvailable) {
          stats['available'] = (stats['available'] ?? 0) + 1;
        } else {
          stats['unavailable'] = (stats['unavailable'] ?? 0) + 1;
        }
      }
      
      return stats;
      
    } catch (e) {
      AppLogger.error('[ServiceManageController] Error getting statistics: $e', tag: 'ServiceManage');
      return {};
    }
  }
  
  /// Filter services by category
  void filterByCategory(String category) {
    selectedCategory.value = category;
    loadServices(refresh: true);
  }
  
  /// Search services
  void searchServices(String query) {
    searchQuery.value = query;
    loadServices(refresh: true);
  }
  
  /// Get status display text
  String getStatusDisplayText(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'draft':
        return 'Draft';
      default:
        return 'Unknown';
    }
  }
  
  /// Get status color
  int getStatusColor(String status) {
    switch (status) {
      case 'active':
        return 0xFF4CAF50; // Green
      case 'inactive':
        return 0xFFF44336; // Red
      case 'draft':
        return 0xFFFFA500; // Orange
      default:
        return 0xFF9E9E9E; // Grey
    }
  }
  
  /// Get category display text
  String getCategoryDisplayText(String category) {
    switch (category) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'draft':
        return 'Draft';
      default:
        return 'All';
    }
  }
  
  /// Get service name
  String getServiceName(Map<String, dynamic> service) {
    return service['name'] ?? 'Unknown Service';
  }
  
  /// Get service description
  String getServiceDescription(Map<String, dynamic> service) {
    return service['description'] ?? 'No description';
  }
  
  /// Get service category
  String getServiceCategory(Map<String, dynamic> service) {
    final category = service['category'] as Map<String, dynamic>?;
    return category?['code_description'] ?? 'Uncategorized';
  }
  
  /// Get service price
  String getServicePrice(Map<String, dynamic> service) {
    final price = service['base_price'];
    if (price == null) return '\$0.00';
    final double amount = price is int ? price.toDouble() : price;
    return '\$${amount.toStringAsFixed(2)}';
  }
  
  /// Get service duration
  String getServiceDuration(Map<String, dynamic> service) {
    final duration = service['duration_minutes'];
    if (duration == null) return 'N/A';
    final int minutes = duration is int ? duration : duration.toInt();
    if (minutes < 60) {
      return '${minutes} min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours} hour${hours > 1 ? 's' : ''}';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }
  
  /// Format price
  String formatPrice(dynamic price) {
    if (price == null) return '\$0.00';
    final double amount = price is int ? price.toDouble() : price;
    return '\$${amount.toStringAsFixed(2)}';
  }
  
  /// Format date time
  String formatDateTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final DateTime dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid Date';
    }
  }
  
  /// Check if service can be edited
  bool canEditService(Map<String, dynamic> service) {
    return service['status'] == 'draft' || service['status'] == 'inactive';
  }
  
  /// Check if service can be deleted
  bool canDeleteService(Map<String, dynamic> service) {
    return service['status'] == 'draft';
  }
  
  /// Refresh services
  Future<void> refreshServices() async {
    await loadServices(refresh: true);
  }
} 