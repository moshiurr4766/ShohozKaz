import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';



class JobOnboardingScreen extends StatefulWidget {
  const JobOnboardingScreen({super.key});

  @override
  State<JobOnboardingScreen> createState() => _JobOnboardingScreenState();
}

class _JobOnboardingScreenState extends State<JobOnboardingScreen> {
  final PageController _controller = PageController();
  bool onLastPage = false;

  final List<Map<String, dynamic>> steps = [
    {
      'icon': Icons.description,
      'title': 'Create Your Profile',
      'desc':
          'Sign up and build your professional profile to showcase your skills and experience to potential employers.'
    },
    {
      'icon': Icons.work_outline,
      'title': 'Find & Apply for Jobs',
      'desc':
          'Browse thousands of local job listings and apply to the ones that fit your expertise with just a single click.'
    },
    {
      'icon': Icons.verified_user_outlined,
      'title': 'Get Hired & Get Paid',
      'desc':
          'Connect with employers, complete jobs, and receive your payments securely through our trusted platform.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final descColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button without splash
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  _controller.jumpToPage(steps.length - 1);
                },
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  foregroundColor: WidgetStateProperty.all(Colors.deepOrange),
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                child: const Text("Skip"),
              ),
            ),

            // Onboarding pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: steps.length,
                onPageChanged: (index) {
                  setState(() {
                    onLastPage = index == steps.length - 1;
                  });
                },
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.deepOrange[100],
                          radius: 60,
                          child: Icon(
                            step['icon'],
                            size: 50,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          step['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          step['desc'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: descColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Page indicator
            SmoothPageIndicator(
              controller: _controller,
              count: steps.length,
              effect: WormEffect(
                activeDotColor: Colors.deepOrange,
                dotColor: Colors.grey.shade400,
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),

            const SizedBox(height: 20),

            // Next / Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (onLastPage) {
                      // Navigate to home/login page
                      Navigator.pushReplacementNamed(context, '/login');
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(onLastPage ? "GET STARTED" : "NEXT"),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
