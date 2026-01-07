import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants/app_colors.dart'; 

class ResultWidget extends StatelessWidget {
  final int score;
  final String time;
  final VoidCallback onRestart;

  const ResultWidget({
    super.key,
    required this.score,
    required this.time,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Initialize Theme
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Performance logic
    String rank;
    IconData icon;
    Color accentColor;

    if (score >= 50) {
      rank = "Speed Demon!";
      icon = Icons.bolt_rounded;
      accentColor = Colors.amber[700]!; 
    } else if (score >= 25) {
      rank = "Great Job!";
      icon = Icons.stars_rounded;
      accentColor = Colors.orange;
    } else {
      rank = "Session Finished";
      icon = Icons.timer_outlined;
      // 2. Dynamic accent: Cyan in Dark, Navy in Light
      accentColor = theme.colorScheme.primary; 
    }

    return Scaffold(
      // 3. Dynamic overlay: Darker in Light Mode, deeper black in Dark Mode
      backgroundColor: Colors.black.withOpacity(isDark ? 0.8 : 0.6), 
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            // 4. Surface color adapts to theme
            color: theme.colorScheme.surface, 
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.5 : 0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- ICON & RANK ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 70),
              ),
              const SizedBox(height: 20),
              Text(
                rank,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  // 5. Automatic text color flip
                  color: theme.colorScheme.onSurface, 
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Performance Summary",
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6), 
                  fontSize: 14,
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Divider(height: 1, color: theme.dividerColor),
              ),

              // --- STATS AREA ---
              _buildStatRow(theme, "Time Taken", time, Icons.access_time_rounded),
              const SizedBox(height: 15),
              _buildStatRow(theme, "Points Earned", "+$score", Icons.emoji_events_outlined),

              const SizedBox(height: 35),

              // --- BUTTONS ---
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onRestart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary, // Navy -> Cyan
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "PLAY AGAIN",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      "Exit to Menu",
                      style: TextStyle(
                        // ignore: deprecated_member_use
                        color: theme.colorScheme.onSurface.withOpacity(0.5), 
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(ThemeData theme, String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // 6. Use background or surface variant for stat icons
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 15),
        Text(
          label,
          style: TextStyle(
            fontSize: 16, 
            // ignore: deprecated_member_use
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}