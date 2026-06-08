import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/notification_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<NotificationModel>('notificationsBox');

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),

      body: ValueListenableBuilder(
        valueListenable: box.listenable(),

        builder: (_, __, ___) {
          final notifications = box.values.toList().reversed.toList();

          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }

          return ListView.builder(
            itemCount: notifications.length,

            itemBuilder: (_, index) {
              final notification = notifications[index];

              return ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    notification.isRead ? Icons.done : Icons.notifications,
                  ),
                ),

                title: Text(notification.title),

                subtitle: Text(notification.body),

                trailing: Text(
                  '${notification.createdAt.day}/${notification.createdAt.month}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
