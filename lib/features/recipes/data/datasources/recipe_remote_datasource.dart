import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';

abstract class RecipeRemoteDataSource {
  Future<List<RecipeModel>> fetchRemoteRecipes();
  Future<void> saveRemoteRecipe(RecipeModel recipe);
  Future<void> saveRemoteRecipes(List<RecipeModel> recipes);
}

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final FirebaseFirestore? _injectedFirestore;
  final FirebaseAuth? _injectedAuth;

  RecipeRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _injectedFirestore = firestore,
        _injectedAuth = auth;

  FirebaseFirestore? get _firestore {
    if (_injectedFirestore != null) return _injectedFirestore;
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseFirestore.instance;
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

  CollectionReference<Map<String, dynamic>>? _getUserRecipesCollection() {
    final user = _auth?.currentUser;
    final firestore = _firestore;
    if (user == null || firestore == null) return null;
    return firestore.collection('users').doc(user.uid).collection('recipes');
  }

  @override
  Future<List<RecipeModel>> fetchRemoteRecipes() async {
    try {
      final col = _getUserRecipesCollection();
      if (col == null) return [];
      final snapshot = await col.get().timeout(const Duration(seconds: 3));
      return snapshot.docs
          .map((doc) => RecipeModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firestore fetchRemoteRecipes note: $e');
      }
      return [];
    }
  }

  @override
  Future<void> saveRemoteRecipe(RecipeModel recipe) async {
    try {
      final col = _getUserRecipesCollection();
      if (col != null) {
        await col
            .doc(recipe.id)
            .set(recipe.toJson(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 3));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firestore saveRemoteRecipe note: $e');
      }
    }
  }

  @override
  Future<void> saveRemoteRecipes(List<RecipeModel> recipes) async {
    for (final recipe in recipes) {
      await saveRemoteRecipe(recipe);
    }
  }
}
