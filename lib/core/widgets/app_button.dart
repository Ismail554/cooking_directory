import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';

/// Primary design system button with loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 48.h;

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: effectiveHeight,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: backgroundColor ?? AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r12),
          ),
          child: _buildChild(context, isOutlined: true),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: effectiveHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? AppColors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r12),
          elevation: AppElevation.e0,
        ),
        child: _buildChild(context, isOutlined: false),
      ),
    );
  }

  Widget _buildChild(BuildContext context, {required bool isOutlined}) {
    if (isLoading) {
      return SizedBox(
        height: 20.r,
        width: 20.r,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: isOutlined ? AppColors.primary : Colors.white,
        ),
      );
    }

    final textColor = isOutlined
        ? (foregroundColor ?? AppColors.primary)
        : (foregroundColor ?? AppColors.onPrimary);

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppIconSize.s18, color: textColor),
          AppSpacing.gapW8,
          Text(
            text,
            style: getSemiBoldStyle(
              fontSize: FontSize.s15,
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: getSemiBoldStyle(
        fontSize: FontSize.s15,
        color: textColor,
      ),
    );
  }
}
