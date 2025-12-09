import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'FlowchartBuilderGame.dart';
import 'pseudocodeEditorGame.dart';
import 'analyticsGame.dart';


class StudentsPage extends StatefulWidget {
  const StudentsPage({Key? key}) : super(key: key);

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          "Students",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Student').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No students found."));

          final students = snapshot.data!.docs;

          return Scrollbar(
            controller: _scrollController,
            thickness: 6.0,
            radius: const Radius.circular(10),
            child: ListView.builder(

              controller: _scrollController,
              itemCount: students.length,
              itemBuilder: (context, index) {
                final doc = students[index];
                final data = doc.data() as Map<String, dynamic>;
                final username = data['username'] ?? 'Unknown';
                final email = data['email'] ?? 'No email';
                final createdAt = data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate().toString() : 'No date';

                return ListTile(
                  leading: CircleAvatar(child: Text(username.isNotEmpty ? username[0].toUpperCase() : '?')),
                  title: Text(username),
                  subtitle: Text(email),
                  trailing: Text(createdAt.split(' ').first, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


// ===================================================================
// PAGE: Mini Games List
// ===================================================================
class MiniGamesListPage extends StatefulWidget {
  final String teacherName;
  const MiniGamesListPage({Key? key, required this.teacherName}) : super(key: key);

  @override
  State<MiniGamesListPage> createState() => _MiniGamesListPageState();
}

class _MiniGamesListPageState extends State<MiniGamesListPage> {

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          "Mini Game List",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: Column(mainAxisAlignment: MainAxisAlignment.end, children: [

        FloatingActionButton(
          heroTag: "migrateButton", backgroundColor: Colors.red,
          onPressed: _migrateFromFlowchartsToGames,
          child: const Icon(Icons.upload_file, color: Colors.white), tooltip: 'Migrate Old Games',
        ),
        const SizedBox(height: 10),

        FloatingActionButton.extended(
          heroTag: "createButton", backgroundColor: Colors.indigo,
          icon: const Icon(Icons.add, size: 28),
          label: const Text("Create Game", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          onPressed: () => _showGameTypeSelector(context),
        ),
      ]),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('teacher_games').where('teacherName', isEqualTo: widget.teacherName).orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No games available. Tap '+' to create one!"));

          final games = snapshot.data!.docs;
          return Scrollbar(
            controller: _scrollController,
            thickness: 6.0,
            radius: const Radius.circular(10),
            child: ListView.builder(

              controller: _scrollController,
              itemCount: games.length,
              itemBuilder: (context, index) {
                final doc = games[index];
                final data = doc.data() as Map<String, dynamic>;
                final title = data['Title'] ?? 'Untitled Game';
                final gameType = data['type'] as String? ?? 'Unknown';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: _getGameTypeColor(gameType), child: Icon(_getGameTypeIcon(gameType), color: Colors.white)),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Type: $gameType"),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit, color: Color(0xFF2537B4)), onPressed: () => _editGameTitle(context, doc.id, title)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDeleteGame(context, doc.id, title)),
                    ]),
                    onTap: () => _openEditor(context, doc),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // --- NAVIGATION & EDITOR LOGIC ---
  void _openEditor(BuildContext context, DocumentSnapshot game) {
    final type = game['type'] as String?;
    final id = game.id;
    if (type == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: Game type is missing."), backgroundColor: Colors.red)); return; }

    Widget page;
    switch (type) {
      case "Carta Alir":
        page = FlowchartBuilderGame(teacherName: widget.teacherName, gameId: id);
        break;
      case "pseudokod":
        page = PseudocodeEditorGamePage(teacherName: widget.teacherName, gameId: id);
        break;
      default:
        page = const Scaffold(body: Center(child: Text("Error: Unknown game type.")));
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _showGameTypeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("Create New Game", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ListTile(leading: const Icon(Icons.account_tree, color: Colors.blue), title: const Text("Carta Alir"), onTap: () { Navigator.pop(context); _createGame(context, "Carta Alir"); }),
          ListTile(leading: const Icon(Icons.code, color: Colors.green), title: const Text("Pseudokod"), onTap: () { Navigator.pop(context); _createGame(context, "pseudokod"); }),
        ]),
      ),
    );
  }

  Future<void> _createGame(BuildContext context, String type) async {
    final newDocRef = await FirebaseFirestore.instance.collection('teacher_games').add({
      'type': type, 'Title': "$type ", 'teacherName': widget.teacherName, 'createdAt': Timestamp.now(),
      if (type == "Carta Alir") "Carta Alir": [], if (type == "pseudokod") "pseudokod": [],
    });
    final newDocSnapshot = await newDocRef.get();
    _openEditor(context, newDocSnapshot);
  }

  void _editGameTitle(BuildContext context, String gameId, String oldTitle) async {
    final titleCtrl = TextEditingController(text: oldTitle);
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text("Edit Game Title"),
      content: TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: "Game title")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        TextButton(onPressed: () async { if (titleCtrl.text.trim().isEmpty) return; await FirebaseFirestore.instance.collection('teacher_games').doc(gameId).update({'Title': titleCtrl.text.trim()}); Navigator.pop(context); }, child: const Text("Save")),
      ],
    ));
  }

  void _confirmDeleteGame(BuildContext context, String gameId, String title) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text("Delete Game"), content: Text("Adakah anda pasti ingin hapuskan \"$title\"?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        TextButton(onPressed: () async { await FirebaseFirestore.instance.collection('teacher_games').doc(gameId).delete(); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Game \"$title\" deleted."))); }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
      ],
    ));
  }

  Future<void> _migrateFromFlowchartsToGames() async {
    final bool? confirm = await showDialog<bool>(context: context, builder: (context) => const AlertDialog(
      title: Text("Confirm Migration"), content: Text("This will move all games from 'teacher_flowcharts' to 'teacher_games' and set their type to 'flowchart'. This is a one-time operation. Continue?"),
      actions: [TextButton(child: Text("Cancel"), onPressed: null), TextButton(child: Text("Migrate"), onPressed: null)],
    ));
    if (confirm != true) return;
    print("Starting migration...");
    final querySnapshot = await FirebaseFirestore.instance.collection('teacher_flowcharts').get();
    final batch = FirebaseFirestore.instance.batch(); int migratedCount = 0;
    for (var doc in querySnapshot.docs) { batch.set(FirebaseFirestore.instance.collection('teacher_games').doc(), {...doc.data()!, 'type': 'Carta Alir'}); migratedCount++; }
    if (migratedCount > 0) { await batch.commit(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully migrated $migratedCount games."))); } else { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No games found to migrate."))); }
  }

  Color _getGameTypeColor(String? type) { switch (type) { case "Carta Alir": return Colors.blue; case "pseudokod": return Colors.green; default: return Colors.grey; } }
  IconData _getGameTypeIcon(String? type) { switch (type) { case "Carta Alir": return Icons.account_tree; case "pseudokod": return Icons.code; default: return Icons.help_outline; } }
}

