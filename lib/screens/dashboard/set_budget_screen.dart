import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';

class SetBudgetScreen extends StatefulWidget {
  const SetBudgetScreen({super.key});

  @override
  State<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  final budgetController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final budgetProvider = Provider.of<BudgetProvider>(context);
    budgetController.text = budgetProvider.monthlyBudget.toStringAsFixed(0);
  }

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Set Monthly Budget')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Monthly Budget',

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: budgetController,

              keyboardType: TextInputType.number,

              decoration: InputDecoration(
                hintText: 'Enter budget amount',

                prefixText: '₹ ',

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,

              height: 58,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,

                  foregroundColor: Colors.white,
                ),

                onPressed: () async {
                  final amount = double.tryParse(budgetController.text);

                  if (amount == null) {
                    return;
                  }

                  await budgetProvider.setBudget(amount);

                  if (!context.mounted) {
                    return;
                  }

                  Navigator.pop(context);
                },

                child: const Text(
                  'Save Budget',

                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
