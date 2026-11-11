import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';

/// Horizontal culinary category chips with smooth selection and gradients.
class HomeCategoryPills extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String>? onCategorySelected;

  static const List<String> defaultCategories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Desserts',
    'Healthy',
  ];

  static const Map<String, String> categoryEmojis = {
    'All': '🍳',
    'Breakfast': '🥞',
    'Lunch': '🥗',
    'Dinner': '🍲',
    'Desserts': '🍰',
    'Healthy': '🥑',
  };

  const HomeCategoryPills({
    super.key,
    this.categories = defaultCategories,
    this.selectedCategory = 'All',
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 42.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => AppSpacing.gapW8,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          final emoji = categoryEmojis[category] ?? '🍽️';

          return InkWell(
            onTap: () => onCategorySelected?.call(category),
            borderRadius: AppBorderRadius.r24,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected
                    ? null
                    : (isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight),
                borderRadius: AppBorderRadius.r24,
                boxShadow: isSelected
                    ? const [AppColors.glowingOrangeShadow]
                    : null,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight),
                  width: 1.w,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    emoji,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  AppSpacing.gapW4,
                  Flexible(
                    child: Text(
                      category,
                      style: isSelected
                          ? getBoldStyle(
                              fontSize: FontSize.s13,
                              color: Colors.white,
                            )
                          : getMediumStyle(
                              context: context,
                              fontSize: FontSize.s13,
                            ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
