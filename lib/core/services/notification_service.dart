import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rupixa_ai/core/services/notification_firestore_service.dart';
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
    } catch (_) {}
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

    /// SAVE TO FIRESTORE
    await NotificationFirestoreService.addNotification(
      title: title,
      body: body,
      type: 'general',
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

    String? category,
    double? amount,
    DateTime? dueDate,
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

    /// SAVE TO FIRESTORE
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'body': body,

      'type': 'bill',

      'category': category,

      'amount': amount,

      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,

      'isRead': false,

      'createdAt': FieldValue.serverTimestamp(),
    });

    print('Notification scheduled successfully');
  }

  /// =========================================
  /// CHECK PENDING
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

  /// =========================================
  /// REQUEST PERMISSION
  /// =========================================

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
