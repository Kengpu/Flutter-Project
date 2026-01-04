import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deck_model.dart';
import '../models/user_stats_model.dart';

class LocalDataSource {
  static const String _decksKey = 'decks_data';
  static const String _statsKey = 'user_stats_data';

  Future<void> saveDecks(List<DeckModel> decks) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      decks.map((deck) => deck.toJson()).toList(),
    );
    await prefs.setString(_decksKey, encodedData);
  }

  Future<List<DeckModel>> loadDecks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? content = prefs.getString(_decksKey);

      if (content == null || content.isEmpty) return [];

      final List<dynamic> decodedData = jsonDecode(content);
      return decodedData.map((item) => DeckModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint("Error loading decks: $e");
      return []; 
    }
  }

  // --- SAVE STATS ---
  Future<void> saveUserStats(UserStatsModel stats) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(stats.toJson());
    await prefs.setString(_statsKey, encodedData);
  }

  // --- LOAD STATS ---
  Future<UserStatsModel?> loadUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? content = prefs.getString(_statsKey);

      if (content == null) return null;
      return UserStatsModel.fromJson(jsonDecode(content));
    } catch (e) {
      return null;
    }
  }
}