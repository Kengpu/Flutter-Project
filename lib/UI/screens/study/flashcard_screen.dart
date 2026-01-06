import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants/app_colors.dart';
import 'package:flutterapp/domain/models/deck.dart';
import 'package:flutterapp/domain/models/flashcard.dart';
import 'dart:math';

class FlashcardScreen extends StatefulWidget {
  final Deck deck;

  const FlashcardScreen({
    super.key,
    required this.deck,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {

  late List<Flashcard> _cards;
  int _currentIndex = 0;
  bool _isFront = true;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _cards = widget.deck.flashcards;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  void _nextCard() {
    if (_cards.isEmpty) return;
    _controller.reset();
    setState(() {
      _isFront = true;
      _currentIndex = (_currentIndex + 1) % _cards.length;
    });
  }

  void _prevCard() {
    if (_cards.isEmpty) return;
    _controller.reset();
    setState(() {
      _isFront = true;
      _currentIndex =
          (_currentIndex - 1 + _cards.length) % _cards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.primaryCyan,
        appBar: AppBar(
          title: Text(widget.deck.title),
          backgroundColor: AppColors.primaryCyan,
          foregroundColor: Colors.black,
        ),
        body: const Center(
          child: Text(
            "No flashcards in this deck",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      backgroundColor: AppColors.primaryCyan,
      appBar: AppBar(
        title: Text(widget.deck.title),
        backgroundColor: AppColors.primaryCyan,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.blueAccent,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),

            const SizedBox(height: 10),
            Text(
              "${_currentIndex + 1} of ${_cards.length}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            // Flashcard
            GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final angle = _animation.value * pi;
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: angle < pi / 2
                        ? _buildCardSide(
                            _cards[_currentIndex].frontText,
                            AppColors.starGold,
                            AppColors.textPrimary,
                          )
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: _buildCardSide(
                              _cards[_currentIndex].backText,
                              AppColors.primaryOrange,
                              AppColors.textPrimary,
                            ),
                          ),
                  );
                },
              ),
            ),

            const Spacer(),

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                  onPressed: _prevCard,
                  icon: const Icon(Icons.arrow_back_ios_new),
                  padding: const EdgeInsets.all(20),
                ),
                IconButton.filled(
                  onPressed: _nextCard,
                  icon: const Icon(Icons.arrow_forward_ios),
                  padding: const EdgeInsets.all(20),
                ),
              ],
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSide(String text, Color bgColor, Color textColor) {
    return Container(
      width: double.infinity,
      height: 350,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
