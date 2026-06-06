import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _rotateController;
  late AnimationController _pulseController;

  late Animation<double> _pulseAnimation;

  String _loadingText = "Loading smart categories...";
  double _progress = 0.0;

  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();

    /// =========================
    /// FADE ANIMATION
    /// =========================

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _fadeController.forward();

    /// =========================
    /// ROTATING ANIMATION
    /// =========================

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    /// =========================
    /// PULSE ANIMATION
    /// =========================

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    /// =========================
    /// LOADING SIMULATION
    /// =========================

    _simulateLoading();

    /// =========================
    /// NAVIGATION
    /// =========================

    Future.delayed(const Duration(milliseconds: 4000), () {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;

      context.go(user == null ? AppRoutes.login : AppRoutes.dashboard);
    });
  }

  void _simulateLoading() {
    int step = 0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: 320), (timer) {
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

  Widget _buildFloatingDot({required double size, required Color color}) {
    return Container(
      height: size,
      width: size,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: color,

        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 14,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();

    _progressTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final compact = size.height < 760;
    final animationHeight = (size.height * (compact ? 0.28 : 0.36)).clamp(
      210.0,
      330.0,
    );
    final outerSize = compact ? 230.0 : 280.0;
    final ringSize = compact ? 190.0 : 230.0;
    final innerSize = compact ? 168.0 : 205.0;
    final iconSize = compact ? 108.0 : 135.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: isDark
                ? const [
                    Color(0xFF0E1320),
                    Color(0xFF171C2C),
                    Color(0xFF101623),
                  ]
                : const [
                    Color(0xFFF8F7FF),
                    Color(0xFFEDE9FF),
                    Color(0xFFFDFDFE),
                  ],
          ),
        ),

        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      /// =========================
                      /// PREMIUM CUSTOM ANIMATION
                      /// =========================
                      AnimatedBuilder(
                        animation: _rotateController,

                        builder: (context, child) {
                          return ScaleTransition(
                            scale: _pulseAnimation,

                            child: SizedBox(
                              height: animationHeight,
                              width: size.width,

                              child: Stack(
                                alignment: Alignment.center,

                                children: [
                                  /// OUTER GLOW
                                  Container(
                                    height: outerSize,
                                    width: outerSize,

                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,

                                      gradient: RadialGradient(
                                        colors: [
                                          const Color(
                                            0xFF7B61FF,
                                          ).withValues(alpha: 0.18),

                                          const Color(
                                            0xFF9D8CFF,
                                          ).withValues(alpha: 0.10),

                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),

                                  /// ROTATING RING
                                  Transform.rotate(
                                    angle:
                                        _rotateController.value * 2 * math.pi,

                                    child: Container(
                                      height: ringSize,
                                      width: ringSize,

                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,

                                        gradient: SweepGradient(
                                          colors: [
                                            Color(0xFF6C63FF),

                                            Color(0xFF8B5CF6),

                                            Color(0xFF00C6FF),

                                            Color(0xFF6C63FF),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  /// INNER WHITE CIRCLE
                                  Container(
                                    height: innerSize,
                                    width: innerSize,

                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,

                                      color:
                                          (isDark
                                                  ? const Color(0xFF171C2C)
                                                  : Colors.white)
                                              .withValues(alpha: 0.92),

                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepPurple.withValues(
                                            alpha: 0.10,
                                          ),

                                          blurRadius: 40,
                                          spreadRadius: 10,

                                          offset: const Offset(0, 15),
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// CENTER ICON
                                  Container(
                                    height: iconSize,
                                    width: iconSize,

                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),

                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,

                                        end: Alignment.bottomRight,

                                        colors: [
                                          Color(0xFF6C63FF),
                                          Color(0xFF8B5CF6),
                                        ],
                                      ),

                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF6C63FF,
                                          ).withValues(alpha: 0.30),

                                          blurRadius: 30,
                                          spreadRadius: 4,

                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),

                                    child: Icon(
                                      Icons.account_balance_wallet_rounded,

                                      color: Colors.white,
                                      size: compact ? 54 : 68,
                                    ),
                                  ),

                                  /// FLOATING DOTS
                                  Positioned(
                                    top: 40,
                                    right: 85,

                                    child: _buildFloatingDot(
                                      size: 16,

                                      color: const Color(0xFF00C6FF),
                                    ),
                                  ),

                                  Positioned(
                                    bottom: 55,
                                    left: 70,

                                    child: _buildFloatingDot(
                                      size: 12,

                                      color: const Color(0xFF8B5CF6),
                                    ),
                                  ),

                                  Positioned(
                                    top: 75,
                                    left: 60,

                                    child: _buildFloatingDot(
                                      size: 10,

                                      color: const Color(0xFF6C63FF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: compact ? 12 : 20),

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

                          child: Text(
                            'RUPIXA AI',

                            style: TextStyle(
                              fontSize: compact ? 40 : 54,
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
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),

                      SizedBox(height: compact ? 32 : 60),

                      /// =========================
                      /// PROGRESS BAR
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

                                    backgroundColor: isDark
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : Colors.white,

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
                                  color: colorScheme.onSurfaceVariant,

                                  fontSize: 15,

                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: compact ? 34 : 70),

                      /// =========================
                      /// FOOTER
                      /// =========================
                      Text(
                        'AI Powered Financial Intelligence',

                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
