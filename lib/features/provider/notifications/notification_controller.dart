import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jinbeanpod_83904710/features/provider/services/notification_service.dart';
import 'package:jinbeanpod_83904710/core/utils/app_logger.dart';

class NotificationController extends GetxController {
  final _notificationService = NotificationService();
  
  // Observable variables
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;
  final RxMap<String, int> typeStats = <String, int>{}.obs;
  
  @override
  void onInit() {
    super.onInit();
    AppLogger.info('[NotificationController] Controller initialized', tag: 'Notification');
    loadNotifications();
    loadUnreadCount();
  }
  
  /// Load notifications
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      
      final notificationsList = await _notificationService.getNotifications();
      notifications.value = notificationsList;
      
      // Load type statistics
      final stats = await _notificationService.getNotificationTypeStats();
      typeStats.value = stats;
      
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
  
  /// Load unread count
  Future<void> loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      unreadCount.value = count;
    } catch (e) {
      AppLogger.error('[NotificationController] Error loading unread count: $e', tag: 'Notification');
    }
  }
  
  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markNotificationAsRead(notificationId);
      
      if (success) {
        // Update local notification
        final index = notifications.indexWhere((n) => n['id'] == notificationId);
        if (index != -1) {
          notifications[index]['is_read'] = true;
          notifications.refresh();
        }
        
        // Update unread count
        await loadUnreadCount();
        
        AppLogger.info('[NotificationController] Notification $notificationId marked as read', tag: 'Notification');
      }
    } catch (e) {
      AppLogger.error('[NotificationController] Error marking notification as read: $e', tag: 'Notification');
    }
  }
  
  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final success = await _notificationService.markAllNotificationsAsRead();
      
      if (success) {
        // Update all local notifications
        for (int i = 0; i < notifications.length; i++) {
          notifications[i]['is_read'] = true;
        }
        notifications.refresh();
        
        // Update unread count
        unreadCount.value = 0;
        
        Get.snackbar(
          'Success',
          'All notifications marked as read',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        AppLogger.info('[NotificationController] All notifications marked as read', tag: 'Notification');
      }
    } catch (e) {
      AppLogger.error('[NotificationController] Error marking all notifications as read: $e', tag: 'Notification');
      Get.snackbar(
        'Error',
        'Failed to mark notifications as read. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(notificationId);
      
      if (success) {
        // Remove from local list
        notifications.removeWhere((n) => n['id'] == notificationId);
        
        // Update unread count
        await loadUnreadCount();
        
        Get.snackbar(
          'Success',
          'Notification deleted',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        AppLogger.info('[NotificationController] Notification $notificationId deleted', tag: 'Notification');
      }
    } catch (e) {
      AppLogger.error('[NotificationController] Error deleting notification: $e', tag: 'Notification');
      Get.snackbar(
        'Error',
        'Failed to delete notification. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Get notification type display name
  String getNotificationTypeDisplayName(String type) {
    return _notificationService.getNotificationTypeDisplayName(type);
  }
  
  /// Get notification type icon
  String getNotificationTypeIcon(String type) {
    return _notificationService.getNotificationTypeIcon(type);
  }
  
  /// Get notification type color
  int getNotificationTypeColor(String type) {
    return _notificationService.getNotificationTypeColor(type);
  }
  
  /// Format notification time
  String formatNotificationTime(String? dateString) {
    return _notificationService.formatNotificationTime(dateString);
  }
  
  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await loadNotifications();
    await loadUnreadCount();
  }
  
  /// Get unread notifications
  List<Map<String, dynamic>> get unreadNotifications {
    return notifications.where((n) => n['is_read'] == false).toList();
  }
  
  /// Get read notifications
  List<Map<String, dynamic>> get readNotifications {
    return notifications.where((n) => n['is_read'] == true).toList();
  }
  
  /// Get notifications by type
  List<Map<String, dynamic>> getNotificationsByType(String type) {
    return notifications.where((n) => n['notification_type'] == type).toList();
  }
} 