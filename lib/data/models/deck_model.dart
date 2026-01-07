import '../../domain/models/deck.dart';
import 'flashcard_model.dart';

class DeckModel {
  final String id;
  final String title;
  final String description;
  final String? coverImage;
  final int totalPoint;
  final int highscore;
  final DeckStatus deckStatus;
  final List<FlashcardModel> flashcards;


  DeckModel({
    required this.id,
    required this.title,
    required this.description,
    this.coverImage,
    required this.totalPoint,
    required this.highscore,
    required this.deckStatus,
    required this.flashcards,
  });

    factory DeckModel.fromEntity(Deck deck){
    return DeckModel(
      id: deck.id,
      title: deck.title,
      description: deck.description,
      coverImage: deck.coverImage,
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
      description: description,
      coverImage: coverImage,
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
      "description": description,
      "coverImage": coverImage,
      "totalPoint": totalPoint,
      "highscore": highscore,
      "deckStatus": deckStatus.name,
      "flashcards": flashcards.map((f) => f.toJson()).toList(),
    };
  }

  factory DeckModel.fromJson(Map<String, dynamic> json) {
    return DeckModel(
      id: json["id"] as String,
      title: json["title"] as String, 
      description: json["description"] ?? "",
      coverImage: json["coverImage"] as String?,
      totalPoint: json["totalPoint"] ?? 0, 
      highscore:json["highscore"] ?? 0, 
      deckStatus: DeckStatus.values.byName(json["deckStatus"]),
      flashcards: (json["flashcards"] as List).map((f) => FlashcardModel.fromJson(f)).toList(),
      );
  }
}