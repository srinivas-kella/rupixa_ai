import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import 'package:rupixa_ai/core/services/pdf_service.dart';

import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  static const Color primary = Color(0xFF5B67FF);

  static const Color secondary = Color(0xFF7B61FF);

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    final budgetProvider = Provider.of<BudgetProvider>(context);

    final expenses = expenseProvider.expenses;

    final totalSpent = expenseProvider.totalExpenses;

    final monthlyBudget = budgetProvider.monthlyBudget;

    final savings = monthlyBudget - totalSpent;

    final spendingPercentage = monthlyBudget == 0
        ? 0.0
        : min(totalSpent / monthlyBudget, 1.0);

    final transactionCount = expenses.length;

    final avgTransaction = transactionCount == 0
        ? 0
        : totalSpent / transactionCount;

    final savingRate = monthlyBudget == 0 ? 0 : (savings / monthlyBudget) * 100;

    final financialScore = savings >= 0 ? 85 + min(savingRate ~/ 5, 15) : 45;

    String financialStatus = "Excellent";

    if (financialScore < 50) {
      financialStatus = "Critical";
    } else if (financialScore < 70) {
      financialStatus = "Needs Attention";
    } else if (financialScore < 85) {
      financialStatus = "Good";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),

      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.85),

        elevation: 0,

        scrolledUnderElevation: 0,

        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12),

          child: GestureDetector(
            onTap: () async {
              await HapticFeedback.lightImpact();

              if (context.mounted) {
                context.pop();
              }
            },

            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),

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

              child: const Icon(CupertinoIcons.back, color: primary, size: 22),
            ),
          ),
        ),

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
                "Advanced Financial Analytics",

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
                "Monthly Report",

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
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            /// ====================================
            /// HERO CARD
            /// ====================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(28),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(38),

                gradient: const LinearGradient(
                  colors: [primary, secondary],

                  begin: Alignment.topLeft,

                  end: Alignment.bottomRight,
                ),

                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.35),

                    blurRadius: 28,

                    offset: const Offset(0, 14),
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
                            'Total Spending',

                            style: GoogleFonts.poppins(
                              color: Colors.white70,

                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            '₹ ${totalSpent.toStringAsFixed(0)}',

                            style: GoogleFonts.poppins(
                              color: Colors.white,

                              fontSize: 40,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      Container(
                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),

                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          CupertinoIcons.chart_bar_alt_fill,

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

                      backgroundColor: Colors.white.withValues(alpha: 0.18),

                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    monthlyBudget == 0
                        ? 'Set your monthly budget for smart analysis.'
                        : '${(spendingPercentage * 100).toStringAsFixed(0)}% budget utilized',

                    style: GoogleFonts.poppins(
                      color: Colors.white70,

                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    children: [
                      Expanded(
                        child: _miniHeroStat(
                          title: "Budget",

                          value: "₹ ${monthlyBudget.toStringAsFixed(0)}",
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: _miniHeroStat(
                          title: savings >= 0 ? "Savings" : "Overspent",

                          value: "₹ ${savings.abs().toStringAsFixed(0)}",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// ====================================
            /// FINANCIAL SCORE
            /// ====================================
            Container(
              padding: const EdgeInsets.all(26),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(32),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),

                    blurRadius: 18,

                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,

                    child: Stack(
                      alignment: Alignment.center,

                      children: [
                        CircularProgressIndicator(
                          value: financialScore / 100,

                          strokeWidth: 9,

                          backgroundColor: Colors.grey.shade200,

                          valueColor: AlwaysStoppedAnimation(
                            financialScore >= 80
                                ? Colors.green
                                : financialScore >= 60
                                ? Colors.orange
                                : Colors.red,
                          ),
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Text(
                              financialScore.toString(),

                              style: GoogleFonts.poppins(
                                fontSize: 24,

                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              "Score",

                              style: GoogleFonts.poppins(
                                fontSize: 11,

                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 22),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          "Financial Health",

                          style: GoogleFonts.poppins(
                            fontSize: 20,

                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          financialStatus,

                          style: GoogleFonts.poppins(
                            color: financialScore >= 80
                                ? Colors.green
                                : financialScore >= 60
                                ? Colors.orange
                                : Colors.red,

                            fontWeight: FontWeight.w600,

                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Based on spending patterns, savings rate and monthly budget usage.",

                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,

                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// ====================================
            /// ANALYTICS GRID
            /// ====================================
            Row(
              children: [
                Expanded(
                  child: _analyticsCard(
                    title: "Transactions",

                    value: transactionCount.toString(),

                    subtitle: "This month",

                    icon: CupertinoIcons.arrow_2_circlepath_circle_fill,

                    color: Colors.green,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _analyticsCard(
                    title: "Average Spend",

                    value: "₹ ${avgTransaction.toStringAsFixed(0)}",

                    subtitle: "Per transaction",

                    icon: CupertinoIcons.money_dollar_circle_fill,

                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _analyticsCard(
                    title: "Saving Rate",

                    value: "${savingRate.toStringAsFixed(1)}%",

                    subtitle: "Monthly savings",

                    icon: CupertinoIcons.arrow_down_circle_fill,

                    color: Colors.blue,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _analyticsCard(
                    title: "Budget Status",

                    value: savings >= 0 ? "Healthy" : "Risk",

                    subtitle: "Current month",

                    icon: savings >= 0
                        ? CupertinoIcons.checkmark_seal_fill
                        : CupertinoIcons.exclamationmark_triangle_fill,

                    color: savings >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 34),

            /// ====================================
            /// AI INSIGHTS
            /// ====================================
            Text(
              'AI Financial Insights',

              style: GoogleFonts.poppins(
                fontSize: 24,

                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 20),

            _buildInsight(
              icon: CupertinoIcons.checkmark_circle_fill,

              text: savings >= 0
                  ? 'Excellent! You are staying within your monthly budget.'
                  : 'Warning: Your expenses exceeded your monthly budget.',

              color: savings >= 0 ? Colors.green : Colors.red,
            ),

            _buildInsight(
              icon: CupertinoIcons.chart_bar_alt_fill,

              text: avgTransaction > 2000
                  ? 'Your average transaction amount is relatively high.'
                  : 'Your transaction behavior looks financially stable.',

              color: Colors.blue,
            ),

            _buildInsight(
              icon: CupertinoIcons.money_dollar_circle_fill,

              text: savingRate >= 20
                  ? 'Amazing saving habits this month.'
                  : 'Try increasing your monthly savings target.',

              color: Colors.orange,
            ),

            const SizedBox(height: 34),

            /// ====================================
            /// PDF EXPORT
            /// ====================================
            Container(
              padding: const EdgeInsets.all(28),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF111827), Color(0xFF1F2937)],
                ),

                borderRadius: BorderRadius.circular(34),
              ),

              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),

                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      CupertinoIcons.doc_chart_fill,

                      color: Colors.white,

                      size: 38,
                    ),
                  ),

                  const SizedBox(height: 22),

                  Text(
                    'Export Premium Financial Report',

                    textAlign: TextAlign.center,

                    style: GoogleFonts.poppins(
                      color: Colors.white,

                      fontSize: 24,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Generate a professional PDF report containing your spending insights and financial analysis.',

                    textAlign: TextAlign.center,

                    style: GoogleFonts.poppins(
                      color: Colors.white70,

                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: () async {
                      await HapticFeedback.mediumImpact();

                      final file = await PdfService.generateReport(
                        totalSpent: totalSpent,

                        budget: monthlyBudget,

                        savings: savings,
                      );

                      await Printing.sharePdf(
                        bytes: await file.readAsBytes(),

                        filename: 'monthly_report.pdf',
                      );
                    },

                    child: Container(
                      height: 64,
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          const Icon(
                            CupertinoIcons.arrow_down_doc_fill,

                            color: primary,
                          ),

                          const SizedBox(width: 12),

                          Text(
                            'Export PDF Report',

                            style: GoogleFonts.poppins(
                              color: primary,

                              fontWeight: FontWeight.w700,

                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniHeroStat({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),

        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
          ),

          const SizedBox(height: 8),

          Text(
            value,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: GoogleFonts.poppins(
              color: Colors.white,

              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _analyticsCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(30),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),

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
              color: color.withValues(alpha: 0.12),

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

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: GoogleFonts.poppins(
              fontSize: 22,

              fontWeight: FontWeight.bold,
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

  Widget _buildInsight({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),

              blurRadius: 14,

              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),

                borderRadius: BorderRadius.circular(18),
              ),

              child: Icon(icon, color: color),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                text,

                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
