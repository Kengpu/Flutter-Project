import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutterapp/core/constants/app_colors.dart'; // Import your colors
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
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          // Uses a light navy tint for the empty state background
          color: AppColors.primaryNavy.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryNavy.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ImageView(imageSource: imagePath, fit: BoxFit.cover),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppColors.primaryNavy,
                    size: 28,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Add",
                    style: TextStyle(
                      color: AppColors.primaryNavy,
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
