import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';

TextStyle _getTextStyle(
  double fontSize,
  FontWeight fontWeight,
  Color? color, {
  double? height,
  double? letterSpacing,
  TextDecoration? decoration,
}) {
  return TextStyle(
    fontSize: fontSize,
    fontFamily: FontConstants.fontFamily,
    color: color,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
  );
}

/// Explicit theme-aware typography helper taking mandatory [context].
TextStyle getThemeAwareStyle(
  BuildContext context, {
  required double fontSize,
  FontWeight fontWeight = FontWeightManager.regular,
  Color? color,
  double? height,
  double? letterSpacing,
  TextDecoration? decoration,
}) {
  final resolvedColor = color ?? Theme.of(context).colorScheme.onSurface;
  return _getTextStyle(
    fontSize,
    fontWeight,
    resolvedColor,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
  );
}

/// Regular text style helper (weight 400). Defaults to theme onSurface.
TextStyle getRegularStyle({
  BuildContext? context,
  double? fontSize,
  Color? color,
  double? height,
  double? letterSpacing,
  TextDecoration? decoration,
}) {
  final resolved = color ??
      (context != null ? Theme.of(context).colorScheme.onSurface : null);
  return _getTextStyle(
    fontSize ?? 14.sp,
    FontWeightManager.regular,
    resolved,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
  );
}

/// Medium text style helper (weight 500). Defaults to theme onSurface.
TextStyle getMediumStyle({
  BuildContext? context,
  double? fontSize,
  Color? color,
  double? height,
  double? letterSpacing,
  TextDecoration? decoration,
}) {
  final resolved = color ??
      (context != null ? Theme.of(context).colorScheme.onSurface : null);
  return _getTextStyle(
    fontSize ?? 14.sp,
    FontWeightManager.medium,
    resolved,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
  );
}

/// SemiBold text style helper (weight 600). Defaults to theme onSurface.
TextStyle getSemiBoldStyle({
  BuildContext? context,
  double? fontSize,
  Color? color,
  double? height,
  double? letterSpacing,
  TextDecoration? decoration,
}) {
  final resolved = color ??
      (context != null ? Theme.of(context).colorScheme.onSurface : null);
  return _getTextStyle(
    fontSize ?? 16.sp,
    FontWeightManager.semiBold,
    resolved,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
  );
}

/// Bold text style helper (weight 700). Defaults to theme onSurface.
TextStyle getBoldStyle({
  BuildContext? context,
  double? fontSize,
  Color? color,
  double? height,
  double? letterSpacing,
  TextDecoration? decoration,
}) {
  final resolved = color ??
      (context != null ? Theme.of(context).colorScheme.onSurface : null);
  return _getTextStyle(
    fontSize ?? 18.sp,
    FontWeightManager.bold,
    resolved,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
  );
}

/// Light text style helper (weight 300). Defaults to theme onSurfaceVariant.
TextStyle getLightStyle({
  BuildContext? context,
  double? fontSize,
  Color? color,
  double? height,
  double? letterSpacing,
  TextDecoration? decoration,
}) {
  final resolved = color ??
      (context != null ? Theme.of(context).colorScheme.onSurfaceVariant : null);
  return _getTextStyle(
    fontSize ?? 12.sp,
    FontWeightManager.light,
    resolved,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
  );
}

/// ExtraBold text style helper (weight 800). Defaults to theme onSurface.
TextStyle getExtraBoldStyle({
  BuildContext? context,
  double? fontSize,
  Color? color,
  double? height,
  double? letterSpacing,
  TextDecoration? decoration,
}) {
  final resolved = color ??
      (context != null ? Theme.of(context).colorScheme.onSurface : null);
  return _getTextStyle(
    fontSize ?? 24.sp,
    FontWeightManager.extraBold,
    resolved,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
  );
}
