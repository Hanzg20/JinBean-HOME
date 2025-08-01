import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:flutter/material.dart';

class RobOrderHallController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  // Observable variables
  final RxList<Map<String, dynamic>> availableOrders = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedFilter = 'all'.obs;
  final RxInt totalOrders = 0.obs;
  final RxInt myRanking = 0.obs;
  final RxInt successCount = 0.obs;
  final RxDouble averageResponseTime = 0.0.obs;
  
  // Filters
  final List<String> filters = ['all', 'high', 'medium', 'low'];
  
  // Pagination
  static const int pageSize = 20;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    AppLogger.info('[RobOrderHallController] Controller initialized', tag: 'RobOrderHall');
    loadAvailableOrders();
    loadStatistics();
  }
  
  /// Load available orders with pagination and filtering
  Future<void> loadAvailableOrders({bool refresh = false}) async {
    try {
      isLoading.value = true;
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[RobOrderHallController] No user ID available', tag: 'RobOrderHall');
        return;
      }
      
      if (refresh) {
        currentPage.value = 1;
        availableOrders.clear();
        hasMoreData.value = true;
      }
      
      if (!hasMoreData.value || isLoading.value) return;
      
      // Build base query for available orders
      var query = _supabase
          .from('orders')
          .select('''
            *,
            service:services(
              title,
              description,
              category_level1_id,
              category_level2_id
            ),
            customer:user_profiles!orders_customer_id_fkey(
              id,
              full_name,
              avatar_url,
              rating,
              order_count
            )
          ''')
          .eq('status', 'pending')
          .order('created_at', ascending: false)
          .range((currentPage.value - 1) * pageSize, currentPage.value * pageSize - 1);
      
      // Apply urgency filter
      if (selectedFilter.value != 'all') {
        query = _supabase
            .from('orders')
            .select('''
              *,
              service:services(
                title,
                description,
                category_level1_id,
                category_level2_id
              ),
              customer:user_profiles!orders_customer_id_fkey(
                id,
                full_name,
                avatar_url,
                rating,
                order_count
              )
            ''')
            .eq('status', 'pending')
            .eq('urgency_level', selectedFilter.value)
            .order('created_at', ascending: false)
            .range((currentPage.value - 1) * pageSize, currentPage.value * pageSize - 1);
      }
      
      final response = await query;
      
      if (refresh) {
        availableOrders.value = List<Map<String, dynamic>>.from(response);
      } else {
        availableOrders.addAll(List<Map<String, dynamic>>.from(response));
      }
      
      // Check if there's more data
      hasMoreData.value = response.length == pageSize;
      currentPage.value++;
      
      AppLogger.info('[RobOrderHallController] Loaded ${availableOrders.length} available orders', tag: 'RobOrderHall');
      
    } catch (e) {
      AppLogger.error('[RobOrderHallController] Error loading available orders: $e', tag: 'RobOrderHall');
      Get.snackbar(
        'Error',
        'Failed to load available orders. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Grab an order
  Future<void> grabOrder(String orderId) async {
    try {
      isLoading.value = true;
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[RobOrderHallController] No user ID available', tag: 'RobOrderHall');
        return;
      }
      
      // Update order status to accepted and assign provider
      await _supabase
          .from('orders')
          .update({
            'status': 'accepted',
            'provider_id': userId,
            'accepted_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId)
          .eq('status', 'pending'); // Only grab if still pending
      
      // Remove from available orders list
      availableOrders.removeWhere((order) => order['id'] == orderId);
      
      // Update statistics
      successCount.value++;
      await loadStatistics();
      
      Get.snackbar(
        'Success',
        'Order accepted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      AppLogger.info('[RobOrderHallController] Order accepted: $orderId', tag: 'RobOrderHall');
      
    } catch (e) {
      AppLogger.error('[RobOrderHallController] Error accepting order: $e', tag: 'RobOrderHall');
      Get.snackbar(
        'Error',
        'Failed to accept order. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Load statistics
  Future<void> loadStatistics() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[RobOrderHallController] No user ID available', tag: 'RobOrderHall');
        return;
      }
      
      // Get total available orders
      final totalResponse = await _supabase
          .from('orders')
          .select('id')
          .eq('status', 'pending');
      
      totalOrders.value = totalResponse.length;
      
      // Get provider ranking (placeholder calculation)
      final providerResponse = await _supabase
          .from('user_profiles')
          .select('id, rating, order_count')
          .eq('role', 'provider')
          .order('rating', ascending: false);
      
      final myProfileIndex = providerResponse.indexWhere((profile) => profile['id'] == userId);
      myRanking.value = myProfileIndex >= 0 ? myProfileIndex + 1 : 999;
      
      // Get success count (orders accepted by this provider)
      final successResponse = await _supabase
          .from('orders')
          .select('id')
          .eq('provider_id', userId)
          .eq('status', 'accepted');
      
      successCount.value = successResponse.length;
      
      // Calculate average response time (placeholder)
      averageResponseTime.value = 2.5; // minutes
      
      AppLogger.info('[RobOrderHallController] Statistics loaded', tag: 'RobOrderHall');
      
    } catch (e) {
      AppLogger.error('[RobOrderHallController] Error loading statistics: $e', tag: 'RobOrderHall');
    }
  }
  
  /// Filter orders by urgency
  void filterByUrgency(String urgency) {
    selectedFilter.value = urgency;
    loadAvailableOrders(refresh: true);
  }
  
  /// Get urgency display text
  String getUrgencyDisplayText(String urgency) {
    switch (urgency) {
      case 'high':
        return '紧急';
      case 'medium':
        return '普通';
      case 'low':
        return '不急';
      default:
        return '未知';
    }
  }
  
  /// Get urgency color
  Color getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  /// Get service title
  String getServiceTitle(Map<String, dynamic> order) {
    final service = order['service'] as Map<String, dynamic>?;
    if (service != null) {
      final title = service['title'] as Map<String, dynamic>?;
      if (title != null) {
        return title['zh'] ?? title['en'] ?? 'Unknown Service';
      }
    }
    return 'Unknown Service';
  }
  
  /// Get customer name
  String getCustomerName(Map<String, dynamic> order) {
    final customer = order['customer'] as Map<String, dynamic>?;
    if (customer != null) {
      return customer['full_name'] ?? 'Unknown Customer';
    }
    return 'Unknown Customer';
  }
  
  /// Get customer rating
  double getCustomerRating(Map<String, dynamic> order) {
    final customer = order['customer'] as Map<String, dynamic>?;
    if (customer != null) {
      return (customer['rating'] ?? 0.0).toDouble();
    }
    return 0.0;
  }
  
  /// Get customer order count
  int getCustomerOrderCount(Map<String, dynamic> order) {
    final customer = order['customer'] as Map<String, dynamic>?;
    if (customer != null) {
      return customer['order_count'] ?? 0;
    }
    return 0;
  }
  
  /// Format price
  String formatPrice(dynamic price) {
    if (price == null) return '\$0.00';
    final double amount = price is int ? price.toDouble() : price;
    return '\$${amount.toStringAsFixed(2)}';
  }
  
  /// Format relative time
  String formatRelativeTime(String? dateTime) {
    if (dateTime == null) return '刚刚';
    try {
      final DateTime dt = DateTime.parse(dateTime);
      final Duration difference = DateTime.now().difference(dt);
      
      if (difference.inMinutes < 1) {
        return '刚刚';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}分钟前';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}小时前';
      } else {
        return '${difference.inDays}天前';
      }
    } catch (e) {
      return '刚刚';
    }
  }
  
  /// Refresh data
  Future<void> refreshData() async {
    await loadAvailableOrders(refresh: true);
    await loadStatistics();
  }
} 