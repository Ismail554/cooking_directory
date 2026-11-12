import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/managers/app_colors.dart';
import '../../../../core/managers/font_manager.dart';
import '../../../../core/managers/style_manager.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/widgets/auth_dialog.dart';
import '../../../recipes/presentation/providers/recipe_provider.dart';
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
  List<String> _fallbackDietary = ['Halal', 'Gluten-Free'];
  String _fallbackCurrency = 'USD (\$)';
  double _fallbackBudget = 1200.0;
  bool? _fallbackDarkOverride;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider?>();
    final themeProvider = context.watch<ThemeProvider?>();
    final user = auth?.currentUser;
    final isAuth = auth?.isAuthenticated ?? false;
    final isDark = themeProvider != null
        ? themeProvider.isDarkActive(context)
        : (_fallbackDarkOverride ?? (Theme.of(context).brightness == Brightness.dark));
    final secColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primaryTone = isDark ? AppColors.primaryLight : AppColors.primary;

    final dietary = themeProvider?.dietaryPreferences ?? _fallbackDietary;
    final currency = themeProvider?.currency ?? _fallbackCurrency;
    final budget = themeProvider?.monthlyBudget ?? _fallbackBudget;
    final sym = themeProvider?.currencySymbol ?? '\$';

    final resolvedName = isAuth
        ? ((user?.displayName != null && user!.displayName!.isNotEmpty)
            ? user.displayName!
            : (user?.email?.split('@').first ?? 'Chef'))
        : 'Guest Chef';
    final resolvedEmail = isAuth
        ? (user?.email ?? 'Authenticated Session')
        : 'Not signed in • Tap to Sign In';

    return Scaffold(
      appBar: AppBar(
        title: Text('Chef Profile', style: getBoldStyle(context: context, fontSize: FontSize.s18)),
        actions: [
          if (!isAuth)
            TextButton.icon(
              onPressed: () => AuthDialog.show(context),
              icon: Icon(Icons.login_rounded, size: 18, color: primaryTone),
              label: Text('Sign In', style: getSemiBoldStyle(fontSize: FontSize.s13, color: primaryTone)),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          cacheExtent: 2000,
          padding: AppSpacing.screenPadding,
          children: [
            ProfileHeader(
              name: resolvedName,
              email: resolvedEmail,
              role: isAuth ? 'Executive Chef' : 'Guest Vault',
              badgeText: isAuth ? 'PRO' : 'GUEST',
              photoUrl: user?.photoUrl,
              onTap: isAuth ? null : () => AuthDialog.show(context),
            ),
            AppSpacing.gapH12,
            _buildSectionHeader('Preferences', primaryTone),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.dark_mode_outlined, color: primaryTone),
              title: Text('Dark Mode', style: getMediumStyle(context: context, fontSize: FontSize.s14)),
              subtitle: Text(
                isDark ? 'Dark theme active' : 'Light theme active',
                style: getRegularStyle(context: context, fontSize: FontSize.s12, color: secColor),
              ),
              value: isDark,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => themeProvider != null
                  ? themeProvider.toggleDarkMode(val)
                  : setState(() => _fallbackDarkOverride = val),
            ),
            _buildActionTile(
              icon: Icons.restaurant_outlined,
              iconColor: isDark ? AppColors.secondaryLight : AppColors.secondary,
              title: 'Dietary Preferences',
              subtitle: dietary.isEmpty ? 'None selected' : dietary.join(', '),
              secColor: secColor,
              onTap: () => _openDietaryDialog(dietary, themeProvider),
            ),
            _buildActionTile(
              icon: Icons.attach_money_rounded,
              iconColor: AppColors.accent,
              title: 'Currency & Budget',
              subtitle: '$currency • $sym${budget.toStringAsFixed(0)} limit',
              secColor: secColor,
              onTap: () => _openCurrencyBudgetDialog(currency, budget, themeProvider),
            ),
            AppSpacing.gapH8,
            _buildSectionHeader('Data & Backup', primaryTone),
            const ExportRecipesTile(),
            const ImportRecipesTile(),
            AppSpacing.gapH8,
            _buildSectionHeader('Account', primaryTone),
            _buildActionTile(
              icon: Icons.logout_rounded,
              iconColor: AppColors.error,
              title: 'Sign Out',
              subtitle: isAuth ? 'Signed in as ${user?.email ?? resolvedName}' : 'End current session and lock recipe vault',
              textColor: AppColors.error,
              secColor: secColor,
              onTap: () => _confirmSignOut(auth),
            ),
            AppSpacing.gapH16,
            const AppBrandingCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(title.toUpperCase(), style: getBoldStyle(fontSize: FontSize.s11, color: color, letterSpacing: 1.1)),
    );
  }

  Widget _buildActionTile({
    required IconData icon, required Color iconColor, required String title,
    required String subtitle, required Color secColor, required VoidCallback onTap, Color? textColor,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: getMediumStyle(context: context, fontSize: FontSize.s14, color: textColor)),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: getRegularStyle(context: context, fontSize: FontSize.s12, color: secColor)),
      trailing: Icon(Icons.chevron_right_rounded, size: 20, color: secColor),
      onTap: onTap,
    );
  }

  void _openDietaryDialog(List<String> current, ThemeProvider? tp) {
    PreferenceDialogs.showDietaryPreferencesDialog(context, selectedOptions: current, onSave: (updated) {
      tp != null ? tp.setDietaryPreferences(updated) : setState(() => _fallbackDietary = updated);
      CustomSnackbar.showSuccess(context, 'Dietary preferences updated');
    });
  }

  void _openCurrencyBudgetDialog(String curr, double bud, ThemeProvider? tp) {
    PreferenceDialogs.showCurrencyBudgetDialog(context, currentCurrency: curr, currentBudget: bud, onSave: (currency, budget) {
      tp != null ? tp.setCurrencyAndBudget(currency, budget) : setState(() { _fallbackCurrency = currency; _fallbackBudget = budget; });
      CustomSnackbar.showSuccess(context, 'Budget preferences saved');
    });
  }

  void _confirmSignOut(AuthProvider? auth) {
    PreferenceDialogs.showSignOutDialog(context, onConfirm: () async {
      await auth?.signOut();
      if (!mounted) return;
      context.read<RecipeProvider?>()?.loadRecipes();
      CustomSnackbar.showSuccess(context, 'Signed out successfully');
      if (GoRouter.maybeOf(context) != null) {
        context.go(AppRoutePaths.auth);
      }
    });
  }
}
