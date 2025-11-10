import 'package:flutter/material.dart';
import '../miniGame_teacher/dashboard_minigame.dart';
import '../miniGame_student/student_dashboard.dart';
import 'registerPage.dart';
import 'loginPage.dart';

class RegisterPageWrapper extends StatelessWidget {
  const RegisterPageWrapper({super.key});

  void _navigateToDashboard(BuildContext context, String role, String username) {
    if (role == 'Teacher') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardMiniGamePage(teacherName: username),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudentDashboard(studentName: username),
        ),
      );
    }
  }

  void _switchToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          onLoginSuccess: () {
            // Optionally navigate to dashboard after login
          },
          onSwitchToRegister: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RegisterPageWrapper()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RegisterPage(
      onRegistered: (String role, String username) {
        _navigateToDashboard(context, role, username);
      },
      onSwitchToLogin: () => _switchToLogin(context),
    );
  }
}
