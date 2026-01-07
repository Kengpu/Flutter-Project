import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants/app_colors.dart';

class UserLevel extends StatelessWidget {
  final int level;
  final int currentExp;
  final int totalExpNeeded;
  final int streak;

  const UserLevel({
    super.key,
    required this.level,
    required this.currentExp,
    required this.totalExpNeeded,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Initialize Theme
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    double progress = currentExp / totalExpNeeded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        // 2. Surface color adapts to theme
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        // 3. Subtle border for dark mode to define the card edge
        border: isDark 
            ? Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)) 
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Lvl $level",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  // 4. Color follows primary (Navy vs Cyan)
                  color: theme.colorScheme.primary,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    "$streak",
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Thinner XP Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              // 5. Background adapts to surface variant or scaffold bg
              backgroundColor: isDark 
                  ? theme.colorScheme.onSurface.withOpacity(0.1) 
                  : AppColors.scaffoldBg,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "$currentExp/$totalExpNeeded XP",
              style: TextStyle(
                fontSize: 9,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}