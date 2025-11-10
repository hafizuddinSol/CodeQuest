import 'package:flutter/material.dart';
import 'analyticsGame.dart';
import 'FlowchartBuilderGame.dart';
import '../miniGame_student/student_dashboard.dart';

// ---------------- Placeholder Pages ----------------
class StudentsPage extends StatelessWidget {
  const StudentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Students"), backgroundColor: Colors.indigo),
      body: const Center(child: Text("Students Page Placeholder")),
    );
  }
}

class MiniGamesListPage extends StatelessWidget {
  const MiniGamesListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mini Games List"), backgroundColor: Colors.indigo),
      body: const Center(child: Text("Mini Games List Placeholder")),
    );
  }
}

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leaderboard"), backgroundColor: Colors.indigo),
      body: const Center(child: Text("Leaderboard Page Placeholder")),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), backgroundColor: Colors.indigo),
      body: const Center(child: Text("Settings Page Placeholder")),
    );
  }
}

// ---------------- Teacher Dashboard ----------------
class DashboardMiniGamePage extends StatefulWidget {
  final String teacherName;
  const DashboardMiniGamePage({Key? key, required this.teacherName}) : super(key: key);

  @override
  State<DashboardMiniGamePage> createState() => _DashboardMiniGamePageState();
}

class _DashboardMiniGamePageState extends State<DashboardMiniGamePage> {
  final int totalStudents = 28;
  final int totalGames = 7;
  final int activeSessions = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: Colors.indigo,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildStatsRow(),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: (MediaQuery.of(context).size.width > 600) ? 3 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3 / 2,
                  children: [
                    _buildTile('View Students', Icons.group, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const StudentsPage()));
                    }),
                    _buildTile('Mini Games List', Icons.videogame_asset, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MiniGamesListPage()));
                    }),
                    _buildTile('Add New Game', Icons.add_box, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => FlowchartBuilderGame(teacherName: widget.teacherName)));
                    }),
                    _buildTile('Leaderboard', Icons.emoji_events, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LeaderboardPage()));
                    }),
                    _buildTile('Settings', Icons.settings, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsPage()));
                    }),
                    _buildTile('Game Analytics', Icons.bar_chart, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AnalyticsPage()));
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white,
          child: Text(
            widget.teacherName.isNotEmpty ? widget.teacherName[0] : 'T',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome,', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
              Text(widget.teacherName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard('Students', totalStudents.toString()),
        _buildStatCard('Games', totalGames.toString()),
        _buildStatCard('Active', activeSessions.toString()),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
          child: Column(
            children: [
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(String title, IconData icon, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFEEF1FF),
                child: Icon(icon, color: const Color(0xFF3F51B5)),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
