import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/auth_user.dart';

/// Test-only fallback store when Firebase is not initialized (e.g. widget tests)
/// and human-friendly FirebaseAuthException error mapper.
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
      emailVerified: false,
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
      emailVerified: true,
    );
  }

  static String friendlyFirebaseError(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' || 'invalid-credential' || 'wrong-password' =>
        'Invalid email or password. New here? Tap "Create Account" above.',
      'email-already-in-use' =>
        'An account with this email already exists. Please sign in instead.',
      'weak-password' =>
        'Password is too weak. Please use at least 6 characters.',
      'invalid-email' => 'Please enter a valid email address.',
      'user-disabled' => 'This account has been disabled. Contact support.',
      'too-many-requests' =>
        'Too many attempts. Please wait a moment and try again.',
      'network-request-failed' =>
        'Network error. Please check your internet connection.',
      'operation-not-allowed' =>
        'This sign-in method is not enabled in Firebase Console.',
      'account-exists-with-different-credential' =>
        'An account already exists with this email using another sign-in method.',
      _ => e.message ?? 'Authentication error (${e.code}).',
    };
  }
}
