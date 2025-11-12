import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Screens
import 'pages/registerPageWrapper.dart';
import 'forum/home_screen.dart';

// Material Management Pages
import 'learning/teacher_upload_material.dart';
import 'learning/teacher_update_material.dart';
import 'learning/student_view_material.dart';

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
      title: 'CodeQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: kBackgroundColor,
        useMaterial3: true,
      ),

      // Start at Register Page
      home: const RegisterPageWrapper(),

      // Routes
      routes: {
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterPageWrapper(),

        // Material Management Routes
        '/teacher_upload': (_) => const TeacherUploadMaterialPage(),
        '/teacher_update': (_) => const TeacherUpdateMaterialPage(),
        '/student_view': (_) => const StudentViewMaterialPage(),
      },
    );
  }
}
