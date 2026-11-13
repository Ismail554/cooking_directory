import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/asset_manager.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';
import 'package:cooking_directory/core/routing/route_paths.dart';
import 'package:cooking_directory/core/widgets/recipe_image_view.dart';

/// Compact culinary card for recipe grids and discovery lists.
class RecipeGridCard extends StatelessWidget {
  final String recipeId, title, prepTime, imageAsset;
  final int calories;
  final double rating;
  final VoidCallback? onTap;

  const RecipeGridCard({
    super.key,
    this.recipeId = 'recipe_002',
    this.title = 'Classic Beef Bolognese',
    this.prepTime = '20 min',
    this.calories = 550,
    this.rating = 4.8,
    this.imageAsset = AssetManager.recipePlaceholder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppBorderRadius.r16,
        boxShadow: const [AppColors.culinaryCardShadow],
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight.withValues(alpha: 0.6),
          width: 1.w,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => context.push(AppRoutePaths.recipeDetails),
          borderRadius: AppBorderRadius.r16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: Stack(
                  children: [
                    RecipeImageView(
                      imageSource: imageAsset,
                      fallbackAsset: AssetManager.recipePlaceholder,
                      height: 105.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: AppBorderRadius.r12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, size: AppIconSize.s14, color: AppColors.ratingStar),
                            AppSpacing.gapW2,
                            Flexible(
                              child: Text(
                                rating.toStringAsFixed(1),
                                style: getBoldStyle(fontSize: FontSize.s10, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: getBoldStyle(context: context, fontSize: FontSize.s13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.gapH8,
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.calorieBadge,
                            borderRadius: AppBorderRadius.r4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_fire_department_rounded, size: AppIconSize.s14, color: AppColors.calorieText),
                              AppSpacing.gapW2,
                              Flexible(
                                child: Text('$calories kcal', style: getBoldStyle(fontSize: FontSize.s11, color: AppColors.calorieText)),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.gapW8,
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: AppIconSize.s14,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                              AppSpacing.gapW2,
                              Flexible(
                                child: Text(
                                  prepTime,
                                  style: getRegularStyle(
                                    context: context,
                                    fontSize: FontSize.s11,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
