import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherUpdateMaterialPage extends StatefulWidget {
  const TeacherUpdateMaterialPage({super.key});

  @override
  State<TeacherUpdateMaterialPage> createState() =>
      _TeacherUpdateMaterialPageState();
}

class _TeacherUpdateMaterialPageState extends State<TeacherUpdateMaterialPage> {
  final TextEditingController _titleController =
  TextEditingController(text: "Example Material");
  final TextEditingController _descriptionController =
  TextEditingController(text: "This is an example material description.");

  String? selectedFile = "example_document.pdf";

  // Firestore collection reference (same name as upload page)
  final CollectionReference _materialsCollection =
  FirebaseFirestore.instance.collection('material');

  // Simulate file selection
  void _chooseFile() {
    setState(() {
      selectedFile = "updated_document.pdf"; // mock file selection
    });
  }

  // Update material in Firestore
  Future<void> _updateMaterial() async {
    if (_titleController.text.trim().isEmpty || selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a title and choose a file!'),
        ),
      );
      return;
    }

    try {
      // 🔥 Find the first document (for demo purposes)
      QuerySnapshot snapshot = await _materialsCollection.limit(1).get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No materials found to update!')),
        );
        return;
      }

      // Get the first document ID
      String docId = snapshot.docs.first.id;

      // Perform update
      await _materialsCollection.doc(docId).update({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'file': selectedFile!,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Material updated successfully in Firestore!'),
        ),
      );

      // Optional: clear after update
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        selectedFile = null;
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
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Material'),
        backgroundColor: const Color(0xFF2537B4),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Material Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _chooseFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Choose File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2537B4),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(selectedFile ?? 'No file selected'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
      ),
    );
  }
}
