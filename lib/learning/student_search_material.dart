import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentSearchMaterialPage extends StatefulWidget {
  const StudentSearchMaterialPage({super.key});

  @override
  State<StudentSearchMaterialPage> createState() => _StudentSearchMaterialPageState();
}

class _StudentSearchMaterialPageState extends State<StudentSearchMaterialPage> {
  final TextEditingController _searchController = TextEditingController();
  String query = "";

  Future<void> _openFile(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Material by Name'),
        backgroundColor: const Color(0xFF2537B4),
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
                  prefixIcon: Icon(Icons.search)),
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
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs.where((doc) {
                    final title = doc['title'] ?? '';
                    return title == query; // exact match
                  }).toList();

                  if (docs.isEmpty) return const Center(child: Text('No material found. Check spelling'));

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final title = doc['title'];
                      final desc = doc['desc'];
                      final fileUrl = doc['file'] ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text(desc),
                          trailing: IconButton(
                            icon: const Icon(Icons.download, color: Color(0xFF2537B4)),
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
