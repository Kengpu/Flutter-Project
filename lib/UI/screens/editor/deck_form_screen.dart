import 'package:flutter/material.dart';
import 'package:flutterapp/domain/models/deck.dart';
import 'package:flutterapp/domain/models/flashcard.dart';
import 'package:flutterapp/data/repositories/deck_repository_impl.dart';
import 'package:flutterapp/data/datascource/local_database.dart';
import 'package:flutterapp/UI/widgets/image_picker_widget.dart';

class CardControllers {
  final TextEditingController termController;
  final TextEditingController definitionController;
  List<TextEditingController> distractorControllers;
  String? imageBase64;

  CardControllers({String term = "", String definition = "", List<String>? distractors, this.imageBase64})
      : termController = TextEditingController(text: term),
        definitionController = TextEditingController(text: definition),
        distractorControllers = (distractors ?? []).map((d) => TextEditingController(text: d)).toList();

  void addDistractor(){
    distractorControllers.add(TextEditingController());
  }

  void dispose() {
    termController.dispose();
    definitionController.dispose();
    for (var c in distractorControllers) {c.dispose();}
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
      
      _cardControllers = widget.deckToEdit!.flashcards.map((card) => 
        CardControllers(
          term: card.frontText, 
          definition: card.backText, 
          imageBase64: card.image,
          distractors: card.distractors,
        )
      ).toList();
    } else {
      _cardControllers.add(CardControllers());
    }
  }

  void _addCard() {
    setState(() => _cardControllers.add(CardControllers()));
  }

  void _saveDeck() async {
    List<Flashcard> finalCards = _cardControllers.map((c) => Flashcard(
      frontText: c.termController.text,
      backText: c.definitionController.text,
      image: c.imageBase64,
      distractors: c.distractorControllers
      .map((dc) => dc.text)
      .where((text) => text.isNotEmpty).toList(),
    )).toList();

    final updatedDeck = Deck(
      id: widget.deckToEdit?.id, 
      title: _titleController.text,
      description: _descController.text,
      coverImage: _deckImageBase64,
      flashcards: finalCards,
    );

    if (widget.deckToEdit == null) {
      await _deckRepo.addDeck(updatedDeck);
    } else {
      await _deckRepo.updateDeck(updatedDeck);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00E5FF),
      appBar: AppBar(
        title: Text(widget.deckToEdit == null ? "Create Deck" : "Edit Deck"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildDeckHeader(),
            const SizedBox(height: 20),
            
            ..._cardControllers.asMap().entries.map((entry) => 
              _buildCardEditor(entry.value, entry.key)
            ),
            
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addCard,
              child: const Text("Add Card"),
            ),
            const SizedBox(height: 40),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Discard"),
                ),
                ElevatedButton(
                  onPressed: _saveDeck,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Save"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDeckHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Deck Title")),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: "Description")),
          const SizedBox(height: 10),
          ImagePickerWidget(
            imagePath: _deckImageBase64,
            onImageSelected: (base64) => setState(() => _deckImageBase64 = base64),
          ),
        ],
      ),
    );
  }

Widget _buildCardEditor(CardControllers controllers, int index) {
  return Container(
    margin: const EdgeInsets.only(top: 15),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(12)),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  TextField(controller: controllers.termController, decoration: const InputDecoration(labelText: "Term")),
                  TextField(controller: controllers.definitionController, decoration: const InputDecoration(labelText: "Definition")),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ImagePickerWidget(
              imagePath: controllers.imageBase64,
              onImageSelected: (base) => setState(() => controllers.imageBase64 = base),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        ...controllers.distractorControllers.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextField(
              controller: entry.value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: "Distractor ${entry.key + 1}",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
              ),
            ),
          );
        }),
        TextButton.icon(
          onPressed: () => setState(() => controllers.addDistractor()),
          icon: const Icon(Icons.add, color: Colors.yellow, size: 18),
          label: const Text("Add multiple choice", style: TextStyle(color: Colors.yellow)),
        ),
      ],
    ),
  );
}
  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (var c in _cardControllers) { c.dispose(); }
    super.dispose();
  }
}