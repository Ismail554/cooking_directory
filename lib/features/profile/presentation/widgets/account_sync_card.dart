import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';
import '../../../../core/sync/account_sync_provider.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../recipes/presentation/providers/recipe_provider.dart';
import 'email_verification_banner.dart';

/// User control card for Firebase Realtime Database & Account Synchronization.
class AccountSyncCard extends StatefulWidget {
  const AccountSyncCard({super.key});

  @override
  State<AccountSyncCard> createState() => _AccountSyncCardState();
}

class _AccountSyncCardState extends State<AccountSyncCard> {
  bool _fallbackRealtimeEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final sync = context.watch<AccountSyncProvider?>();
    final auth = context.watch<AuthProvider?>();
    final recipesCount = context.watch<RecipeProvider?>()?.allRecipes.length ?? 0;
    final expensesCount = context.watch<ExpenseProvider?>()?.allExpenses.length ?? 0;

    final isAuth = auth?.isAuthenticated ?? sync?.isAuthenticated ?? false;
    final isLive = sync?.isRealtimeSyncEnabled ?? _fallbackRealtimeEnabled;
    final isSyncing = sync?.isSyncing ?? false;
    final statusMsg = sync?.statusMessage ??
        (isLive ? 'Realtime DB Live Sync Active' : 'Realtime Sync Paused by User');
    final badgeColor = isLive ? AppColors.secondary : AppColors.warning;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceLight)
            .withValues(alpha: 0.92),
        borderRadius: AppBorderRadius.r16,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EmailVerificationBanner(),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: AppBorderRadius.r12,
                ),
                child: Icon(
                  isLive ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                  size: 20.r,
                  color: AppColors.primary,
                ),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Realtime DB & Account Sync',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getBoldStyle(context: context, fontSize: FontSize.s14),
                    ),
                    AppSpacing.gapH2,
                    Text(
                      '$statusMsg • $recipesCount recipes, $expensesCount expenses',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getRegularStyle(
                        context: context,
                        fontSize: FontSize.s11,
                        color: secColor,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapW8,
              InkWell(
                key: const Key('rtdb_live_toggle'),
                borderRadius: AppBorderRadius.r20,
                onTap: () async {
                  final next = !isLive;
                  if (sync != null) {
                    await sync.setRealtimeSyncEnabled(next);
                  } else {
                    setState(() => _fallbackRealtimeEnabled = next);
                  }
                  if (!context.mounted) return;
                  CustomSnackbar.showSuccess(
                    context,
                    next
                        ? 'Realtime DB live sync enabled'
                        : 'Realtime DB live sync paused (manual mode)',
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.16),
                    borderRadius: AppBorderRadius.r20,
                    border: Border.all(color: badgeColor.withValues(alpha: 0.45)),
                  ),
                  child: Text(
                    isLive ? 'LIVE ON' : 'PAUSED',
                    style: getBoldStyle(fontSize: FontSize.s10, color: badgeColor),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapH12,
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              _buildActionChip(
                icon: isSyncing ? Icons.sync_rounded : Icons.cloud_sync_rounded,
                label: isSyncing ? 'Syncing...' : 'Sync Account Now',
                onTap: isSyncing ? null : () async {
                  await sync?.syncAccountNow();
                  if (!context.mounted) return;
                  if (sync?.lastSyncSucceeded == false) {
                    CustomSnackbar.showError(context, sync?.syncError ?? 'Sync failed. Saved locally.');
                  } else {
                    CustomSnackbar.showSuccess(context, isAuth ? 'Account synced with Realtime DB' : 'Local vault synchronized');
                  }
                },
              ),
              _buildActionChip(
                icon: Icons.cloud_upload_outlined,
                label: 'Push to Cloud',
                onTap: isSyncing ? null : () async {
                  await sync?.pushLocalVaultToCloud();
                  if (!context.mounted) return;
                  if (sync?.lastSyncSucceeded == false) {
                    CustomSnackbar.showError(context, sync?.syncError ?? 'Push failed. Saved locally.');
                  } else {
                    CustomSnackbar.showSuccess(context, 'Local recipes & expenses pushed to Realtime DB');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.r12,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: AppBorderRadius.r12,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.r, color: AppColors.primary),
            AppSpacing.gapW4,
            Text(
              label,
              style: getSemiBoldStyle(fontSize: FontSize.s11, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

