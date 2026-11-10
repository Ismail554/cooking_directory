import 'package:flutter/material.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';

ThemeData getLightTheme() {
  final colorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimaryLight,
    error: AppColors.error,
    onError: Colors.white,
    outline: AppColors.borderLight,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: FontConstants.fontFamily,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      elevation: AppElevation.e0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 18,
        fontWeight: FontWeightManager.semiBold,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: AppElevation.e1,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r16),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: AppElevation.e0,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r12),
        padding: AppSpacing.paddingH20,
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeightManager.semiBold,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariantLight,
      contentPadding: AppSpacing.paddingAll16,
      border: OutlineInputBorder(
        borderRadius: AppBorderRadius.r12,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.r12,
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.r12,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.r12,
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
  );
}
