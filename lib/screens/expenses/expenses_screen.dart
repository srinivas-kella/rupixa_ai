import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/firestore_service.dart';
import '../../core/utils/category_helper.dart';
import '../../models/expense_model.dart';
import 'package:intl/intl.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen>
    with TickerProviderStateMixin {
  static const Color primary = Color(0xFF5B67FF);

  static const Color secondary = Color(0xFF7B61FF);

  static const Color accent = Color(0xFF00C6FF);

  final TextEditingController _searchController = TextEditingController();

  final ValueNotifier<String> _searchNotifier = ValueNotifier("");

  String selectedFilter = "All";

  final List<String> filters = ["All", "Today", "Week", "Month"];

  late ScrollController _scrollController;

  //bool _showFab = true;

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
  /// DELETE DIALOG
  /// =========================================

  Future<bool> _showDeleteDialog() async {
    return await showCupertinoDialog<bool>(
          context: context,

          builder: (context) => CupertinoAlertDialog(
            title: Text(
              "Delete Expense",

              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),

            content: Padding(
              padding: const EdgeInsets.only(top: 10),

              child: Text(
                "Are you sure you want to delete this expense?",

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
  /// PREMIUM PREVIEW SHEET
  /// =========================================

  void _showExpensePreview(QueryDocumentSnapshot expense) {
    final category = expense['category'];

    final icon = CategoryHelper.getCategoryIcon(category);

    final color = CategoryHelper.getCategoryColor(category);

    DateTime? expenseDate;

    if (expense.data() is Map<String, dynamic>) {
      final data = expense.data() as Map<String, dynamic>;

      if (data.containsKey('date') && data['date'] is Timestamp) {
        expenseDate = (data['date'] as Timestamp).toDate();
      } else if (data.containsKey('createdAt') &&
          data['createdAt'] is Timestamp) {
        expenseDate = (data['createdAt'] as Timestamp).toDate();
      }
    }

    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.transparent,

      isScrollControlled: true,

      builder: (_) {
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = colorScheme.brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,

                          end: Alignment.bottomRight,

                          colors: isDark
                              ? [colorScheme.surface, const Color(0xFF171C2C)]
                              : const [Colors.white, Color(0xFFF8F9FF)],
                        ),

                        borderRadius: BorderRadius.circular(36),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.22 : 0.08,
                            ),

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
                              color: colorScheme.outlineVariant,

                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),

                          const SizedBox(height: 28),

                          Container(
                            padding: const EdgeInsets.all(22),

                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),

                              borderRadius: BorderRadius.circular(28),
                            ),

                            child: Icon(icon, color: color, size: 42),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            expense['title'],

                            maxLines: 2,

                            overflow: TextOverflow.ellipsis,

                            textAlign: TextAlign.center,

                            style: GoogleFonts.poppins(
                              color: colorScheme.onSurface,
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
                              color: color.withValues(alpha: 0.10),

                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: Text(
                              category,

                              style: GoogleFonts.poppins(
                                color: color,

                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          Text(
                            "₹ ${expense['amount']}",
                            style: GoogleFonts.poppins(
                              color: colorScheme.onSurface,
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.calendar,
                                  color: primary,
                                  size: 20,
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Created Date",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        expenseDate != null
                                            ? DateFormat(
                                                'dd MMM yyyy • hh:mm a',
                                              ).format(expenseDate)
                                            : 'Unknown',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    await HapticFeedback.lightImpact();

                                    if (!mounted) {
                                      return;
                                    }

                                    Navigator.pop(context);

                                    context.push(
                                      '/editExpense',

                                      extra: ExpenseModel(
                                        title: expense['title'],

                                        amount: (expense['amount'] as num)
                                            .toDouble(),

                                        category: expense['category'],

                                        date: expenseDate ?? DateTime.now(),
                                      ),
                                    );
                                  },

                                  child: _actionButton(
                                    title: "Edit",

                                    icon: CupertinoIcons.pencil,

                                    gradient: const [primary, secondary],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final confirm = await _showDeleteDialog();

                                    if (!confirm) {
                                      return;
                                    }

                                    await FirestoreService.deleteExpense(
                                      expense.id,
                                    );

                                    if (mounted) {
                                      Navigator.pop(context);
                                    }
                                  },

                                  child: _actionButton(
                                    title: "Delete",

                                    icon: CupertinoIcons.delete,

                                    gradient: [Colors.redAccent, Colors.orange],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

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
                    context.push('/addExpense');
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.getExpensesStream(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allExpenses = snapshot.data?.docs ?? [];

          /// TOTAL

          final totalAmount = allExpenses.fold<double>(
            0,
            (sum, item) => sum + ((item['amount'] as num).toDouble()),
          );

          return ValueListenableBuilder(
            valueListenable: _searchNotifier,

            builder: (context, searchQuery, _) {
              final now = DateTime.now();

              final expenses = allExpenses.where((expense) {
                final title = expense['title'].toString().toLowerCase();

                final matchesSearch = title.contains(searchQuery.toLowerCase());

                final data = expense.data() as Map<String, dynamic>;

                DateTime? expenseDate;

                if (data.containsKey('date') && data['date'] is Timestamp) {
                  expenseDate = (data['date'] as Timestamp).toDate();
                } else if (data.containsKey('createdAt') &&
                    data['createdAt'] is Timestamp) {
                  expenseDate = (data['createdAt'] as Timestamp).toDate();
                }

                bool matchesFilter = true;

                if (expenseDate != null) {
                  switch (selectedFilter) {
                    case 'Today':
                      matchesFilter =
                          expenseDate.day == now.day &&
                          expenseDate.month == now.month &&
                          expenseDate.year == now.year;
                      break;

                    case 'Week':
                      matchesFilter =
                          now.difference(expenseDate).inDays >= 0 &&
                          now.difference(expenseDate).inDays <= 7;
                      break;

                    case 'Month':
                      matchesFilter =
                          expenseDate.month == now.month &&
                          expenseDate.year == now.year;
                      break;

                    case 'All':
                    default:
                      matchesFilter = true;
                  }
                }

                return matchesSearch && matchesFilter;
              }).toList();

              return CustomScrollView(
                controller: _scrollController,

                physics: const BouncingScrollPhysics(),

                slivers: [
                  /// =========================================
                  /// STICKY APPBAR
                  /// =========================================
                  SliverAppBar(
                    pinned: true,

                    floating: false,

                    snap: false,

                    expandedHeight: 170,

                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,

                    elevation: 0,

                    surfaceTintColor: Colors.transparent,

                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(left: 20, bottom: 20),

                      title: Text(
                        "Expenses",

                        style: GoogleFonts.poppins(
                          color: colorScheme.onSurface,

                          fontWeight: FontWeight.bold,

                          fontSize: 28,
                        ),
                      ),

                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,

                            end: Alignment.bottomCenter,

                            colors: isDark
                                ? const [Color(0xFF0E1320), Color(0xFF101623)]
                                : const [Color(0xFFF8FAFF), Color(0xFFF4F6FF)],
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
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 180),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          /// OVERVIEW CARD
                          Container(
                            width: double.infinity,

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

                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  "Total Expenses",

                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,

                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                Text(
                                  "₹ ${totalAmount.toStringAsFixed(0)}",

                                  style: GoogleFonts.poppins(
                                    color: Colors.white,

                                    fontWeight: FontWeight.bold,

                                    fontSize: 38,
                                  ),
                                ),

                                const SizedBox(height: 26),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _miniStat(
                                        title: "Transactions",

                                        value: expenses.length.toString(),

                                        icon: CupertinoIcons
                                            .money_dollar_circle_fill,
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    Expanded(
                                      child: _miniStat(
                                        title: "Top Category",

                                        value: expenses.isEmpty
                                            ? "None"
                                            : expenses.first['category'],

                                        icon: CupertinoIcons.chart_pie_fill,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 26),

                          /// SEARCH
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18),

                            decoration: BoxDecoration(
                              color: colorScheme.surface,

                              borderRadius: BorderRadius.circular(26),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.18 : 0.04,
                                  ),

                                  blurRadius: 14,

                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),

                            child: TextField(
                              controller: _searchController,

                              onChanged: (value) {
                                _searchNotifier.value = value;
                              },

                              style: GoogleFonts.poppins(
                                color: colorScheme.onSurface,
                              ),

                              decoration: InputDecoration(
                                border: InputBorder.none,

                                prefixIcon: const Icon(
                                  CupertinoIcons.search,

                                  color: primary,
                                ),

                                hintText: "Search expenses...",

                                hintStyle: GoogleFonts.poppins(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          /// FILTERS
                          SizedBox(
                            height: 48,

                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,

                              itemBuilder: (context, index) {
                                final filter = filters[index];

                                final bool selected = selectedFilter == filter;

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

                                      color: selected
                                          ? null
                                          : colorScheme.surface,

                                      borderRadius: BorderRadius.circular(18),

                                      boxShadow: selected
                                          ? [
                                              BoxShadow(
                                                color: primary.withValues(
                                                  alpha: 0.25,
                                                ),

                                                blurRadius: 16,

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

                          const SizedBox(height: 26),

                          /// EMPTY
                          if (expenses.isEmpty)
                            SizedBox(
                              height: 320,

                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(28),

                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            primary.withValues(alpha: 0.15),
                                            secondary.withValues(alpha: 0.10),
                                          ],
                                        ),

                                        shape: BoxShape.circle,
                                      ),

                                      child: const Icon(
                                        CupertinoIcons.money_dollar_circle_fill,

                                        size: 60,

                                        color: primary,
                                      ),
                                    ),

                                    const SizedBox(height: 22),

                                    Text(
                                      "No Expenses Found",

                                      style: GoogleFonts.poppins(
                                        color: colorScheme.onSurface,
                                        fontSize: 22,

                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      "Track your spending beautifully.",

                                      textAlign: TextAlign.center,

                                      style: GoogleFonts.poppins(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          /// EXPENSE LIST
                          ...expenses.map((expense) {
                            final category = expense['category'];

                            final icon = CategoryHelper.getCategoryIcon(
                              category,
                            );

                            final color = CategoryHelper.getCategoryColor(
                              category,
                            );
                            DateTime? expenseDate;

                            final data = expense.data() as Map<String, dynamic>;

                            if (data.containsKey('date') &&
                                data['date'] is Timestamp) {
                              expenseDate = (data['date'] as Timestamp)
                                  .toDate();
                            } else if (data.containsKey('createdAt') &&
                                data['createdAt'] is Timestamp) {
                              expenseDate = (data['createdAt'] as Timestamp)
                                  .toDate();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 18),

                              child: Dismissible(
                                key: Key(expense.id),

                                direction: DismissDirection.endToStart,

                                background: Container(
                                  alignment: Alignment.centerRight,

                                  padding: const EdgeInsets.only(right: 24),

                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),

                                    gradient: const LinearGradient(
                                      colors: [Colors.redAccent, Colors.orange],
                                    ),
                                  ),

                                  child: const Icon(
                                    CupertinoIcons.delete,

                                    color: Colors.white,

                                    size: 30,
                                  ),
                                ),

                                confirmDismiss: (direction) async {
                                  return await _showDeleteDialog();
                                },

                                onDismissed: (direction) async {
                                  await FirestoreService.deleteExpense(
                                    expense.id,
                                  );
                                },

                                child: GestureDetector(
                                  onTap: () async {
                                    await HapticFeedback.lightImpact();

                                    _showExpensePreview(expense);
                                  },

                                  child: TweenAnimationBuilder(
                                    duration: const Duration(milliseconds: 250),

                                    tween: Tween(begin: 0.98, end: 1.0),

                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value.toDouble(),

                                        child: child,
                                      );
                                    },

                                    child: Container(
                                      padding: const EdgeInsets.all(20),

                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isDark
                                              ? [
                                                  colorScheme.surface,
                                                  const Color(0xFF171C2C),
                                                ]
                                              : const [
                                                  Colors.white,
                                                  Color(0xFFF8F9FF),
                                                ],
                                        ),

                                        borderRadius: BorderRadius.circular(30),

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

                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),

                                            decoration: BoxDecoration(
                                              color: color.withValues(
                                                alpha: 0.12,
                                              ),

                                              borderRadius:
                                                  BorderRadius.circular(22),
                                            ),

                                            child: Icon(
                                              icon,

                                              color: color,

                                              size: 28,
                                            ),
                                          ),

                                          const SizedBox(width: 18),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,

                                              children: [
                                                Text(
                                                  expense['title'],

                                                  maxLines: 1,

                                                  overflow:
                                                      TextOverflow.ellipsis,

                                                  style: GoogleFonts.poppins(
                                                    color:
                                                        colorScheme.onSurface,
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
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,

                                                            vertical: 5,
                                                          ),

                                                      decoration: BoxDecoration(
                                                        color: color.withValues(
                                                          alpha: 0.10,
                                                        ),

                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),

                                                      child: Text(
                                                        category,

                                                        style:
                                                            GoogleFonts.poppins(
                                                              color: color,

                                                              fontSize: 11,

                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                    ),

                                                    Text(
                                                      expenseDate != null
                                                          ? DateFormat(
                                                              'dd MMM yyyy',
                                                            ).format(
                                                              expenseDate,
                                                            )
                                                          : "No Date",
                                                      style: GoogleFonts.poppins(
                                                        color: colorScheme
                                                            .onSurfaceVariant,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,

                                            children: [
                                              Text(
                                                "₹ ${expense['amount']}",

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

                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
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
          );
        },
      ),
    );
  }

  /// =========================================
  /// MINI STAT
  /// =========================================

  Widget _miniStat({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),

        borderRadius: BorderRadius.circular(22),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),

              borderRadius: BorderRadius.circular(18),
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

                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// =========================================
  /// ACTION BUTTON
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

          Text(
            title,

            style: GoogleFonts.poppins(
              color: Colors.white,

              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
