import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../chat/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rupixa AI'),

        actions: [
          IconButton(
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();

              if (!context.mounted) return;

              context.go(AppRoutes.login);
            },

            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,

              MaterialPageRoute(builder: (_) => const ChatScreen()),
            );
          },

          child: const Text('Open AI Chat'),
        ),
      ),
    );
  }
}
