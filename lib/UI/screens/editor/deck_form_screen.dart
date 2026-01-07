import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutterapp/core/constants/app_colors.dart';
import 'package:flutterapp/domain/models/deck.dart';
import 'package:flutterapp/domain/models/flashcard.dart';
import 'package:flutterapp/data/repositories/deck_repository_impl.dart';
import 'package:flutterapp/data/datascource/local_database.dart';
import 'package:flutterapp/UI/widgets/image_picker_widget.dart';
import 'package:flutterapp/UI/screens/home/home_screen.dart';

class CardControllers {
  final TextEditingController termController;
  final TextEditingController definitionController;
  List<TextEditingController> distractorControllers;
  String? imageBase64;

  CardControllers({
    String term = "",
    String definition = "",
    List<String>? distractors,
    this.imageBase64,
  }) : termController = TextEditingController(text: term),
       definitionController = TextEditingController(text: definition),
       distractorControllers = (distractors ?? [])
           .map((d) => TextEditingController(text: d))
           .toList();

  void addDistractor() {
    distractorControllers.add(TextEditingController());
  }

  void dispose() {
    termController.dispose();
    definitionController.dispose();
    for (var c in distractorControllers) {
      c.dispose();
    }
  }
}

class EditDeckScreen extends StatefulWidget {
  final Deck? deckToEdit;
  const EditDeckScreen({super.key, this.deckToEdit});

  @override
  State<EditDeckScreen> createState() => _EditDeckScreenState();
}

class _EditDeckScreenState extends State<EditDeckScreen> {
  final DeckRepositoryImpl _deckRepo = DeckRepositoryImpl(LocalDataSource());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _deckImageBase64;
  List<CardControllers> _cardControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.deckToEdit != null) {
      _titleController.text = widget.deckToEdit!.title;
      _descController.text = widget.deckToEdit!.description;
      _deckImageBase64 = widget.deckToEdit!.coverImage;
      _cardControllers = widget.deckToEdit!.flashcards
          .map(
            (card) => CardControllers(
              term: card.frontText,
              definition: card.backText,
              imageBase64: card.image,
              distractors: card.distractors,
            ),
          )
          .toList();
    } else {
      _cardControllers.add(CardControllers());
    }
  }

  void _addCard() {
    setState(() => _cardControllers.add(CardControllers()));
  }

  void _saveDeck() async {
    if (!_isValid()) return;
    List<Flashcard> finalCards = _cardControllers
        .map(
          (c) => Flashcard(
            frontText: c.termController.text,
            backText: c.definitionController.text,
            image: c.imageBase64,
            distractors: c.distractorControllers
                .map((dc) => dc.text)
                .where((text) => text.isNotEmpty)
                .toList(),
          ),
        )
        .toList();
        
    final updatedDeck = Deck(
      id: widget.deckToEdit?.id,
      title: _titleController.text,
      description: _descController.text,
      coverImage: _deckImageBase64,
      flashcards: finalCards,
    );
    
    if (widget.deckToEdit == null) {
      await _deckRepo.addDeck(updatedDeck);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } else {
      await _deckRepo.updateDeck(updatedDeck);
      if (mounted) Navigator.pop(context, true);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error,),
    );
  }

  bool _isValid () {
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar("Please enter the deck title");
      return false;
    }
    if (_cardControllers.isEmpty) {
      _showSnackBar("Please add at least one card");
      return false;
    }

    for (int i = 0; i < _cardControllers.length; i++) {
      final c = _cardControllers[i];
      if (c.termController.text.trim().isEmpty || c.definitionController.text.trim().isEmpty) {
        _showSnackBar("Card ${i+1} is missing a Term or Definition.");
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          _buildCustomAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildSectionTitle(context, "Deck Details"),
                  const SizedBox(height: 10),
                  _buildDeckHeader(context),
                  const SizedBox(height: 30),
                  _buildSectionTitle(context, "Flashcards (${_cardControllers.length})"),
                  const SizedBox(height: 10),
                  ..._cardControllers.asMap().entries.map(
                    (entry) => _buildCardEditor(context, entry.value, entry.key),
                  ),
                  const SizedBox(height: 20),
                  _buildAddCardButton(context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomActions(context),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 50, 20, 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: theme.colorScheme.onPrimary),
          ),
          const SizedBox(width: 10),
          Text(
            widget.deckToEdit == null ? "Create New Deck" : "Edit Deck",
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onBackground.withOpacity(0.6),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDeckHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.03), 
            blurRadius: 10
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildStyledField(context, _titleController, "Deck Title", Icons.title),
                const SizedBox(height: 12),
                _buildStyledField(context, _descController, "Description (Optional)", Icons.notes),
              ],
            ),
          ),
          const SizedBox(width: 15),
          _buildImagePickerWrapper(context, _deckImageBase64, (base64) => setState(() => _deckImageBase64 = base64)),
        ],
      ),
    );
  }

  Widget _buildCardEditor(BuildContext context, CardControllers controllers, int index) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.03), 
            blurRadius: 10
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "CARD ${index + 1}",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _cardControllers.removeAt(index)),
                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 20),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildStyledField(context, controllers.termController, "Term", null),
                    const SizedBox(height: 12),
                    _buildStyledField(context, controllers.definitionController, "Definition", null),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              _buildImagePickerWrapper(context, controllers.imageBase64, (base64) => setState(() => controllers.imageBase64 = base64)),
            ],
          ),
          if (controllers.distractorControllers.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Divider(height: 1, color: theme.colorScheme.background),
            ),
            Text(
              "MULTIPLE CHOICE OPTIONS",
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
            ...controllers.distractorControllers.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _buildStyledField(context, entry.value, "Option ${entry.key + 1}", null),
              );
            }),
          ],
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => setState(() => controllers.addDistractor()),
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text("Add Choice"),
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerWrapper(BuildContext context, String? imagePath, Function(String) onSelected) {
    final theme = Theme.of(context);
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: ImagePickerWidget(
        imagePath: imagePath,
        size: 80,
        onImageSelected: onSelected,
      ),
    );
  }

  Widget _buildStyledField(BuildContext context, TextEditingController controller, String hint, IconData? icon) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
        prefixIcon: icon != null ? Icon(icon, size: 20, color: theme.colorScheme.primary) : null,
        filled: true,
        fillColor: theme.colorScheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }

  Widget _buildAddCardButton(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: _addCard,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.primary, width: 1.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Text(
              "Add New Card",
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveDeck,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
              ),
              child: const Text(
                "Save Deck",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (var c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }
}