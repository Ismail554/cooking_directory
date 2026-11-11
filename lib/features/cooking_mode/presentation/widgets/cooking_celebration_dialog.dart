import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/asset_manager.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';
import 'package:cooking_directory/core/widgets/app_button.dart';

/// Celebratory completion dialog featuring animated cooking Lottie.
class CookingCelebrationDialog extends StatelessWidget {
  const CookingCelebrationDialog({super.key, this.title});
  final String? title;

  static Future<void> show(BuildContext context, {String? title}) {
    return showDialog(
      context: context,
      builder: (ctx) => CookingCelebrationDialog(title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r20),
      icon: SizedBox(
        width: 100.w,
        height: 100.h,
        child: Lottie.asset(
          AssetManager.lottieCooking,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Icon(
            Icons.celebration_rounded,
            color: AppColors.primary,
            size: 48,
          ),
        ),
      ),
      title: Text(
        'Bon Appétit! 🎉',
        style: getBoldStyle(context: context, fontSize: FontSize.s20),
      ),
      content: Text(
        'You completed "${title ?? 'your recipe'}". Enjoy your meal!',
        textAlign: TextAlign.center,
        style: getRegularStyle(context: context, fontSize: FontSize.s14),
      ),
      actions: [
        AppButton(
          text: 'Finish & Return',
          onPressed: () {
            Navigator.of(context).pop();
            context.pop();
          },
        ),
      ],
    );
  }
}
