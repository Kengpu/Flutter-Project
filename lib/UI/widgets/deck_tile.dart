import 'package:flutter/material.dart';
import 'package:flutterapp/UI/widgets/image_view.dart';
import 'package:flutterapp/core/constants/app_colors.dart';
import 'package:flutterapp/domain/models/deck.dart';

class DeckTile extends StatelessWidget {
  final Deck deck;
  final VoidCallback onTap;
  final Function(String) onActionSelected;

  const DeckTile({
    super.key,
    required this.deck,
    required this.onTap,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.starGold, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: onTap,
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ImageView(imageSource: deck.coverImage, fit: BoxFit.cover,),
          )
        ),
        title: Text(
          deck.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          "${deck.flashcards.length} cards\n${deck.description}",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: onActionSelected,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Edit")],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [Icon(Icons.delete, size: 18, color: AppColors.error), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}