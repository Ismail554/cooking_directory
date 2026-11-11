import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/asset_manager.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';
import 'package:cooking_directory/core/widgets/custom_snackbar.dart';

import '../widgets/export_recipes_tile.dart';
import '../widgets/preference_dialogs.dart';
import '../widgets/profile_header.dart';

/// Chef profile screen with preferences, theming, currency & budget, and data export.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> _dietaryPreferences = ['Halal', 'Gluten-Free'];
  String _currency = 'USD (\$)';
  double _monthlyBudget = 1200.0;
  bool _isDarkMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chef Profile', style: getBoldStyle(context: context, fontSize: FontSize.s18)),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            const ProfileHeader(),
            AppSpacing.gapH24,
            _buildSectionHeader('Preferences'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
              title: Text('Dark Mode', style: getMediumStyle(context: context, fontSize: FontSize.s14)),
              subtitle: Text(
                _isDarkMode ? 'Dark theme active' : 'Light theme active',
                style: getRegularStyle(context: context, fontSize: FontSize.s12, color: AppColors.textSecondaryLight),
              ),
              value: _isDarkMode,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => setState(() => _isDarkMode = val),
            ),
            _buildActionTile(
              icon: Icons.restaurant_outlined,
              iconColor: AppColors.secondary,
              title: 'Dietary Preferences',
              subtitle: _dietaryPreferences.isEmpty ? 'None selected' : _dietaryPreferences.join(', '),
              onTap: _openDietaryDialog,
            ),
            _buildActionTile(
              icon: Icons.attach_money_rounded,
              iconColor: AppColors.accent,
              title: 'Currency & Budget',
              subtitle: '$_currency • \$${_monthlyBudget.toStringAsFixed(0)} limit',
              onTap: _openCurrencyBudgetDialog,
            ),
            AppSpacing.gapH16,
            _buildSectionHeader('Data & Backup'),
            const ExportRecipesTile(),
            AppSpacing.gapH16,
            _buildSectionHeader('Account'),
            _buildActionTile(
              icon: Icons.logout_rounded,
              iconColor: AppColors.error,
              title: 'Sign Out',
              subtitle: 'End current session and lock recipe vault',
              textColor: AppColors.error,
              onTap: _confirmSignOut,
            ),
            AppSpacing.gapH24,
            _buildAppBrandingCard(context),
            AppSpacing.gapH16,
          ],
        ),
      ),
    );
  }

  Widget _buildAppBrandingCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 96.h,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppBorderRadius.r16,
        image: const DecorationImage(
          image: AssetImage(AssetManager.splashBackground),
          fit: BoxFit.cover,
          opacity: 0.28,
        ),
        boxShadow: const [AppColors.culinaryCardShadow],
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppBorderRadius.r12,
            child: Image.asset(AssetManager.appLogo, width: 48.r, height: 48.r, fit: BoxFit.contain),
          ),
          AppSpacing.gapW16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Cooking Directory', style: getBoldStyle(context: context, fontSize: FontSize.s16)),
                AppSpacing.gapH2,
                Text('v1.0.0 • Artisan Culinary Suite', style: getRegularStyle(context: context, fontSize: FontSize.s12, color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title.toUpperCase(), style: getBoldStyle(fontSize: FontSize.s11, color: AppColors.primary, letterSpacing: 1.1)),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: getMediumStyle(context: context, fontSize: FontSize.s14, color: textColor)),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: getRegularStyle(context: context, fontSize: FontSize.s12, color: AppColors.textSecondaryLight)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }

  void _openDietaryDialog() {
    PreferenceDialogs.showDietaryPreferencesDialog(context, selectedOptions: _dietaryPreferences, onSave: (updated) {
      setState(() => _dietaryPreferences = updated);
      CustomSnackbar.showSuccess(context, 'Dietary preferences updated');
    });
  }

  void _openCurrencyBudgetDialog() {
    PreferenceDialogs.showCurrencyBudgetDialog(context, currentCurrency: _currency, currentBudget: _monthlyBudget, onSave: (currency, budget) {
      setState(() { _currency = currency; _monthlyBudget = budget; });
      CustomSnackbar.showSuccess(context, 'Budget preferences saved');
    });
  }

  void _confirmSignOut() {
    PreferenceDialogs.showSignOutDialog(context, onConfirm: () => CustomSnackbar.show(context, message: 'Signed out successfully'));
  }
}
