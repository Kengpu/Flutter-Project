import 'package:flutterapp/domain/models/flashcard.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid(); 

class Deck {
  final String id;
  String title;
  int totalPoint;
  int highscore;
  List<Flashcard> flashcards;

  Deck({
    String? id,
    required this.title,
    this.totalPoint = 0,
    this.highscore =0,
    required this.flashcards
  }) : id = id ?? uuid.v4();

  @override
  String toString() {
    return """"
Id: $id,
Title: $title,
Total Point: $totalPoint,
Highscore: $highscore,
Card: ${flashcards.length} total
""";
  }
}