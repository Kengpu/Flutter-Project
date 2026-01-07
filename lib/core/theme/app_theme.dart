import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import your constants file here
import 'package:flutterapp/core/constants/app_colors.dart'; 

class AppTheme {
  // --- 1. THEME LOGIC ---
  static const String _key = "user_theme_mode";
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == "dark") themeMode.value = ThemeMode.dark;
    if (saved == "light") themeMode.value = ThemeMode.light;
  }

  static Future<void> toggleTheme(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  // --- 2. THEME DATA (Using your Constants) ---
  
  // Light Mode: Using your Navy and ScaffoldBg
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.cyan,
        brightness: Brightness.light,
        primary: AppColors.primaryNavy,    // Your 0xFF1A237E
        secondary: Colors.cyan,           // Your Cyan accent
        surface: Colors.white,            // For your cards
        onSurface: AppColors.primaryNavy, // Text on cards
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBg, // Your 0xFFF8FAFC
    );
  }

  // Dark Mode: Using Navy as background and Cyan as Primary
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.cyan,
        brightness: Brightness.dark,
        primary: Colors.cyanAccent,        // Cyan pops in dark
        secondary: Colors.cyan,
        // Using a darker version of your Navy for the background
        surface: const Color(0xFF1E293B),  
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A), 
    );
  }
}