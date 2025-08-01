import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/notifications/notification_controller.dart';

class NotificationPage extends GetView<NotificationController> {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
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
                      Text('Mark All as Read'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Settings'),
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
              Tab(text: 'Notifications'),
              Tab(text: 'Messages'),
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
        // Filter Section
        _buildFilterSection(),
        
        // Statistics Section
        _buildStatisticsSection(),
        
        // Notifications List
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: controller.notificationTypes.map((type) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Obx(() => FilterChip(
                label: Text(controller.getTypeDisplayText(type)),
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
                child: _buildStatCard('Total', stats['total']?.toString() ?? '0', Colors.blue),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('Unread', stats['unread']?.toString() ?? '0', Colors.orange),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('Read', stats['read']?.toString() ?? '0', Colors.green),
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
                'No notifications found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Notifications will appear here when you receive them',
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
    final type = notification['notification_type'] as String;
    final typeColor = Color(controller.getTypeColor(type));
    final isRead = notification['is_read'] as bool? ?? false;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRead ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isRead ? Colors.white : Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Type Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    controller.getTypeIcon(type),
                    color: typeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Notification Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'] ?? 'Notification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.formatDateTime(notification['created_at']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Unread indicator
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Message
            if (notification['message'] != null && notification['message'].isNotEmpty)
              Text(
                notification['message'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Action Buttons
            Row(
              children: [
                if (!isRead)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => controller.markAsRead(notification['id']),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Mark as Read'),
                    ),
                  ),
                if (!isRead) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showNotificationDetails(notification),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showDeleteNotificationDialog(notification),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    return Obx(() {
      if (controller.isLoading.value && controller.messages.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No messages found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Messages will appear here when you receive them',
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
        onRefresh: () => controller.refreshMessages(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.messages.length,
          itemBuilder: (context, index) {
            final message = controller.messages[index];
            return _buildMessageCard(message);
          },
        ),
      );
    });
  }

  Widget _buildMessageCard(Map<String, dynamic> message) {
    final conversation = message['conversations'] as Map<String, dynamic>?;
    final participants = conversation?['participants'] as List<dynamic>?;
    
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
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue[100],
                  child: const Icon(Icons.person, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                
                // Message Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation?['title'] ?? 'Message',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.formatDateTime(message['created_at']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Message Content
            Text(
              message['content'] ?? 'No content',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showMessageDetails(message),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('View Message'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showReplyDialog(message),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Reply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUnreadNotifications() {
    controller.filterByType('all');
    // This would typically show only unread notifications
    // For now, we'll just refresh the list
    controller.refreshNotifications();
  }

  void _showNotificationSettings() {
    Get.dialog(
      AlertDialog(
        title: const Text('Notification Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Notification settings will be implemented here.'),
            SizedBox(height: 16),
            Text('This will include options for:'),
            Text('• Push notifications'),
            Text('• Email notifications'),
            Text('• SMS notifications'),
            Text('• Notification frequency'),
          ],
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

  void _showNotificationDetails(Map<String, dynamic> notification) {
    Get.dialog(
      AlertDialog(
        title: Text(notification['title'] ?? 'Notification'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (notification['message'] != null && notification['message'].isNotEmpty)
              Text(notification['message']),
            const SizedBox(height: 16),
            Text(
              'Type: ${controller.getTypeDisplayText(notification['notification_type'])}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Created: ${controller.formatDateTime(notification['created_at'])}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (notification['read_at'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Read: ${controller.formatDateTime(notification['read_at'])}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          if (!(notification['is_read'] ?? false))
            ElevatedButton(
              onPressed: () {
                controller.markAsRead(notification['id']);
                Get.back();
              },
              child: const Text('Mark as Read'),
            ),
        ],
      ),
    );
  }

  void _showDeleteNotificationDialog(Map<String, dynamic> notification) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Notification'),
        content: Text('Are you sure you want to delete "${notification['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteNotification(notification['id']);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showMessageDetails(Map<String, dynamic> message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Message Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'From: ${message['sender_id']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Content:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(message['content'] ?? 'No content'),
            const SizedBox(height: 16),
            Text(
              'Sent: ${controller.formatDateTime(message['created_at'])}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showReplyDialog(message);
            },
            child: const Text('Reply'),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(Map<String, dynamic> message) {
    final replyController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Reply to Message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: replyController,
              decoration: const InputDecoration(
                labelText: 'Your Reply',
                hintText: 'Enter your reply...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (replyController.text.isNotEmpty) {
                // TODO: Implement reply functionality
                Get.snackbar(
                  'Success',
                  'Reply sent successfully',
                  snackPosition: SnackPosition.BOTTOM,
                );
                Get.back();
              }
            },
            child: const Text('Send Reply'),
          ),
        ],
      ),
    );
  }
} 