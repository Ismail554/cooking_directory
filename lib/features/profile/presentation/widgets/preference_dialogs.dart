import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';

/// Modal dialog helpers for Chef Profile preferences, currency, and sign out.
abstract final class PreferenceDialogs {
  static const List<String> availableDietaryOptions = [
    'Vegetarian', 'Halal', 'Gluten-Free', 'Vegan', 'Keto'
  ];
  static const List<String> availableCurrencies = [
    'USD (\$)', 'EUR (€)', 'GBP (£)', 'BDT (৳)'
  ];

  /// Multi-select dialog for dietary preferences.
  static Future<void> showDietaryPreferencesDialog(
    BuildContext context, {
    required List<String> selectedOptions,
    required ValueChanged<List<String>> onSave,
  }) async {
    final tempSelected = List<String>.from(selectedOptions);
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r16),
          title: Text('Dietary Preferences', style: getBoldStyle(context: context, fontSize: FontSize.s18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: availableDietaryOptions.map((opt) {
                return CheckboxListTile(
                  value: tempSelected.contains(opt),
                  activeColor: AppColors.primary,
                  title: Text(opt, style: getRegularStyle(context: context, fontSize: FontSize.s14)),
                  onChanged: (val) => setModalState(() {
                    val == true ? tempSelected.add(opt) : tempSelected.remove(opt);
                  }),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: getMediumStyle(fontSize: FontSize.s14, color: AppColors.textSecondaryLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r8),
              ),
              onPressed: () {
                onSave(tempSelected);
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  /// Currency and monthly budget configuration dialog.
  static Future<void> showCurrencyBudgetDialog(
    BuildContext context, {
    required String currentCurrency,
    required double currentBudget,
    required void Function(String currency, double budget) onSave,
  }) async {
    String selectedCurrency = currentCurrency;
    final budgetCtrl = TextEditingController(text: currentBudget.toStringAsFixed(0));
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r16),
          title: Text('Currency & Budget', style: getBoldStyle(context: context, fontSize: FontSize.s18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Currency', style: getSemiBoldStyle(context: context, fontSize: FontSize.s14)),
                AppSpacing.gapH8,
                Wrap(
                  spacing: 8.w,
                  children: availableCurrencies.map((curr) => ChoiceChip(
                    label: Text(curr),
                    selected: selectedCurrency == curr,
                    selectedColor: AppColors.primaryContainer,
                    onSelected: (val) {
                      if (val) setModalState(() => selectedCurrency = curr);
                    },
                  )).toList(),
                ),
                AppSpacing.gapH16,
                Text('Monthly Budget Limit', style: getSemiBoldStyle(context: context, fontSize: FontSize.s14)),
                AppSpacing.gapH8,
                TextField(
                  controller: budgetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(borderRadius: AppBorderRadius.r12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: getMediumStyle(fontSize: FontSize.s14, color: AppColors.textSecondaryLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r8),
              ),
              onPressed: () {
                final val = double.tryParse(budgetCtrl.text) ?? currentBudget;
                onSave(selectedCurrency, val);
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  /// Sign out confirmation alert dialog.
  static Future<void> showSignOutDialog(BuildContext context, {required VoidCallback onConfirm}) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r16),
        title: Text('Sign Out', style: getBoldStyle(context: context, fontSize: FontSize.s18)),
        content: Text('Are you sure you want to sign out of your chef profile?',
            style: getRegularStyle(context: context, fontSize: FontSize.s14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: getMediumStyle(fontSize: FontSize.s14, color: AppColors.textSecondaryLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r8),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
