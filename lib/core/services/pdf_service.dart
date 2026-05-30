import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  static Future<File> generateReport({
    required double totalSpent,
    required double budget,
    required double savings,
  }) async {
    final pdf = pw.Document();

    final currentDate = DateFormat('dd MMM yyyy').format(DateTime.now());

    final spendingPercentage = budget == 0 ? 0.0 : (totalSpent / budget);

    final savingsRate = budget == 0 ? 0.0 : (savings / budget) * 100;

    int financialScore = 80;

    if (savings < 0) {
      financialScore = 45;
    } else if (savingsRate > 30) {
      financialScore = 96;
    } else if (savingsRate > 20) {
      financialScore = 90;
    }

    String financialStatus = "Excellent";

    if (financialScore < 50) {
      financialStatus = "Critical";
    } else if (financialScore < 70) {
      financialStatus = "Needs Attention";
    } else if (financialScore < 85) {
      financialStatus = "Good";
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(margin: const pw.EdgeInsets.all(28)),

        build: (context) => [
          /// =====================================
          /// HEADER
          /// =====================================
          pw.Container(
            padding: const pw.EdgeInsets.all(28),

            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(28),

              color: PdfColor.fromHex('#5B67FF'),
            ),

            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,

              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,

                      children: [
                        pw.Text(
                          'Rupixa AI',

                          style: pw.TextStyle(
                            color: PdfColors.white,

                            fontSize: 30,

                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),

                        pw.SizedBox(height: 6),

                        pw.Text(
                          'Premium Financial Report',

                          style: pw.TextStyle(
                            color: PdfColors.white,

                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),

                    pw.Container(
                      padding: const pw.EdgeInsets.all(18),

                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,

                        color: PdfColors.white,
                      ),

                      child: pw.Text(
                        'AI',

                        style: pw.TextStyle(
                          color: PdfColor.fromHex('#5B67FF'),

                          fontWeight: pw.FontWeight.bold,

                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 28),

                pw.Container(
                  padding: const pw.EdgeInsets.all(18),

                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(20),

                    color: PdfColors.white.shade(0.15),
                  ),

                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

                    children: [
                      _heroStat(
                        title: "Total Spent",

                        value: "₹ ${totalSpent.toStringAsFixed(0)}",
                      ),

                      _heroStat(
                        title: "Budget",

                        value: "₹ ${budget.toStringAsFixed(0)}",
                      ),

                      _heroStat(
                        title: savings >= 0 ? "Savings" : "Overspent",

                        value: "₹ ${savings.abs().toStringAsFixed(0)}",
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 18),

                pw.Text(
                  'Generated on $currentDate',

                  style: pw.TextStyle(color: PdfColors.white, fontSize: 12),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 30),

          /// =====================================
          /// FINANCIAL SCORE
          /// =====================================
          pw.Container(
            padding: const pw.EdgeInsets.all(24),

            decoration: pw.BoxDecoration(
              color: PdfColors.white,

              borderRadius: pw.BorderRadius.circular(24),

              border: pw.Border.all(color: PdfColors.grey300),
            ),

            child: pw.Row(
              children: [
                pw.Container(
                  width: 90,
                  height: 90,

                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,

                    color: financialScore >= 80
                        ? PdfColors.green100
                        : financialScore >= 60
                        ? PdfColors.orange100
                        : PdfColors.red100,
                  ),

                  child: pw.Center(
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,

                      children: [
                        pw.Text(
                          financialScore.toString(),

                          style: pw.TextStyle(
                            fontSize: 24,

                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),

                        pw.Text(
                          'Score',

                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),

                pw.SizedBox(width: 24),

                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,

                    children: [
                      pw.Text(
                        'Financial Health Analysis',

                        style: pw.TextStyle(
                          fontSize: 22,

                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),

                      pw.SizedBox(height: 10),

                      pw.Text(
                        financialStatus,

                        style: pw.TextStyle(
                          fontSize: 18,

                          fontWeight: pw.FontWeight.bold,

                          color: financialScore >= 80
                              ? PdfColors.green
                              : financialScore >= 60
                              ? PdfColors.orange
                              : PdfColors.red,
                        ),
                      ),

                      pw.SizedBox(height: 10),

                      pw.Text(
                        'Your financial score is calculated using spending habits, savings ratio, and monthly budget utilization.',

                        style: const pw.TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 30),

          /// =====================================
          /// ANALYTICS SECTION
          /// =====================================
          pw.Text(
            'Financial Analytics',

            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 18),

          pw.Row(
            children: [
              pw.Expanded(
                child: _analyticsCard(
                  title: "Budget Usage",

                  value: "${(spendingPercentage * 100).toStringAsFixed(0)}%",

                  subtitle: "Current utilization",
                ),
              ),

              pw.SizedBox(width: 14),

              pw.Expanded(
                child: _analyticsCard(
                  title: "Savings Rate",

                  value: "${savingsRate.toStringAsFixed(1)}%",

                  subtitle: "Monthly efficiency",
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 14),

          pw.Row(
            children: [
              pw.Expanded(
                child: _analyticsCard(
                  title: "Budget Status",

                  value: savings >= 0 ? "Healthy" : "Critical",

                  subtitle: "Financial condition",
                ),
              ),

              pw.SizedBox(width: 14),

              pw.Expanded(
                child: _analyticsCard(
                  title: "Spending Level",

                  value: totalSpent > budget ? "High" : "Normal",

                  subtitle: "Monthly behavior",
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 34),

          /// =====================================
          /// AI INSIGHTS
          /// =====================================
          pw.Text(
            'AI Smart Insights',

            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 20),

          _insightTile(
            title: savings >= 0
                ? "Positive Savings Trend"
                : "Budget Overspending",

            description: savings >= 0
                ? "You successfully maintained your monthly spending within the allocated budget."
                : "Your spending exceeded the allocated monthly budget. Consider reducing non-essential expenses.",

            color: savings >= 0 ? PdfColors.green : PdfColors.red,
          ),

          _insightTile(
            title: "Budget Optimization",

            description: spendingPercentage > 0.85
                ? "Your monthly budget usage is very high. Maintaining a reserve margin is recommended."
                : "Your budget utilization looks balanced and financially sustainable.",

            color: PdfColors.blue,
          ),

          _insightTile(
            title: "Savings Recommendation",

            description: savingsRate >= 20
                ? "Excellent saving habits detected. Continue maintaining this consistency."
                : "Try increasing your savings target to at least 20% of your monthly budget.",

            color: PdfColors.orange,
          ),

          pw.SizedBox(height: 34),

          /// =====================================
          /// SUMMARY SECTION
          /// =====================================
          pw.Container(
            padding: const pw.EdgeInsets.all(24),

            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#111827'),

              borderRadius: pw.BorderRadius.circular(28),
            ),

            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,

              children: [
                pw.Text(
                  'Executive Summary',

                  style: pw.TextStyle(
                    color: PdfColors.white,

                    fontSize: 24,

                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 18),

                pw.Text(
                  'This monthly report provides a complete overview of your financial activity including budget performance, savings behavior, financial health score, and AI-generated recommendations to improve your financial stability.',

                  style: pw.TextStyle(
                    color: PdfColors.white,

                    fontSize: 14,

                    lineSpacing: 4,
                  ),
                ),

                pw.SizedBox(height: 24),

                pw.Divider(color: PdfColors.white),

                pw.SizedBox(height: 18),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

                  children: [
                    pw.Text(
                      'Generated by Rupixa AI',

                      style: pw.TextStyle(
                        color: PdfColors.white,

                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),

                    pw.Text(
                      currentDate,

                      style: pw.TextStyle(color: PdfColors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final directory = await getTemporaryDirectory();

    final file = File('${directory.path}/monthly_report.pdf');

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// =====================================
  /// HERO STAT
  /// =====================================

  static pw.Widget _heroStat({required String title, required String value}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,

      children: [
        pw.Text(
          title,

          style: pw.TextStyle(color: PdfColors.white, fontSize: 11),
        ),

        pw.SizedBox(height: 6),

        pw.Text(
          value,

          style: pw.TextStyle(
            color: PdfColors.white,

            fontWeight: pw.FontWeight.bold,

            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// =====================================
  /// ANALYTICS CARD
  /// =====================================

  static pw.Widget _analyticsCard({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),

      decoration: pw.BoxDecoration(
        color: PdfColors.white,

        borderRadius: pw.BorderRadius.circular(20),

        border: pw.Border.all(color: PdfColors.grey300),
      ),

      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,

        children: [
          pw.Text(
            title,

            style: pw.TextStyle(fontSize: 13, color: PdfColors.grey700),
          ),

          pw.SizedBox(height: 10),

          pw.Text(
            value,

            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 6),

          pw.Text(
            subtitle,

            style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  /// =====================================
  /// INSIGHT TILE
  /// =====================================

  static pw.Widget _insightTile({
    required String title,
    required String description,
    required PdfColor color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),

      child: pw.Container(
        padding: const pw.EdgeInsets.all(20),

        decoration: pw.BoxDecoration(
          color: PdfColors.white,

          borderRadius: pw.BorderRadius.circular(20),

          border: pw.Border.all(color: PdfColors.grey300),
        ),

        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,

          children: [
            pw.Container(
              width: 12,
              height: 12,

              margin: const pw.EdgeInsets.only(top: 6),

              decoration: pw.BoxDecoration(
                color: color,

                shape: pw.BoxShape.circle,
              ),
            ),

            pw.SizedBox(width: 14),

            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,

                children: [
                  pw.Text(
                    title,

                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,

                      fontSize: 16,
                    ),
                  ),

                  pw.SizedBox(height: 8),

                  pw.Text(
                    description,

                    style: const pw.TextStyle(fontSize: 13, lineSpacing: 3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
