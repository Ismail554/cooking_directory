import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  StreamSubscription<AuthUser?>? _userSub;

  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    AuthRepository? repository,
  }) : _repository = repository ?? FirebaseAuthRepository() {
    _currentUser = _repository.currentUser;
    _userSub = _repository.authStateChanges.listen((user) {
      if (user != null &&
          (user.displayName == null || user.displayName!.isEmpty) &&
          _currentUser?.displayName != null &&
          _currentUser!.displayName!.isNotEmpty &&
          user.uid == _currentUser!.uid) {
        _currentUser = user.copyWith(displayName: _currentUser!.displayName);
      } else {
        _currentUser = user;
      }
      notifyListeners();
    });
  }

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && !_currentUser!.isAnonymous;
  bool get isEmailVerified => _currentUser?.emailVerified ?? false;
  bool get isAnonymous => _currentUser?.isAnonymous ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get idToken => _currentUser?.token;
  String? get photoUrl => _currentUser?.photoUrl;
  String? get displayName => _currentUser?.displayName;
  String? get email => _currentUser?.email;

  Future<bool> _runAction(Future<bool> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      return await action();
    } catch (e) {
      _errorMessage = _cleanError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendEmailVerification() => _runAction(() async {
        await _repository.sendEmailVerification();
        return true;
      });

  Future<bool> reloadUser() => _runAction(() async {
        _currentUser = await _repository.reloadUser();
        return _currentUser?.emailVerified ?? false;
      });

  Future<bool> sendPasswordResetEmail(String email) => _runAction(() async {
        await _repository.sendPasswordResetEmail(email);
        return true;
      });

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<String?> getFreshToken() async {
    final token = await _repository.getIdToken(forceRefresh: true);
    if (_currentUser != null && token != null) {
      _currentUser = _currentUser!.copyWith(token: token);
      notifyListeners();
    }
    return token;
  }

  Future<bool> signInWithGoogle() => _runAction(() async {
        _currentUser = await _repository.signInWithGoogle();
        return _currentUser != null;
      });

  Future<bool> signInWithEmail(String email, String password) => _runAction(() async {
        _currentUser = await _repository.signInWithEmail(email, password);
        if (_currentUser == null) {
          _errorMessage = 'Unable to sign in with the provided credentials.';
          return false;
        }
        return true;
      });

  Future<bool> registerWithEmail(String name, String email, String password) => _runAction(() async {
        _currentUser = await _repository.registerWithEmail(name, email, password);
        if (_currentUser == null) {
          _errorMessage = 'Could not create account. Please try again.';
          return false;
        }
        return true;
      });

  Future<bool> signInAnonymously() => _runAction(() async {
        _currentUser = await _repository.signInAnonymously();
        return _currentUser != null;
      });

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.signOut();
    } finally {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  String _cleanError(Object e) {
    return e
        .toString()
        .replaceFirst(RegExp(r'^(Exception|FirebaseAuthException|FirebaseException):\s*'), '')
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .trim();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }
}
