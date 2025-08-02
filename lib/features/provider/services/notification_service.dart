import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 获取通知列表
  Future<List<Map<String, dynamic>>> getNotifications({int limit = 50}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[NotificationService] No user ID available');
        return [];
      }

      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('recipient_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('[NotificationService] Error getting notifications: $e');
      return [];
    }
  }

  /// 标记通知为已读
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      AppLogger.info('[NotificationService] Notification $notificationId marked as read');
      return true;
    } catch (e) {
      AppLogger.error('[NotificationService] Error marking notification as read: $e');
      return false;
    }
  }

  /// 标记所有通知为已读
  Future<bool> markAllNotificationsAsRead() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[NotificationService] No user ID available');
        return false;
      }

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('recipient_id', userId)
          .eq('is_read', false);

      AppLogger.info('[NotificationService] All notifications marked as read');
      return true;
    } catch (e) {
      AppLogger.error('[NotificationService] Error marking all notifications as read: $e');
      return false;
    }
  }

  /// 删除通知
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      AppLogger.info('[NotificationService] Notification $notificationId deleted');
      return true;
    } catch (e) {
      AppLogger.error('[NotificationService] Error deleting notification: $e');
      return false;
    }
  }

  /// 获取未读通知数量
  Future<int> getUnreadCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[NotificationService] No user ID available');
        return 0;
      }

      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('recipient_id', userId)
          .eq('is_read', false);

      return response.length;
    } catch (e) {
      AppLogger.error('[NotificationService] Error getting unread count: $e');
      return 0;
    }
  }

  /// 创建通知
  Future<bool> createNotification(String recipientId, String notificationType, String title, String message, {String? relatedId}) async {
    try {
      await _supabase
          .from('notifications')
          .insert({
            'recipient_id': recipientId,
            'notification_type': notificationType,
            'title': title,
            'message': message,
            'related_id': relatedId,
            'is_read': false,
            'created_at': DateTime.now().toIso8601String(),
          });

      AppLogger.info('[NotificationService] Notification created for user $recipientId');
      return true;
    } catch (e) {
      AppLogger.error('[NotificationService] Error creating notification: $e');
      return false;
    }
  }

  /// 获取通知类型统计
  Future<Map<String, int>> getNotificationTypeStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        AppLogger.warning('[NotificationService] No user ID available');
        return {};
      }

      final response = await _supabase
          .from('notifications')
          .select('notification_type')
          .eq('recipient_id', userId);

      final Map<String, int> typeStats = {};
      for (final notification in response) {
        final type = notification['notification_type'] as String;
        typeStats[type] = (typeStats[type] ?? 0) + 1;
      }

      return typeStats;
    } catch (e) {
      AppLogger.error('[NotificationService] Error getting notification type stats: $e');
      return {};
    }
  }

  /// 获取通知类型显示名称
  String getNotificationTypeDisplayName(String type) {
    switch (type) {
      case 'order':
        return 'Order';
      case 'message':
        return 'Message';
      case 'system':
        return 'System';
      case 'payment':
        return 'Payment';
      case 'client':
        return 'Client';
      default:
        return type;
    }
  }

  /// 获取通知类型图标
  String getNotificationTypeIcon(String type) {
    switch (type) {
      case 'order':
        return 'receipt';
      case 'message':
        return 'message';
      case 'system':
        return 'notifications';
      case 'payment':
        return 'payment';
      case 'client':
        return 'person';
      default:
        return 'notifications';
    }
  }

  /// 获取通知类型颜色
  int getNotificationTypeColor(String type) {
    switch (type) {
      case 'order':
        return 0xFF4CAF50; // Green
      case 'message':
        return 0xFF2196F3; // Blue
      case 'system':
        return 0xFFFF9800; // Orange
      case 'payment':
        return 0xFF9C27B0; // Purple
      case 'client':
        return 0xFF607D8B; // Blue Grey
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  /// 格式化通知时间
  String formatNotificationTime(String? dateString) {
    if (dateString == null) return 'Unknown';
    
    try {
      final DateTime date = DateTime.parse(dateString);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(date);
      
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
      return 'Invalid date';
    }
  }
} 