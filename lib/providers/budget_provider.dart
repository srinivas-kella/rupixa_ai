import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetProvider extends ChangeNotifier {
  double monthlyBudget = 25000;

  BudgetProvider() {
    loadBudget();
  }

  Future<void> setBudget(double amount) async {
    monthlyBudget = amount;

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('monthlyBudget', amount);
  }

  Future<void> loadBudget() async {
    final prefs = await SharedPreferences.getInstance();

    monthlyBudget = prefs.getDouble('monthlyBudget') ?? 25000;

    notifyListeners();
  }
}
