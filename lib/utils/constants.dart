import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFFF3B8B5); // Soft pink
  static const Color secondaryColor = Color(0xFFFFE0B2); // Light peach
  static const Color backgroundColor = Color(0xFFFFF8E1); // Light orange-peach
  static const Color surfaceColor = Color(0xFFFFF3E0); // Soft surface color

  // Padding
  static const double defaultPadding = 16.0;

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: Colors.black, // Directly use black instead of withOpacity for better readability
    fontFamily: 'Roboto', // Ensure 'Roboto' is defined in your pubspec.yaml
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16.0,
    color: Colors.black, // Directly use black instead of withOpacity for better readability
    fontFamily: 'OpenSans', // Ensure 'OpenSans' is defined in your pubspec.yaml
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
