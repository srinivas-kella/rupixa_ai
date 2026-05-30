import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/bill_model.dart';

class BillProvider extends ChangeNotifier {
  final Box<BillModel> billBox = Hive.box<BillModel>('billsBox');

  List<BillModel> get bills => billBox.values.toList();

  /// ADD BILL

  Future<void> addBill(BillModel bill) async {
    await billBox.add(bill);

    notifyListeners();
  }

  /// TOGGLE STATUS

  Future<void> toggleBillStatus(int index) async {
    final bill = bills[index];

    bill.isPaid = !bill.isPaid;

    await bill.save();

    notifyListeners();
  }

  /// DELETE BILL

  Future<void> removeBill(int index) async {
    await billBox.deleteAt(index);

    notifyListeners();
  }

  /// CLEAR ALL

  Future<void> clearBills() async {
    await billBox.clear();

    notifyListeners();
  }
}
