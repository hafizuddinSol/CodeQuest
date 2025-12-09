//reply_form.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'user_service.dart';

class ReplyForm extends StatefulWidget {
  final String questionId;
  final String userName;
  final String userId;

  const ReplyForm({
    super.key,
    required this.questionId,
    required this.userName,
    required this.userId,
  });

  @override
  State<ReplyForm> createState() => _ReplyFormState();
}

class _ReplyFormState extends State<ReplyForm> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // TRANSLATED: 'Your Reply' -> 'Balasan Anda'
            'Mesej Anda',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              // TRANSLATED: 'Write your reply...' -> 'Tulis balasan anda...'
              hintText: 'Tulis mesej anda...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            maxLines: 3,
            minLines: 1,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _isSubmitting ? null : () async {
                  final msg = _messageController.text.trim();

                  if (msg.isEmpty) return;

                  setState(() {
                    _isSubmitting = true;
                  });

                  try {
                    await FirebaseFirestore.instance
                        .collection("questions")
                        .doc(widget.questionId)
                        .collection("replies")
                        .add({
                      "message": msg,
                      "name": widget.userName,
                      "authorId": widget.userId,
                      "timestamp": DateTime.now(),
                      "upvotes": 0,
                      "upvotedBy": [],
                    });

                    // Update the replies count in the question document
                    await FirebaseFirestore.instance
                        .collection("questions")
                        .doc(widget.questionId)
                        .update({
                      'repliesCount': FieldValue.increment(1),
                    });

                    _messageController.clear();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          // TRANSLATED: 'Reply posted successfully' -> 'Balasan berjaya dihantar'
                          content: const Text('Mesej berjaya dihantar'),
                          backgroundColor: Colors.green[600],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    print('Error posting reply: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          // TRANSLATED: 'Failed to post reply' -> 'Balasan gagal dihantar'
                          content: const Text('Mesej gagal dihantar'),
                          backgroundColor: Colors.red[600],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  } finally { // finally - always runs, whether success or error.
                    setState(() {
                      _isSubmitting = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2537B4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.0,
                  ),
                )
                // TRANSLATED: 'Post Reply' -> 'Hantar Balasan'
                    : const Text('Hantar Mesej'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}