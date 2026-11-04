import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/agri_product_model.dart';

/// Renders a product image from Network, Base64 Data URI, or File
/// with [BoxFit.contain] so the full product is displayed without cropping.
class ProductSafeImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final AgriProductCategory category;

  const ProductSafeImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.contain, // Default BoxFit.contain: full image visible without crop
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.category = AgriProductCategory.seeds,
  });

  Color get _categoryColor {
    switch (category) {
      case AgriProductCategory.seeds:
        return const Color(0xFF16A34A);
      case AgriProductCategory.fertilizers:
        return const Color(0xFF0284C7);
      case AgriProductCategory.sprays:
        return const Color(0xFFEA580C);
      case AgriProductCategory.all:
        return AppColors.primaryDark;
    }
  }

  IconData get _categoryIcon {
    switch (category) {
      case AgriProductCategory.seeds:
        return Icons.spa_rounded;
      case AgriProductCategory.fertilizers:
        return Icons.science_rounded;
      case AgriProductCategory.sprays:
        return Icons.sanitizer_rounded;
      case AgriProductCategory.all:
        return Icons.inventory_2_rounded;
    }
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? _categoryColor.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          _categoryIcon,
          color: _categoryColor,
          size: (height != null && height! < 100) ? 26 : 40,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageTrimmed = imageUrl.trim();

    Widget imageWidget;

    if (imageTrimmed.isEmpty) {
      imageWidget = _buildFallbackIcon();
    } else if (imageTrimmed.startsWith('data:image')) {
      // Base64 Data URI from Firebase
      try {
        final commaIdx = imageTrimmed.indexOf(',');
        final base64String = commaIdx != -1 ? imageTrimmed.substring(commaIdx + 1) : imageTrimmed;
        final bytes = base64Decode(base64String);
        imageWidget = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, _, _) => _buildFallbackIcon(),
        );
      } catch (_) {
        imageWidget = _buildFallbackIcon();
      }
    } else if (imageTrimmed.startsWith('http://') || imageTrimmed.startsWith('https://')) {
      // Network image
      imageWidget = Image.network(
        imageTrimmed,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _buildFallbackIcon(),
      );
    } else {
      // Local file path
      try {
        final file = File(imageTrimmed);
        if (file.existsSync()) {
          imageWidget = Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => _buildFallbackIcon(),
          );
        } else {
          imageWidget = _buildFallbackIcon();
        }
      } catch (_) {
        imageWidget = _buildFallbackIcon();
      }
    }

    final container = Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.white,
      alignment: Alignment.center,
      child: imageWidget,
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: container,
      );
    }

    return container;
  }
}
