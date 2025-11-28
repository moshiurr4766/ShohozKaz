import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/services/auth_service.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  String? _emailError; // custom error under textfield

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  ///  Beautiful Custom Floating SnackBar
  void _showSnack(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        backgroundColor: success ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  ///  Firebase Reset Password
  Future<void> resetPassword() async {
    setState(() => _isLoading = true);

    try {
      await authService.value.resetPassword(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      _showSnack("Password reset email sent!", success: true);

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? "Reset failed");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Error message layout under field
  Widget _inputError(String? error) {
    return Container(
      height: 18,
      alignment: Alignment.centerLeft,
      child: error != null
          ? Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color fieldColor = isDark ? Colors.grey.shade900 : Colors.white;
    final Color borderColor = isDark ? Colors.white24 : Colors.black12;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8F8F8),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  /// Title
                  Text(
                    "Forgot Password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 10),
                  
                  Text(
                    "Enter your email and we'll send you a reset link.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 50),

                  /// Email Field
                  Container(
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        prefixIcon: Icon(Icons.email_outlined,
                            color: AppColors.button),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),

                      onChanged: (_) => setState(() => _emailError = null),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() => _emailError = "Email is required");
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          setState(() => _emailError = "Enter a valid email");
                        }
                        return null;
                      },
                    ),
                  ),

                  _inputError(_emailError),

                  const SizedBox(height: 20),

                  ///  Submit Button
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            _formKey.currentState!.validate();

                            if (_emailError == null) {
                              resetPassword();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Send Reset Link",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  ///  Back to login
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Back to Login",
                      style: TextStyle(
                        color: AppColors.button,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
