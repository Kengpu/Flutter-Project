import 'dart:convert';
import '../../domain/repositories/i_deck_repository.dart';
import '../datascource/local_database.dart';
import '../../domain/models/deck.dart';
import '../models/deck_model.dart';

class DeckRepositoryImpl implements IDeckRepository {
  final LocalDataSource localDataSource;

  DeckRepositoryImpl(this.localDataSource);

  @override
  Future<List<Deck>> getAllDecks() async {
    final List<DeckModel> models = await localDataSource.loadDecks();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Deck> getDeckById(String id) async {
    final List<DeckModel> models = await localDataSource.loadDecks();
    final model = models.firstWhere((d) => d.id == id);
    return model.toEntity();
  }

  @override
  Future<void> addDeck(Deck deck) async {
    final List<DeckModel> models = await localDataSource.loadDecks();
    models.add(DeckModel.fromEntity(deck));
    await localDataSource.saveDecks(models);
  }
  
  @override
  Future<void> updateDeck(Deck updateDeck) async {
    final List<DeckModel> models = await localDataSource.loadDecks();
    final index = models.indexWhere((d) => d.id == updateDeck.id);

    if (index != -1) {
      models[index] = DeckModel.fromEntity(updateDeck);
      await localDataSource.saveDecks(models);
    }
  }

  @override
  Future<void> deleteDeck (String id) async {
    final List<DeckModel> models = await localDataSource.loadDecks();
    models.removeWhere((d) => d.id == id);
    await localDataSource.saveDecks(models);
  }
}