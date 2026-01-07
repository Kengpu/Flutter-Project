import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutterapp/core/constants/app_colors.dart';
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
    // Access current theme data
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.deck.title),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: Center(
          child: Text(
            "No cards found.", 
            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))
          ),
        ),
      );
    }

    final progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.primary,
        title: Text(widget.deck.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.surfaceVariant,
              color: theme.colorScheme.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 12),
            Text(
              "CARD ${_currentIndex + 1} OF ${_cards.length}",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: theme.colorScheme.onSurface.withOpacity(0.5), 
                fontSize: 12
              ),
            ),
            const Spacer(),
            // Flip Card Animation
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
                            context,
                            _cards[_currentIndex].frontText,
                            "TERM",
                            _cards[_currentIndex].image,
                            theme.colorScheme.primary, 
                            theme.colorScheme.surface, 
                          )
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: _buildCardSide(
                              context,
                              _cards[_currentIndex].backText,
                              "DEFINITION",
                              null,
                              isDark ? Colors.redAccent[100]! : AppColors.error, 
                              isDark ? theme.colorScheme.surface : const Color(0xFFFFF5F5),
                            ),
                          ),
                  );
                },
              ),
            ),
            const Spacer(),
            // Navigation Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(context, Icons.arrow_back_ios_new, _prevCard, _currentIndex > 0),
                _buildNavButton(context, Icons.arrow_forward_ios, _nextCard, _currentIndex < _cards.length - 1),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSide(
    BuildContext context, 
    String text, 
    String label, 
    String? imageBase64, 
    Color themeColor, 
    Color cardBg
  ) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      height: 420,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: themeColor.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.1),
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
                color: themeColor.withOpacity(0.7),
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
                        color: theme.colorScheme.onSurface, 
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Icon(
              Icons.flip_camera_android, 
              color: themeColor.withOpacity(0.4), 
              size: 20
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, IconData icon, VoidCallback onTap, bool enabled) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: enabled 
              ? theme.colorScheme.primary 
              : (isDark ? theme.colorScheme.surface : theme.colorScheme.surfaceVariant),
          borderRadius: BorderRadius.circular(20),
          border: enabled ? null : Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1)),
        ),
        child: Icon(
          icon, 
          color: enabled 
              ? theme.colorScheme.onPrimary 
              : theme.colorScheme.onSurface.withOpacity(0.3), 
          size: 24
        ),
      ),
    );
  }
}