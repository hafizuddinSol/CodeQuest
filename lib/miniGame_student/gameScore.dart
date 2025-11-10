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
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = (snapshot.data! as QuerySnapshot).docs;
          if (docs.isEmpty) return const Center(child: Text('No scores yet'));

          return ListView(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['gameTitle'] ?? ''),
                trailing: Text(data['score']?.toString() ?? '0'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
