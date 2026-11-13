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

/// Gastronomic hero card showcasing the featured recipe of the day.
class FeaturedRecipeCard extends StatefulWidget {
  final String recipeId, title, description, prepTime, difficulty, imageAsset;
  final double rating;
  final int reviewCount;
  final bool isFavorite;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onFavoriteToggle;

  const FeaturedRecipeCard({
    super.key,
    this.recipeId = 'recipe_001',
    this.title = 'Creamy Tuscan Garlic Chicken',
    this.description = 'Pan-seared chicken cutlets bathed in rich garlic sun-dried tomato sauce.',
    this.prepTime = '25 min',
    this.difficulty = 'Medium',
    this.rating = 4.9,
    this.reviewCount = 128,
    this.imageAsset = AssetManager.recipePlaceholder,
    this.isFavorite = true,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  State<FeaturedRecipeCard> createState() => _FeaturedRecipeCardState();
}

class _FeaturedRecipeCardState extends State<FeaturedRecipeCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(FeaturedRecipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) _isFavorite = widget.isFavorite;
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    widget.onFavoriteToggle?.call(_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220.h,
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.r20,
        boxShadow: const [AppColors.culinaryCardShadow],
      ),
      child: ClipRRect(
        borderRadius: AppBorderRadius.r20,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RecipeImageView(
              imageSource: widget.imageAsset,
              fallbackAsset: AssetManager.recipePlaceholder,
              fit: BoxFit.cover,
            ),
            const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.heroOverlayGradient)),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap ?? () {
                  try { context.push(AppRoutePaths.recipeDetails); } catch (_) {}
                },
              ),
            ),
            Positioned(
              left: 14.w,
              right: 14.w,
              bottom: 14.h,
              child: IgnorePointer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      children: [
                        _buildBadge(AppColors.prepTimeTag, Icons.schedule_rounded, widget.prepTime, AppColors.prepTimeText),
                        _buildBadge(AppColors.difficultyMedium.withValues(alpha: 0.25), Icons.restaurant_rounded, widget.difficulty, AppColors.difficultyMedium),
                      ],
                    ),
                    AppSpacing.gapH8,
                    Text(widget.title, style: getBoldStyle(fontSize: FontSize.s18, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                    AppSpacing.gapH4,
                    Text(widget.description, style: getRegularStyle(fontSize: FontSize.s12, color: Colors.white.withValues(alpha: 0.85)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12.h,
              left: 14.w,
              right: 14.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IgnorePointer(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: AppBorderRadius.r12),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.star_rounded, size: AppIconSize.s16, color: AppColors.ratingStar),
                        AppSpacing.gapW4,
                        Flexible(child: Text('${widget.rating} (${widget.reviewCount})', style: getBoldStyle(fontSize: FontSize.s12, color: Colors.white))),
                      ]),
                    ),
                  ),
                  InkWell(
                    onTap: _toggleFavorite,
                    borderRadius: AppBorderRadius.circular,
                    child: Container(
                      padding: EdgeInsets.all(7.r),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), shape: BoxShape.circle),
                      child: Icon(
                        _isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: _isFavorite ? AppColors.accent : Colors.white,
                        size: AppIconSize.s20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(Color bg, IconData icon, String text, Color fg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(color: bg, borderRadius: AppBorderRadius.r8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSize.s14, color: fg),
          AppSpacing.gapW4,
          Flexible(child: Text(text, style: getBoldStyle(fontSize: FontSize.s11, color: fg))),
        ],
      ),
    );
  }
}
