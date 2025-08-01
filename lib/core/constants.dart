import 'package:flutter/material.dart';

class AppConstants {
  // App name
  static const String appName = "ShohozKaz";

  // API base URL
  static const String apiUrl = "https://api.shohozkaz.com";

  // User roles
  static const String roleWorker = "worker";
  static const String roleEmployer = "employer";

  // Job categories
  static const List<String> jobCategories = [
    "Domestic Help",
    "Delivery",
    "Cleaning",
    "Event Support",
    "Repairs",
    "Driver",
    "Mover",
  ];

  // Padding & Radius
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
}

// helpers.dart

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF008080); // Teal
  static const Color secondary = Color(0xFF4DB6AC); // Light Teal
  static const Color accent = Color(0xFFFFA000); // Amber

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF9F9F9);
  static const Color backgroundDark = Color(0xFF121212);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Colors.white;

  //Light Buttons
  static const Color button = Color(0xFFFF6B00);
  static const Color hover = Color.fromARGB(255, 170, 71, 1);
  static const Color buttonText = Colors.white;

  // Error & Success
  static const Color error = Colors.redAccent;
  static const Color success = Colors.green;

  // Border
  static const Color border = Color(0xFFE0E0E0);
}

class AppImages {
  //Banner
  static const String promoBanner1 = "assets/images/banner/b1.png";
  static const String promoBanner2 = "assets/images/banner/b2.png";
  static const String promoBanner3 = "assets/images/banner/b3.png";
  static const String promoBanner4 = "assets/images/banner/b4.png";

  //Onboarding
  static const String onBoard1 = "assets/animations/loading/handshake.gif";
  static const String onBoard2 = "assets/images/banner/b4.png";
  static const String onBoard3 = "assets/images/banner/b2.png";
}

class AppTexts {
  //Onboarding Title Description
  static const String title1 = "Find Nearby Jobs Instantly";
  static const String description1 ="Get local jobs fast based on your skills and location";
  static const String title2 = "Hire Local Workers Fast";
  static const String description2 = "Quickly connect with nearby workers for any short task";
  static const String title3 = "Secure Digital Payments";
  static const String description3 = "Pay workers securely via bKash or Nagad anytime";
}
