import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants/app_colors.dart';
import 'package:flutterapp/UI/screens/home/home_screen.dart';
// Using the import path you provided
import 'package:flutterapp/UI/screens/home/settings_screen.dart'; 

class MainBottomNav extends StatelessWidget {
  final int currentIndex;

  const MainBottomNav({
    super.key,
    required this.currentIndex, required Null Function(dynamic index) onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.textPrimary,
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
                color: currentIndex == 0 ? AppColors.primaryNavy : AppColors.textSecondary,
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
                color: currentIndex == 1 ? AppColors.primaryNavy : AppColors.textSecondary,
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