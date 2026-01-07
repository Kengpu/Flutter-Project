import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants/app_colors.dart'; // Import your colors

class QuizResultWidget extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<Map<String, dynamic>> quizCards;
  final Map<int, int> userAnswers;
  final VoidCallback onRestart;

  const QuizResultWidget({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.quizCards,
    required this.userAnswers,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    int percentage = totalQuestions > 0 ? ((score / totalQuestions) * 100).toInt() : 0;
    
    // Performance logic
    String rank;
    IconData icon;
    Color accentColor;

    if (percentage >= 85) {
      rank = "Quiz Master!";
      icon = Icons.emoji_events_rounded;
      accentColor = Colors.amber[700]!;
    } else if (percentage >= 60) {
      rank = "Great Effort!";
      icon = Icons.stars_rounded;
      accentColor = Colors.orange;
    } else {
      rank = "Keep Practicing!";
      icon = Icons.menu_book_rounded;
      accentColor = AppColors.primaryNavy;
    }

    return Scaffold(
      backgroundColor: Colors.black54, 
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.88,
          height: MediaQuery.of(context).size.height * 0.82, 
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBg,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 20, spreadRadius: 2)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              // --- ICON & RANK ---
              // Removed 'const' here because 'icon' and 'accentColor' are dynamic
              Icon(icon, color: accentColor, size: 70),
              const SizedBox(height: 10),
              Text(
                rank,
                style: const TextStyle(
                  fontSize: 26, 
                  fontWeight: FontWeight.bold, 
                  color: AppColors.textDark
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Divider(thickness: 1),
              ),

              // --- STATS ROW ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem("Accuracy", "$percentage%"),
                  _buildStatItem("Score", "$score / $totalQuestions"),
                ],
              ),
              
              const SizedBox(height: 20),

              // --- SCROLLABLE REVIEW LIST ---
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Review Answers", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 13)
                ),
              ),
              const SizedBox(height: 10),
              
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withOpacity(0.5), // White-ish overlay
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: quizCards.length,
                    itemBuilder: (context, index) {
                      final card = quizCards[index];
                      final userAnswerIdx = userAnswers[index];
                      final options = card['shuffledOptions'];
                      final String userText = userAnswerIdx != null ? options[userAnswerIdx] : "No Answer";
                      
                      return _buildCompactReviewRow(
                        card['frontText'],
                        card['correctAnswer'],
                        userText,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // --- BUTTONS ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRestart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: const Text(
                    "PLAY AGAIN",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              TextButton(
                onPressed: () => Navigator.pop(context, score),
                child: const Text(
                  "Exit to Menu",
                  style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
      ],
    );
  }

  Widget _buildCompactReviewRow(String question, String correct, String user) {
    bool isCorrect = correct == user;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textPrimary, // White
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question, 
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
            maxLines: 1, 
            overflow: TextOverflow.ellipsis
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel, 
                color: isCorrect ? Colors.green : AppColors.error, 
                size: 14
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isCorrect ? "Correct!" : "Right: $correct",
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.w500,
                    color: isCorrect ? Colors.green[700] : AppColors.error
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}