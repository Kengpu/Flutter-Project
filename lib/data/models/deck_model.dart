import '../../domain/models/deck.dart';
import 'flashcard_model.dart';

class DeckModel {
  final String id;
  final String title;
  final int totalPoint;
  final int highscore;
  final DeckStatus deckStatus;
  final List<FlashcardModel> flashcards;


  DeckModel({
    required this.id,
    required this.title,
    required this.totalPoint,
    required this.highscore,
    required this.deckStatus,
    required this.flashcards,
  });

    factory DeckModel.fromEntity(Deck deck){
    return DeckModel(
      id: deck.id,
      title: deck.title,
      totalPoint: deck.totalPoint,
      highscore: deck.highscore,
      deckStatus: deck.deckStatus,
      flashcards: deck.flashcards.map((f) => FlashcardModel.fromEntity(f)).toList(),
    );
  }

  Deck toEntity() {
    return Deck(
      id: id,
      title: title,
      totalPoint: totalPoint,
      highscore: highscore,
      deckStatus: deckStatus,
      flashcards: flashcards.map((f) => f.toEntity()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {  
      "id": id,
      "title": title,
      "totalPoint": totalPoint,
      "highscore": highscore,
      "deckStatus": deckStatus.name,
      "flashcards": flashcards.map((f) => f.toJson()).toList(),
    };
  }

  factory DeckModel.fromJson(Map<String, dynamic> json) {
    return DeckModel(
      id: json["id"],
      title: json["title"], 
      totalPoint: json["totalPoint"], 
      highscore:json["highscore"], 
      deckStatus: DeckStatus.values.byName(json["deckStatus"]),
      flashcards: (json["flashcards"] as List).map((f) => FlashcardModel.fromJson(f)).toList(),
      );
  }
}