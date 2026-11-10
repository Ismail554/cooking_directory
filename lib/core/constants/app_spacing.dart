import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Centralized spacing tokens and helper widgets.
/// Follows responsive screen scaling via [ScreenUtil].
abstract final class AppSpacing {
  // Raw numeric scale
  static const double zero = 0.0;
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double massive = 48.0;
  static const double giant = 64.0;

  // Scaled dimensions
  static double get s2 => 2.r;
  static double get s4 => 4.r;
  static double get s8 => 8.r;
  static double get s12 => 12.r;
  static double get s16 => 16.r;
  static double get s20 => 20.r;
  static double get s24 => 24.r;
  static double get s32 => 32.r;
  static double get s40 => 40.r;
  static double get s48 => 48.r;
  static double get s64 => 64.r;

  // Horizontal gap widgets
  static SizedBox get gapW2 => SizedBox(width: 2.w);
  static SizedBox get gapW4 => SizedBox(width: 4.w);
  static SizedBox get gapW8 => SizedBox(width: 8.w);
  static SizedBox get gapW12 => SizedBox(width: 12.w);
  static SizedBox get gapW16 => SizedBox(width: 16.w);
  static SizedBox get gapW20 => SizedBox(width: 20.w);
  static SizedBox get gapW24 => SizedBox(width: 24.w);
  static SizedBox get gapW32 => SizedBox(width: 32.w);
  static SizedBox get gapW40 => SizedBox(width: 40.w);
  static SizedBox get gapW48 => SizedBox(width: 48.w);

  // Vertical gap widgets
  static SizedBox get gapH2 => SizedBox(height: 2.h);
  static SizedBox get gapH4 => SizedBox(height: 4.h);
  static SizedBox get gapH8 => SizedBox(height: 8.h);
  static SizedBox get gapH12 => SizedBox(height: 12.h);
  static SizedBox get gapH16 => SizedBox(height: 16.h);
  static SizedBox get gapH20 => SizedBox(height: 20.h);
  static SizedBox get gapH24 => SizedBox(height: 24.h);
  static SizedBox get gapH32 => SizedBox(height: 32.h);
  static SizedBox get gapH40 => SizedBox(height: 40.h);
  static SizedBox get gapH48 => SizedBox(height: 48.h);
  static SizedBox get gapH64 => SizedBox(height: 64.h);

  // Custom gap methods
  static SizedBox horizontal(double width) => SizedBox(width: width.w);
  static SizedBox vertical(double height) => SizedBox(height: height.h);

  // Reusable padding presets
  static EdgeInsets get paddingZero => EdgeInsets.zero;
  static EdgeInsets get paddingAll4 => EdgeInsets.all(4.r);
  static EdgeInsets get paddingAll8 => EdgeInsets.all(8.r);
  static EdgeInsets get paddingAll12 => EdgeInsets.all(12.r);
  static EdgeInsets get paddingAll16 => EdgeInsets.all(16.r);
  static EdgeInsets get paddingAll20 => EdgeInsets.all(20.r);
  static EdgeInsets get paddingAll24 => EdgeInsets.all(24.r);

  static EdgeInsets get paddingH8 => EdgeInsets.symmetric(horizontal: 8.w);
  static EdgeInsets get paddingH16 => EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets get paddingH20 => EdgeInsets.symmetric(horizontal: 20.w);
  static EdgeInsets get paddingH24 => EdgeInsets.symmetric(horizontal: 24.w);

  static EdgeInsets get paddingV8 => EdgeInsets.symmetric(vertical: 8.h);
  static EdgeInsets get paddingV12 => EdgeInsets.symmetric(vertical: 12.h);
  static EdgeInsets get paddingV16 => EdgeInsets.symmetric(vertical: 16.h);
  static EdgeInsets get paddingV24 => EdgeInsets.symmetric(vertical: 24.h);

  // Screen & Component padding presets
  static EdgeInsets get screenPadding =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);
  static EdgeInsets get cardPadding => EdgeInsets.all(16.r);
  static EdgeInsets get dialogPadding => EdgeInsets.all(24.r);
  static EdgeInsets get bottomSheetPadding =>
      EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h);
}
