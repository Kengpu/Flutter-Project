// import 'dart:ui';

class Card {
  const Card ({
    required this.id,
    required this.frontText,
    required this.backText,
    required this.status,
    required this.distractors,
  });

  final String id;
  final String frontText;
  final String backText;
  final CardStatus status;
  final List<String> distractors;
}

enum CardStatus {
  news,
  learning,
  mastered,
}