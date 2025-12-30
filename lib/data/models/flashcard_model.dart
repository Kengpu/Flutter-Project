import '../../domain/models/flashcard.dart';

class FlashcardModel {
  final String id;
  final String frontText;
  final String backText;
  final CardStatus status;
  final List<String>? distractors;

  FlashcardModel({
    required this.id,
    required this.frontText,
    required this.backText,
    required this.status,
    this.distractors,
  });

  factory FlashcardModel.fromEntity(Flashcard flashcard){
    return FlashcardModel(
      id: flashcard.id,
      frontText: flashcard.frontText,
      backText: flashcard.backText,
      status: flashcard.status,
      distractors: flashcard.distractors
    );
  }

  Flashcard toEntity() {
    return Flashcard(
      id: id,
      frontText: frontText,
      backText: backText,
      status: status,
      distractors: distractors,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "frontText": frontText,
    "backText": backText,
    "status": status.name,
    "distractors": distractors,
  };

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json["id"] as String,
      frontText: json["frontText"] as String, 
      backText: json["backText"] as String, 
      status: CardStatus.values.firstWhere((e) => e.name == json["status"]), 
      distractors: json["distractors"] != null ? List<String>.from(json["distractors"]) : null,
      );
  }
}