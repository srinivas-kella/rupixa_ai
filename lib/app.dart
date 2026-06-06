import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/widgets/app_lock_gate.dart';
import 'providers/theme_provider.dart';
import 'routes/router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// =========================================
  /// PREMIUM COLORS
  /// =========================================

  static const Color primary = Color(0xFF6C63FF);

  static const Color secondary = Color(0xFF8B5CF6);

  static const Color accent = Color(0xFF00C6FF);

  static const Color lightBg = Color(0xFFF6F8FF);

  static const Color darkBg = Color(0xFF0E1320);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      title: 'Rupixa AI',

      themeMode: themeProvider.currentTheme,

      /// =========================================
      /// PREMIUM SCROLLING
      /// =========================================
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
      ),

      /// =========================================
      /// GLOBAL PAGE TRANSITIONS
      /// =========================================
      builder: (context, child) {
        return AppLockGate(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),

            switchInCurve: Curves.easeOutCubic,

            switchOutCurve: Curves.easeInCubic,

            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,

                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.02, 0),

                    end: Offset.zero,
                  ).animate(animation),

                  child: child,
                ),
              );
            },

            child: child,
          ),
        );
      },

      /// =========================================
      /// LIGHT THEME
      /// =========================================
      theme: ThemeData(
        useMaterial3: true,

        brightness: Brightness.light,

        primaryColor: primary,

        scaffoldBackgroundColor: lightBg,

        visualDensity: VisualDensity.adaptivePlatformDensity,

        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

        splashFactory: NoSplash.splashFactory,

        splashColor: Colors.transparent,

        highlightColor: Colors.transparent,

        fontFamily: GoogleFonts.poppins().fontFamily,

        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,

          brightness: Brightness.light,

          primary: primary,

          secondary: secondary,

          surface: Colors.white,
        ),

        /// =========================================
        /// TEXT THEME
        /// =========================================
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          headlineLarge: GoogleFonts.poppins(
            fontSize: 34,

            fontWeight: FontWeight.bold,

            color: const Color(0xFF161B2E),
          ),

          headlineMedium: GoogleFonts.poppins(
            fontSize: 28,

            fontWeight: FontWeight.w700,

            color: const Color(0xFF161B2E),
          ),

          bodyLarge: GoogleFonts.poppins(
            color: const Color(0xFF20263A),

            fontSize: 16,
          ),

          bodyMedium: GoogleFonts.poppins(
            color: Colors.grey.shade700,

            fontSize: 14,
          ),
        ),

        /// =========================================
        /// APP BAR
        /// =========================================
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,

          elevation: 0,

          centerTitle: false,

          scrolledUnderElevation: 0,

          iconTheme: const IconThemeData(color: Color(0xFF161B2E)),

          titleTextStyle: GoogleFonts.poppins(
            fontSize: 24,

            fontWeight: FontWeight.bold,

            color: const Color(0xFF161B2E),
          ),
        ),

        /// =========================================
        /// CARD THEME
        /// =========================================
        cardTheme: CardThemeData(
          elevation: 0,

          color: Colors.white,

          shadowColor: primary.withValues(alpha: 0.08),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),

          margin: EdgeInsets.zero,
        ),

        /// =========================================
        /// INPUTS
        /// =========================================
        inputDecorationTheme: InputDecorationTheme(
          filled: true,

          fillColor: Colors.white,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),

          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade500,

            fontSize: 14,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),

            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),

            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),

            borderSide: BorderSide(color: primary, width: 1.5),
          ),
        ),

        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? Colors.white
                : Colors.grey.shade500;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? primary
                : Colors.grey.shade300;
          }),
        ),

        /// =========================================
        /// BUTTONS
        /// =========================================
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,

            foregroundColor: Colors.white,

            elevation: 0,

            shadowColor: Colors.transparent,

            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),

            textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,

              fontSize: 16,
            ),
          ),
        ),

        /// =========================================
        /// FAB
        /// =========================================
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primary,

          foregroundColor: Colors.white,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        /// =========================================
        /// CHIP
        /// =========================================
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,

          disabledColor: Colors.grey.shade200,

          selectedColor: primary.withValues(alpha: 0.14),

          secondarySelectedColor: primary.withValues(alpha: 0.14),

          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        /// =========================================
        /// PAGE TRANSITIONS
        /// =========================================
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),

            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),

      /// =========================================
      /// DARK THEME
      /// =========================================
      darkTheme: ThemeData(
        useMaterial3: true,

        brightness: Brightness.dark,

        primaryColor: primary,

        scaffoldBackgroundColor: darkBg,

        visualDensity: VisualDensity.adaptivePlatformDensity,

        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

        splashFactory: NoSplash.splashFactory,

        splashColor: Colors.transparent,

        highlightColor: Colors.transparent,

        fontFamily: GoogleFonts.poppins().fontFamily,

        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,

          brightness: Brightness.dark,

          primary: primary,

          secondary: secondary,

          surface: const Color(0xFF171C2C),
        ),

        /// =========================================
        /// TEXT THEME
        /// =========================================
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
            .copyWith(
              headlineLarge: GoogleFonts.poppins(
                fontSize: 34,

                fontWeight: FontWeight.bold,

                color: Colors.white,
              ),

              headlineMedium: GoogleFonts.poppins(
                fontSize: 28,

                fontWeight: FontWeight.w700,

                color: Colors.white,
              ),

              bodyLarge: GoogleFonts.poppins(color: Colors.white, fontSize: 16),

              bodyMedium: GoogleFonts.poppins(
                color: Colors.white70,

                fontSize: 14,
              ),
            ),

        /// =========================================
        /// APP BAR
        /// =========================================
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,

          elevation: 0,

          scrolledUnderElevation: 0,

          iconTheme: const IconThemeData(color: Colors.white),

          titleTextStyle: GoogleFonts.poppins(
            color: Colors.white,

            fontSize: 24,

            fontWeight: FontWeight.bold,
          ),
        ),

        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF171C2C),
          shadowColor: Colors.black.withValues(alpha: 0.18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.zero,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF171C2C),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          hintStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: primary, width: 1.5),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF171C2C),
          disabledColor: const Color(0xFF242B3D),
          selectedColor: primary.withValues(alpha: 0.18),
          secondarySelectedColor: primary.withValues(alpha: 0.18),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? Colors.white
                : Colors.grey.shade500;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? primary
                : const Color(0xFF30384D);
          }),
        ),

        /// =========================================
        /// PAGE TRANSITIONS
        /// =========================================
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),

            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),

      routerConfig: appRouter,
    );
  }
}
