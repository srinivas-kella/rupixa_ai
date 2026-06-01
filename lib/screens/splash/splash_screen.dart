import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _loadingText = "Loading smart categories...";
  double _progress = 0.0;

  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();

    // Smooth fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _fadeController.forward();

    _simulateLoading();

    // Navigate after splash
    Future.delayed(const Duration(milliseconds: 3800), () {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;

      context.go(user == null ? AppRoutes.login : AppRoutes.dashboard);
    });
  }

  void _simulateLoading() {
    int step = 0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      step++;

      setState(() {
        _progress = (step / 12).clamp(0.0, 1.0);

        switch (step) {
          case 4:
            _loadingText = "Securing your financial data...";
            break;

          case 8:
            _loadingText = "Loading smart categories...";
            break;

          case 11:
            _loadingText = "Preparing AI insights...";
            break;
        }
      });

      if (step >= 12) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: [Color(0xFFF8F7FF), Color(0xFFEDE9FF), Color(0xFFFDFDFE)],
          ),
        ),

        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// =========================
              /// PREMIUM ANIMATION AREA
              /// =========================
              SizedBox(
                height: size.height * 0.38,
                width: size.width,

                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    /// BIG GLOW
                    Container(
                      height: 260,
                      width: 260,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF7B61FF).withValues(alpha: 0.22),

                            const Color(0xFF9D8CFF).withValues(alpha: 0.12),

                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    /// GLASS CONTAINER
                    Container(
                      height: 230,
                      width: 230,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),

                        color: Colors.white.withValues(alpha: 0.55),

                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7),
                          width: 1.5,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withValues(alpha: 0.10),
                            blurRadius: 40,
                            spreadRadius: 8,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                    ),

                    /// LOTTIE
                    Lottie.asset(
                      'assets/animations/finance_wallet.json',

                      repeat: true,

                      fit: BoxFit.contain,

                      width: 260,
                      height: 260,

                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 120,
                          color: Color(0xFF6C63FF),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// =========================
              /// APP TITLE
              /// =========================
              FadeTransition(
                opacity: _fadeAnimation,

                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFF5B4DFF), Color(0xFF8B5CF6)],
                    ).createShader(bounds);
                  },

                  child: const Text(
                    'RUPIXA',

                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 6,
                      height: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              FadeTransition(
                opacity: _fadeAnimation,

                child: Text(
                  'Smart Expense Companion',

                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              /// =========================
              /// PREMIUM PROGRESS
              /// =========================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 55),

                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),

                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: _progress),

                        duration: const Duration(milliseconds: 350),

                        curve: Curves.easeOutCubic,

                        builder: (context, value, _) {
                          return LinearProgressIndicator(
                            value: value,

                            minHeight: 9,

                            backgroundColor: Colors.white,

                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF6C63FF),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),

                      child: Text(
                        _loadingText,

                        key: ValueKey(_loadingText),

                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 70),

              /// =========================
              /// FOOTER
              /// =========================
              Text(
                'AI Powered Financial Intelligence',

                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
