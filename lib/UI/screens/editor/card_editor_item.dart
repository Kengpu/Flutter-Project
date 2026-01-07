import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants/app_colors.dart';
import 'package:flutterapp/domain/models/flashcard.dart';
import 'package:flutterapp/UI/widgets/image_picker_widget.dart';

class CardEditorItem extends StatelessWidget {
  final Flashcard card;
  final int index;
  final VoidCallback onAddMultipleChoice;
  final VoidCallback onDelete;
  final Function(String) onFrontChanged;
  final Function(String) onBackChanged;
  final Function(String) onImageChanged;
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Theme-aware surface color
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Card Number and Delete Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "CARD ${index + 1}",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 22),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Term, Definition and Image Picker
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildField(context, "Term", card.frontText, onFrontChanged),
                    const SizedBox(height: 12),
                    _buildField(context, "Definition", card.backText, onBackChanged),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              ImagePickerWidget(
                imagePath: card.image,
                size: 80,
                onImageSelected: onImageChanged,
              ),
            ],
          ),

          // --- MULTIPLE CHOICE SECTION ---
          if (card.distractors != null && card.distractors!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Divider(
                color: theme.colorScheme.onSurface.withOpacity(0.1), 
                thickness: 1
              ),
            ),
            Text(
              "MULTIPLE CHOICE OPTIONS",
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            ...card.distractors!.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildField(
                  context,
                  "Option ${entry.key + 1}",
                  entry.value,
                  (val) => onDistractorChanged(entry.key, val),
                ),
              );
            }).toList(),
          ],

          // Add Multiple Choice Button
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onAddMultipleChoice,
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text("Add Choice"),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(BuildContext context, String hint, String initialValue, Function(String) onChanged) {
    final theme = Theme.of(context);
    
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.4), 
          fontSize: 14
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        filled: true,
        fillColor: theme.colorScheme.background, // Recessed field color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}