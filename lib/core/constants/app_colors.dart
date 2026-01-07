import 'package:flutter/material.dart';

class AppColors {
  // --- Your Branding Colors ---
  static const Color primaryOrange = Color(0xFFF05D00);
  static const Color primaryCyan = Color(0xFF00E9EF); 

  // --- Study Flow Navy Theme ---
  static const Color primaryNavy = Color(0xFF1A4594);    // Headers & Buttons
  static const Color navyLight = Color(0xFFE8F0FF);      // Icon backgrounds
  static const Color navyDark = Color(0xFF0C2B64);       // Deep Navy for shadows

  // --- Light Mode Surface Colors ---
  static const Color scaffoldBg = Color(0xFFF8F9FB);     // Main light background
  static const Color cardLight = Color(0xFFFFFFFF);      // Pure white for cards
  static const Color borderLight = Color(0xFFE0E0E0);    // Subtle borders

  // --- Dark Mode Surface Colors ---
  static const Color background = Color(0xFF121212);     // Main dark background
  static const Color surface = Color(0xFF1E1E1E);        // Card background in dark
  static const Color surfaceLight = Color(0xFF2C2C2C);   // Lighter dark for inputs
  static const Color borderDark = Color(0xFF383838);     // Subtle borders in dark

  // --- Status Colors ---
  static const Color success = Color(0xFF4CAF50);        
  static const Color error = Color(0xFFE53935);          
  static const Color starGold = Color(0xFFFFD700);       

  // --- Text Colors ---
  static const Color textPrimary = Color(0xFFFFFFFF);    // White text (on dark/navy)
  static const Color textDark = Color(0xFF1A1A1B);       // Dark text (on light)
  static const Color textSecondary = Color(0xFF757575);  // Gray text for "subtitle"
  static const Color textMuted = Color(0xFFB3B3B3);      // Faded text
}