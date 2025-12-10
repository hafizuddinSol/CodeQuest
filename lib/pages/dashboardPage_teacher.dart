import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sulam_project/learning/learning_teacher.dart';
import '../widgets/notification_widget.dart';
import '../miniGame_teacher/dashboard_minigame.dart';
import '../forum/home_screen.dart';
import '../learning/learning_teacher.dart';
import 'logInPage.dart';
import 'profilePage.dart';

const Color kPrimaryColor = Color(0xFF2537B4);
const Color kBackgroundColor = Color(0xFFF0F0FF);

class DashboardPage_Teacher extends StatefulWidget {
  final String userRole;
  final String username;

  const DashboardPage_Teacher({
    super.key,
    required this.userRole,
    required this.username,
  });

  @override
  State<DashboardPage_Teacher> createState() => _DashboardPage_TeacherState();
}

class _DashboardPage_TeacherState extends State<DashboardPage_Teacher> {
  final List<Widget> widgets = [];

  // Filters
  bool showFilters = false;
  String timeFilter = "all";
  String topicFilter = "all";

  @override
  void initState() {
    super.initState();
    // Only add NotificationWidget by default for teacher
    widgets.add(NotificationWidget(
      key: UniqueKey(),
      onRemove: () => _removeWidget(0),
      timeFilter: timeFilter,
      topicFilter: topicFilter,
    ));
  }

  void _removeWidget(int index) {
    if (index < widgets.length) {
      setState(() => widgets.removeAt(index));
    }
  }

  void _addWidget() {
    setState(() {
      final newIndex = widgets.length;
      widgets.add(NotificationWidget(
        key: UniqueKey(),
        onRemove: () => _removeWidget(newIndex),
        timeFilter: timeFilter,
        topicFilter: topicFilter,
      ));
    });
    Navigator.pop(context);
  }

  void _navigateToMiniGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardMiniGamePage(teacherName: widget.username),
      ),
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Signed out successfully"),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  void _refreshFilteredWidgets() {
    setState(() {
      for (int i = 0; i < widgets.length; i++) {
        if (widgets[i] is NotificationWidget) {
          widgets[i] = NotificationWidget(
            key: UniqueKey(),
            onRemove: () => _removeWidget(i),
            timeFilter: timeFilter,
            topicFilter: topicFilter,
          );
        }
      }
    });
  }

  void _showAddWidgetSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: 100,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Add Notification Widget'),
              onTap: _addWidget,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 3,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Welcome, ${widget.username}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            offset: const Offset(0, 50),
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
            onSelected: (value) {
              if (value == 'learning') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningTeacherPage()));
              } else if (value == 'forum') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
              } else if (value == 'minigame') {
                _navigateToMiniGame();
              } else if (value == 'profile') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditPage()));
              } else if (value == 'signout') {
                _signOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'learning',
                child: Row(
                  children: const [
                    Icon(Icons.menu_book_outlined, color: Colors.blueAccent),
                    SizedBox(width: 12),
                    Text("learning Homepage", style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'forum',
                child: Row(
                  children: const [
                    Icon(Icons.forum_outlined, color: Colors.teal),
                    SizedBox(width: 12),
                    Text("Forum", style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'minigame',
                child: Row(
                  children: const [
                    Icon(Icons.sports_esports_outlined, color: Colors.purple),
                    SizedBox(width: 12),
                    Text("Minigame", style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: const [
                    Icon(Icons.person_outline, color: Colors.orange),
                    SizedBox(width: 12),
                    Text("Profile", style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.redAccent),
                    SizedBox(width: 12),
                    Text(
                      "Sign Out",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FloatingActionButton(
              mini: true,
              onPressed: _showAddWidgetSheet,
              backgroundColor: Colors.white,
              child: Icon(Icons.add, size: 24, color: kPrimaryColor),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- FILTER BUTTON + AREA ---------------------
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 1,
                ),
                icon: const Icon(Icons.filter_alt),
                label: const Text("Filters"),
                onPressed: () => setState(() => showFilters = !showFilters),
              ),
            ),

            if (showFilters)
              _buildFiltersUI(),

            const SizedBox(height: 8),

            // ---------------- WIDGETS STACK ---------------------
            Expanded(
              child: widgets.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widgets.length,
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: widgets[index],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersUI() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          // TIME FILTER
          Row(
            children: [
              const Text("Time:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: timeFilter,
                items: const [
                  DropdownMenuItem(value: "all", child: Text("All Time")),
                  DropdownMenuItem(value: "today", child: Text("Today")),
                  DropdownMenuItem(value: "week", child: Text("This Week")),
                  DropdownMenuItem(value: "month", child: Text("This Month")),
                ],
                onChanged: (value) {
                  setState(() => timeFilter = value!);
                  _refreshFilteredWidgets();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          // TOPIC FILTER
          Row(
            children: [
              const Text("Topic:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: topicFilter,
                items: const [
                  DropdownMenuItem(value: "all", child: Text("All Topics")),
                  DropdownMenuItem(value: "learning", child: Text("Learning")),
                  DropdownMenuItem(value: "minigame", child: Text("Mini Game")),
                  DropdownMenuItem(value: "forum", child: Text("Forum")),
                  DropdownMenuItem(value: "profile", child: Text("Profile")),
                ],
                onChanged: (value) {
                  setState(() => topicFilter = value!);
                  _refreshFilteredWidgets();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.widgets_outlined, size: 48, color: kPrimaryColor),
              const SizedBox(height: 16),
              Text(
                'No widgets added yet',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _showAddWidgetSheet,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Your First Widget'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
