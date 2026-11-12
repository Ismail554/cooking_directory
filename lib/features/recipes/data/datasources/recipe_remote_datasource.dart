import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';

abstract class RecipeRemoteDataSource {
  Future<List<RecipeModel>> fetchRemoteRecipes();
  Future<void> saveRemoteRecipe(RecipeModel recipe);
  Future<void> saveRemoteRecipes(List<RecipeModel> recipes);
}

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  RecipeRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? _getUserRecipesCollection() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('recipes');
  }

  @override
  Future<List<RecipeModel>> fetchRemoteRecipes() async {
    try {
      final col = _getUserRecipesCollection();
      if (col == null) return [];
      final snapshot = await col.get();
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
        await col.doc(recipe.id).set(recipe.toJson(), SetOptions(merge: true));
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

