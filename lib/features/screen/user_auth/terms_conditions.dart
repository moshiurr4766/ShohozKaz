import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  static const String routeName = '/terms-and-conditions';

  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ShohozKaz – Terms & Conditions',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last Updated: January 2025',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 16),

                _sectionTitle('1. Acceptance of Terms', textTheme),
                _sectionBody(
                  'By accessing or using the ShohozKaz platform, you agree to abide by these '
                  'Terms & Conditions. If you do not agree, please discontinue using the app.',
                  textTheme,
                ),

                _sectionTitle('2. Description of Service', textTheme),
                _sectionBody(
                  'ShohozKaz is a digital service marketplace connecting Employees (hirers) '
                  'with Workers (service providers). Users can communicate through real-time chat, '
                  'post jobs (Workers only), hire workers (Employees only), and manage service workflows. '
                  'ShohozKaz does not employ workers directly; it only facilitates connections.',
                  textTheme,
                ),

                _sectionTitle('3. Unified Account System', textTheme),
                _sectionBody(
                  'ShohozKaz uses a single account system. Every user begins as an Employee. '
                  'To access Worker features, users must complete KYC verification. '
                  'Once approved, Worker Mode becomes available and users can post jobs.',
                  textTheme,
                ),

                _sectionTitle('4. User Roles', textTheme),
                _sectionBody(
                  'ShohozKaz supports two roles within one account:\n\n'
                  'Employee (default role):\n'
                  '• Can browse and hire workers\n'
                  '• Can use live chat\n'
                  '• Cannot post jobs unless KYC verified\n\n'
                  'Worker (unlocked after KYC):\n'
                  '• Can post jobs\n'
                  '• Can manage job applications and statuses\n'
                  '• Can communicate with employees\n'
                  '• Must provide accurate skills and service details\n\n'
                  'Users must select the correct role and must not misrepresent themselves.',
                  textTheme,
                ),

                _sectionTitle('5. Posting Jobs (Workers Only)', textTheme),
                _sectionBody(
                  'Only verified Workers may post jobs. All job posts must be truthful, legal, '
                  'and clearly describe service details. Illegal, abusive, misleading, or spam content '
                  'will be removed, and accounts may be suspended.',
                  textTheme,
                ),

                _sectionTitle('6. Hiring Workers (Employees Only)', textTheme),
                _sectionBody(
                  'Employees must review worker profiles before hiring and communicate clearly. '
                  'ShohozKaz is not responsible for worker performance, disputes, or agreements between users.',
                  textTheme,
                ),

                _sectionTitle('7. Live Chat Usage', textTheme),
                _sectionBody(
                  'ShohozKaz provides real-time chat for communication between Employees and Workers. '
                  'Users agree not to send harassment, threats, explicit material, or fraudulent content. '
                  'Reported abuse may lead to restrictions or account suspension.',
                  textTheme,
                ),

                _sectionTitle('8. KYC Verification', textTheme),
                _sectionBody(
                  'To unlock Worker Mode, users must complete KYC verification. All information must be truthful. '
                  'ShohozKaz may reject or suspend verification if fraud or mismatch is detected. '
                  'KYC data is protected and stored securely.',
                  textTheme,
                ),

                _sectionTitle('9. Privacy & Data Protection', textTheme),
                _sectionBody(
                  'ShohozKaz collects necessary data including profile details, contact information, '
                  'job history, chat messages, and KYC documents. Data is securely stored in Firebase. '
                  'ShohozKaz does not sell or misuse user data.',
                  textTheme,
                ),

                _sectionTitle('10. User Responsibilities', textTheme),
                _sectionBody(
                  'Users agree not to engage in fraud, spam, illegal acts, or abusive behavior. '
                  'Users must not upload harmful files or attempt to hack the system. Violations may '
                  'result in permanent account termination.',
                  textTheme,
                ),

                _sectionTitle('11. Limitation of Liability', textTheme),
                _sectionBody(
                  'ShohozKaz is not responsible for job quality, worker performance, disputes, or losses '
                  'arising from user interactions. The platform only facilitates communication and connection.',
                  textTheme,
                ),

                _sectionTitle('12. Account Termination', textTheme),
                _sectionBody(
                  'ShohozKaz may suspend or terminate accounts for violating terms, fraudulent activity, '
                  'or illegal behavior. Users may also request account deletion.',
                  textTheme,
                ),

                _sectionTitle('13. Modifications to Terms', textTheme),
                _sectionBody(
                  'ShohozKaz may update these Terms & Conditions at any time. Continued use of the platform '
                  'after updates means you accept the new terms.',
                  textTheme,
                ),

                _sectionTitle('14. Governing Law', textTheme),
                _sectionBody(
                  'These Terms are governed by the laws of Bangladesh. Any disputes shall be handled under '
                  'Bangladeshi jurisdiction.',
                  textTheme,
                ),

                _sectionTitle('15. Contact & Support', textTheme),
                _sectionBody(
                  'For support, inquiries, or complaints, please contact us at:\n'
                  'Email: shohozkaz@gmail.com',
                  textTheme,
                ),

                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'By using ShohozKaz, you agree to these Terms & Conditions.',
                    style: textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
      child: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _sectionBody(String text, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: textTheme.bodyMedium,
      ),
    );
  }
}
