// question_edit_dialog.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionEditDialog extends StatefulWidget {
  final String questionId;
  final String currentTitle;
  final String currentContent;
  final String currentCategory;

  const QuestionEditDialog({
    super.key,
    required this.questionId,
    required this.currentTitle,
    required this.currentContent,
    required this.currentCategory,
  });

  @override
  State<QuestionEditDialog> createState() => _QuestionEditDialogState();

  // Static method to show the dialog
  static void show(BuildContext context, {
    required String questionId,
    required String currentTitle,
    required String currentContent,
    required String currentCategory,
  }) {
    showDialog(
      context: context,
      builder: (context) => QuestionEditDialog(
        questionId: questionId,
        currentTitle: currentTitle,
        currentContent: currentContent,
        currentCategory: currentCategory,
      ),
    );
  }
}

class _QuestionEditDialogState extends State<QuestionEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedCategory;
  bool _isLoading = false;

  // List of all available categories
  final List<String> _categories = ['General', 'Pseudocode', 'Flowchart']; //Pseudokod Carta Alir

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.currentTitle);
    _contentController = TextEditingController(text: widget.currentContent);

    // Initialize with the current category, default to 'General' if empty
    _selectedCategory = widget.currentCategory.isNotEmpty ? widget.currentCategory : 'General';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Text('Edit Question'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              value: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () async {
            setState(() {
              _isLoading = true;
            });

            final title = _titleController.text.trim();
            final content = _contentController.text.trim();

            if (title.isEmpty || content.isEmpty) {
              setState(() {
                _isLoading = false;
              });
              return;
            }

            try {
              Map<String, dynamic> updateData = {
                'title': title,
                'content': content,
                'category': _selectedCategory, // Always update category
              };

              await FirebaseFirestore.instance.collection('questions').doc(widget.questionId).update(updateData);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Question updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              print('Error updating question: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update question'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2537B4),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.0,
            ),
          )
              : const Text('Update'),
        ),
      ],
    );
  }
}