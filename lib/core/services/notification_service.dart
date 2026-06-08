import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:rupixa_ai/models/notification_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// =========================================
  /// INITIALIZE
  /// =========================================

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await notificationsPlugin.initialize(settings);

    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();

    try {
      await androidPlugin?.requestExactAlarmsPermission();
    } catch (_) {
      // Older Android versions may not support this.
    }
  }

  /// =========================================
  /// INSTANT NOTIFICATION
  /// =========================================

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'rupixa_channel',
          'Rupixa Notifications',
          channelDescription: 'Bill reminders and app notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await notificationsPlugin.show(id, title, body, details);
    final box = Hive.box<NotificationModel>('notificationsBox');

    await box.add(
      NotificationModel(title: title, body: body, createdAt: DateTime.now()),
    );
  }

  /// =========================================
  /// SCHEDULE BILL REMINDER
  /// =========================================

  static Future<void> scheduleBillReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    print('Scheduling notification for: $scheduledDate');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'rupixa_channel',
          'Rupixa Notifications',
          channelDescription: 'Bill reminders and app notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print('Notification scheduled successfully');
  }

  /// =========================================
  /// PENDING NOTIFICATIONS
  /// =========================================

  static Future<void> checkPendingNotifications() async {
    final pending = await notificationsPlugin.pendingNotificationRequests();

    print('Pending notifications count: ${pending.length}');

    for (final notification in pending) {
      print(
        'ID: ${notification.id}, '
        'Title: ${notification.title}',
      );
    }
  }

  /// =========================================
  /// CANCEL SINGLE
  /// =========================================

  static Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  static Future<bool> requestPermission() async {
    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    return await androidPlugin?.requestNotificationsPermission() ?? true;
  }

  /// =========================================
  /// CANCEL ALL
  /// =========================================

  static Future<void> cancelAll() async {
    await notificationsPlugin.cancelAll();
  }
}
