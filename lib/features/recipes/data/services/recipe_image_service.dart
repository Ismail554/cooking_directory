import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Service responsible for picking recipe photos (Gallery / Camera)
/// and persisting them locally on the device (never uploaded to Firebase).
class RecipeImageService {
  final ImagePicker _picker;

  RecipeImageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Picks an image from [source] (Gallery or Camera) and saves it locally
  /// on the device, returning the local file path or `null` if cancelled.
  Future<String?> pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );
      if (picked == null) return null;
      return await saveLocally(picked);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RecipeImageService.pickAndUploadImage error: $e');
      }
      return null;
    }
  }

  /// Copies the picked [XFile] into the app's persistent `recipe_images`
  /// directory on the device so it survives restarts without cloud storage.
  Future<String> saveLocally(XFile file) async {
    if (!kIsWeb && file.path.isNotEmpty) {
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        final recipesDir = Directory('${docsDir.path}/recipe_images');
        if (!recipesDir.existsSync()) {
          recipesDir.createSync(recursive: true);
        }
        final ext = file.path.contains('.') ? file.path.split('.').last : 'jpg';
        final targetPath =
            '${recipesDir.path}/recipe_${DateTime.now().millisecondsSinceEpoch}.$ext';
        final copied = await File(file.path).copy(targetPath);
        return copied.path;
      } catch (_) {
        return file.path;
      }
    }
    return file.path;
  }
}
