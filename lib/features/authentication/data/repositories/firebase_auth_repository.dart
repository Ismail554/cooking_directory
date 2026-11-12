import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/services/auth_token_service.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final AuthTokenService _tokenService;

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    AuthTokenService? tokenService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _tokenService = tokenService ?? AuthTokenService(auth: auth);

  Future<AuthUser?> _mapUserWithToken(User? user) async {
    if (user == null) return null;
    final token = await _tokenService.getIdToken();
    final provider = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : (user.isAnonymous ? 'anonymous' : 'password');

    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      token: token,
      providerId: provider,
      isAnonymous: user.isAnonymous,
    );
  }

  @override
  Stream<AuthUser?> get authStateChanges =>
      _auth.idTokenChanges().asyncMap(_mapUserWithToken);

  @override
  Stream<String?> get idTokenChanges => _tokenService.onTokenChanged;

  @override
  AuthUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      token: _tokenService.cachedToken,
      providerId: user.providerData.isNotEmpty
          ? user.providerData.first.providerId
          : (user.isAnonymous ? 'anonymous' : 'password'),
      isAnonymous: user.isAnonymous,
    );
  }

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) =>
      _tokenService.getIdToken(forceRefresh: forceRefresh);

  @override
  Future<AuthUser?> signInWithGoogle() async {
    UserCredential? credential;
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      credential = await _auth.signInWithPopup(googleProvider);
    } else {
      GoogleSignInAccount? googleAccount;
      try {
        googleAccount = await GoogleSignIn.instance.authenticate();
      } catch (e) {
        if (kDebugMode) debugPrint('GoogleSignIn authenticate note: $e');
      }

      if (googleAccount != null) {
        final googleAuth = await googleAccount.authentication;
        final authCred = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        credential = await _auth.signInWithCredential(authCred);
      } else {
        // Fallback to federated provider
        final googleProvider = GoogleAuthProvider();
        credential = await _auth.signInWithProvider(googleProvider);
      }
    }

    final user = credential.user;
    if (user != null) {
      await _syncUserProfile(user, provider: 'google.com');
    }
    return _mapUserWithToken(user);
  }

  @override
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      await _syncUserProfile(user, provider: 'password');
    }
    return _mapUserWithToken(user);
  }

  @override
  Future<AuthUser?> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      if (name.trim().isNotEmpty) {
        await user.updateDisplayName(name.trim());
      }
      await _syncUserProfile(user, name: name.trim(), provider: 'password');
    }
    return _mapUserWithToken(user);
  }

  @override
  Future<AuthUser?> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    return _mapUserWithToken(cred.user);
  }

  @override
  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
    await _auth.signOut();
    _tokenService.clear();
  }

  Future<void> _syncUserProfile(
    User user, {
    String? name,
    required String provider,
  }) async {
    try {
      final docData = <String, dynamic>{
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': name ?? user.displayName ?? '',
        'photoUrl': user.photoURL ?? '',
        'provider': provider,
        'lastLoginAt': FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(docData, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) debugPrint('Firestore user sync warning: $e');
    }
  }
}
