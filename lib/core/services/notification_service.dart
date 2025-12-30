import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService extends GetxService {
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(InitializationSettings(android: android, iOS: ios));
  }

  Future<void> showOrderNotification(String title, String body, String orderId) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'order_channel',
        'Order Updates',
        importance: Importance.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      orderId.hashCode,
      title,
      body,
      details,
      payload: orderId,
    );
  }

  Future<void> showMessage(String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'default',
        'General',
        importance: Importance.defaultImportance,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }
}