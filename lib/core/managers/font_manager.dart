import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Font families and typography constants.
abstract final class FontConstants {
  static const String fontFamily = 'Poppins';
}

/// Centralized Font Weights.
abstract final class FontWeightManager {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}

/// Centralized Font Sizes scaled with ScreenUtil (.sp).
abstract final class FontSize {
  static double get s10 => 10.sp;
  static double get s11 => 11.sp;
  static double get s12 => 12.sp;
  static double get s13 => 13.sp;
  static double get s14 => 14.sp;
  static double get s15 => 15.sp;
  static double get s16 => 16.sp;
  static double get s18 => 18.sp;
  static double get s20 => 20.sp;
  static double get s22 => 22.sp;
  static double get s24 => 24.sp;
  static double get s28 => 28.sp;
  static double get s32 => 32.sp;
  static double get s36 => 36.sp;
  static double get s40 => 40.sp;
}
