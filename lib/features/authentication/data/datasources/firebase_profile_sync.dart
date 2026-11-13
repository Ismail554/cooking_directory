import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Executes native/web Google Sign-In and exchanges credentials with FirebaseAuth.
Future<UserCredential> signInWithGoogleFirebase(FirebaseAuth auth) async {
  if (kIsWeb) {
    return auth.signInWithPopup(GoogleAuthProvider()..addScope('email')..addScope('profile'));
  }
  await GoogleSignIn.instance.initialize(
    clientId: defaultTargetPlatform == TargetPlatform.iOS
        ? '453421733668-3op8qpumtd2p3vs6hdbh0sp5mgceca1m.apps.googleusercontent.com'
        : null,
    serverClientId: '453421733668-01cl1epvjhjguc7u1v3v0r19numbioit.apps.googleusercontent.com',
  );
  final acc = await GoogleSignIn.instance.authenticate(scopeHint: const ['email', 'profile']);
  final idToken = acc.authentication.idToken;
  if (idToken == null || idToken.isEmpty) {
    throw Exception('Google Sign-In failed to return an ID token.');
  }
  String? accessToken;
  try {
    accessToken = (await acc.authorizationClient.authorizationForScopes(const ['email', 'profile']))?.accessToken;
  } catch (_) {}
  return auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken, accessToken: accessToken));
}

/// Syncs basic Firebase user profile fields to Firestore and Realtime Database.
Future<void> syncFirebaseUserProfile({
  required User user,
  FirebaseFirestore? firestore,
  String? name,
  required String provider,
}) async {
  final data = <String, dynamic>{
    'uid': user.uid,
    'email': user.email ?? '',
    'displayName': name ?? user.displayName ?? '',
    'photoUrl': user.photoURL ?? '',
    'provider': provider,
    'emailVerified': user.emailVerified || provider == 'google.com',
    'lastLoginAt': DateTime.now().toIso8601String(),
  };
  try {
    await firestore
        ?.collection('users')
        .doc(user.uid)
        .set(data, SetOptions(merge: true))
        .timeout(const Duration(seconds: 3));
  } catch (_) {}
  try {
    if (Firebase.apps.isNotEmpty) {
      await FirebaseDatabase.instance
          .ref('users/${user.uid}/profile')
          .update(data)
          .timeout(const Duration(seconds: 3));
    }
  } catch (_) {}
}
