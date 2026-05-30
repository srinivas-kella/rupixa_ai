import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ADD EXPENSE

  static Future<void> addExpense({
    required String title,

    required String category,

    required double amount,
  }) async {
    try {
      final user = _auth.currentUser;

      print('USER => ${user?.uid}');

      if (user == null) {
        print('USER IS NULL');

        return;
      }

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .add({
            'title': title,

            'category': category,

            'amount': amount,

            'createdAt': Timestamp.now(),
          });

      print('EXPENSE SAVED => ${doc.id}');
    } catch (e) {
      print('FIRESTORE ERROR => $e');
    }
  }

  /// REALTIME STREAM

  static Stream<QuerySnapshot> getExpensesStream() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .snapshots();
  }

  /// DELETE EXPENSE

  static Future<void> deleteExpense(String expenseId) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }
}
