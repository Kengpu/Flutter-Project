import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutterapp/core/constants/app_colors.dart';
import 'package:flutterapp/data/datascource/local_database.dart';
import 'package:flutterapp/data/repositories/user_repository_impl.dart';
import 'package:flutterapp/domain/models/deck.dart';
import 'package:flutterapp/domain/models/flashcard.dart';
import 'package:flutterapp/UI/widgets/matching_result.dart';

class GameItem {
  final String text;
  final String matchId;
  bool isMatched = false;
  bool isSelected = false;
  bool isError = false;

  GameItem({required this.text, required this.matchId});
}

class MatchingScreen extends StatefulWidget {
  final Deck deck;

  const MatchingScreen({
    super.key,
    required this.deck,
  });

  @override
  State<MatchingScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingScreen> {
  List<GameItem> flatList = [];
  int? firstSelectedIndex;
  bool isProcessing = false;

  Timer? _timer;
  int _secondsElapsed = 0;
  int pointsEarned = 0;
  bool gameFinished = false;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    _timer?.cancel();
    setState(() {
      gameFinished = false;
      _secondsElapsed = 0;
      pointsEarned = 0;
      firstSelectedIndex = null;
      flatList.clear();

      for (Flashcard card in widget.deck.flashcards) {
        flatList.add(GameItem(text: card.frontText, matchId: card.id ?? ""));
        flatList.add(GameItem(text: card.backText, matchId: card.id ?? ""));
      }
      flatList.shuffle();
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _secondsElapsed++),
    );
  }

  void _onWin() async {
    _timer?.cancel();
    int pairsCount = widget.deck.flashcards.length;
    int basePoints = pairsCount * 7;
    int targetTimeSeconds = pairsCount * 60;
    int halfTime = targetTimeSeconds ~/ 2;

    double multiplier = 1.0;
    if (_secondsElapsed < halfTime) {
      multiplier = 2.0;
    } else if (_secondsElapsed < targetTimeSeconds) {
      double progress = (_secondsElapsed - halfTime) / (targetTimeSeconds - halfTime);
      multiplier = 2.0 - progress;
    }

    pointsEarned = (basePoints * multiplier).toInt();

    final userRepository = UserRepositoryImpl(LocalDataSource());
    final stats = await userRepository.getUserStats("current_user");
    stats.addEXP(pointsEarned);
    stats.updateStreak();
    await userRepository.updateUserStats(stats);

    setState(() => gameFinished = true);
  }

  void _handleTap(int index) async {
    if (isProcessing || flatList[index].isMatched || flatList[index].isSelected) return;

    setState(() => flatList[index].isSelected = true);

    if (firstSelectedIndex == null) {
      firstSelectedIndex = index;
    } else {
      isProcessing = true;
      if (flatList[firstSelectedIndex!].matchId == flatList[index].matchId) {
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {
          flatList[firstSelectedIndex!].isMatched = true;
          flatList[index].isMatched = true;
        });
        if (flatList.every((item) => item.isMatched)) _onWin();
      } else {
        setState(() {
          flatList[firstSelectedIndex!].isError = true;
          flatList[index].isError = true;
        });
        await Future.delayed(const Duration(milliseconds: 600));
        setState(() {
          flatList[firstSelectedIndex!].isSelected = false;
          flatList[index].isSelected = false;
          flatList[firstSelectedIndex!].isError = false;
          flatList[index].isError = false;
        });
      }
      firstSelectedIndex = null;
      isProcessing = false;
    }
  }

  String _formatTime(int sec) =>
      '${(sec ~/ 60).toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: flatList.length,
                    itemBuilder: (context, index) => _buildCard(context, flatList[index], index),
                  ),
                ),
              ],
            ),
          ),
          if (gameFinished)
            ResultWidget(
              score: pointsEarned,
              time: _formatTime(_secondsElapsed),
              onRestart: _setupGame,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.close, color: theme.colorScheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  _formatTime(_secondsElapsed),
                  style: TextStyle(
                    color: theme.colorScheme.primary, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48), 
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, GameItem item, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color cardColor;
    Color textColor;
    Color borderColor = Colors.transparent;
    
    if (item.isError) {
      cardColor = isDark ? const Color(0xFFFF8A80).withOpacity(0.2) : AppColors.error;
      textColor = isDark ? const Color(0xFFFF8A80) : Colors.white;
      borderColor = isDark ? const Color(0xFFFF8A80) : Colors.transparent;
    } else if (item.isSelected) {
      // FIX: Light Mode Selection Visibility
      cardColor = isDark ? theme.colorScheme.primary : Colors.white; 
      textColor = isDark ? theme.colorScheme.onPrimary : theme.colorScheme.primary;
      borderColor = theme.colorScheme.primary; 
    } else {
      cardColor = isDark ? theme.colorScheme.surface : theme.colorScheme.primary;
      textColor = isDark ? theme.colorScheme.onSurface : Colors.white;
      borderColor = Colors.transparent;
    }

    return GestureDetector(
      onTap: () => _handleTap(index),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: item.isMatched ? 0.0 : 1.0,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: item.isError ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            final shake = sin(value * pi * 4) * 8;
            return Transform.translate(
              offset: Offset(shake, 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(isDark ? 0.1 : 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                  border: Border.all(
                    color: borderColor,
                    width: 3, 
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  item.text,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}