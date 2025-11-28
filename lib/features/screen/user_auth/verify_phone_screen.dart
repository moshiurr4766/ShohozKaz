// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:shohozkaz/core/constants.dart';

// class PhoneVerificationScreen extends StatefulWidget {
//   final String phoneNumber;

//   const PhoneVerificationScreen({
//     super.key,
//     required this.phoneNumber,
//   });

//   @override
//   State<PhoneVerificationScreen> createState() =>
//       _PhoneVerificationScreenState();
// }

// class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
//   final TextEditingController _codeController = TextEditingController();
//   String? _verificationId;
//   String? _codeError;

//   bool _isSending = false;
//   bool _isVerifying = false;

//   @override
//   void initState() {
//     super.initState();
//     _sendCode();
//   }

//   /// Snack message
//   void _showSnack(String msg, {bool success = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: success ? Colors.green : Colors.redAccent,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       ),
//     );
//   }

//   /// Send OTP
//   Future<void> _sendCode() async {
//     setState(() => _isSending = true);

//     await FirebaseAuth.instance.verifyPhoneNumber(
//       phoneNumber: widget.phoneNumber,
//       verificationCompleted: (PhoneAuthCredential credential) {},
//       verificationFailed: (e) => _showSnack(e.message ?? "Failed"),
//       codeSent: (verificationId, resendToken) {
//         setState(() => _verificationId = verificationId);
//         _showSnack("OTP sent to ${widget.phoneNumber}", success: true);
//       },
//       codeAutoRetrievalTimeout: (verificationId) {
//         _verificationId = verificationId;
//       },
//     );

//     setState(() => _isSending = false);
//   }

//   /// Verify OTP
//   Future<bool> _verifyCode() async {
//     if (_verificationId == null) return false;

//     setState(() => _isVerifying = true);

//     final code = _codeController.text.trim();

//     if (code.length != 6) {
//       setState(() {
//         _codeError = "Enter 6-digit code";
//         _isVerifying = false;
//       });
//       return false;
//     }

//     try {
//       final credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId!,
//         smsCode: code,
//       );

//       await FirebaseAuth.instance.signInWithCredential(credential);

//       if (!mounted) return false;

//       _showSnack("Phone number verified!", success: true);
//       return true;
//     } catch (e) {
//       _showSnack("Invalid OTP. Try again.");
//       return false;
//     } finally {
//       setState(() => _isVerifying = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isDark = Theme.of(context).brightness == Brightness.dark;

//     final Color textColor = isDark ? Colors.white : Colors.black87;
//     final Color fieldColor = isDark ? Colors.grey.shade900 : Colors.white;
//     final Color borderColor = isDark ? Colors.white24 : Colors.black12;

//     return Scaffold(
//       backgroundColor: isDark ? Colors.black : const Color(0xFFF8F8F8),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 420),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Text(
//                   "Verify Phone Number",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
//                 ),

//                 const SizedBox(height: 10),

//                 Text(
//                   widget.phoneNumber,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       fontSize: 18,
//                       color: AppColors.button,
//                       fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 35),

//                 /// OTP FIELD
//                 Container(
//                   decoration: BoxDecoration(
//                     color: fieldColor,
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(color: borderColor),
//                   ),
//                   child: TextField(
//                     controller: _codeController,
//                     keyboardType: TextInputType.number,
//                     maxLength: 6,
//                     style: TextStyle(
//                         color: textColor,
//                         fontSize: 20,
//                         letterSpacing: 4,
//                         fontWeight: FontWeight.bold),
//                     decoration: const InputDecoration(
//                       counterText: "",
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.all(16),
//                       hintText: "Enter OTP",
//                     ),
//                     onChanged: (_) => setState(() => _codeError = null),
//                   ),
//                 ),

//                 if (_codeError != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 6),
//                     child: Text(
//                       _codeError!,
//                       style: const TextStyle(color: Colors.red, fontSize: 13),
//                     ),
//                   ),

//                 const SizedBox(height: 20),

//                 /// VERIFY BUTTON
//                 ElevatedButton(
//                   onPressed: _isVerifying
//                       ? null
//                       : () async {
//                           final ok = await _verifyCode();
//                           if (ok && mounted) Navigator.pop(context, true);
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.button,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                   ),
//                   child: _isVerifying
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text(
//                           "Verify",
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold),
//                         ),
//                 ),

//                 const SizedBox(height: 14),

//                 /// RESEND
//                 TextButton(
//                   onPressed: _isSending ? null : _sendCode,
//                   child: _isSending
//                       ? const SizedBox(
//                           width: 18,
//                           height: 18,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Text(
//                           "Resend Code",
//                           style: TextStyle(
//                               color: AppColors.button,
//                               fontWeight: FontWeight.bold),
//                         ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shohozkaz/core/constants.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const PhoneVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  String? _verificationId;
  String? _codeError;

  bool _isSending = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _sendCode();
  }

  /// Snack Alert
  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  /// Send Code
  Future<void> _sendCode() async {
    setState(() => _isSending = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (_) {},
      verificationFailed: (e) => _showSnack(e.message ?? "Verification failed"),
      codeSent: (id, _) {
        setState(() => _verificationId = id);
        _showSnack("OTP sent to ${widget.phoneNumber}", success: true);
      },
      codeAutoRetrievalTimeout: (id) => _verificationId = id,
    );

    setState(() => _isSending = false);
  }

  /// Verify OTP
  Future<bool> _verifyCode() async {
    if (_verificationId == null) return false;

    final code = _codeController.text.trim();

    if (code.length != 6) {
      setState(() => _codeError = "Enter 6-digit code");
      return false;
    }

    setState(() => _isVerifying = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      _showSnack("Phone number verified!", success: true);
      return true;
    } catch (_) {
      _showSnack("Invalid OTP. Please try again.");
      return false;
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color cardColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.white;
    final Color borderColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF2F4F7),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black26 : Colors.grey.shade300,
                      blurRadius: 25,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // TITLE
                    Text(
                      "Verify Your Phone",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Code sent to",
                      style: TextStyle(
                        fontSize: 15,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      widget.phoneNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.button,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // OTP BOX
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _codeError == null
                              ? borderColor
                              : Colors.redAccent,
                        ),
                      ),
                      child: TextField(
                        controller: _codeController,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 10,
                          color: textColor,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: "",
                          hintText: "••••••",
                          hintStyle: TextStyle(
                            fontSize: 26,
                            letterSpacing: 10,
                            color: Colors.grey,
                          ),
                        ),
                        onChanged: (_) => setState(() => _codeError = null),
                      ),
                    ),

                    if (_codeError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _codeError!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    // VERIFY BUTTON
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity, // FULL WIDTH
                      child: SizedBox(
                        width: double.infinity, // FULL WIDTH
                        child: ElevatedButton(
                          onPressed: _isVerifying
                              ? null
                              : () async {
                                  final verified = await _verifyCode();
                                  if (verified && mounted) {
                                    Navigator.pop(context, true);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            backgroundColor: AppColors.button,
                          ),
                          child: _isVerifying
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Verify Code",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // RESEND BUTTON
                    TextButton(
                      onPressed: _isSending ? null : _sendCode,
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              "Resend Code",
                              style: TextStyle(
                                color: AppColors.button,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
