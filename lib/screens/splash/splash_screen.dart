import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;

      context.go(user == null ? AppRoutes.login : AppRoutes.dashboard);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              height: 130,
              width: 130,

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(35),

                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.15),

                    blurRadius: 25,

                    offset: const Offset(0, 10),
                  ),
                ],
              ),

              child: const Icon(
                Icons.account_balance_wallet,

                size: 70,

                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              'RUPIXA',

              style: TextStyle(
                fontSize: 38,

                fontWeight: FontWeight.bold,

                letterSpacing: 8,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Smart Expense Companion',

              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 80),

            const SizedBox(
              width: 180,

              child: LinearProgressIndicator(minHeight: 5),
            ),

            const SizedBox(height: 20),

            Text(
              'Initializing secure vault',

              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
