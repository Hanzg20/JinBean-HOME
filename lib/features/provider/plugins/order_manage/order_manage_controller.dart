import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';
import 'package:jinbeanpod_83904710/features/provider/services/provider_settings_service.dart';
import 'package:jinbeanpod_83904710/features/provider/services/client_conversion_service.dart';
import 'package:jinbeanpod_83904710/features/provider/services/income_management_service.dart';
import 'package:jinbeanpod_83904710/features/provider/services/notification_service.dart';

class OrderManageController extends GetxController {
  final _supabase = Supabase.instance.client;
  final _settingsService = ProviderSettingsService();
  final _clientConversionService = ClientConversionService();
  final _incomeService = IncomeManagementService();
  final _notificationService = NotificationService();
  
  // Observable variables
  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentStatus = 'all'.obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;
  
  // Status options
  final List<String> statusOptions = [
    'all', 'pending', 'accepted', 'in_progress', 'completed', 'cancelled'
  ];
  
  // Pagination
  static const int pageSize = 20;
  
  @override
  void onInit() {
    super.onInit();
    AppLogger.info('[OrderManageController] Controller initialized', tag: 'OrderManage');
    loadOrders();
  }
  
  /// Load orders
  Future<void> loadOrders({bool refresh = false}) async {
    try {
      isLoading.value = true;
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[OrderManageController] No user ID available', tag: 'OrderManage');
        return;
      }
      
      if (refresh) {
        currentPage.value = 1;
        orders.clear();
      }
      
      // Build base query
      var query = _supabase
          .from('orders')
          .select('''
            *,
            customer:users!orders_customer_id_fkey(
              id,
              full_name,
              email,
              phone
            ),
            service:services(
              id,
              name,
              description,
              price
            )
          ''')
          .eq('provider_id', userId)
          .order('created_at', ascending: false)
          .range((currentPage.value - 1) * pageSize, currentPage.value * pageSize - 1);
      
      // Apply status filter
      if (currentStatus.value != 'all') {
        query = _supabase
            .from('orders')
            .select('''
              *,
              customer:users!orders_customer_id_fkey(
                id,
                full_name,
                email,
                phone
              ),
              service:services(
                id,
                name,
                description,
                price
              )
            ''')
            .eq('provider_id', userId)
            .eq('status', currentStatus.value)
            .order('created_at', ascending: false)
            .range((currentPage.value - 1) * pageSize, currentPage.value * pageSize - 1);
      }
      
      // Apply search filter
      if (searchQuery.value.isNotEmpty) {
        query = _supabase
            .from('orders')
            .select('''
              *,
              customer:users!orders_customer_id_fkey(
                id,
                full_name,
                email,
                phone
              ),
              service:services(
                id,
                name,
                description,
                price
              )
            ''')
            .eq('provider_id', userId)
            .or('id.ilike.%${searchQuery.value}%,customer.full_name.ilike.%${searchQuery.value}%')
            .order('created_at', ascending: false)
            .range((currentPage.value - 1) * pageSize, currentPage.value * pageSize - 1);
      }
      
      final response = await query;
      
      if (refresh) {
        orders.value = List<Map<String, dynamic>>.from(response);
      } else {
        orders.addAll(List<Map<String, dynamic>>.from(response));
      }
      
      // Check if there's more data
      hasMoreData.value = response.length == pageSize;
      currentPage.value++;
      
      AppLogger.info('[OrderManageController] Loaded ${orders.length} orders', tag: 'OrderManage');
      
    } catch (e) {
      AppLogger.error('[OrderManageController] Error loading orders: $e', tag: 'OrderManage');
      Get.snackbar(
        'Error',
        'Failed to load orders. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      isLoading.value = true;
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[OrderManageController] No user ID available', tag: 'OrderManage');
        return;
      }
      
      // Update order status
      await _supabase
          .from('orders')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
      
      // Add status history
      await _supabase
          .from('order_status_history')
          .insert({
            'order_id': orderId,
            'status': newStatus,
            'changed_by': userId,
            'changed_at': DateTime.now().toIso8601String(),
          });
      
      // Refresh orders list
      await loadOrders(refresh: true);
      
      Get.snackbar(
        'Success',
        'Order status updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      AppLogger.info('[OrderManageController] Order $orderId status updated to $newStatus', tag: 'OrderManage');
      
    } catch (e) {
      AppLogger.error('[OrderManageController] Error updating order status: $e', tag: 'OrderManage');
      Get.snackbar(
        'Error',
        'Failed to update order status. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Accept order
  Future<void> acceptOrder(String orderId) async {
    await updateOrderStatus(orderId, 'accepted');
  }
  
  /// Reject order
  Future<void> rejectOrder(String orderId) async {
    await updateOrderStatus(orderId, 'cancelled');
  }
  
  /// Start service
  Future<void> startService(String orderId) async {
    await updateOrderStatus(orderId, 'in_progress');
  }
  
  /// Complete service
  Future<void> completeService(String orderId) async {
    await updateOrderStatus(orderId, 'completed');
  }

  /// Complete service with client conversion
  Future<void> completeServiceWithClientConversion(String orderId, Map<String, dynamic> orderData) async {
    try {
      isLoading.value = true;
      
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[OrderManageController] No user ID available', tag: 'OrderManage');
        return;
      }

      // 获取自动转换设置
      final autoConvert = await _settingsService.getAutoConvertToClient();
      
      if (autoConvert) {
        // 自动转换客户
        await _autoConvertToClient(orderId, orderData);
      } else {
        // 显示转换选择对话框
        await _showClientConversionDialog(orderId, orderData);
      }
      
      // 更新订单状态
      await updateOrderStatus(orderId, 'completed');
      
      // 创建收入记录
      await _createIncomeRecord(orderId, orderData);
      
      // 发送完成通知
      await _sendCompletionNotification(orderId, orderData);
      
    } catch (e) {
      AppLogger.error('[OrderManageController] Error completing service: $e', tag: 'OrderManage');
      Get.snackbar(
        'Error',
        'Failed to complete service. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 自动转换客户
  Future<void> _autoConvertToClient(String orderId, Map<String, dynamic> orderData) async {
    try {
      final customer = orderData['customer'] as Map<String, dynamic>?;
      if (customer == null) {
        AppLogger.warning('[OrderManageController] No customer data found', tag: 'OrderManage');
        return;
      }

      final customerUserId = customer['id'] as String;
      final customerName = customer['full_name'] as String? ?? 'Unknown Customer';
      final customerPhone = customer['phone'] as String?;
      final customerEmail = customer['email'] as String?;

      // 检查是否已经是客户
      final isAlreadyClient = await _clientConversionService.isUserAlreadyClient(customerUserId);
      
      if (isAlreadyClient) {
        // 更新客户统计
        final orderAmount = (orderData['amount'] ?? 0).toDouble();
        await _clientConversionService.updateClientStats(customerUserId, orderId, orderAmount);
        AppLogger.info('[OrderManageController] Updated existing client stats', tag: 'OrderManage');
      } else {
        // 转换为新客户
        final success = await _clientConversionService.convertOrderUserToClient(
          orderId, 
          customerUserId, 
          customerName, 
          customerPhone, 
          customerEmail
        );
        
        if (success) {
          Get.snackbar(
            'Success',
            'Customer automatically converted from order',
            snackPosition: SnackPosition.BOTTOM,
          );
          AppLogger.info('[OrderManageController] Customer automatically converted', tag: 'OrderManage');
        }
      }
    } catch (e) {
      AppLogger.error('[OrderManageController] Error in auto convert: $e', tag: 'OrderManage');
    }
  }

  /// 显示客户转换选择对话框
  Future<void> _showClientConversionDialog(String orderId, Map<String, dynamic> orderData) async {
    final customer = orderData['customer'] as Map<String, dynamic>?;
    if (customer == null) {
      AppLogger.warning('[OrderManageController] No customer data found', tag: 'OrderManage');
      return;
    }

    final customerName = customer['full_name'] as String? ?? 'Unknown Customer';
    
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Convert to Client?'),
        content: Text('Would you like to add "$customerName" to your client list?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => _showAutoConvertDialog(),
            child: const Text('Always Convert'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _autoConvertToClient(orderId, orderData);
    }
  }

  /// 显示自动转换设置对话框
  Future<void> _showAutoConvertDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Auto Convert Settings'),
        content: const Text('Would you like to automatically convert order customers to clients in the future?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _settingsService.setAutoConvertToClient(result);
      Get.snackbar(
        'Settings Updated',
        result ? 'Auto convert enabled' : 'Auto convert disabled',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 创建收入记录
  Future<void> _createIncomeRecord(String orderId, Map<String, dynamic> orderData) async {
    try {
      final amount = (orderData['amount'] ?? 0).toDouble();
      if (amount > 0) {
        await _incomeService.createIncomeRecord(
          orderId,
          amount,
          'service_fee',
          'Income from completed order $orderId',
        );
        AppLogger.info('[OrderManageController] Income record created for order $orderId', tag: 'OrderManage');
      }
    } catch (e) {
      AppLogger.error('[OrderManageController] Error creating income record: $e', tag: 'OrderManage');
    }
  }

  /// 发送完成通知
  Future<void> _sendCompletionNotification(String orderId, Map<String, dynamic> orderData) async {
    try {
      final customer = orderData['customer'] as Map<String, dynamic>?;
      final customerName = customer?['full_name'] ?? 'Customer';
      final service = orderData['service'] as Map<String, dynamic>?;
      final serviceName = service?['name'] ?? 'Service';
      
      await _notificationService.createNotification(
        _supabase.auth.currentUser?.id ?? '',
        'order',
        'Order Completed',
        'Order #${orderId.substring(0, 8)} for $serviceName has been completed successfully.',
        relatedId: orderId,
      );
      
      AppLogger.info('[OrderManageController] Completion notification sent for order $orderId', tag: 'OrderManage');
    } catch (e) {
      AppLogger.error('[OrderManageController] Error sending completion notification: $e', tag: 'OrderManage');
    }
  }
  
  /// Filter orders by status
  void filterByStatus(String status) {
    currentStatus.value = status;
    loadOrders(refresh: true);
  }
  
  /// Search orders
  void searchOrders(String query) {
    searchQuery.value = query;
    loadOrders(refresh: true);
  }
  
  /// Get order statistics
  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[OrderManageController] No user ID available', tag: 'OrderManage');
        return {};
      }
      
      final response = await _supabase
          .from('orders')
          .select('status')
          .eq('provider_id', userId);
      
      final Map<String, int> stats = {
        'total': response.length,
        'pending': 0,
        'accepted': 0,
        'in_progress': 0,
        'completed': 0,
        'cancelled': 0,
      };
      
      for (final order in response) {
        final status = order['status'] as String;
        if (stats.containsKey(status)) {
          stats[status] = (stats[status] ?? 0) + 1;
        }
      }
      
      return stats;
      
    } catch (e) {
      AppLogger.error('[OrderManageController] Error getting statistics: $e', tag: 'OrderManage');
      return {};
    }
  }
  
  /// Get status display text
  String getStatusDisplayText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
  
  /// Get status color
  int getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return 0xFFFFA500; // Orange
      case 'accepted':
        return 0xFF2196F3; // Blue
      case 'in_progress':
        return 0xFF4CAF50; // Green
      case 'completed':
        return 0xFF4CAF50; // Green
      case 'cancelled':
        return 0xFFF44336; // Red
      default:
        return 0xFF9E9E9E; // Grey
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
  
  /// Get customer name
  String getCustomerName(Map<String, dynamic> order) {
    final customer = order['customer'] as Map<String, dynamic>?;
    return customer?['full_name'] ?? 'Unknown Customer';
  }
  
  /// Get service name
  String getServiceName(Map<String, dynamic> order) {
    final service = order['service'] as Map<String, dynamic>?;
    return service?['name'] ?? 'Unknown Service';
  }
  
  /// Check if order can be accepted
  bool canAcceptOrder(Map<String, dynamic> order) {
    return order['status'] == 'pending';
  }
  
  /// Check if order can be started
  bool canStartOrder(Map<String, dynamic> order) {
    return order['status'] == 'accepted';
  }
  
  /// Check if order can be completed
  bool canCompleteOrder(Map<String, dynamic> order) {
    return order['status'] == 'in_progress';
  }
  
  /// Refresh orders
  Future<void> refreshOrders() async {
    await loadOrders(refresh: true);
  }
} 