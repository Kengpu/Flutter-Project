import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants/app_colors.dart'; // Import your colors

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
    // Performance logic
    String rank;
    IconData icon;
    Color accentColor;

    if (score >= 50) {
      rank = "Speed Demon!";
      icon = Icons.bolt_rounded;
      accentColor = Colors.amber[700]!; // Keeping amber for the "Gold" achievement feel
    } else if (score >= 25) {
      rank = "Great Job!";
      icon = Icons.stars_rounded;
      accentColor = Colors.orange;
    } else {
      rank = "Session Finished";
      icon = Icons.timer_outlined;
      accentColor = AppColors.primaryNavy;
    }

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6), // Dim background overlay
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBg, // Consistent light background
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
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
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 70),
              ),
              const SizedBox(height: 20),
              Text(
                rank,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Performance Summary",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 25),
                child: Divider(height: 1),
              ),

              // --- STATS AREA ---
              _buildStatRow("Time Taken", time, Icons.access_time_rounded),
              const SizedBox(height: 15),
              _buildStatRow("Points Earned", "+$score", Icons.emoji_events_outlined),

              const SizedBox(height: 35),

              // --- BUTTONS ---
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onRestart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: AppColors.textPrimary,
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Exit to Menu",
                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
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

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.textPrimary, // White box for the icon
            borderRadius: BorderRadius.circular(10),
          ),
          child:Icon(icon, size: 20, color: AppColors.primaryNavy),
        ),
        const SizedBox(width: 15),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNavy,
          ),
        ),
      ],
    );
  }
}