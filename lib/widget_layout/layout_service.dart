import 'package:cloud_firestore/cloud_firestore.dart';
import 'layout_model.dart';

class LayoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveLayout(String userId, DashboardLayout layout) async {
    await _firestore.collection('dashboard_layouts').doc(userId).set(
      layout.toMap(),
      SetOptions(merge: true),
    );
  }

  Future<DashboardLayout?> loadLayout(String userId) async {
    final doc = await _firestore.collection('dashboard_layouts').doc(userId).get();

    if (doc.exists) {
      return DashboardLayout.fromMap(doc.data()!);
    }
    return null;
  }
}
