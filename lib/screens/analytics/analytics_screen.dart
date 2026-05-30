import 'dart:math';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../core/services/pdf_service.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  static const Color primary = Color(0xFF5B67FF);

  static const Color secondary = Color(0xFF7B61FF);

  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    final budgetProvider = Provider.of<BudgetProvider>(context);

    final expenses = expenseProvider.expenses;

    final monthlyBudget = budgetProvider.monthlyBudget;

    double food = 0;
    double shopping = 0;
    double transport = 0;
    double entertainment = 0;
    double others = 0;

    for (var expense in expenses) {
      switch (expense.category) {
        case 'Food':
          food += expense.amount;
          break;

        case 'Shopping':
          shopping += expense.amount;
          break;

        case 'Transport':
          transport += expense.amount;
          break;

        case 'Entertainment':
          entertainment += expense.amount;
          break;

        default:
          others += expense.amount;
      }
    }

    final total = food + shopping + transport + entertainment + others;

    final savings = monthlyBudget - total;

    final topCategory = {
      "Food": food,
      "Shopping": shopping,
      "Transport": transport,
      "Entertainment": entertainment,
      "Others": others,
    }.entries.reduce((a, b) => a.value > b.value ? a : b);

    final spendingPercentage = monthlyBudget == 0
        ? 0.0
        : min(total / monthlyBudget, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),

      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.85),

        elevation: 0,

        scrolledUnderElevation: 0,

        automaticallyImplyLeading: false,

        toolbarHeight: 88,

        centerTitle: false,

        titleSpacing: 20,

        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),

            child: Container(color: Colors.white.withOpacity(0.72)),
          ),
        ),

        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),

                borderRadius: BorderRadius.circular(30),
              ),

              child: Text(
                "Financial Intelligence",

                style: GoogleFonts.poppins(
                  fontSize: 11,

                  fontWeight: FontWeight.w600,

                  color: primary,
                ),
              ),
            ),

            const SizedBox(height: 8),

            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [const Color(0xFF15192D), primary, secondary],
                ).createShader(bounds);
              },

              child: Text(
                "Analytics",

                style: GoogleFonts.poppins(
                  fontSize: 30,

                  fontWeight: FontWeight.w800,

                  color: Colors.white,

                  letterSpacing: -1,
                ),
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 12, bottom: 12),

            child: GestureDetector(
              onTap: () async {
                await HapticFeedback.lightImpact();

                if (context.mounted) {
                  context.push('/monthlyReport');
                }
              },

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),

                height: 48,
                width: 48,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),

                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.white.withOpacity(0.92)],
                  ),

                  border: Border.all(color: Colors.white.withOpacity(0.7)),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),

                      blurRadius: 14,

                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: const Icon(
                  CupertinoIcons.doc_chart_fill,

                  color: primary,

                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            /// ===================================
            /// FINANCIAL OVERVIEW
            /// ===================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(28),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),

                gradient: const LinearGradient(
                  colors: [primary, secondary],

                  begin: Alignment.topLeft,

                  end: Alignment.bottomRight,
                ),

                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.35),

                    blurRadius: 28,

                    offset: const Offset(0, 16),
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
                          Text(
                            "Total Spending",

                            style: GoogleFonts.poppins(
                              color: Colors.white70,

                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "₹ ${total.toStringAsFixed(0)}",

                            style: GoogleFonts.poppins(
                              color: Colors.white,

                              fontSize: 36,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      Container(
                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),

                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          CupertinoIcons.chart_pie_fill,

                          color: Colors.white,

                          size: 34,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),

                    child: LinearProgressIndicator(
                      minHeight: 12,

                      value: spendingPercentage,

                      backgroundColor: Colors.white.withOpacity(0.18),

                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    monthlyBudget == 0
                        ? "Set your monthly budget to track spending."
                        : "${(spendingPercentage * 100).toStringAsFixed(0)}% of your monthly budget used",

                    style: GoogleFonts.poppins(
                      color: Colors.white70,

                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 26),

                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniCard(
                          title: "Budget",

                          value: "₹ ${monthlyBudget.toStringAsFixed(0)}",

                          icon: CupertinoIcons.creditcard_fill,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: _buildMiniCard(
                          title: savings >= 0 ? "Savings" : "Overspent",

                          value: "₹ ${savings.abs().toStringAsFixed(0)}",

                          icon: savings >= 0
                              ? CupertinoIcons.arrow_down_circle_fill
                              : CupertinoIcons.exclamationmark_triangle_fill,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// ===================================
            /// QUICK INSIGHTS
            /// ===================================
            Row(
              children: [
                Expanded(
                  child: _buildInsightCard(
                    title: "Top Category",

                    value: topCategory.key,

                    subtitle: "₹ ${topCategory.value.toStringAsFixed(0)}",

                    icon: CupertinoIcons.star_fill,

                    color: Colors.orange,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _buildInsightCard(
                    title: "Transactions",

                    value: expenses.length.toString(),

                    subtitle: "This month",

                    icon: CupertinoIcons.arrow_2_circlepath_circle_fill,

                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 34),

            /// ===================================
            /// CHART
            /// ===================================
            Text(
              "Spending Breakdown",

              style: GoogleFonts.poppins(
                fontSize: 24,

                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(32),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),

                    blurRadius: 18,

                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(
                children: [
                  SizedBox(
                    height: 290,

                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              touchedIndex =
                                  response
                                      ?.touchedSection
                                      ?.touchedSectionIndex ??
                                  -1;
                            });
                          },
                        ),

                        sectionsSpace: 6,

                        centerSpaceRadius: 75,

                        sections: [
                          _buildSection(
                            index: 0,
                            value: food,
                            title: "Food",
                            color: const Color(0xFFFFA726),
                          ),

                          _buildSection(
                            index: 1,
                            value: shopping,
                            title: "Shopping",
                            color: const Color(0xFF42A5F5),
                          ),

                          _buildSection(
                            index: 2,
                            value: transport,
                            title: "Transport",
                            color: const Color(0xFF66BB6A),
                          ),

                          _buildSection(
                            index: 3,
                            value: entertainment,
                            title: "Fun",
                            color: const Color(0xFFEF5350),
                          ),

                          _buildSection(
                            index: 4,
                            value: others,
                            title: "Others",
                            color: const Color(0xFFAB47BC),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Tap chart sections to interact",

                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade500,

                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 34),

            /// ===================================
            /// MONTHLY REPORT CARD
            /// ===================================
            GestureDetector(
              onTap: () async {
                await HapticFeedback.mediumImpact();

                if (context.mounted) {
                  context.push('/monthlyReport');
                }
              },

              child: Container(
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF111827), Color(0xFF1F2937)],
                  ),

                  borderRadius: BorderRadius.circular(32),
                ),

                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        CupertinoIcons.doc_chart_fill,

                        color: Colors.white,

                        size: 32,
                      ),
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Advanced Monthly Report",

                            style: GoogleFonts.poppins(
                              color: Colors.white,

                              fontSize: 18,

                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Generate premium financial insights & export PDF reports.",

                            style: GoogleFonts.poppins(
                              color: Colors.white70,

                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      CupertinoIcons.chevron_right,

                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 34),

            /// ===================================
            /// CATEGORY LIST
            /// ===================================
            Text(
              "Category Insights",

              style: GoogleFonts.poppins(
                fontSize: 24,

                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 20),

            _buildTile(
              title: 'Food',
              amount: food,
              color: const Color(0xFFFFA726),
              icon: CupertinoIcons.cart_fill,
            ),

            _buildTile(
              title: 'Shopping',
              amount: shopping,
              color: const Color(0xFF42A5F5),
              icon: CupertinoIcons.bag_fill,
            ),

            _buildTile(
              title: 'Transport',
              amount: transport,
              color: const Color(0xFF66BB6A),
              icon: CupertinoIcons.car_fill,
            ),

            _buildTile(
              title: 'Entertainment',
              amount: entertainment,
              color: const Color(0xFFEF5350),
              icon: CupertinoIcons.game_controller_solid,
            ),

            _buildTile(
              title: 'Others',
              amount: others,
              color: const Color(0xFFAB47BC),
              icon: CupertinoIcons.square_grid_2x2_fill,
            ),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: GestureDetector(
        onTap: () async {
          await HapticFeedback.mediumImpact();

          final file = await PdfService.generateReport(
            totalSpent: total,

            budget: monthlyBudget,

            savings: savings,
          );

          await Printing.sharePdf(
            bytes: await file.readAsBytes(),

            filename: 'monthly_report.pdf',
          );
        },

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),

          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [primary, secondary]),

            borderRadius: BorderRadius.circular(24),

            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.35),

                blurRadius: 24,

                offset: const Offset(0, 12),
              ),
            ],
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Icon(
                CupertinoIcons.arrow_down_doc_fill,

                color: Colors.white,
              ),

              const SizedBox(width: 12),

              Text(
                "Export PDF",

                style: GoogleFonts.poppins(
                  color: Colors.white,

                  fontWeight: FontWeight.w600,

                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===================================
  /// PIE CHART SECTION
  /// ===================================

  PieChartSectionData _buildSection({
    required int index,
    required double value,
    required String title,
    required Color color,
  }) {
    final isTouched = index == touchedIndex;

    final radius = isTouched ? 95.0 : 82.0;

    final fontSize = isTouched ? 14.0 : 11.0;

    return PieChartSectionData(
      value: value == 0 ? 0.1 : value,

      color: color,

      radius: radius,

      title: value == 0 ? "" : title,

      titleStyle: GoogleFonts.poppins(
        color: Colors.white,

        fontSize: fontSize,

        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// ===================================
  /// MINI OVERVIEW CARD
  /// ===================================

  Widget _buildMiniCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),

        borderRadius: BorderRadius.circular(24),
      ),

      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: GoogleFonts.poppins(
                    color: Colors.white70,

                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: GoogleFonts.poppins(
                    color: Colors.white,

                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ===================================
  /// QUICK INSIGHT CARD
  /// ===================================

  Widget _buildInsightCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),

            blurRadius: 16,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: color.withOpacity(0.12),

              borderRadius: BorderRadius.circular(18),
            ),

            child: Icon(icon, color: color),
          ),

          const SizedBox(height: 18),

          Text(
            title,

            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,

              fontSize: 12,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,

            style: GoogleFonts.poppins(
              fontSize: 22,

              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            subtitle,

            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,

              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// ===================================
  /// CATEGORY TILE
  /// ===================================

  Widget _buildTile({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: GestureDetector(
        onTap: () async {
          await HapticFeedback.lightImpact();
        },

        child: Container(
          padding: const EdgeInsets.all(22),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(30),

            border: Border.all(color: Colors.grey.shade100),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),

                blurRadius: 16,

                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),

                  borderRadius: BorderRadius.circular(22),
                ),

                child: Icon(icon, color: color, size: 28),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: GoogleFonts.poppins(
                        fontSize: 18,

                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Monthly category spending",

                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade500,

                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                "₹ ${amount.toStringAsFixed(0)}",

                style: GoogleFonts.poppins(
                  fontSize: 18,

                  fontWeight: FontWeight.w700,

                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
