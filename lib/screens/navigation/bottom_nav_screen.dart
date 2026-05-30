import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,

      body: screens[currentIndex],

      bottomNavigationBar: SafeArea(
        top: false,

        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),

          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),

            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),

              child: Container(
                height: 88,

                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,

                    colors: [
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white.withValues(alpha: 0.88),
                    ],
                  ),

                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(34),
                  ),

                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.10),
                      blurRadius: 30,
                      spreadRadius: 1,
                      offset: const Offset(0, -2),
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
                          await HapticFeedback.mediumImpact();

                          setState(() {
                            currentIndex = index;
                          });
                        },

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 280),

                          curve: Curves.easeInOut,

                          margin: const EdgeInsets.symmetric(horizontal: 4),

                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: isSelected ? 10 : 0,
                          ),

                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [primary, secondary],
                                  )
                                : null,

                            borderRadius: BorderRadius.circular(22),

                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: primary.withValues(alpha: 0.35),

                                      blurRadius: 18,

                                      offset: const Offset(0, 8),
                                    ),
                                  ]
                                : [],
                          ),

                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),

                            child: isSelected
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,

                                    children: [
                                      Icon(
                                        icons[index],
                                        color: Colors.white,
                                        size: 24,
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

                                    color: Colors.grey.shade500,

                                    size: 24,
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
    );
  }
}
