import 'package:flutter/material.dart';

/// Centralized color manager for Cooking Directory.
/// Strictly avoid hardcoding Color literals outside this file.
abstract final class AppColors {
  // Brand & Primary Palette (Warm Culinary Terracotta & Orange)
  static const Color primary = Color(0xFFE65100);
  static const Color primaryDark = Color(0xFFAC1900);
  static const Color primaryLight = Color(0xFFFF833A);
  static const Color primaryContainer = Color(0xFFFFE0B2);
  static const Color onPrimary = Colors.white;

  // Secondary Palette (Fresh Herb & Sage Green)
  static const Color secondary = Color(0xFF2E7D32);
  static const Color secondaryDark = Color(0xFF005005);
  static const Color secondaryLight = Color(0xFF60AD5E);
  static const Color secondaryContainer = Color(0xFFC8E6C9);
  static const Color onSecondary = Colors.white;

  // Accent & Highlights (Golden Saffron & Warm Honey)
  static const Color accent = Color(0xFFFFA000);
  static const Color accentLight = Color(0xFFFFD54F);

  // Background & Surface - Light Mode
  static const Color backgroundLight = Color(0xFFFBF9F6);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF3EFEA);

  // Background & Surface - Dark Mode
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF252525);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);

  // Typography & Text - Light Mode
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF6C6C6C);
  static const Color textTertiaryLight = Color(0xFF9E9E9E);
  static const Color textHintLight = Color(0xFFBDBDBD);

  // Typography & Text - Dark Mode
  static const Color textPrimaryDark = Color(0xFFEEEEEE);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  static const Color textTertiaryDark = Color(0xFF757575);
  static const Color textHintDark = Color(0xFF616161);

  // Borders, Outlines & Dividers
  static const Color borderLight = Color(0xFFE5E0D8);
  static const Color dividerLight = Color(0xFFEEEEEE);
  static const Color borderDark = Color(0xFF383838);
  static const Color dividerDark = Color(0xFF2A2A2A);

  // Semantic Status
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFED6C02);
  static const Color info = Color(0xFF0288D1);

  // Culinary Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF833A), Color(0xFFE65100)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient warmCardGradient = LinearGradient(
    colors: [Color(0xFFFFF8F1), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Culinary Card Shadows
  static const BoxShadow culinaryCardShadow = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 16,
    offset: Offset(0, 6),
  );

  static const BoxShadow glowingOrangeShadow = BoxShadow(
    color: Color(0x33E65100),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  // Culinary Semantic Badges & Tags
  static const Color ratingStar = Color(0xFFFFB300);
  static const Color calorieBadge = Color(0xFFFFF3E0);
  static const Color calorieText = Color(0xFFE65100);
  static const Color prepTimeTag = Color(0xFFE8F5E9);
  static const Color prepTimeText = Color(0xFF2E7D32);

  // Culinary Difficulty Badges
  static const Color difficultyEasy = Color(0xFF2E7D32);
  static const Color difficultyMedium = Color(0xFFFFA000);
  static const Color difficultyHard = Color(0xFFD32F2F);

  // Expense Categories Palette
  static const Color expenseGroceries = Color(0xFF4CAF50);
  static const Color expenseDiningOut = Color(0xFFFF7043);
  static const Color expenseEquipment = Color(0xFF42A5F5);
  static const Color expenseBeverages = Color(0xFFAB47BC);
  static const Color expenseSpices = Color(0xFFFFCA28);
  static const Color expenseMiscellaneous = Color(0xFF78909C);

  // Shimmer Effect
  static const Color shimmerBaseLight = Color(0xFFE0E0E0);
  static const Color shimmerHighlightLight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF2C2C2C);
  static const Color shimmerHighlightDark = Color(0xFF3D3D3D);
}
