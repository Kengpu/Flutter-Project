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
    double progress = currentExp / totalExpNeeded;

    return Container(
      // Reduced padding for a tighter fit in the header
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Simplified Level Text
              Text(
                "Lvl $level",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.primaryNavy,
                ),
              ),
              // Compact Streak
              Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 14),
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
              backgroundColor: AppColors.scaffoldBg,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryNavy),
            ),
          ),
          const SizedBox(height: 4),
          // Micro XP Text
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "$currentExp/$totalExpNeeded XP",
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}