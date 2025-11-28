


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //  Error Message States
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    // Trigger validators
    _formKey.currentState!.validate();

    // If any custom error exists → stop login
    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);

    try {
      await authService.value.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/nav');

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _passwordError = e.message ?? "Login failed";
      });

    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black54;
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
                  /// LOGO + TITLE
                  Column(
                    children: [
                      Icon(Icons.lock_outline, size: 70, color: textColor),
                      const SizedBox(height: 12),
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Access your account securely",
                        style: TextStyle(fontSize: 14, color: subTextColor),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  /// EMAIL FIELD
                  Container(
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.button),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() => _emailError = "Please enter your email");
                          return null;
                        }

                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          setState(() => _emailError = "Enter a valid email");
                          return null;
                        }

                        setState(() => _emailError = null);
                        return null;
                      },
                    ),
                  ),

                  /// FIXED ERROR AREA (email)
                  Container(
                    height: 20,
                    alignment: Alignment.centerLeft,
                    child: _emailError != null
                        ? Text(
                            _emailError!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          )
                        : null,
                  ),

                  const SizedBox(height: 10),

                  /// PASSWORD FIELD
                  Container(
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        prefixIcon: Icon(Icons.lock_outline, color: AppColors.button),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.button,
                          ),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() => _passwordError = "Please enter your password");
                          return null;
                        }

                        if (value.length < 6) {
                          setState(() => _passwordError = "Password must be at least 6 characters");
                          return null;
                        }

                        setState(() => _passwordError = null);
                        return null;
                      },
                    ),
                  ),

                  /// FIXED ERROR AREA (password)
                  Container(
                    height: 20,
                    alignment: Alignment.centerLeft,
                    child: _passwordError != null
                        ? Text(
                            _passwordError!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          )
                        : null,
                  ),

                  /// FORGOT PASSWORD
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgot'),
                      child: const Text("Forgot Password?", style: TextStyle(color: AppColors.button)),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// LOGIN BUTTON
                  ElevatedButton(
                    onPressed: _isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  const SizedBox(height: 25),

                  /// SIGNUP LINK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?", style: TextStyle(color: subTextColor)),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/signup'),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(color: AppColors.button, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
