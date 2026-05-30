import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/utils/category_helper.dart';
import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';

class EditExpenseScreen extends StatefulWidget {
  final ExpenseModel expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen>
    with TickerProviderStateMixin {
  static const Color primary = Color(0xFF6C63FF);

  static const Color secondary = Color(0xFF8B5CF6);

  static const Color accent = Color(0xFF00C6FF);

  late TextEditingController titleController;

  late TextEditingController amountController;

  late TextEditingController noteController;

  late String selectedCategory;

  late DateTime selectedDate;

  bool isSaving = false;

  late AnimationController _animationController;

  final List<double> quickAmounts = [100, 250, 500, 1000, 2500];

  @override
  void initState() {
    super.initState();

    /// AUTO POPULATE DATA

    titleController = TextEditingController(text: widget.expense.title);

    amountController = TextEditingController(
      text: widget.expense.amount.toString(),
    );

    noteController = TextEditingController();

    selectedCategory = widget.expense.category;

    selectedDate = widget.expense.date;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    titleController.dispose();

    amountController.dispose();

    noteController.dispose();

    _animationController.dispose();

    super.dispose();
  }

  /// =========================================
  /// DATE PICKER
  /// =========================================

  Future<void> pickDate() async {
    await HapticFeedback.lightImpact();

    final pickedDate = await showDatePicker(
      context: context,

      initialDate: selectedDate,

      firstDate: DateTime(2020),

      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  /// =========================================
  /// UPDATE EXPENSE
  /// =========================================

  Future<void> updateExpense() async {
    await HapticFeedback.mediumImpact();

    final amount = double.tryParse(amountController.text);

    if (titleController.text.trim().isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,

          backgroundColor: Colors.redAccent,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          content: Text(
            "Please enter valid details",

            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    final updatedExpense = ExpenseModel(
      title: titleController.text.trim(),

      amount: amount,

      category: selectedCategory,

      date: selectedDate,
    );

    if (!mounted) return;

    Provider.of<ExpenseProvider>(
      context,
      listen: false,
    ).updateExpense(widget.expense, updatedExpense);

    setState(() {
      isSaving = false;
    });

    showSuccessDialog();
  }

  /// =========================================
  /// SUCCESS
  /// =========================================

  void showSuccessDialog() {
    showCupertinoDialog(
      context: context,

      builder: (context) => CupertinoAlertDialog(
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),

              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [primary, secondary]),

                shape: BoxShape.circle,
              ),

              child: const Icon(
                CupertinoIcons.check_mark,

                color: Colors.white,

                size: 34,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Expense Updated",

              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ],
        ),

        content: Padding(
          padding: const EdgeInsets.only(top: 10),

          child: Text(
            "Your expense has been updated successfully.",

            textAlign: TextAlign.center,

            style: GoogleFonts.poppins(),
          ),
        ),

        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);

              Navigator.pop(context);
            },

            child: Text(
              "Done",

              style: GoogleFonts.poppins(
                color: primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final categoryColor = CategoryHelper.getCategoryColor(selectedCategory);

    final categoryIcon = CategoryHelper.getCategoryIcon(selectedCategory);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),

      appBar: AppBar(
        backgroundColor: Colors.transparent,

        elevation: 0,

        centerTitle: false,

        title: Text(
          "Edit Expense",

          style: GoogleFonts.poppins(
            fontSize: 30,

            fontWeight: FontWeight.bold,

            color: const Color(0xFF15192D),
          ),
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,

            end: Alignment.bottomCenter,

            colors: [Color(0xFFF8FAFF), Color(0xFFF1F4FF), Color(0xFFF7F8FF)],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: EdgeInsets.fromLTRB(width * 0.05, 10, width * 0.05, 120),

            child: FadeTransition(
              opacity: _animationController,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  /// HEADER
                  Text(
                    "Update Your Expense",

                    style: GoogleFonts.poppins(
                      fontSize: 34,

                      fontWeight: FontWeight.bold,

                      color: const Color(0xFF15192D),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Edit and manage your financial records beautifully.",

                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,

                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// LIVE PREVIEW
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),

                    padding: const EdgeInsets.all(28),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,

                        end: Alignment.bottomRight,

                        colors: [primary, secondary, accent],
                      ),

                      borderRadius: BorderRadius.circular(36),

                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.30),

                          blurRadius: 30,

                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Text(
                              "Expense Preview",

                              style: GoogleFonts.poppins(
                                color: Colors.white70,

                                fontSize: 14,
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.all(14),

                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),

                                shape: BoxShape.circle,
                              ),

                              child: Icon(categoryIcon, color: Colors.white),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        Text(
                          titleController.text.isEmpty
                              ? "Expense Title"
                              : titleController.text,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: GoogleFonts.poppins(
                            color: Colors.white,

                            fontSize: 28,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          amountController.text.isEmpty
                              ? "₹ 0"
                              : "₹ ${amountController.text}",

                          style: GoogleFonts.poppins(
                            color: Colors.white,

                            fontSize: 40,

                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            _previewChip(selectedCategory),

                            const SizedBox(width: 12),

                            _previewChip(
                              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// TITLE
                  _glassCard(
                    child: TextField(
                      controller: titleController,

                      onChanged: (_) {
                        setState(() {});
                      },

                      style: GoogleFonts.poppins(),

                      decoration: InputDecoration(
                        border: InputBorder.none,

                        hintText: "Expense Title",

                        hintStyle: GoogleFonts.poppins(color: Colors.grey),

                        prefixIcon: const Icon(
                          CupertinoIcons.textformat,

                          color: primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  /// AMOUNT
                  _glassCard(
                    child: TextField(
                      controller: amountController,

                      onChanged: (_) {
                        setState(() {});
                      },

                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      style: GoogleFonts.poppins(
                        fontSize: 18,

                        fontWeight: FontWeight.w600,
                      ),

                      decoration: InputDecoration(
                        border: InputBorder.none,

                        hintText: "Amount",

                        hintStyle: GoogleFonts.poppins(color: Colors.grey),

                        prefixIcon: const Icon(
                          CupertinoIcons.money_dollar_circle,

                          color: primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// QUICK AMOUNTS
                  SizedBox(
                    height: 52,

                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,

                      itemBuilder: (context, index) {
                        final amount = quickAmounts[index];

                        return GestureDetector(
                          onTap: () async {
                            await HapticFeedback.lightImpact();

                            amountController.text = amount.toStringAsFixed(0);

                            setState(() {});
                          },

                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,

                              vertical: 12,
                            ),

                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.white, Color(0xFFF7F8FF)],
                              ),

                              borderRadius: BorderRadius.circular(18),

                              boxShadow: [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.05),

                                  blurRadius: 16,

                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),

                            child: Center(
                              child: Text(
                                "₹ ${amount.toInt()}",

                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },

                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),

                      itemCount: quickAmounts.length,
                    ),
                  ),

                  const SizedBox(height: 22),

                  /// CATEGORY
                  _glassCard(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedCategory,

                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),

                      icon: const Icon(CupertinoIcons.chevron_down),

                      style: GoogleFonts.poppins(color: Colors.black),

                      items: CategoryHelper.categories.map((category) {
                        return DropdownMenuItem(
                          value: category,

                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),

                                decoration: BoxDecoration(
                                  color: CategoryHelper.getCategoryColor(
                                    category,
                                  ).withValues(alpha: 0.10),

                                  borderRadius: BorderRadius.circular(14),
                                ),

                                child: Icon(
                                  CategoryHelper.getCategoryIcon(category),

                                  color: CategoryHelper.getCategoryColor(
                                    category,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 14),

                              Text(category),
                            ],
                          ),
                        );
                      }).toList(),

                      onChanged: (value) async {
                        if (value == null) {
                          return;
                        }

                        await HapticFeedback.lightImpact();

                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 22),

                  /// DATE
                  GestureDetector(
                    onTap: pickDate,

                    child: _glassCard(
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.calendar, color: categoryColor),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Text(
                              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",

                              style: GoogleFonts.poppins(
                                fontSize: 16,

                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          Icon(
                            CupertinoIcons.chevron_right,

                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  /// NOTES
                  _glassCard(
                    child: TextField(
                      controller: noteController,

                      maxLines: 4,

                      style: GoogleFonts.poppins(),

                      decoration: InputDecoration(
                        border: InputBorder.none,

                        hintText: "Add notes...",

                        hintStyle: GoogleFonts.poppins(color: Colors.grey),

                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 70),

                          child: Icon(CupertinoIcons.doc_text, color: primary),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// UPDATE BUTTON
                  GestureDetector(
                    onTap: isSaving ? null : updateExpense,

                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),

                      height: 68,

                      width: double.infinity,

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,

                          end: Alignment.bottomRight,

                          colors: [primary, secondary, accent],
                        ),

                        borderRadius: BorderRadius.circular(28),

                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.35),

                            blurRadius: 30,

                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),

                      child: Center(
                        child: isSaving
                            ? const CupertinoActivityIndicator(
                                color: Colors.white,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  const Icon(
                                    CupertinoIcons.check_mark,

                                    color: Colors.white,
                                  ),

                                  const SizedBox(width: 12),

                                  Text(
                                    "Update Expense",

                                    style: GoogleFonts.poppins(
                                      color: Colors.white,

                                      fontWeight: FontWeight.w700,

                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// =========================================
  /// CHIP
  /// =========================================

  Widget _previewChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),

        borderRadius: BorderRadius.circular(16),
      ),

      child: Text(
        text,

        style: GoogleFonts.poppins(
          color: Colors.white,

          fontWeight: FontWeight.w600,

          fontSize: 12,
        ),
      ),
    );
  }

  /// =========================================
  /// GLASS CARD
  /// =========================================

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),

      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),

          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.96),
                Colors.white.withValues(alpha: 0.88),
              ],
            ),

            borderRadius: BorderRadius.circular(28),

            border: Border.all(color: Colors.white.withValues(alpha: 0.7)),

            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.05),

                blurRadius: 18,

                offset: const Offset(0, 10),
              ),
            ],
          ),

          child: child,
        ),
      ),
    );
  }
}
