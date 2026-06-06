import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/bill_model.dart';
import '../../models/expense_model.dart';

class BackupService {
  static const String cloudBackupEnabledKey = 'cloudBackup';
  static const String lastBackupAtKey = 'lastBackupAt';

  static Future<void> backupNow() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Please login before enabling cloud backup.');
    }

    final expenses = Hive.box<ExpenseModel>('expensesBox').values.map((item) {
      return {
        'title': item.title,
        'amount': item.amount,
        'category': item.category,
        'date': Timestamp.fromDate(item.date),
        'documentId': item.documentId,
      };
    }).toList();

    final bills = Hive.box<BillModel>('billsBox').values.map((item) {
      return {
        'title': item.title,
        'amount': item.amount,
        'category': item.category,
        'dueDate': Timestamp.fromDate(item.dueDate),
        'reminderDate': Timestamp.fromDate(item.reminderDate),
        'isPaid': item.isPaid,
      };
    }).toList();

    final now = DateTime.now();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('backups')
        .doc('latest')
        .set({
          'expenses': expenses,
          'bills': bills,
          'expenseCount': expenses.length,
          'billCount': bills.length,
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedAtLocal': now.toIso8601String(),
        });

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(cloudBackupEnabledKey, true);
    await prefs.setString(lastBackupAtKey, now.toIso8601String());
  }

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(cloudBackupEnabledKey, enabled);
  }
}
