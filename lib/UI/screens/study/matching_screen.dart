import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutterapp/UI/widgets/matching_result.dart'; // <--- Import the other file here

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MatchingScreen(),
    );
  }
}

class GameItem {
  final String text;
  final String matchId;
  bool isMatched = false;
  bool isSelected = false;
  bool isError = false;

  GameItem({required this.text, required this.matchId});
}

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingScreen> {
  final List<Map<String, String>> rawData = [
    {"front": "Primary Language", "back": "Dart"},
    {"front": "UI Building Block", "back": "Widget"},
    {"front": "Static UI Widget", "back": "StatelessWidget"},
    {"front": "Dynamic UI Widget", "back": "StatefulWidget"},
    {"front": "Update State Method", "back": "setState()"},
    {"front": "Config File", "back": "pubspec.yaml"},
  ];

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
      flatList = [];
      for (var data in rawData) {
        flatList.add(GameItem(text: data['front']!, matchId: data['front']!));
        flatList.add(GameItem(text: data['back']!, matchId: data['front']!));
      }
      flatList.shuffle();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() => _secondsElapsed++));
  }

  void _onWin() {
    _timer?.cancel();
    int minutes = _secondsElapsed ~/ 60;
    if (minutes < 2) pointsEarned = 50;
    else if (minutes < 5) pointsEarned = 25;
    else pointsEarned = 10;

    setState(() => gameFinished = true);
  }

  void _handleTap(int index) async {
    if (isProcessing || flatList[index].isMatched || flatList[index].isSelected) return;

    setState(() => flatList[index].isSelected = true);

    if (firstSelectedIndex == null) {
      firstSelectedIndex = index;
    } else {
      isProcessing = true;
      await Future.delayed(const Duration(milliseconds: 500));

      if (flatList[firstSelectedIndex!].matchId == flatList[index].matchId) {
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
        await Future.delayed(const Duration(milliseconds: 500));
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Text(_formatTime(_secondsElapsed), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Text("FLUTTER MATCH", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.5,
                      ),
                      itemCount: flatList.length,
                      itemBuilder: (context, index) {
                        final item = flatList[index];
                        return _buildCard(item, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Using the widget from the other file
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

  Widget _buildCard(GameItem item, int index) {
    return GestureDetector(
      onTap: () => _handleTap(index),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: item.isMatched ? 0.0 : 1.0,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: item.isError ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            double shakeOffset = sin(value * pi * 4) * 10;
            return Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: item.isError ? Colors.redAccent : (item.isSelected ? Colors.white : Colors.white.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(item.text, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: item.isSelected || item.isError ? Colors.black : Colors.white)),
              ),
            );
          },
        ),
      ),
    );
  }
}