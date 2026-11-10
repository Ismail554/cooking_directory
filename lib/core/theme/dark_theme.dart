import 'package:flutter/material.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';

ThemeData getDarkTheme() {
  final colorScheme = ColorScheme.dark(
    primary: AppColors.primaryLight,
    onPrimary: Colors.black,
    primaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondaryLight,
    onSecondary: Colors.black,
    secondaryContainer: AppColors.secondaryDark,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    error: AppColors.error,
    onError: Colors.white,
    outline: AppColors.borderDark,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: FontConstants.fontFamily,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: AppElevation.e0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 18,
        fontWeight: FontWeightManager.semiBold,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: AppElevation.e1,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r16),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.black,
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
      fillColor: AppColors.surfaceVariantDark,
      contentPadding: AppSpacing.paddingAll16,
      border: OutlineInputBorder(
        borderRadius: AppBorderRadius.r12,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.r12,
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.r12,
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.r12,
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
  );
}
