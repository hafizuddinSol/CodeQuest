// FlowchartBuilderGameStudent.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';

class FlowchartBuilderGameStudent extends StatefulWidget {
  final String studentName;
  final String gameId;

  const FlowchartBuilderGameStudent({
    super.key,
    required this.studentName,
    required this.gameId,
  });

  @override
  _FlowchartBuilderGameStudentState createState() =>
      _FlowchartBuilderGameStudentState();
}

class _FlowchartBuilderGameStudentState
    extends State<FlowchartBuilderGameStudent> {
  List<String> correctOrder = [
    'Mula',
    'Input A, B',
    'Keputusan (A > B?)',
    'Output',
    'Tamat'
  ];

  final Map<String, bool> matched = {};
  int score = 0;
  int timeLeft = 30;
  bool gameOver = false;
  Timer? timer;

  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _loadingGame = true;

  @override
  void initState() {
    super.initState();
    _loadTeacherGameThenCheckSaved();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _loadTeacherGameThenCheckSaved() async {
    // Attempt to load flowchart template from teacher_games/{gameId}
    try {
      final doc = await _db.collection('teacher_games').doc(widget.gameId).get();
      if (doc.exists) {
        final data = doc.data()!;
        // teacher might store the flowchart under 'Carta Alir' or 'flowchart'
        final dynamic flow = data['Carta Alir'] ?? data['flowchart'];
        if (flow != null && flow is List) {
          setState(() {
            correctOrder = flow.map((e) => e.toString()).toList();
          });
        }
        // optionally you could also adjust starting time or score based on doc
      }
    } catch (e) {
      // ignore silently or show a SnackBar if desired
    } finally {
      setState(() => _loadingGame = false);
    }

    // After loading template, check for saved student progress
    _checkSavedGame();
  }

  Future<void> _checkSavedGame() async {
    final savedState = await _firebaseService.loadInProgressGame(
        widget.studentName, "Permainan Carta Alir_${widget.gameId}");

    if (savedState != null) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Lanjutkan Permainan?"),
          content: const Text(
              "Anda mempunyai permainan belum selesai. Adakah anda ingin meneruskan?"),
          actions: [
            TextButton(
              onPressed: () {
                // Start new game
                Navigator.pop(context);
                setState(() {
                  matched.clear();
                  score = 0;
                  timeLeft = 30;
                  gameOver = false;
                });
                startTimer();
              },
              child: const Text("Mulakan Baru"),
            ),
            TextButton(
              onPressed: () {
                // Resume saved game
                setState(() {
                  score = savedState['score'] ?? 0;
                  final savedMatched = savedState['matched'] ?? {};
                  matched.clear();
                  matched.addAll(Map<String, bool>.from(savedMatched));
                  timeLeft = savedState['timeLeft'] ?? 30;
                  gameOver = false;
                });
                Navigator.pop(context);
                startTimer();
              },
              child: const Text("Teruskan"),
            ),
          ],
        ),
      );
    } else {
      startTimer();
    }
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (gameOver) return;

      if (timeLeft <= 0) {
        await endGame();
        return;
      }

      setState(() => timeLeft--);

      // Auto-save progress
      await _saveProgress();
    });
  }

  Future<void> _saveProgress() async {
    await _firebaseService.saveInProgressGame(
      name: widget.studentName,
      gameTitle: "Permainan Carta Alir_${widget.gameId}",
      score: score,
      questionIndex: 0,
      timeLeft: timeLeft,
      extraData: {'matched': matched},
    );
  }

  Future<void> endGame() async {
    if (gameOver) return;
    gameOver = true;
    timer?.cancel();

    await _firebaseService.saveGameResult(
      name: widget.studentName,
      gameTitle: "Permainan Carta Alir_${widget.gameId}",
      score: score,
    );

    await _firebaseService.deleteInProgressGame(
        widget.studentName, "Permainan Carta Alir_${widget.gameId}");

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Permainan Tamat!"),
        content: Text("Skor akhir anda: $score"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    if (_loadingGame) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧩 Carta Alir'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Stats + Resume Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "⏱ $timeLeft s",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
                Text(
                  "⭐ Skor: $score",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2537B4)),
                ),
                Text(
                  "✅ ${matched.values.where((v) => v).length}/${correctOrder.length}",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.orange),
                  tooltip: 'Resume Game',
                  onPressed: () async {
                    final savedState = await _firebaseService.loadInProgressGame(
                        widget.studentName, "Permainan Carta Alir_${widget.gameId}");
                    if (savedState != null) {
                      setState(() {
                        score = savedState['score'] ?? 0;
                        final savedMatched = savedState['matched'] ?? {};
                        matched.clear();
                        matched.addAll(Map<String, bool>.from(savedMatched));
                        timeLeft = savedState['timeLeft'] ?? 30;
                        gameOver = false;
                      });
                      startTimer();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tiada permainan untuk diteruskan!')),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  // Draggable blocks (source)
                  Expanded(
                    child: Column(
                      children: correctOrder.map((label) {
                        return Draggable<String>(
                          data: label,
                          feedback: _buildBlock(label, Colors.blueAccent),
                          childWhenDragging: _buildBlock(label, Colors.grey),
                          child: _buildBlock(label, Colors.blue[100]!),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Drop targets (destination)
                  Expanded(
                    child: Column(
                      children: List.generate(correctOrder.length, (index) {
                        final target = correctOrder[index];
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
                                    : 'Letakkan di sini ${index + 1}',
                                style:
                                const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                          onAccept: (data) async {
                            setState(() {
                              if (data == target && (matched[target] ?? false) != true) {
                                matched[target] = true;
                                score += 20;
                              }
                            });

                            await _saveProgress();

                            if (matched.length == correctOrder.length &&
                                matched.values.every((v) => v)) {
                              await endGame();
                            }
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await endGame();
              },
              child: const Text('Hantar Keputusan'),
            ),
          ],
        ),
      ),
    );
  }
}
