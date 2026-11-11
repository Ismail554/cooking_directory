import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';
import 'package:cooking_directory/core/widgets/app_button.dart';

/// Reusable error state display widget with theme-aware styling and retry callback.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.title = 'Oops!',
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.icon = Icons.error_outline_rounded,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final errorColor = theme.colorScheme.error;
    final errorContainer = theme.colorScheme.errorContainer;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppIconSize.s48,
                color: errorColor,
              ),
            ),
            AppSpacing.gapH16,
            Text(
              title,
              textAlign: TextAlign.center,
              style: getBoldStyle(
                context: context,
                fontSize: FontSize.s18,
                color: onSurface,
              ),
            ),
            AppSpacing.gapH8,
            Text(
              message,
              textAlign: TextAlign.center,
              style: getRegularStyle(
                context: context,
                fontSize: FontSize.s14,
                color: onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              AppSpacing.gapH24,
              SizedBox(
                width: 160.w,
                child: AppButton(
                  text: retryLabel,
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
