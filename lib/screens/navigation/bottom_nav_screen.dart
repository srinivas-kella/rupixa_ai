import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

import '../analytics/analytics_screen.dart';
import '../bills/bills_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../expenses/expenses_screen.dart';
import '../settings/settings_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int currentIndex = 0;

  bool _isNavVisible = true;

  static const Color primary = Color(0xFF5B67FF);

  static const Color secondary = Color(0xFF7B61FF);

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      DashboardScreen(
        onNavigate: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),

      const ExpensesScreen(),

      const BillsScreen(),

      const AnalyticsScreen(),

      const SettingsScreen(),
    ];
  }

  final List<IconData> icons = [
    Icons.home_rounded,
    Icons.wallet_rounded,
    Icons.receipt_long_rounded,
    Icons.bar_chart_rounded,
    Icons.settings_rounded,
  ];

  final List<String> labels = [
    "Home",
    "Expenses",
    "Bills",
    "Analytics",
    "Settings",
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,

      extendBody: true,

      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            if (_isNavVisible) {
              setState(() {
                _isNavVisible = false;
              });
            }
          }

          if (notification.direction == ScrollDirection.forward) {
            if (!_isNavVisible) {
              setState(() {
                _isNavVisible = true;
              });
            }
          }

          return true;
        },

        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),

          switchInCurve: Curves.easeOutCubic,

          switchOutCurve: Curves.easeInCubic,

          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,

              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.03, 0),

                  end: Offset.zero,
                ).animate(animation),

                child: child,
              ),
            );
          },

          child: KeyedSubtree(
            key: ValueKey(currentIndex),

            child: screens[currentIndex],
          ),
        ),
      ),

      /// =========================================
      /// PREMIUM FLOATING NAVBAR
      /// =========================================
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 350),

        curve: Curves.easeOutCubic,

        offset: _isNavVisible ? Offset.zero : const Offset(0, 1.5),

        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),

          opacity: _isNavVisible ? 1 : 0,

          child: SafeArea(
            top: false,

            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),

                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),

                  child: Container(
                    height: 82,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF101623) : Colors.white)
                          .withValues(alpha: isDark ? 0.84 : 0.78),

                      borderRadius: BorderRadius.circular(32),

                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.white)
                            .withValues(alpha: isDark ? 0.10 : 0.35),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.08),

                          blurRadius: 40,

                          spreadRadius: 1,

                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: List.generate(icons.length, (index) {
                        final bool isSelected = currentIndex == index;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await HapticFeedback.lightImpact();

                              setState(() {
                                currentIndex = index;
                              });
                            },

                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),

                              curve: Curves.easeOutCubic,

                              margin: const EdgeInsets.symmetric(horizontal: 4),

                              padding: EdgeInsets.symmetric(
                                vertical: 12,

                                horizontal: isSelected ? 12 : 0,
                              ),

                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [primary, secondary],
                                      )
                                    : null,

                                borderRadius: BorderRadius.circular(24),

                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: primary.withValues(
                                            alpha: 0.30,
                                          ),

                                          blurRadius: 18,

                                          offset: const Offset(0, 8),
                                        ),
                                      ]
                                    : [],
                              ),

                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),

                                child: isSelected
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,

                                        children: [
                                          Icon(
                                            icons[index],

                                            color: Colors.white,

                                            size: 23,
                                          ),

                                          const SizedBox(width: 8),

                                          Flexible(
                                            child: Text(
                                              labels[index],

                                              overflow: TextOverflow.ellipsis,

                                              style: GoogleFonts.poppins(
                                                color: Colors.white,

                                                fontWeight: FontWeight.w600,

                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Icon(
                                        icons[index],

                                        color: isDark
                                            ? Colors.white60
                                            : Colors.grey.shade500,

                                        size: 23,
                                      ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
