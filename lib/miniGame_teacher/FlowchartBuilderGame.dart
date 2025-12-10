import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FlowchartBuilderGame extends StatefulWidget {
  final String teacherName; // Track which teacher created the flowchart
  final String? gameId; // If null → new game, otherwise edit existing

  const FlowchartBuilderGame({super.key, required this.teacherName, this.gameId});

  @override
  _FlowchartBuilderGameState createState() => _FlowchartBuilderGameState();
}

class _FlowchartBuilderGameState extends State<FlowchartBuilderGame> {
  final List<String> availableBlocks = [
    'Mula',
    'Input A, B',
    'Keputusan (A > B?)',
    'Output',
    'Tamat'
  ];

  List<String> flowchartSequence = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.gameId != null) {
      _loadFlowchart(); // Load existing flowchart if editing
    }
  }

  Future<void> _loadFlowchart() async {
    setState(() => _loading = true);
    try {
      final doc = await _db.collection('teacher_games').doc(widget.gameId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final List<dynamic> flow = data['flowchart'] ?? [];
        flowchartSequence = flow.map((e) => e.toString()).toList();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading flowchart: $e')),
      );
    }
    setState(() => _loading = false);
  }

  Future<void> _saveFlowchart() async {
    if (flowchartSequence.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flowchart is empty! Add some blocks.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      if (widget.gameId == null) {
        // Create new flowchart
        await _db.collection('teacher_games').add({
          'teacherName': widget.teacherName,
          'Carta Alir': flowchartSequence,
          'createdAt': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carta Alir created successfully!')),
        );
      } else {
        // Update existing flowchart
        await _db.collection('teacher_games').doc(widget.gameId).update({
          'Carta Alir': flowchartSequence,
          'updatedAt': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carta Alir updated successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving Carta Alir: $e')),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameId == null
            ? '🛠 Create Carta Alir'
            : '🛠 Edit Carta Alir'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Padankan jawapan Carta Alir dengan betul',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
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
                  // Right: Flowchart drop area
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                      itemCount: flowchartSequence.length + 1,
                      itemBuilder: (context, index) {
                        if (index == flowchartSequence.length) {
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
                                child: const Text('Letak di sini untuk tambah blok'),
                              );
                            },
                            onAccept: (data) {
                              setState(() {
                                flowchartSequence.add(data);
                              });
                            },
                          );
                        } else {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save CartaAlir'),
                  onPressed: _saveFlowchart,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Clear CartaAlir'),
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