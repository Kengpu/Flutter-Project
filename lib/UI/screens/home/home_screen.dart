import 'package:flutter/material.dart';
import 'package:flutterapp/UI/screens/editor/deck_form_screen.dart';
import 'package:flutterapp/UI/screens/study/flashcard_screen.dart';
import 'package:flutterapp/domain/models/deck.dart';
import 'package:provider/provider.dart';
import 'package:flutterapp/UI/providers/deck_provider.dart';
import 'package:flutterapp/UI/providers/user_provider.dart';
import 'package:flutterapp/core/constants/app_colors.dart';
import 'package:flutterapp/UI/widgets/deck_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deckProvider = context.watch<DeckProvider>();
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.primaryCyan, 
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'StudyFlow',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToCreateDeck(context),
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text('Deck', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4FF93), // Lime color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Decks',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
            ),

            Expanded(
              child: deckProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 10, bottom: 80),
                      itemCount: deckProvider.decks.length,
                      itemBuilder: (context, index) {
                        final deck = deckProvider.decks[index];
                        return DeckTile(
                          deck: deck,
                          onTap: () => _showGameModePopup(context, deck),
                          onActionSelected: (action) {
                            if (action == 'edit') {
                              _navigateToEditDeck(context, deck);
                            } else if (action == 'delete') {
                              deckProvider.deleteDeck(deck.id);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGameModePopup(BuildContext context, Deck deck) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFFF4FF93), // Match the yellow in your screenshot
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close Button at top right
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildModeButton(context, "Quiz", Icons.help_outline, () {
                Navigator.pop(context);
                // navigate to quiz screen
              }),
              _buildModeButton(context, "Matching", Icons.extension, () {
                Navigator.pop(context);
                // navigate to matching screen
              }),
            ],
          ),
          const SizedBox(height: 20),
          _buildModeButton(context, "Flashcard", Icons.style, () {
            Navigator.pop(context);
            _navigateToFlashcard(context, deck); 
          }),
        ],
      ),
    ),
  );
}

Widget _buildModeButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 40, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    ),
  );
  }

  void _navigateToCreateDeck(BuildContext context) {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const DeckFormScreen()),
      );
  }

  void _navigateToEditDeck(BuildContext context, deck) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeckFormScreen(existingDeck: deck,)),
      );
  }

  void _navigateToFlashcard(BuildContext context, deck) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FlashcardScreen()),
      );
  }
}