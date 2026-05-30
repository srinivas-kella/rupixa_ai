import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rupixa_ai/core/services/firebase_auth_service.dart';

import '../../routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: [Color(0xFF111827), Color(0xFF1E1B4B), Color(0xFF0F172A)],
          ),
        ),

        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),

              child: Container(
                padding: const EdgeInsets.all(30),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),

                  borderRadius: BorderRadius.circular(30),

                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Container(
                      height: 90,
                      width: 90,

                      decoration: BoxDecoration(
                        color: Colors.deepPurple,

                        borderRadius: BorderRadius.circular(25),
                      ),

                      child: const Icon(
                        Icons.account_balance_wallet,

                        size: 45,

                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Rupixa',

                      style: TextStyle(
                        fontSize: 36,

                        fontWeight: FontWeight.bold,

                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Your smart expense companion',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 16,

                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),

                    const SizedBox(height: 50),

                    SizedBox(
                      width: double.infinity,

                      height: 58,

                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,

                          foregroundColor: Colors.black,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),

                        onPressed: () async {
                          final result =
                              await FirebaseAuthService.signInWithGoogle();

                          if (result == null) {
                            return;
                          }

                          if (!context.mounted) {
                            return;
                          }

                          context.go(AppRoutes.dashboard);
                        },

                        icon: const Icon(Icons.login),

                        label: const Text(
                          'Continue with Google',

                          style: TextStyle(
                            fontSize: 18,

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Text(
                      'Secure login powered by Google',

                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),

                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
