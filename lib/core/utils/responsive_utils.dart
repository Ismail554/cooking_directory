import 'package:flutter/material.dart';

/// Screen breakpoints and adaptive layout helpers.
abstract final class ResponsiveUtils {
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  /// Selects a responsive value based on current device width.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletBreakpoint && desktop != null) {
      return desktop;
    }
    if (width >= mobileBreakpoint && tablet != null) {
      return tablet;
    }
    return mobile;
  }
}
