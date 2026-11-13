import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Service responsible for picking recipe photos (Gallery / Camera)
/// and uploading them to Firebase Storage with local/offline fallback.
class RecipeImageService {
  final ImagePicker _picker;
  final FirebaseStorage? _injectedStorage;
  final FirebaseAuth? _injectedAuth;

  RecipeImageService({
    ImagePicker? picker,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  })  : _picker = picker ?? ImagePicker(),
        _injectedStorage = storage,
        _injectedAuth = auth;

  FirebaseStorage? get _storage {
    if (_injectedStorage != null) return _injectedStorage;
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseStorage.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseAuth? get _auth {
    if (_injectedAuth != null) return _injectedAuth;
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  /// Picks an image from [source] (Gallery or Camera) and uploads/persists it,
  /// returning a usable `imageUrl` (cloud URL, local path, or data URI), or `null` if cancelled.
  Future<String?> pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );
      if (picked == null) return null;
      return await uploadXFile(picked);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('RecipeImageService.pickAndUploadImage error: $e');
      }
      return null;
    }
  }

  /// Uploads an [XFile] to Firebase Storage when authenticated, falling back
  /// to local app document storage or Base64 data URI when offline.
  Future<String> uploadXFile(XFile file) async {
    Uint8List? bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {}

    final storage = _storage;
    final user = _auth?.currentUser;
    if (storage != null && user != null && bytes != null && bytes.isNotEmpty) {
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final ref = storage.ref().child('users/${user.uid}/recipes/img_$timestamp.jpg');
        final metadata = SettableMetadata(contentType: 'image/jpeg');
        await ref.putData(bytes, metadata).timeout(const Duration(seconds: 4));
        final downloadUrl = await ref.getDownloadURL().timeout(const Duration(seconds: 3));
        if (downloadUrl.isNotEmpty) {
          return downloadUrl;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Firebase Storage upload fallback: $e');
        }
      }
    }

    // Try saving to persistent local application documents directory
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

    if (bytes != null && bytes.isNotEmpty) {
      return 'data:image/jpeg;base64,${base64Encode(bytes)}';
    }

    return file.path;
  }
}

