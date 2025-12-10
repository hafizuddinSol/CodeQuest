import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gameScore.dart';
import 'FlowchartBuilderGameStudent.dart';
import 'pseudocode_game.dart';

class StudentDashboard extends StatelessWidget {
  final String studentName;

  const StudentDashboard({super.key, required this.studentName});

  @override
  Widget build(BuildContext context) {
    final studentDocRef =
    FirebaseFirestore.instance.collection('student_badges').doc(studentName);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          "Student Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8EAF6), Color(0xFFF5F5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: studentDocRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>?;

            List<String> badges = [];
            if (data != null && data['badges'] != null) {
              badges = List<String>.from(data['badges']);
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, $studentName",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2537B4),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildBadgeSection(context, badges),
                    const SizedBox(height: 22),

                    const Text(
                      "List Carta Alir Game",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2537B4)),
                    ),
                    const SizedBox(height: 12),
                    _buildGameList(
                        context,
                        'Carta Alir',
                            (String student, String gameId) =>
                            FlowchartBuilderGameStudent(
                                studentName: student, gameId: gameId)),

                    const SizedBox(height: 22),
                    const Text(
                      "List Pseudokod Game",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2537B4)),
                    ),
                    const SizedBox(height: 12),
                    _buildGameList(
                        context,
                        'pseudokod',
                            (String student, String gameId) =>
                            PseudocodeFillGamePage(
                                studentName: student, gameId: gameId)),

                    const SizedBox(height: 22),
                    const Text(
                      "List Scores",
                      style: TextStyle(fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2537B4)),
                    ),
                    const SizedBox(height: 12),
                    _buildDashboardButton(
                      context,
                      icon: Icons.bar_chart,
                      label: "View My Scores",
                      destination: ScorePage(studentName: studentName),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// --------------------------------------------
  /// LIST OF GAMES (FLOWCHART + PSEUDOCODE)
  /// --------------------------------------------
  Widget _buildGameList(BuildContext context, String type,
      Widget Function(String, String) destinationBuilder) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('teacher_games')
      .where('type', isEqualTo:type)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final games = snapshot.data!.docs;
        if (games.isEmpty) return const Text("No games available.");

        return Column(
          children: games.map((game) {
            final title = game['Title'] ?? 'Untitled Game';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: _buildDashboardButton(
                context,
                label: title,
                icon: type == 'Carta Alir' ? Icons.account_tree : Icons.code,
                destination:
                destinationBuilder(studentName, game.id), // 🔥 FIXED HERE
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// --------------------------------------------
  /// BADGE SECTION
  /// --------------------------------------------
  Widget _buildBadgeSection(BuildContext context, List<String> badges) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "My Badges",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2537B4),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 0.75,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              return _buildBadgeCard(context, badges[index]);
            },
          ),
        ],
      ),
    );
  }

  /// --------------------------------------------
  /// BADGE CARD
  /// --------------------------------------------
  Widget _buildBadgeCard(BuildContext context, String badge) {
    IconData icon;
    Color color;

    switch (badge) {
      case "Code Master":
        icon = Icons.code;
        color = Colors.orange;
        break;
      case "Flowchart Guru":
        icon = Icons.account_tree;
        color = Colors.blue;
        break;
      case "High Achiever":
        icon = Icons.star;
        color = Colors.green;
        break;
      default:
        icon = Icons.emoji_events;
        color = Colors.grey;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          badge,
          textAlign: TextAlign.center,
          softWrap: true,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// --------------------------------------------
  /// DASHBOARD BUTTON
  /// --------------------------------------------
  Widget _buildDashboardButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Widget destination,
      }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 3,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF2537B4)),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2537B4),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}