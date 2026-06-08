import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 3)
class NotificationModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String body;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  bool isRead;

  NotificationModel({
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });
}
