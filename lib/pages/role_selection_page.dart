import 'package:flutter/material.dart';
import 'package:sulam_project/miniGame_teacher/dashboard_minigame.dart';
import '../miniGame_student//student_dashboard.dart';



class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  void _navigateToDashboard(BuildContext context, String role) {
    if (role == 'student') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const StudentDashboard(
            studentName: 'Adlina Narisya',
          ),
        ),
      );
    } else if (role == 'teacher') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardMiniGamePage(
            teacherName: 'Ms. Nurul Natalia',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _navigateToDashboard(context, 'student'),
              child: const Text('Student'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateToDashboard(context, 'teacher'),
              child: const Text('Teacher'),
            ),
          ],
        ),
      ),
    );
  }
}
