import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/asset_manager.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';

/// Gastronomic header displaying chef greeting, subtitle, and branded avatar.
class HomeHeader extends StatelessWidget {
  final String greeting;
  final String subtitle;
  final String avatarAsset;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;

  const HomeHeader({
    super.key,
    this.greeting = 'Hello, Chef Ismail',
    this.subtitle = 'What are we cooking today?',
    this.avatarAsset = AssetManager.userAvatar,
    this.onAvatarTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(3.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).cardColor,
            boxShadow: const [AppColors.culinaryCardShadow],
          ),
          child: ClipOval(
            child: Image.asset(
              AssetManager.appLogo,
              width: 36.r,
              height: 36.r,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.restaurant_menu,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        AppSpacing.gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                greeting,
                style: getBoldStyle(
                  context: context,
                  fontSize: FontSize.s20,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.gapH4,
              Text(
                subtitle,
                style: getMediumStyle(
                  context: context,
                  fontSize: FontSize.s13,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        AppSpacing.gapW12,
        if (onNotificationTap != null) ...[
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: onNotificationTap,
            tooltip: 'Notifications',
          ),
          AppSpacing.gapW4,
        ],
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            padding: EdgeInsets.all(2.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 1.5.w,
              ),
              boxShadow: const [AppColors.culinaryCardShadow],
            ),
            child: CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColors.primaryContainer,
              backgroundImage: AssetImage(avatarAsset),
              onBackgroundImageError: (exception, stackTrace) {},
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}
