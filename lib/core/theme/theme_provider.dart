import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// Centralized provider for app theme mode (Light / Dark / System)
/// and shared culinary preferences with Realtime DB + Firestore sync.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode;
  List<String> _dietaryPreferences;
  String _currency;
  double _monthlyBudget;
  bool _realtimeSyncEnabled = true;
  StreamSubscription<DatabaseEvent>? _rtdbSub;

  ThemeProvider({
    ThemeMode initialThemeMode = ThemeMode.system,
    List<String>? initialDietaryPreferences,
    String initialCurrency = 'USD (\$)',
    double initialMonthlyBudget = 1200.0,
  })  : _themeMode = initialThemeMode,
        _dietaryPreferences = initialDietaryPreferences ?? ['Halal', 'Gluten-Free'],
        _currency = initialCurrency,
        _monthlyBudget = initialMonthlyBudget {
    loadPreferences();
  }

  ThemeMode get themeMode => _themeMode;
  List<String> get dietaryPreferences => List.unmodifiable(_dietaryPreferences);
  String get currency => _currency;
  double get monthlyBudget => _monthlyBudget;
  bool get isRealtimeSyncEnabled => _realtimeSyncEnabled;

  String get currencySymbol {
    final match = RegExp(r'\((.+?)\)').firstMatch(_currency);
    return (match != null && match.group(1) != null) ? match.group(1)! : '\$';
  }

  String? get _uid {
    if (Firebase.apps.isEmpty) return null;
    try { return FirebaseAuth.instance.currentUser?.uid; } catch (_) { return null; }
  }

  DocumentReference<Map<String, dynamic>>? _getPrefsDoc() {
    final uid = _uid;
    if (uid == null) return null;
    try {
      return FirebaseFirestore.instance.collection('users').doc(uid).collection('settings').doc('preferences');
    } catch (_) {
      return null;
    }
  }

  DatabaseReference? _getRtdbRef() {
    final uid = _uid;
    if (uid == null) return null;
    try { return FirebaseDatabase.instance.ref('users/$uid/preferences'); } catch (_) { return null; }
  }

  void _applyMap(Map<dynamic, dynamic> data) {
    final modeStr = data['themeMode'] as String?;
    if (modeStr == 'dark') _themeMode = ThemeMode.dark;
    if (modeStr == 'light') _themeMode = ThemeMode.light;
    if (data['dietaryPreferences'] is List) {
      _dietaryPreferences = (data['dietaryPreferences'] as List).map((e) => e.toString()).toList();
    }
    if (data['currency'] is String) _currency = data['currency'] as String;
    if (data['monthlyBudget'] is num) _monthlyBudget = (data['monthlyBudget'] as num).toDouble();
    if (data['realtimeSyncEnabled'] is bool) _realtimeSyncEnabled = data['realtimeSyncEnabled'] as bool;
    notifyListeners();
  }

  void setRealtimeSyncEnabled(bool enabled) {
    _realtimeSyncEnabled = enabled;
    enabled ? startRealtimeSync() : stopRealtimeSync();
    notifyListeners();
    _saveRemotePreferences();
  }

  void startRealtimeSync() {
    stopRealtimeSync();
    if (!_realtimeSyncEnabled) return;
    try {
      _rtdbSub = _getRtdbRef()?.onValue.listen((event) {
        if (event.snapshot.value is Map) _applyMap(event.snapshot.value as Map);
      }, onError: (_) {});
    } catch (_) {}
  }

  void stopRealtimeSync() {
    _rtdbSub?.cancel();
    _rtdbSub = null;
  }

  Future<void> loadPreferences() async {
    try {
      final rtdbRef = _getRtdbRef();
      if (rtdbRef != null) {
        final snap = await rtdbRef.get().timeout(const Duration(seconds: 3));
        if (snap.value is Map) {
          _applyMap(snap.value as Map);
          if (_realtimeSyncEnabled) startRealtimeSync();
          return;
        }
      }
    } catch (_) {}

    try {
      final docRef = _getPrefsDoc();
      if (docRef == null) return;
      final snap = await docRef.get().timeout(const Duration(seconds: 3));
      if (snap.data() != null) _applyMap(snap.data()!);
      if (_realtimeSyncEnabled) startRealtimeSync();
    } catch (_) {}
  }

  Future<void> savePreferencesToCloud() => _saveRemotePreferences();

  Future<void> _saveRtdbPrefs(Map<String, dynamic> payload) async {
    try {
      final ref = _getRtdbRef();
      if (ref != null) await ref.update(payload).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  Future<void> _saveFsPrefs(Map<String, dynamic> payload) async {
    try {
      final doc = _getPrefsDoc();
      if (doc != null) await doc.set(payload, SetOptions(merge: true)).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  Future<void> _saveRemotePreferences() async {
    final payload = <String, dynamic>{
      'themeMode': _themeMode == ThemeMode.dark ? 'dark' : (_themeMode == ThemeMode.light ? 'light' : 'system'),
      'dietaryPreferences': _dietaryPreferences,
      'currency': _currency,
      'monthlyBudget': _monthlyBudget,
      'realtimeSyncEnabled': _realtimeSyncEnabled,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await Future.wait([_saveRtdbPrefs(payload), _saveFsPrefs(payload)]);
  }

  bool isDarkActive(BuildContext context) {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return Theme.of(context).brightness == Brightness.dark;
  }

  Future<void> toggleDarkMode(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    if (_realtimeSyncEnabled) await _saveRemotePreferences();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    if (_realtimeSyncEnabled) await _saveRemotePreferences();
  }

  Future<void> setDietaryPreferences(List<String> preferences) async {
    _dietaryPreferences = List<String>.from(preferences);
    notifyListeners();
    if (_realtimeSyncEnabled) await _saveRemotePreferences();
  }

  Future<void> setCurrencyAndBudget(String currency, double budget) async {
    _currency = currency;
    _monthlyBudget = budget > 0 ? budget : _monthlyBudget;
    notifyListeners();
    if (_realtimeSyncEnabled) await _saveRemotePreferences();
  }

  @override
  void dispose() {
    stopRealtimeSync();
    super.dispose();
  }
}
