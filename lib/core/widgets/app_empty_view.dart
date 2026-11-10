import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';
import 'package:cooking_directory/core/widgets/app_button.dart';

/// Reusable empty-state display widget.
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.soup_kitchen_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

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
              decoration: BoxDecoration(
                color: AppColors.surfaceVariantLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppIconSize.s48,
                color: AppColors.textSecondaryLight,
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
            if (message != null) ...[
              AppSpacing.gapH8,
              Text(
                message!,
                textAlign: TextAlign.center,
                style: getRegularStyle(
                  fontSize: FontSize.s14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.gapH24,
              SizedBox(
                width: 180.w,
                child: AppButton(
                  text: actionLabel!,
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
