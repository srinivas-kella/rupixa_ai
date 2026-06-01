import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  bool isLoading = true;

  /// =========================================
  /// INIT
  /// =========================================

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  /// =========================================
  /// LOAD SETTINGS
  /// =========================================

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      notifications = prefs.getBool('notifications') ?? true;

      biometrics = prefs.getBool('biometrics') ?? false;

      cloudBackup = prefs.getBool('cloudBackup') ?? true;

      isLoading = false;
    });
  }

  /// =========================================
  /// SAVE SETTINGS
  /// =========================================

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(key, value);
  }

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

            onPressed: () async {
              Navigator.pop(context);

              await FirebaseAuth.instance.signOut();

              if (context.mounted) {
                context.go(AppRoutes.login);
              }
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

    final user = FirebaseAuth.instance.currentUser;

    final userName = user?.displayName ?? "Guest User";

    final userEmail = user?.email ?? "No Email";

    final userPhoto = user?.photoURL;

    if (isLoading) {
      return const Scaffold(body: Center(child: CupertinoActivityIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),

        slivers: [
          /// PREMIUM APPBAR
          SliverAppBar(
            pinned: true,
            floating: false,
            stretch: false,
            elevation: 0,
            systemOverlayStyle: isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            toolbarHeight: 100,
            expandedHeight: 150,
            collapsedHeight: 100,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,

            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final top = constraints.biggest.height;

                final collapsed = top <= 100;

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),

                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,

                      colors: collapsed
                          ? [
                              Colors.white.withOpacity(0.96),
                              Colors.white.withOpacity(0.88),
                            ]
                          : [const Color(0xFFF5F7FF), const Color(0xFFEFF2FF)],
                    ),

                    boxShadow: collapsed
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),

                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),

                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: collapsed ? 18 : 0,
                        sigmaY: collapsed ? 18 : 0,
                      ),

                      child: SafeArea(
                        bottom: false,

                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 10,
                          ),

                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: [
                              Expanded(
                                child: AnimatedPadding(
                                  duration: const Duration(milliseconds: 250),

                                  padding: EdgeInsets.only(
                                    bottom: collapsed ? 2 : 6,
                                  ),

                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,

                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 220,
                                        ),

                                        child: collapsed
                                            ? const SizedBox.shrink()
                                            : Container(
                                                key: const ValueKey("badge"),

                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),

                                                decoration: BoxDecoration(
                                                  color: primary.withOpacity(
                                                    0.10,
                                                  ),

                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),

                                                child: Text(
                                                  "Rupixa AI Preferences",

                                                  style: GoogleFonts.poppins(
                                                    color: primary,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                      ),

                                      SizedBox(height: collapsed ? 4 : 10),

                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,

                                        child: ShaderMask(
                                          shaderCallback: (bounds) {
                                            return const LinearGradient(
                                              colors: [
                                                Color(0xFF111827),
                                                primary,
                                                secondary,
                                              ],
                                            ).createShader(bounds);
                                          },

                                          child: Text(
                                            "Settings",

                                            maxLines: 1,

                                            overflow: TextOverflow.ellipsis,

                                            style: GoogleFonts.poppins(
                                              color: Colors.white,

                                              fontSize: collapsed ? 22 : 34,

                                              fontWeight: FontWeight.w800,

                                              letterSpacing: -1.4,

                                              height: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 14),

                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),

                                height: collapsed ? 48 : 58,
                                width: collapsed ? 48 : 58,

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    collapsed ? 18 : 22,
                                  ),

                                  gradient: const LinearGradient(
                                    colors: [primary, secondary],
                                  ),

                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.24),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),

                                child: const Icon(
                                  CupertinoIcons.sparkles,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  /// HERO PROFILE CARD
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(26),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(38),

                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primary, secondary],
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.22),
                          blurRadius: 28,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            Hero(
                              tag: "profile",

                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.white,

                                backgroundImage: userPhoto != null
                                    ? NetworkImage(userPhoto)
                                    : null,

                                child: userPhoto == null
                                    ? const Icon(
                                        CupertinoIcons.person_fill,
                                        size: 36,
                                        color: primary,
                                      )
                                    : null,
                              ),
                            ),

                            const Spacer(),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),

                                borderRadius: BorderRadius.circular(18),
                              ),

                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.checkmark_seal_fill,
                                    color: Colors.white,
                                    size: 16,
                                  ),

                                  const SizedBox(width: 6),

                                  Text(
                                    "Premium",

                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        Text(
                          userName,

                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          userEmail,

                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.82),
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),

                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              const Icon(
                                CupertinoIcons.cloud_fill,
                                color: Colors.white,
                                size: 16,
                              ),

                              const SizedBox(width: 8),

                              Text(
                                "AI Cloud Sync Enabled",

                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  Text(
                    "Preferences",

                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _premiumSwitchTile(
                    icon: CupertinoIcons.moon_fill,
                    iconColor: Colors.deepPurple,
                    title: "Dark Mode",
                    subtitle: "Enable immersive dark experience",
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
                    subtitle: "Receive alerts and AI reminders",
                    value: notifications,
                    onChanged: (value) async {
                      setState(() {
                        notifications = value;
                      });

                      await _saveSetting('notifications', value);
                    },
                  ),

                  _premiumSwitchTile(
                    icon: CupertinoIcons.lock_shield_fill,
                    iconColor: Colors.green,
                    title: "App Lock",
                    subtitle: "Protect your financial data",
                    value: biometrics,
                    onChanged: (value) async {
                      setState(() {
                        biometrics = value;
                      });

                      await _saveSetting('biometrics', value);
                    },
                  ),

                  _premiumSwitchTile(
                    icon: CupertinoIcons.cloud_fill,
                    iconColor: Colors.blue,
                    title: "Cloud Backup",
                    subtitle: "Securely backup all your data",
                    value: cloudBackup,
                    onChanged: (value) async {
                      setState(() {
                        cloudBackup = value;
                      });

                      await _saveSetting('cloudBackup', value);
                    },
                  ),

                  const SizedBox(height: 42),

                  GestureDetector(
                    onTap: () async {
                      await HapticFeedback.mediumImpact();

                      _showLogoutDialog();
                    },

                    child: Container(
                      height: 68,
                      width: double.infinity,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),

                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5A5F), Color(0xFFFF3B30)],
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.20),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
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
          ),
        ],
      ),
    );
  }

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
          color: Colors.white.withOpacity(0.92),

          borderRadius: BorderRadius.circular(28),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),

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
                color: iconColor.withOpacity(0.12),

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

              onChanged: (v) {
                onChanged(v);
              },
            ),
          ],
        ),
      ),
    );
  }
}
