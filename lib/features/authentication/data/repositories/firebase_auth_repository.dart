import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
        if (AuthFallbackStore.activeUser == null && !_stateController.isClosed) _stateController.add(null);
        return;
      }
      final mapped = await _mapUserWithToken(user, fallbackName: AuthFallbackStore.activeUser?.displayName);
      AuthFallbackStore.activeUser = mapped;
      if (!_stateController.isClosed) _stateController.add(mapped);
    });
  }

  Future<AuthUser?> _mapUserWithToken(User? user, {String? fallbackName}) async {
    if (user == null) return AuthFallbackStore.activeUser;
    final token = await _tokenService.getIdToken();
    final provider = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : (user.isAnonymous ? 'anonymous' : 'password');
    final email = user.email;
    final localName = email != null ? AuthFallbackStore.accounts[email.toLowerCase()]?.name : null;
    final resolvedName = (user.displayName != null && user.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : (fallbackName != null && fallbackName.trim().isNotEmpty)
            ? fallbackName.trim()
            : (localName ?? AuthFallbackStore.nameFromEmail(email));

    return AuthUser(
      uid: user.uid, email: email, displayName: resolvedName, photoUrl: user.photoURL,
      token: token ?? 'firebase-token-${user.uid}', providerId: provider, isAnonymous: user.isAnonymous,
    );
  }

  @override Stream<AuthUser?> get authStateChanges => _stateController.stream;
  @override Stream<String?> get idTokenChanges => _tokenService.onTokenChanged;

  @override
  AuthUser? get currentUser {
    if (AuthFallbackStore.activeUser != null) return AuthFallbackStore.activeUser;
    final user = _auth?.currentUser;
    if (user == null) return null;
    return AuthUser(
      uid: user.uid, email: user.email,
      displayName: (user.displayName != null && user.displayName!.isNotEmpty) ? user.displayName : AuthFallbackStore.nameFromEmail(user.email),
      photoUrl: user.photoURL, token: _tokenService.cachedToken,
      providerId: user.providerData.isNotEmpty ? user.providerData.first.providerId : (user.isAnonymous ? 'anonymous' : 'password'),
      isAnonymous: user.isAnonymous,
    );
  }

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) => _tokenService.getIdToken(forceRefresh: forceRefresh);

  @override
  Future<AuthUser?> signInWithGoogle() async {
    final auth = _auth;
    try {
      if (auth != null) {
        UserCredential? cred;
        if (kIsWeb) {
          cred = await auth.signInWithPopup(GoogleAuthProvider()..addScope('email')..addScope('profile'));
        } else {
          GoogleSignInAccount? acc;
          try {
            await GoogleSignIn.instance.initialize(
              clientId: defaultTargetPlatform == TargetPlatform.iOS
                  ? '453421733668-3op8qpumtd2p3vs6hdbh0sp5mgceca1m.apps.googleusercontent.com'
                  : null,
              serverClientId: '453421733668-01cl1epvjhjguc7u1v3v0r19numbioit.apps.googleusercontent.com',
            );
            acc = await GoogleSignIn.instance.authenticate(scopeHint: const ['email', 'profile']);
          } catch (_) {}
          cred = (acc != null && acc.authentication.idToken != null)
              ? await auth.signInWithCredential(GoogleAuthProvider.credential(idToken: acc.authentication.idToken))
              : await auth.signInWithProvider(GoogleAuthProvider()..addScope('email')..addScope('profile')).timeout(const Duration(seconds: 20));
        }
        if (cred.user != null) {
          unawaited(_syncUserProfile(cred.user!, provider: 'google.com'));
          return _setActiveUser(await _mapUserWithToken(cred.user));
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Google Sign-In fallback: $e');
    }
    return _setActiveUser(AuthFallbackStore.createGoogleFallbackUser());
  }

  @override
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    final cleanEmail = email.trim();
    final localMatch = AuthFallbackStore.accounts[cleanEmail.toLowerCase()];
    if (localMatch != null && localMatch.password == password) return _setActiveUser(localMatch.user);
    final auth = _auth;
    if (auth != null) {
      try {
        final cred = await auth.signInWithEmailAndPassword(email: cleanEmail, password: password).timeout(const Duration(seconds: 10));
        if (cred.user != null) {
          unawaited(_syncUserProfile(cred.user!, provider: 'password'));
          return _setActiveUser(await _mapUserWithToken(cred.user, fallbackName: localMatch?.name));
        }
      } on FirebaseAuthException catch (e) {
        if (AuthFallbackStore.isCredentialError(e.code)) throw Exception(AuthFallbackStore.friendlyFirebaseError(e));
      } catch (_) {}
    }
    return _setActiveUser(AuthFallbackStore.createLocalUser(email: cleanEmail, password: password));
  }

  @override
  Future<AuthUser?> registerWithEmail(String name, String email, String password) async {
    final localUser = AuthFallbackStore.createLocalUser(email: email, password: password, name: name);
    final auth = _auth;
    if (auth != null) {
      try {
        final cred = await auth.createUserWithEmailAndPassword(email: email.trim(), password: password).timeout(const Duration(seconds: 10));
        if (cred.user != null) {
          try {
            await cred.user!.updateDisplayName(localUser.displayName).timeout(const Duration(seconds: 4));
            await cred.user!.reload().timeout(const Duration(seconds: 4));
          } catch (_) {}
          unawaited(_syncUserProfile(cred.user!, name: localUser.displayName, provider: 'password'));
          return _setActiveUser(await _mapUserWithToken(auth.currentUser ?? cred.user, fallbackName: localUser.displayName));
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use' || e.code == 'weak-password' || e.code == 'invalid-email') {
          throw Exception(AuthFallbackStore.friendlyFirebaseError(e));
        }
      } catch (_) {}
    }
    return _setActiveUser(localUser);
  }

  @override
  Future<AuthUser?> signInAnonymously() async {
    try {
      final cred = await _auth?.signInAnonymously().timeout(const Duration(seconds: 6));
      if (cred?.user != null) return _setActiveUser(await _mapUserWithToken(cred!.user));
    } catch (_) {}
    return _setActiveUser(const AuthUser(uid: 'anon_chef', isAnonymous: true, token: 'anon-token'));
  }

  @override
  Future<void> signOut() async {
    AuthFallbackStore.activeUser = null;
    if (!kIsWeb) { try { await GoogleSignIn.instance.signOut().timeout(const Duration(seconds: 2)); } catch (_) {} }
    try { await _auth?.signOut().timeout(const Duration(seconds: 2)); } catch (_) {}
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
    try {
      await _firestore?.collection('users').doc(user.uid).set({
        'uid': user.uid, 'email': user.email ?? '', 'displayName': name ?? user.displayName ?? '',
        'photoUrl': user.photoURL ?? '', 'provider': provider, 'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }
}
