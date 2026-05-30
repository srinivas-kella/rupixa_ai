import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../providers/expense_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    final expenses = expenseProvider.expenses.where((expense) {
      return expense.date.day == selectedDay.day &&
          expense.date.month == selectedDay.month &&
          expense.date.year == selectedDay.year;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),

      appBar: AppBar(title: const Text('Expense Calendar')),

      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(24),
            ),

            child: TableCalendar(
              focusedDay: selectedDay,

              firstDay: DateTime(2020),

              lastDay: DateTime(2100),

              selectedDayPredicate: (day) {
                return isSameDay(selectedDay, day);
              },

              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDay = selected;
                });
              },

              headerStyle: const HeaderStyle(
                formatButtonVisible: false,

                titleCentered: true,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: expenses.isEmpty
                ? const Center(child: Text('No expenses for this day'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),

                    itemCount: expenses.length,

                    itemBuilder: (context, index) {
                      final expense = expenses[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),

                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(20),

                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6),
                          ],
                        ),

                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.deepPurple,

                              child: Icon(Icons.wallet, color: Colors.white),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    expense.title,

                                    style: const TextStyle(
                                      fontSize: 18,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(expense.category),
                                ],
                              ),
                            ),

                            Text(
                              '₹ ${expense.amount.toStringAsFixed(0)}',

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,

                                fontSize: 18,

                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
