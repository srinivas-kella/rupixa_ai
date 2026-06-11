import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/expense_model.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const Color primary = Color(0xFF5B67FF);
  static const Color secondary = Color(0xFF7B61FF);

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final expenseProvider = context.watch<ExpenseProvider>();
    final budgetProvider = context.watch<BudgetProvider>();

    final expenses = expenseProvider.allExpenses;

    final monthlyBudget = budgetProvider.monthlyBudget;

    double monthlySpend = 0;

    final now = DateTime.now();

    for (final expense in expenses) {
      if (expense.date.month == now.month && expense.date.year == now.year) {
        monthlySpend += expense.amount;
      }
    }

    final remaining = monthlyBudget - monthlySpend;

    final selectedDayExpenses = expenses.where((expense) {
      return expense.date.day == selectedDay.day &&
          expense.date.month == selectedDay.month &&
          expense.date.year == selectedDay.year;
    }).toList();

    double selectedDayTotal = 0;

    for (final expense in selectedDayExpenses) {
      selectedDayTotal += expense.amount;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),

          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              expandedHeight: 90,

              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Calendar",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    _summaryCard(monthlySpend, monthlyBudget, remaining),

                    const SizedBox(height: 24),

                    _calendarWidget(expenses),

                    const SizedBox(height: 24),

                    _selectedDayCard(
                      selectedDay,
                      selectedDayTotal,
                      selectedDayExpenses.length,
                    ),

                    const SizedBox(height: 20),

                    _expenseTimeline(selectedDayExpenses),

                    const SizedBox(height: 24),

                    _monthlyInsight(monthlySpend, monthlyBudget, expenses),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(double spent, double budget, double remaining) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),

        gradient: const LinearGradient(colors: [primary, secondary]),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Monthly Overview",
            style: GoogleFonts.poppins(color: Colors.white70),
          ),

          const SizedBox(height: 12),

          Text(
            "₹${spent.toStringAsFixed(0)}",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _miniStat("Budget", "₹${budget.toStringAsFixed(0)}"),
              ),

              Expanded(
                child: _miniStat(
                  "Remaining",
                  "₹${remaining.toStringAsFixed(0)}",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _calendarWidget(List<ExpenseModel> expenses) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: .06),
      ),

      child: TableCalendar(
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2050),
        focusedDay: focusedDay,

        availableCalendarFormats: const {CalendarFormat.month: 'Month'},

        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          leftChevronIcon: const Icon(
            CupertinoIcons.chevron_left,
            color: primary,
          ),
          rightChevronIcon: const Icon(
            CupertinoIcons.chevron_right,
            color: primary,
          ),
        ),

        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: primary.withValues(alpha: .35),
            shape: BoxShape.circle,
          ),

          selectedDecoration: const BoxDecoration(
            color: primary,
            shape: BoxShape.circle,
          ),

          markerDecoration: const BoxDecoration(
            color: primary,
            shape: BoxShape.circle,
          ),
        ),

        selectedDayPredicate: (day) {
          return isSameDay(selectedDay, day);
        },

        onDaySelected: (selected, focused) {
          setState(() {
            selectedDay = selected;
            focusedDay = focused;
          });
        },

        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            final hasExpense = expenses.any(
              (e) =>
                  e.date.day == date.day &&
                  e.date.month == date.month &&
                  e.date.year == date.year,
            );

            if (!hasExpense) {
              return null;
            }

            return Positioned(
              bottom: 6,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _selectedDayCard(DateTime day, double total, int transactions) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: .06),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${day.day}/${day.month}/${day.year}",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            "Spent ₹${total.toStringAsFixed(0)}",
            style: GoogleFonts.poppins(),
          ),

          Text("$transactions Transactions", style: GoogleFonts.poppins()),
        ],
      ),
    );
  }

  Widget _expenseTimeline(List<ExpenseModel> expenses) {
    return Column(
      children: expenses.map((expense) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: .06),
          ),

          child: Row(
            children: [
              const Icon(
                CupertinoIcons.money_dollar_circle_fill,
                color: primary,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),

                    Text(expense.category),
                  ],
                ),
              ),

              Text(
                "₹${expense.amount.toStringAsFixed(0)}",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _monthlyInsight(
    double spend,
    double budget,
    List<ExpenseModel> expenses,
  ) {
    final percent = budget == 0 ? 0 : (spend / budget) * 100;

    String insight;

    if (percent > 90) {
      insight = "You're very close to your monthly budget limit.";
    } else if (percent < 50) {
      insight = "Excellent spending control this month.";
    } else {
      insight = "Your spending pattern is balanced.";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: .06),
      ),

      child: Row(
        children: [
          const Icon(CupertinoIcons.sparkles, color: primary),

          const SizedBox(width: 12),

          Expanded(child: Text(insight, style: GoogleFonts.poppins())),
        ],
      ),
    );
  }
}
