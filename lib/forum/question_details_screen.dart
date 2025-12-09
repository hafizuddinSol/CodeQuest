import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'user_service.dart';
import 'question_edit_dialog.dart';
import 'reply_edit_dialog.dart';
import 'reply_form.dart';

class QuestionDetailsScreen extends StatefulWidget {
  final String questionId;
  final String title;
  final String content;
  final String author;
  final bool isTeacher;
  final String userId;

  const QuestionDetailsScreen({
    super.key,
    required this.questionId,
    required this.title,
    required this.content,
    required this.author,
    required this.isTeacher,
    required this.userId,
  });

  @override
  State<QuestionDetailsScreen> createState() => _QuestionDetailsScreenState();
}

class _QuestionDetailsScreenState extends State<QuestionDetailsScreen> with TickerProviderStateMixin {
  bool _pinned = false;
  int _upvotes = 0;
  bool _userUpvoted = false;
  String _userName = "Loading...";
  String? _authorId;
  String? _category;
  int _repliesCount = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _loadQuestionData();
    _loadUserName();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();

    _scrollController.addListener(() {
      if (_scrollController.hasClients &&
          _scrollController.offset < _scrollController.position.maxScrollExtent - 200 &&
          !_showScrollToBottom) {
        setState(() {
          _showScrollToBottom = true;
        });
      } else if (_scrollController.hasClients &&
          _scrollController.offset >= _scrollController.position.maxScrollExtent - 200 &&
          _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final userName = await UserService().getUserName();
    setState(() {
      _userName = userName;
    });
  }

  Future<void> _loadQuestionData() async {
    final questionDoc = await FirebaseFirestore.instance
        .collection('questions')
        .doc(widget.questionId)
        .get();

    if (questionDoc.exists) {
      final data = questionDoc.data()!;
      setState(() {
        _pinned = data['pinned'] ?? false;
        _upvotes = data['upvotes'] ?? 0;
        _userUpvoted = data['upvotedBy'] != null &&
            data['upvotedBy'].contains(widget.userId);
        _authorId = data['authorId'] ?? '';
        _category = data['category'] ?? 'General';
        // Use null-aware operator to safely access repliesCount
        _repliesCount = data['repliesCount'] ?? 0;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _toggleUpvote() async {
    final questionRef = FirebaseFirestore.instance.collection('questions').doc(widget.questionId);

    if (_userUpvoted) {
      await questionRef.update({
        'upvotes': FieldValue.increment(-1),
        'upvotedBy': FieldValue.arrayRemove([widget.userId])
      });
      setState(() {
        _upvotes--;
        _userUpvoted = false;
      });
    } else {
      await questionRef.update({
        'upvotes': FieldValue.increment(1),
        'upvotedBy': FieldValue.arrayUnion([widget.userId])
      });
      setState(() {
        _upvotes++;
        _userUpvoted = true;
      });
    }
  }

  Future<void> _togglePin() async {
    await FirebaseFirestore.instance.collection('questions').doc(widget.questionId).update({
      'pinned': !_pinned,
    });
    setState(() {
      _pinned = !_pinned;
    });
  }

  void _showEditQuestionDialog() {
    QuestionEditDialog.show(
      context,
      questionId: widget.questionId,
      currentTitle: widget.title,
      currentContent: widget.content,
      currentCategory: _category ?? 'General',
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteQuestion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteQuestion() async {
    try {
      // First, delete all replies to this question
      final repliesSnapshot = await FirebaseFirestore.instance
          .collection('questions')
          .doc(widget.questionId)
          .collection('replies')
          .get();

      for (var doc in repliesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Then delete the question itself
      await FirebaseFirestore.instance.collection('questions').doc(widget.questionId).delete();

      // Show a success message and go back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Question deleted successfully'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error deleting question: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete question'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repliesRef = FirebaseFirestore.instance
        .collection('questions')
        .doc(widget.questionId)
        .collection('replies')
        .orderBy('timestamp', descending: true)
        .snapshots();

    final isAuthor = _authorId == widget.userId;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2537B4), Color(0xFF1A2799)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildQuestionHeader(),
                      _buildRepliesList(repliesRef),
                      ReplyForm(
                        questionId: widget.questionId,
                        userName: _userName,
                        userId: widget.userId,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _showScrollToBottom
          ? FloatingActionButton(
        heroTag: "scrollToBottom",
        onPressed: _scrollToBottom,
        backgroundColor: Colors.white,
        mini: true,
        elevation: 4,
        child: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2537B4)),
      )
          : null,
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: const Text(
              'Question Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader() {
    final isAuthor = _authorId == widget.userId;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _pinned ? const Color(0xFF2537B4).withOpacity(0.05) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: _pinned ? Border.all(color: const Color(0xFF2537B4), width: 1) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_pinned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2537B4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.push_pin, size: 16, color: const Color(0xFF2537B4)),
                    const SizedBox(width: 4),
                    Text(
                      'Pinned by teacher',
                      style: TextStyle(
                        color: const Color(0xFF2537B4),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            if (_pinned) const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(_category ?? 'General'),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _category ?? 'General',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _repliesCount > 0 ? '$_repliesCount replies' : 'No replies',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2537B4),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.content,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF2537B4).withOpacity(0.1),
                  child: Text(
                    widget.author.isNotEmpty ? widget.author[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      color: Color(0xFF2537B4),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.author,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      'Posted this question',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                InkWell(
                  onTap: _toggleUpvote,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _userUpvoted ? const Color(0xFF2537B4).withOpacity(0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _userUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                          size: 18,
                          color: _userUpvoted ? const Color(0xFF2537B4) : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _upvotes.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: _userUpvoted ? const Color(0xFF2537B4) : Colors.grey[600],
                            fontWeight: _userUpvoted ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isAuthor || widget.isTeacher)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isAuthor)
                      _buildActionButton(
                        icon: Icons.edit,
                        label: 'Edit',
                        color: Colors.blue,
                        onTap: _showEditQuestionDialog,
                      ),
                    if (isAuthor) const SizedBox(width: 8),
                    if (isAuthor)
                      _buildActionButton(
                        icon: Icons.delete,
                        label: 'Delete',
                        color: Colors.red,
                        onTap: _showDeleteConfirmation,
                      ),
                    if (isAuthor && widget.isTeacher) const SizedBox(width: 8),
                    if (widget.isTeacher)
                      _buildActionButton(
                        icon: _pinned ? Icons.push_pin : Icons.push_pin_outlined,
                        label: _pinned ? 'Unpin' : 'Pin',
                        color: _pinned ? Colors.red : Colors.green,
                        onTap: _togglePin,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepliesList(Stream<QuerySnapshot> repliesRef) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: repliesRef,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final replies = snapshot.data!.docs;

          if (replies.isEmpty) {
            return _buildEmptyRepliesState();
          }

          // Update replies count if needed
          if (_repliesCount != replies.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              FirebaseFirestore.instance
                  .collection('questions')
                  .doc(widget.questionId)
                  .update({'repliesCount': replies.length});
              setState(() {
                _repliesCount = replies.length;
              });
            });
          }

          return ListView.builder(
            key: const PageStorageKey<String>('replies_list'),
            controller: _scrollController,
            // Use AlwaysScrollableScrollPhysics for better trackpad/mouse wheel support
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.all(16),
            itemCount: replies.length,
            // Add cache extent to improve performance
            cacheExtent: 250,
            itemBuilder: (context, index) {
              final reply = replies[index];
              return _buildReplyCard(reply);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyRepliesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF2537B4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 50,
              color: Color(0xFF2537B4),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No replies yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2537B4),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to reply!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyCard(DocumentSnapshot reply) {
    final message = reply["message"];
    final name = reply["name"];
    final authorId = reply["authorId"] ?? "";
    final timestamp = reply["timestamp"] as Timestamp;
    final upvotes = reply["upvotes"] ?? 0;
    final replyId = reply.id;
    final userUpvoted = reply["upvotedBy"] != null &&
        reply["upvotedBy"].contains(widget.userId);
    final isReplyAuthor = widget.userId == authorId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF2537B4).withOpacity(0.1),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      color: Color(0xFF2537B4),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      _formatTimestamp(timestamp.toDate()),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                InkWell(
                  onTap: () async {
                    await _toggleReplyUpvote(replyId, userUpvoted);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: userUpvoted ? const Color(0xFF2537B4).withOpacity(0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          userUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                          size: 16,
                          color: userUpvoted ? const Color(0xFF2537B4) : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          upvotes.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: userUpvoted ? const Color(0xFF2537B4) : Colors.grey[600],
                            fontWeight: userUpvoted ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            if (isReplyAuthor)
              Container(
                margin: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      icon: Icons.edit,
                      label: 'Edit',
                      color: Colors.blue,
                      onTap: () {
                        ReplyEditDialog.show(
                          context,
                          questionId: widget.questionId,
                          replyId: replyId,
                          currentMessage: message,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.delete,
                      label: 'Delete',
                      color: Colors.red,
                      onTap: () => _showDeleteReplyConfirmation(replyId),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pseudocode': //Pseudokod
        return const Color(0xFF4CAF50);
      case 'Flowchart': //Carta Alir
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF2537B4);
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  Future<void> _toggleReplyUpvote(String replyId, bool currentlyUpvoted) async {
    final replyRef = FirebaseFirestore.instance
        .collection('questions')
        .doc(widget.questionId)
        .collection('replies')
        .doc(replyId);

    if (currentlyUpvoted) {
      await replyRef.update({
        'upvotes': FieldValue.increment(-1),
        'upvotedBy': FieldValue.arrayRemove([widget.userId])
      });
    } else {
      await replyRef.update({
        'upvotes': FieldValue.increment(1),
        'upvotedBy': FieldValue.arrayUnion([widget.userId])
      });
    }
  }

  void _showDeleteReplyConfirmation(String replyId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Reply'),
        content: const Text('Are you sure you want to delete this reply? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteReply(replyId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReply(String replyId) async {
    try {
      await FirebaseFirestore.instance
          .collection('questions')
          .doc(widget.questionId)
          .collection('replies')
          .doc(replyId)
          .delete();

      // Update replies count in question document
      await FirebaseFirestore.instance
          .collection('questions')
          .doc(widget.questionId)
          .update({
        'repliesCount': FieldValue.increment(-1),
      });

      // Update local state
      setState(() {
        _repliesCount = (_repliesCount > 0) ? _repliesCount - 1 : 0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reply deleted successfully'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error deleting reply: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete reply'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}