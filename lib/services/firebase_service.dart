import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- Save Finished Game Result ----------------
  Future<void> saveGameResult({
    required String name,
    required String gameTitle,
    required int score,
  }) async {
    try {
      // Save the game result
      await _db.collection('game_results').add({
        'name': name,
        'gameTitle': gameTitle,
        'score': score,
        'date': Timestamp.now(),
      });

      // Update student's badges and scores
      await updateStudentScore(name, gameTitle, score);

      // Clear any in-progress game
      await clearInProgressGame(name, gameTitle);
    } catch (e) {
      print('Error saving game result: $e');
    }
  }

  // ---------------- Save In-Progress Game ----------------
  Future<void> saveInProgressGame({
    required String name,
    required String gameTitle,
    required int score,
    required int questionIndex,
    required int timeLeft,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      await _db.collection('in_progress_games').doc('$name-$gameTitle').set({
        'name': name,
        'gameTitle': gameTitle,
        'score': score,
        'questionIndex': questionIndex,
        'timeLeft': timeLeft,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error saving in-progress game: $e');
    }
  }



  // ---------------- Load In-Progress Game ----------------
  Future<Map<String, dynamic>?> loadInProgressGame(String name, String gameTitle) async {
    try {
      final doc = await _db.collection('in_progress_games').doc('$name-$gameTitle').get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error loading in-progress game: $e');
      return null;
    }
  }

  // ---------------- Clear In-Progress Game ----------------
  Future<void> clearInProgressGame(String name, String gameTitle) async {
    try {
      await _db.collection('in_progress_games').doc('$name-$gameTitle').delete();
    } catch (e) {
      print('Error clearing in-progress game: $e');
    }
  }

  //Delete In Progress
  Future<void> deleteInProgressGame(String name, String gameTitle) async {
    try {
      await _db
          .collection('in_progress_games')
          .doc('$name-$gameTitle')
          .delete();
    } catch (e) {
      print('Error deleting in-progress game: $e');
    }
  }


  // ---------------- Update Student Score & Badges ----------------
  Future<void> updateStudentScore(String studentEmail, String gameTitle, int score) async {
    final docRef = _db.collection('student_badges').doc(studentEmail);

    try {
      final snapshot = await docRef.get();
      List<String> badges = [];
      Map<String, dynamic> scores = {};

      if (snapshot.exists) {
        final data = snapshot.data()!;
        badges = List<String>.from(data['badges'] ?? []);
        scores = Map<String, dynamic>.from(data['scores'] ?? {});
      }

      // Update score
      scores[gameTitle] = score;

      // Assign badges based on performance
      if (gameTitle == "Pseudocode Game" && score == 100 && !badges.contains("Code Master")) {
        badges.add("Code Master");
      }
      if (gameTitle == "Permainan Carta Alir" && score == 100 && !badges.contains("Flowchart Guru")) {
        badges.add("Flowchart Guru");
      }

      // High Achiever badge: ≥80 in both games
      if ((scores['Pseudocode Game'] ?? 0) >= 80 &&
          (scores['Permainan Carta Alir'] ?? 0) >= 80) {
        if (!badges.contains("High Achiever")) badges.add("High Achiever");
      }

      // Save/update the student document
      await docRef.set({
        'name': studentEmail, // change to actual name if available
        'badges': badges,
        'scores': scores,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error updating student score & badges: $e");
    }
  }

  // ---------------- Get Student's Past Results ----------------
  Stream<QuerySnapshot> getStudentResults(String name) {
    try {
      return _db
          .collection('game_results')
          .where('name', isEqualTo: name)
          .orderBy('date', descending: true)
          .limit(50) // load only latest 50 scores
          .snapshots();
    } catch (e) {
      print('Error fetching student results: $e');
      rethrow;
    }
  }

  // ---------------- Create a New Game (Teacher) ----------------
  Future<void> createGame(String title, List<Map<String, String>> questions) async {
    try {
      await _db.collection('games').add({
        'gameTitle': title,
        'questions': questions,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error creating game: $e');
    }
  }

  // ---------------- Get All Results (Teacher Analytics) ----------------
  Stream<QuerySnapshot> getAllResults() {
    try {
      return _db.collection('game_results').snapshots();
    } catch (e) {
      print('Error fetching all results: $e');
      rethrow;
    }
  }

  // ---------------- Save Flowchart (Teacher) ----------------
  Future<void> saveFlowchart({
    required String teacherName,
    required List<String> flowchart,
  }) async {
    try {
      await _db.collection('teacher_flowcharts').add({
        'teacherName': teacherName,
        'flowchart': flowchart,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error saving flowchart: $e');
    }
  }

  // ---------------- Get Flowchart By ID ----------------
  Future<Map<String, dynamic>?> getFlowchartById(String flowchartId) async {
    try {
      final doc = await _db.collection('teacher_flowcharts').doc(flowchartId).get();
      if (doc.exists) return doc.data();
      return null;
    } catch (e) {
      print('Error fetching flowchart: $e');
      return null;
    }
  }

  // ---------------- Update Existing Flowchart ----------------
  Future<void> updateFlowchart(String flowchartId, List<String> flowchart) async {
    try {
      await _db.collection('teacher_flowcharts').doc(flowchartId).update({
        'flowchart': flowchart,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating flowchart: $e');
    }
  }
}