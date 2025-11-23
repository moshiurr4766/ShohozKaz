import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'worker_kyc.dart';

class KyCHomePage extends StatelessWidget {
  const KyCHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return _errorScreen(context, "You must be logged in.");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("KYC Verification"),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("workerKyc")
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _noKycScreen(context);
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data["status"];
          final reason = data["rejectedReason"] ??
              "Your information did not match our verification requirements.";

          switch (status) {
            case "pending":
              return _pendingScreen(context);

            case "approved":
              return _approvedScreen(context);

            case "rejected":
              return _rejectedScreen(context, reason);

            default:
              return _errorScreen(context, "Unknown KYC state.");
          }
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------  
  //                        DIFFERENT STATE SCREENS  
  // ---------------------------------------------------------------------------  

  /// User has not submitted a KYC yet
  Widget _noKycScreen(BuildContext context) {
    final theme = Theme.of(context);
    return _centerCard(
      context,
      icon: Icons.shield_outlined,
      iconColor: theme.colorScheme.primary,
      title: "You have not submitted KYC yet",
      subtitle: "Please complete your identity verification to continue.",
      buttonText: "Start KYC Verification",
      buttonAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KycWizard()),
        );
      },
    );
  }

  /// KYC is under review
  Widget _pendingScreen(BuildContext context) {
    //final theme = Theme.of(context);
    return _centerCard(
      context,
      icon: Icons.hourglass_bottom_rounded,
      iconColor: Colors.orange,
      title: "KYC Under Review",
      subtitle:
          "We’re reviewing your submitted information. You will be notified once it's approved.",
      highlight: _highlightBox(
        context,
        "Expected review time: 24–48 hours",
        Colors.orange,
      ),
    );
  }

  /// KYC approved - success screen
  Widget _approvedScreen(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(28),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 70,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "KYC Verified!",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                "Your identity has been successfully verified.\nYou now have full access.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              _highlightBox(
                context,
                "Thank you for completing your verification.",
                Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// KYC rejected - show reason + resubmit option
  Widget _rejectedScreen(BuildContext context, String reason) {
    //final theme = Theme.of(context);

    return _centerCard(
      context,
      icon: Icons.error_rounded,
      iconColor: Colors.red,
      title: "KYC Rejected",
      subtitle: reason,
      buttonText: "Resubmit KYC",
      buttonColor: Colors.red,
      buttonAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KycWizard()),
        );
      },
    );
  }

  /// Fallback error UI
  Widget _errorScreen(BuildContext context, String msg) {
    final theme = Theme.of(context);
    return _centerCard(
      context,
      icon: Icons.warning_amber_rounded,
      iconColor: theme.colorScheme.error,
      title: "Error",
      subtitle: msg,
    );
  }

  // ---------------------------------------------------------------------------  
  //                    REUSABLE COMPONENTS (CARD BUILDER)  
  // ---------------------------------------------------------------------------  

  Widget _centerCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? buttonText,
    Color? buttonColor,
    VoidCallback? buttonAction,
    Widget? highlight,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(28),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 70, color: iconColor),
              const SizedBox(height: 16),

              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),

              if (highlight != null) ...[
                const SizedBox(height: 18),
                highlight,
              ],

              if (buttonText != null) ...[
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          buttonColor ?? theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: buttonAction,
                    child: Text(buttonText),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  /// Highlight box used in pending + approved messages
  Widget _highlightBox(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color.withOpacity(0.9),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
