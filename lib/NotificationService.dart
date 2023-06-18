
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  static FlutterLocalNotificationsPlugin localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const InitializationSettings initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings()
    );

    await NotificationService.localNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: onTapNotification,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
  }

  static NotificationDetails platformChannelSpecifics = const NotificationDetails(
    android: AndroidNotificationDetails(
        "high_importance_channel",
        "High Importance Notifications",
        priority: Priority.max, importance: Importance.max,
        icon: "@mipmap/ic_launcher"
    ),
  );

  static Future<void> onTapNotification(NotificationResponse? response) async {
    print("notification data: ${response?.payload}");
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(
      NotificationResponse notificationResponse) {
    print("notification data: ${notificationResponse.payload}");
  }

  static Future<void> showNotification(String reminderId, String title, String text) async {
    await NotificationService.localNotificationsPlugin.show(
      0, title, text,
      NotificationService.platformChannelSpecifics,
      payload: reminderId,
    );
  }
}