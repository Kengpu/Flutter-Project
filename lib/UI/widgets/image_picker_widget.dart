import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutterapp/core/constants/app_colors.dart'; 
import 'package:flutterapp/UI/widgets/image_view.dart';

class ImagePickerWidget extends StatelessWidget {
  final String? imagePath;
  final double size;
  final Function(String) onImageSelected;

  const ImagePickerWidget({
    super.key,
    this.imagePath,
    this.size = 80,
    required this.onImageSelected,
  });

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      imageQuality: 75,
    );

    if (image != null) {
      Uint8List imageBytes = await image.readAsBytes();
      String base64String = base64Encode(imageBytes);
      onImageSelected(base64String);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Initialize Theme
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          // 2. Dynamic Background: Light Navy for light theme, Surface color for dark
          color: isDark 
              ? theme.colorScheme.surfaceVariant.withOpacity(0.5) 
              : AppColors.primaryNavy.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // 3. Dynamic Border: Use primary color (Navy/Cyan) at low opacity
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ImageView(imageSource: imagePath, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    // 4. Icon color follows Primary (Navy or Cyan)
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Add",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}