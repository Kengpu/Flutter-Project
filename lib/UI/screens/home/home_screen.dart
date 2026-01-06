import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutterapp/UI/screens/editor/deck_form_screen.dart';
import 'package:flutterapp/UI/screens/study/quiz_screen.dart';
import 'package:flutterapp/core/constants/app_colors.dart';
import 'package:flutterapp/data/datascource/local_database.dart';
import 'package:flutterapp/data/repositories/deck_repository_impl.dart';
import 'package:flutterapp/domain/models/deck.dart';
import 'package:flutterapp/UI/widgets/deck_card.dart'; // Custom widget we'll make
import 'package:flutterapp/UI/screens/study/flashcard_screen.dart';
import 'package:flutterapp/UI/screens/study/matching_screen.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DeckRepositoryImpl _deckRepo = DeckRepositoryImpl(LocalDataSource());

  List<Deck> _decks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    setState(() => _isLoading = true);
    final data = await _deckRepo.getAllDecks();
    setState(() {
      _decks = data;
      _isLoading = false;
    });
  }

  void _goToCreate() async {
    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditDeckScreen()),
    );
    if (refresh == true) {
      _loadDecks();
    }
  }

  void _goToEdit(Deck deck) async {
    final bool? refreshNeeded = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditDeckScreen(deckToEdit: deck), // Pass the existing deck
      ),
    );

    if (refreshNeeded == true) {
      _loadDecks();
    }
  }

  void _handleDelete(String deckId) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Deck?"),
            content: const Text("This action cannot be undone."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await _deckRepo.deleteDeck(deckId);
      _loadDecks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryCyan,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 30),
              const Text(
                "Decks",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _decks.isEmpty
                    ? const Center(child: Text("No decks yet. Tap + to start!"))
                    : ListView.builder(
                        itemCount: _decks.length,
                        itemBuilder: (context, index) {
                          final deck = _decks[index];
                          return DeckCard(
                            deck: deck,
                            onTap: () => _showOptionsOverlay(_decks[index]),
                            onEdit: () => _goToEdit(deck),
                            onDelete: () => _handleDelete(deck.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "StudyFlow",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        ElevatedButton.icon(
          onPressed: _goToCreate,
          icon: const Icon(Icons.add),
          label: const Text("Deck"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE1F5FE),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  void _showOptionsOverlay(Deck deck) {
    showDialog(
      context: context,
      builder: (context) => _OptionsPopup(deck: deck),
    );
  }
}

class _OptionsPopup extends StatelessWidget {
  final Deck deck;
  const _OptionsPopup({required this.deck});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF59D), // Yellow color from Figma
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _modeIcon(
                  Icons.help_outline,
                  "Quiz",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(deck: deck),
                      ),
                    );
                  },
                ),
                _modeIcon(
                  Icons.extension_outlined,
                  "Matching",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MatchingScreen(deck: deck),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _modeIcon(
              Icons.style_outlined,
              "Flashcard",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FlashcardScreen(deck: deck),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _modeIcon(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Icon(icon, size: 32, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
