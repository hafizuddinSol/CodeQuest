import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/notification_widget.dart';
import '../miniGame_teacher/dashboard_minigame.dart';
import '../miniGame_student/student_dashboard.dart';
import '../forum/home_screen.dart';
import '../learning/learningHomePage.dart';
import 'logInPage.dart';
import 'profilePage.dart';

const Color kPrimaryColor = Color(0xFF4256A4);
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

  @override
  void initState() {
    super.initState();
    // Only add NotificationWidget by default for teacher
    widgets.add(NotificationWidget(
      key: UniqueKey(),
      onRemove: () => _removeWidget(0),
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
      ));
    });
    Navigator.pop(context);
  }

  void _navigateToMiniGame() {
    if (widget.userRole == 'teacher') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardMiniGamePage(teacherName: widget.username),
        ),
      );
    } else if (widget.userRole == 'student') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentDashboard(studentName: widget.username),
        ),
      );
    }
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
          // Dropdown menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (value) {
              if (value == 'learning') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LearningHomePage()),
                );
              } else if (value == 'forum') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              } else if (value == 'minigame') {
                _navigateToMiniGame();
              } else if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileEditPage()),
                );
              } else if (value == 'signout') {
                _signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'learning',
                child: ListTile(
                  leading: Icon(Icons.menu_book),
                  title: Text('Learning Homepage'),
                ),
              ),
              const PopupMenuItem(
                value: 'forum',
                child: ListTile(
                  leading: Icon(Icons.forum),
                  title: Text('Forum'),
                ),
              ),
              const PopupMenuItem(
                value: 'minigame',
                child: ListTile(
                  leading: Icon(Icons.videogame_asset),
                  title: Text('Mini Game'),
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'signout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.redAccent),
                  title: Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),

          // Add Notification Widget Button
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
        child: widgets.isEmpty
            ? Center(
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
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: widgets.length,
          itemBuilder: (_, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: widgets[index],
          ),
        ),
      ),
    );
  }
}
