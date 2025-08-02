import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/notifications/notification_controller.dart';
import 'package:jinbeanpod_83904710/core/ui/components/provider_theme_components.dart';
import 'package:jinbeanpod_83904710/core/ui/themes/provider_theme_utils.dart';

class NotificationPage extends GetView<NotificationController> {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '通知中心',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
            onPressed: () => controller.refreshNotifications(),
          ),
          IconButton(
            icon: Icon(Icons.clear_all, color: colorScheme.onSurface),
            onPressed: () => _showClearAllDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 统计区域
          _buildStatisticsSection(context),
          
          // 通知列表
          Expanded(
            child: _buildNotificationsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ProviderStatCard(
                  title: '总通知数',
                  value: controller.notifications.length.toString(),
                  icon: Icons.notifications,
                  iconColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProviderStatCard(
                  title: '未读通知',
                  value: controller.unreadNotifications.length.toString(),
                  icon: Icons.mark_email_unread,
                  iconColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ProviderStatCard(
                  title: '今日通知',
                  value: _getTodayNotificationsCount().toString(),
                  icon: Icons.today,
                  iconColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProviderStatCard(
                  title: '本周通知',
                  value: _getWeekNotificationsCount().toString(),
                  icon: Icons.date_range,
                  iconColor: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }

  Widget _buildNotificationsList(BuildContext context) {
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
              onTap: () => _showNotificationDetail(context, notification),
              child: Row(
                children: [
                  // 通知图标
                  ProviderIconContainer(
                    icon: _getNotificationIcon(notification['notification_type']),
                    size: 40,
                    iconColor: _getNotificationColor(context, notification['notification_type']),
                  ),
                  const SizedBox(width: 12),
                  // 通知信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification['title'] ?? '未知通知',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (!notification['is_read'])
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.error,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification['message'] ?? '无内容',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              controller.formatNotificationTime(notification['created_at']),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 16),
                            ProviderBadge(
                              text: _getTypeText(notification['notification_type']),
                              type: _getTypeBadgeType(notification['notification_type']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 操作按钮
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          notification['is_read'] ? Icons.mark_email_read : Icons.mark_email_unread,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => _toggleReadStatus(notification),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => _deleteNotification(notification),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showClearAllDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.surface,
        title: Row(
          children: [
            ProviderIconContainer(
              icon: Icons.clear_all,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              '清空通知',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          '确定要清空所有通知吗？此操作不可撤销。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              '取消',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ProviderButton(
            onPressed: () {
              controller.markAllAsRead();
              Get.back();
            },
            text: '清空',
            type: ProviderButtonType.error,
          ),
        ],
      ),
    );
  }

  void _showNotificationDetail(BuildContext context, Map<String, dynamic> notification) {
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
        title: Row(
          children: [
            ProviderIconContainer(
              icon: _getNotificationIcon(notification['notification_type']),
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notification['title'] ?? '通知详情',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(context, '类型', _getTypeText(notification['notification_type'])),
            _buildDetailRow(context, '内容', notification['message'] ?? '无内容'),
            _buildDetailRow(context, '状态', notification['is_read'] ? '已读' : '未读'),
            _buildDetailRow(context, '时间', controller.formatNotificationTime(notification['created_at'])),
            if (notification['data'] != null)
              _buildDetailRow(context, '数据', notification['data'].toString()),
          ],
        ),
        actions: [
          ProviderButton(
            onPressed: () => Get.back(),
            text: '关闭',
            type: ProviderButtonType.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleReadStatus(Map<String, dynamic> notification) {
    if (notification['is_read']) {
      // 标记为未读 - 这里需要实现markAsUnread方法
      // 暂时使用markAsRead作为替代
      controller.markAsRead(notification['id']);
    } else {
      controller.markAsRead(notification['id']);
    }
  }

  void _deleteNotification(Map<String, dynamic> notification) {
    controller.deleteNotification(notification['id']);
  }

  // 辅助方法：获取今日通知数量
  int _getTodayNotificationsCount() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return controller.notifications.where((notification) {
      final createdAt = DateTime.tryParse(notification['created_at'] ?? '');
      if (createdAt == null) return false;
      final notificationDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
      return notificationDate.isAtSameMomentAs(today);
    }).length;
  }

  // 辅助方法：获取本周通知数量
  int _getWeekNotificationsCount() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return controller.notifications.where((notification) {
      final createdAt = DateTime.tryParse(notification['created_at'] ?? '');
      if (createdAt == null) return false;
      return createdAt.isAfter(startOfWeekDate) || createdAt.isAtSameMomentAs(startOfWeekDate);
    }).length;
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

  Color _getNotificationColor(BuildContext context, String? type) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case 'order':
        return colorScheme.primary;
      case 'payment':
        return colorScheme.secondary;
      case 'system':
        return colorScheme.tertiary;
      case 'promotion':
        return colorScheme.error;
      case 'reminder':
        return colorScheme.primary;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _getTypeText(String? type) {
    switch (type) {
      case 'order':
        return '订单';
      case 'payment':
        return '支付';
      case 'system':
        return '系统';
      case 'promotion':
        return '推广';
      case 'reminder':
        return '提醒';
      default:
        return '通知';
    }
  }

  ProviderBadgeType _getTypeBadgeType(String? type) {
    switch (type) {
      case 'order':
        return ProviderBadgeType.primary;
      case 'payment':
        return ProviderBadgeType.secondary;
      case 'system':
        return ProviderBadgeType.warning;
      case 'promotion':
        return ProviderBadgeType.error;
      case 'reminder':
        return ProviderBadgeType.primary;
      default:
        return ProviderBadgeType.secondary;
    }
  }
} 