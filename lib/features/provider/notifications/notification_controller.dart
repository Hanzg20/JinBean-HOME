import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class NotificationController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  // Observable variables
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedType = 'all'.obs;
  final RxBool hasUnreadNotifications = false.obs;
  final RxInt unreadCount = 0.obs;
  
  // Notification types
  final List<String> notificationTypes = ['all', 'order', 'payment', 'system', 'message'];
  
  @override
  void onInit() {
    super.onInit();
    AppLogger.info('[NotificationController] Controller initialized', tag: 'Notification');
    loadNotifications();
    _setupRealtimeSubscription();
  }
  
  @override
  void onClose() {
    _supabase.removeAllChannels();
    super.onClose();
  }
  
  /// Setup realtime subscription for notifications
  void _setupRealtimeSubscription() {
    _supabase
        .channel('notifications')
        .on(
          RealtimeListenTypes.postgresChanges,
          ChannelFilter(
            event: 'INSERT',
            schema: 'public',
            table: 'notifications',
            filter: 'recipient_id=eq.${_supabase.auth.currentUser?.id}',
          ),
          (payload, [ref]) {
            AppLogger.info('[NotificationController] New notification received: $payload', tag: 'Notification');
            _handleNewNotification(payload);
          },
        )
        .subscribe();
  }
  
  /// Handle new notification from realtime
  void _handleNewNotification(Map<String, dynamic> payload) {
    final newNotification = payload['new'] as Map<String, dynamic>?;
    if (newNotification != null) {
      notifications.insert(0, newNotification);
      unreadCount.value++;
      hasUnreadNotifications.value = true;
      
      // Show snackbar for new notification
      Get.snackbar(
        'New Notification',
        newNotification['title'] ?? 'You have a new notification',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  /// Load notifications
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      
      // Build query
      var query = _supabase
          .from('notifications')
          .select('*')
          .eq('recipient_id', _supabase.auth.currentUser?.id)
          .order('created_at', ascending: false)
          .limit(50);
      
      // Apply type filter
      if (selectedType.value != 'all') {
        query = query.eq('notification_type', selectedType.value);
      }
      
      final response = await query;
      
      notifications.value = List<Map<String, dynamic>>.from(response);
      
      // Calculate unread count
      _calculateUnreadCount();
      
      AppLogger.info('[NotificationController] Loaded ${notifications.length} notifications', tag: 'Notification');
      
    } catch (e) {
      AppLogger.error('[NotificationController] Error loading notifications: $e', tag: 'Notification');
      Get.snackbar(
        'Error',
        'Failed to load notifications. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Load messages
  Future<void> loadMessages() async {
    try {
      isLoading.value = true;
      
      final response = await _supabase
          .from('messages')
          .select('''
            *,
            conversations:conversations(
              id,
              title,
              participants:conversation_participants(
                user_id,
                users:users(
                  id,
                  full_name,
                  avatar_url
                )
              )
            )
          ''')
          .eq('recipient_id', _supabase.auth.currentUser?.id)
          .order('created_at', ascending: false)
          .limit(50);
      
      messages.value = List<Map<String, dynamic>>.from(response);
      
      AppLogger.info('[NotificationController] Loaded ${messages.length} messages', tag: 'Notification');
      
    } catch (e) {
      AppLogger.error('[NotificationController] Error loading messages: $e', tag: 'Notification');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
      
      // Update local state
      final index = notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        notifications[index]['is_read'] = true;
        notifications[index]['read_at'] = DateTime.now().toIso8601String();
        notifications.refresh();
      }
      
      _calculateUnreadCount();
      
      AppLogger.info('[NotificationController] Notification marked as read: $notificationId', tag: 'Notification');
      
    } catch (e) {
      AppLogger.error('[NotificationController] Error marking notification as read: $e', tag: 'Notification');
    }
  }
  
  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _supabase
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('recipient_id', _supabase.auth.currentUser?.id)
          .eq('is_read', false);
      
      // Update local state
      for (final notification in notifications) {
        notification['is_read'] = true;
        notification['read_at'] = DateTime.now().toIso8601String();
      }
      notifications.refresh();
      
      _calculateUnreadCount();
      
      Get.snackbar(
        'Success',
        'All notifications marked as read',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      AppLogger.info('[NotificationController] All notifications marked as read', tag: 'Notification');
      
    } catch (e) {
      AppLogger.error('[NotificationController] Error marking all notifications as read: $e', tag: 'Notification');
      Get.snackbar(
        'Error',
        'Failed to mark notifications as read',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);
      
      // Remove from local state
      notifications.removeWhere((n) => n['id'] == notificationId);
      
      _calculateUnreadCount();
      
      Get.snackbar(
        'Success',
        'Notification deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      AppLogger.info('[NotificationController] Notification deleted: $notificationId', tag: 'Notification');
      
    } catch (e) {
      AppLogger.error('[NotificationController] Error deleting notification: $e', tag: 'Notification');
      Get.snackbar(
        'Error',
        'Failed to delete notification',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Send notification
  Future<void> sendNotification(String recipientId, String title, String message, String type) async {
    try {
      await _supabase
          .from('notifications')
          .insert({
            'recipient_id': recipientId,
            'title': title,
            'message': message,
            'notification_type': type,
            'is_read': false,
            'created_at': DateTime.now().toIso8601String(),
          });
      
      AppLogger.info('[NotificationController] Notification sent to $recipientId', tag: 'Notification');
      
    } catch (e) {
      AppLogger.error('[NotificationController] Error sending notification: $e', tag: 'Notification');
    }
  }
  
  /// Get notification statistics
  Future<Map<String, dynamic>> getNotificationStatistics() async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('notification_type, is_read')
          .eq('recipient_id', _supabase.auth.currentUser?.id);
      
      final Map<String, int> stats = {
        'total': response.length,
        'unread': 0,
        'read': 0,
        'order': 0,
        'payment': 0,
        'system': 0,
        'message': 0,
      };
      
      for (final notification in response) {
        final type = notification['notification_type'] as String;
        final isRead = notification['is_read'] as bool;
        
        if (isRead) {
          stats['read'] = (stats['read'] ?? 0) + 1;
        } else {
          stats['unread'] = (stats['unread'] ?? 0) + 1;
        }
        
        if (stats.containsKey(type)) {
          stats[type] = (stats[type] ?? 0) + 1;
        }
      }
      
      return stats;
      
    } catch (e) {
      AppLogger.error('[NotificationController] Error getting statistics: $e', tag: 'Notification');
      return {};
    }
  }
  
  /// Filter notifications by type
  void filterByType(String type) {
    selectedType.value = type;
    loadNotifications();
  }
  
  /// Calculate unread count
  void _calculateUnreadCount() {
    int count = 0;
    for (final notification in notifications) {
      if (notification['is_read'] == false) {
        count++;
      }
    }
    unreadCount.value = count;
    hasUnreadNotifications.value = count > 0;
  }
  
  /// Get type display text
  String getTypeDisplayText(String type) {
    switch (type) {
      case 'order':
        return 'Order';
      case 'payment':
        return 'Payment';
      case 'system':
        return 'System';
      case 'message':
        return 'Message';
      default:
        return 'All';
    }
  }
  
  /// Get type color
  int getTypeColor(String type) {
    switch (type) {
      case 'order':
        return 0xFF4CAF50; // Green
      case 'payment':
        return 0xFF2196F3; // Blue
      case 'system':
        return 0xFFFF9800; // Orange
      case 'message':
        return 0xFF9C27B0; // Purple
      default:
        return 0xFF9E9E9E; // Grey
    }
  }
  
  /// Get type icon
  IconData getTypeIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_cart;
      case 'payment':
        return Icons.payment;
      case 'system':
        return Icons.info;
      case 'message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }
  
  /// Format date time
  String formatDateTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final DateTime dt = DateTime.parse(dateTime);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dt);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Invalid Date';
    }
  }
  
  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await loadNotifications();
  }
  
  /// Refresh messages
  Future<void> refreshMessages() async {
    await loadMessages();
  }
} 