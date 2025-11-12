//home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All'; // filter category

  @override
  Widget build(BuildContext context) {
    final CollectionReference questions =
    FirebaseFirestore.instance.collection('questions');

    Query query = questions.orderBy('timestamp', descending: true);
    if (_selectedCategory != 'All') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CodeQuest Forum',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2537B4),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 🔹 Filter dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Filter by category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Pseudocode', child: Text('Pseudocode')),
                DropdownMenuItem(value: 'Flowchart', child: Text('Flowchart')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
          ),

          // 🔹 Forum posts
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              //stream: questions.orderBy('timestamp', descending: true).snapshots(),
              //stream: query.snapshots(),
              stream: _selectedCategory == 'All'
                  ? FirebaseFirestore.instance
                  .collection('questions')
                  .orderBy('timestamp', descending: true)
                  .snapshots()
                  : FirebaseFirestore.instance
                  .collection('questions')
                  .where('category', isEqualTo: _selectedCategory)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No questions yet.\nBe the first to ask!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final data = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final question = data[index];
                    final title = question['title'] ?? '';
                    final content = question['content'] ?? '';
                    final author = question['author'] ?? 'Anonymous';
                    //final category = question['category'] ?? 'General';
                    final category = question.data().toString().contains('category')
                        ? question['category']
                        : 'General';
                    final timestamp = question['timestamp'] as Timestamp?;
                    final dateString = timestamp != null
                        ? DateFormat('dd MMM yyyy, hh:mm a')
                        .format(timestamp.toDate())
                        : 'Unknown time';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateString,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: category == 'Pseudocode'
                                        ? Colors.blue[100]
                                        : category == 'Flowchart'
                                        ? Colors.green[100]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Text(
                          author,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostDetailScreen(
                                title: title,
                                content: content,
                                author: author,
                                timestamp: dateString,
                                category: category,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2537B4),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddQuestionDialog(),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddQuestionDialog extends StatefulWidget {
  const AddQuestionDialog({super.key});

  @override
  State<AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ask a Question'),
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
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Your Name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Category'),
              items: const [
                DropdownMenuItem(value: 'Pseudocode', child: Text('Pseudocode')),
                DropdownMenuItem(value: 'Flowchart', child: Text('Flowchart')),
              ],
              initialValue: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
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
          onPressed: () async {
            final title = _titleController.text.trim();
            final content = _contentController.text.trim();
            final author = _authorController.text.trim().isEmpty
                ? 'Anonymous'
                : _authorController.text.trim();
            final category = _selectedCategory ?? 'General';

            if (title.isEmpty || content.isEmpty) return;

            await FirebaseFirestore.instance.collection('questions').add({
              'title': title,
              'content': content,
              'author': author,
              'category': category,
              'timestamp': FieldValue.serverTimestamp(),
            });

            if (context.mounted) Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2537B4),
            foregroundColor: Colors.white,
          ),
          child: const Text('Post'),
        ),
      ],
    );
  }
}

// ✅ Post Details Screen
class PostDetailScreen extends StatelessWidget {
  final String title;
  final String content;
  final String author;
  final String timestamp;
  final String category;

  const PostDetailScreen({
    super.key,
    required this.title,
    required this.content,
    required this.author,
    required this.timestamp,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: const Color(0xFF2537B4),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'By $author',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: category == 'Pseudocode'
                        ? Colors.blue[100]
                        : category == 'Flowchart'
                        ? Colors.green[100]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              timestamp,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}