import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/notification_widget.dart';
import '../widgets/progress_widget.dart';
import '../widgets/RecentActivityWidget.dart';
import '../miniGame_student/student_dashboard.dart';
import '../forum/home_screen.dart';
import '../learning/learningHomePage.dart';
import 'logInPage.dart';
import 'profilePage.dart';
import '../widget_layout/layout_service.dart';
import '../widget_layout/layout_model.dart';
import '../widget_layout/widget_factory.dart';


const Color kPrimaryColor = Color(0xFF2537B4);
const Color kBackgroundColor = Color(0xFFF0F0FF);

class DashboardPage_Student extends StatefulWidget {
  final String userRole;
  final String username;

  const DashboardPage_Student({
    super.key,
    required this.userRole,
    required this.username,
  });

  @override
  State<DashboardPage_Student> createState() => _DashboardPage_StudentState();
}

class _DashboardPage_StudentState extends State<DashboardPage_Student> {
  final List<Widget> widgets = [];

  final LayoutService _layoutService = LayoutService();
  String userId = ""; // will store Firebase user ID


  // Filters
  bool showFilters = false;
  String timeFilter = "all";
  String topicFilter = "all";

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) userId = user.uid;

    _loadSavedLayout();
  }

  void _navigateToMiniGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDashboard(studentName: widget.username),
      ),
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signed out successfully")),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  void _showAddWidgetSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: 180,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Tambah Widget Notifikasi'),
              onTap: () => _addWidget('notifications'),
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('Tambah Widget Pencapaian'),
              onTap: () => _addWidget('progress'),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Tambah Widget Aktiviti Terkini'),
              onTap: () => _addWidget('recent'),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshFilteredWidgets() {
    setState(() {
      for (int i = 0; i < widgets.length; i++) {
        if (widgets[i] is NotificationWidget) {
          widgets[i] = NotificationWidget(
            key: UniqueKey(),
            onRemove: () => _removeWidget(i),
            timeFilter: timeFilter,
            topicFilter: topicFilter,
          );
        }
      }
    });
  }

  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 3,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Laman Utama',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Selamat Datang, ${widget.username}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (value) {
              if (value == 'learning') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningHomePage()));
              } else if (value == 'forum') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
              } else if (value == 'minigame') {
                _navigateToMiniGame();
              } else if (value == 'profile') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditPage()));
              } else if (value == 'signout') {
                _signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'learning',
                child: ListTile(leading: Icon(Icons.menu_book), title: Text('Laman Utama Pelajaran')),
              ),
              const PopupMenuItem(
                value: 'forum',
                child: ListTile(leading: Icon(Icons.forum), title: Text('Forum')),
              ),
              const PopupMenuItem(
                value: 'minigame',
                child: ListTile(leading: Icon(Icons.videogame_asset), title: Text('Permainan')),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(leading: Icon(Icons.person), title: Text('Profile')),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'signout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.redAccent),
                  title: Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FloatingActionButton(
              mini: true,
              onPressed: _showAddWidgetSheet,
              backgroundColor: Colors.white,
              child: Icon(Icons.add, size: 24, color: kPrimaryColor),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- FILTER BUTTON + AREA ---------------------
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 1,
                ),
                icon: const Icon(Icons.filter_alt),
                label: const Text("Filters"),
                onPressed: () => setState(() => showFilters = !showFilters),
              ),
            ),

            if (showFilters) _buildFiltersUI(),

            const SizedBox(height: 8),

            // ---------------- WIDGETS STACK ---------------------
            Expanded(
              child: widgets.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widgets.length,
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: widgets[index],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersUI() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          // TIME FILTER
          Row(
            children: [
              const Text("Time:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: timeFilter,
                items: const [
                  DropdownMenuItem(value: "all", child: Text("All Time")),
                  DropdownMenuItem(value: "today", child: Text("Today")),
                  DropdownMenuItem(value: "week", child: Text("This Week")),
                  DropdownMenuItem(value: "month", child: Text("This Month")),
                ],
                onChanged: (value) {
                  setState(() => timeFilter = value!);
                  _refreshFilteredWidgets();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // TOPIC FILTER
          Row(
            children: [
              const Text("Topic:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: topicFilter,
                items: const [
                  DropdownMenuItem(value: "all", child: Text("All Topics")),
                  DropdownMenuItem(value: "learning", child: Text("Learning")),
                  DropdownMenuItem(value: "minigame", child: Text("Mini Game")),
                  DropdownMenuItem(value: "forum", child: Text("Forum")),
                  DropdownMenuItem(value: "profile", child: Text("Profile")),
                ],
                onChanged: (value) {
                  setState(() => topicFilter = value!);
                  _refreshFilteredWidgets();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.widgets_outlined, size: 48, color: kPrimaryColor),
              const SizedBox(height: 16),
              Text(
                'No widgets added yet',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _showAddWidgetSheet,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Your First Widget'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadSavedLayout() async {
    DashboardLayout? layout = await _layoutService.loadLayout(userId);

    if (layout == null) {
      // default
      setState(() {
        widgets.addAll([
          WidgetFactory.buildWidget(
            id: "notifications",
            onRemove: () => _removeWidget(0),
            timeFilter: timeFilter,
            topicFilter: topicFilter,
          ),
          WidgetFactory.buildWidget(
            id: "progress",
            onRemove: () => _removeWidget(1),
          ),
          WidgetFactory.buildWidget(
            id: "recent",
            onRemove: () => _removeWidget(2),
          ),
        ]);
      });
      return;
    }

    setState(() {
      widgets.clear();
      for (int i = 0; i < layout.widgetOrder.length; i++) {
        String id = layout.widgetOrder[i];

        widgets.add(
          WidgetFactory.buildWidget(
            id: id,
            onRemove: () => _removeWidget(i),
            timeFilter: timeFilter,
            topicFilter: topicFilter,
          ),
        );
      }
    });
  }

  void _saveLayout() {
    final layout = DashboardLayout(
      widgetOrder: widgets.map((w) {
        if (w is NotificationWidget) return "notifications";
        if (w is ProgressWidget) return "progress";
        if (w is RecentActivityWidget) return "recent";
        return "unknown";
      }).toList(),
    );

    _layoutService.saveLayout(userId, layout);
  }

  // Corrected: Add widget + save layout
  void _addWidget(String type) {
    setState(() {
      final newIndex = widgets.length;

      if (type == 'notifications') {
        widgets.add(NotificationWidget(
          key: UniqueKey(),
          onRemove: () => _removeWidget(newIndex),
          timeFilter: timeFilter,
          topicFilter: topicFilter,
        ));
      } else if (type == 'progress') {
        widgets.add(ProgressWidget(
          key: UniqueKey(),
          onRemove: () => _removeWidget(newIndex),
        ));
      } else if (type == 'recent') {
        widgets.add(
          RecentActivityWidget(
            key: UniqueKey(),
            onRemove: () => _removeWidget(newIndex),
          ),
        );
      }
    });

    _saveLayout();
    Navigator.pop(context);
  }

  void _removeWidget(int index) {
    if (index < widgets.length) {
      setState(() {
        widgets.removeAt(index);
      });
      _saveLayout();
    }
  }


}
