import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Order {
  final String id;
  final String orderNumber;
  final String serviceName;
  final double totalPrice;
  final String orderStatus;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime? scheduledStartTime;
  final String? providerName;

  Order({
    required this.id,
    required this.orderNumber,
    required this.serviceName,
    required this.totalPrice,
    required this.orderStatus,
    required this.paymentStatus,
    required this.createdAt,
    this.scheduledStartTime,
    this.providerName,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['order_number'],
      serviceName: json['service_name_snapshot'] ?? 'Unknown Service',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      orderStatus: json['order_status'],
      paymentStatus: json['payment_status'],
      createdAt: DateTime.parse(json['created_at']),
      scheduledStartTime: json['scheduled_start_time'] != null 
          ? DateTime.parse(json['scheduled_start_time'])
          : null,
      providerName: json['provider_name'],
    );
  }
}

class OrdersController extends GetxController {
  final RxList<Order> orders = <Order>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedStatus = 'All'.obs;

  final List<String> statusFilters = [
    'All',
    'PendingAcceptance',
    'Accepted',
    'InProgress',
    'Completed',
    'Canceled',
  ];

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        errorMessage.value = 'User not authenticated';
        return;
      }

      // Build the query with proper chaining
      var query = Supabase.instance.client
          .from('orders')
          .select('''
            id,
            order_number,
            order_status,
            payment_status,
            total_price,
            currency,
            scheduled_start_time,
            created_at,
            order_items(
              service_name_snapshot
            )
          ''')
          .eq('user_id', user.id);

      // Apply status filter if not 'All'
      if (selectedStatus.value != 'All') {
        query = query.eq('order_status', selectedStatus.value);
      }

      final response = await query.order('created_at', ascending: false);

      final List<Order> orderList = [];
      
      for (final orderData in response) {
        // Extract service name from order_items
        String serviceName = 'Unknown Service';
        if (orderData['order_items'] != null && 
            orderData['order_items'] is List && 
            orderData['order_items'].isNotEmpty) {
          serviceName = orderData['order_items'][0]['service_name_snapshot'] ?? 'Unknown Service';
        }

        orderList.add(Order(
          id: orderData['id'],
          orderNumber: orderData['order_number'],
          serviceName: serviceName,
          totalPrice: (orderData['total_price'] ?? 0).toDouble(),
          orderStatus: orderData['order_status'],
          paymentStatus: orderData['payment_status'],
          createdAt: DateTime.parse(orderData['created_at']),
          scheduledStartTime: orderData['scheduled_start_time'] != null 
              ? DateTime.parse(orderData['scheduled_start_time'])
              : null,
        ));
      }

      orders.value = orderList;
      print('Loaded ${orderList.length} orders');
        } catch (e) {
      print('Error loading orders: $e');
      errorMessage.value = 'Failed to load orders: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    loadOrders();
  }

  String getStatusColor(String status) {
    switch (status) {
      case 'PendingAcceptance':
        return '#FFA500'; // Orange
      case 'Accepted':
        return '#4CAF50'; // Green
      case 'InProgress':
        return '#2196F3'; // Blue
      case 'Completed':
        return '#4CAF50'; // Green
      case 'Canceled':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'PendingAcceptance':
        return 'Pending Acceptance';
      case 'Accepted':
        return 'Accepted';
      case 'InProgress':
        return 'In Progress';
      case 'Completed':
        return 'Completed';
      case 'Canceled':
        return 'Canceled';
      default:
        return status;
    }
  }

  String getPaymentStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return '#4CAF50'; // Green
      case 'Pending':
        return '#FFA500'; // Orange
      case 'Failed':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  void navigateToOrderDetail(String orderId) {
    Get.toNamed('/order_detail', arguments: orderId);
  }

  void navigateToCreateOrder() {
    Get.toNamed('/create_order');
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await Supabase.instance.client
          .from('orders')
          .update({
            'order_status': 'Canceled',
            'cancellation_reason': 'Cancelled by user',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);

      Get.snackbar(
        'Success',
        'Order cancelled successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Reload orders
      loadOrders();
    } catch (e) {
      print('Error cancelling order: $e');
      Get.snackbar(
        'Error',
        'Failed to cancel order',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
} 