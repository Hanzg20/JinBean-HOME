import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/notifications/notification_controller.dart';
import 'package:jinbeanpod_83904710/core/ui/components/provider_theme_components.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => Get.back(),
          ),
          title: Text(
            '消息中心',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: colorScheme.onSurface),
          actions: [
            Obx(() => controller.unreadCount.value > 0
                ? Badge(
                    label: Text(
                      controller.unreadCount.value.toString(),
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                    backgroundColor: colorScheme.error,
                    child: IconButton(
                      icon: Icon(Icons.notifications, color: colorScheme.onSurface),
                      onPressed: () => _showUnreadNotifications(),
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.notifications, color: colorScheme.onSurface),
                    onPressed: () => _showUnreadNotifications(),
                  )),
            IconButton(
              icon: Icon(Icons.refresh, color: colorScheme.onSurface),
              onPressed: () => controller.refreshNotifications(),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
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
                PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.mark_email_read, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('全部标记为已读'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('通知设置'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            labelStyle: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            unselectedLabelStyle: theme.textTheme.labelMedium,
            tabs: const [
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Obx(() {
      if (controller.isLoading.value) {
        return const ProviderLoadingState(message: '加载通知数据...');
      }
      
      if (controller.notifications.isEmpty) {
        return const ProviderEmptyState(
          icon: Icons.notifications_none,
          title: '暂无通知',
          subtitle: '新的通知将显示在这里',
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.notifications.length,
        itemBuilder: (context, index) {
          final notification = controller.notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ProviderCard(
              onTap: () => _showNotificationDetail(notification),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    _getNotificationIcon(notification['notification_type']),
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  notification['title'] ?? '未知通知',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['message'] ?? '无内容',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.formatNotificationTime(notification['created_at']),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: !notification['is_read']
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    : null,
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildMessagesTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return const ProviderEmptyState(
      icon: Icons.message,
      title: '暂无消息',
      subtitle: '消息功能正在开发中...',
    );
  }

  void _showUnreadNotifications() {
    final unreadNotifications = controller.unreadNotifications;
    if (unreadNotifications.isEmpty) {
      Get.snackbar(
        '提示',
        '没有未读通知',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    Get.dialog(
      AlertDialog(
        title: const Text('未读通知'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: unreadNotifications.length,
            itemBuilder: (context, index) {
              final notification = unreadNotifications[index];
              return ListTile(
                title: Text(notification['title'] ?? '未知通知'),
                subtitle: Text(notification['message'] ?? '无内容'),
                onTap: () {
                  Get.back();
                  _showNotificationDetail(notification);
                },
              );
            },
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

  void _showNotificationDetail(Map<String, dynamic> notification) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // 标记为已读
    if (!notification['is_read']) {
      controller.markAsRead(notification['id']);
    }
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.surface,
        title: Text(
          notification['title'] ?? '通知详情',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['message'] ?? '无内容',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '时间: ${controller.formatNotificationTime(notification['created_at'])}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              '关闭',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    Get.snackbar(
      '提示',
      '通知设置功能正在开发中...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'order':
        return Icons.shopping_cart;
      case 'payment':
        return Icons.payment;
      case 'system':
        return Icons.system_update;
      case 'promotion':
        return Icons.local_offer;
      case 'reminder':
        return Icons.alarm;
      default:
        return Icons.notifications;
    }
  }
} 