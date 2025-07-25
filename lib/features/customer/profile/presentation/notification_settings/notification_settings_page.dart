import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './notification_settings_controller.dart';

class NotificationSettingsPage extends GetView<NotificationSettingsController> {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // General Notifications
              _buildSectionTitle('General Notifications'),
              const SizedBox(height: 12),
              _buildNotificationCard(
                title: 'Push Notifications',
                subtitle: 'Receive notifications on your device',
                icon: Icons.notifications,
                value: controller.pushNotificationsEnabled.value,
                onChanged: controller.togglePushNotifications,
              ),
              _buildNotificationCard(
                title: 'Email Notifications',
                subtitle: 'Receive notifications via email',
                icon: Icons.email,
                value: controller.emailNotificationsEnabled.value,
                onChanged: controller.toggleEmailNotifications,
              ),
              _buildNotificationCard(
                title: 'SMS Notifications',
                subtitle: 'Receive notifications via SMS',
                icon: Icons.sms,
                value: controller.smsNotificationsEnabled.value,
                onChanged: controller.toggleSmsNotifications,
              ),
              
              const SizedBox(height: 24),
              
              // Service Notifications
              _buildSectionTitle('Service Notifications'),
              const SizedBox(height: 12),
              _buildNotificationCard(
                title: 'Booking Updates',
                subtitle: 'Get notified about booking status changes',
                icon: Icons.calendar_today,
                value: true,
                onChanged: (value) => Get.snackbar('Setting', 'Booking updates ${value ? "enabled" : "disabled"}'),
              ),
              _buildNotificationCard(
                title: 'Service Reminders',
                subtitle: 'Reminders for upcoming appointments',
                icon: Icons.alarm,
                value: true,
                onChanged: (value) => Get.snackbar('Setting', 'Service reminders ${value ? "enabled" : "disabled"}'),
              ),
              _buildNotificationCard(
                title: 'Provider Messages',
                subtitle: 'Messages from service providers',
                icon: Icons.message,
                value: true,
                onChanged: (value) => Get.snackbar('Setting', 'Provider messages ${value ? "enabled" : "disabled"}'),
              ),
              
              const SizedBox(height: 24),
              
              // Promotional Notifications
              _buildSectionTitle('Promotional Notifications'),
              const SizedBox(height: 12),
              _buildNotificationCard(
                title: 'Special Offers',
                subtitle: 'Deals and discounts from JinBean',
                icon: Icons.local_offer,
                value: false,
                onChanged: (value) => Get.snackbar('Setting', 'Special offers ${value ? "enabled" : "disabled"}'),
              ),
              _buildNotificationCard(
                title: 'New Services',
                subtitle: 'Discover new services in your area',
                icon: Icons.new_releases,
                value: false,
                onChanged: (value) => Get.snackbar('Setting', 'New services ${value ? "enabled" : "disabled"}'),
              ),
              _buildNotificationCard(
                title: 'Community Updates',
                subtitle: 'News and updates from your community',
                icon: Icons.people,
                value: false,
                onChanged: (value) => Get.snackbar('Setting', 'Community updates ${value ? "enabled" : "disabled"}'),
              ),
              
              const SizedBox(height: 24),
              
              // Quiet Hours
              _buildSectionTitle('Quiet Hours'),
              const SizedBox(height: 12),
              _buildQuietHoursCard(),
              
              const SizedBox(height: 24),
              
              // Notification History
              _buildSectionTitle('Notification History'),
              const SizedBox(height: 12),
              _buildHistoryCard(),
              
              const SizedBox(height: 80), // Bottom padding
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.blue[600], size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue[600],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildQuietHoursCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.bedtime, color: Colors.orange[600], size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quiet Hours',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mute notifications during specific hours',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: controller.quietHoursEnabled.value,
                  onChanged: controller.toggleQuietHours,
                  activeColor: Colors.blue[600],
                ),
              ],
            ),
            if (controller.quietHoursEnabled.value) ...[
              const SizedBox(height: 16),
              Builder(
                builder: (context) => Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Time',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectTime(context, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                controller.quietHoursStart.value,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End Time',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectTime(context, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                controller.quietHoursEnd.value,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.history, color: Colors.green[600], size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Notifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'View your notification history',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: Colors.grey[600]),
                  onPressed: () => _showNotificationHistory(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectTime(BuildContext context, bool isStart) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((time) {
      if (time != null) {
        final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        if (isStart) {
          controller.setQuietHoursStart(timeString);
        } else {
          controller.setQuietHoursEnd(timeString);
        }
      }
    });
  }

  void _showNotificationHistory() {
    Get.snackbar(
      'Notification History',
      'Opening notification history...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
} 