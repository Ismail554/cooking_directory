import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

/// Displays email verification status and Send Link / Refresh controls.
class EmailVerificationBanner extends StatelessWidget {
  const EmailVerificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider?>();
    if (auth == null || !auth.isAuthenticated) return const SizedBox.shrink();

    final verified = auth.isEmailVerified;
    final color = verified ? AppColors.secondary : AppColors.warning;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.r12,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(verified ? Icons.verified_rounded : Icons.mark_email_unread_outlined, size: 16.r, color: color),
          AppSpacing.gapW8,
          Expanded(
            child: Text(
              verified ? 'Email Verified' : 'Email Not Verified',
              style: getSemiBoldStyle(fontSize: FontSize.s12, color: color),
            ),
          ),
          if (!verified) ...[
            TextButton(
              onPressed: auth.isLoading ? null : () async {
                final ok = await auth.sendEmailVerification();
                if (!context.mounted) return;
                ok
                    ? CustomSnackbar.showSuccess(context, 'Verification link sent to your email.')
                    : CustomSnackbar.showError(context, auth.errorMessage ?? 'Could not send link.');
              },
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: Text('Send Link', style: getBoldStyle(fontSize: FontSize.s11, color: AppColors.primary)),
            ),
            TextButton(
              onPressed: auth.isLoading ? null : () async {
                final isNowVerified = await auth.reloadUser();
                if (!context.mounted) return;
                isNowVerified
                    ? CustomSnackbar.showSuccess(context, 'Email verified!')
                    : CustomSnackbar.showError(context, 'Still unverified. Check your inbox.');
              },
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: Text('Refresh', style: getBoldStyle(fontSize: FontSize.s11, color: color)),
            ),
          ],
        ],
      ),
    );
  }
}

