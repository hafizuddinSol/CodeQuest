import 'package:flutter/material.dart';

class ProgressWidget extends StatelessWidget {
  final VoidCallback? onRemove;

  const ProgressWidget({super.key, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> progressItems = [
      {'id': 1, 'name': 'Pseudocode', 'progress': 75, 'color': Colors.blue},
      {'id': 2, 'name': 'Gannchart', 'progress': 45, 'color': Colors.purple},
      {'id': 3, 'name': 'Flowchart Launch', 'progress': 90, 'color': Colors.green},
      {'id': 4, 'name': 'Minigame', 'progress': 30, 'color': Colors.orange},
    ];

    final int overallProgress = (progressItems.fold<int>(
      0,
          (sum, item) => sum + item['progress'] as int,
    ) ~/
        progressItems.length);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.trending_up, color: Color(0xFF4256A4), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Jejak Pencapaian',
                      style: TextStyle(
                        color: Color(0xFF4256A4),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: onRemove),
              ],
            ),

            const SizedBox(height: 10),

            // Progress items
            Column(
              children: progressItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['name'],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${item['progress']}%',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: item['progress'] / 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey,
                          valueColor: AlwaysStoppedAnimation<Color>(item['color']),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Summary section
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C3E),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Overall progress
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tahap Kemajuan',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$overallProgress%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Active projects
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Projek Terkini',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${progressItems.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
