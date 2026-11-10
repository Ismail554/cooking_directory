import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';
import 'package:cooking_directory/core/widgets/app_button.dart';

/// Reusable error state display widget with retry callback.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.title = 'Oops!',
    this.onRetry,
    this.retryLabel = 'Try Again',
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: const BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: AppIconSize.s48,
                color: AppColors.error,
              ),
            ),
            AppSpacing.gapH16,
            Text(
              title,
              textAlign: TextAlign.center,
              style: getBoldStyle(
                fontSize: FontSize.s18,
                color: AppColors.textPrimaryLight,
              ),
            ),
            AppSpacing.gapH8,
            Text(
              message,
              textAlign: TextAlign.center,
              style: getRegularStyle(
                fontSize: FontSize.s14,
                color: AppColors.textSecondaryLight,
              ),
            ),
            if (onRetry != null) ...[
              AppSpacing.gapH24,
              SizedBox(
                width: 160.w,
                child: AppButton(
                  text: retryLabel,
                  onPressed: onRetry,
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
