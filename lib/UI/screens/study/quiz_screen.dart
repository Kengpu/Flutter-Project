import 'package:flutter/material.dart';
import 'package:flutterapp/UI/widgets/quiz_result.dart';
import 'package:flutterapp/domain/models/deck.dart';
import 'package:flutterapp/domain/models/flashcard.dart';
import 'dart:math';

class QuizScreen extends StatefulWidget {
  final Deck deck;
  const QuizScreen({super.key, required this.deck});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _gameFinished = false;
  final Map<int, int> _userAnswers = {}; // selected option index

  List<Flashcard> get _quizCards =>
      widget.deck.flashcards.where((f) => true).toList();

  // Build quiz data for QuizResultWidget
  List<Map<String, dynamic>> get _quizCardsData {
    return _quizCards.map((card) {
      List<String> options;
      if (card.quizable) {
        options = [card.backText, ...card.distractors!];
      } else {
        options = ["Correct", "Incorrect"];
      }
      options.shuffle(Random());
      return {
        'frontText': card.frontText,
        'backText': card.backText,
        'distractors': card.distractors ?? [],
        'correctAnswer': card.backText,
        'shuffledOptions': options,
      };
    }).toList();
  }

  void _selectOption(int optionIndex) {
    final cardData = _quizCardsData[_currentIndex];
    final selectedOption = cardData['shuffledOptions'][optionIndex];
    final correctAnswer = cardData['correctAnswer'];

    if (selectedOption == correctAnswer) _score++;

    _userAnswers[_currentIndex] = optionIndex;

    if (_currentIndex + 1 < _quizCards.length) {
      setState(() => _currentIndex++);
    } else {
      setState(() => _gameFinished = true);
    }
  }

  // Restart quiz
  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _gameFinished = false;
      _userAnswers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCards.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF00FFFF),
        body: const Center(
          child: Text(
            "No quiz available for this deck",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Show result screen if quiz finished
    if (_gameFinished) {
      return QuizResultWidget(
        score: _score,
        totalQuestions: _quizCards.length,
        quizCards: _quizCardsData,
        userAnswers: _userAnswers,
        onRestart: _restartQuiz, // restart works now
      );
    }

    final cardData = _quizCardsData[_currentIndex];
    final card = _quizCards[_currentIndex];
    final options = cardData['shuffledOptions'];

    return Scaffold(
      backgroundColor: const Color(0xFF00FFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00FFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // go back to previous screen
          },
        ),
        title: Text(
          "Quiz: ${widget.deck.title}",
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Question ${_currentIndex + 1} of ${_quizCards.length}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF004D4D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    card.frontText,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Column(
                children: List.generate(
                  options.length,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: InkWell(
                      onTap: () => _selectOption(i),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: _userAnswers[_currentIndex] == i
                              ? Colors.yellow
                              : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          options[i],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
}
