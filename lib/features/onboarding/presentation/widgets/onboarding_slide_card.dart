import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';

class OnboardingSlideData {
  final String badge;
  final String title;
  final String description;
  final String svgAsset;
  final IconData fallbackIcon;
  final Color accentColor;

  const OnboardingSlideData({
    required this.badge,
    required this.title,
    required this.description,
    required this.svgAsset,
    required this.fallbackIcon,
    required this.accentColor,
  });
}

class OnboardingSlideCard extends StatelessWidget {
  final OnboardingSlideData data;

  const OnboardingSlideCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180.r,
            height: 180.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.accentColor.withValues(alpha: isDark ? 0.18 : 0.12),
              border: Border.all(
                color: data.accentColor.withValues(alpha: 0.35),
                width: 2.w,
              ),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              data.svgAsset,
              width: 88.r,
              height: 88.r,
              placeholderBuilder: (_) => Icon(
                data.fallbackIcon,
                size: 72.r,
                color: data.accentColor,
              ),
            ),
          ),
          AppSpacing.gapH32,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: data.accentColor.withValues(alpha: 0.15),
              borderRadius: AppBorderRadius.circular,
            ),
            child: Text(
              data.badge.toUpperCase(),
              style: getBoldStyle(
                fontSize: FontSize.s11,
                color: data.accentColor,
                letterSpacing: 1.1,
              ),
            ),
          ),
          AppSpacing.gapH16,
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: getBoldStyle(
              context: context,
              fontSize: FontSize.s24,
            ),
          ),
          AppSpacing.gapH12,
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: getRegularStyle(
              context: context,
              fontSize: FontSize.s14,
              color: secColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
