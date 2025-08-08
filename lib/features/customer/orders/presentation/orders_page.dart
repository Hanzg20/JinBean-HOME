import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/customer/orders/presentation/orders_controller.dart';
import 'package:jinbeanpod_83904710/core/ui/components/customer_theme_components.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/customer_theme_utils.dart';
// Import platform components
import 'package:jinbeanpod_83904710/core/components/platform_core.dart';
import 'package:jinbeanpod_83904710/features/customer/services/presentation/widgets/service_detail_loading.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  // 平台组件状态管理
  final LoadingStateManager _loadingManager = LoadingStateManager();
  
  // 获取controller
  late OrdersController controller;
  
  @override
  void initState() {
    super.initState();
    // 初始化controller
    controller = Get.put(OrdersController());
    // 初始化网络状态为在线
    _loadingManager.setOnline();
    // 数据已经在controller中加载完成，直接设置为成功状态
    _loadingManager.setSuccess();
  }

  @override
  void dispose() {
    _loadingManager.dispose();
    super.dispose();
  }

  /// 加载订单数据
  Future<void> _loadOrdersData() async {
    try {
      _loadingManager.setLoading();
      
      // 加载订单列表
      await controller.loadOrders();
      
      _loadingManager.setSuccess();
    } catch (e) {
      _loadingManager.setError('加载订单数据失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('My Orders', style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: _loadingManager,
        builder: (context, child) {
          return ServiceDetailLoading(
            state: _loadingManager.state,
            errorMessage: _loadingManager.errorMessage,
            onRetry: () => _loadOrdersData(),
            child: Column(
              children: [
                // 状态筛选栏
                _buildStatusFilter(),
                
                // 订单列表
                Expanded(
                  child: _buildOrdersList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
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
                      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    controller.filterByStatus(filter);
                  },
                  backgroundColor: colorScheme.surfaceVariant,
                  selectedColor: colorScheme.primary,
                  checkmarkColor: colorScheme.onPrimary,
                  side: BorderSide(
                    color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
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
      },
    );
  }

  Widget _buildOrderCard(dynamic order, int index) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return CustomerCard(
          onTap: () => _showOrderDetails(order),
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
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Order #${order.orderNumber}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(order.status, colorScheme),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 订单详情
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      order.scheduledDate ?? 'Date not set',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      order.scheduledTime ?? 'Time not set',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.address ?? 'Address not set',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 价格和操作按钮
                Row(
                  children: [
                    Text(
                      '\$${order.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    if (order.status == 'pending')
                      OutlinedButton(
                        onPressed: () => _cancelOrder(order),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: colorScheme.error),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                    if (order.status == 'completed')
                      ElevatedButton(
                        onPressed: () => _reviewService(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Review',
                          style: TextStyle(color: colorScheme.onPrimary),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status, ColorScheme colorScheme) {
    Color badgeColor;
    Color textColor;
    
    switch (status.toLowerCase()) {
      case 'pending':
        badgeColor = Colors.orange;
        textColor = Colors.white;
        break;
      case 'confirmed':
        badgeColor = Colors.blue;
        textColor = Colors.white;
        break;
      case 'in_progress':
        badgeColor = Colors.purple;
        textColor = Colors.white;
        break;
      case 'completed':
        badgeColor = Colors.green;
        textColor = Colors.white;
        break;
      case 'cancelled':
        badgeColor = Colors.red;
        textColor = Colors.white;
        break;
      default:
        badgeColor = colorScheme.surfaceVariant;
        textColor = colorScheme.onSurfaceVariant;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
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

  Widget _buildOrdersList() {
    return Obx(() {
      
      if (controller.orders.isEmpty) {
        return const CustomerEmptyState(
          icon: Icons.receipt_long,
          title: 'No Orders Yet',
          subtitle: 'Your orders will appear here once you book a service',
        );
      }
      
      return RefreshIndicator(
        onRefresh: () async {
          await _loadOrdersData();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return _buildOrderCard(order, index);
          },
        ),
      );
    });
  }
} 