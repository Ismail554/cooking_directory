import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/managers/value_manager.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/widgets/auth_dialog.dart';
import '../widgets/app_branding_card.dart';
import '../widgets/export_recipes_tile.dart';
import '../widgets/import_recipes_tile.dart';
import '../widgets/preference_dialogs.dart';
import '../widgets/profile_header.dart';

/// Chef profile screen with preferences, theming, currency, data import/export, and auth.
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
    final auth = context.watch<AuthProvider?>();
    final user = auth?.currentUser;
    final isAuth = auth?.isAuthenticated ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chef Profile', style: getBoldStyle(context: context, fontSize: FontSize.s18)),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            ProfileHeader(
              name: (user?.displayName != null && user!.displayName!.isNotEmpty)
                  ? user.displayName!
                  : 'Chef Ismail',
              email: (user?.email != null && user!.email!.isNotEmpty)
                  ? user.email!
                  : 'ismail@example.com',
              photoUrl: user?.photoUrl,
            ),
            AppSpacing.gapH20,
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
            const ImportRecipesTile(),
            const ExportRecipesTile(),
            AppSpacing.gapH16,
            _buildSectionHeader('Account'),
            if (!isAuth)
              _buildActionTile(
                icon: Icons.login_rounded,
                iconColor: AppColors.primary,
                title: 'Sign In / Register',
                subtitle: 'Sync recipes and cloud storage via Firebase',
                onTap: () => AuthDialog.show(context),
              ),
            _buildActionTile(
              icon: Icons.logout_rounded,
              iconColor: AppColors.error,
              title: 'Sign Out',
              subtitle: isAuth
                  ? 'Signed in as ${user?.email ?? "Chef"}'
                  : 'End current session and lock recipe vault',
              textColor: AppColors.error,
              onTap: () => _confirmSignOut(auth),
            ),
            AppSpacing.gapH24,
            const AppBrandingCard(),
            AppSpacing.gapH16,
          ],
        ),
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

  void _confirmSignOut(AuthProvider? auth) {
    PreferenceDialogs.showSignOutDialog(context, onConfirm: () async {
      await auth?.signOut();
      if (mounted) CustomSnackbar.show(context, message: 'Signed out successfully');
    });
  }
}
