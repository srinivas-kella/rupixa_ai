import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/services/firestore_service.dart';
import '../../core/utils/category_helper.dart';
import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with TickerProviderStateMixin {
  static const Color primary = Color(0xFF6C63FF);

  static const Color secondary = Color(0xFF8B5CF6);

  static const Color accent = Color(0xFF00C6FF);

  final TextEditingController titleController = TextEditingController();

  final TextEditingController amountController = TextEditingController();

  final TextEditingController noteController = TextEditingController();

  String selectedCategory = CategoryHelper.categories.first;

  DateTime selectedDate = DateTime.now();

  bool isSaving = false;

  bool isRecurring = false;

  int selectedPriority = 1;

  late stt.SpeechToText speech;

  bool isListening = false;

  late AnimationController _micAnimationController;

  final List<double> quickAmounts = [100, 250, 500, 1000, 2500];

  @override
  void initState() {
    super.initState();

    speech = stt.SpeechToText();

    _micAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    titleController.dispose();

    amountController.dispose();

    noteController.dispose();

    speech.stop();

    _micAnimationController.dispose();

    super.dispose();
  }

  /// =========================================
  /// SUCCESS POPUP
  /// =========================================

  void showSuccessPopup() {
    showCupertinoDialog(
      context: context,

      builder: (context) => CupertinoAlertDialog(
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.green, Color(0xFF3DD598)],
                ),

                shape: BoxShape.circle,
              ),

              child: const Icon(
                CupertinoIcons.check_mark,

                color: Colors.white,

                size: 34,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              "Expense Added",

              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ],
        ),

        content: Padding(
          padding: const EdgeInsets.only(top: 10),

          child: Text(
            "Your expense has been saved successfully.",

            textAlign: TextAlign.center,

            style: GoogleFonts.poppins(height: 1.5),
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

  /// =========================================
  /// SPEECH
  /// =========================================

  Future<void> toggleListening() async {
    await HapticFeedback.lightImpact();

    if (!isListening) {
      final available = await speech.initialize();

      if (available) {
        setState(() {
          isListening = true;
        });

        _micAnimationController.repeat();

        speech.listen(
          onResult: (result) {
            titleController.text = result.recognizedWords;

            setState(() {});

            if (result.finalResult) {
              speech.stop();

              _micAnimationController.stop();

              setState(() {
                isListening = false;
              });
            }
          },
        );
      }
    } else {
      speech.stop();

      _micAnimationController.stop();

      setState(() {
        isListening = false;
      });
    }
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
  /// SAVE EXPENSE
  /// =========================================

  Future<void> saveExpense() async {
    await HapticFeedback.mediumImpact();

    final title = titleController.text.trim();

    final amount = double.tryParse(amountController.text.trim());

    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,

          backgroundColor: Colors.redAccent,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          content: Text(
            'Please enter valid expense details',

            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final expense = ExpenseModel(
        title: title,
        amount: amount,
        category: selectedCategory,
        date: selectedDate,
      );

      Provider.of<ExpenseProvider>(context, listen: false).addExpense(expense);

      await FirestoreService.addExpense(
        title: title,
        category: selectedCategory,
        amount: amount,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      showSuccessPopup();
    } catch (e) {
      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,

          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),

      appBar: AppBar(
        backgroundColor: Colors.transparent,

        elevation: 0,

        centerTitle: false,

        title: Text(
          "Add Expense",

          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,

            fontSize: 30,

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

            padding: EdgeInsets.fromLTRB(width * 0.05, 10, width * 0.05, 140),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                /// HEADER
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),

                  duration: const Duration(milliseconds: 600),

                  curve: Curves.easeOutCubic,

                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),

                      child: Opacity(opacity: value, child: child),
                    );
                  },

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        "Track Your Spending",

                        style: GoogleFonts.poppins(
                          fontSize: 34,

                          fontWeight: FontWeight.bold,

                          color: const Color(0xFF15192D),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Smart AI powered expense tracking.",

                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,

                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// LIVE PREVIEW CARD
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),

                  padding: const EdgeInsets.all(26),

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
                              color: Colors.white.withValues(alpha: 0.14),

                              shape: BoxShape.circle,
                            ),

                            child: Icon(
                              CategoryHelper.getCategoryIcon(selectedCategory),

                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      Text(
                        titleController.text.isEmpty
                            ? "Expense Title"
                            : titleController.text,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: GoogleFonts.poppins(
                          color: Colors.white,

                          fontSize: 26,

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

                          fontSize: 38,

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

                const SizedBox(height: 32),

                /// TITLE
                _buildGlassCard(
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

                      suffixIcon: GestureDetector(
                        onTap: toggleListening,

                        child: AnimatedBuilder(
                          animation: _micAnimationController,

                          builder: (context, child) {
                            return Transform.scale(
                              scale: isListening
                                  ? 1 + (_micAnimationController.value * 0.08)
                                  : 1,

                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),

                                margin: const EdgeInsets.all(10),

                                decoration: BoxDecoration(
                                  gradient: isListening
                                      ? const LinearGradient(
                                          colors: [
                                            Colors.redAccent,
                                            Colors.orange,
                                          ],
                                        )
                                      : LinearGradient(
                                          colors: [
                                            primary.withValues(alpha: 0.15),
                                            secondary.withValues(alpha: 0.10),
                                          ],
                                        ),

                                  shape: BoxShape.circle,
                                ),

                                child: Icon(
                                  isListening
                                      ? CupertinoIcons.mic_fill
                                      : CupertinoIcons.mic,

                                  color: isListening ? Colors.white : primary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                /// AMOUNT
                _buildGlassCard(
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
                _buildGlassCard(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedCategory,

                    decoration: const InputDecoration(border: InputBorder.none),

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

                                size: 20,
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

                  child: _buildGlassCard(
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.calendar, color: primary),

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

                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                /// NOTE FIELD
                _buildGlassCard(
                  child: TextField(
                    controller: noteController,

                    maxLines: 4,

                    style: GoogleFonts.poppins(),

                    decoration: InputDecoration(
                      border: InputBorder.none,

                      hintText: "Add note (optional)",

                      hintStyle: GoogleFonts.poppins(color: Colors.grey),

                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 70),

                        child: Icon(CupertinoIcons.doc_text, color: primary),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// RECURRING TOGGLE
                Container(
                  padding: const EdgeInsets.all(22),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFF8F9FF)],
                    ),

                    borderRadius: BorderRadius.circular(28),

                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.05),

                        blurRadius: 18,

                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primary.withValues(alpha: 0.16),
                              secondary.withValues(alpha: 0.08),
                            ],
                          ),

                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: const Icon(
                          CupertinoIcons.repeat,
                          color: primary,
                        ),
                      ),

                      const SizedBox(width: 18),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Recurring Expense",

                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,

                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "Automatically repeat every month",

                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade600,

                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      CupertinoSwitch(
                        value: isRecurring,

                        activeTrackColor: primary,

                        onChanged: (value) async {
                          await HapticFeedback.lightImpact();

                          setState(() {
                            isRecurring = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// PRIORITY
                Text(
                  "Expense Priority",

                  style: GoogleFonts.poppins(
                    fontSize: 18,

                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: List.generate(3, (index) {
                    final selected = selectedPriority == index;

                    final labels = ["Low", "Medium", "High"];

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index != 2 ? 12 : 0),

                        child: GestureDetector(
                          onTap: () async {
                            await HapticFeedback.lightImpact();

                            setState(() {
                              selectedPriority = index;
                            });
                          },

                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),

                            padding: const EdgeInsets.symmetric(vertical: 16),

                            decoration: BoxDecoration(
                              gradient: selected
                                  ? const LinearGradient(
                                      colors: [primary, secondary],
                                    )
                                  : const LinearGradient(
                                      colors: [Colors.white, Color(0xFFF8F9FF)],
                                    ),

                              borderRadius: BorderRadius.circular(20),

                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: primary.withValues(alpha: 0.25),

                                        blurRadius: 18,

                                        offset: const Offset(0, 10),
                                      ),
                                    ]
                                  : [],
                            ),

                            child: Center(
                              child: Text(
                                labels[index],

                                style: GoogleFonts.poppins(
                                  color: selected
                                      ? Colors.white
                                      : Colors.black87,

                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 40),

                /// SAVE BUTTON
                GestureDetector(
                  onTap: isSaving ? null : saveExpense,

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
                                  "Save Expense",

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

                const SizedBox(height: 26),

                /// AI TIP
                Container(
                  padding: const EdgeInsets.all(22),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEFF3FF), Color(0xFFE8EAFF)],
                    ),

                    borderRadius: BorderRadius.circular(30),

                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.06),

                        blurRadius: 18,

                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [primary, secondary],
                          ),

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: const Icon(
                          CupertinoIcons.sparkles,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 18),

                      Expanded(
                        child: Text(
                          "AI Tip: Tracking expenses daily improves monthly financial predictions by 73%.",

                          style: GoogleFonts.poppins(
                            fontSize: 14,

                            height: 1.5,

                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// =========================================
  /// PREVIEW CHIP
  /// =========================================

  Widget _previewChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),

        borderRadius: BorderRadius.circular(16),
      ),

      child: Text(
        text,

        style: GoogleFonts.poppins(
          color: Colors.white,

          fontSize: 12,

          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// =========================================
  /// GLASS CARD
  /// =========================================

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),

      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),

          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.95),
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
