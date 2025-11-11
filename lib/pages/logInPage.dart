import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboardPage.dart'; // Import your DashboardPage

const Color kPrimaryColor = Color(0xFF4256A4);
const Color kBackgroundColor = Color(0xFFF0F0FF);

class LoginPage extends StatefulWidget {
  final void Function(String role, String username) ? onLoginSuccess;
  final VoidCallback? onSwitchToRegister;

  const LoginPage({super.key, this.onLoginSuccess, this.onSwitchToRegister});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameOrEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final input = _usernameOrEmailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      String email = input;
      String role = 'Student'; // default role if needed

      // Check if input is a username and get email + role
      if (!input.contains('@')) {
        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: input)
            .limit(1)
            .get();

        if (userQuery.docs.isEmpty) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user found with that username.',
          );
        }

        final userData = userQuery.docs.first.data();
        email = userData['email'] ?? input;
        role = userData['role'] ?? 'Student';
      }

      // Sign in with Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );

      // Navigate to DashboardPage with role & username
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(
            userRole: role,
            username: input,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          break;
        case 'user-not-found':
          errorMessage = 'No account found for this user.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        default:
          errorMessage = 'Login failed. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/CodeQuest.png', height: 120),
                const SizedBox(height: 12),
                const Text(
                  'Welcome to CodeQuest',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kPrimaryColor),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in with your email or username',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                _buildInput(controller: _usernameOrEmailController, hintText: 'Email or Username', icon: Icons.person_outline),
                const SizedBox(height: 16),
                _buildInput(
                  controller: _passwordController,
                  hintText: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey.shade500),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  onFieldSubmitted: (_) => _handleLogin(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : const Text('Log In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    void Function(String)? onFieldSubmitted,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      validator: (value) {
        if (value == null || value.isEmpty) return '$hintText is required.';
        return null;
      },
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );
  }
}
