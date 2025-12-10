import 'package:flutter/material.dart';
import 'student_view_material.dart';
import 'student_search_material.dart';

class LearningStudentPage extends StatelessWidget {
  const LearningStudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        title: const Text("Student Dashboard", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentViewMaterialPage()),
                );
              },
              child: const Text("View Materials"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentSearchMaterialPage()),
                );
              },
              child: const Text("Search Material by Name"),
            ),
          ],
        ),
      ),
    );
  }
}
