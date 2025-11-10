import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/dashboardPage.dart';
import 'pages/registerPageWrapper.dart';
import '../miniGame_teacher/dashboard_minigame.dart';
import 'miniGame_student/student_dashboard.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundColor,
      ),
      home: const RegisterPageWrapper(),
    );
  }
}
