import 'package:flutter/material.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';

enum SnackbarType { success, error, warning, info }

/// Reusable snackbar manager.
/// Enforces consistent theme colors and prevents duplicate snackbars.
abstract final class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final backgroundColor = switch (type) {
      SnackbarType.success => AppColors.success,
      SnackbarType.error => AppColors.error,
      SnackbarType.warning => AppColors.warning,
      SnackbarType.info => AppColors.info,
    };

    final icon = switch (type) {
      SnackbarType.success => Icons.check_circle_outline,
      SnackbarType.error => Icons.error_outline,
      SnackbarType.warning => Icons.warning_amber_rounded,
      SnackbarType.info => Icons.info_outline,
    };

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: AppIconSize.s20),
            AppSpacing.gapW12,
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r12),
        margin: AppSpacing.paddingAll16,
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) =>
      show(context, message: message, type: SnackbarType.success);

  static void showError(BuildContext context, String message) =>
      show(context, message: message, type: SnackbarType.error);
}
