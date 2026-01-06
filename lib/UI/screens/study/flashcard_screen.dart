import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants/app_colors.dart';
import 'dart:math';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FlashcardScreen(),
    ));

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  // 1. Data Source
  final List<Map<String, String>> _cards = [
    {"front": "Primary Language", "back": "Dart"},
    {"front": "UI Building Block", "back": "Widget"},
    {"front": "Static UI Widget", "back": "StatelessWidget"},
    {"front": "Dynamic UI Widget", "back": "StatefulWidget"},
    {"front": "Update State Method", "back": "setState()"},
    {"front": "Config File", "back": "pubspec.yaml"},
    {"front": "App Structure Widget", "back": "Scaffold"},
    {"front": "Vertical Layout", "back": "Column"},
    {"front": "Horizontal Layout", "back": "Row"},
    {"front": "Widget Location Tree", "back": "BuildContext"},
    {"front": "Padding & Margin Widget", "back": "Container"},
    {"front": "Scrollable Linear List", "back": "ListView"},
    {"front": "Fill Available Space", "back": "Expanded"},
    {"front": "Hot Reload", "back": "Update code without losing state"},
    {"front": "initState()", "back": "Called once when widget is created"},
    {"front": "dispose()", "back": "Called when widget is destroyed"},
    {"front": "Detect Taps", "back": "GestureDetector"},
    {"front": "Top Widget Tree", "back": "MaterialApp"},
    {"front": "Overlap Widgets", "back": "Stack"},
    {"front": "Fetch Dependencies", "back": "flutter pub get"},
    {"front": "State Management", "back": "Sharing data across the app"},
    {"front": "Main Axis (Column)", "back": "Vertical Alignment"},
    {"front": "Cross Axis (Column)", "back": "Horizontal Alignment"},
    {"front": "Ripple Effect", "back": "InkWell"},
    {"front": "App Entry Point", "back": "main()"},
  ];

  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    // 2. Setup Animation Controller
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
    _controller.reset(); // Reset animation for new card
    setState(() {
      _isFront = true;
      _currentIndex = (_currentIndex + 1) % _cards.length;
    });
  }

  void _prevCard() {
    _controller.reset();
    setState(() {
      _isFront = true;
      _currentIndex = (_currentIndex - 1 + _cards.length) % _cards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      backgroundColor: AppColors.primaryCyan,
      appBar: AppBar(
        backgroundColor: AppColors.primaryCyan,
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),

      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
            Text("${_currentIndex + 1} of ${_cards.length}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            // 3. Animated Flashcard
            GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final angle = _animation.value * pi;
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspective
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: angle < pi / 2
                        ? _buildCardSide(
                            _cards[_currentIndex]["front"]!,
                            AppColors.starGold,
                            AppColors.textPrimary,
                          )
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: _buildCardSide(
                              _cards[_currentIndex]["back"]!,
                              AppColors.primaryOrange,
                              AppColors.textPrimary,
                            ),
                          ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
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
          )
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
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