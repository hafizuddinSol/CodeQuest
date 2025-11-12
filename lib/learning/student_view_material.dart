import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentViewMaterialPage extends StatelessWidget {
  const StudentViewMaterialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Materials'),
        backgroundColor: const Color(0xFF2537B4),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('material')
            .orderBy('uploadedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading materials'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final materials = snapshot.data!.docs;

          if (materials.isEmpty) {
            return const Center(child: Text('No materials uploaded yet.'));
          }

          return ListView.builder(
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final material = materials[index];
              final title = material['title'] ?? 'No Title';
              final desc = material['desc'] ?? 'No Description';
              final file = material['file'] ?? 'No File';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(desc),
                  trailing: IconButton(
                    icon: const Icon(Icons.download, color: Color(0xFF2537B4)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opened $file')),
                      );
                      // TODO: Integrate real file open/download here
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
