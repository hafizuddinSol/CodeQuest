import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TeacherUploadMaterialPage extends StatefulWidget {
  const TeacherUploadMaterialPage({super.key});

  @override
  State<TeacherUploadMaterialPage> createState() => _TeacherUploadMaterialPageState();
}

class _TeacherUploadMaterialPageState extends State<TeacherUploadMaterialPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String? selectedFileName;
  String? selectedFilePath;

  // PICK PDF FILE
  Future<void> _chooseFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    setState(() {
      selectedFilePath = result.files.single.path;
      selectedFileName = result.files.single.name;
    });
  }

  // UPLOAD PDF TO STORAGE + FIRESTORE
  Future<void> _uploadMaterial() async {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        selectedFilePath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields and select a PDF file.')),
        );
      }
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Upload PDF to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child("pdf/${selectedFileName!}");
      await storageRef.putFile(File(selectedFilePath!));

      // Get PDF download URL
      final downloadURL = await storageRef.getDownloadURL();

      // Save material data to Firestore
      await FirebaseFirestore.instance.collection('material').add({
        "title": _titleController.text,
        "desc": _descController.text, // keep field consistent with student view
        "fileName": selectedFileName,
        "pdfUrl": downloadURL,
        "uploadedAt": FieldValue.serverTimestamp(),
      });

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Material "${_titleController.text}" uploaded successfully!')),
        );
      }

      // Reset form
      _titleController.clear();
      _descController.clear();
      setState(() {
        selectedFilePath = null;
        selectedFileName = null;
      });
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
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
                  label: const Text('Choose PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2537B4),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedFileName ?? 'No file selected',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
