import '../entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;
  Stream<String?> get idTokenChanges;
  AuthUser? get currentUser;
  Future<String?> getIdToken({bool forceRefresh = false});
  Future<AuthUser?> signInWithEmail(String email, String password);
  Future<AuthUser?> registerWithEmail(String name, String email, String password);
  Future<AuthUser?> signInWithGoogle();
  Future<AuthUser?> signInAnonymously();
  Future<void> sendEmailVerification();
  Future<AuthUser?> reloadUser();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}
