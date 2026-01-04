import 'package:flutter/material.dart';
import 'package:flutterapp/UI/screens/editor/deck_form_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutterapp/UI/providers/deck_provider.dart';
import 'package:flutterapp/UI/providers/user_provider.dart';
import 'package:flutterapp/core/constants/app_colors.dart';
import 'package:flutterapp/UI/widgets/deck_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the providers for data updates
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
                          onTap: () => _navigateToStudy(context, deck),
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

  void _navigateToStudy(BuildContext context, deck) {
    // Navigator.push logic to your Study/Game Screen
  }
}