import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../../features/authentication/domain/entities/auth_user.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/expenses/data/datasources/expense_local_datasource.dart';
import '../../features/expenses/presentation/providers/expense_provider.dart';
import '../../features/recipes/data/datasources/recipe_local_datasource.dart';
import '../../features/recipes/presentation/providers/recipe_provider.dart';
import '../theme/theme_provider.dart';

/// Coordinates Realtime Database + Cloud Firestore account synchronization
/// and exposes user-controlled sync toggles and manual push/pull actions.
class AccountSyncProvider extends ChangeNotifier {
  RecipeProvider? _recipeProvider;
  ExpenseProvider? _expenseProvider;
  ThemeProvider? _themeProvider;

  String? _activeUid;
  String? _activeEmail;
  String? _activeDisplayName;
  bool _realtimeSyncEnabled = true;
  bool _autoSyncOnChange = true;
  bool _isSyncing = false;
  DateTime? _lastSyncedAt;
  String? _syncError;
  bool _lastSyncSucceeded = true;
  String _statusMessage = 'Guest Mode • Local Vault';

  String? get activeUid => _activeUid;
  String? get activeEmail => _activeEmail;
  String? get activeDisplayName => _activeDisplayName;
  bool get isAuthenticated => _activeUid != null && _activeUid!.isNotEmpty;
  bool get isRealtimeSyncEnabled => _realtimeSyncEnabled;
  bool get isAutoSyncOnChange => _autoSyncOnChange;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  String? get syncError => _syncError;
  bool get lastSyncSucceeded => _lastSyncSucceeded;
  String get statusMessage => _statusMessage;

  String get lastSyncedLabel {
    if (_lastSyncedAt == null) return isAuthenticated ? 'Ready to sync' : 'Not signed in';
    final h = _lastSyncedAt!.hour.toString().padLeft(2, '0');
    final m = _lastSyncedAt!.minute.toString().padLeft(2, '0');
    final s = _lastSyncedAt!.second.toString().padLeft(2, '0');
    return 'Synced at $h:$m:$s';
  }

  void bindProviders({
    required AuthProvider auth,
    required RecipeProvider recipes,
    required ExpenseProvider expenses,
    required ThemeProvider theme,
  }) {
    _recipeProvider = recipes;
    _expenseProvider = expenses;
    _themeProvider = theme;

    final user = auth.isAuthenticated ? auth.currentUser : null;
    final newUid = user?.uid;
    if (newUid != _activeUid) {
      _activeUid = newUid;
      _activeEmail = user?.email;
      _activeDisplayName = user?.displayName;
      user != null ? _onAccountSignedIn(user) : _onAccountSignedOut();
    }
  }

  Future<void> _onAccountSignedIn(AuthUser user) async {
    RecipeLocalDataSourceImpl.setActiveUid(user.uid);
    ExpenseLocalDataSourceImpl.setActiveUid(user.uid);
    _syncError = null;
    _statusMessage = _realtimeSyncEnabled ? 'Realtime DB Live Sync Active' : 'Realtime Sync Paused by User';
    notifyListeners();
    await _upsertUserProfile(user);
    await syncAccountNow();
  }

  void _onAccountSignedOut() {
    RecipeLocalDataSourceImpl.setActiveUid(null);
    ExpenseLocalDataSourceImpl.setActiveUid(null);
    _recipeProvider?.stopRealtimeSync();
    _expenseProvider?.stopRealtimeSync();
    _themeProvider?.stopRealtimeSync();
    _recipeProvider?.loadRecipes();
    _expenseProvider?.loadExpenses();
    _lastSyncedAt = null;
    _syncError = null;
    _lastSyncSucceeded = true;
    _statusMessage = 'Guest Mode • Local Vault';
    notifyListeners();
  }

