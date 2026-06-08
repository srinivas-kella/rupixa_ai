import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:rupixa_ai/core/services/bill_firestore_service.dart';
import 'package:rupixa_ai/core/services/notification_service.dart';

import '../../models/bill_model.dart';
import '../../providers/bill_provider.dart';

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen>
    with TickerProviderStateMixin {
  static const Color primary = Color(0xFF5B67FF);

  static const Color secondary = Color(0xFF7B61FF);

  static const Color accent = Color(0xFF00C6FF);

  final titleController = TextEditingController();

  final amountController = TextEditingController();

  final notesController = TextEditingController();

  late stt.SpeechToText speech;

  bool isListening = false;

  bool isSaving = false;

  bool showAllCategories = false;

  DateTime selectedDate = DateTime.now();

  DateTime reminderDate = DateTime.now();

  String selectedCategory = 'Electricity';

  late AnimationController _animationController;

  final List<double> quickAmounts = [500, 1000, 2500, 5000, 10000];

  final List<Map<String, dynamic>> categories = [
    {
      "title": "Electricity",
      "icon": CupertinoIcons.bolt_fill,
      "color": Colors.orange,
    },

    {"title": "Internet", "icon": CupertinoIcons.wifi, "color": Colors.blue},

    {"title": "Water", "icon": CupertinoIcons.drop_fill, "color": Colors.cyan},

    {"title": "Rent", "icon": CupertinoIcons.house_fill, "color": Colors.green},

    {
      "title": "EMI",
      "icon": CupertinoIcons.creditcard_fill,
      "color": Colors.purple,
    },

    {
      "title": "Subscription",
      "icon": CupertinoIcons.play_rectangle_fill,
      "color": Colors.redAccent,
    },

    {
      "title": "Insurance",
      "icon": CupertinoIcons.shield_fill,
      "color": Colors.indigo,
    },

    {"title": "Phone", "icon": CupertinoIcons.phone_fill, "color": Colors.teal},

    {
      "title": "Gas",
      "icon": CupertinoIcons.flame_fill,
      "color": Colors.deepOrange,
    },

    {
      "title": "Credit Card",
      "icon": CupertinoIcons.creditcard,
      "color": Colors.pink,
    },

    {
      "title": "Streaming",
      "icon": CupertinoIcons.tv_fill,
      "color": Colors.deepPurple,
    },

    {"title": "Gym", "icon": CupertinoIcons.heart_fill, "color": Colors.red},

    {
      "title": "Education",
      "icon": CupertinoIcons.book_fill,
      "color": Colors.blueAccent,
    },

    {"title": "Travel", "icon": CupertinoIcons.airplane, "color": Colors.amber},

    {
      "title": "Other",
      "icon": CupertinoIcons.square_grid_2x2_fill,
      "color": Colors.grey,
    },
  ];

  @override
  void initState() {
    super.initState();

    speech = stt.SpeechToText();

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

    notesController.dispose();

    speech.stop();

    _animationController.dispose();

    super.dispose();
  }

  /// =========================================
  /// SPEECH TO TEXT
  /// =========================================

  Future<void> toggleListening() async {
    await HapticFeedback.lightImpact();

    if (!isListening) {
      final available = await speech.initialize();

      if (available) {
        setState(() {
          isListening = true;
        });

        speech.listen(
          onResult: (result) {
            setState(() {
              titleController.text = result.recognizedWords;
            });

            if (result.finalResult) {
              speech.stop();

              setState(() {
                isListening = false;
              });
            }
          },
        );
      }
    } else {
      speech.stop();

      setState(() {
        isListening = false;
      });
    }
  }

  /// =========================================
  /// DATE PICKERS
  /// =========================================

  Future<void> pickDueDate() async {
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

  Future<void> pickReminderDate() async {
    await HapticFeedback.lightImpact();

    final pickedDate = await showDatePicker(
      context: context,

      initialDate: reminderDate,

      firstDate: DateTime.now(),

      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        reminderDate = pickedDate;
      });
    }
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

            const SizedBox(height: 18),

            Text(
              "Bill Added",

              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ],
        ),

        content: Padding(
          padding: const EdgeInsets.only(top: 10),

          child: Text(
            "Your bill reminder has been added successfully.",

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

  /// =========================================
  /// SAVE BILL
  /// =========================================

  Future<void> saveBill() async {
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
            'Please enter valid bill details',

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
      final bill = BillModel(
        title: title,

        amount: amount,

        category: selectedCategory,

        dueDate: selectedDate,

        reminderDate: reminderDate,
      );

      await Provider.of<BillProvider>(context, listen: false).addBill(bill);

      final scheduledReminder = DateTime.now().add(const Duration(minutes: 1));

      // await NotificationService.scheduleBillReminder(
      //   id: bill.hashCode,
      //   title: 'Bill Reminder',
      //   body: '${bill.title} is due soon',
      //   scheduledDate: scheduledReminder,
      // );

      await NotificationService.scheduleBillReminder(
        id: bill.hashCode,
        title: 'Bill Reminder',
        body: '${bill.title} is due soon',
        scheduledDate: scheduledReminder,
      );

      await NotificationService.checkPendingNotifications();

      await BillFirestoreService.addBill(
        title: bill.title,

        category: bill.category,

        amount: bill.amount,

        dueDate: bill.dueDate,
      );

      await NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,

        title: 'Bill Reminder',

        body: '${bill.title} bill added successfully',
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final selectedItem = categories.firstWhere(
      (item) => item['title'] == selectedCategory,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,

        elevation: 0,

        centerTitle: false,

        title: Text(
          "Add Bill",

          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,

            color: colorScheme.onSurface,

            fontSize: 30,
          ),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,

            end: Alignment.bottomCenter,

            colors: isDark
                ? const [
                    Color(0xFF0E1320),
                    Color(0xFF101623),
                    Color(0xFF171C2C),
                  ]
                : const [
                    Color(0xFFF8FAFF),
                    Color(0xFFF1F4FF),
                    Color(0xFFF7F8FF),
                  ],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),

            child: FadeTransition(
              opacity: _animationController,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  /// HEADER
                  Text(
                    "Manage Bill Payments",

                    style: GoogleFonts.poppins(
                      color: colorScheme.onSurface,
                      fontSize: 34,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Track reminders and avoid late payments beautifully.",

                    style: GoogleFonts.poppins(
                      color: colorScheme.onSurfaceVariant,

                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// PREVIEW CARD
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),

                    padding: const EdgeInsets.all(26),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,

                        end: Alignment.bottomRight,

                        colors: [primary, secondary, accent],
                      ),

                      borderRadius: BorderRadius.circular(34),

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
                            Text(
                              "Bill Preview",

                              style: GoogleFonts.poppins(color: Colors.white70),
                            ),

                            Container(
                              padding: const EdgeInsets.all(14),

                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),

                                shape: BoxShape.circle,
                              ),

                              child: Icon(
                                selectedItem['icon'],

                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        Text(
                          titleController.text.isEmpty
                              ? "Bill Title"
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

                            fontSize: 38,

                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 22),

                        Wrap(
                          spacing: 10,

                          runSpacing: 10,

                          children: [
                            _previewChip(selectedCategory),

                            _previewChip(
                              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// BILL TITLE
                  _buildGlassCard(
                    child: TextField(
                      controller: titleController,

                      onChanged: (_) {
                        setState(() {});
                      },

                      style: GoogleFonts.poppins(),

                      decoration: InputDecoration(
                        border: InputBorder.none,

                        hintText: "Bill Title",

                        hintStyle: GoogleFonts.poppins(color: Colors.grey),

                        prefixIcon: const Icon(
                          CupertinoIcons.doc_text_fill,

                          color: primary,
                        ),

                        suffixIcon: GestureDetector(
                          onTap: toggleListening,

                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),

                            margin: const EdgeInsets.all(10),

                            decoration: BoxDecoration(
                              color: isListening
                                  ? Colors.red.withValues(alpha: 0.12)
                                  : primary.withValues(alpha: 0.10),

                              shape: BoxShape.circle,
                            ),

                            child: Icon(
                              isListening
                                  ? CupertinoIcons.mic_fill
                                  : CupertinoIcons.mic,

                              color: isListening ? Colors.red : primary,
                            ),
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

                      style: GoogleFonts.poppins(),

                      decoration: InputDecoration(
                        border: InputBorder.none,

                        hintText: "Bill Amount",

                        hintStyle: GoogleFonts.poppins(color: Colors.grey),

                        prefixIcon: const Icon(
                          CupertinoIcons.money_dollar_circle_fill,

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

                  const SizedBox(height: 28),

                  /// CATEGORY TITLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        "Bill Category",

                        style: GoogleFonts.poppins(
                          fontSize: 18,

                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      GestureDetector(
                        onTap: () async {
                          await HapticFeedback.lightImpact();

                          setState(() {
                            showAllCategories = !showAllCategories;
                          });
                        },

                        child: AnimatedRotation(
                          duration: const Duration(milliseconds: 300),

                          turns: showAllCategories ? 0.5 : 0,

                          child: Container(
                            padding: const EdgeInsets.all(10),

                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primary.withValues(alpha: 0.12),
                                  secondary.withValues(alpha: 0.08),
                                ],
                              ),

                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: const Icon(
                              CupertinoIcons.chevron_down,

                              color: primary,

                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// PREMIUM CATEGORY WRAP
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),

                    curve: Curves.easeOutCubic,

                    child: Wrap(
                      spacing: 14,
                      runSpacing: 14,

                      children:
                          (showAllCategories ? categories : categories.take(6))
                              .map((item) {
                                final bool selected =
                                    selectedCategory == item['title'];

                                return GestureDetector(
                                  onTap: () async {
                                    await HapticFeedback.lightImpact();

                                    setState(() {
                                      selectedCategory = item['title'];
                                    });
                                  },

                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),

                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,

                                      vertical: 14,
                                    ),

                                    decoration: BoxDecoration(
                                      gradient: selected
                                          ? const LinearGradient(
                                              begin: Alignment.topLeft,

                                              end: Alignment.bottomRight,

                                              colors: [primary, secondary],
                                            )
                                          : LinearGradient(
                                              colors: [
                                                Colors.white,
                                                const Color(0xFFF8F9FF),
                                              ],
                                            ),

                                      borderRadius: BorderRadius.circular(24),

                                      border: Border.all(
                                        color: selected
                                            ? Colors.transparent
                                            : Colors.white,
                                      ),

                                      boxShadow: selected
                                          ? [
                                              BoxShadow(
                                                color: primary.withValues(
                                                  alpha: 0.25,
                                                ),

                                                blurRadius: 18,

                                                offset: const Offset(0, 10),
                                              ),
                                            ]
                                          : [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.03,
                                                ),

                                                blurRadius: 10,

                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                    ),

                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,

                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),

                                          decoration: BoxDecoration(
                                            color: selected
                                                ? Colors.white.withValues(
                                                    alpha: 0.18,
                                                  )
                                                : item['color'].withOpacity(
                                                    0.10,
                                                  ),

                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),

                                          child: Icon(
                                            item['icon'],

                                            color: selected
                                                ? Colors.white
                                                : item['color'],

                                            size: 20,
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Text(
                                          item['title'],

                                          style: GoogleFonts.poppins(
                                            color: selected
                                                ? Colors.white
                                                : Colors.black87,

                                            fontWeight: FontWeight.w600,

                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                    ),
                  ),

                  const SizedBox(height: 26),

                  /// DUE DATE
                  GestureDetector(
                    onTap: pickDueDate,

                    child: _buildGlassCard(
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.calendar, color: primary),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  "Due Date",

                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600,

                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",

                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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

                  const SizedBox(height: 18),

                  /// REMINDER DATE
                  GestureDetector(
                    onTap: pickReminderDate,

                    child: _buildGlassCard(
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.bell_fill, color: primary),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  "Reminder Date",

                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600,

                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  "${reminderDate.day}/${reminderDate.month}/${reminderDate.year}",

                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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

                  const SizedBox(height: 18),

                  /// NOTES
                  _buildGlassCard(
                    child: TextField(
                      controller: notesController,

                      maxLines: 4,

                      style: GoogleFonts.poppins(),

                      decoration: InputDecoration(
                        border: InputBorder.none,

                        hintText: "Notes...",

                        hintStyle: GoogleFonts.poppins(color: Colors.grey),

                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 70),

                          child: Icon(
                            CupertinoIcons.doc_plaintext,

                            color: primary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// SAVE BUTTON
                  GestureDetector(
                    onTap: isSaving ? null : saveBill,

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
                                    "Save Bill",

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

                  const SizedBox(height: 28),

                  /// SMART INFO CARD
                  Container(
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, const Color(0xFFF7F8FF)],
                      ),

                      borderRadius: BorderRadius.circular(26),

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
                            color: primary.withValues(alpha: 0.1),

                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: const Icon(
                            CupertinoIcons.sparkles,

                            color: primary,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Text(
                            "Enable reminders to never miss your bill payments and avoid penalties.",

                            style: GoogleFonts.poppins(
                              fontSize: 14,

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

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),

      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),

          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),

            borderRadius: BorderRadius.circular(26),

            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),

                blurRadius: 18,

                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: child,
        ),
      ),
    );
  }
}
