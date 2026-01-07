import 'package:flutter/material.dart';
import 'package:flutterapp/UI/screens/home/home_screen.dart';
import 'package:flutterapp/UI/screens/home/settings_screen.dart'; 

class MainBottomNav extends StatelessWidget {
  final int currentIndex;

  const MainBottomNav({
    super.key,
    required this.currentIndex, required Null Function(dynamic index) onTabSelected, 
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BottomAppBar(
      color: theme.colorScheme.surface,
      elevation: 10,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home_filled,
                color: currentIndex == 0 
                    ? theme.colorScheme.primary 
                    // ignore: deprecated_member_use
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

            const SizedBox(width: 40), 

            IconButton(
              icon: Icon(
                Icons.settings,
                color: currentIndex == 1 
                    ? theme.colorScheme.primary 
                    // ignore: deprecated_member_use
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