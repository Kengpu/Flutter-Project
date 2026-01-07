import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutterapp/core/constants/app_colors.dart'; // Import your colors
import 'package:flutterapp/UI/widgets/quiz_result.dart';
import 'package:flutterapp/data/datascource/local_database.dart';
import 'package:flutterapp/data/models/user_stats_model.dart';
import 'package:flutterapp/data/repositories/user_repository_impl.dart';
import 'package:flutterapp/domain/models/deck.dart';
import 'package:flutterapp/domain/models/flashcard.dart';
import 'dart:math';

import 'package:flutterapp/domain/models/user_stats.dart';

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
  
  int? _selectedOptionIndex;
  bool _showFeedback = false;

  late List<Map<String, dynamic>> _quizData;

  @override
  void initState() {
    super.initState();
    _generateQuizData();
  }

  void _generateQuizData() {
    _quizData = widget.deck.flashcards.map((card) {
      List<String> options = [card.backText, ...(card.distractors ?? [])];
      options.shuffle(Random());
      return {
        'frontText': card.frontText,
        'backText': card.backText,
        'image': card.image,
        'correctAnswer': card.backText,
        'shuffledOptions': options,
      };
    }).toList();
  }

  void _selectOption(int optionIndex) async {
    if (_showFeedback) return; 

    final currentCard = _quizData[_currentIndex];
    final selectedOption = currentCard['shuffledOptions'][optionIndex];
    final correctAnswer = currentCard['correctAnswer'];
    bool isCorrect = selectedOption == correctAnswer;

    setState(() {
      _selectedOptionIndex = optionIndex;
      _showFeedback = true;
    });

    if (isCorrect) _score++;

    await Future.delayed(Duration(milliseconds: isCorrect ? 600 : 1200));

    if (!mounted) return;

    if (_currentIndex + 1 < _quizData.length) {
      setState(() {
        _currentIndex++;
        _showFeedback = false;
        _selectedOptionIndex = null;
      });
    } else {
      _finishQuiz();
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _gameFinished = false;
      _showFeedback = false;
      _selectedOptionIndex = null;
      _generateQuizData();
    });
  }

  void _finishQuiz() async {
    int totalExpEarned = _score * 10;
    final userRepo = UserRepositoryImpl(LocalDataSource());
    UserStats? stats = await userRepo.getUserStats("current_user");
    
    stats.addEXP(totalExpEarned);
    stats.updateStreak();
    await userRepo.updateUserStats(stats);
  
    setState(() {
      _gameFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_quizData.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: Center(child: Text("No questions.", style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    if (_gameFinished) {
      return QuizResultWidget(
        score: _score,
        totalQuestions: _quizData.length,
        quizCards: _quizData,
        userAnswers: const {}, 
        onRestart: _restartQuiz,
      );
    }

    final currentCard = _quizData[_currentIndex];
    final options = currentCard['shuffledOptions'] as List<String>;
    final progress = (_currentIndex + 1) / _quizData.length;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primaryNavy,
        title: const Text("Quiz Mode", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                tween: Tween<double>(begin: 0, end: progress),
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.textPrimary,
                  color: AppColors.primaryNavy,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    key: ValueKey<int>(_currentIndex), 
                    children: [
                      _buildQuestionCard(currentCard),
                      const SizedBox(height: 30),
                      ...List.generate(options.length, (i) => _buildOptionTile(options[i], i, currentCard['correctAnswer'])),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> card) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primaryNavy.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          if (card['image'] != null && card['image'].isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.memory(base64Decode(card['image']), height: 140, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            card['frontText'],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String text, int index, String correctAnswer) {
    Color cardColor = AppColors.textPrimary;
    Color textColor = AppColors.textDark;
    Color borderColor = AppColors.textDark.withOpacity(0.05);

    if (_showFeedback) {
      if (text == correctAnswer) {
        // Highlighting correct answer in Green
        cardColor = const Color(0xFFE8F5E9); 
        textColor = const Color(0xFF2E7D32);
        borderColor = Colors.green;
      } else if (_selectedOptionIndex == index) {
        // Highlighting wrong selection in Red
        cardColor = const Color(0xFFFFEBEE); 
        textColor = AppColors.error;
        borderColor = AppColors.error;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _selectOption(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}