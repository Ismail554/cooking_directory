import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';

abstract class RecipeRemoteDataSource {
  Future<List<RecipeModel>> fetchRemoteRecipes();
  Future<void> saveRemoteRecipe(RecipeModel recipe);
  Future<void> saveRemoteRecipes(List<RecipeModel> recipes);
  Future<void> deleteRemoteRecipe(String id);
  Stream<List<RecipeModel>> watchRemoteRecipes();
}

/// Dual-engine Remote DataSource synchronizing user recipes with both
/// Firebase Realtime Database (`users/{uid}/recipes`) and Cloud Firestore.
class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final FirebaseFirestore? _injectedFirestore;
  final FirebaseDatabase? _injectedDatabase;
  final FirebaseAuth? _injectedAuth;

  RecipeRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseDatabase? database,
    FirebaseAuth? auth,
  })  : _injectedFirestore = firestore,
        _injectedDatabase = database,
        _injectedAuth = auth;

  FirebaseFirestore? get _firestore {
    if (_injectedFirestore != null) return _injectedFirestore;
    if (Firebase.apps.isEmpty) return null;
    try { return FirebaseFirestore.instance; } catch (_) { return null; }
  }

  FirebaseDatabase? get _database {
    if (_injectedDatabase != null) return _injectedDatabase;
    if (Firebase.apps.isEmpty) return null;
    try { return FirebaseDatabase.instance; } catch (_) { return null; }
  }

  FirebaseAuth? get _auth {
    if (_injectedAuth != null) return _injectedAuth;
    if (Firebase.apps.isEmpty) return null;
    try { return FirebaseAuth.instance; } catch (_) { return null; }
  }

  String? get _uid => _auth?.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? _getFirestoreCol() {
    final uid = _uid;
    final fs = _firestore;
    if (uid == null || fs == null) return null;
    return fs.collection('users').doc(uid).collection('recipes');
  }

  DatabaseReference? _getRtdbRef() {
    final uid = _uid;
    final db = _database;
    if (uid == null || db == null) return null;
    return db.ref('users/$uid/recipes');
  }

  List<RecipeModel> _parseRtdbValue(Object? raw) {
    if (raw is! Map) return [];
    final List<RecipeModel> items = [];
    for (final entry in raw.entries) {
      if (entry.value is Map) {
        try {
          final map = Map<String, dynamic>.from(entry.value as Map);
          items.add(RecipeModel.fromJson(map));
        } catch (_) {}
      }
    }
    return items;
  }

  @override
  Future<List<RecipeModel>> fetchRemoteRecipes() async {
    final Map<String, RecipeModel> merged = {};
    try {
      final rtdbRef = _getRtdbRef();
      if (rtdbRef != null) {
        final snap = await rtdbRef.get().timeout(const Duration(seconds: 3));
        for (final m in _parseRtdbValue(snap.value)) {
          merged[m.id] = m;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('RTDB fetchRemoteRecipes note: $e');
    }

    try {
      final col = _getFirestoreCol();
      if (col != null) {
        final snapshot = await col.get().timeout(const Duration(seconds: 3));
        for (final doc in snapshot.docs) {
          final m = RecipeModel.fromJson(doc.data());
          merged[m.id] = m;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Firestore fetchRemoteRecipes note: $e');
    }

    return merged.values.toList();
  }

  Future<void> _saveRtdb(String id, Map<String, dynamic> json) async {
    try {
      final rtdbRef = _getRtdbRef();
      if (rtdbRef != null) {
        await rtdbRef.child(id).set(json).timeout(const Duration(seconds: 3));
      }
    } catch (_) {}
  }

  Future<void> _saveFs(String id, Map<String, dynamic> json) async {
    try {
      final col = _getFirestoreCol();
      if (col != null) {
        await col.doc(id).set(json, SetOptions(merge: true)).timeout(const Duration(seconds: 3));
      }
    } catch (_) {}
  }

  @override
  Future<void> saveRemoteRecipe(RecipeModel recipe) async {
    final json = recipe.toJson();
    await Future.wait([_saveRtdb(recipe.id, json), _saveFs(recipe.id, json)]);
  }

  @override
  Future<void> saveRemoteRecipes(List<RecipeModel> recipes) async {
    for (final recipe in recipes) {
      await saveRemoteRecipe(recipe);
    }
  }

  Future<void> _delRtdb(String id) async {
    try {
      final ref = _getRtdbRef();
      if (ref != null) await ref.child(id).remove().timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  Future<void> _delFs(String id) async {
    try {
      final col = _getFirestoreCol();
      if (col != null) await col.doc(id).delete().timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  @override
  Future<void> deleteRemoteRecipe(String id) async {
    await Future.wait([_delRtdb(id), _delFs(id)]);
  }

  @override
  Stream<List<RecipeModel>> watchRemoteRecipes() {
    try {
      final rtdbRef = _getRtdbRef();
      if (rtdbRef != null) {
        return rtdbRef.onValue.map((event) => _parseRtdbValue(event.snapshot.value));
      }
      final col = _getFirestoreCol();
      if (col != null) {
        return col.snapshots().map(
          (snap) => snap.docs.map((d) => RecipeModel.fromJson(d.data())).toList(),
        );
      }
    } catch (_) {}
    return const Stream<List<RecipeModel>>.empty();
  }
}