  Future<void> _saveProfileRtdb(String uid, Map<String, dynamic> payload) async {
    try {
      await FirebaseDatabase.instance.ref('users/$uid/profile').update(payload).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  Future<void> _saveProfileFs(String uid, Map<String, dynamic> payload) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(payload, SetOptions(merge: true)).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  Future<void> _upsertUserProfile(AuthUser user) async {
    if (Firebase.apps.isEmpty) return;
    final payload = <String, dynamic>{
      'uid': user.uid,
      'email': user.email ?? '',
      'displayName': user.displayName ?? 'Chef',
      'photoUrl': user.photoUrl ?? '',
      'emailVerified': user.emailVerified,
      'realtimeSyncEnabled': _realtimeSyncEnabled,
      'autoSyncOnChange': _autoSyncOnChange,
      'lastSyncedAt': DateTime.now().toIso8601String(),
    };
    await Future.wait([_saveProfileRtdb(user.uid, payload), _saveProfileFs(user.uid, payload)]);
  }

  Future<void> setRealtimeSyncEnabled(bool enabled) async {
    _realtimeSyncEnabled = enabled;
    _recipeProvider?.setRealtimeSyncEnabled(enabled);
    _expenseProvider?.setRealtimeSyncEnabled(enabled);
    _themeProvider?.setRealtimeSyncEnabled(enabled);
    _statusMessage = enabled ? (isAuthenticated ? 'Realtime DB Live Sync Active' : 'Realtime Sync Ready') : 'Realtime Sync Paused by User';
    notifyListeners();
    if (enabled && isAuthenticated) await syncAccountNow();
  }

  void setAutoSyncOnChange(bool enabled) {
    _autoSyncOnChange = enabled;
    final active = enabled && _realtimeSyncEnabled;
    _recipeProvider?.setRealtimeSyncEnabled(active);
    _expenseProvider?.setRealtimeSyncEnabled(active);
    notifyListeners();
  }

  Future<void> syncAccountNow() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _syncError = null;
    _statusMessage = 'Syncing with Realtime DB...';
    notifyListeners();
    try {
      await Future.wait([
        if (_recipeProvider != null) _recipeProvider!.loadRecipes(),
        if (_expenseProvider != null) _expenseProvider!.loadExpenses(),
        if (_themeProvider != null) _themeProvider!.loadPreferences(),
      ]);
      if (isAuthenticated && _realtimeSyncEnabled) {
        await Future.wait([
          if (_recipeProvider != null) _recipeProvider!.pushLocalToCloud(),
          if (_expenseProvider != null) _expenseProvider!.pushLocalToCloud(),
          if (_themeProvider != null) _themeProvider!.savePreferencesToCloud(),
        ]);
      }
      _lastSyncedAt = DateTime.now();
      _lastSyncSucceeded = true;
      final rCount = _recipeProvider?.allRecipes.length ?? 0;
      final eCount = _expenseProvider?.allExpenses.length ?? 0;
      _statusMessage = _realtimeSyncEnabled
          ? 'Live RTDB • $rCount recipes, $eCount expenses'
          : 'Synced (Manual Mode) • $rCount recipes, $eCount expenses';
    } catch (e) {
      _lastSyncSucceeded = false;
      _syncError = e.toString();
      _statusMessage = 'Sync Issue • Saved locally';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> pushLocalVaultToCloud() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _syncError = null;
    _statusMessage = 'Pushing local vault to Realtime DB...';
    notifyListeners();
    try {
      await Future.wait([
        if (_recipeProvider != null) _recipeProvider!.pushLocalToCloud(),
        if (_expenseProvider != null) _expenseProvider!.pushLocalToCloud(),
        if (_themeProvider != null) _themeProvider!.savePreferencesToCloud(),
      ]);
      _lastSyncedAt = DateTime.now();
      _lastSyncSucceeded = true;
      _statusMessage = 'Local vault pushed to cloud account';
    } catch (e) {
      _lastSyncSucceeded = false;
      _syncError = e.toString();
      _statusMessage = 'Push failed • Saved locally';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
