import 'package:flutter/material.dart';
import 'student_view_material.dart';
import 'student_search_material.dart';

class LearningStudentPage extends StatelessWidget {
  const LearningStudentPage({super.key});

  // Hardcoded tips
  static const List<String> tips = [
    "Tip: Check materials regularly to stay up-to-date.",
    "Tip: Review PDFs thoroughly to understand key concepts.",
    "Tip: Use the search feature to quickly find materials by name.",
    "Tip: Take notes while reading materials for better retention.",
    "Tip: Ask your teacher if a material seems unclear or outdated."
  ];

  @override
  Widget build(BuildContext context) {
    // Pick a random tip each time the page builds
    final tipOfTheDay = (List<String>.from(tips)..shuffle()).first;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2537B4),
        title: const Text(
          "Student Dashboard",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tip of the Day
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow[200],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tipOfTheDay,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Student Menu Buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const StudentViewMaterialPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2537B4),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("View Materials",
              style: TextStyle(color: Colors.white),
              ),

            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const StudentSearchMaterialPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2537B4),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Search Material by Name",
              style: TextStyle(color: Colors.white)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
