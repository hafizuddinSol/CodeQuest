import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentViewMaterialPage extends StatelessWidget {
  const StudentViewMaterialPage({super.key});

  Future<void> _openFile(String url, BuildContext context) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file URL found')),
      );
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open file')),
      );
    }
  }

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
          if (snapshot.hasError) return const Center(child: Text('Error loading materials'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final materials = snapshot.data!.docs;
          if (materials.isEmpty) return const Center(child: Text('No materials uploaded yet'));

          return ListView.builder(
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final doc = materials[index];
              final title = doc['title'] ?? 'No Title';
              final desc = doc['desc'] ?? 'No Description';
              final fileUrl = doc['file'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(desc),
                  trailing: IconButton(
                    icon: const Icon(Icons.download, color: Color(0xFF2537B4)),
                    onPressed: () => _openFile(fileUrl, context),
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
