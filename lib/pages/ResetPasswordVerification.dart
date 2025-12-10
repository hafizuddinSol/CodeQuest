import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logInPage.dart';

const Color _primaryBlue = Color(0xFF1E2A85);
const Color _cardBackground = Color(0xFFC4C2E6);

class ResetPassword extends StatelessWidget {
  const ResetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E-mel sudah dihantar')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Password reset link sudah berjaya dihantar. Sila check inbox e-mel anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: _primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class ResetPasswordVerification extends StatefulWidget {
  const ResetPasswordVerification({super.key});

  @override
  State<ResetPasswordVerification> createState() =>
      _ResetPasswordVerificationState();
}

class _ResetPasswordVerificationState
    extends State<ResetPasswordVerification> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetPasswordEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();

    try {
      // Firebase handles the actual sending
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset link sent to $email.'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'Failed to send reset link. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red.shade700),
      );
    } catch (e) {
      // Handle unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
    debugPrint('Navigating back to Log In Page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: _cardBackground,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'VERIFIKASI E-MEL',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _primaryBlue,
                        fontSize: 21.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'E-mel tidak boleh kosong.';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Sila masukkan e-mel yang betul.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Masukkan email anda…',
                        errorStyle: const TextStyle(fontSize: 12),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 14.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                          const BorderSide(color: _primaryBlue, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: _CustomButton(
                            onPressed: _isLoading ? null : _sendResetPasswordEmail,
                            label: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                                : const Text('Confirm',
                                style:
                                TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: _CustomButton(
                            onPressed: _handleBack,
                            label: const Text('Back',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget label;

  const _CustomButton({required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
        elevation: 4,
      ).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return _primaryBlue.withOpacity(0.5);
            }
            return _primaryBlue;
          },
        ),
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.pressed)) {
              return Colors.white.withOpacity(0.1);
            }
            return null;
          },
        ),
      ),
      child: label,
    );
  }
}
