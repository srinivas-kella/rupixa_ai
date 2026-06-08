import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/bill_provider.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen>
    with TickerProviderStateMixin {
  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Electricity':
        return CupertinoIcons.bolt_fill;
      case 'Internet':
        return CupertinoIcons.wifi;
      case 'Water':
        return CupertinoIcons.drop_fill;
      case 'Rent':
        return CupertinoIcons.house_fill;
      case 'EMI':
        return CupertinoIcons.creditcard_fill;
      case 'Subscription':
        return CupertinoIcons.play_rectangle_fill;
      case 'Insurance':
        return CupertinoIcons.shield_fill;
      case 'Phone':
        return CupertinoIcons.phone_fill;
      case 'Gas':
        return CupertinoIcons.flame_fill;
      case 'Credit Card':
        return CupertinoIcons.creditcard;
      case 'Streaming':
        return CupertinoIcons.tv_fill;
      case 'Gym':
        return CupertinoIcons.heart_fill;
      case 'Education':
        return CupertinoIcons.book_fill;
      case 'Travel':
        return CupertinoIcons.airplane;
      default:
        return CupertinoIcons.square_grid_2x2_fill;
    }
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'Electricity':
        return Colors.orange;
      case 'Internet':
        return Colors.blue;
      case 'Water':
        return Colors.cyan;
      case 'Rent':
        return Colors.green;
      case 'EMI':
        return Colors.purple;
      case 'Subscription':
        return Colors.redAccent;
      case 'Insurance':
        return Colors.indigo;
      case 'Phone':
        return Colors.teal;
      case 'Gas':
        return Colors.deepOrange;
      case 'Credit Card':
        return Colors.pink;
      case 'Streaming':
        return Colors.deepPurple;
      case 'Gym':
        return Colors.red;
      case 'Education':
        return Colors.blueAccent;
      case 'Travel':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  static const Color primary = Color(0xFF5B67FF);

  static const Color secondary = Color(0xFF7B61FF);

  static const Color accent = Color(0xFF00C6FF);

  final TextEditingController _searchController = TextEditingController();

  final ValueNotifier<String> _searchNotifier = ValueNotifier("");

  String selectedFilter = "All";

  final List<String> filters = [
    "All",
    "Pending",
    "Paid",
    "Upcoming",
    "Overdue",
  ];

  late ScrollController _scrollController;

  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1,
    );

    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;

      if (direction == ScrollDirection.reverse) {
        _fabAnimationController.reverse();
      }

      if (direction == ScrollDirection.forward) {
        _fabAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();

    _searchNotifier.dispose();

    _scrollController.dispose();

    _fabAnimationController.dispose();

    super.dispose();
  }

  /// =========================================
  /// DELETE CONFIRMATION
  /// =========================================

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showCupertinoDialog<bool>(
          context: context,

          builder: (context) => CupertinoAlertDialog(
            title: Text(
              "Delete Bill",

              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),

            content: Padding(
              padding: const EdgeInsets.only(top: 10),

              child: Text(
                "Are you sure you want to permanently delete this bill?",

                style: GoogleFonts.poppins(),
              ),
            ),

            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, false),

                child: Text(
                  "Cancel",

                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),

              CupertinoDialogAction(
                isDestructiveAction: true,

                onPressed: () => Navigator.pop(context, true),

                child: Text(
                  "Delete",

                  style: GoogleFonts.poppins(
                    color: Colors.red,

                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// =========================================
  /// STATUS CONFIRMATION
  /// =========================================

  Future<bool> _showStatusConfirmation({required bool isPaid}) async {
    return await showCupertinoDialog<bool>(
          context: context,

          builder: (context) => CupertinoAlertDialog(
            title: Text(
              isPaid ? "Mark Pending" : "Mark Paid",

              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),

            content: Padding(
              padding: const EdgeInsets.only(top: 10),

              child: Text(
                isPaid
                    ? "Move this bill back to pending?"
                    : "Confirm this bill as paid?",

                style: GoogleFonts.poppins(),
              ),
            ),

            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, false),

                child: Text(
                  "Cancel",

                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),

              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, true),

                child: Text(
                  "Confirm",

                  style: GoogleFonts.poppins(
                    color: primary,

                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// =========================================
  /// PREVIEW SHEET
  /// =========================================

  void _showBillPreview(BuildContext context, dynamic bill, int index) {
    final bool isPaid = bill.isPaid;

    final bool isOverdue = !isPaid && bill.dueDate.isBefore(DateTime.now());

    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.transparent,

      isScrollControlled: true,

      builder: (_) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),

          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 350),

            tween: Tween(begin: 0.92, end: 1.0),

            curve: Curves.easeOutCubic,

            builder: (context, value, child) {
              return Transform.scale(
                scale: value.toDouble(),

                child: Container(
                  margin: const EdgeInsets.all(14),

                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,

                      end: Alignment.bottomRight,

                      colors: [Colors.white, Color(0xFFF8F9FF)],
                    ),

                    borderRadius: BorderRadius.circular(36),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),

                        blurRadius: 30,

                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Container(
                        width: 50,

                        height: 5,

                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,

                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      const SizedBox(height: 28),

                      Container(
                        padding: const EdgeInsets.all(24),

                        decoration: BoxDecoration(
                          color: isPaid
                              ? Colors.green.withValues(alpha: 0.12)
                              : isOverdue
                              ? Colors.red.withValues(alpha: 0.12)
                              : getCategoryColor(
                                  bill.category,
                                ).withValues(alpha: 0.12),

                          borderRadius: BorderRadius.circular(30),
                        ),

                        child: Icon(
                          isPaid
                              ? CupertinoIcons.check_mark_circled_solid
                              : isOverdue
                              ? CupertinoIcons.exclamationmark_triangle_fill
                              : getCategoryIcon(bill.category),

                          color: isPaid
                              ? Colors.green
                              : isOverdue
                              ? Colors.redAccent
                              : getCategoryColor(bill.category),

                          size: 42,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        bill.title,

                        textAlign: TextAlign.center,

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                        style: GoogleFonts.poppins(
                          fontSize: 26,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),

                        decoration: BoxDecoration(
                          color: isPaid
                              ? Colors.green.withValues(alpha: 0.10)
                              : isOverdue
                              ? Colors.red.withValues(alpha: 0.10)
                              : primary.withValues(alpha: 0.10),

                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: Text(
                          isPaid
                              ? "Paid"
                              : isOverdue
                              ? "Overdue"
                              : "Pending",

                          style: GoogleFonts.poppins(
                            color: isPaid
                                ? Colors.green
                                : isOverdue
                                ? Colors.redAccent
                                : primary,

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        "₹ ${bill.amount.toStringAsFixed(0)}",

                        style: GoogleFonts.poppins(
                          fontSize: 42,

                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        "Due: ${bill.dueDate.day}/${bill.dueDate.month}/${bill.dueDate.year}",

                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,

                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 32),

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final confirm = await _showStatusConfirmation(
                                  isPaid: isPaid,
                                );

                                if (!confirm) {
                                  return;
                                }

                                await HapticFeedback.mediumImpact();

                                Provider.of<BillProvider>(
                                  context,
                                  listen: false,
                                ).toggleBillStatus(index);

                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },

                              child: _actionButton(
                                title: isPaid ? "Mark Pending" : "Mark Paid",

                                icon: isPaid
                                    ? CupertinoIcons.arrow_uturn_left
                                    : CupertinoIcons.check_mark,

                                gradient: const [primary, secondary],
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final confirm = await _showDeleteConfirmation(
                                  context,
                                );

                                if (!confirm) {
                                  return;
                                }

                                await HapticFeedback.mediumImpact();

                                Provider.of<BillProvider>(
                                  context,
                                  listen: false,
                                ).removeBill(index);

                                if (context.mounted) {
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,

                                      backgroundColor: Colors.black87,

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),

                                      content: Text(
                                        "Bill deleted successfully",

                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },

                              child: _outlineActionButton(
                                title: "Delete",

                                icon: CupertinoIcons.delete,

                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final billProvider = Provider.of<BillProvider>(context);

    final allBills = billProvider.bills;

    final pendingBills = allBills.where((e) => !e.isPaid).length;

    final paidBills = allBills.where((e) => e.isPaid).length;

    final totalAmount = allBills.fold(
      0.0,
      (previousValue, element) => previousValue + element.amount,
    );

    final dueToday = allBills.where((bill) {
      final now = DateTime.now();

      return bill.dueDate.day == now.day &&
          bill.dueDate.month == now.month &&
          bill.dueDate.year == now.year &&
          !bill.isPaid;
    }).toList();

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // appBar: AppBar(
      //   toolbarHeight: 80,

      //   elevation: 0,

      //   backgroundColor: Colors.white.withOpacity(0.75),

      //   surfaceTintColor: Colors.transparent,

      //   scrolledUnderElevation: 0,

      //   flexibleSpace: ClipRect(
      //     child: BackdropFilter(
      //       filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),

      //       child: Container(color: Colors.white.withOpacity(0.15)),
      //     ),
      //   ),

      //   title: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,

      //     children: [
      //       Text(
      //         "Bills",

      //         style: GoogleFonts.poppins(
      //           fontSize: 30,

      //           fontWeight: FontWeight.w700,

      //           color: Colors.black,
      //         ),
      //       ),

      //       Text(
      //         "Manage your payments",

      //         style: GoogleFonts.poppins(
      //           color: Colors.grey.shade600,

      //           fontSize: 13,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      body: ValueListenableBuilder(
        valueListenable: _searchNotifier,

        builder: (context, searchQuery, _) {
          final bills = allBills.where((bill) {
            final title = bill.title.toLowerCase();

            final matchesSearch = title.contains(searchQuery.toLowerCase());

            final now = DateTime.now();

            final isOverdue = !bill.isPaid && bill.dueDate.isBefore(now);

            final isUpcoming = !bill.isPaid && bill.dueDate.isAfter(now);

            final matchesFilter = selectedFilter == "All"
                ? true
                : selectedFilter == "Paid"
                ? bill.isPaid
                : selectedFilter == "Pending"
                ? !bill.isPaid
                : selectedFilter == "Upcoming"
                ? isUpcoming
                : isOverdue;

            return matchesSearch && matchesFilter;
          }).toList();

          return CustomScrollView(
            controller: _scrollController,

            physics: const BouncingScrollPhysics(),

            slivers: [
              /// =========================================
              /// STICKY PREMIUM IOS APPBAR
              /// =========================================
              SliverAppBar(
                pinned: true,

                floating: false,

                snap: false,

                elevation: 0,

                expandedHeight: 110,

                backgroundColor: colorScheme.surface.withValues(alpha: 0.82),

                surfaceTintColor: Colors.transparent,

                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),

                    child: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(left: 20, bottom: 18),

                      title: Column(
                        mainAxisSize: MainAxisSize.min,

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Bills",

                            style: GoogleFonts.poppins(
                              fontSize: 28,

                              fontWeight: FontWeight.w700,

                              color: colorScheme.onSurface,
                            ),
                          ),

                          Text(
                            "Manage your payments",

                            style: GoogleFonts.poppins(
                              color: colorScheme.onSurfaceVariant,

                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /// =========================================
              /// BODY
              /// =========================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 180),

                  child: Column(
                    children: [
                      /// SEARCH
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 450),

                        tween: Tween(begin: 20.0, end: 0.0),

                        curve: Curves.easeOutCubic,

                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, value.toDouble()),

                            child: child,
                          );
                        },

                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,

                            borderRadius: BorderRadius.circular(26),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.18 : 0.04,
                                ),

                                blurRadius: 16,

                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),

                          child: TextField(
                            controller: _searchController,

                            style: GoogleFonts.poppins(
                              color: colorScheme.onSurface,
                            ),

                            onChanged: (value) {
                              _searchNotifier.value = value;
                            },

                            decoration: InputDecoration(
                              border: InputBorder.none,

                              prefixIcon: const Icon(
                                CupertinoIcons.search,

                                color: primary,
                              ),

                              hintText: "Search bills...",

                              hintStyle: GoogleFonts.poppins(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      /// COMPACT STATUS CARDS
                      Row(
                        children: [
                          Expanded(
                            child: _compactStatCard(
                              title: "Pending",

                              value: pendingBills.toString(),

                              icon: CupertinoIcons.clock_fill,

                              gradient: const [
                                Color(0xFFFF9966),
                                Color(0xFFFF5E62),
                              ],
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: _compactStatCard(
                              title: "Paid",

                              value: paidBills.toString(),

                              icon: CupertinoIcons.check_mark_circled_solid,

                              gradient: const [
                                Color(0xFF00C9A7),
                                Color(0xFF00E4A0),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      /// PREMIUM OVERVIEW CARD
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 500),

                        tween: Tween(begin: 35.0, end: 0.0),

                        curve: Curves.easeOutCubic,

                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, value.toDouble()),

                            child: child,
                          );
                        },

                        child: Container(
                          width: double.infinity,

                          padding: const EdgeInsets.all(24),

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
                              Text(
                                "Total Bills",

                                style: GoogleFonts.poppins(
                                  color: Colors.white70,

                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "₹ ${totalAmount.toStringAsFixed(0)}",

                                style: GoogleFonts.poppins(
                                  color: Colors.white,

                                  fontSize: 32,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 16),

                              LinearProgressIndicator(
                                value: allBills.isEmpty
                                    ? 0
                                    : paidBills / allBills.length,

                                minHeight: 8,

                                borderRadius: BorderRadius.circular(30),

                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.14,
                                ),

                                valueColor: const AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "${((paidBills / (allBills.isEmpty ? 1 : allBills.length)) * 100).toStringAsFixed(0)}% bills paid",

                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      /// FILTERS
                      SizedBox(
                        height: 50,

                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,

                          itemBuilder: (context, index) {
                            final filter = filters[index];

                            final selected = selectedFilter == filter;

                            return GestureDetector(
                              onTap: () async {
                                await HapticFeedback.lightImpact();

                                setState(() {
                                  selectedFilter = filter;
                                });
                              },

                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),

                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,

                                  vertical: 12,
                                ),

                                decoration: BoxDecoration(
                                  gradient: selected
                                      ? const LinearGradient(
                                          colors: [primary, secondary],
                                        )
                                      : null,

                                  color: selected ? null : colorScheme.surface,

                                  borderRadius: BorderRadius.circular(18),

                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: primary.withValues(
                                              alpha: 0.25,
                                            ),

                                            blurRadius: 18,

                                            offset: const Offset(0, 8),
                                          ),
                                        ]
                                      : [],
                                ),

                                child: Center(
                                  child: Text(
                                    filter,

                                    style: GoogleFonts.poppins(
                                      color: selected
                                          ? Colors.white
                                          : colorScheme.onSurface,

                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },

                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 10),

                          itemCount: filters.length,
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// BILL LIST
                      ...List.generate(bills.length, (index) {
                        final bill = bills[index];

                        return TweenAnimationBuilder(
                          duration: Duration(milliseconds: 350 + (index * 60)),

                          tween: Tween(begin: 50.0, end: 0.0),

                          curve: Curves.easeOutCubic,

                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, value.toDouble()),

                              child: child,
                            );
                          },

                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 18),

                            child: _buildBillCard(bill, index),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),

        child: FadeTransition(
          opacity: _fabAnimationController,

          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 1.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _fabAnimationController,
                    curve: Curves.easeOutCubic,
                  ),
                ),

            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _fabAnimationController,
                curve: Curves.easeOutBack,
              ),

              child: GestureDetector(
                onTap: () async {
                  await HapticFeedback.mediumImpact();

                  if (context.mounted) {
                    context.push('/addBill');
                  }
                },

                child: Container(
                  height: 60,
                  width: 60,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,

                      colors: [primary, secondary, accent],
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.40),

                        blurRadius: 28,

                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),

                  child: const Icon(
                    CupertinoIcons.add,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// =========================================
  /// MINI STAT
  /// =========================================

  Widget _buildMiniStat({
    required String title,
    required String value,
    required Color color,
  }) {
    IconData icon;

    switch (title) {
      case "Pending":
        icon = CupertinoIcons.clock_fill;
        break;

      case "Paid":
        icon = CupertinoIcons.check_mark_circled_solid;
        break;

      default:
        icon = CupertinoIcons.money_dollar_circle_fill;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.20),

              borderRadius: BorderRadius.circular(16),
            ),

            child: Icon(icon, size: 18, color: Colors.white),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

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

                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),

        borderRadius: BorderRadius.circular(26),

        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.28),

            blurRadius: 20,

            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),

              borderRadius: BorderRadius.circular(16),
            ),

            child: Icon(icon, color: Colors.white, size: 18),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: GoogleFonts.poppins(
                    color: Colors.white70,

                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: GoogleFonts.poppins(
                    color: Colors.white,

                    fontWeight: FontWeight.w700,

                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(dynamic bill, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final bool isPaid = bill.isPaid;

    final bool isOverdue = !isPaid && bill.dueDate.isBefore(DateTime.now());

    return Dismissible(
      key: Key("${bill.title}$index"),

      background: Container(
        alignment: Alignment.centerLeft,

        padding: const EdgeInsets.only(left: 24),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),

          gradient: const LinearGradient(colors: [primary, secondary]),
        ),

        child: const Icon(
          CupertinoIcons.check_mark,

          color: Colors.white,

          size: 30,
        ),
      ),

      secondaryBackground: Container(
        alignment: Alignment.centerRight,

        padding: const EdgeInsets.only(right: 24),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),

          gradient: const LinearGradient(
            colors: [Color(0xFFFF5A5F), Color(0xFFFF3B30)],
          ),
        ),

        child: const Icon(CupertinoIcons.delete, color: Colors.white, size: 30),
      ),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context);
        }

        final confirm = await _showStatusConfirmation(isPaid: isPaid);

        if (!confirm) {
          return false;
        }

        await HapticFeedback.mediumImpact();

        Provider.of<BillProvider>(
          context,
          listen: false,
        ).toggleBillStatus(index);

        return false;
      },

      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          Provider.of<BillProvider>(context, listen: false).removeBill(index);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,

              backgroundColor: Colors.black87,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              content: Text(
                "Bill deleted successfully",

                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          );
        }
      },

      child: GestureDetector(
        onTap: () async {
          await HapticFeedback.lightImpact();

          _showBillPreview(context, bill, index);
        },

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),

          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [colorScheme.surface, const Color(0xFF171C2C)]
                  : const [Colors.white, Color(0xFFF8F9FF)],
            ),

            borderRadius: BorderRadius.circular(32),

            border: isOverdue
                ? Border.all(
                    color: Colors.red.withValues(alpha: 0.25),
                    width: 1.2,
                  )
                : null,

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),

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
                  color: isPaid
                      ? Colors.green.withValues(alpha: 0.12)
                      : isOverdue
                      ? Colors.red.withValues(alpha: 0.12)
                      : primary.withValues(alpha: 0.12),

                  borderRadius: BorderRadius.circular(24),
                ),

                child: Icon(
                  isPaid
                      ? CupertinoIcons.check_mark_circled_solid
                      : isOverdue
                      ? CupertinoIcons.exclamationmark_triangle_fill
                      : getCategoryIcon(bill.category),

                  color: isPaid
                      ? Colors.green
                      : isOverdue
                      ? Colors.redAccent
                      : getCategoryColor(bill.category),

                  size: 30,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      bill.title,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: GoogleFonts.poppins(
                        color: colorScheme.onSurface,
                        fontSize: 18,

                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,

                      runSpacing: 8,

                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,

                            vertical: 5,
                          ),

                          decoration: BoxDecoration(
                            color: isPaid
                                ? Colors.green.withValues(alpha: 0.10)
                                : isOverdue
                                ? Colors.red.withValues(alpha: 0.10)
                                : primary.withValues(alpha: 0.10),

                            borderRadius: BorderRadius.circular(10),
                          ),

                          child: Text(
                            isPaid
                                ? "Paid"
                                : isOverdue
                                ? "Overdue"
                                : "Pending",

                            style: GoogleFonts.poppins(
                              color: isPaid
                                  ? Colors.green
                                  : isOverdue
                                  ? Colors.redAccent
                                  : primary,

                              fontSize: 11,

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        Text(
                          "${bill.dueDate.day}/${bill.dueDate.month}/${bill.dueDate.year}",

                          style: GoogleFonts.poppins(
                            color: colorScheme.onSurfaceVariant,

                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  Text(
                    "₹ ${bill.amount.toStringAsFixed(0)}",

                    style: GoogleFonts.poppins(
                      color: colorScheme.onSurface,

                      fontWeight: FontWeight.w700,

                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Icon(
                    CupertinoIcons.chevron_right,

                    size: 14,

                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =========================================
  /// PRIMARY ACTION BUTTON
  /// =========================================

  Widget _actionButton({
    required String title,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),

      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),

        borderRadius: BorderRadius.circular(24),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(icon, color: Colors.white, size: 20),

          const SizedBox(width: 10),

          Flexible(
            child: Text(
              title,

              overflow: TextOverflow.ellipsis,

              style: GoogleFonts.poppins(
                color: Colors.white,

                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// =========================================
  /// OUTLINE ACTION BUTTON
  /// =========================================

  Widget _outlineActionButton({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),

        borderRadius: BorderRadius.circular(24),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(icon, color: color, size: 20),

          const SizedBox(width: 10),

          Flexible(
            child: Text(
              title,

              overflow: TextOverflow.ellipsis,

              style: GoogleFonts.poppins(
                color: color,

                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
