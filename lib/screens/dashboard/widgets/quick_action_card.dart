import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {
  final IconData icon;

  final String title;

  final VoidCallback onTap;

  const QuickActionCard({
    super.key,

    required this.icon,

    required this.title,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 100,

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(24),

          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),

        child: Column(
          children: [
            CircleAvatar(
              radius: 26,

              backgroundColor: Colors.deepPurple.withValues(alpha: 0.12),

              child: Icon(icon, color: Colors.deepPurple),
            ),

            const SizedBox(height: 14),

            Text(
              title,

              textAlign: TextAlign.center,

              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
