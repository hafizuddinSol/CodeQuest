// user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<bool> isTeacher() async {
    if (currentUser == null) return false;

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (!userDoc.exists) {
        // If user document doesn't exist, create it with default role
        await _firestore.collection('users').doc(currentUser!.uid).set({
          'username': currentUser!.displayName ?? currentUser!.email?.split('@')[0] ?? 'User',
          'email': currentUser!.email,
          'role': 'Student', // Default role, matching your DB format
          'createdAt': FieldValue.serverTimestamp(),
        });
        return false;
      }
      // Check for 'Teacher' with a capital 'T' to match your database
      return userDoc.get('role') == 'Teacher';
    } catch (e) {
      print('Error checking user role: $e');
      return false;
    }
  }

  Future<String> getUserName() async {
    if (currentUser == null) return "Anonymous";

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (!userDoc.exists) {
        // If user document doesn't exist, create it
        final username = currentUser!.displayName ?? currentUser!.email?.split('@')[0] ?? 'User';
        await _firestore.collection('users').doc(currentUser!.uid).set({
          'username': username,
          'email': currentUser!.email,
          'role': 'Student',
          'createdAt': FieldValue.serverTimestamp(),
        });
        return username;
      }
      // Get 'username' field instead of 'name'
      return userDoc.get('username') ?? currentUser!.displayName ?? currentUser!.email?.split('@')[0] ?? 'Anonymous';
    } catch (e) {
      print('Error getting user name: $e');
      // Fallback to a more sensible default if Firestore fails
      return currentUser!.displayName ?? currentUser!.email?.split('@')[0] ?? 'Anonymous';
    }
  }

  Future<String> getUserId() async {
    return currentUser?.uid ?? "anonymous";
  }
}