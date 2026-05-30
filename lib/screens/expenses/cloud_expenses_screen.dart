import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import '../../core/services/firestore_service.dart';

class CloudExpensesScreen extends StatelessWidget {
  const CloudExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),

      appBar: AppBar(title: const Text('Cloud Expenses')),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.getExpensesStream(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No expenses found'));
          }

          final expenses = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),

            itemCount: expenses.length,

            itemBuilder: (context, index) {
              final expense = expenses[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(22),

                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6),
                  ],
                ),

                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.deepPurple,

                      child: Icon(
                        Icons.account_balance_wallet,

                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            expense['title'],

                            style: const TextStyle(
                              fontSize: 18,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(expense['category']),
                        ],
                      ),
                    ),

                    Text(
                      '₹ ${expense['amount']}',

                      style: const TextStyle(
                        color: Colors.red,

                        fontWeight: FontWeight.bold,

                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
