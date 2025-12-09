import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatelessWidget {
  final String gameTitle;

  const LeaderboardPage({super.key, required this.gameTitle});

  @override
  Widget build(BuildContext context) {
    final col = FirebaseFirestore.instance.collection('game_results');

    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard: $gameTitle'),
        backgroundColor: Color(0xFF2537B4),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Only order by date on the server (no composite index)
        stream: col.where('gameTitle', isEqualTo: gameTitle)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Tiada skor tersedia.'));
          }

          // Convert and sort by score descending client-side (tie-breaker: earlier date wins)
          final results = docs.map((d) {
            final data = d.data() as Map<String, dynamic>;
            final name = (data['name'] ?? 'Unknown').toString();
            final scoreRaw = data['score'];
            final score = (scoreRaw is int) ? scoreRaw : (scoreRaw is num ? scoreRaw.toInt() : 0);
            final date = data['date'] is Timestamp ? (data['date'] as Timestamp).toDate() : null;
            return {
              'name': name,
              'score': score,
              'date': date,
            };
          }).toList();

          results.sort((a, b) {
            final int sa = a['score'] as int;
            final int sb = b['score'] as int;
            if (sb != sa) return sb.compareTo(sa); // by score desc
            final DateTime? da = a['date'] as DateTime?;
            final DateTime? db = b['date'] as DateTime?;
            if (da == null && db == null) return 0;
            if (da == null) return 1;
            if (db == null) return -1;
            return da.compareTo(db); // earlier date -> higher rank
          });

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: results.length,
            separatorBuilder: (_, __) => const Divider(height: 12),
            itemBuilder: (context, index) {
              final r = results[index];
              final name = r['name'] as String;
              final score = r['score'] as int;
              final date = r['date'] as DateTime?;
              final dateStr = date != null
                  ? "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}"
                  : '-';

              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(dateStr),
                trailing: Text('$score ⭐', style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          );
        },
      ),
    );
  }
}
