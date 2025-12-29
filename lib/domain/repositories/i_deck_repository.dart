import '../models/deck.dart';

abstract class IDeckRepository {
  Future<List<Deck>> getAllDecks();
  Future<Deck> getDeckById(String id);
  Future<void> addDeck(Deck deck);
  Future<void> updateDeck(Deck deck);
  Future<void> deleteDeck(String id);
}
