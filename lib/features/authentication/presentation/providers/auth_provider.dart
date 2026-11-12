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
      _currentUser = user;
      notifyListeners();
    });
  }

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && !_currentUser!.isAnonymous;
  bool get isAnonymous => _currentUser?.isAnonymous ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get idToken => _currentUser?.token;
  String? get photoUrl => _currentUser?.photoUrl;
  String? get displayName => _currentUser?.displayName;
  String? get email => _currentUser?.email;

  Future<String?> getFreshToken() async {
    final token = await _repository.getIdToken(forceRefresh: true);
    if (_currentUser != null && token != null) {
      _currentUser = _currentUser!.copyWith(token: token);
      notifyListeners();
    }
    return token;
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _repository.signInWithGoogle();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = _cleanError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _repository.signInWithEmail(email, password);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerWithEmail(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _repository.registerWithEmail(name, email, password);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInAnonymously() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _repository.signInAnonymously();
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _currentUser = null;
    notifyListeners();
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
