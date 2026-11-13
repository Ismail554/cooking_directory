import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/asset_manager.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';

class AppBrandingCard extends StatelessWidget {
  const AppBrandingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: BoxConstraints(minHeight: 84.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppBorderRadius.r16,
        image: const DecorationImage(
          image: AssetImage(AssetManager.splashBackground),
          fit: BoxFit.cover,
          opacity: 0.28,
        ),
        boxShadow: const [AppColors.culinaryCardShadow],
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppBorderRadius.r12,
            child: Image.asset(
              AssetManager.appLogo,
              width: 48.r,
              height: 48.r,
              fit: BoxFit.cover,
            ),
          ),
          AppSpacing.gapW16,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Cooking Directory',
                  style: getBoldStyle(context: context, fontSize: FontSize.s16),
                ),
                AppSpacing.gapH2,
                Text(
                  'v1.0.0 • Artisan Culinary Suite',
                  style: getRegularStyle(
                    context: context,
                    fontSize: FontSize.s12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
