import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants/app_colors.dart';

class ImageView extends StatelessWidget {
  final String? imageSource;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ImageView({
    super.key,
    required this.imageSource,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageSource == null || imageSource!.isEmpty) {
      return const Icon(Icons.image, color:AppColors.surfaceLight);
    }

    if (kIsWeb || !imageSource!.contains('/')) {
      try {
        return Image.memory(
          base64Decode(imageSource!),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
        );
      } catch (e) {
        return const Icon(Icons.broken_image, color: AppColors.error);
      }
    }

    return Image.file(
      File(imageSource!),
      width: width,
      height: height,
      fit: fit,
    );
  }
}