import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save game result
  Future<void> saveGameResult({
    required String name,
    required String gameTitle,
    required int score,
  }) async {
    await _db.collection('game_results').add({
      'name': name,
      'gameTitle': gameTitle,
      'score': score,
      'date': Timestamp.now(),
    });
  }

  // Get student’s past results
  Stream<QuerySnapshot> getStudentResults(String name) {
    return _db.collection('game_results')
        .where('name', isEqualTo: name)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Create a new game (teacher)
  Future<void> createGame(String title, List<Map<String, String>> questions) async {
    await _db.collection('games').add({
      'gameTitle': title,
      'questions': questions,
      'createdAt': Timestamp.now(),
    });
  }

  // Get analytics (teacher)
  Stream<QuerySnapshot> getAllResults() {
    return _db.collection('game_results').snapshots();
  }

  // Save a flowchart created by a teacher
  Future<void> saveFlowchart({
    required String teacherName,
    required List<String> flowchart,
  }) async {
    await _db.collection('teacher_flowcharts').add({
      'teacherName': teacherName,
      'flowchart': flowchart,
      'createdAt': Timestamp.now(),
    });
  }
}
