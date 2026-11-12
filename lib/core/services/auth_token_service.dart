import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service responsible for managing, caching, and refreshing Firebase auth tokens.
class AuthTokenService {
  final FirebaseAuth _auth;
  String? _cachedToken;
  final _tokenController = StreamController<String?>.broadcast();

  AuthTokenService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance {
    _initListener();
  }

  void _initListener() {
    _auth.idTokenChanges().listen((user) async {
      if (user != null) {
        _cachedToken = await user.getIdToken();
      } else {
        _cachedToken = null;
      }
      _tokenController.add(_cachedToken);
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
      final user = _auth.currentUser;
      if (user == null) {
        _cachedToken = null;
        return null;
      }
      _cachedToken = await user.getIdToken(forceRefresh);
      return _cachedToken;
    } catch (e) {
      if (kDebugMode) debugPrint('Error retrieving ID token: $e');
      return _cachedToken;
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
    _tokenController.add(null);
  }

  void dispose() {
    _tokenController.close();
  }
}
