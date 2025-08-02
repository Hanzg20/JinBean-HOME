import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/core/ui/design_system/colors.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/order_manage/order_manage_controller.dart';
import 'package:jinbeanpod_83904710/features/provider/plugins/order_manage/order_manage_binding.dart';

class OrderManagePage extends GetView<OrderManageController> {
  const OrderManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JinBeanColors.background,
      appBar: AppBar(
        title: const Text(
          '订单管理',
          style: TextStyle(
            color: JinBeanColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: JinBeanColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: JinBeanColors.textPrimary),
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
        color: JinBeanColors.surface,
        border: Border(
          bottom: BorderSide(color: JinBeanColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) => controller.searchOrders(value),
            decoration: InputDecoration(
              hintText: '搜索订单ID或客户姓名...',
              prefixIcon: const Icon(Icons.search, color: JinBeanColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: JinBeanColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: JinBeanColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: JinBeanColors.primary, width: 2),
              ),
              filled: true,
              fillColor: JinBeanColors.background,
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
                    backgroundColor: JinBeanColors.surface,
                    selectedColor: JinBeanColors.primaryLight,
                    checkmarkColor: JinBeanColors.primary,
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
                child: _buildStatCard('总订单', stats['total']?.toString() ?? '0', JinBeanColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('待接单', stats['pending']?.toString() ?? '0', JinBeanColors.warning),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('服务中', stats['in_progress']?.toString() ?? '0', JinBeanColors.success),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('已完成', stats['completed']?.toString() ?? '0', JinBeanColors.success),
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
                '未找到订单',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '当客户下单时，订单将显示在此处',
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
                    '订单 #${order['id'].toString().substring(0, 8)}',
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
            child: const Text('查看详情'),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Action Button based on status
        if (controller.canAcceptOrder(order))
          Expanded(
            child: ElevatedButton(
              onPressed: () => _acceptOrder(orderId),
              style: ElevatedButton.styleFrom(
                backgroundColor: JinBeanColors.success,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('接单'),
            ),
          ),
        
        if (controller.canStartOrder(order))
          Expanded(
            child: ElevatedButton(
              onPressed: () => _startService(orderId),
              style: ElevatedButton.styleFrom(
                backgroundColor: JinBeanColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('开始服务'),
            ),
          ),
        
        if (controller.canCompleteOrder(order))
          Expanded(
            child: ElevatedButton(
              onPressed: () => _completeService(orderId),
              style: ElevatedButton.styleFrom(
                backgroundColor: JinBeanColors.success,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('完成服务'),
            ),
          ),
        
        if (status == 'pending')
          Expanded(
            child: ElevatedButton(
              onPressed: () => _rejectOrder(orderId),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('拒绝'),
            ),
          ),
      ],
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    Get.dialog(
      AlertDialog(
        title: Text('订单 #${order['id'].toString().substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('客户', controller.getCustomerName(order)),
              _buildDetailRow('服务', controller.getServiceName(order)),
              _buildDetailRow('金额', controller.formatPrice(order['amount'])),
              _buildDetailRow('状态', controller.getStatusDisplayText(order['status'])),
              _buildDetailRow('创建时间', controller.formatDateTime(order['created_at'])),
              if (order['scheduled_date'] != null)
                _buildDetailRow('预约时间', controller.formatDateTime(order['scheduled_date'])),
              if (order['notes'] != null && order['notes'].isNotEmpty)
                _buildDetailRow('备注', order['notes']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
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
        title: const Text('接单'),
        content: const Text('您确定要接这个订单吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.acceptOrder(orderId);
            },
            child: const Text('接单'),
          ),
        ],
      ),
    );
  }

  void _rejectOrder(String orderId) {
    Get.dialog(
      AlertDialog(
        title: const Text('拒绝订单'),
        content: const Text('您确定要拒绝这个订单吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.rejectOrder(orderId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('拒绝'),
          ),
        ],
      ),
    );
  }

  void _startService(String orderId) {
    Get.dialog(
      AlertDialog(
        title: const Text('开始服务'),
        content: const Text('您确定要开始这个服务吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.startService(orderId);
            },
            child: const Text('开始服务'),
          ),
        ],
      ),
    );
  }

  void _completeService(String orderId) {
    // 找到对应的订单数据
    final orderData = controller.orders.firstWhere(
      (order) => order['id'] == orderId,
      orElse: () => <String, dynamic>{},
    );

    if (orderData.isEmpty) {
      Get.snackbar(
        '错误',
        '未找到订单数据',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('完成服务'),
        content: const Text('您确定要将此服务标记为已完成吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.completeServiceWithClientConversion(orderId, orderData);
            },
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }
} 