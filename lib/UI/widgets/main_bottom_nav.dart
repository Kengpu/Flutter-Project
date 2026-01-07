import 'package:flutter/material.dart';
import 'package:flutterapp/UI/screens/home/home_screen.dart';
import 'package:flutterapp/UI/screens/home/settings_screen.dart'; 

class MainBottomNav extends StatelessWidget {
  final int currentIndex;

  const MainBottomNav({
    super.key,
    required this.currentIndex, required Null Function(dynamic index) onTabSelected, 
    // Removed the unused onTabSelected parameter to keep it clean, 
    // as navigation is handled inside onPressed here.
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BottomAppBar(
      // 1. Dynamic Background: White in Light Mode, Dark Surface in Dark Mode
      color: theme.colorScheme.surface,
      elevation: 10,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // --- HOME BUTTON ---
            IconButton(
              icon: Icon(
                Icons.home_filled,
                // 2. Active color: Navy in Light Mode, Cyan in Dark Mode
                color: currentIndex == 0 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              onPressed: () {
                if (currentIndex != 0) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                }
              },
            ),

            const SizedBox(width: 40), // Space for FloatingActionButton

            // --- SETTINGS BUTTON ---
            IconButton(
              icon: Icon(
                Icons.settings,
                // 2. Active color logic repeated
                color: currentIndex == 1 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              onPressed: () {
                if (currentIndex != 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}