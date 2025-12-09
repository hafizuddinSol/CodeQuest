import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CodeQuestApp());
}

//hi

// Global instance for secure storage
const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

class CodeQuestApp extends StatelessWidget {
  const CodeQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Edit',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const ProfileEditPage(),
    );
  }
}

const Color primaryIndigo = Color(0xFF4F46E5);
const Color lightBackground = Color(0xFFEEF2FF);
const Color cardBackground = Color(0xFFA5B4FC);

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  String? _profileImageUrl;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  String username = "";
  String email = "";
  String savedPassword = "Password not stored locally.";
  bool isLoading = true;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    loadSavedPassword();
  }

  // Load password securely from flutter_secure_storage
  Future<void> loadSavedPassword() async {
    final password = await _secureStorage.read(key: 'secure_password');
    setState(() {
      savedPassword = password ?? 'Password not stored locally.';
    });
  }

  // DATA FETCHING
  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          username = data['username'] ?? "";
          email = data['email'] ?? user.email ?? "";
          _profileImageUrl = data['profilePic'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => isLoading = false);
    }
  }

  // IMAGE PICKER / UPLOAD LOGIC
  void chooseImageSource() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a Photo"),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickAndUploadImage(ImageSource source) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final pickedFile =
      await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile == null) return;

      setState(() => _selectedImage = File(pickedFile.path));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uploading profile picture...")),
      );

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profilePic')
          .child('${user.uid}.jpg');

      final uploadTask = await storageRef.putFile(_selectedImage!);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'profilePic': downloadUrl});

      setState(() {
        _profileImageUrl = downloadUrl;
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated successfully!")),
      );
    } on FirebaseException catch (e) {
      print("FIREBASE UPLOAD ERROR: ${e.code} - ${e.message}");
      setState(() => _selectedImage = null);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload failed. Check storage rules! (${e.code})"),
        ),
      );
    } catch (e) {
      print("GENERAL ERROR: $e");
      setState(() => _selectedImage = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred: $e")),
      );
    }
  }

  Widget buildProfileImage() {
    if (_selectedImage != null) {
      return Container(
        width: 128,
        height: 128,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(_selectedImage!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return Container(
        width: 128,
        height: 128,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(_profileImageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: 128,
        height: 128,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: const Icon(Icons.person, size: 64, color: primaryIndigo),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryIndigo))
          : Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: chooseImageSource,
                      child: buildProfileImage(),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: primaryIndigo,
                        radius: 20,
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                DisplayField(label: "Username", value: username),
                const SizedBox(height: 16),
                DisplayField(label: "Email", value: email),

                const SizedBox(height: 16),
                PasswordField(
                  password: savedPassword,
                  showPassword: _showPassword,
                  onToggle: () {
                    setState(() => _showPassword = !_showPassword);
                  },
                ),

                const SizedBox(height: 32),
                const Text(
                  "This is your profile page.",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DisplayField extends StatelessWidget {
  final String label;
  final String value;

  const DisplayField({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: primaryIndigo,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordField extends StatelessWidget {
  final String password;
  final bool showPassword;
  final VoidCallback onToggle;

  const PasswordField({
    super.key,
    required this.password,
    required this.showPassword,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = showPassword ? password : "••••••••••";
    final icon = showPassword ? Icons.visibility_off : Icons.visibility;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Password",
            style: TextStyle(
              color: primaryIndigo,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayValue,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontFamily: 'monospace',
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  icon,
                  color: primaryIndigo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}