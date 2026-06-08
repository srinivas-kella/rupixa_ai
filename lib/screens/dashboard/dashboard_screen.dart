import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rupixa_ai/core/services/firestore_service.dart';
import 'package:rupixa_ai/core/utils/category_helper.dart';

import 'package:rupixa_ai/screens/expenses/calendar_screen.dart';
import 'package:rupixa_ai/screens/expenses/cloud_expenses_screen.dart';
import 'package:rupixa_ai/screens/insights/insights_screen.dart';
import 'package:rupixa_ai/screens/notifications/notification_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rupixa_ai/models/notification_model.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const DashboardScreen({super.key, this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  static const Color primary = Color(0xFF6C63FF);

  static const Color secondary = Color(0xFF8B5CF6);

  static const Color accent = Color(0xFF00C6FF);

  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;

  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,

            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  /// =========================================
  /// GREETING
  /// =========================================

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning ☀️";
    } else if (hour < 17) {
      return "Good Afternoon 🌤️";
    } else {
      return "Good Evening 🌙";
    }
  }

  /// =========================================
  /// TOP CATEGORY
  /// =========================================

  String _getTopCategory(Map<String, dynamic> stats) {
    final categories = {
      'Food': stats['food'],
      'Shopping': stats['shopping'],
      'Transport': stats['transport'],
      'Entertainment': stats['entertainment'],
      'Others': stats['others'],
    };

    String topCategory = 'Food';

    double highest = 0;

    categories.forEach((key, value) {
      if (value > highest) {
        highest = value;
        topCategory = key;
      }
    });

    return topCategory;
  }

  /// =========================================
  /// CALCULATE STATS
  /// =========================================

  Map<String, dynamic> calculateStats(List<QueryDocumentSnapshot> expenses) {
    double totalExpenses = 0;

    double food = 0;
    double shopping = 0;
    double transport = 0;
    double entertainment = 0;
    double others = 0;

    for (var expense in expenses) {
      final amount = (expense['amount'] as num).toDouble();

      totalExpenses += amount;

      switch (expense['category']) {
        case 'Food':
          food += amount;
          break;

        case 'Shopping':
          shopping += amount;
          break;

        case 'Transport':
          transport += amount;
          break;

        case 'Entertainment':
          entertainment += amount;
          break;

        default:
          others += amount;
      }
    }

    return {
      'totalExpenses': totalExpenses,
      'food': food,
      'shopping': shopping,
      'transport': transport,
      'entertainment': entertainment,
      'others': others,
    };
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

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
                    Color(0xFFEFF2FF),
                    Color(0xFFF5F7FF),
                  ],
          ),
        ),

        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,

            child: SlideTransition(
              position: _slideAnimation,

              child: RefreshIndicator(
                color: primary,

                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 900));
                },

                child: StreamBuilder<QuerySnapshot>(
                  stream: FirestoreService.getExpensesStream(),

                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CupertinoActivityIndicator(radius: 18),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState();
                    }

                    final expenses = snapshot.data!.docs;

                    final stats = calculateStats(expenses);

                    final totalExpenses = stats['totalExpenses'];

                    final monthlyBudget = 100000.0;

                    final savings = monthlyBudget - totalExpenses;

                    final budgetUsage = totalExpenses / monthlyBudget;

                    final topCategory = _getTopCategory(stats);

                    final financialHealth = savings >= 0
                        ? "Healthy"
                        : "Critical";

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),

                      slivers: [
                        SliverAppBar(
                          pinned: true,
                          floating: false,
                          snap: false,
                          elevation: 0,
                          scrolledUnderElevation: 0,
                          automaticallyImplyLeading: false,
                          backgroundColor: Colors.transparent,
                          expandedHeight: 122,
                          collapsedHeight: 68,

                          flexibleSpace: LayoutBuilder(
                            builder: (context, constraints) {
                              final top = constraints.biggest.height;

                              final collapsed = top <= kToolbarHeight + 18;

                              return Container(
                                decoration: BoxDecoration(
                                  color: collapsed
                                      ? colorScheme.surface.withValues(
                                          alpha: 0.90,
                                        )
                                      : Colors.transparent,
                                ),

                                child: ClipRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: collapsed ? 18 : 0,
                                      sigmaY: collapsed ? 18 : 0,
                                    ),

                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top:
                                            MediaQuery.of(context).padding.top +
                                            2,
                                        bottom: collapsed ? 4 : 8,
                                      ),

                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,

                                        children: [
                                          /// TITLE
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,

                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,

                                              mainAxisSize: MainAxisSize.min,

                                              children: [
                                                AnimatedOpacity(
                                                  duration: const Duration(
                                                    milliseconds: 180,
                                                  ),

                                                  opacity: collapsed ? 0 : 1,

                                                  child: collapsed
                                                      ? const SizedBox.shrink()
                                                      : Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                                vertical: 5,
                                                              ),

                                                          decoration: BoxDecoration(
                                                            color: primary
                                                                .withValues(
                                                                  alpha: 0.08,
                                                                ),

                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  30,
                                                                ),
                                                          ),

                                                          child: Text(
                                                            getGreeting(),

                                                            style:
                                                                GoogleFonts.poppins(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color:
                                                                      primary,
                                                                ),
                                                          ),
                                                        ),
                                                ),

                                                SizedBox(
                                                  height: collapsed ? 0 : 6,
                                                ),

                                                ShaderMask(
                                                  shaderCallback: (bounds) {
                                                    return const LinearGradient(
                                                      colors: [
                                                        Color(0xFF15192D),
                                                        primary,
                                                        secondary,
                                                      ],
                                                    ).createShader(bounds);
                                                  },

                                                  child:
                                                      AnimatedDefaultTextStyle(
                                                        duration:
                                                            const Duration(
                                                              milliseconds: 220,
                                                            ),

                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize:
                                                                  collapsed
                                                                  ? 20
                                                                  : 30,

                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,

                                                              color:
                                                                  Colors.white,

                                                              letterSpacing: -1,

                                                              height: 1,
                                                            ),

                                                        child: const Text(
                                                          "Rupixa AI",

                                                          maxLines: 1,

                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          /// ACTIONS
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  await HapticFeedback.lightImpact();

                                                  if (!mounted) return;

                                                  Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                      builder: (_) =>
                                                          const NotificationScreen(),
                                                    ),
                                                  );
                                                },

                                                child: Stack(
                                                  clipBehavior: Clip.none,

                                                  children: [
                                                    AnimatedContainer(
                                                      duration: const Duration(
                                                        milliseconds: 220,
                                                      ),

                                                      height: collapsed
                                                          ? 38
                                                          : 46,
                                                      width: collapsed
                                                          ? 38
                                                          : 46,

                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              collapsed
                                                                  ? 12
                                                                  : 16,
                                                            ),

                                                        gradient:
                                                            LinearGradient(
                                                              colors: [
                                                                colorScheme
                                                                    .surface,
                                                                colorScheme
                                                                    .surface
                                                                    .withValues(
                                                                      alpha:
                                                                          0.92,
                                                                    ),
                                                              ],
                                                            ),

                                                        border: Border.all(
                                                          color: colorScheme
                                                              .outlineVariant
                                                              .withValues(
                                                                alpha: 0.5,
                                                              ),
                                                        ),
                                                      ),

                                                      child: Icon(
                                                        CupertinoIcons
                                                            .bell_fill,
                                                        size: collapsed
                                                            ? 18
                                                            : 20,
                                                        color: colorScheme
                                                            .onSurface,
                                                      ),
                                                    ),

                                                    Positioned(
                                                      top: -2,
                                                      right: -2,

                                                      child: Container(
                                                        height: 18,
                                                        width: 18,

                                                        decoration: BoxDecoration(
                                                          color:
                                                              Colors.redAccent,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                          border: Border.all(
                                                            color: colorScheme
                                                                .surface,
                                                            width: 2,
                                                          ),
                                                        ),

                                                        alignment:
                                                            Alignment.center,

                                                        child: Text(
                                                          Hive.box<
                                                                NotificationModel
                                                              >('notificationsBox')
                                                              .length
                                                              .toString(),
                                                          style:
                                                              GoogleFonts.poppins(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 9,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              const SizedBox(width: 10),

                                              AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 220,
                                                ),

                                                height: collapsed ? 38 : 46,
                                                width: collapsed ? 38 : 46,

                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        collapsed ? 12 : 16,
                                                      ),

                                                  gradient: LinearGradient(
                                                    colors: [
                                                      colorScheme.surface,
                                                      colorScheme.surface
                                                          .withValues(
                                                            alpha: 0.92,
                                                          ),
                                                    ],
                                                  ),

                                                  border: Border.all(
                                                    color: colorScheme
                                                        .outlineVariant
                                                        .withValues(alpha: 0.5),
                                                  ),
                                                ),

                                                child: Icon(
                                                  CupertinoIcons
                                                      .person_crop_circle_fill,
                                                  size: collapsed ? 18 : 20,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              width * 0.05,
                              6,
                              width * 0.05,
                              0,
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                // /// HEADER
                                // Row(
                                //   mainAxisAlignment:
                                //       MainAxisAlignment.spaceBetween,

                                //   children: [
                                //     Expanded(
                                //       child: Column(
                                //         crossAxisAlignment:
                                //             CrossAxisAlignment.start,

                                //         children: [
                                //           Text(
                                //             getGreeting(),

                                //             style: GoogleFonts.poppins(
                                //               fontSize: 14,

                                //               color: Colors.grey.shade600,
                                //             ),
                                //           ),

                                //           const SizedBox(height: 6),

                                //           Text(
                                //             "Rupixa AI",

                                //             overflow: TextOverflow.ellipsis,

                                //             style: GoogleFonts.poppins(
                                //               fontSize: 34,

                                //               fontWeight: FontWeight.bold,

                                //               color: const Color(0xFF15192D),
                                //             ),
                                //           ),
                                //         ],
                                //       ),
                                //     ),

                                //     Row(
                                //       children: [
                                //         _topButton(CupertinoIcons.bell_fill),

                                //         const SizedBox(width: 12),

                                //         _topButton(CupertinoIcons.person_fill),
                                //       ],
                                //     ),
                                //   ],
                                // ),

                                /// =========================================
                                /// PREMIUM STICKY IOS APP BAR
                                /// =========================================
                                const SizedBox(height: 8),

                                /// HERO CARD
                                TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0.95, end: 1),

                                  duration: const Duration(milliseconds: 700),

                                  curve: Curves.easeOutBack,

                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,

                                      child: child,
                                    );
                                  },

                                  child: Container(
                                    width: double.infinity,

                                    padding: const EdgeInsets.all(28),

                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(42),

                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,

                                        end: Alignment.bottomRight,

                                        colors: [
                                          Color(0xFF6C63FF),
                                          Color(0xFF8B5CF6),
                                          Color(0xFF00C6FF),
                                        ],
                                      ),

                                      boxShadow: [
                                        BoxShadow(
                                          color: primary.withValues(
                                            alpha: 0.30,
                                          ),

                                          blurRadius: 35,

                                          spreadRadius: 2,

                                          offset: const Offset(0, 20),
                                        ),
                                      ],
                                    ),

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,

                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,

                                                children: [
                                                  Text(
                                                    "Total Balance",

                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white70,

                                                      fontSize: 15,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 12),

                                                  Text(
                                                    "₹ ${savings.toStringAsFixed(0)}",

                                                    overflow:
                                                        TextOverflow.ellipsis,

                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,

                                                      fontSize: width < 370
                                                          ? 30
                                                          : 38,

                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Container(
                                              padding: const EdgeInsets.all(18),

                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(
                                                  alpha: 0.14,
                                                ),

                                                shape: BoxShape.circle,
                                              ),

                                              child: const Icon(
                                                CupertinoIcons
                                                    .chart_bar_alt_fill,

                                                color: Colors.white,

                                                size: 32,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 28),

                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),

                                          child: LinearProgressIndicator(
                                            minHeight: 12,

                                            value: budgetUsage,

                                            backgroundColor: Colors.white
                                                .withValues(alpha: 0.15),

                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),

                                        const SizedBox(height: 12),

                                        Text(
                                          "${(budgetUsage * 100).toStringAsFixed(0)}% monthly budget used",

                                          style: GoogleFonts.poppins(
                                            color: Colors.white70,

                                            fontSize: 13,
                                          ),
                                        ),

                                        const SizedBox(height: 24),

                                        Row(
                                          children: [
                                            Expanded(
                                              child: _heroStat(
                                                title: "Spent",

                                                value:
                                                    "₹ ${totalExpenses.toStringAsFixed(0)}",

                                                icon: CupertinoIcons
                                                    .arrow_up_circle_fill,
                                              ),
                                            ),

                                            const SizedBox(width: 14),

                                            Expanded(
                                              child: _heroStat(
                                                title: "Top",

                                                value: topCategory,

                                                icon: CupertinoIcons.star_fill,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 34),

                                /// QUICK INSIGHTS
                                Row(
                                  children: [
                                    Expanded(
                                      child: _premiumInsightCard(
                                        title: "Health",

                                        value: financialHealth,

                                        subtitle: "Financial status",

                                        icon: CupertinoIcons.heart_fill,

                                        color: savings >= 0
                                            ? Colors.green
                                            : Colors.red,

                                        gradient: isDark
                                            ? [
                                                const Color(0xFF1B2332),
                                                const Color(0xFF252F42),
                                              ]
                                            : [
                                                const Color(0xFFE7FFF1),
                                                const Color(0xFFCFFFE2),
                                              ],
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    Expanded(
                                      child: _premiumInsightCard(
                                        title: "Transactions",

                                        value: expenses.length.toString(),

                                        subtitle: "This month",

                                        icon: CupertinoIcons
                                            .arrow_2_circlepath_circle_fill,

                                        color: Colors.orange,

                                        gradient: isDark
                                            ? [
                                                const Color(0xFF1B2332),
                                                const Color(0xFF252F42),
                                              ]
                                            : [
                                                const Color(0xFFFFF4E6),
                                                const Color(0xFFFFE8C8),
                                              ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 34),

                                /// QUICK ACTIONS
                                Text(
                                  "Quick Actions",

                                  style: GoogleFonts.poppins(
                                    fontSize: 24,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 22),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,

                                  children: [
                                    Expanded(
                                      child: _quickAction(
                                        icon: CupertinoIcons.cloud_fill,

                                        title: "Cloud",

                                        gradient: isDark
                                            ? [
                                                const Color(0xFF1B2332),
                                                const Color(0xFF252F42),
                                              ]
                                            : [
                                                const Color(0xFFEAF4FF),
                                                const Color(0xFFD7E9FF),
                                              ],

                                        onTap: () {
                                          Navigator.push(
                                            context,

                                            CupertinoPageRoute(
                                              builder: (_) =>
                                                  const CloudExpensesScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    Expanded(
                                      child: _quickAction(
                                        icon: CupertinoIcons.calendar,

                                        title: "Calendar",

                                        gradient: isDark
                                            ? [
                                                const Color(0xFF1B2332),
                                                const Color(0xFF252F42),
                                              ]
                                            : [
                                                const Color(0xFFF0ECFF),
                                                const Color(0xFFE2DBFF),
                                              ],

                                        onTap: () {
                                          Navigator.push(
                                            context,

                                            CupertinoPageRoute(
                                              builder: (_) =>
                                                  const CalendarScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    Expanded(
                                      child: _quickAction(
                                        icon: CupertinoIcons.sparkles,

                                        title: "Insights",

                                        gradient: isDark
                                            ? [
                                                const Color(0xFF1B2332),
                                                const Color(0xFF252F42),
                                              ]
                                            : [
                                                const Color(0xFFE8FCFF),
                                                const Color(0xFFD2F7FF),
                                              ],

                                        onTap: () {
                                          Navigator.push(
                                            context,

                                            CupertinoPageRoute(
                                              builder: (_) =>
                                                  const InsightsScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 34),

                                /// AI CARD
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),

                                  curve: Curves.easeOutCubic,

                                  padding: const EdgeInsets.all(24),

                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDark
                                          ? [
                                              const Color(0xFF1B2332),
                                              const Color(0xFF252F42),
                                            ]
                                          : const [
                                              Color(0xFFEFF3FF),
                                              Color(0xFFE8EAFF),
                                            ],
                                    ),

                                    borderRadius: BorderRadius.circular(32),

                                    boxShadow: [
                                      BoxShadow(
                                        color: primary.withValues(alpha: 0.08),

                                        blurRadius: 20,

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
                                            colors: [
                                              Color(0xFF6C63FF),
                                              Color(0xFF8B5CF6),
                                            ],
                                          ),

                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                        ),

                                        child: const Icon(
                                          CupertinoIcons.sparkles,

                                          color: Colors.white,

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
                                              "AI Smart Insight",

                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,

                                                fontSize: 17,
                                              ),
                                            ),

                                            const SizedBox(height: 8),

                                            Text(
                                              totalExpenses > 5000
                                                  ? "Your spending increased this month. Reduce unnecessary expenses."
                                                  : "Excellent! Your spending habits look healthy.",

                                              style: GoogleFonts.poppins(
                                                color: Colors.grey.shade700,

                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 34),

                                /// TRANSACTIONS TITLE
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,

                                  children: [
                                    Text(
                                      "Recent",

                                      style: GoogleFonts.poppins(
                                        fontSize: 24,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    InkWell(
                                      borderRadius: BorderRadius.circular(16),

                                      onTap: () async {
                                        await HapticFeedback.lightImpact();

                                        widget.onNavigate?.call(1);
                                      },

                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 7,
                                        ),

                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              primary.withValues(alpha: 0.12),
                                              secondary.withValues(alpha: 0.08),
                                            ],
                                          ),

                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),

                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,

                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,

                                            children: [
                                              Text(
                                                "View All",

                                                style: GoogleFonts.poppins(
                                                  color: primary,

                                                  fontWeight: FontWeight.w600,

                                                  fontSize: 13,
                                                ),
                                              ),

                                              const SizedBox(width: 2),

                                              const Icon(
                                                CupertinoIcons.chevron_right,

                                                size: 12,

                                                color: primary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 22),
                              ],
                            ),
                          ),
                        ),

                        /// TRANSACTION LIST
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            width * 0.05,
                            0,
                            width * 0.05,
                            140,
                          ),

                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final expense = expenses[index];

                              final category = expense['category'];

                              final icon = CategoryHelper.getCategoryIcon(
                                category,
                              );

                              final color = CategoryHelper.getCategoryColor(
                                category,
                              );

                              return TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 1),

                                duration: Duration(
                                  milliseconds: 400 + (index * 80),
                                ),

                                curve: Curves.easeOut,

                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 40 * (1 - value)),

                                    child: Opacity(
                                      opacity: value,

                                      child: child,
                                    ),
                                  );
                                },

                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 18),

                                  child: Container(
                                    padding: const EdgeInsets.all(18),

                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isDark
                                            ? [
                                                colorScheme.surface,
                                                const Color(0xFF171C2C),
                                              ]
                                            : [
                                                Colors.white,
                                                const Color(0xFFF7F8FF),
                                              ],
                                      ),

                                      borderRadius: BorderRadius.circular(30),

                                      boxShadow: [
                                        BoxShadow(
                                          color: primary.withValues(
                                            alpha: 0.05,
                                          ),

                                          blurRadius: 20,

                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),

                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(15),

                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                color.withValues(alpha: 0.22),
                                                color.withValues(alpha: 0.06),
                                              ],
                                            ),

                                            borderRadius: BorderRadius.circular(
                                              22,
                                            ),
                                          ),

                                          child: Icon(
                                            icon,

                                            color: color,

                                            size: 26,
                                          ),
                                        ),

                                        const SizedBox(width: 16),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,

                                            children: [
                                              Text(
                                                expense['title'],

                                                maxLines: 1,

                                                overflow: TextOverflow.ellipsis,

                                                style: GoogleFonts.poppins(
                                                  color: colorScheme.onSurface,
                                                  fontSize: 16,

                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),

                                              const SizedBox(height: 8),

                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,

                                                      vertical: 5,
                                                    ),

                                                decoration: BoxDecoration(
                                                  color: color.withValues(
                                                    alpha: 0.12,
                                                  ),

                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),

                                                child: Text(
                                                  category,

                                                  style: GoogleFonts.poppins(
                                                    color: color,

                                                    fontSize: 11,

                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,

                                          children: [
                                            Text(
                                              "- ₹${expense['amount']}",

                                              overflow: TextOverflow.ellipsis,

                                              style: GoogleFonts.poppins(
                                                color: Colors.redAccent,

                                                fontWeight: FontWeight.bold,

                                                fontSize: 17,
                                              ),
                                            ),

                                            const SizedBox(height: 8),

                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,

                                                    vertical: 5,
                                                  ),

                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: isDark
                                                      ? [
                                                          const Color(
                                                            0xFF123524,
                                                          ),
                                                          const Color(
                                                            0xFF16452E,
                                                          ),
                                                        ]
                                                      : const [
                                                          Color(0xFFE9FFF0),
                                                          Color(0xFFD6FFE3),
                                                        ],
                                                ),

                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),

                                              child: Text(
                                                "Completed",

                                                style: GoogleFonts.poppins(
                                                  color: Colors.green,

                                                  fontSize: 10,

                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }, childCount: min(expenses.length, 8)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// =========================================
  /// EMPTY STATE
  /// =========================================

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),

      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 120, 24, 120),

        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(34),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary.withValues(alpha: 0.18),
                    accent.withValues(alpha: 0.10),
                  ],
                ),

                shape: BoxShape.circle,
              ),

              child: const Icon(
                CupertinoIcons.creditcard_fill,

                size: 80,

                color: primary,
              ),
            ),

            const SizedBox(height: 28),

            Text(
              "No Expenses Yet",

              style: GoogleFonts.poppins(
                color: colorScheme.onSurface,
                fontSize: 28,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              "Start tracking your expenses\nfor smart AI insights.",

              textAlign: TextAlign.center,

              style: GoogleFonts.poppins(
                color: colorScheme.onSurfaceVariant,

                height: 1.6,

                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _collapsedTopButton(IconData icon) {
    return Container(
      height: 36,
      width: 36,

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),

        borderRadius: BorderRadius.circular(12),
      ),

      child: Icon(icon, size: 17, color: const Color(0xFF15192D)),
    );
  }

  Widget _buildPremiumHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,

      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),

                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),

                  borderRadius: BorderRadius.circular(30),
                ),

                child: Text(
                  getGreeting(),

                  style: GoogleFonts.poppins(
                    fontSize: 12,

                    fontWeight: FontWeight.w600,

                    color: primary,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [Color(0xFF15192D), primary, secondary],
                  ).createShader(bounds);
                },

                child: Text(
                  "Rupixa AI",

                  overflow: TextOverflow.ellipsis,

                  style: GoogleFonts.poppins(
                    fontSize: 32,

                    fontWeight: FontWeight.w800,

                    color: Colors.white,

                    letterSpacing: -1,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 14),

        Row(
          children: [
            _premiumTopButton(CupertinoIcons.bell_fill),

            const SizedBox(width: 12),

            _premiumTopButton(CupertinoIcons.person_crop_circle_fill),
          ],
        ),
      ],
    );
  }

  Widget _premiumTopButton(IconData icon) {
    return GestureDetector(
      onTap: () async {
        await HapticFeedback.lightImpact();
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        height: 46,
        width: 46,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),

          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withValues(alpha: 0.92)],
          ),

          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),

              blurRadius: 14,

              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Icon(icon, size: 20, color: const Color(0xFF15192D)),
      ),
    );
  }

  Widget _topButton(IconData icon) {
    return GestureDetector(
      onTap: () async {
        await HapticFeedback.lightImpact();
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF5F7FF)],
          ),

          shape: BoxShape.circle,

          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.05),

              blurRadius: 16,

              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Icon(icon, color: primary, size: 22),
      ),
    );
  }

  Widget _heroStat({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),

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

                const SizedBox(height: 6),

                Text(
                  value,

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

  Widget _premiumInsightCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),

        borderRadius: BorderRadius.circular(30),

        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),

            blurRadius: 20,

            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.45),

              borderRadius: BorderRadius.circular(18),
            ),

            child: Icon(icon, color: color),
          ),

          const SizedBox(height: 18),

          Text(
            title,

            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,

              fontSize: 12,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,

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
              color: Colors.grey.shade700,

              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () async {
        await HapticFeedback.lightImpact();

        onTap();
      },

      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),

        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),

          borderRadius: BorderRadius.circular(28),

          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.05),

              blurRadius: 16,

              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),

                borderRadius: BorderRadius.circular(22),
              ),

              child: Icon(icon, color: primary, size: 28),
            ),

            const SizedBox(height: 16),

            Text(
              title,

              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,

                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
