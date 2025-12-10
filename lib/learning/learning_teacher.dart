import 'package:flutter/material.dart';
import 'teacher_upload_material.dart';
import 'teacher_update_material.dart';

class LearningTeacherPage extends StatelessWidget {
  const LearningTeacherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
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
              color: Colors.blue.shade600,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TeacherUploadMaterialPage()),
                );
              },
            ),
            const SizedBox(height: 14),

            // Update Material
            _buildMenuButton(
              context,
              title: "Update Materials",
              subtitle: "View all materials and correct typos",
              color: Colors.blue.shade400,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TeacherUpdateMaterialPage()),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 4),
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
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
