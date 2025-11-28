import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/user_auth/verify_phone_screen.dart';
import 'package:shohozkaz/services/auth_service.dart';
import 'package:shohozkaz/services/store_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscureText = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  // Custom validation error messages
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _termsError;

  String? _completePhoneNumber;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> registerAndStoreUserInfo() async {
    setState(() => _isLoading = true);

    try {
      await authService.value.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = authService.value.currentUser?.uid;
      if (uid == null) throw Exception("UID is null after sign up");

      await storeService.value.storeUserData(
        uid: uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: _completePhoneNumber ?? '',
        status: 'active',
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/nav');
    } catch (e) {
      debugPrint("Signup error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Shows fixed-height validation error under fields
  Widget _inputError(String? error) {
    return Container(
      height: 20,
      alignment: Alignment.centerLeft,
      child: error != null
          ? Text(error, style: const TextStyle(color: Colors.red, fontSize: 13))
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
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Sign Up",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 50),

                  //  NAME FIELD
                  Container(
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Enter your name",
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: AppColors.button,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      onChanged: (_) => setState(() => _nameError = null),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() => _nameError = "Please enter your name");
                        }
                        return null;
                      },
                    ),
                  ),
                  _inputError(_nameError),

                  const SizedBox(height: 12),

                  //  EMAIL FIELD
                  Container(
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColors.button,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      onChanged: (_) => setState(() => _emailError = null),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() => _emailError = "Email is required");
                        } else if (!RegExp(
                          r'^[^@]+@[^@]+\.[^@]+',
                        ).hasMatch(value)) {
                          setState(() => _emailError = "Enter a valid email");
                        }
                        return null;
                      },
                    ),
                  ),
                  _inputError(_emailError),

                  const SizedBox(height: 12),

                  //  PHONE FIELD (REQUIRED, BD ONLY)
                  Container(
                    padding: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: IntlPhoneField(
                      controller: phoneController,
                      initialCountryCode: 'BD',
                      disableLengthCheck: true,
                      showCountryFlag: true,
                      showDropdownIcon: false,

                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Phone number",
                        contentPadding: EdgeInsets.all(16),
                      ),

                      onChanged: (phone) {
                        final local = phoneController.text.replaceAll(" ", "");
                        _completePhoneNumber = "+880$local";
                        setState(() => _phoneError = null);
                      },

                      validator: (value) {
                        final local = phoneController.text.replaceAll(" ", "");

                        if (local.isEmpty) {
                          setState(
                            () => _phoneError = "Phone number is required",
                          );
                        } else if (!RegExp(r'^01[0-9]{9}$').hasMatch(local)) {
                          setState(
                            () => _phoneError =
                                "Enter a valid BD number (11 digits)",
                          );
                        }

                        return null;
                      },
                    ),
                  ),
                  _inputError(_phoneError),

                  const SizedBox(height: 12),

                  //  PASSWORD FIELD
                  Container(
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppColors.button,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.button,
                          ),
                          onPressed: () =>
                              setState(() => _obscureText = !_obscureText),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      onChanged: (_) => setState(() => _passwordError = null),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(
                            () => _passwordError = "Password is required",
                          );
                        } else if (value.length < 6) {
                          setState(
                            () => _passwordError =
                                "Password must be at least 6 characters",
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                  _inputError(_passwordError),

                  const SizedBox(height: 15),

                  // TERMS CHECKBOX
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (v) {
                          setState(() {
                            _acceptTerms = v ?? false;
                            _termsError = null;
                          });
                        },
                      ),

                      Text("I accept the"),

                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/termsandconditions'),
                        child: const Text(
                          "Terms & Conditions",
                          style: TextStyle(
                            color: AppColors.button,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _inputError(_termsError),

                  const SizedBox(height: 10),

                  // //  SIGN UP BUTTON
                  // ElevatedButton(
                  //   onPressed: _isLoading
                  //       ? null
                  //       : () {
                  //           setState(() {
                  //             if (!_acceptTerms) {
                  //               _termsError =
                  //                   "You must accept the Terms & Conditions";
                  //             }
                  //           });

                  //           _formKey.currentState!.validate();

                  //           if (_nameError == null &&
                  //               _emailError == null &&
                  //               _passwordError == null &&
                  //               _phoneError == null &&
                  //               _termsError == null) {
                  //             registerAndStoreUserInfo();
                  //           }
                  //         },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: AppColors.button,
                  //     padding: const EdgeInsets.symmetric(vertical: 14),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(14),
                  //     ),
                  //   ),
                  //   child: _isLoading
                  //       ? const CircularProgressIndicator(color: Colors.white)
                  //       : const Text(
                  //           "Sign Up",
                  //           style: TextStyle(
                  //               fontSize: 16,
                  //               fontWeight: FontWeight.bold,
                  //               color: Colors.white),
                  //         ),
                  // ),

                  //  SIGN UP BUTTON
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              if (!_acceptTerms) {
                                _termsError =
                                    "You must accept the Terms & Conditions";
                              }
                            });

                            _formKey.currentState!.validate();

                            // If local validation fails, stop
                            if (_nameError != null ||
                                _emailError != null ||
                                _passwordError != null ||
                                _phoneError != null ||
                                _termsError != null) {
                              return;
                            }

                            //  Step 1: Navigate to OTP Verification Screen
                            final verified = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PhoneVerificationScreen(
                                  phoneNumber:
                                      _completePhoneNumber!, // +8801XXXXXXXXX
                                ),
                              ),
                            );

                            //  Step 2: If user verified phone → Complete registration
                            if (verified == true) {
                              registerAndStoreUserInfo();
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
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Sign Up for Free",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  //  ALREADY HAVE ACCOUNT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: AppColors.button,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}




















