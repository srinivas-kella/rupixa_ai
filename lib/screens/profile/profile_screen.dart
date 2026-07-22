import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rupixa_ai/screens/settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color accent = Color(0xFF00C6FF);

  @override
  Widget build(BuildContext context) {
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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),

            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 90,
                backgroundColor: Colors.transparent,
                elevation: 0,

                leading: IconButton(
                  icon: const Icon(CupertinoIcons.back),
                  onPressed: () => Navigator.pop(context),
                ),

                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    "Profile",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    children: [
                      _profileHeader(isDark),

                      const SizedBox(height: 24),

                      _settingsCard(context),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader(bool isDark) {
    final user = FirebaseAuth.instance.currentUser;

    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6), Color(0xFF00C6FF)],
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.20),
                ),
                child: CircleAvatar(
                  radius: 42,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  backgroundColor: Colors.white,
                  child: user?.photoURL == null
                      ? const Icon(CupertinoIcons.person_fill, color: primary)
                      : null,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                user?.displayName?.isNotEmpty == true
                    ? user!.displayName!
                    : "Rupixa User",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                user?.email ?? "No email connected",
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final data = snapshot.data?.data() as Map<String, dynamic>?;

                    return Text(
                      'Cloud Synced',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsCard(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.95, end: 1),
      curve: Curves.easeOutBack,

      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },

      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 450),

              reverseTransitionDuration: const Duration(milliseconds: 350),

              pageBuilder: (_, animation, _) {
                return FadeTransition(
                  opacity: animation,
                  child: const SettingsScreen(),
                );
              },
            ),
          );
        },

        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),

          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),

            child: Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),

                borderRadius: BorderRadius.circular(28),

                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),

              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),

                      gradient: const LinearGradient(
                        colors: [primary, secondary],
                      ),
                    ),

                    child: const Icon(
                      CupertinoIcons.gear_alt_fill,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          "Settings",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Theme, preferences & app settings",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(CupertinoIcons.chevron_right, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
