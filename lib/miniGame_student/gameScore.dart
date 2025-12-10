import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScorePage extends StatelessWidget {
  final String studentName;

  const ScorePage({super.key, required this.studentName});

  @override
  Widget build(BuildContext context) {
    final FirebaseService _service = FirebaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('My Scores')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.getStudentResults(studentName),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No scores yet'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp?)?.toDate();
              final formattedDate =
              date != null ? "${date.day}/${date.month}/${date.year}" : "";

              return ListTile(
                title: Text(data['gameTitle'] ?? ''),
                subtitle: Text(formattedDate),
                trailing: Text(data['score']?.toString() ?? '0'),
              );
            },
          );
        },
      ),
    );
  }
}