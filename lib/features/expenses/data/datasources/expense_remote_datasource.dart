import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> fetchRemoteExpenses();
  Future<void> saveRemoteExpense(ExpenseModel expense);
  Future<void> saveRemoteExpenses(List<ExpenseModel> expenses);
  Future<void> deleteRemoteExpense(String id);
  Stream<List<ExpenseModel>> watchRemoteExpenses();
}

/// Dual-engine Remote DataSource synchronizing user expenses with both
/// Firebase Realtime Database (`users/{uid}/expenses`) and Cloud Firestore.
class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseFirestore? _injectedFirestore;
  final FirebaseDatabase? _injectedDatabase;
  final FirebaseAuth? _injectedAuth;

  ExpenseRemoteDataSourceImpl({
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
    return fs.collection('users').doc(uid).collection('expenses');
  }

  DatabaseReference? _getRtdbRef() {
    final uid = _uid;
    final db = _database;
    if (uid == null || db == null) return null;
    return db.ref('users/$uid/expenses');
  }

  List<ExpenseModel> _parseRtdbValue(Object? raw) {
    if (raw is! Map) return [];
    final List<ExpenseModel> items = [];
    for (final entry in raw.entries) {
      if (entry.value is Map) {
        try {
          final map = Map<String, dynamic>.from(entry.value as Map);
          items.add(ExpenseModel.fromJson(map));
        } catch (_) {}
      }
    }
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<List<ExpenseModel>> fetchRemoteExpenses() async {
    final Map<String, ExpenseModel> merged = {};
    try {
      final rtdbRef = _getRtdbRef();
      if (rtdbRef != null) {
        final snap = await rtdbRef.get().timeout(const Duration(seconds: 3));
        for (final m in _parseRtdbValue(snap.value)) {
          merged[m.id] = m;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('RTDB fetchRemoteExpenses note: $e');
    }

    try {
      final col = _getFirestoreCol();
      if (col != null) {
        final snapshot = await col
            .orderBy('createdAt', descending: true)
            .get()
            .timeout(const Duration(seconds: 3));
        for (final doc in snapshot.docs) {
          final m = ExpenseModel.fromJson(doc.data());
          merged[m.id] = m;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Firestore fetchRemoteExpenses note: $e');
    }

    final list = merged.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
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
  Future<void> saveRemoteExpense(ExpenseModel expense) async {
    final json = expense.toJson();
    await Future.wait([_saveRtdb(expense.id, json), _saveFs(expense.id, json)]);
  }

  @override
  Future<void> saveRemoteExpenses(List<ExpenseModel> expenses) async {
    for (final exp in expenses) {
      await saveRemoteExpense(exp);
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
  Future<void> deleteRemoteExpense(String id) async {
    await Future.wait([_delRtdb(id), _delFs(id)]);
  }

  @override
  Stream<List<ExpenseModel>> watchRemoteExpenses() {
    try {
      final rtdbRef = _getRtdbRef();
      if (rtdbRef != null) {
        return rtdbRef.onValue.map((event) => _parseRtdbValue(event.snapshot.value));
      }
      final col = _getFirestoreCol();
      if (col != null) {
        return col.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => ExpenseModel.fromJson(d.data())).toList(),
        );
      }
    } catch (_) {}
    return const Stream<List<ExpenseModel>>.empty();
  }
}
