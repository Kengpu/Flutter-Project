import 'card.dart';
class Deck {
  const Deck ({
    required this.id,
    required this.title, 
    required this.totalPoint, 
    required this.highscore, 
    required this.cards, 
  
  });
  final String id;
  final String title;
  final int totalPoint;
  final int highscore;
  final List<Card> cards;

  void saveDeck(){}
  void deleteDeck(){}
  void getAllDecks(){}
  void importFromCSV(file){}
}