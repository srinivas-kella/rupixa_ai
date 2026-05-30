import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

class BillFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ADD BILL

  static Future<void> addBill({
    required String title,

    required String category,

    required double amount,

    required DateTime dueDate,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    await _firestore.collection('users').doc(user.uid).collection('bills').add({
      'title': title,

      'category': category,

      'amount': amount,

      'dueDate': Timestamp.fromDate(dueDate),

      'isPaid': false,

      'createdAt': Timestamp.now(),
    });
  }

  /// GET BILLS STREAM

  static Stream<QuerySnapshot> getBillsStream() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bills')
        .orderBy('dueDate')
        .snapshots();
  }

  /// DELETE BILL

  static Future<void> deleteBill(String billId) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bills')
        .doc(billId)
        .delete();
  }

  /// TOGGLE PAID STATUS

  static Future<void> togglePaidStatus({
    required String billId,

    required bool isPaid,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bills')
        .doc(billId)
        .update({'isPaid': isPaid});
  }
}
