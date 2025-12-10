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
      // Save the final game result
      await _db.collection('game_results').add({
        'name': name,
        'gameTitle': gameTitle,
        'score': score,
        'date': Timestamp.now(),
      });

      // Update badges & cumulative score
      await updateStudentScore(name, gameTitle, score);

      // Clear in-progress game
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
        if (extraData != null) ...extraData,
      });
    } catch (e) {
      print('Error saving in-progress game: $e');
    }
  }

  // ---------------- Load In-Progress Game ----------------
  Future<Map<String, dynamic>?> loadInProgressGame(
      String name, String gameTitle) async {
    try {
      final doc =
      await _db.collection('in_progress_games').doc('$name-$gameTitle').get();
      return doc.exists ? doc.data() : null;
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

  // ---------------- Update Student Score & Badges ----------------
  Future<void> updateStudentScore(
      String studentEmail, String gameTitle, int score) async {
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

      // --------- FIXED: Clean game titles ---------
      String cleanGameTitle = gameTitle;
      if (gameTitle.toLowerCase().contains("carta")) {
        cleanGameTitle = "Permainan Carta Alir";
      } else if (gameTitle.toLowerCase().contains("pseudo") ||
          gameTitle.toLowerCase().contains("pseudokod")) {
        cleanGameTitle = "Pseudokod";
      }

      // Update score using the clean title
      scores[cleanGameTitle] = score;

      // --------- Badges ---------
      if (cleanGameTitle == "Pseudokod" &&
          score == 100 &&
          !badges.contains("Code Master")) {
        badges.add("Code Master");
      }

      if (cleanGameTitle == "Permainan Carta Alir" &&
          score == 100 &&
          !badges.contains("Flowchart Guru")) {
        badges.add("Flowchart Guru");
      }

      if ((scores.values.every((s) => s >= 80)) &&
          !badges.contains("High Achiever")) {
        badges.add("High Achiever");
      }

      await docRef.set({
        'name': studentEmail,
        'badges': badges,
        'scores': scores,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error updating student score & badges: $e");
    }
  }

  // ---------------- Get Student Past Results ----------------
  Stream<QuerySnapshot> getStudentResults(String name) {
    return _db
        .collection('game_results')
        .where('name', isEqualTo: name)
        .orderBy('date', descending: true)
        .limit(50)
        .snapshots();
  }

  // ---------------- Create a New Game (Teacher) ----------------
  Future<void> createGame(
      String title, List<Map<String, String>> questions) async {
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
    return _db.collection('game_results').snapshots();
  }

  // ---------------- Save Flowchart ----------------
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
      final doc =
      await _db.collection('teacher_flowcharts').doc(flowchartId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error fetching flowchart: $e');
      return null;
    }
  }

  // ---------------- Update Existing Flowchart ----------------
  Future<void> updateFlowchart(
      String flowchartId, List<String> flowchart) async {
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