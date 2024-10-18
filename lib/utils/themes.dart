import 'package:flutter/material.dart';

ThemeData calmSpaceTheme() {
  return ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFF3B8B5), // Soft pink primary color
      onPrimary: Colors.white, // Text on primary color
      secondary: Color(0xFFFFE0B2), // Light peach for secondary color
      onSecondary: Colors.white, // Text on secondary color
      error: Color(0xFFD32F2F), // Soft red for error
      onError: Colors.white,
      surface: Color(0xFFFFF3E0), // Softer surface color for cards, dialogs
      onSurface: Colors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFFFFF8E1), // Background color
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: Colors.black.withOpacity(0.8),
        fontFamily: 'Roboto', // Calming sans-serif font for headings
      ),
      bodyLarge: TextStyle(
        fontSize: 16.0,
        color: Colors.black.withOpacity(0.7),
        fontFamily: 'OpenSans', // Smooth font for body text
      ),
      labelLarge: const TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF3B8B5), // Soft pink
      foregroundColor: Colors.white,
      elevation: 2.0, // Small shadow for a calm effect
      centerTitle: true, // Centered title for balance
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: const Color(0xFFF3B8B5), // Soft pink for buttons
      textTheme: ButtonTextTheme.primary, // Button text will be white
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded button corners for softness
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF3B8B5), // Pink button background
        foregroundColor: Colors.white, // White text on button
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded edges for a calm aesthetic
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFFFFF3E0), // Soft peach color for card background
      elevation: 1.0, // Minimal shadow for a light feel
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Rounded corners for cards
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFFF3B8B5), // Use primary color for icons
      size: 24.0, // Default icon size
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFF3B8B5), // Floating action button in soft pink
      foregroundColor: Colors.white, // White icon on the FAB
    ),
    useMaterial3: true, // Enable Material 3 features
  );
}
