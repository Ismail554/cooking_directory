import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label = 'Sign in with Google',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r12),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.2,
        ),
        backgroundColor: isDark ? AppColors.surfaceVariantDark : Colors.white,
      ),
      onPressed: isLoading ? null : onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24.r,
            height: 24.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white : AppColors.primary.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: Text(
              'G',
              style: getBoldStyle(
                fontSize: FontSize.s14,
                color: AppColors.primary,
              ),
            ),
          ),
          AppSpacing.gapW12,
          Text(
            label,
            style: getSemiBoldStyle(
              fontSize: FontSize.s14,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
