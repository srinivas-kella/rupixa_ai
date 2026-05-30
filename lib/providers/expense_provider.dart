import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final Box<ExpenseModel> expensesBox = Hive.box<ExpenseModel>('expensesBox');

  String searchQuery = '';

  String selectedCategory = 'All';

  List<ExpenseModel> get allExpenses =>
      expensesBox.values.toList().reversed.toList();

  List<ExpenseModel> get expenses {
    List<ExpenseModel> filteredExpenses = allExpenses;

    if (selectedCategory != 'All') {
      filteredExpenses = filteredExpenses.where((expense) {
        return expense.category == selectedCategory;
      }).toList();
    }

    if (searchQuery.isNotEmpty) {
      filteredExpenses = filteredExpenses.where((expense) {
        return expense.title.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    return filteredExpenses;
  }

  void setSearchQuery(String query) {
    searchQuery = query;

    notifyListeners();
  }

  void setCategory(String category) {
    selectedCategory = category;

    notifyListeners();
  }

  void addExpense(ExpenseModel expense) {
    expensesBox.add(expense);

    notifyListeners();
  }

  Future<void> updateExpense(
    ExpenseModel currentExpense,
    ExpenseModel updatedExpense,
  ) async {
    await expensesBox.put(currentExpense.key, updatedExpense);

    notifyListeners();
  }

  Future<void> deleteExpense(ExpenseModel expense) async {
    await expensesBox.delete(expense.key);

    notifyListeners();
  }

  double get totalExpenses {
    double total = 0;

    for (var expense in allExpenses) {
      total += expense.amount;
    }

    return total;
  }
}
