import 'package:flutter/material.dart';
import 'teacher_upload_material.dart';
import 'teacher_update_material.dart';
import 'dart:math';

class LearningTeacherPage extends StatefulWidget {
  const LearningTeacherPage({super.key});

  @override
  State<LearningTeacherPage> createState() => _LearningTeacherPageState();
}

class _LearningTeacherPageState extends State<LearningTeacherPage> {
  // Hardcoded tips
  final List<String> tips = [
    "Tip: Review materials before uploading to ensure accuracy.",
    "Tip: Keep PDFs organized by topic for easy access.",
    "Tip: Encourage students to provide feedback on materials.",
    "Tip: Regularly update old materials to stay relevant.",
    "Tip: Use descriptive titles for quick searchability."
  ];

  late final String tipOfTheDay;

  @override
  void initState() {
    super.initState();
    // Pick a random tip once
    tipOfTheDay = tips[Random().nextInt(tips.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2537B4),
        title: const Text(
          "Materials Hub - Teacher",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tip of the Day
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 249, 196, 1), // yellow[100]
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
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

            const Text(
              'Teacher Menu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Upload Material
            _buildMenuButton(
              context,
              title: "Upload Materials",
              subtitle: "Add new learning resources (PDF only)",
              color: const Color(0xFF2537B4),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TeacherUploadMaterialPage()),
                );
              },
            ),
            const SizedBox(height: 14),

            // Update Material
            _buildMenuButton(
              context,
              title: "Update Materials",
              subtitle: "View all materials and correct typos",
              color: const Color(0xFF2537B4),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TeacherUpdateMaterialPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
      BuildContext context, {
        required String title,
        required String subtitle,
        required VoidCallback onPressed,
        required Color color,
      }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.08),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
