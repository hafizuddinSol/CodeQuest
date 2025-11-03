import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/registerPage.dart';
import 'pages/dashboardPage.dart';

const Color kPrimaryColor = Color(0xFF4256A4);
const Color kBackgroundColor = Color(0xFFF0F0FF);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeQuest Auth',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundColor,
      ),
      home: const RegisterPageWrapper(),
    );
  }
}

/// Wrapper for handling navigation after registration
class RegisterPageWrapper extends StatelessWidget {
  const RegisterPageWrapper({super.key});

  void _navigateToDashboard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  void _switchToLogin() {
    debugPrint("Switch to login clicked");
  }

  @override
  Widget build(BuildContext context) {
    return RegisterPage(
      onRegistered: () => _navigateToDashboard(context),
      onSwitchToLogin: _switchToLogin,
    );
  }
}
