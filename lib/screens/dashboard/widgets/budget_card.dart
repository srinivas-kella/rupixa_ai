import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/budget_provider.dart';
import '../../../providers/expense_provider.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    final budgetProvider = Provider.of<BudgetProvider>(context);

    final totalSpent = expenseProvider.totalExpenses;

    final monthlyBudget = budgetProvider.monthlyBudget;

    final remaining = monthlyBudget - totalSpent;

    double progress = totalSpent / monthlyBudget;

    if (progress > 1) {
      progress = 1;
    }

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [Color(0xFF6D5DF6), Color(0xFF8E7CFF)],
        ),

        borderRadius: BorderRadius.circular(30),

        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.2),

            blurRadius: 20,

            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Monthly Budget',

                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    '₹ ${monthlyBudget.toStringAsFixed(0)}',

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 34,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),

                  borderRadius: BorderRadius.circular(18),
                ),

                child: const Icon(
                  Icons.account_balance_wallet,

                  color: Colors.white,

                  size: 34,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),

            child: LinearProgressIndicator(
              minHeight: 12,

              value: progress,

              backgroundColor: Colors.white24,

              valueColor: AlwaysStoppedAnimation(
                remaining < 0 ? Colors.red : Colors.green,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                'Spent: ₹ ${totalSpent.toStringAsFixed(0)}',

                style: const TextStyle(
                  color: Colors.white,

                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                remaining >= 0
                    ? 'Left: ₹ ${remaining.toStringAsFixed(0)}'
                    : 'Over Budget',

                style: const TextStyle(
                  color: Colors.white,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
