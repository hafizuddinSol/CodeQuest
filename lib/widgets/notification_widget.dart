import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationWidget extends StatelessWidget {
  final VoidCallback onRemove;
  final String timeFilter;   // "all", "today", "week", "month"
  final String topicFilter;  // "all", "Pembelajaran", "Permainan", "Perbincagan", "Profil", "Pseudokod", "Carta Alir"

  const NotificationWidget({
    super.key,
    required this.onRemove,
    required this.timeFilter,
    required this.topicFilter,
  });

  Color _getColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'amber':
        return Colors.amber;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'warning':
      case 'warning_amber_rounded':
        return Icons.warning_amber_rounded;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Firestore query
    Query query = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('timestamp', descending: true);

    // Topic filter latest 18/11
    if (topicFilter.toLowerCase() != 'all') {
      query = query.where('topic', isEqualTo: topicFilter);
    }

    // Time filter latest 18/11
    if (timeFilter != 'all') {
      final now = DateTime.now();
      DateTime from;

      if (timeFilter == 'today') {
        from = DateTime(now.year, now.month, now.day);
      } else if (timeFilter == 'week') {
        from = now.subtract(const Duration(days: 7));
      } else {
        // month
        final prevMonth = now.month - 1 <= 0 ? 12 : now.month - 1;
        final year = now.month - 1 <= 0 ? now.year - 1 : now.year;
        from = DateTime(year, prevMonth, now.day);
      }

      query = query.where('timestamp', isGreaterThan: from);
    }

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.notifications,
                        color: Color(0xFF4256A4), size: 22),
                    SizedBox(width: 10),
                    Text(
                      "Notifikasi",
                      style: TextStyle(
                        color: Color(0xFF4256A4),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: onRemove),
              ],
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox(
                    height: 100,
                    child: Center(
                      child: Text(
                        "No notifications available",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  );
                }

                final notifications = snapshot.data!.docs;

                return SizedBox(
                  height: 280,
                  child: ListView.separated(
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final data =
                      notifications[index].data() as Map<String, dynamic>;
                      final color = _getColor(data['color'] ?? 'grey');
                      final icon = _getIcon(data['icon'] ?? 'notifications');

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(icon, color: color, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['title'] ?? 'Untitled',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87)),
                                  const SizedBox(height: 4),
                                  Text(data['message'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black54)),
                                  const SizedBox(height: 4),
                                  Text(data['time'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
