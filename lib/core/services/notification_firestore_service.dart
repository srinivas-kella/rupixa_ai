import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _notificationRef =>
      _firestore.collection('notifications');

  static Future<void> addNotification({
    required String title,
    required String body,
    required String type,

    String? category,
  }) async {
    await _notificationRef.add({
      'title': title,
      'body': body,
      'type': type,
      'category': category,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getNotifications() {
    return _notificationRef.orderBy('createdAt', descending: true).snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> unreadNotifications() {
    return _notificationRef.where('isRead', isEqualTo: false).snapshots();
  }

  static Future<void> markAsRead(String notificationId) async {
    await _notificationRef.doc(notificationId).update({'isRead': true});
  }

  static Future<void> deleteNotification(String notificationId) async {
    await _notificationRef.doc(notificationId).delete();
  }

  static IconData _categoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'electricity':
        return Icons.electric_bolt_rounded;

      case 'water':
        return Icons.water_drop_rounded;

      case 'internet':
        return Icons.wifi_rounded;

      case 'rent':
        return Icons.home_rounded;

      case 'shopping':
        return Icons.shopping_bag_rounded;

      case 'food':
        return Icons.restaurant_rounded;

      case 'transport':
        return Icons.directions_car_rounded;

      case 'entertainment':
        return Icons.movie_rounded;

      default:
        return Icons.receipt_long_rounded;
    }
  }

  static Color _categoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'electricity':
        return Colors.amber;

      case 'water':
        return Colors.blue;

      case 'internet':
        return Colors.indigo;

      case 'rent':
        return Colors.green;

      case 'shopping':
        return Colors.pink;

      case 'food':
        return Colors.orange;

      case 'transport':
        return Colors.teal;

      default:
        return Colors.deepPurple;
    }
  }

  static Future<void> markAllRead() async {
    final snapshot = await _notificationRef.get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  static Future<void> deleteAllNotifications() async {
    final snapshot = await _notificationRef.get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
