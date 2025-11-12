import 'package:flutter/material.dart';
import 'teacher_upload_material.dart';
import 'teacher_update_material.dart';
import 'student_view_material.dart';

class LearningHomePage extends StatefulWidget {
  const LearningHomePage({super.key});

  @override
  State<LearningHomePage> createState() => _LearningHomePageState();
}

class _LearningHomePageState extends State<LearningHomePage> {
  String currentView = 'home'; // 'home', 'teacher', or 'student'

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (currentView == 'teacher') {
      content = const TeacherUploadMaterialPage();
    } else if (currentView == 'student') {
      content = const StudentViewMaterialPage();
    } else {
      content = _buildHomeView(context);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 393),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: content),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.blue.shade600,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Materials Hub',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (currentView != 'home')
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () => setState(() => currentView = 'home'),
              tooltip: 'Home',
            ),
        ],
      ),
    );
  }

  Widget _buildHomeView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Teacher',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Upload Material Button
          _buildHomeButton(
            title: 'Upload Materials',
            subtitle: 'Add new learning resources',
            color: Colors.blue.shade600,
            onPressed: () => setState(() => currentView = 'teacher'),
          ),
          const SizedBox(height: 12),

          // Update Material Button
          _buildHomeButton(
            title: 'Update Materials',
            subtitle: 'Edit existing resources',
            color: Colors.blue.shade400,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TeacherUpdateMaterialPage()),
            ),
          ),
          const SizedBox(height: 24),

          const Divider(),
          const SizedBox(height: 24),

          const Text(
            'Student',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildHomeButton(
            title: 'View Materials',
            subtitle: 'Browse learning resources',
            color: Colors.white,
            borderColor: Colors.blue.shade600,
            textColor: Colors.blue.shade600,
            onPressed: () => setState(() => currentView = 'student'),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeButton({
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
    Color? color,
    Color? borderColor,
    Color textColor = Colors.white,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: borderColor != null ? Border.all(color: borderColor, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: textColor, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(12),
      child: const Text(
        'Materials Management System',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }
}
