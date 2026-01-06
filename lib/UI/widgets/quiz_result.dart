import 'package:flutter/material.dart';

class QuizResultWidget extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<Map<String, dynamic>> quizCards;
  final Map<int, int> userAnswers;
  final VoidCallback onRestart; // renamed for clarity

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
    int percentage = ((score / totalQuestions) * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFF00FFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Result",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "$percentage%",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text("Correct: $score", style: const TextStyle(fontSize: 22)),
              Text("Incorrect: ${totalQuestions - score}", style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 20),

              // Review of questions
              ...List.generate(quizCards.length, (index) {
                final card = quizCards[index];
                final userAnswerIdx = userAnswers[index];
                final options = [...card['shuffledOptions']];
                return _buildReviewCard(
                  card['frontText'],
                  options,
                  card['correctAnswer'],
                  userAnswerIdx,
                );
              }),

              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: ElevatedButton(
                    onPressed: onRestart, // calls the restart function from QuizScreen
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF88),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Restart Quiz",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(
      String question, List<dynamic> options, String correctText, int? userIdx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF004D4D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Question",
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 8),
          Text(question,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 15),
          ...List.generate(options.length, (i) {
            String optionText = options[i];
            bool isCorrect = optionText == correctText;
            bool isUserChoice = (userIdx != null && options[userIdx] == optionText);

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(optionText,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (isCorrect)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else if (isUserChoice && !isCorrect)
                    const Icon(Icons.cancel, color: Colors.red),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
