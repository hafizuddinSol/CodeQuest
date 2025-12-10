import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class TeacherUpdateMaterialPage extends StatefulWidget {
  const TeacherUpdateMaterialPage({super.key});

  @override
  State<TeacherUpdateMaterialPage> createState() =>
      _TeacherUpdateMaterialPageState();
}

class _TeacherUpdateMaterialPageState extends State<TeacherUpdateMaterialPage> {
  final CollectionReference _materialsCollection =
  FirebaseFirestore.instance.collection('material');

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String? selectedDocId;
  String? selectedFileName;
  String? selectedFilePath;

  void _setSelectedDocument(String docId, String title, String desc) {
    setState(() {
      selectedDocId = docId;
      _titleController.text = title;
      _descController.text = desc;
      selectedFilePath = null;
      selectedFileName = null;
    });
  }

  // Pick a new PDF file
  Future<void> _chooseFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() {
      selectedFilePath = result.files.single.path;
      selectedFileName = result.files.single.name;
    });
  }

  Future<void> _updateMaterial() async {
    if (selectedDocId == null) return;

    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill both Title and Description!')),
        );
      }
      return;
    }

    String? downloadURL;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Upload new PDF if selected
      if (selectedFilePath != null && selectedFileName != null) {
        final storageRef =
        FirebaseStorage.instance.ref().child("pdf/$selectedFileName");
        await storageRef.putFile(File(selectedFilePath!));
        downloadURL = await storageRef.getDownloadURL();
      }

      // Prepare update data
      final Map<String, Object> updateData = {
        'title': _titleController.text.trim(),
        'desc': _descController.text.trim(),
        'uploadedAt': FieldValue.serverTimestamp(),
      };

      if (downloadURL != null && selectedFileName != null) {
        updateData['pdfUrl'] = downloadURL;
        updateData['fileName'] = selectedFileName!;
      }

      // Update Firestore
      await _materialsCollection.doc(selectedDocId).update(updateData);

      if (!mounted) return;
      Navigator.pop(context); // close loading dialog

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material updated successfully!')),
        );
      }

      // Reset form
      setState(() {
        selectedDocId = null;
        selectedFilePath = null;
        selectedFileName = null;
        _titleController.clear();
        _descController.clear();
      });
    } catch (e) {
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating material: $e')),
        );
      }
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
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading materials.'));
                }
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
                    final title = doc['title'] as String? ?? 'No Title';
                    final desc = doc['desc'] as String? ?? 'No Description';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
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
            SingleChildScrollView(
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
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _chooseFile,
                        icon: const Icon(Icons.attach_file),
                        label: Text(selectedFileName ?? 'Choose PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2537B4),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
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
