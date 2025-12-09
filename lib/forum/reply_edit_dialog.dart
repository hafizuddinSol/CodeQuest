// reply_edit_dialog.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReplyEditDialog extends StatefulWidget {
  final String questionId;
  final String replyId;
  final String currentMessage;

  const ReplyEditDialog({
    super.key,
    required this.questionId,
    required this.replyId,
    required this.currentMessage,
  });

  @override
  State<ReplyEditDialog> createState() => _ReplyEditDialogState();

  // Static method to show the dialog
  static void show(BuildContext context, {
    required String questionId,
    required String replyId,
    required String currentMessage,
  }) {
    showDialog(
      context: context,
      builder: (context) => ReplyEditDialog(
        questionId: questionId,
        replyId: replyId,
        currentMessage: currentMessage,
      ),
    );
  }
}

class _ReplyEditDialogState extends State<ReplyEditDialog> {
  late TextEditingController _messageController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: widget.currentMessage);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Text('Edit Reply'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: TextField(
        controller: _messageController,
        decoration: const InputDecoration(
          labelText: 'Your Reply',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
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

            final message = _messageController.text.trim();

            if (message.isEmpty) {
              setState(() {
                _isLoading = false;
              });
              return;
            }

            try {
              await FirebaseFirestore.instance
                  .collection('questions')
                  .doc(widget.questionId)
                  .collection('replies')
                  .doc(widget.replyId)
                  .update({
                'message': message,
              });

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reply updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              print('Error updating reply: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update reply'),
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