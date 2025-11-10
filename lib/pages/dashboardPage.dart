import 'package:flutter/material.dart';
import '../widgets/notification_widget.dart';
import '../widgets/progress_widget.dart';
import '../miniGame_teacher/dashboard_minigame.dart';
import '../miniGame_student/student_dashboard.dart';
import 'role_selection_page.dart';

class DashboardPage extends StatefulWidget {
  final String userRole; // 'teacher' or 'student'
  final String username; // the user's name

  const DashboardPage({super.key, required this.userRole, required this.username});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Widget> widgets = [];

  @override
  void initState() {
    super.initState();
    widgets = [
      NotificationWidget(
        key: UniqueKey(),
        onRemove: () => _removeWidget(0),
      ),
      ProgressWidget(
        key: UniqueKey(),
        onRemove: () => _removeWidget(1),
      ),
    ];
  }

  void _removeWidget(int index) {
    setState(() {
      if (index < widgets.length) {
        widgets.removeAt(index);
      }
    });
  }

  void _addWidget(String type) {
    setState(() {
      final newIndex = widgets.length;
      if (type == 'notifications') {
        widgets.add(
          NotificationWidget(
            key: UniqueKey(),
            onRemove: () => _removeWidget(newIndex),
          ),
        );
      } else if (type == 'progress') {
        widgets.add(
          ProgressWidget(
            key: UniqueKey(),
            onRemove: () => _removeWidget(newIndex),
          ),
        );
      }
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
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
      );
    }
  }

  void _showAddWidgetSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Add Notification Widget'),
                onTap: () => _addWidget('notifications'),
              ),
              ListTile(
                leading: const Icon(Icons.show_chart),
                title: const Text('Add Progress Widget'),
                onTap: () => _addWidget('progress'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF333333),
      appBar: AppBar(
        backgroundColor: const Color(0xFF333333),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Welcome, ${widget.username}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFBDBDBD),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _navigateToMiniGame,
            icon: const Icon(Icons.videogame_asset, color: Colors.orange),
            tooltip: 'Mini Game',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FloatingActionButton(
              mini: true,
              onPressed: _showAddWidgetSheet,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, size: 24),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFF616161),
            height: 1,
          ),
        ),
      ),
      body: widgets.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF616161),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 32,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No widgets added yet',
                    style: TextStyle(
                      color: Color(0xFFBDBDBD),
                      fontSize: 14,
                    ),
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
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widgets.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: widgets[index],
          );
        },
      ),
    );
  }
}
