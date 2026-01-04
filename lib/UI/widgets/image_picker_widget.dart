import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        Uint8List imageBytes = await image.readAsBytes();
        String base64String = base64Encode(imageBytes);
        onImageSelected(base64String);
      } else {
      onImageSelected(image.path);
      }
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
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ImageView(
                  imageSource: imagePath,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(
                Icons.image_outlined,
                color: Colors.white,
                size: 32,
              ),
      ),
    );
  }
}