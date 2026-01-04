import 'package:uuid/uuid.dart';

enum CardStatus 
{
  isNew,
  learning,
  mastered
}

const uuid = Uuid();

class Flashcard {
  final String id;
  String frontText;
  String backText;
  String? image;
  CardStatus status;
  List<String>? distractors;

  Flashcard({
    String? id,
    required this.frontText,
    required this.backText,
    this.image,
    this.status = CardStatus.isNew,
    this.distractors,
  }): id = id ?? uuid.v4();

  bool get quizable => distractors != null && distractors!.isNotEmpty;

  @override
  String toString() {
    return """
Id: $id,
Front Text: $frontText,
Back Text: $backText,
Image: $image,
Status: $status,
Distrators: $distractors,
Quizable: $quizable
""";
  }
}