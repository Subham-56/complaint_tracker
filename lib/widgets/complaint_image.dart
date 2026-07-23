import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ComplaintImage extends StatelessWidget {
  const ComplaintImage({
    super.key,
    required this.imageUrl,
    required this.height,
    this.width,
  });

  final String imageUrl;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        height: height,
        width: width ?? double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: height,
            width: width,
            color: AppTheme.surfaceLight,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primary,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) {
          return Container(
            height: height,
            width: width,
            color: AppTheme.surfaceLight,
            child: const Center(
              child: Icon(
                Icons.broken_image_rounded,
                color: AppTheme.textSecondary,
                size: 32,
              ),
            ),
          );
        },
      ),
    );
  }
}
