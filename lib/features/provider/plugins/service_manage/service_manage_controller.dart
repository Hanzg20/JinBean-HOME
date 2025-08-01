import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:flutter/material.dart'; // Added for Color

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
      isLoading.value = true;
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ServiceManageController] No user ID available', tag: 'ServiceManage');
        return;
      }
      
      if (refresh) {
        currentPage.value = 1;
        services.clear();
        hasMoreData.value = true;
      }
      
      if (!hasMoreData.value || isLoading.value) return;
      
      // Build base query - updated to match actual database schema
      var query = _supabase
          .from('services')
          .select('''
            *,
            service_details:service_details(*),
            category_level1:ref_codes!services_category_level1_id_fkey(
              code_value,
              code_description
            ),
            category_level2:ref_codes!services_category_level2_id_fkey(
              code_value,
              code_description
            )
          ''')
          .eq('provider_id', userId)
          .order('created_at', ascending: false)
          .range((currentPage.value - 1) * pageSize, currentPage.value * pageSize - 1);
      
      // Apply category filter
      if (selectedCategory.value != 'all') {
        query = _supabase
            .from('services')
            .select('''
              *,
              service_details:service_details(*),
              category_level1:ref_codes!services_category_level1_id_fkey(
                code_value,
                code_description
              ),
              category_level2:ref_codes!services_category_level2_id_fkey(
                code_value,
                code_description
              )
            ''')
            .eq('provider_id', userId)
            .eq('status', selectedCategory.value)
            .order('created_at', ascending: false)
            .range((currentPage.value - 1) * pageSize, currentPage.value * pageSize - 1);
      }
      
      // Apply search filter - updated to use title and description fields
      if (searchQuery.value.isNotEmpty) {
        query = _supabase
            .from('services')
            .select('''
              *,
              service_details:service_details(*),
              category_level1:ref_codes!services_category_level1_id_fkey(
                code_value,
                code_description
              ),
              category_level2:ref_codes!services_category_level2_id_fkey(
                code_value,
                code_description
              )
            ''')
            .eq('provider_id', userId)
            .or('title->>zh.ilike.%${searchQuery.value}%,title->>en.ilike.%${searchQuery.value}%,description->>zh.ilike.%${searchQuery.value}%,description->>en.ilike.%${searchQuery.value}%')
            .order('created_at', ascending: false)
            .range((currentPage.value - 1) * pageSize, currentPage.value * pageSize - 1);
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
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ServiceManageController] No user ID available', tag: 'ServiceManage');
        return;
      }
      
      // Create service - updated to match actual database schema
      final serviceResponse = await _supabase
          .from('services')
          .insert({
            'provider_id': userId,
            'title': {
              'zh': serviceData['name'],
              'en': serviceData['name']
            },
            'description': {
              'zh': serviceData['description'],
              'en': serviceData['description']
            },
            'category_level1_id': serviceData['category_id'],
            'category_level2_id': serviceData['category_level2_id'],
            'status': serviceData['status'] ?? 'draft',
            'service_delivery_method': serviceData['service_delivery_method'] ?? 'on_site',
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
              'pricing_type': serviceData['details']['pricing_type'] ?? 'fixed_price',
              'price': serviceData['details']['price'],
              'currency': serviceData['details']['currency'] ?? 'USD',
              'duration_type': serviceData['details']['duration_type'] ?? 'hours',
              'duration': serviceData['details']['duration'],
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
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
            'title': {
              'zh': serviceData['name'],
              'en': serviceData['name']
            },
            'description': {
              'zh': serviceData['description'],
              'en': serviceData['description']
            },
            'category_level1_id': serviceData['category_id'],
            'category_level2_id': serviceData['category_level2_id'],
            'status': serviceData['status'],
            'service_delivery_method': serviceData['service_delivery_method'] ?? 'on_site',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', serviceId);
      
      // Update service details if provided
      if (serviceData['details'] != null) {
        await _supabase
            .from('service_details')
            .upsert({
              'service_id': serviceId,
              'pricing_type': serviceData['details']['pricing_type'] ?? 'fixed_price',
              'price': serviceData['details']['price'],
              'currency': serviceData['details']['currency'] ?? 'USD',
              'duration_type': serviceData['details']['duration_type'] ?? 'hours',
              'duration': serviceData['details']['duration'],
              'updated_at': DateTime.now().toIso8601String(),
            });
      }
      
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
          .inFilter('status', ['pending', 'accepted', 'in_progress']);
      
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
  
  /// Toggle service availability by changing status
  Future<void> toggleServiceAvailability(String serviceId, bool isAvailable) async {
    try {
      // Get current service status
      final serviceResponse = await _supabase
          .from('services')
          .select('status')
          .eq('id', serviceId)
          .single();
      
      final currentStatus = serviceResponse['status'] as String;
      String newStatus;
      
      if (isAvailable) {
        // If making available, set to active if it was paused
        newStatus = currentStatus == 'paused' ? 'active' : currentStatus;
      } else {
        // If making unavailable, set to paused if it was active
        newStatus = currentStatus == 'active' ? 'paused' : currentStatus;
      }
      
      await _supabase
          .from('services')
          .update({
            'status': newStatus,
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
          .eq('code_type', 'SERVICE_TYPE')
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
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[ServiceManageController] No user ID available', tag: 'ServiceManage');
        return {
          'total': 0,
          'active': 0,
          'inactive': 0,
          'draft': 0,
          'paused': 0,
          'archived': 0,
          'total_revenue': 0,
        };
      }
      
      final response = await _supabase
          .from('services')
          .select('status')
          .eq('provider_id', userId);
      
      final Map<String, int> stats = {
        'total': response.length,
        'active': 0,
        'inactive': 0,
        'draft': 0,
        'paused': 0,
        'archived': 0,
        'total_revenue': 0,
      };
      
      for (final service in response) {
        final status = service['status'] as String? ?? 'draft';
        if (stats.containsKey(status)) {
          stats[status] = (stats[status] ?? 0) + 1;
        }
      }
      
      // Calculate total revenue (placeholder - would need to join with orders table)
      // For now, we'll use a simple calculation based on active services
      stats['total_revenue'] = stats['active']! * 50; // Placeholder calculation
      
      AppLogger.info('[ServiceManageController] Statistics calculated: $stats', tag: 'ServiceManage');
      
      return stats;
      
    } catch (e) {
      AppLogger.error('[ServiceManageController] Error getting statistics: $e', tag: 'ServiceManage');
      return {
        'total': 0,
        'active': 0,
        'inactive': 0,
        'draft': 0,
        'paused': 0,
        'archived': 0,
        'total_revenue': 0,
      };
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
        return '活跃';
      case 'inactive':
        return '暂停';
      case 'draft':
        return '草稿';
      case 'paused':
        return '暂停';
      case 'archived':
        return '已归档';
      default:
        return '未知';
    }
  }
  
  /// Get status color
  Color getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'draft':
        return Colors.orange;
      case 'paused':
        return Colors.red;
      case 'archived':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
  
  /// Check if service is available (active status)
  bool isServiceAvailable(Map<String, dynamic> service) {
    final status = service['status'] as String?;
    return status == 'active';
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
    final title = service['title'] as Map<String, dynamic>?;
    if (title != null) {
      return title['zh'] ?? title['en'] ?? 'Unknown Service';
    }
    return 'Unknown Service';
  }
  
  /// Get service description
  String getServiceDescription(Map<String, dynamic> service) {
    final description = service['description'] as Map<String, dynamic>?;
    if (description != null) {
      return description['zh'] ?? description['en'] ?? 'No description';
    }
    return 'No description';
  }
  
  /// Get service category
  String getServiceCategory(Map<String, dynamic> service) {
    final categoryLevel1 = service['category_level1'] as Map<String, dynamic>?;
    if (categoryLevel1 != null) {
      return categoryLevel1['code_description'] ?? 'Uncategorized';
    }
    return 'Uncategorized';
  }
  
  /// Get service price from service_details
  String getServicePrice(Map<String, dynamic> service) {
    final serviceDetails = service['service_details'] as List<dynamic>?;
    if (serviceDetails != null && serviceDetails.isNotEmpty) {
      final details = serviceDetails.first as Map<String, dynamic>;
      final price = details['price'];
      if (price != null) {
        final double amount = price is int ? price.toDouble() : price;
        return '\$${amount.toStringAsFixed(2)}';
      }
    }
    return '\$0.00';
  }
  
  /// Get service duration from service_details
  String getServiceDuration(Map<String, dynamic> service) {
    final serviceDetails = service['service_details'] as List<dynamic>?;
    if (serviceDetails != null && serviceDetails.isNotEmpty) {
      final details = serviceDetails.first as Map<String, dynamic>;
      final duration = details['duration'];
      
      if (duration != null) {
        // Handle interval type duration
        if (duration is String) {
          return duration;
        }
      }
    }
    return 'N/A';
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