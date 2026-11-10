import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';

TextStyle _getTextStyle(
  double fontSize,
  FontWeight fontWeight,
  Color color, {
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

/// Regular text style helper
TextStyle getRegularStyle({
  double? fontSize,
  Color color = AppColors.textPrimaryLight,
  double? height,
  double? letterSpacing,
}) {
  return _getTextStyle(
    fontSize ?? 14.sp,
    FontWeightManager.regular,
    color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

/// Medium text style helper
TextStyle getMediumStyle({
  double? fontSize,
  Color color = AppColors.textPrimaryLight,
  double? height,
  double? letterSpacing,
}) {
  return _getTextStyle(
    fontSize ?? 14.sp,
    FontWeightManager.medium,
    color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

/// SemiBold text style helper
TextStyle getSemiBoldStyle({
  double? fontSize,
  Color color = AppColors.textPrimaryLight,
  double? height,
  double? letterSpacing,
}) {
  return _getTextStyle(
    fontSize ?? 16.sp,
    FontWeightManager.semiBold,
    color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

/// Bold text style helper
TextStyle getBoldStyle({
  double? fontSize,
  Color color = AppColors.textPrimaryLight,
  double? height,
  double? letterSpacing,
}) {
  return _getTextStyle(
    fontSize ?? 18.sp,
    FontWeightManager.bold,
    color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

/// Light text style helper
TextStyle getLightStyle({
  double? fontSize,
  Color color = AppColors.textSecondaryLight,
  double? height,
  double? letterSpacing,
}) {
  return _getTextStyle(
    fontSize ?? 12.sp,
    FontWeightManager.light,
    color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

/// ExtraBold text style helper
TextStyle getExtraBoldStyle({
  double? fontSize,
  Color color = AppColors.textPrimaryLight,
  double? height,
  double? letterSpacing,
}) {
  return _getTextStyle(
    fontSize ?? 24.sp,
    FontWeightManager.extraBold,
    color,
    height: height,
    letterSpacing: letterSpacing,
  );
}
