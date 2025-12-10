
import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import 'leaderboard_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PseudocodeFillGamePage extends StatefulWidget {
  final String studentName;
  final String gameId;

  const PseudocodeFillGamePage({
    super.key,
    required this.studentName,
    required this.gameId,
  });

  @override
  _PseudocodeFillGamePageState createState() =>
      _PseudocodeFillGamePageState();
}

class _PseudocodeFillGamePageState extends State<PseudocodeFillGamePage> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  int score = 0;
  int questionIndex = 0;
  int timeLeft = 30;
  bool gameOver = false;
  bool hasSavedGame = false;
  Timer? timer;
  bool _loading = true;

  List<Map<String, dynamic>> questions = [
    {
      "question": """
Kod berikut menghasilkan output apa?

int x = 5;
int y = 10;
if (x > y) {
    System.out.println("X lebih besar daripada Y");
} else {
    System.out.println("X tidak lebih besar daripada Y");
}
""",
      "answer": "X tidak lebih besar daripada Y",
      "choices": [
        "X lebih besar daripada Y",
        "X tidak lebih besar daripada Y",
        "Error",
        "Tiada output"
      ]
    },
    {
      "question": """
Lengkapkan for-loop supaya cetak nombor 1 hingga 5:

for (int i = 1; ............ 5; i++) {
    System.out.println(i);
}
""",
      "answer": "i <= 5",
      "choices": ["i < 5", "i <= 5", "i == 5", "i != 5"]
    },
    {
      "question": """
1. Mula
2. Ulang
3. Laksanakan blok penyataan berulang
4. Selagi (syarat masih benar)
5. Tamat

Pilih struktur kawalan ulangan 
""",
      "answer": "do-while",
      "choices": ["do-while", "for", "while"]
    },
    {
      "question": """
1. Mula
2. Untuk pembilang dari nilai mula 
hingga nilai henti lakukan
3. Laksanakan blok
penyataan berulang
4. Tamat Untuk
5. Tamat

Pilih struktur kawalan ulangan 
""",
      "answer": "for",
      "choices": ["do-while", "for", "while"]
    },
    {
      "question": """
1. Mula
2. Selagi (syarat masih
benar) lakukan
3. Laksanakan blok
penyataan berulang
4. Tamat Selagi
5. Tamat

Pilih struktur kawalan ulangan 
""",
      "answer": "while",
      "choices": ["do-while", "for", "while"]
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTeacherQuestionsAndState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _loadTeacherQuestionsAndState() async {
    // Try to fetch teacher-provided questions from teacher_games/{gameId}.questions
    try {
      final doc = await _db.collection('teacher_games').doc(widget.gameId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final dynamic q = data['questions'] ?? data['pseudocodeQuestions'];
        if (q != null && q is List) {
          questions = q.map((e) {
            if (e is Map<String, dynamic>) return e;
            return Map<String, dynamic>.from(e);
          }).toList();
        }
      }
    } catch (e) {
      // ignore or log if desired
    } finally {
      setState(() => _loading = false);
    }

    // Then check saved progress
    final savedState = await _firebaseService.loadInProgressGame(
      widget.studentName,
      "Pseudocode Game_${widget.gameId}",
    );

    if (savedState != null) {
      setState(() => hasSavedGame = true);

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
                Navigator.pop(context);
                startTimer();
              },
              child: const Text("Mulakan Baru"),
            ),
            TextButton(
              onPressed: () {
                _resumeGame(savedState);
                Navigator.pop(context);
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

  void _resumeGame(Map<String, dynamic> savedState) {
    setState(() {
      score = savedState['score'] ?? 0;
      questionIndex = savedState['questionIndex'] ?? 0;
      timeLeft = savedState['timeLeft'] ?? 30;
      hasSavedGame = false;
    });
    startTimer();
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

      await _firebaseService.saveInProgressGame(
        name: widget.studentName,
        gameTitle: "Pseudocode Game_${widget.gameId}",
        score: score,
        questionIndex: questionIndex,
        timeLeft: timeLeft,
      );
    });
  }

  Future<void> checkAnswer(String selected) async {
    if (gameOver) return;

    final current = questions[questionIndex];
    bool correct = selected == current["answer"];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(correct ? 'Betul! 🎉' : 'Salah ❌'),
        duration: const Duration(milliseconds: 600),
        backgroundColor: correct ? Colors.green : Colors.red,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 600));
    if (correct) score += 20;

    if (questionIndex + 1 >= questions.length) {
      await endGame();
    } else {
      setState(() => questionIndex++);
      await _firebaseService.saveInProgressGame(
        name: widget.studentName,
        gameTitle: "Pseudocode Game_${widget.gameId}",
        score: score,
        questionIndex: questionIndex,
        timeLeft: timeLeft,
      );
    }
  }

  Future<void> endGame() async {
    if (gameOver) return;
    gameOver = true;
    timer?.cancel();

    await _firebaseService.saveGameResult(
      name: widget.studentName,
      gameTitle: "Pseudocode Game_${widget.gameId}",
      score: score,
    );


    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Skor akhir anda: $score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      LeaderboardPage(gameTitle: "Pseudocode Game_${widget.gameId}"),
                ),
              );
            },
            child: const Text("Lihat Leaderboard"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQuestion = questions[questionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("🧠 Pseudokod"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Stats + Resume Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("⏱ $timeLeft s",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text("⭐ Skor: $score",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text("❌ Soalan: ${questionIndex + 1}/${questions.length}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                if (hasSavedGame)
                  IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.orange),
                    tooltip: 'Resume Game',
                    onPressed: () async {
                      final savedState =
                      await _firebaseService.loadInProgressGame(
                        widget.studentName,
                        "Pseudocode Game_${widget.gameId}",
                      );
                      if (savedState != null) _resumeGame(savedState);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
            // Question Card
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Text(
                    currentQuestion["question"],
                    style: const TextStyle(
                        fontSize: 16, height: 1.4, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Answer Buttons
            Expanded(
              flex: 5,
              child: ListView.builder(
                itemCount: (currentQuestion["choices"] as List).length,
                itemBuilder: (context, index) {
                  final choice = currentQuestion["choices"][index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: () => checkAnswer(choice),
                      child: Text(choice,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
