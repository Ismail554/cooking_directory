import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/asset_manager.dart';

/// Universal recipe image renderer supporting asset paths, network URLs,
/// Base64 data URIs (`data:image/...`), and local device file paths.
class RecipeImageView extends StatelessWidget {
  final String imageSource;
  final String fallbackAsset;
  final double? width;
  final double? height;
  final BoxFit fit;

  const RecipeImageView({
    super.key,
    required this.imageSource,
    this.fallbackAsset = AssetManager.recipePlaceholder,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  Widget _buildIconFallback() {
    return Container(
      width: width,
      height: height,
      color: AppColors.primaryContainer,
      child: const Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 36,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildAssetFallback() {
    return Image.asset(
      fallbackAsset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => _buildIconFallback(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = imageSource.trim();
    if (trimmed.isEmpty || trimmed == fallbackAsset) {
      return _buildAssetFallback();
    }

    if (trimmed.startsWith('assets/')) {
      return Image.asset(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _buildAssetFallback(),
      );
    }

    if (trimmed.startsWith('data:image/')) {
      try {
        final commaIdx = trimmed.indexOf(',');
        if (commaIdx != -1) {
          final bytes = base64Decode(trimmed.substring(commaIdx + 1));
          return Image.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => _buildAssetFallback(),
          );
        }
      } catch (_) {}
      return _buildAssetFallback();
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _buildAssetFallback(),
      );
    }

    final filePath = trimmed.startsWith('file://')
        ? Uri.parse(trimmed).toFilePath()
        : trimmed;
    return Image.file(
      File(filePath),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => _buildAssetFallback(),
    );
  }
}

