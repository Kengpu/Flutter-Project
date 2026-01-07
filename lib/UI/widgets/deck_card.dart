import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants/app_colors.dart'; 
import 'package:flutterapp/domain/models/deck.dart';

class DeckCard extends StatelessWidget {
  final Deck deck;
  final VoidCallback onTap;
  final Function(String) onActionSelected;

  const DeckCard({
    super.key,
    required this.deck,
    required this.onTap,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Initialize Theme Engine
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    bool hasImage = deck.coverImage != null && deck.coverImage!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          // 2. Dynamic Gradient: Shifts from Navy/Light-Blue to Slate/Cyan
          gradient: !hasImage
              ? LinearGradient(
                  colors: isDark 
                    ? [const Color(0xFF1E293B), theme.colorScheme.primary.withOpacity(0.7)] 
                    : [AppColors.navyLight, theme.colorScheme.primary], 
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(isDark ? 0.3 : 0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
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
                    // 3. Image Contrast: Darker in dark mode to make white text pop
                    Colors.black.withOpacity(isDark ? 0.55 : 0.35), 
                    BlendMode.darken,
                  ),
                  child: Image.memory(
                    base64Decode(deck.coverImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Tag
            Positioned(
              top: 12,
              left: 12,
              child: _buildStatusTag(context, deck.deckStatus),
            ),

            // --- Text Content ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    deck.title,
                    style: const TextStyle(
                      color: Colors.white, // Locked to white for readability on image/gradient
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      letterSpacing: -0.2,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${deck.flashcards.length} Cards",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      shadows: const [Shadow(color: Colors.black38, blurRadius: 4)],
                    ),
                  ),
                ],
              ),
            ),

            // --- Menu Button ---
            Positioned(
              top: 4,
              right: 4,
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded, 
                  color: Colors.white.withOpacity(0.9), // White works best on card backgrounds
                ),
                color: theme.colorScheme.surface, 
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: onActionSelected,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text("Edit Deck", style: TextStyle(color: theme.colorScheme.onSurface)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                        const SizedBox(width: 12),
                        const Text("Delete", style: TextStyle(color: AppColors.error)),
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

  Widget _buildStatusTag(BuildContext context, DeckStatus status) {
    if(status == DeckStatus.newDeck) return const SizedBox.shrink();
    
    Color color;
    String text;

    switch (status) {
      case DeckStatus.struggling: color = AppColors.error; text = "Struggling"; break;
      case DeckStatus.uncertain: color = Colors.orange; text = "Uncertain"; break;
      case DeckStatus.confident: color = const Color(0xFF00B4D8); text = "Confident"; break;
      case DeckStatus.mastered: color = AppColors.success; text = "Mastered"; break;
      default: color = Colors.grey; text = "New"; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9), // Slight transparency for glass effect
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white, 
          fontSize: 8, 
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}