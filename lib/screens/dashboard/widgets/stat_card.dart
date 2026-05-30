import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),

        margin: const EdgeInsets.symmetric(horizontal: 6),

        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),

          borderRadius: BorderRadius.circular(20),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            CircleAvatar(
              backgroundColor: color,

              child: Icon(icon, color: Colors.white),
            ),

            const SizedBox(height: 20),

            Text(
              title,

              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 6),

            Text(
              amount,

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
