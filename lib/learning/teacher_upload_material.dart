import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherUploadMaterialPage extends StatefulWidget {
  const TeacherUploadMaterialPage({super.key});

  @override
  State<TeacherUploadMaterialPage> createState() => _TeacherUploadMaterialPageState();
}

class _TeacherUploadMaterialPageState extends State<TeacherUploadMaterialPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? selectedFile;

  void _chooseFile() {
    // Replace this with actual file picker logic
    String fileName = "sample_upload.pdf"; // Mock file for now

    if (!fileName.toLowerCase().endsWith('.pdf')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file only!')),
      );
      return;
    }

    setState(() {
      selectedFile = fileName;
    });
  }

  Future<void> _uploadMaterial() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty || selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields!')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('material').add({
        'title': _titleController.text,
        'desc': _descController.text,
        'file': selectedFile,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Material "${_titleController.text}" uploaded successfully!')),
      );

      _titleController.clear();
      _descController.clear();
      setState(() {
        selectedFile = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Material'),
        backgroundColor: const Color(0xFF2537B4),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _chooseFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Choose PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2537B4),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(selectedFile ?? 'No file selected')),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _uploadMaterial,
              icon: const Icon(Icons.upload),
              label: const Text('Upload Material'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2537B4),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
