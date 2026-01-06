import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutterapp/core/constants/app_colors.dart'; // Import your colors
import 'package:flutterapp/domain/models/deck.dart';
import 'package:flutterapp/domain/models/flashcard.dart';

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
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
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
    if (_cards.isEmpty || _currentIndex >= _cards.length - 1) return;
    _controller.reset();
    setState(() {
      _isFront = true;
      _currentIndex++;
    });
  }

  void _prevCard() {
    if (_cards.isEmpty || _currentIndex <= 0) return;
    _controller.reset();
    setState(() {
      _isFront = true;
      _currentIndex--;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.deck.title),
          backgroundColor: AppColors.primaryNavy,
          foregroundColor: AppColors.textPrimary,
        ),
        body: const Center(
          child: Text("No cards found.", style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primaryNavy,
        title: Text(widget.deck.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.textPrimary,
              color: AppColors.primaryNavy,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 12),
            Text(
              "CARD ${_currentIndex + 1} OF ${_cards.length}",
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 12),
            ),
            const Spacer(),
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
                            "TERM",
                            _cards[_currentIndex].image,
                            AppColors.primaryNavy, 
                            AppColors.textPrimary, 
                          )
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: _buildCardSide(
                              _cards[_currentIndex].backText,
                              "DEFINITION",
                              null,
                              AppColors.error,       // Red theme for back
                              const Color(0xFFFFF5F5), // Light error tint
                            ),
                          ),
                  );
                },
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(Icons.arrow_back_ios_new, _prevCard, _currentIndex > 0),
                _buildNavButton(Icons.arrow_forward_ios, _nextCard, _currentIndex < _cards.length - 1),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSide(String text, String label, String? imageBase64, Color themeColor, Color cardBg) {
    return Container(
      width: double.infinity,
      height: 420,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: themeColor.withOpacity(0.1), width: 2),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              label,
              style: TextStyle(
                color: themeColor.withOpacity(0.6),
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (imageBase64 != null && imageBase64.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(
                          base64Decode(imageBase64),
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: themeColor == AppColors.primaryNavy 
                            ? AppColors.textDark 
                            : themeColor, 
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Icon(Icons.flip_camera_android, color: themeColor.withOpacity(0.3), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap, bool enabled) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryNavy : AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(20),
          border: enabled ? null : Border.all(color: AppColors.navyLight),
        ),
        child: Icon(
          icon, 
          color: enabled ? AppColors.textPrimary : AppColors.textSecondary, 
          size: 24
        ),
      ),
    );
  }
}