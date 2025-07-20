import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/orders/presentation/orders_controller.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations.dart';
import 'package:jinbeanpod_83904710/l10n/app_localizations_en.dart';

class OrdersPage extends GetView<OrdersController> {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 状态筛选栏
          _buildStatusFilter(),
          
          // 订单列表
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.orders.isEmpty) {
                return _buildEmptyState();
              }
              
              return RefreshIndicator(
                onRefresh: controller.loadOrders,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: controller.orders.length,
                  itemBuilder: (context, index) {
                    final order = controller.orders[index];
                    return _buildOrderCard(order, index);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() => ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.statusFilters.length,
        itemBuilder: (context, index) {
          final filter = controller.statusFilters[index];
          final isSelected = controller.selectedStatus.value == filter;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                controller.filterByStatus(filter);
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Colors.blue,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? Colors.blue : Colors.grey[300]!,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      )),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start booking services to see your orders here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Browse Services'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Get.toNamed('/service_booking');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic order, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 订单头部信息
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.serviceName ?? 'Service Name',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order #${order.orderNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(order.orderStatus),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 服务商信息
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, size: 16, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.providerName ?? 'Provider Name',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 订单详情
              _buildOrderDetails(order),
              
              const SizedBox(height: 12),
              
              // 操作按钮
              _buildOrderActions(order),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'pendingacceptance':
        chipColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        icon = Icons.schedule;
        break;
      case 'accepted':
        chipColor = Colors.blue[50]!;
        textColor = Colors.blue[700]!;
        icon = Icons.check_circle_outline;
        break;
      case 'inprogress':
        chipColor = Colors.purple[50]!;
        textColor = Colors.purple[700]!;
        icon = Icons.work;
        break;
      case 'completed':
        chipColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        icon = Icons.done_all;
        break;
      case 'canceled':
        chipColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        icon = Icons.cancel;
        break;
      default:
        chipColor = Colors.grey[50]!;
        textColor = Colors.grey[700]!;
        icon = Icons.info_outline;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            controller.getStatusText(status),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(dynamic order) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildDetailRow('Date', _formatDate(order.createdAt)),
          _buildDetailRow('Time', order.scheduledStartTime != null ? _formatDateTime(order.scheduledStartTime!) : 'Not scheduled'),
          _buildDetailRow('Total', '\$${order.totalPrice.toStringAsFixed(2)}'),
          _buildDetailRow('Payment', order.paymentStatus),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderActions(dynamic order) {
    final status = order.orderStatus.toLowerCase();
    
    return Row(
      children: [
        // 查看详情按钮
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Details'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onPressed: () => _showOrderDetails(order),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // 主要操作按钮
        Expanded(
          child: _buildMainActionButton(order, status),
        ),
        
        // 更多操作按钮
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(value, order),
          itemBuilder: (context) => _buildMenuItems(order, status),
        ),
      ],
    );
  }

  Widget _buildMainActionButton(dynamic order, String status) {
    switch (status) {
      case 'pendingacceptance':
        return ElevatedButton.icon(
          icon: const Icon(Icons.cancel, size: 16),
          label: const Text('Cancel'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onPressed: () => _cancelOrder(order),
        );
      case 'accepted':
        return ElevatedButton.icon(
          icon: const Icon(Icons.message, size: 16),
          label: const Text('Message'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onPressed: () => _messageProvider(order),
        );
      case 'completed':
        return ElevatedButton.icon(
          icon: const Icon(Icons.rate_review, size: 16),
          label: const Text('Review'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onPressed: () => _reviewService(order),
        );
      default:
        return ElevatedButton.icon(
          icon: const Icon(Icons.info, size: 16),
          label: const Text('Info'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onPressed: () => _showOrderDetails(order),
        );
    }
  }

  List<PopupMenuEntry<String>> _buildMenuItems(dynamic order, String status) {
    final items = <PopupMenuEntry<String>>[];
    
    items.add(
      const PopupMenuItem(
        value: 'details',
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16),
            SizedBox(width: 8),
            Text('Order Details'),
          ],
        ),
      ),
    );
    
    if (status == 'pendingacceptance') {
      items.add(
        const PopupMenuItem(
          value: 'reschedule',
          child: Row(
            children: [
              Icon(Icons.schedule, size: 16),
              SizedBox(width: 8),
              Text('Reschedule'),
            ],
          ),
        ),
      );
    }
    
    if (status == 'completed') {
      items.add(
        const PopupMenuItem(
          value: 'rebook',
          child: Row(
            children: [
              Icon(Icons.replay, size: 16),
              SizedBox(width: 8),
              Text('Book Again'),
            ],
          ),
        ),
      );
    }
    
    items.add(
      const PopupMenuItem(
        value: 'share',
        child: Row(
          children: [
            Icon(Icons.share, size: 16),
            SizedBox(width: 8),
            Text('Share'),
          ],
        ),
      ),
    );
    
    return items;
  }

  void _handleMenuAction(String action, dynamic order) {
    switch (action) {
      case 'details':
        _showOrderDetails(order);
        break;
      case 'reschedule':
        _rescheduleOrder(order);
        break;
      case 'rebook':
        _rebookService(order);
        break;
      case 'share':
        _shareOrder(order);
        break;
    }
  }

  void _showOrderDetails(dynamic order) {
    controller.navigateToOrderDetail(order.id);
  }

  void _cancelOrder(dynamic order) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.cancelOrder(order.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _messageProvider(dynamic order) {
    Get.snackbar(
      'Message',
      'Opening chat with ${order.providerName}...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _reviewService(dynamic order) {
    Get.toNamed('/review_service', arguments: {'orderId': order.id});
  }

  void _rescheduleOrder(dynamic order) {
    Get.snackbar(
      'Reschedule',
      'Opening reschedule form...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _rebookService(dynamic order) {
    Get.toNamed('/service_booking', arguments: {'serviceId': order.id});
  }

  void _shareOrder(dynamic order) {
    Get.snackbar(
      'Share',
      'Sharing order details...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 