import 'package:flutter/material.dart';

class CategoryHelper {
  static const List<String> categories = [
    'Food',

    'Transport',

    'Shopping',

    'Bills',

    'Entertainment',

    'Health',

    'Education',

    'Travel',

    'Other',
  ];

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood;

      case 'Transport':
        return Icons.directions_car;

      case 'Shopping':
        return Icons.shopping_bag;

      case 'Bills':
        return Icons.receipt_long;

      case 'Entertainment':
        return Icons.movie;

      case 'Health':
        return Icons.health_and_safety;

      case 'Education':
        return Icons.school;

      case 'Travel':
        return Icons.flight;

      default:
        return Icons.account_balance_wallet;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;

      case 'Transport':
        return Colors.blue;

      case 'Shopping':
        return Colors.pink;

      case 'Bills':
        return Colors.red;

      case 'Entertainment':
        return Colors.purple;

      case 'Health':
        return Colors.green;

      case 'Education':
        return Colors.teal;

      case 'Travel':
        return Colors.indigo;

      default:
        return Colors.grey;
    }
  }
}
