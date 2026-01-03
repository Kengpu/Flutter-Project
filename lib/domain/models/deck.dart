import 'package:flutterapp/domain/models/flashcard.dart';
import 'package:uuid/uuid.dart';

enum DeckStatus{
  newDeck,
  struggling,
  uncertain,
  confident,
  mastered,
}

const uuid = Uuid(); 

class Deck {
  final String id;
  String title;
  String description;
  String? coverImage;
  int totalPoint;
  int highscore;
  DeckStatus deckStatus;
  List<Flashcard> flashcards;

  Deck({
    String? id,
    required this.title,
    this.description = """""",
    this.coverImage,
    this.totalPoint = 0,
    this.highscore =0,
    this.deckStatus = DeckStatus.newDeck,
    required this.flashcards
  }) : id = id ?? uuid.v4();

  @override
  String toString() {
    return """"
Id: $id,
Title: $title,
Descripton: $description,
Cover Image: $coverImage,
Deck Status: $deckStatus,
Total Point: $totalPoint,
Highscore: $highscore,
Card: ${flashcards.length} total
""";
  }
}