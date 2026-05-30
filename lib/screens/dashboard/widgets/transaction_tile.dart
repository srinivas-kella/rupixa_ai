import 'package:flutter/material.dart';

import '../../../models/expense_model.dart';

class TransactionTile extends StatelessWidget {
  final ExpenseModel expense;

  const TransactionTile({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple.shade100,

        child: const Icon(Icons.account_balance_wallet),
      ),

      title: Text(expense.title),

      subtitle: Text(expense.category),

      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        crossAxisAlignment: CrossAxisAlignment.end,

        children: [
          Text(
            '- ₹${expense.amount}',

            style: const TextStyle(
              color: Colors.red,

              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            '${expense.date.day}/${expense.date.month}/${expense.date.year}',

            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
