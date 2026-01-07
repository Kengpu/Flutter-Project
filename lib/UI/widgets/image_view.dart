import 'dart:convert';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 1. Unified Placeholder Builder
    Widget buildPlaceholder({IconData icon = Icons.image_outlined}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          // Uses surface variant to distinguish from main background
          color: theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.5),
        ),
        child: Center(
          child: Icon(
            icon,
            // Adapts color to Primary (Navy/Cyan) or Muted OnSurface
            color: theme.colorScheme.onSurface.withOpacity(0.3),
            size: width != null ? width! * 0.4 : 24,
          ),
        ),
      );
    }

    // 2. Null/Empty Check
    if (imageSource == null || imageSource!.isEmpty) {
      return buildPlaceholder();
    }

    // 3. Base64 Check
    if (!imageSource!.startsWith('http')) {
      try {
        return Image.memory(
          base64Decode(imageSource!),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
              buildPlaceholder(icon: Icons.broken_image_outlined),
        );
      } catch (e) {
        debugPrint("Base64 decode failed: $e");
        return buildPlaceholder(icon: Icons.error_outline_rounded);
      }
    }

    // 4. Network Image
    return Image.network(
      imageSource!,
      width: width,
      height: height,
      fit: fit,
      // Loading builder adds a nice themed shimmer-like effect
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return buildPlaceholder(icon: Icons.downloading_rounded);
      },
      errorBuilder: (context, error, stackTrace) =>
          buildPlaceholder(icon: Icons.broken_image_outlined),
    );
  }
}