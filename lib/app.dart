import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
      /// LIGHT THEME
      /// =========================================
      theme: ThemeData(
        useMaterial3: true,

        brightness: Brightness.light,

        primaryColor: primary,

        scaffoldBackgroundColor: lightBg,

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

        /// TEXT THEME
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

        /// APP BAR
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

        /// CARD THEME
        cardTheme: CardThemeData(
          elevation: 0,

          color: Colors.white,

          shadowColor: primary.withValues(alpha: 0.08),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),

          margin: EdgeInsets.zero,
        ),

        /// INPUTS
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

        /// BUTTONS
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

        /// FAB
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primary,

          foregroundColor: Colors.white,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        /// BOTTOM SHEET
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,

          elevation: 0,
        ),

        /// DIVIDER
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade200,

          thickness: 1,
        ),

        /// CHIP
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

        /// PAGE TRANSITIONS
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),

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

        scaffoldBackgroundColor: darkBg,

        primaryColor: primary,

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

        /// TEXT THEME
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

        /// APP BAR
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

        /// CARD
        cardTheme: CardThemeData(
          elevation: 0,

          color: const Color(0xFF171C2C),

          shadowColor: Colors.black.withValues(alpha: 0.25),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),

        /// INPUTS
        inputDecorationTheme: InputDecorationTheme(
          filled: true,

          fillColor: const Color(0xFF1C2336),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,

            vertical: 20,
          ),

          hintStyle: GoogleFonts.poppins(color: Colors.white54),

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

            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
        ),

        /// BUTTONS
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

        /// FAB
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primary,

          foregroundColor: Colors.white,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        /// CHIP
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF1B2235),

          disabledColor: Colors.grey.shade800,

          selectedColor: primary.withValues(alpha: 0.18),

          secondarySelectedColor: primary.withValues(alpha: 0.18),

          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

          labelStyle: GoogleFonts.poppins(color: Colors.white),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        /// PAGE TRANSITIONS
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),

            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),

      routerConfig: appRouter,
    );
  }
}
