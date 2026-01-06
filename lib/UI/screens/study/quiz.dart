import 'package:flutter/material.dart';
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
  late List<Flashcard> _quizCards; // Only cards with distractors
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  bool _gameFinished = false;
  List<String> _currentOptions = [];
  int? _selectedOptionIndex;

  @override
  void initState() {
    super.initState();
    // Filter only cards with distractors
    _quizCards = widget.deck.flashcards.where((c) => c.quizable).toList();
    if (_quizCards.isNotEmpty) {
      _setupCurrentQuestion();
    } else {
      _gameFinished = true; // No quiz available
    }
  }

  void _setupCurrentQuestion() {
    _answered = false;
    _selectedOptionIndex = null;
    final card = _quizCards[_currentIndex];

    // Multiple Choice options
    _currentOptions = List<String>.from(card.distractors!);
    _currentOptions.add(card.backText); // correct answer
    _currentOptions.shuffle();
  }

  void _answer(int index) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedOptionIndex = index;
      final card = _quizCards[_currentIndex];

      if (_currentOptions[index] == card.backText) _score++;
    });

    // Move to next question after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (_currentIndex + 1 < _quizCards.length) {
        setState(() {
          _currentIndex++;
        });
        _setupCurrentQuestion();
      } else {
        setState(() => _gameFinished = true);
      }
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _gameFinished = false;
      _quizCards = widget.deck.flashcards.where((c) => c.quizable).toList();
    });
    if (_quizCards.isNotEmpty) _setupCurrentQuestion();
  }

  @override
  Widget build(BuildContext context) {
    if (_gameFinished) {
      return Scaffold(
        backgroundColor: const Color(0xFF00FFFF),
        body: SafeArea(
          child: Center(
            child: _quizCards.isEmpty
                ? const Text(
                    "No quiz available for this deck",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Quiz Completed!",
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Score: $_score / ${_quizCards.length}",
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _restartQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          "Restart Quiz",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    }

    final card = _quizCards[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF00FFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              Text(
                "Quiz: ${widget.deck.title}",
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _quizCards.length,
                backgroundColor: Colors.grey[300],
                color: Colors.blueAccent,
                minHeight: 10,
              ),
              const SizedBox(height: 10),
              Text(
                "${_currentIndex + 1} of ${_quizCards.length}",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF004D4D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  card.frontText,
                  style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 50),
              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: _currentOptions.length,
                  itemBuilder: (context, i) {
                    bool isSelected = _selectedOptionIndex == i;
                    bool isCorrect =
                        _answered && _currentOptions[i] == card.backText;
                    Color bgColor = Colors.white.withOpacity(0.2);

                    if (_answered) {
                      if (isCorrect) bgColor = Colors.greenAccent;
                      else if (isSelected && !isCorrect)
                        bgColor = Colors.redAccent;
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: () => _answer(i),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bgColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          _currentOptions[i],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
