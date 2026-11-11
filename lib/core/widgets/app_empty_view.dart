import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/asset_manager.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';
import 'package:cooking_directory/core/widgets/app_button.dart';

/// Reusable empty-state display widget supporting illustrations and icons.
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.title,
    this.message,
    this.illustrationPath,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final String? illustrationPath;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildVisual(context),
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
            if (message != null) ...[
              AppSpacing.gapH8,
              Text(
                message!,
                textAlign: TextAlign.center,
                style: getRegularStyle(
                  context: context,
                  fontSize: FontSize.s14,
                  color: onSurfaceVariant,
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

  Widget _buildVisual(BuildContext context) {
    if (icon != null && illustrationPath == null) {
      return _buildIconBadge(context, icon!);
    }

    final targetPath = illustrationPath ?? AssetManager.emptyStateIllustration;
    if (targetPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        targetPath,
        width: 140.w,
        height: 140.h,
        placeholderBuilder: (_) => _buildIconBadge(
          context,
          icon ?? Icons.soup_kitchen_outlined,
        ),
      );
    }

    return Image.asset(
      targetPath,
      width: 140.w,
      height: 140.h,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _buildIconBadge(
        context,
        icon ?? Icons.soup_kitchen_outlined,
      ),
    );
  }

  Widget _buildIconBadge(BuildContext context, IconData iconData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: AppIconSize.s48,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
