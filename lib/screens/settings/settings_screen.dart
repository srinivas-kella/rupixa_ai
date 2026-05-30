import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../routes/app_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color primary = Color(0xFF5B67FF);

  static const Color secondary = Color(0xFF7B61FF);

  bool notifications = true;

  bool biometrics = false;

  bool cloudBackup = true;

  /// =========================================
  /// LOGOUT POPUP
  /// =========================================

  Future<void> _showLogoutDialog() async {
    await showCupertinoDialog(
      context: context,

      builder: (context) => CupertinoAlertDialog(
        title: Text(
          "Logout",

          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),

        content: Padding(
          padding: const EdgeInsets.only(top: 10),

          child: Text(
            "Are you sure you want to logout from Rupixa AI?",

            style: GoogleFonts.poppins(),
          ),
        ),

        actions: [
          CupertinoDialogAction(
            child: Text(
              "Cancel",

              style: GoogleFonts.poppins(color: Colors.grey),
            ),

            onPressed: () {
              Navigator.pop(context);
            },
          ),

          CupertinoDialogAction(
            isDestructiveAction: true,

            child: Text(
              "Logout",

              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),

            onPressed: () {
              Navigator.pop(context);

              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),

      appBar: AppBar(
        backgroundColor: Colors.transparent,

        elevation: 0,

        centerTitle: false,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Settings",

              style: GoogleFonts.poppins(
                fontSize: 30,

                fontWeight: FontWeight.w700,

                color: Colors.black,
              ),
            ),

            Text(
              "Manage your preferences",

              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,

                fontSize: 13,
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            /// ====================================
            /// PROFILE CARD
            /// ====================================
            ClipRRect(
              borderRadius: BorderRadius.circular(36),

              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(28),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primary, secondary],
                    ),

                    borderRadius: BorderRadius.circular(36),

                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.35),

                        blurRadius: 28,

                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),

                            width: 2,
                          ),
                        ),

                        child: const CircleAvatar(
                          radius: 34,

                          backgroundColor: Colors.white,

                          child: Icon(
                            CupertinoIcons.person_fill,

                            size: 36,

                            color: primary,
                          ),
                        ),
                      ),

                      const SizedBox(width: 18),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              'Nani',

                              style: GoogleFonts.poppins(
                                color: Colors.white,

                                fontSize: 26,

                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,

                                vertical: 6,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),

                                borderRadius: BorderRadius.circular(14),
                              ),

                              child: Text(
                                'Premium Member',

                                style: GoogleFonts.poppins(
                                  color: Colors.white,

                                  fontWeight: FontWeight.w500,

                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),

                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          CupertinoIcons.star_fill,

                          color: Colors.white,

                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 34),

            /// ====================================
            /// PREFERENCES
            /// ====================================
            Text(
              "Preferences",

              style: GoogleFonts.poppins(
                fontSize: 22,

                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 20),

            _premiumSwitchTile(
              icon: CupertinoIcons.moon_fill,

              iconColor: Colors.deepPurple,

              title: "Dark Mode",

              subtitle: "Enable premium dark appearance",

              value: isDark,

              onChanged: (value) async {
                await HapticFeedback.lightImpact();

                themeProvider.toggleTheme(value);
              },
            ),

            _premiumSwitchTile(
              icon: CupertinoIcons.bell_fill,

              iconColor: Colors.orange,

              title: "Notifications",

              subtitle: "Receive reminders and alerts",

              value: notifications,

              onChanged: (value) async {
                await HapticFeedback.lightImpact();

                setState(() {
                  notifications = value;
                });
              },
            ),

            _premiumSwitchTile(
              icon: CupertinoIcons.lock_shield_fill,

              iconColor: Colors.green,

              title: "Face ID / App Lock",

              subtitle: "Secure your financial data",

              value: biometrics,

              onChanged: (value) async {
                await HapticFeedback.lightImpact();

                setState(() {
                  biometrics = value;
                });
              },
            ),

            _premiumSwitchTile(
              icon: CupertinoIcons.cloud_fill,

              iconColor: Colors.blue,

              title: "Cloud Backup",

              subtitle: "Automatically sync app data",

              value: cloudBackup,

              onChanged: (value) async {
                await HapticFeedback.lightImpact();

                setState(() {
                  cloudBackup = value;
                });
              },
            ),

            const SizedBox(height: 34),

            /// ====================================
            /// DATA & SECURITY
            /// ====================================
            Text(
              "Data & Security",

              style: GoogleFonts.poppins(
                fontSize: 22,

                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 20),

            _actionTile(
              icon: CupertinoIcons.arrow_down_doc_fill,

              color: Colors.deepPurple,

              title: "Export Data",

              subtitle: "Download all financial records",

              onTap: () async {
                await HapticFeedback.mediumImpact();
              },
            ),

            _actionTile(
              icon: CupertinoIcons.cloud_upload_fill,

              color: Colors.blue,

              title: "Backup Data",

              subtitle: "Create secure cloud backup",

              onTap: () async {
                await HapticFeedback.mediumImpact();
              },
            ),

            _actionTile(
              icon: CupertinoIcons.lock_fill,

              color: Colors.orange,

              title: "Privacy Policy",

              subtitle: "Review data protection terms",

              onTap: () async {
                await HapticFeedback.mediumImpact();
              },
            ),

            _actionTile(
              icon: CupertinoIcons.doc_text_fill,

              color: Colors.green,

              title: "Terms & Conditions",

              subtitle: "Read app usage guidelines",

              onTap: () async {
                await HapticFeedback.mediumImpact();
              },
            ),

            const SizedBox(height: 34),

            /// ====================================
            /// APP INFO
            /// ====================================
            Container(
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(30),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),

                    blurRadius: 16,

                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(
                children: [
                  Row(
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

                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 18),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Rupixa AI",

                              style: GoogleFonts.poppins(
                                fontSize: 20,

                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "Version 1.0.0",

                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Divider(color: Colors.grey.shade200),

                  const SizedBox(height: 18),

                  Text(
                    "AI-powered premium finance management platform designed for modern financial tracking and smart insights.",

                    textAlign: TextAlign.center,

                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,

                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// ====================================
            /// LOGOUT BUTTON
            /// ====================================
            GestureDetector(
              onTap: () async {
                await HapticFeedback.mediumImpact();

                _showLogoutDialog();
              },

              child: Container(
                height: 64,
                width: double.infinity,

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF5A5F), Color(0xFFFF3B30)],
                  ),

                  borderRadius: BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.25),

                      blurRadius: 24,

                      offset: Offset(0, 12),
                    ),
                  ],
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    const Icon(
                      CupertinoIcons.square_arrow_right_fill,

                      color: Colors.white,
                    ),

                    const SizedBox(width: 12),

                    Text(
                      "Logout",

                      style: GoogleFonts.poppins(
                        color: Colors.white,

                        fontSize: 18,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================================
  /// SWITCH TILE
  /// =========================================

  Widget _premiumSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(28),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),

              blurRadius: 16,

              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),

                borderRadius: BorderRadius.circular(18),
              ),

              child: Icon(icon, color: iconColor),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: GoogleFonts.poppins(
                      fontSize: 17,

                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    subtitle,

                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,

                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            CupertinoSwitch(
              activeTrackColor: primary,

              value: value,

              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  /// =========================================
  /// ACTION TILE
  /// =========================================

  Widget _actionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: GestureDetector(
        onTap: onTap,

        child: Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(28),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),

                blurRadius: 16,

                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),

                  borderRadius: BorderRadius.circular(18),
                ),

                child: Icon(icon, color: color),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: GoogleFonts.poppins(
                        fontSize: 17,

                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      subtitle,

                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,

                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                CupertinoIcons.chevron_right,

                size: 18,

                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
