import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutterapp/core/constants/app_colors.dart'; // Import your colors
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

  void _onWin() {
    _timer?.cancel();
    
    if (_secondsElapsed < 30) {
      pointsEarned = 100;
    } else if (_secondsElapsed < 60) {
      pointsEarned = 75;
    } else {
      pointsEarned = 50;
    }

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

        if (flatList.every((item) => item.isMatched)) {
          _onWin();
        }
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
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
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
                    itemBuilder: (context, index) => _buildCard(flatList[index], index),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.primaryNavy),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.primaryNavy, size: 18),
                const SizedBox(width: 8),
                Text(
                  _formatTime(_secondsElapsed),
                  style: const TextStyle(
                    color: AppColors.primaryNavy, 
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

  Widget _buildCard(GameItem item, int index) {
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
                  color: item.isError
                      ? AppColors.error
                      : item.isSelected
                          ? AppColors.textPrimary 
                          : AppColors.primaryNavy, 
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNavy.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                  border: Border.all(
                    color: item.isSelected ? AppColors.primaryNavy : Colors.transparent,
                    width: 2,
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
                    color: item.isSelected || item.isError 
                        ? AppColors.primaryNavy 
                        : AppColors.textPrimary,
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