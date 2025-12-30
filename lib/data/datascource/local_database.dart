import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/deck_model.dart';
import '../models/user_stats_model.dart';

class LocalDataSource {
  static const String _decksFileName = 'decks.json';
  static const String _statsFileName = 'user_stats.json';

  Future<String> _getDirPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> saveDecks(List<DeckModel> decks) async {
    final path = await _getDirPath();
    final file = File('$path/$_decksFileName');
    
    final String encodedData = jsonEncode(
      decks.map((deck) => deck.toJson()).toList(),
    );
    
    await file.writeAsString(encodedData);
  }

  Future<List<DeckModel>> loadDecks() async {
    try {
      final path = await _getDirPath();
      final file = File('$path/$_decksFileName');

      if (!await file.exists()) return [];

      final String content = await file.readAsString();
      final List<dynamic> decodedData = jsonDecode(content);

      return decodedData.map((item) => DeckModel.fromJson(item)).toList();
    } catch (e) {
      return []; 
    }
  }

  Future<void> saveUserStats(UserStatsModel stats) async {
    final path = await _getDirPath();
    final file = File('$path/$_statsFileName');
    
    final String encodedData = jsonEncode(stats.toJson());
    await file.writeAsString(encodedData);
  }

  Future<UserStatsModel?> loadUserStats() async {
    try {
      final path = await _getDirPath();
      final file = File('$path/$_statsFileName');

      if (!await file.exists()) return null;

      final String content = await file.readAsString();
      return UserStatsModel.fromJson(jsonDecode(content));
    } catch (e) {
      return null;
    }
  }
}