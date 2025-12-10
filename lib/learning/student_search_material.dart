import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentSearchMaterialPage extends StatefulWidget {
  const StudentSearchMaterialPage({super.key});

  @override
  State<StudentSearchMaterialPage> createState() =>
      _StudentSearchMaterialPageState();
}

class _StudentSearchMaterialPageState extends State<StudentSearchMaterialPage> {
  final TextEditingController _searchController = TextEditingController();
  String query = "";

  Future<void> _openFile(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file URL available')),
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
        title: const Text('Search Material by Name'),
        backgroundColor: const Color(0xFF2537B4),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'File Name (exact)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) {
                setState(() {
                  query = val.trim();
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('material')
                    .orderBy('uploadedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error loading materials'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Filter materials by exact title match
                  final docs = snapshot.data!.docs.where((doc) {
                    final title = doc['title'] as String? ?? '';
                    return title == query; // exact match
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(
                        child: Text('No material found. Check spelling.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final title = doc['title'] as String? ?? 'No Title';
                      final desc = doc['desc'] as String? ?? 'No Description';
                      final fileUrl = doc['pdfUrl'] as String? ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text(desc),
                          trailing: IconButton(
                            icon: const Icon(Icons.download,
                                color: Color(0xFF2537B4)),
                            onPressed: () => _openFile(fileUrl),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
