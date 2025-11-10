import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class FlowchartBuilderGameStudent extends StatefulWidget {
  final String studentName;

  const FlowchartBuilderGameStudent({super.key, required this.studentName});

  @override
  _FlowchartBuilderGameStudentState createState() =>
      _FlowchartBuilderGameStudentState();
}

class _FlowchartBuilderGameStudentState
    extends State<FlowchartBuilderGameStudent> {
  final List<String> correctOrder = [
    'Start',
    'Input A, B',
    'Decision (A > B?)',
    'Output',
    'End'
  ];

  Map<String, bool> matched = {};
  int score = 0;

  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🧩 Flowchart Builder Game')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '🎯 Drag the correct shapes into sequence',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  // Draggable items
                  Expanded(
                    child: Column(
                      children: correctOrder.map((label) {
                        return Draggable<String>(
                          data: label,
                          feedback: Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(
                                label,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          childWhenDragging: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(5)),
                            child: Text(label, style: const TextStyle(color: Colors.grey)),
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(5)),
                            child: Text(label),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Drop targets
                  Expanded(
                    child: Column(
                      children:
                      List.generate(correctOrder.length, (index) {
                        String target = correctOrder[index];
                        return DragTarget<String>(
                          builder: (context, candidate, rejected) {
                            return Container(
                              height: 60,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: matched[target] == true
                                    ? Colors.green
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.black26),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                matched[target] == true
                                    ? '✅ $target'
                                    : 'Drop here ${index + 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                          onAccept: (data) {
                            setState(() {
                              if (data == target) {
                                matched[target] = true;
                                score += 10;
                              }
                            });
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Text('⭐ Score: $score',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await _firebaseService.saveGameResult(
                  name: widget.studentName,
                  gameTitle: "Flowchart Builder",
                  score: score,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Score $score saved for ${widget.studentName}!')),
                );
              },
              child: const Text('Submit Result'),
            ),
          ],
        ),
      ),
    );
  }
}