// PAGE: Leaderboard

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildLeaderboard(String gameTitle) {
    return Card(
      margin: const EdgeInsets.all(8.0), elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("$gameTitle Leaderboard", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            // --- ADDED: Wrap ListView with a Scrollbar ---
            child: Scrollbar(
              controller: _scrollController,
              thickness: 6.0,
              radius: const Radius.circular(10),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('game_results').where('gameTitle', isEqualTo: gameTitle).orderBy('score', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No data available."));
                  final results = snapshot.data!.docs;
                  Map<String, int> leaderboard = {};
                  for (var doc in results) { final data = doc.data() as Map<String, dynamic>; final studentName = data['name'] ?? 'Unknown'; final score = data['score'] ?? 0; if (!leaderboard.containsKey(studentName) || leaderboard[studentName]! < score) { leaderboard[studentName] = score; } }
                  final sortedLeaderboard = leaderboard.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
                  return ListView.builder(
                    // --- ADDED: Assign the controller to the ListView ---
                    controller: _scrollController,
                    itemCount: sortedLeaderboard.length,
                    itemBuilder: (context, index) {
                      final entry = sortedLeaderboard[index]; final studentName = entry.key; final score = entry.value;
                      return ListTile(leading: CircleAvatar(child: Text(studentName.isNotEmpty ? studentName[0].toUpperCase() : '?')), title: Text(studentName), trailing: Text(score.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
                    },
                  );
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          "Leaderboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(child: Column(children: [
        _buildLeaderboard("Permainan Carta Alir"),
        _buildLeaderboard("Pseudocode Game"),
      ])),
    );
  }
}

class DashboardMiniGamePage extends StatefulWidget {
  final String teacherName;
  const DashboardMiniGamePage({Key? key, required this.teacherName}) : super(key: key);

  @override
  State<DashboardMiniGamePage> createState() => _DashboardMiniGamePageState();
}

class _DashboardMiniGamePageState extends State<DashboardMiniGamePage> {
  int totalStudents = 0;
  int totalGames = 0;
  int activeSessions = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  void _fetchStats() async {
    final studentsSnapshot =
    await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Student').get();
    final gamesSnapshot = await FirebaseFirestore.instance
        .collection('teacher_games')
        .where('teacherName', isEqualTo: widget.teacherName)
        .get();
    final activeSnapshot =
    await FirebaseFirestore.instance.collection('users').get();
    if (mounted) {
      setState(() {
        totalStudents = studentsSnapshot.docs.length;
        totalGames = gamesSnapshot.docs.length;
        activeSessions = activeSnapshot.docs.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ENHANCED: Added a subtle background color to make cards pop
      backgroundColor: const Color(0xFFF5F7FA),
      // ENHANCED: Added a gradient to the AppBar
      appBar: AppBar(
        title: const Text('Teacher Dashboard',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)], // Blue gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent, // Make the AppBar transparent to show gradient
        elevation: 4,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildTiles(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF2537B4), Color(0xFF5C6BC0)],
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.transparent,
              child: Text(
                widget.teacherName.isNotEmpty ? widget.teacherName[0] : 'T',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome,',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                Text(
                  widget.teacherName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard('Students', totalStudents.toString(), Icons.group),
        _buildStatCard('Games', totalGames.toString(), Icons.videogame_asset),
        _buildStatCard('Active', activeSessions.toString(), Icons.online_prediction),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6), // Add margin between cards
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: const Color(0xFF2537B4)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTiles(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    final childAspectRatio = screenWidth > 600 ? 3 / 2.3 : 3 / 2.2;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: childAspectRatio,
      children: [
        _buildTile('View Students', Icons.group, Colors.purpleAccent, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const StudentsPage()));
        }),
        _buildTile('Mini Games List', Icons.videogame_asset, Colors.red, () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => MiniGamesListPage(
                      teacherName: widget.teacherName)));
        }),
        _buildTile('Leaderboard', Icons.emoji_events, Colors.amber, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const LeaderboardPage()));
        }),
        _buildTile('Game Analytics', Icons.bar_chart, Colors.pink, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AnalyticsPage()));
        }),
      ],
    );
  }

  // --- ENHANCED TILE with ANIMATION and COLOR ---
  Widget _buildTile(String title, IconData icon, Color iconColor, VoidCallback onTap) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1, end: 0.95),
      duration: const Duration(milliseconds: 100),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            elevation: 6, // ENHANCED: Increased elevation for more "pop"
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Trigger the animation on tap
                onTap();
              },
              splashColor: iconColor.withOpacity(0.2), // ENHANCED: Dynamic splash color
              highlightColor: iconColor.withOpacity(0.1), // ENHANCED: Dynamic highlight color
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1), // Use the dynamic color
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: iconColor.withOpacity(0.3), width: 1.5), // ENHANCED: Added border
                      ),
                      child: Icon(icon, color: iconColor, size: 30),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}