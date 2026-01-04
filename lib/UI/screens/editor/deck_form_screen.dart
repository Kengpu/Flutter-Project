import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterapp/UI/screens/editor/card_editor_item.dart';
import 'package:flutterapp/UI/widgets/image_picker_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutterapp/UI/providers/deck_provider.dart';
import 'package:flutterapp/core/constants/app_colors.dart';
import 'package:flutterapp/domain/models/deck.dart';
import 'package:flutterapp/domain/models/flashcard.dart';

class DeckFormScreen extends StatefulWidget {
  final Deck? existingDeck;

  const DeckFormScreen({super.key, this.existingDeck});

  @override
  State<DeckFormScreen> createState() => _DeckFormScreenState();
}

class _DeckFormScreenState extends State<DeckFormScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String? _coverImage;

  List<Flashcard> _cardsBuffer = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingDeck?.title ?? "");
    _descController = TextEditingController(text: widget.existingDeck?.description ?? "");
    _coverImage = widget.existingDeck?.coverImage;
    
    _cardsBuffer = widget.existingDeck != null 
        ? List.from(widget.existingDeck!.flashcards) 
        : [Flashcard(frontText: "", backText: "")];
  }

  void _addNewCard() {
    setState(() {
      _cardsBuffer.add(Flashcard(frontText: "", backText: ""));
    });
  }

void _onSave() async {
  final provider = context.read<DeckProvider>();
  
  // Validation: Ensure title is not empty
  if (_titleController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter a title")),
    );
    return;
  }

  if (widget.existingDeck == null) {
    await provider.createDeck(
      title: _titleController.text,
      description: _descController.text,
      coverImage: _coverImage,
      cards: _cardsBuffer,
    );
  } else {
    await provider.updateDeck(
      id: widget.existingDeck!.id,
      newTitle: _titleController.text,
      newDescription: _descController.text,
      newCoverImage: _coverImage,
      updateCards: _cardsBuffer,
    );
  }

  Navigator.pop(context);
}

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.existingDeck != null;

    return Scaffold(
      backgroundColor: AppColors.primaryCyan,
      appBar: AppBar(
        title: Text(isEditing ? "Edit Deck" : "Create Deck"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context), 
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDeckField("Deck Title", _titleController),
                const SizedBox(height: 12),
                _buildDeckField("Description", _descController),                
                const SizedBox(height: 20),
                Center(
                  child: ImagePickerWidget(
                    imagePath: _coverImage,
                    size: 100,
                    onImageSelected: (path) => setState(() => _coverImage = path,),
                  ),
                ),
                const SizedBox(height: 30),
                
                  ..._cardsBuffer.asMap().entries.map((entry) {
                    int index = entry.key;
                    Flashcard card = entry.value;
                    return CardEditorItem(
                      key: ValueKey(card.id),
                      index: index,
                      card: card,
                      onFrontChanged: (val) => entry.value.frontText = val,
                      onBackChanged: (val) => entry.value.backText = val,
                      onImageChanged: (path) => setState(() => card.image = path),
                      onDistractorChanged: (dIndex, val) => card.distractors![dIndex] =val,
                      onDelete: () => setState(() => _cardsBuffer.removeAt(entry.key)),
                      onAddMultipleChoice: () {
                        setState(() {
                          entry.value.distractors = entry.value.distractors ?? [];
                          entry.value.distractors!.add("");
                        });
                      },
                    );
                  }).toList(),
                const SizedBox(height: 10,),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _addNewCard,
                    icon: const Icon(Icons.add, color: Colors.white,),
                    label: const Text("Add Card", style: TextStyle(color: AppColors.textPrimary)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 31, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  )
                ),
                const SizedBox(height: 40,),
              ],
            ),
          ),
          
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildDeckField(String hint, TextEditingController controller) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white.withOpacity(0.2),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context), 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Discard"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _onSave, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
              child: const Text("Save"),
            ),
          ),
        ],
      ),
    );
  }
}