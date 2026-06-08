import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/notification_firestore_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(85),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Notifications',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        'Stay updated with Rupixa AI',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  icon: Container(
                    height: 42,
                    width: 42,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: colorScheme.surfaceContainerHighest,
                    ),

                    child: const Icon(Icons.more_horiz_rounded, size: 22),
                  ),

                  onSelected: (value) async {
                    if (value == 'read') {
                      _showMarkAllReadDialog(context);
                    }

                    if (value == 'delete') {
                      _showDeleteAllDialog(context);
                    }
                  },

                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'read',
                      child: Row(
                        children: [
                          Icon(Icons.done_all_rounded),
                          SizedBox(width: 10),
                          Text('Mark All Read'),
                        ],
                      ),
                    ),

                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_forever_rounded, color: Colors.red),
                          SizedBox(width: 10),
                          Text(
                            'Delete All',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: NotificationFirestoreService.getNotifications(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const _EmptyState();
          }

          final notifications = snapshot.data!.docs;

          final unreadCount = notifications.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return !(data['isRead'] ?? false);
          }).length;

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),

                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha: .25),

                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Stay Updated',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Bills, reminders, budgets & AI insights',
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Unread',
                            value: unreadCount.toString(),
                            icon: Icons.mark_email_unread_rounded,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _StatCard(
                            title: 'Total',
                            value: notifications.length.toString(),
                            icon: Icons.notifications_active_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 500));
                  },

                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),

                    itemCount: notifications.length,

                    itemBuilder: (context, index) {
                      final doc = notifications[index];

                      final data = doc.data() as Map<String, dynamic>;

                      return Dismissible(
                        key: Key(doc.id),

                        confirmDismiss: (_) async {
                          return await showCupertinoDialog<bool>(
                                context: context,

                                builder: (_) => CupertinoAlertDialog(
                                  title: const Text('Delete Notification?'),

                                  content: const Text(
                                    'This notification will be permanently deleted.',
                                  ),

                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('Cancel'),

                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                    ),

                                    CupertinoDialogAction(
                                      isDestructiveAction: true,

                                      child: const Text('Delete'),

                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                        },
                        onDismissed: (_) async {
                          await HapticFeedback.heavyImpact();

                          await NotificationFirestoreService.deleteNotification(
                            doc.id,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Notification deleted'),

                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },

                        background: Container(
                          margin: const EdgeInsets.only(bottom: 14),

                          decoration: BoxDecoration(
                            color: Colors.redAccent,

                            borderRadius: BorderRadius.circular(30),
                          ),

                          alignment: Alignment.centerRight,

                          padding: const EdgeInsets.only(right: 24),

                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                          ),
                        ),

                        child: GestureDetector(
                          onTap: () async {
                            await HapticFeedback.lightImpact();

                            if (!(data['isRead'] ?? false)) {
                              await NotificationFirestoreService.markAsRead(
                                doc.id,
                              );
                            }

                            if (context.mounted) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,

                                backgroundColor: Colors.transparent,

                                builder: (_) {
                                  return Container(
                                    padding: const EdgeInsets.all(24),

                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,

                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(32),
                                      ),
                                    ),

                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,

                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Center(
                                          child: Container(
                                            width: 50,
                                            height: 5,

                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,

                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 26,

                                              backgroundColor: _categoryColor(
                                                data['category'],
                                              ).withValues(alpha: .12),

                                              child: Icon(
                                                _categoryIcon(data['category']),

                                                color: _categoryColor(
                                                  data['category'],
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 14),

                                            Expanded(
                                              child: Text(
                                                data['title'] ?? '',

                                                style: GoogleFonts.poppins(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 20),

                                        Container(
                                          width: double.infinity,

                                          padding: const EdgeInsets.all(16),

                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,

                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),

                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,

                                            children: [
                                              if (data['amount'] != null) ...[
                                                _DetailTile(
                                                  Icons.currency_rupee_rounded,
                                                  'Amount',
                                                  '₹${data['amount']}',
                                                ),

                                                const SizedBox(height: 12),
                                              ],

                                              if (data['dueDate'] != null) ...[
                                                _DetailTile(
                                                  Icons.calendar_month_rounded,
                                                  'Due Date',
                                                  _formatDate(data['dueDate']),
                                                ),

                                                const SizedBox(height: 12),
                                              ],

                                              _DetailTile(
                                                Icons.category_rounded,
                                                'Category',
                                                data['category'] ?? 'General',
                                              ),

                                              const SizedBox(height: 12),

                                              _DetailTile(
                                                Icons.notifications_rounded,
                                                'Type',
                                                data['type'] ?? 'Notification',
                                              ),

                                              const SizedBox(height: 12),

                                              _DetailTile(
                                                Icons.description_rounded,
                                                'Message',
                                                data['body']
                                                            ?.toString()
                                                            .isNotEmpty ==
                                                        true
                                                    ? data['body']
                                                    : 'No additional details available',
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        Text(
                                          _timeAgo(data['createdAt']),

                                          style: GoogleFonts.poppins(
                                            color: Colors.grey,
                                          ),
                                        ),

                                        const SizedBox(height: 30),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                          },

                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),

                            margin: const EdgeInsets.only(bottom: 14),

                            padding: const EdgeInsets.all(18),

                            decoration: BoxDecoration(
                              color: (data['isRead'] ?? false)
                                  ? colorScheme.surface
                                  : Colors.deepPurple.withValues(alpha: .05),

                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: (data['isRead'] ?? false)
                                    ? colorScheme.outline.withValues(alpha: .15)
                                    : Colors.deepPurple.withValues(alpha: .30),
                              ),

                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 35,
                                  spreadRadius: -5,
                                  offset: const Offset(0, 10),
                                  color: Colors.black.withValues(alpha: .05),
                                ),
                              ],
                            ),

                            child: Row(
                              children: [
                                Container(
                                  height: 60,
                                  width: 60,

                                  decoration: BoxDecoration(
                                    color: _iconColor(
                                      data['type'],
                                    ).withValues(alpha: .12),

                                    borderRadius: BorderRadius.circular(18),
                                  ),

                                  child: Icon(
                                    _categoryIcon(data['category']),
                                    color: _categoryColor(data['category']),
                                    size: 28,
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _categoryColor(
                                                  data['category'],
                                                ).withValues(alpha: .12),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                data['title'] ?? '',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  color: _categoryColor(
                                                    data['category'],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          if (!(data['isRead'] ?? false))
                                            TweenAnimationBuilder(
                                              tween: Tween(
                                                begin: 0.8,
                                                end: 1.0,
                                              ),

                                              duration: const Duration(
                                                milliseconds: 900,
                                              ),

                                              builder: (_, value, child) {
                                                return Transform.scale(
                                                  scale: value,
                                                  child: child,
                                                );
                                              },

                                              child: Container(
                                                height: 10,
                                                width: 10,

                                                decoration: const BoxDecoration(
                                                  color: Colors.deepPurple,

                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        data['body'] ?? '',

                                        style: GoogleFonts.poppins(
                                          color: Colors.grey,

                                          fontSize: 13,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      Text(
                                        _timeAgo(data['createdAt']),

                                        style: GoogleFonts.poppins(
                                          fontSize: 11,

                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static IconData _icon(String? type) {
    switch (type) {
      case 'bill':
        return Icons.electric_bolt_rounded;

      case 'budget':
        return Icons.account_balance_wallet_rounded;

      case 'ai':
        return Icons.auto_awesome_rounded;

      case 'system':
        return Icons.notifications_active_rounded;

      default:
        return Icons.notifications_active_rounded;
    }
  }

  static Color _iconColor(String? type) {
    switch (type) {
      case 'bill':
        return Colors.orange;

      case 'budget':
        return Colors.green;

      case 'ai':
        return Colors.deepPurple;

      case 'system':
        return Colors.redAccent;

      default:
        return Colors.blue;
    }
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

      case 'entertainment':
        return Colors.purple;

      default:
        return Colors.deepPurple;
    }
  }

  static String _formatDate(dynamic timestamp) {
    if (timestamp == null) {
      return '-';
    }

    final date = (timestamp as Timestamp).toDate();

    return '${date.day}/${date.month}/${date.year}';
  }

  static String _timeAgo(dynamic timestamp) {
    if (timestamp == null) {
      return 'Just now';
    }

    final date = (timestamp as Timestamp).toDate();

    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) {
      return 'Just now';
    }

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }

    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }

    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  static Future<void> _showMarkAllReadDialog(BuildContext context) async {
    await showCupertinoDialog(
      context: context,

      builder: (_) => CupertinoAlertDialog(
        title: const Text('Mark All Read?'),

        content: const Text('All notifications will be marked as read.'),

        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),

            onPressed: () {
              Navigator.pop(context);
            },
          ),

          CupertinoDialogAction(
            isDefaultAction: true,

            child: const Text('Mark Read'),

            onPressed: () async {
              Navigator.pop(context);

              await HapticFeedback.lightImpact();

              await NotificationFirestoreService.markAllRead();
            },
          ),
        ],
      ),
    );
  }

  static Future<void> _showDeleteAllDialog(BuildContext context) async {
    await showCupertinoDialog(
      context: context,

      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete All Notifications?'),

        content: const Text('This action cannot be undone.'),

        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),

            onPressed: () {
              Navigator.pop(context);
            },
          ),

          CupertinoDialogAction(
            isDestructiveAction: true,

            child: const Text('Delete'),

            onPressed: () async {
              Navigator.pop(context);

              await HapticFeedback.heavyImpact();

              await NotificationFirestoreService.deleteAllNotifications();
            },
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailTile(this.icon, this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Icon(icon, size: 18, color: Colors.grey),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),

              Text(
                value,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .15),

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          Icon(icon, color: Colors.white),

          const SizedBox(height: 8),

          Text(
            value,

            style: GoogleFonts.poppins(
              color: Colors.white,

              fontWeight: FontWeight.w700,

              fontSize: 20,
            ),
          ),

          Text(
            title,

            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Container(
            height: 120,
            width: 120,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: Colors.deepPurple.withValues(alpha: .08),
            ),

            child: const Icon(Icons.notifications_active_outlined, size: 60),
          ),

          const SizedBox(height: 16),

          Text(
            "You're all caught up!",

            style: GoogleFonts.poppins(
              fontSize: 20,

              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "New reminders and alerts\nwill appear here.",

            textAlign: TextAlign.center,

            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
