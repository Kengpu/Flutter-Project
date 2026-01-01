import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutterapp/domain/models/deck.dart';
import 'package:flutterapp/domain/models/flashcard.dart';
import 'package:flutterapp/domain/repositories/i_deck_repository.dart';

class DeckProvider extends ChangeNotifier{
  final IDeckRepository deckRepository;
  List<Deck> _decks = [];
  bool _isLoading = false;

  DeckProvider({required this.deckRepository});

  List<Deck> get decks => _decks;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    _decks = await deckRepository.getAllDecks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> importFromCSV (String CSVContent, String deckTitle) async {
    List<Flashcard> improtedCards = [];
    final lines = CSVContent.split("\n");
    var uuid = const Uuid();

    for(var line in lines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split(",");
      improtedCards.add(Flashcard(
        frontText: parts[0].trim(), 
        backText: parts[1].trim()));
    }

    final newDeck = Deck(id: uuid.v4(), title: deckTitle, flashcards: improtedCards);
    await deckRepository.addDeck(newDeck);
    _decks.add(newDeck);
    notifyListeners();
  }

  Future<void> createDeck(String title) async {
    final newDeck = Deck(
      title: title.trim(), 
      flashcards: [],
      );

      await deckRepository.addDeck(newDeck);
      _decks.add(newDeck);
      notifyListeners();
  }

  Deck getDeckById(String id) {
    return _decks.firstWhere((d) => d.id == id);
  }

  Future<void> updateDeck (String id, String? newTitle, List<Flashcard>? updateCards) async {
    final index = _decks.indexWhere((d) => d.id == id);
    if(index == -1) return;
    Deck existingDeck = _decks[index];
    
    final updatedDeck = Deck(
      id: existingDeck.id,
      title: newTitle ?? existingDeck.title,
      flashcards: updateCards ?? existingDeck.flashcards,
      deckStatus: existingDeck.deckStatus,
      highscore: existingDeck.highscore,
      totalPoint: existingDeck.totalPoint,);
    await deckRepository.updateDeck(updatedDeck);
    _decks[index] = updatedDeck;
    notifyListeners();
  }
  
  Future<void> deleteDeck (String id) async {
    await deckRepository.deleteDeck(id);
    _decks.removeWhere((d) => d.id == id);
    notifyListeners();
  }

}