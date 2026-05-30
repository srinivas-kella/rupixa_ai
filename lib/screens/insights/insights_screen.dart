import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/insight_service.dart';

import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = Provider.of<ExpenseProvider>(context).expenses;

    final budget = Provider.of<BudgetProvider>(context).monthlyBudget;

    double totalSpent = 0;

    for (var expense in expenses) {
      totalSpent += expense.amount;
    }

    final insights = InsightService.generateInsights(
      totalSpent: totalSpent,

      budget: budget,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),

      appBar: AppBar(title: const Text('Smart Insights')),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),

        itemCount: insights.length,

        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 18),

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(22),

              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),

            child: Text(
              insights[index],

              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          );
        },
      ),
    );
  }
}
