import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Service responsible for managing, caching, and refreshing Firebase auth tokens.
class AuthTokenService {
  final FirebaseAuth? _injectedAuth;
  String? _cachedToken;
  StreamSubscription<User?>? _sub;
  final _tokenController = StreamController<String?>.broadcast();

  AuthTokenService({FirebaseAuth? auth}) : _injectedAuth = auth {
    _initListener();
  }

  FirebaseAuth? get _auth {
    if (_injectedAuth != null) return _injectedAuth;
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  void _initListener() {
    final auth = _auth;
    if (auth == null) return;
    _sub = auth.idTokenChanges().listen((user) async {
      if (user != null) {
        try {
          _cachedToken = await user
              .getIdToken()
              .timeout(const Duration(seconds: 3));
        } catch (_) {}
      } else {
        _cachedToken = null;
      }
      if (!_tokenController.isClosed) {
        _tokenController.add(_cachedToken);
      }
    });
  }

  /// Current cached token (synchronous access).
  String? get cachedToken => _cachedToken;

  /// Whether a valid token is present in memory.
  bool get hasToken => _cachedToken != null && _cachedToken!.isNotEmpty;

  /// Stream of token updates (fires on sign-in, sign-out, and auto-refresh).
  Stream<String?> get onTokenChanged => _tokenController.stream;

  /// Retrieves the current token, optionally forcing a refresh.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _auth?.currentUser;
      if (user == null) {
        return _cachedToken;
      }
      _cachedToken = await user
          .getIdToken(forceRefresh)
          .timeout(const Duration(seconds: 3));
      return _cachedToken;
    } catch (e) {
      if (kDebugMode) debugPrint('Error retrieving ID token: $e');
      return _cachedToken;
    }
  }

  /// Sets a local fallback token when offline or using local session fallback.
  void setFallbackToken(String token) {
    _cachedToken = token;
    if (!_tokenController.isClosed) {
      _tokenController.add(_cachedToken);
    }
  }

  /// Prepares Authorization Bearer headers for outgoing API requests.
  Future<Map<String, String>> getAuthorizationHeaders({
    bool forceRefresh = false,
  }) async {
    final token = await getIdToken(forceRefresh: forceRefresh);
    if (token != null && token.isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }
    return {};
  }

  /// Manually clears cached token.
  void clear() {
    _cachedToken = null;
    if (!_tokenController.isClosed) {
      _tokenController.add(null);
    }
  }

  void dispose() {
    _sub?.cancel();
    _tokenController.close();
  }
}
