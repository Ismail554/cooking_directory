import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/auth_user.dart';

/// In-memory session and local account fallback store for offline/emulator resilience
/// and human-friendly Firebase error mapping.
abstract final class AuthFallbackStore {
  static AuthUser? activeUser;
  static final Map<String, ({String name, String password, AuthUser user})>
      accounts = {};

  static String nameFromEmail(String? email) {
    if (email == null || email.trim().isEmpty) return 'Chef';
    final prefix =
        email.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ').trim();
    if (prefix.isEmpty) return 'Chef';
    return prefix[0].toUpperCase() + prefix.substring(1);
  }

  static AuthUser createLocalUser({
    required String email,
    required String password,
    String? name,
  }) {
    final cleanEmail = email.trim();
    final key = cleanEmail.toLowerCase();
    final existing = accounts[key];
    final resolvedName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : (existing?.name ?? nameFromEmail(cleanEmail));
    final user = AuthUser(
      uid: 'chef_${key.hashCode.abs()}',
      email: cleanEmail,
      displayName: resolvedName,
      token: 'local-token-${key.hashCode.abs()}',
      providerId: 'password',
    );
    accounts[key] = (name: resolvedName, password: password, user: user);
    return user;
  }

  static AuthUser createGoogleFallbackUser() {
    return AuthUser(
      uid: 'google_chef_${DateTime.now().millisecondsSinceEpoch}',
      email: 'ismailshuvo555@gmail.com',
      displayName: 'Chef Ismail',
      token: 'google-oauth-token',
      providerId: 'google.com',
      isAnonymous: false,
    );
  }

  static bool isCredentialError(String code) => const {
        'wrong-password',
        'user-not-found',
        'invalid-credential',
        'invalid-email',
        'user-disabled',
      }.contains(code);

  static String friendlyFirebaseError(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' || 'invalid-credential' || 'wrong-password' =>
        'Invalid email or password. New here? Tap "Create one" below to register.',
      'email-already-in-use' =>
        'An account with this email already exists. Please sign in instead.',
      'weak-password' =>
        'Password is too weak. Please use at least 6 characters.',
      'invalid-email' => 'Please enter a valid email address.',
      _ => e.message ?? 'Authentication error (${e.code}).',
    };
  }
}

