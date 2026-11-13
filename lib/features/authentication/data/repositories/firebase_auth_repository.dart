import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/services/auth_token_service.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_fallback_store.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth? _injectedAuth;
  final FirebaseFirestore? _injectedFirestore;
  final AuthTokenService _tokenService;
  final _stateController = StreamController<AuthUser?>.broadcast();

  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore, AuthTokenService? tokenService})
      : _injectedAuth = auth, _injectedFirestore = firestore, _tokenService = tokenService ?? AuthTokenService(auth: auth) {
    _initAuthStream();
  }

  FirebaseAuth? get _auth {
    if (_injectedAuth != null) return _injectedAuth;
    if (Firebase.apps.isEmpty) return null;
    try { return FirebaseAuth.instance; } catch (_) { return null; }
  }

  FirebaseFirestore? get _firestore {
    if (_injectedFirestore != null) return _injectedFirestore;
    if (Firebase.apps.isEmpty) return null;
    try { return FirebaseFirestore.instance; } catch (_) { return null; }
  }

  void _initAuthStream() {
    _auth?.idTokenChanges().listen((user) async {
      if (user == null) {
        AuthFallbackStore.activeUser = null;
        if (!_stateController.isClosed) _stateController.add(null);
        return;
      }
      final mapped = await _mapUserWithToken(user, fallbackName: AuthFallbackStore.activeUser?.displayName);
      AuthFallbackStore.activeUser = mapped;
      if (!_stateController.isClosed) _stateController.add(mapped);
    });
  }

  Future<AuthUser?> _mapUserWithToken(User? user, {String? fallbackName}) async {
    if (user == null) return null;
    final token = await _tokenService.getIdToken();
    final provider = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : (user.isAnonymous ? 'anonymous' : 'password');
    final resolvedName = (user.displayName != null && user.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : (fallbackName != null && fallbackName.trim().isNotEmpty ? fallbackName.trim() : AuthFallbackStore.nameFromEmail(user.email));

    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: resolvedName,
      photoUrl: user.photoURL,
      token: token,
      providerId: provider,
      isAnonymous: user.isAnonymous,
      emailVerified: user.emailVerified || provider == 'google.com',
    );
  }

  @override Stream<AuthUser?> get authStateChanges => _stateController.stream;
  @override Stream<String?> get idTokenChanges => _tokenService.onTokenChanged;

  @override
  AuthUser? get currentUser {
    final user = _auth?.currentUser;
    if (user != null) {
      final provider = user.providerData.isNotEmpty ? user.providerData.first.providerId : (user.isAnonymous ? 'anonymous' : 'password');
      return AuthUser(
        uid: user.uid, email: user.email,
        displayName: (user.displayName != null && user.displayName!.isNotEmpty) ? user.displayName : AuthFallbackStore.nameFromEmail(user.email),
        photoUrl: user.photoURL, token: _tokenService.cachedToken, providerId: provider,
        isAnonymous: user.isAnonymous, emailVerified: user.emailVerified || provider == 'google.com',
      );
    }
    return _auth == null ? AuthFallbackStore.activeUser : null;
  }

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) => _tokenService.getIdToken(forceRefresh: forceRefresh);

  @override
  Future<AuthUser?> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) return _setActiveUser(AuthFallbackStore.createGoogleFallbackUser());
    try {
      UserCredential cred;
      if (kIsWeb) {
        cred = await auth.signInWithPopup(GoogleAuthProvider()..addScope('email')..addScope('profile'));
      } else {
        await GoogleSignIn.instance.initialize(
          clientId: defaultTargetPlatform == TargetPlatform.iOS ? '453421733668-3op8qpumtd2p3vs6hdbh0sp5mgceca1m.apps.googleusercontent.com' : null,
          serverClientId: '453421733668-01cl1epvjhjguc7u1v3v0r19numbioit.apps.googleusercontent.com',
        );
        final acc = await GoogleSignIn.instance.authenticate(scopeHint: const ['email', 'profile']);
        final idToken = acc.authentication.idToken;
        if (idToken == null || idToken.isEmpty) throw Exception('Google Sign-In failed to return an ID token.');
        String? accessToken;
        try { accessToken = (await acc.authorizationClient.authorizationForScopes(const ['email', 'profile']))?.accessToken; } catch (_) {}
        cred = await auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken, accessToken: accessToken));
      }
      if (cred.user == null) throw Exception('Google Sign-In failed to create a Firebase session.');
      unawaited(_syncUserProfile(cred.user!, provider: 'google.com'));
      return _setActiveUser(await _mapUserWithToken(cred.user));
    } on FirebaseAuthException catch (e) {
      throw Exception(AuthFallbackStore.friendlyFirebaseError(e));
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) throw Exception('Google Sign-In cancelled.');
      throw Exception('Google Sign-In failed: ${e.description ?? e.code.name}');
    }
  }

  @override
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    final cleanEmail = email.trim();
    final auth = _auth;
    if (auth == null) {
      final localMatch = AuthFallbackStore.accounts[cleanEmail.toLowerCase()];
      if (localMatch != null && localMatch.password == password) return _setActiveUser(localMatch.user);
      return _setActiveUser(AuthFallbackStore.createLocalUser(email: cleanEmail, password: password));
    }
    try {
      final cred = await auth.signInWithEmailAndPassword(email: cleanEmail, password: password).timeout(const Duration(seconds: 15));
      if (cred.user == null) throw Exception('Sign-in failed. Please try again.');
      unawaited(_syncUserProfile(cred.user!, provider: 'password'));
      return _setActiveUser(await _mapUserWithToken(cred.user));
    } on FirebaseAuthException catch (e) {
      throw Exception(AuthFallbackStore.friendlyFirebaseError(e));
    }
  }

  @override
  Future<AuthUser?> registerWithEmail(String name, String email, String password) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim();
    final auth = _auth;
    if (auth == null) return _setActiveUser(AuthFallbackStore.createLocalUser(email: cleanEmail, password: password, name: cleanName));
    try {
      final cred = await auth.createUserWithEmailAndPassword(email: cleanEmail, password: password).timeout(const Duration(seconds: 15));
      final user = cred.user;
      if (user == null) throw Exception('Registration failed. Please try again.');
      if (cleanName.isNotEmpty) await user.updateDisplayName(cleanName);
      try { await user.sendEmailVerification(); } catch (_) {}
      await user.reload();
      final refreshed = auth.currentUser ?? user;
      unawaited(_syncUserProfile(refreshed, name: cleanName, provider: 'password'));
      return _setActiveUser(await _mapUserWithToken(refreshed, fallbackName: cleanName));
    } on FirebaseAuthException catch (e) {
      throw Exception(AuthFallbackStore.friendlyFirebaseError(e));
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth?.currentUser;
    if (user == null) throw Exception('Please sign in first to verify your email.');
    if (user.emailVerified) return;
    await user.sendEmailVerification();
  }

  @override
  Future<AuthUser?> reloadUser() async {
    final user = _auth?.currentUser;
    if (user == null) return currentUser;
    await user.reload();
    final refreshed = _auth?.currentUser;
    if (refreshed == null) return null;
    final mapped = await _mapUserWithToken(refreshed);
    if (mapped != null) unawaited(_syncUserProfile(refreshed, provider: mapped.providerId ?? 'password'));
    return _setActiveUser(mapped);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final auth = _auth;
    if (auth == null) return;
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(AuthFallbackStore.friendlyFirebaseError(e));
    }
  }

  @override
  Future<AuthUser?> signInAnonymously() async {
    final auth = _auth;
    if (auth == null) return _setActiveUser(const AuthUser(uid: 'anon_chef', isAnonymous: true, token: 'anon-token'));
    final cred = await auth.signInAnonymously().timeout(const Duration(seconds: 10));
    return _setActiveUser(await _mapUserWithToken(cred.user));
  }

  @override
  Future<void> signOut() async {
    AuthFallbackStore.activeUser = null;
    if (!kIsWeb) { try { await GoogleSignIn.instance.signOut().timeout(const Duration(seconds: 2)); } catch (_) {} }
    try { await _auth?.signOut().timeout(const Duration(seconds: 3)); } catch (_) {}
    _tokenService.clear();
    if (!_stateController.isClosed) _stateController.add(null);
  }

  AuthUser? _setActiveUser(AuthUser? user) {
    AuthFallbackStore.activeUser = user;
    if (user?.token != null) _tokenService.setFallbackToken(user!.token!);
    if (!_stateController.isClosed) _stateController.add(user);
    return user;
  }

  Future<void> _syncUserProfile(User user, {String? name, required String provider}) async {
    final data = <String, dynamic>{
      'uid': user.uid, 'email': user.email ?? '', 'displayName': name ?? user.displayName ?? '',
      'photoUrl': user.photoURL ?? '', 'provider': provider, 'emailVerified': user.emailVerified || provider == 'google.com',
      'lastLoginAt': DateTime.now().toIso8601String(),
    };
    try { await _firestore?.collection('users').doc(user.uid).set(data, SetOptions(merge: true)).timeout(const Duration(seconds: 3)); } catch (_) {}
    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseDatabase.instance.ref('users/${user.uid}/profile').update(data).timeout(const Duration(seconds: 3));
      }
    } catch (_) {}
  }
}
