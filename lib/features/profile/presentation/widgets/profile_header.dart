import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/asset_manager.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';

/// Clean, overflow-safe chef profile header card with branded avatar and badges.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    this.name = 'Chef Ismail',
    this.email = 'ismail@example.com',
    this.role = 'Executive Chef',
    this.badgeText = 'PRO',
    this.photoUrl,
    this.onTap,
  });

  final String name;
  final String email;
  final String role;
  final String badgeText;
  final String? photoUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.r16,
      child: Container(
        padding: AppSpacing.paddingAll16,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppBorderRadius.r16,
          boxShadow: const [AppColors.culinaryCardShadow],
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 2.w),
              ),
              child: CircleAvatar(
                radius: 34.r,
                backgroundColor: AppColors.primaryContainer,
                backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
                    ? NetworkImage(photoUrl!) as ImageProvider
                    : const AssetImage(AssetManager.userAvatar),
                onBackgroundImageError: (error, stack) {},
              ),
            ),
            AppSpacing.gapW16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: getBoldStyle(
                            context: context,
                            fontSize: FontSize.s18,
                          ),
                        ),
                      ),
                      AppSpacing.gapW8,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: AppBorderRadius.r8,
                        ),
                        child: Text(
                          badgeText,
                          style: getBoldStyle(
                            fontSize: FontSize.s10,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapH4,
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getRegularStyle(
                      context: context,
                      fontSize: FontSize.s13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  AppSpacing.gapH4,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariantLight,
                      borderRadius: AppBorderRadius.r12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AssetManager.svgChefHat,
                          width: 14.r,
                          height: 14.r,
                        ),
                        AppSpacing.gapW4,
                        Flexible(
                          child: Text(
                            role,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: getMediumStyle(
                              fontSize: FontSize.s11,
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
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
}
