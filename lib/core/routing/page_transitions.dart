import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

/// Utilities for smooth native iOS Cupertino page transitions.
abstract final class PageTransitions {
  /// Builds a [CupertinoPage] providing native iOS slide transition
  /// and interactive swipe-back gesture support.
  static Page<T> cupertino<T>({
    required Widget child,
    required GoRouterState state,
    String? title,
  }) {
    return CupertinoPage<T>(
      key: state.pageKey,
      name: state.name ?? state.matchedLocation,
      title: title,
      child: child,
    );
  }

  /// Builds a native iOS modal presentation (slides up from bottom).
  static Page<T> cupertinoModal<T>({
    required Widget child,
    required GoRouterState state,
    String? title,
  }) {
    return CupertinoPage<T>(
      key: state.pageKey,
      name: state.name ?? state.matchedLocation,
      fullscreenDialog: true,
      title: title,
      child: child,
    );
  }
}
