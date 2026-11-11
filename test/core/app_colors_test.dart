import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';

void main() {
  group('AppColors Culinary Tokens Tests', () {
    test('culinary gradients have correct stops, colors and alignments', () {
      // Primary Gradient
      expect(AppColors.primaryGradient.colors, const [
        Color(0xFFFF833A),
        Color(0xFFE65100),
      ]);
      expect(AppColors.primaryGradient.begin, Alignment.topLeft);
      expect(AppColors.primaryGradient.end, Alignment.bottomRight);

      // Hero Overlay Gradient
      expect(AppColors.heroOverlayGradient.colors, const [
        Colors.transparent,
        Color(0xCC000000),
      ]);
      expect(AppColors.heroOverlayGradient.begin, Alignment.topCenter);
      expect(AppColors.heroOverlayGradient.end, Alignment.bottomCenter);

      // Warm Card Gradient
      expect(AppColors.warmCardGradient.colors, const [
        Color(0xFFFFF8F1),
        Color(0xFFFFFFFF),
      ]);
      expect(AppColors.warmCardGradient.begin, Alignment.topCenter);
      expect(AppColors.warmCardGradient.end, Alignment.bottomCenter);
    });

    test('culinary card shadows have correct elevation metrics', () {
      // Culinary Card Shadow
      expect(AppColors.culinaryCardShadow.color, const Color(0x0F000000));
      expect(AppColors.culinaryCardShadow.blurRadius, 16);
      expect(AppColors.culinaryCardShadow.offset, const Offset(0, 6));

      // Glowing Orange Shadow
      expect(AppColors.glowingOrangeShadow.color, const Color(0x33E65100));
      expect(AppColors.glowingOrangeShadow.blurRadius, 12);
      expect(AppColors.glowingOrangeShadow.offset, const Offset(0, 4));
    });

    test('culinary semantic tokens match design specification', () {
      expect(AppColors.ratingStar, const Color(0xFFFFB300));
      expect(AppColors.calorieBadge, const Color(0xFFFFF3E0));
      expect(AppColors.calorieText, const Color(0xFFE65100));
      expect(AppColors.prepTimeTag, const Color(0xFFE8F5E9));
      expect(AppColors.prepTimeText, const Color(0xFF2E7D32));
      expect(AppColors.difficultyEasy, const Color(0xFF2E7D32));
      expect(AppColors.difficultyMedium, const Color(0xFFFFA000));
      expect(AppColors.difficultyHard, const Color(0xFFD32F2F));
    });
  });
}
