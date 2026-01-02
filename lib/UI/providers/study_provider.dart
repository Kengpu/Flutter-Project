import 'package:flutter/material.dart';
import 'package:flutterapp/UI/providers/user_provider.dart';
import 'package:flutterapp/domain/models/deck.dart';
import 'package:flutterapp/domain/models/flashcard.dart';

class StudyProvider extends ChangeNotifier{
  List<Flashcard> _cardsSession = [];
  int _index = 0;
  int _correctAnswers = 0;

  void submit(bool isCorrect) {
    if (isCorrect) _correctAnswers += 1;
  }
  void startQuiz (Deck deck) {
    _cardsSession = List.from(deck.flashcards)..shuffle();
    _index = 0;
    _correctAnswers = 0;
    notifyListeners();
  }

  List<String> getOptions(Flashcard card, List<Flashcard> allCards) {
    List<String> options = [card.backText];

    final distractors = allCards.where((c) => c.id != card.id).map((c) => c.backText).toSet().toList()..shuffle();
    return options..shuffle();
  }

  void nextCard() {
    if (_index < _cardsSession.length - 1) {
      _index += 1;
      notifyListeners();
    }
  } 

  void endSession(UserProvider userProvider) {
    int exp = _correctAnswers * 10;

    userProvider.stats?.updateStreak();
    userProvider.addProgress(exp);
    notifyListeners();
  }
}