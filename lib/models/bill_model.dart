import 'package:hive/hive.dart';

part 'bill_model.g.dart';

@HiveType(typeId: 1)
class BillModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String category;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  DateTime reminderDate;

  @HiveField(5)
  bool isPaid;

  BillModel({
    required this.title,
    required this.amount,
    required this.category,
    required this.dueDate,
    required this.reminderDate,
    this.isPaid = false,
  });
}
