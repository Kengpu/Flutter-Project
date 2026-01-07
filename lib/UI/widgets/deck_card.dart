import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants/app_colors.dart'; 
import 'package:flutterapp/domain/models/deck.dart';

class DeckCard extends StatelessWidget {
  final Deck deck;
  final VoidCallback onTap;
  final Function(String) onActionSelected; // Passes 'edit' or 'delete' back

  const DeckCard({
    super.key,
    required this.deck,
    required this.onTap,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    bool hasImage = deck.coverImage != null && deck.coverImage!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: !hasImage
              ? const LinearGradient(
                  colors: [AppColors.navyLight, AppColors.primaryNavy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryNavy.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Stack(
          children: [
            // --- Background Image Overlay ---
            if (hasImage)
              Positioned.fill(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.35),
                    BlendMode.darken,
                  ),
                  child: Image.memory(
                    base64Decode(deck.coverImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // --- Text Content ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hasImage)
                    const Icon(
                      Icons.folder_copy_rounded, 
                      color: AppColors.textSecondary, 
                      size: 30
                    ),
                  const Spacer(),
                  Text(
                    deck.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary, // White
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 8)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${deck.flashcards.length} Cards",
                    style: const TextStyle(
                      color: AppColors.textPrimary, // White
                      fontSize: 12,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                    ),
                  ),
                ],
              ),
            ),

            // --- Menu Button ---
            Positioned(
              top: 2,
              right: 2,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                onSelected: onActionSelected,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18, color: AppColors.primaryNavy),
                        SizedBox(width: 8),
                        Text("Edit Deck"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text("Delete", style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}