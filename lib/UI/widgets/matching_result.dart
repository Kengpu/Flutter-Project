import 'package:flutter/material.dart';

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
    // Dynamic message based on performance
    String rank;
    IconData icon;
    Color iconColor;

    if (score >= 50) {
      rank = "Speed Demon!";
      icon = Icons.bolt;
      iconColor = Colors.amber;
    } else if (score >= 25) {
      rank = "Great Job!";
      icon = Icons.star;
      iconColor = Colors.orange;
    } else {
      rank = "Finish!";
      icon = Icons.emoji_events;
      iconColor = Colors.blueGrey;
    }

    return Container(
      color: Colors.black54, // Dim background
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 20, spreadRadius: 2)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 80),
              const SizedBox(height: 10),
              Text(
                rank,
                style: const TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.black87
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Divider(),
              ),
              _buildStatRow("Time Taken", time),
              _buildStatRow("Points Earned", "+$score"),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRestart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C9FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    "PLAY AGAIN",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }
} 