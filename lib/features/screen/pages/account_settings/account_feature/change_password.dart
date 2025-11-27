import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shohozkaz/core/constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user == null || user.email == null) {
      setState(() => _loading = false);
      _showSnack(context, "User not logged in", false);
      return;
    }

    try {
      // Re-authenticate user
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentCtrl.text.trim(),
      );

      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(_newCtrl.text.trim());

      setState(() => _loading = false);

      _showSnack(context, "Password updated successfully", true);

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);

      String message = "Enter correct credential !";
      if (e.code == 'wrong-password') {
        message = "Current password is incorrect.";
      } else if (e.code == 'weak-password') {
        message = "New password is too weak.";
      } else if (e.code == 'requires-recent-login') {
        message = "Please log in again before changing your password.";
      }

      _showSnack(context, message, false);
    } catch (e) {
      setState(() => _loading = false);
      _showSnack(context, "Error: $e", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Change Password"), centerTitle: true),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "For your security, please enter your current password and a new one.",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Current password
                  TextFormField(
                    controller: _currentCtrl,
                    obscureText: !_showCurrent,
                    decoration: InputDecoration(
                      labelText: "Current Password",
                      prefixIcon: const Icon(Iconsax.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showCurrent ? Iconsax.eye_slash : Iconsax.eye,
                        ),
                        onPressed: () {
                          setState(() => _showCurrent = !_showCurrent);
                        },
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Enter your current password";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // New password
                  TextFormField(
                    controller: _newCtrl,
                    obscureText: !_showNew,
                    decoration: InputDecoration(
                      labelText: "New Password",
                      prefixIcon: const Icon(Iconsax.lock_1),
                      suffixIcon: IconButton(
                        icon: Icon(_showNew ? Iconsax.eye_slash : Iconsax.eye),
                        onPressed: () {
                          setState(() => _showNew = !_showNew);
                        },
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Enter a new password";
                      }
                      if (v.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      if (v == _currentCtrl.text.trim()) {
                        return "New password must be different";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm password
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: !_showConfirm,
                    decoration: InputDecoration(
                      labelText: "Confirm New Password",
                      prefixIcon: const Icon(Iconsax.lock_1),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirm ? Iconsax.eye_slash : Iconsax.eye,
                        ),
                        onPressed: () {
                          setState(() => _showConfirm = !_showConfirm);
                        },
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Confirm your new password";
                      }
                      if (v != _newCtrl.text.trim()) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppColors.button,
                      ),
                      child: const Text(
                        "Update Password",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_loading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: success
            ? AppColors.button
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }
}
