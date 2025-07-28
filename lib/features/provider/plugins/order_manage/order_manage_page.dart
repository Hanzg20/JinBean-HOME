import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/order_manage/order_manage_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/order_manage/order_manage_binding.dart';

class OrderManagePage extends GetView<OrderManageController> {
  const OrderManagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshOrders(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilterSection(),
          
          // Statistics Section
          _buildStatisticsSection(),
          
          // Orders List
          Expanded(
            child: _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) => controller.searchOrders(value),
            decoration: InputDecoration(
              hintText: 'Search orders by ID or customer name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          
          // Status Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.statusOptions.map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Obx(() => FilterChip(
                    label: Text(controller.getStatusDisplayText(status)),
                    selected: controller.currentStatus.value == status,
                    onSelected: (selected) {
                      if (selected) {
                        controller.filterByStatus(status);
                      }
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: Colors.blue[100],
                    checkmarkColor: Colors.blue,
                  )),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<Map<String, dynamic>>(
        future: controller.getOrderStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final stats = snapshot.data ?? {};
          
          return Row(
            children: [
              Expanded(
                child: _buildStatCard('Total', stats['total']?.toString() ?? '0', Colors.blue),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('Pending', stats['pending']?.toString() ?? '0', Colors.orange),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('In Progress', stats['in_progress']?.toString() ?? '0', Colors.green),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('Completed', stats['completed']?.toString() ?? '0', Colors.green),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return Obx(() {
      if (controller.isLoading.value && controller.orders.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No orders found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Orders will appear here when customers place them',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }
      
      return RefreshIndicator(
        onRefresh: () => controller.refreshOrders(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.orders.length + (controller.hasMoreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.orders.length) {
              // Load more indicator
              if (controller.hasMoreData.value) {
                controller.loadOrders();
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return const SizedBox.shrink();
            }
            
            final order = controller.orders[index];
            return _buildOrderCard(order);
          },
        ),
      );
    });
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final statusColor = Color(controller.getStatusColor(status));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #${order['id'].toString().substring(0, 8)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    controller.getStatusDisplayText(status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Customer Info
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.getCustomerName(order),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Service Info
            Row(
              children: [
                const Icon(Icons.work, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.getServiceName(order),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Price
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  controller.formatPrice(order['amount']),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  controller.formatDateTime(order['created_at']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            _buildActionButtons(order),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final orderId = order['id'] as String;
    
    return Row(
      children: [
        // View Details Button
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showOrderDetails(order),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('View Details'),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Action Button based on status
        if (controller.canAcceptOrder(order))
          Expanded(
            child: ElevatedButton(
              onPressed: () => _acceptOrder(orderId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Accept'),
            ),
          ),
        
        if (controller.canStartOrder(order))
          Expanded(
            child: ElevatedButton(
              onPressed: () => _startService(orderId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Start'),
            ),
          ),
        
        if (controller.canCompleteOrder(order))
          Expanded(
            child: ElevatedButton(
              onPressed: () => _completeService(orderId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Complete'),
            ),
          ),
        
        if (status == 'pending')
          Expanded(
            child: ElevatedButton(
              onPressed: () => _rejectOrder(orderId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Reject'),
            ),
          ),
      ],
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    Get.dialog(
      AlertDialog(
        title: Text('Order #${order['id'].toString().substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Customer', controller.getCustomerName(order)),
              _buildDetailRow('Service', controller.getServiceName(order)),
              _buildDetailRow('Amount', controller.formatPrice(order['amount'])),
              _buildDetailRow('Status', controller.getStatusDisplayText(order['status'])),
              _buildDetailRow('Created', controller.formatDateTime(order['created_at'])),
              if (order['scheduled_date'] != null)
                _buildDetailRow('Scheduled', controller.formatDateTime(order['scheduled_date'])),
              if (order['notes'] != null && order['notes'].isNotEmpty)
                _buildDetailRow('Notes', order['notes']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _acceptOrder(String orderId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Accept Order'),
        content: const Text('Are you sure you want to accept this order?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.acceptOrder(orderId);
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _rejectOrder(String orderId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reject Order'),
        content: const Text('Are you sure you want to reject this order?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.rejectOrder(orderId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _startService(String orderId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Start Service'),
        content: const Text('Are you sure you want to start this service?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.startService(orderId);
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _completeService(String orderId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Complete Service'),
        content: const Text('Are you sure you want to mark this service as completed?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.completeService(orderId);
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
} 