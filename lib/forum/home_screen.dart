//home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'question_details_screen.dart';
import 'user_service.dart';
import 'package:sulam_project/pages/dashboardPage_student.dart';
import 'package:sulam_project/pages/dashboardPage_teacher.dart';
import 'question_edit_dialog.dart';
import 'add_question_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // TRANSLATED: 'All' -> 'Semua'
  String _selectedCategory = 'Semua';
  bool _isTeacher = false;
  String _userName = "Loading...";
  String _userId = "";
  bool _isLoading = true;
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final isTeacher = await UserService().isTeacher();
      final userName = await UserService().getUserName();
      final userId = await UserService().getUserId();

      setState(() {
        _isTeacher = isTeacher;
        _userName = userName;
        _userId = userId;
        _isLoading = false; //meaning loading is complete
      });
    } catch (e) {
      print('Error loading user data: $e'); //exceptional
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goBackToDashboard() {
    if (_isTeacher) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage_Teacher(
            userRole: 'teacher',
            username: _userName,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage_Student(
            userRole: 'student',
            username: _userName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) { // means isLoading = true, which means the screen is still loading
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
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator( //ni bulatan loading tu
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Memuatkan Forum...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold( // ni else dia which is false means the loading is complete
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
              _buildSearchAndFilter(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: _buildQuestionsList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "addQuestion",
        backgroundColor: const Color(0xFF2537B4),
        elevation: 6,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddQuestionDialog(
              isTeacher: _isTeacher,
              userName: _userName,
              userId: _userId,
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goBackToDashboard,
          ),
          Expanded(
            child: Text(
              _isTeacher ? 'Forum Guru' : 'Forum Pelajar',
              style: const TextStyle(
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

  Widget _buildSearchAndFilter() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari soalan...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF2537B4)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF2537B4)),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip('Semua', Icons.apps),
                  _buildCategoryChip('Am', Icons.chat),
                  _buildCategoryChip('Pseudokod', Icons.code),
                  _buildCategoryChip('Carta Alir', Icons.account_tree),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, IconData icon) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF2537B4)),
            const SizedBox(width: 6),
            Text(category),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF2537B4),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF2537B4),
        ),
        side: const BorderSide(color: Color(0xFF2537B4)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
        pressElevation: 4,
      ),
    );
  }

  Widget _buildQuestionsList() {
    final CollectionReference questions = FirebaseFirestore.instance.collection('questions');

    Query query = questions.orderBy('pinned', descending: true).orderBy('timestamp', descending: true);
    if (_selectedCategory != 'Semua') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final data = snapshot.data!.docs;

        // Filter by search query
        final filteredData = _searchQuery.isEmpty
            ? data
            : data.where((doc) {
          final title = doc['title']?.toString().toLowerCase() ?? '';
          final content = doc['content']?.toString().toLowerCase() ?? '';
          final author = doc['author']?.toString().toLowerCase() ?? '';
          return title.contains(_searchQuery) ||
              content.contains(_searchQuery) ||
              author.contains(_searchQuery);
        }).toList();

        if (filteredData.isEmpty) {
          return _buildNoSearchResultsState();
        }

        // Use a custom scroll physics that works better with trackpad
        return ListView.builder(
          key: const PageStorageKey<String>('questions_list'),
          controller: _scrollController,
          // Use AlwaysScrollableScrollPhysics for better trackpad/mouse wheel support
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.only(top: 16, bottom: 80),
          itemCount: filteredData.length,
          // Add cache extent to improve performance
          cacheExtent: 250,
          itemBuilder: (context, index) {
            final question = filteredData[index];
            return _buildQuestionCard(question);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF2537B4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.forum_outlined,
              size: 60,
              color: Color(0xFF2537B4),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tiada soalan lagi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2537B4),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jadi yang pertama bertanya!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddQuestionDialog(
                  isTeacher: _isTeacher,
                  userName: _userName,
                  userId: _userId,
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Tanya Soalan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2537B4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF2537B4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.search_off,
              size: 60,
              color: Color(0xFF2537B4),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tiada hasil dijumpai',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2537B4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tiada soalan sepadan dengan "${_searchController.text}"',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
            icon: const Icon(Icons.clear),
            label: const Text('Kosongkan Carian'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2537B4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(DocumentSnapshot question) {
    final id = question.id;
    final title = question['title'] ?? '';
    final content = question['content'] ?? '';
    final author = question['author'] ?? 'Anonymous';
    final authorId = question['authorId'] ?? '';
    final category = question.data().toString().contains('category')
        ? question['category']
        : 'Am';
    final timestamp = question['timestamp'] as Timestamp?;
    final dateString = timestamp != null
        ? _formatTimestamp(timestamp.toDate())
        : 'Masa tidak diketahui';
    final upvotes = question['upvotes'] ?? 0;
    final pinned = question['pinned'] ?? false;
    final userUpvoted = question['upvotedBy'] != null &&
        question['upvotedBy'].contains(_userId);
    final isAuthor = _userId == authorId;
    // Use null-aware operator to safely access repliesCount
    final repliesCount = question.data().toString().contains('repliesCount')
        ? question['repliesCount'] ?? 0
        : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        border: pinned ? Border.all(color: const Color(0xFF2537B4), width: 1.5) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuestionDetailsScreen(
                  questionId: id,
                  title: title,
                  content: content,
                  author: author,
                  isTeacher: _isTeacher,
                  userId: _userId,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pinned)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2537B4).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.push_pin, size: 16, color: const Color(0xFF2537B4)),
                      const SizedBox(width: 4),
                      Text(
                        'Dipin oleh guru',
                        style: TextStyle(
                          color: const Color(0xFF2537B4),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(category),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          dateString,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2537B4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: const Color(0xFF2537B4).withOpacity(0.1),
                          child: Text(
                            author.isNotEmpty ? author[0].toUpperCase() : 'A',
                            style: const TextStyle(
                              color: Color(0xFF2537B4),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          author,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            _buildActionButton(
                              icon: userUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                              count: upvotes,
                              isActive: userUpvoted,
                              onTap: () => _toggleUpvote(id, userUpvoted),
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              icon: Icons.comment_outlined,
                              count: repliesCount,
                              isActive: false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QuestionDetailsScreen(
                                      questionId: id,
                                      title: title,
                                      content: content,
                                      author: author,
                                      isTeacher: _isTeacher,
                                      userId: _userId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isAuthor || _isTeacher)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isAuthor)
                        _buildActionTextButton(
                          icon: Icons.edit,
                          label: 'Edit',
                          color: Colors.blue,
                          onTap: () {
                            QuestionEditDialog.show(
                              context,
                              questionId: id,
                              currentTitle: title,
                              currentContent: content,
                              currentCategory: category,
                            );
                          },
                        ),
                      if (isAuthor) const SizedBox(width: 8),
                      if (isAuthor)
                        _buildActionTextButton(
                          icon: Icons.delete,
                          label: 'Padam',
                          color: Colors.red,
                          onTap: () => _showDeleteConfirmation(context, id),
                        ),
                      if (isAuthor && _isTeacher) const SizedBox(width: 8),
                      if (_isTeacher)
                        _buildActionTextButton(
                          icon: pinned ? Icons.push_pin : Icons.push_pin_outlined,
                          label: pinned ? 'Unpin' : 'Pin',
                          color: pinned ? Colors.red : Colors.green,
                          onTap: () async {
                            await _togglePin(id, !pinned);
                          },
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? const Color(0xFF2537B4) : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                color: isActive ? const Color(0xFF2537B4) : Colors.grey[600],
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTextButton({
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pseudokod':
        return const Color(0xFF4CAF50);
      case 'Carta Alir':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF2537B4);
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru sahaja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  Future<void> _toggleUpvote(String questionId, bool currentlyUpvoted) async {
    final userId = await UserService().getUserId();
    final questionRef = FirebaseFirestore.instance.collection('questions').doc(questionId);

    if (currentlyUpvoted) {
      await questionRef.update({
        'upvotes': FieldValue.increment(-1),
        'upvotedBy': FieldValue.arrayRemove([userId])
      });
    } else {
      await questionRef.update({
        'upvotes': FieldValue.increment(1),
        'upvotedBy': FieldValue.arrayUnion([userId])
      });
    }
  }

  Future<void> _togglePin(String questionId, bool pin) async {
    await FirebaseFirestore.instance.collection('questions').doc(questionId).update({
      'pinned': pin,
    });
  }

  void _showDeleteConfirmation(BuildContext context, String questionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Padam Soalan'),
        content: const Text('Adakah anda pasti ingin memadam soalan ini? Tindakan ini tidak boleh dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteQuestion(questionId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Padam'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteQuestion(String questionId) async {
    try {
      // First, delete all replies to this question
      final repliesSnapshot = await FirebaseFirestore.instance
          .collection('questions')
          .doc(questionId)
          .collection('replies')
          .get();

      for (var doc in repliesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Then delete the question itself
      await FirebaseFirestore.instance.collection('questions').doc(questionId).delete();

      // Show a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Soalan berjaya dipadam'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error deleting question: $e'); //exceptional
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Soalan gagal dipadam'),
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