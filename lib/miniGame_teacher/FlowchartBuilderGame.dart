import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class FlowchartBuilderGame extends StatefulWidget {
  final String teacherName; // Track which teacher created the flowchart

  const FlowchartBuilderGame({super.key, required this.teacherName});

  @override
  _FlowchartBuilderGameState createState() => _FlowchartBuilderGameState();
}

class _FlowchartBuilderGameState extends State<FlowchartBuilderGame> {
  final List<String> availableBlocks = [
    'Start',
    'Input',
    'Decision',
    'Process',
    'Output',
    'End',
  ];

  List<String> flowchartSequence = [];
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛠 Flowchart Builder (Teacher)'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Drag blocks to build your flowchart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Main builder area
            Expanded(
              child: Row(
                children: [
                  // Left: Available blocks
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: availableBlocks.map((block) {
                        return Draggable<String>(
                          data: block,
                          feedback: _buildBlock(block, Colors.blueAccent),
                          childWhenDragging: _buildBlock(block, Colors.grey),
                          child: _buildBlock(block, Colors.blue[100]!),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Right: Flowchart sequence (drop area)
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                      itemCount: flowchartSequence.length + 1,
                      itemBuilder: (context, index) {
                        if (index == flowchartSequence.length) {
                          // Extra target at the end
                          return DragTarget<String>(
                            builder: (context, candidate, rejected) {
                              return Container(
                                height: 60,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.black26),
                                ),
                                alignment: Alignment.center,
                                child: const Text('Drop here to add block'),
                              );
                            },
                            onAccept: (data) {
                              setState(() {
                                flowchartSequence.add(data);
                              });
                            },
                          );
                        } else {
                          // Existing block
                          final block = flowchartSequence[index];
                          return DragTarget<String>(
                            builder: (context, candidate, rejected) {
                              return Container(
                                height: 60,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green[200],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.black26),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  block,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                            onAccept: (data) {
                              setState(() {
                                flowchartSequence.insert(index, data);
                              });
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Flowchart'),
                  onPressed: () async {
                    if (flowchartSequence.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Flowchart is empty! Add some blocks.')),
                      );
                      return;
                    }
                    await _firebaseService.saveFlowchart(
                      teacherName: widget.teacherName,
                      flowchart: flowchartSequence,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Flowchart saved successfully!')),
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Clear Flowchart'),
                  onPressed: () {
                    setState(() {
                      flowchartSequence.clear();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildBlock(String label, Color color) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black26),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
