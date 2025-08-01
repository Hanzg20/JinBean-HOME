import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/notifications/notification_controller.dart';

class MessageCenterPage extends StatefulWidget {
  const MessageCenterPage({super.key});

  @override
  State<MessageCenterPage> createState() => _MessageCenterPageState();
}

class _MessageCenterPageState extends State<MessageCenterPage> {
  late NotificationController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController());
    }
    controller = Get.find<NotificationController>();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          title: const Text('消息中心'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          actions: [
            Obx(() => controller.hasUnreadNotifications.value
                ? Badge(
                    label: Text(controller.unreadCount.value.toString()),
                    child: IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () => _showUnreadNotifications(),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () => _showUnreadNotifications(),
                  )),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.refreshNotifications(),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'mark_all_read':
                    controller.markAllAsRead();
                    break;
                  case 'settings':
                    _showNotificationSettings();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.mark_email_read),
                      SizedBox(width: 8),
                      Text('全部标记为已读'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('通知设置'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: '通知'),
              Tab(text: '消息'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNotificationsTab(),
            _buildMessagesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return Column(
      children: [
        // 筛选区域
        _buildFilterSection(),
        
        // 统计区域
        _buildStatisticsSection(),
        
        // 通知列表
        Expanded(
          child: _buildNotificationsList(),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
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
          // 类型筛选
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'all',
                'order',
                'message',
                'system',
                'payment',
              ].map((type) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Obx(() => FilterChip(
                    label: Text(_getNotificationTypeText(type)),
                    selected: controller.selectedType.value == type,
                    onSelected: (selected) {
                      if (selected) {
                        controller.filterByType(type);
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
        future: controller.getNotificationStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final stats = snapshot.data ?? {};
          
          return Row(
            children: [
              Expanded(
                child: _buildStatCard('全部', stats['total']?.toString() ?? '0', Colors.blue),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('未读', stats['unread']?.toString() ?? '0', Colors.orange),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('今日', stats['today']?.toString() ?? '0', Colors.green),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return Obx(() {
      if (controller.isLoading.value && controller.notifications.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.notifications.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                '暂无通知',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '有新的通知时会在这里显示',
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
        onRefresh: () => controller.refreshNotifications(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return _buildNotificationCard(notification);
          },
        ),
      );
    });
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['is_read'] ?? false;
    final type = notification['notification_type'] ?? 'system';
    final title = notification['title'] ?? '';
    final message = notification['message'] ?? '';
    final createdAt = notification['created_at'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isRead ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationTypeColor(type).withOpacity(0.1),
          child: Icon(
            _getNotificationTypeIcon(type),
            color: _getNotificationTypeColor(type),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              createdAt != null ? _formatDate(createdAt) : '未知时间',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: !isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () => _showNotificationDetail(notification),
      ),
    );
  }

  Widget _buildMessagesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '消息功能',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '与客户的实时消息功能正在开发中',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _getNotificationTypeText(String type) {
    switch (type) {
      case 'all':
        return '全部';
      case 'order':
        return '订单';
      case 'message':
        return '消息';
      case 'system':
        return '系统';
      case 'payment':
        return '支付';
      default:
        return type;
    }
  }

  Color _getNotificationTypeColor(String type) {
    switch (type) {
      case 'order':
        return Colors.blue;
      case 'message':
        return Colors.green;
      case 'system':
        return Colors.orange;
      case 'payment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationTypeIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_cart;
      case 'message':
        return Icons.message;
      case 'system':
        return Icons.info;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(dynamic date) {
    if (date is String) {
      return DateTime.parse(date).toString().substring(0, 10);
    } else if (date is DateTime) {
      return date.toString().substring(0, 10);
    }
    return '未知日期';
  }

  void _showNotificationDetail(Map<String, dynamic> notification) {
    Get.dialog(
      AlertDialog(
        title: Text(notification['title'] ?? '通知详情'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['message'] ?? ''),
            const SizedBox(height: 16),
            Text(
              '时间: ${_formatDate(notification['created_at'])}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
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

  void _showUnreadNotifications() {
    Get.snackbar(
      '未读通知',
      '您有 ${controller.unreadCount.value} 条未读通知',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showNotificationSettings() {
    Get.dialog(
      AlertDialog(
        title: const Text('通知设置'),
        content: const Text('通知设置功能正在开发中...'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
} 