import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Centralized border radii tokens.
abstract final class AppRadius {
  static double get r4 => 4.r;
  static double get r8 => 8.r;
  static double get r12 => 12.r;
  static double get r16 => 16.r;
  static double get r20 => 20.r;
  static double get r24 => 24.r;
  static double get r32 => 32.r;
  static double get circular => 999.r;
}

/// Centralized [BorderRadius] objects for widget styling.
abstract final class AppBorderRadius {
  static BorderRadius get r4 => BorderRadius.circular(4.r);
  static BorderRadius get r8 => BorderRadius.circular(8.r);
  static BorderRadius get r12 => BorderRadius.circular(12.r);
  static BorderRadius get r16 => BorderRadius.circular(16.r);
  static BorderRadius get r20 => BorderRadius.circular(20.r);
  static BorderRadius get r24 => BorderRadius.circular(24.r);
  static BorderRadius get r32 => BorderRadius.circular(32.r);
  static BorderRadius get circular => BorderRadius.circular(999.r);

  // Top rounded corners (bottom sheets, cards)
  static BorderRadius get topSheet => BorderRadius.vertical(
        top: Radius.circular(24.r),
      );
}

/// Centralized Icon Sizes.
abstract final class AppIconSize {
  static double get s14 => 14.r;
  static double get s16 => 16.r;
  static double get s18 => 18.r;
  static double get s20 => 20.r;
  static double get s24 => 24.r;
  static double get s28 => 28.r;
  static double get s32 => 32.r;
  static double get s40 => 40.r;
  static double get s48 => 48.r;
}

/// Centralized Elevation values.
abstract final class AppElevation {
  static const double e0 = 0.0;
  static const double e1 = 1.0;
  static const double e2 = 2.0;
  static const double e4 = 4.0;
  static const double e8 = 8.0;
}
