import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/asset_manager.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';

/// Delightful culinary loading animation widget with clean fallback.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({
    super.key,
    this.message,
    this.color,
    this.size,
    this.useLottie = true,
  });

  final String? message;
  final Color? color;
  final double? size;
  final bool useLottie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final effectiveSize = size ?? 100.w;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (useLottie)
            SizedBox(
              width: effectiveSize,
              height: effectiveSize,
              child: Lottie.asset(
                AssetManager.lottieLoading,
                width: effectiveSize,
                height: effectiveSize,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallback(context, effectiveColor, effectiveSize),
              ),
            )
          else
            _buildFallback(context, effectiveColor, effectiveSize),
          if (message != null) ...[
            AppSpacing.gapH16,
            Text(
              message!,
              textAlign: TextAlign.center,
              style: getMediumStyle(
                context: context,
                fontSize: FontSize.s14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFallback(
    BuildContext context,
    Color indicatorColor,
    double effectiveSize,
  ) {
    final spinnerSize = (effectiveSize * 0.45).clamp(24.0, 48.0);
    return SizedBox(
      width: spinnerSize,
      height: spinnerSize,
      child: CircularProgressIndicator(
        color: indicatorColor,
        strokeWidth: 3.0,
      ),
    );
  }
}
