import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:cooking_directory/features/authentication/domain/entities/auth_user.dart';
import 'package:cooking_directory/features/authentication/domain/repositories/auth_repository.dart';
import 'package:cooking_directory/features/authentication/presentation/providers/auth_provider.dart';

class _MockAuthRepository implements AuthRepository {
  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? mockUser;
  String? mockToken = 'mock-id-token-123';
  bool throwOnGoogle = false;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  @override
  Stream<String?> get idTokenChanges => Stream.value(mockToken);

  @override
  AuthUser? get currentUser => mockUser;

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return forceRefresh ? 'refreshed-$mockToken' : mockToken;
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    if (throwOnGoogle) throw Exception('Google sign in failed');
    mockUser = const AuthUser(
      uid: 'google-uid-1',
      email: 'chef@google.com',
      displayName: 'Google Chef',
      photoUrl: 'https://example.com/photo.jpg',
      token: 'mock-id-token-123',
      providerId: 'google.com',
      isAnonymous: false,
    );
    _controller.add(mockUser);
    return mockUser;
  }

  @override
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    mockUser = AuthUser(
      uid: 'email-uid-1',
      email: email,
      displayName: 'Email Chef',
      token: 'email-token',
      providerId: 'password',
    );
    _controller.add(mockUser);
    return mockUser;
  }

  @override
  Future<AuthUser?> registerWithEmail(String name, String email, String password) async {
    mockUser = AuthUser(
      uid: 'reg-uid-1',
      email: email,
      displayName: name,
      token: 'reg-token',
      providerId: 'password',
    );
    _controller.add(mockUser);
    return mockUser;
  }

  @override
  Future<AuthUser?> signInAnonymously() async {
    mockUser = const AuthUser(
      uid: 'anon-1',
      isAnonymous: true,
      token: 'anon-token',
    );
    _controller.add(mockUser);
    return mockUser;
  }

  @override
  Future<void> signOut() async {
    mockUser = null;
    _controller.add(null);
  }

  void dispose() => _controller.close();
}

void main() {
  group('AuthProvider Tests', () {
    late _MockAuthRepository mockRepo;
    late AuthProvider provider;

    setUp(() {
      mockRepo = _MockAuthRepository();
      provider = AuthProvider(repository: mockRepo);
    });

    tearDown(() {
      provider.dispose();
      mockRepo.dispose();
    });

    test('initial state has no authenticated user', () {
      expect(provider.currentUser, isNull);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('signInWithGoogle succeeds and populates user profile and token', () async {
      final success = await provider.signInWithGoogle();

      expect(success, isTrue);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.displayName, 'Google Chef');
      expect(provider.email, 'chef@google.com');
      expect(provider.photoUrl, 'https://example.com/photo.jpg');
      expect(provider.idToken, 'mock-id-token-123');
      expect(provider.errorMessage, isNull);
    });

    test('signInWithGoogle handles exception and sets errorMessage', () async {
      mockRepo.throwOnGoogle = true;
      final success = await provider.signInWithGoogle();

      expect(success, isFalse);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.errorMessage, contains('Google sign in failed'));
      expect(provider.isLoading, isFalse);
    });

    test('getFreshToken forces refresh and updates user token', () async {
      await provider.signInWithGoogle();
      final fresh = await provider.getFreshToken();

      expect(fresh, 'refreshed-mock-id-token-123');
      expect(provider.idToken, 'refreshed-mock-id-token-123');
    });

    test('signInWithEmail and signOut flow correctly', () async {
      final loggedIn = await provider.signInWithEmail('test@chef.com', 'password');
      expect(loggedIn, isTrue);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.email, 'test@chef.com');

      await provider.signOut();
      expect(provider.currentUser, isNull);
      expect(provider.isAuthenticated, isFalse);
    });
  });
}

