import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherUpdateMaterialPage extends StatefulWidget {
  const TeacherUpdateMaterialPage({super.key});

  @override
  State<TeacherUpdateMaterialPage> createState() =>
      _TeacherUpdateMaterialPageState();
}

class _TeacherUpdateMaterialPageState extends State<TeacherUpdateMaterialPage> {
  final CollectionReference _materialsCollection =
  FirebaseFirestore.instance.collection('material');

  // Controllers for updating
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? selectedDocId;

  void _setSelectedDocument(String docId, String title, String desc) {
    setState(() {
      selectedDocId = docId;
      _titleController.text = title;
      _descController.text = desc;
    });
  }

  Future<void> _updateMaterial() async {
    if (selectedDocId == null) return;

    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill both Title and Description!')),
      );
      return;
    }

    try {
      await _materialsCollection.doc(selectedDocId).update({
        'title': _titleController.text.trim(),
        'desc': _descController.text.trim(),
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Material updated successfully!')),
      );

      setState(() {
        selectedDocId = null;
        _titleController.clear();
        _descController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating material: $e')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Materials'),
        backgroundColor: const Color(0xFF2537B4),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Material List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _materialsCollection
                  .orderBy('uploadedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Error loading materials.'));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final materials = snapshot.data?.docs ?? [];
                if (materials.isEmpty) {
                  return const Center(child: Text('No materials uploaded yet.'));
                }

                return ListView.builder(
                  itemCount: materials.length,
                  itemBuilder: (context, index) {
                    final doc = materials[index];
                    final title = doc['title'] ?? 'No Title';
                    final desc = doc['desc'] ?? 'No Description';
                    final file = doc['file'] ?? 'No File';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      child: ListTile(
                        title: Text(title),
                        subtitle: Text(desc),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _setSelectedDocument(doc.id, title, desc);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Update Form
          if (selectedDocId != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _updateMaterial,
                    icon: const Icon(Icons.update),
                    label: const Text('Update Material'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2537B4),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
