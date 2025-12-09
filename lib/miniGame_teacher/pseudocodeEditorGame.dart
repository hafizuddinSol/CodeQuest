import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PseudocodeEditorGamePage extends StatefulWidget {
  final String teacherName;
  final String gameId;

  const PseudocodeEditorGamePage({super.key, required this.teacherName, required this.gameId});

  @override
  _PseudocodeEditorGamePageState createState() => _PseudocodeEditorGamePageState();
}

class _PseudocodeEditorGamePageState extends State<PseudocodeEditorGamePage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- ADD QUESTION ---
  // Opens a dialog to create a new question and saves it directly to Firestore.
  void _addQuestion() {
    // Controllers for the dialog's text fields
    final questionController = TextEditingController();
    final choiceControllers = List.generate(4, (_) => TextEditingController());
    int? correctIndex;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Add New Question"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: questionController,
                    decoration: const InputDecoration(labelText: 'Question Text'),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(4, (i) {
                    return Row(
                      children: [
                        Radio<int>(
                          value: i,
                          groupValue: correctIndex,
                          onChanged: (val) => setDialogState(() => correctIndex = val),
                        ),
                        Expanded(
                          child: TextField(
                            controller: choiceControllers[i],
                            decoration: InputDecoration(labelText: 'Choice ${i + 1}'),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  final questionText = questionController.text.trim();
                  final choices = choiceControllers.map((c) => c.text.trim()).toList();

                  if (questionText.isEmpty || choices.where((c) => c.isNotEmpty).length < 2 || correctIndex == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fill question, 2+ choices, and select correct answer")),
                    );
                    return;
                  }

                  final newQuestion = {
                    'question': questionText,
                    'choices': choices,
                    'answer': choices[correctIndex!],
                  };

                  // --- ATOMIC UPDATE: Add the new question to the array in Firestore ---
                  await _db.collection('teacher_games').doc(widget.gameId).update({
                    'pseudocode': FieldValue.arrayUnion([newQuestion]),
                    'updatedAt': Timestamp.now(),
                  });

                  if (mounted) Navigator.pop(context);
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- EDIT QUESTION ---
  // Opens a dialog pre-filled with existing data and saves the changes.
  void _editQuestion(List<dynamic> questions, int index) {
    final q = questions[index];
    final questionController = TextEditingController(text: q['question']);
    final choiceControllers = List.generate(4, (i) => TextEditingController(text: q['choices'][i]));
    int correctIndex = q['choices'].indexOf(q['answer']);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Edit Question"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: questionController,
                    decoration: const InputDecoration(labelText: 'Question Text'),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(4, (i) {
                    return Row(
                      children: [
                        Radio<int>(
                          value: i,
                          groupValue: correctIndex,
                          onChanged: (val) => setDialogState(() => correctIndex = val!),
                        ),
                        Expanded(
                          child: TextField(
                            controller: choiceControllers[i],
                            decoration: InputDecoration(labelText: 'Choice ${i + 1}'),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  final questionText = questionController.text.trim();
                  final choices = choiceControllers.map((c) => c.text.trim()).toList();

                  if (questionText.isEmpty || choices.where((c) => c.isNotEmpty).length < 2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fill question and at least 2 choices")),
                    );
                    return;
                  }

                  // --- ATOMIC UPDATE: Modify the specific question in the array ---
                  // We create a new list with the updated question and replace the whole array.
                  List<dynamic> updatedQuestions = List.from(questions);
                  updatedQuestions[index] = {
                    'question': questionText,
                    'choices': choices,
                    'answer': choices[correctIndex],
                  };

                  await _db.collection('teacher_games').doc(widget.gameId).update({
                    'pseudocode': updatedQuestions,
                    'updatedAt': Timestamp.now(),
                  });

                  if (mounted) Navigator.pop(context);
                },
                child: const Text("Save Changes"),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- DELETE QUESTION ---
  // Removes a question from the list in Firestore.
  Future<void> _deleteQuestion(List<dynamic> questions, int index) async {
    final questionToDelete = questions[index];

    // --- ATOMIC UPDATE: Remove the specific question from the array ---
    await _db.collection('teacher_games').doc(widget.gameId).update({
      'pseudocode': FieldValue.arrayRemove([questionToDelete]),
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🛠 Edit Pseudokod"),
        backgroundColor: Colors.green, // Changed color to distinguish from Flowchart
      ),
      body: StreamBuilder<DocumentSnapshot>(
        // --- REAL-TIME STREAM: Listen to the specific game document ---
        stream: _db.collection('teacher_games').doc(widget.gameId).snapshots(),
        builder: (context, snapshot) {
          // 1. Handle Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Handle Error State
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // 3. Handle No Data State
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Game not found.'));
          }

          // 4. Handle Data State
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final questions = List<Map<String, dynamic>>.from(data?['pseudocode'] ?? []);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add Question"),
                  onPressed: _addQuestion,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: questions.isEmpty
                      ? const Center(child: Text("No questions yet. Tap 'Add Question' to start!"))
                      : ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final q = questions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(q['question']),
                          subtitle: Text("Answer: ${q['answer']}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editQuestion(questions, index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteQuestion(questions, index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}