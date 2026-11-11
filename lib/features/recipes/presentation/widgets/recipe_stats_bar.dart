import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';

/// Horizontal stats summary bar displaying prep time, cook time, calories,
/// rating, and difficulty badge using centralized culinary design tokens.
class RecipeStatsBar extends StatelessWidget {
  const RecipeStatsBar({
    super.key,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.calories,
    required this.rating,
    required this.difficulty,
  });

  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int calories;
  final double rating;
  final String difficulty;

  Color _resolveDifficultyColor() {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.difficultyEasy;
      case 'hard':
        return AppColors.difficultyHard;
      case 'medium':
      default:
        return AppColors.difficultyMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final diffColor = _resolveDifficultyColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppBorderRadius.r16,
        boxShadow: const [AppColors.culinaryCardShadow],
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(
            context,
            icon: Icons.timer_outlined,
            iconColor: AppColors.prepTimeText,
            bgColor: AppColors.prepTimeTag,
            label: '$prepTimeMinutes m',
            subLabel: 'Prep',
          ),
          _buildDivider(isDark),
          _buildItem(
            context,
            icon: Icons.restaurant_rounded,
            iconColor: AppColors.primary,
            bgColor: AppColors.primaryContainer,
            label: '$cookTimeMinutes m',
            subLabel: 'Cook',
          ),
          _buildDivider(isDark),
          _buildItem(
            context,
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.calorieText,
            bgColor: AppColors.calorieBadge,
            label: '$calories',
            subLabel: 'kcal',
          ),
          _buildDivider(isDark),
          _buildItem(
            context,
            icon: Icons.star_rounded,
            iconColor: AppColors.ratingStar,
            bgColor: AppColors.ratingStar.withValues(alpha: 0.18),
            label: rating.toStringAsFixed(1),
            subLabel: 'Rating',
          ),
          _buildDivider(isDark),
          _buildItem(
            context,
            icon: Icons.speed_rounded,
            iconColor: diffColor,
            bgColor: diffColor.withValues(alpha: 0.16),
            label: difficulty,
            subLabel: 'Level',
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1.w,
      height: 28.h,
      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String subLabel,
  }) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(5.r),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: AppIconSize.s16, color: iconColor),
          ),
          AppSpacing.gapH4,
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: getBoldStyle(
              context: context,
              fontSize: FontSize.s13,
            ),
          ),
          Text(
            subLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: getRegularStyle(
              context: context,
              fontSize: FontSize.s11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
