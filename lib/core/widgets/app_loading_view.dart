import 'package:flutter/material.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';

/// Reusable loading indicator widget.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({
    super.key,
    this.message,
    this.color,
  });

  final String? message;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: color ?? AppColors.primary,
            strokeWidth: 3.0,
          ),
          if (message != null) ...[
            AppSpacing.gapH16,
            Text(
              message!,
              style: getMediumStyle(
                fontSize: FontSize.s14,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
