import 'package:flutter/material.dart';
import 'package:flutterapp/UI/widgets/image_picker_widget.dart';
import 'package:flutterapp/domain/models/flashcard.dart';
import 'package:flutterapp/UI/widgets/image_picker_widget.dart';

class CardEditorItem extends StatelessWidget {
  final Flashcard card;
  final int index;
  final VoidCallback onAddMultipleChoice;
  final VoidCallback onDelete;
  final Function(String) onFrontChanged;
  final Function(String) onBackChanged;
  // Callback for when the card's specific image changes
  final Function(String) onImageChanged;
  // Callback for when a distractor text is updated
  final Function(int, String) onDistractorChanged;

  const CardEditorItem({
    super.key,
    required this.card,
    required this.index,
    required this.onAddMultipleChoice,
    required this.onDelete,
    required this.onFrontChanged,
    required this.onBackChanged,
    required this.onImageChanged,
    required this.onDistractorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6), 
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildField("Term", card.frontText, onFrontChanged),
                    const SizedBox(height: 10),
                    _buildField("Definition", card.backText, onBackChanged),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ImagePickerWidget(
                imagePath: card.image,
                size: 70,
                onImageSelected: onImageChanged,
              ),
            ],
          ),
          
          // --- DISTRACTORS SECTION ---
          if (card.distractors != null && card.distractors!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Column(
                children: card.distractors!.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildField(
                      "Option ${entry.key + 1}", 
                      entry.value, 
                      (val) => onDistractorChanged(entry.key, val)
                    ),
                  );
                }).toList(),
              ),
            ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: onAddMultipleChoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD9FF50), // Lime green
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Add multiple choice"),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.white70),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(String hint, String initialValue, Function(String) onChanged) {
     return TextFormField(
       initialValue: initialValue,
       onChanged: onChanged,
       style: const TextStyle(fontSize: 14),
       decoration: InputDecoration(
         hintText: hint,
         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
         filled: true,
         fillColor: Colors.white,
         border: OutlineInputBorder(
           borderRadius: BorderRadius.circular(8),
           borderSide: BorderSide.none,
         ),
       ),
     );
  }
}