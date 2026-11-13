import 'package:flutter/material.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';
import 'package:cooking_directory/features/expenses/domain/entities/expense.dart';

/// Budget summary card displaying monthly budget, spent, remaining, and progress bar.
class ExpenseBudgetCard extends StatelessWidget {
  final double budget;
  final double spent;
  final double remaining;
  final double ratio;
  final String currencySymbol;

  const ExpenseBudgetCard({
    super.key,
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.ratio,
    required this.currencySymbol,
  });

  String _fmtWhole(double v) {
    final str = v
        .round()
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$currencySymbol$str';
  }

  @override
  Widget build(BuildContext context) {
    final pct = (ratio * 100).round();
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppBorderRadius.r16,
        boxShadow: const [AppColors.culinaryCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Monthly Food Budget',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getMediumStyle(
                    fontSize: FontSize.s13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
              AppSpacing.gapW8,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppBorderRadius.r12,
                ),
                child: Text(
                  '$pct% spent',
                  style: getSemiBoldStyle(fontSize: FontSize.s12, color: Colors.white),
                ),
              ),
            ],
          ),
          AppSpacing.gapH12,
          Row(
            children: [
              Expanded(child: _buildStatCol('Total Budget', _fmtWhole(budget))),
              Expanded(child: _buildStatCol('Spent', _fmtWhole(spent))),
              Expanded(child: _buildStatCol('Remaining', _fmtWhole(remaining))),
            ],
          ),
          AppSpacing.gapH12,
          ClipRRect(
            borderRadius: AppBorderRadius.r8,
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: getRegularStyle(
            fontSize: FontSize.s11,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        AppSpacing.gapH2,
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            amount,
            style: getBoldStyle(fontSize: FontSize.s18, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// Individual expense list item tile with category icon and formatted amount.
class ExpenseLogTile extends StatelessWidget {
  final Expense item;
  final String currencySymbol;

  const ExpenseLogTile({
    super.key,
    required this.item,
    required this.currencySymbol,
  });

  (IconData, Color) _resolveVisual(String category) => switch (category) {
        'Groceries' => (Icons.local_grocery_store_outlined, AppColors.expenseGroceries),
        'Dining Out' => (Icons.restaurant_outlined, AppColors.expenseDiningOut),
        'Kitchen Tools' => (Icons.hardware_outlined, AppColors.expenseEquipment),
        'Spices' => (Icons.spa_outlined, AppColors.expenseSpices),
        'Delivery' => (Icons.delivery_dining_outlined, AppColors.accent),
        _ => (Icons.receipt_long_outlined, AppColors.primary),
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (icon, color) = _resolveVisual(item.category);
    final secColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: AppBorderRadius.r8),
            child: Icon(icon, color: color, size: 20),
          ),
          AppSpacing.gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: getSemiBoldStyle(context: context, fontSize: FontSize.s14)),
                AppSpacing.gapH2,
                Text('${item.category} • ${item.dateLabel}', maxLines: 1, overflow: TextOverflow.ellipsis, style: getRegularStyle(context: context, fontSize: FontSize.s12, color: secColor)),
              ],
            ),
          ),
          AppSpacing.gapW8,
          Text('-$currencySymbol${item.amount.toStringAsFixed(2)}', style: getBoldStyle(context: context, fontSize: FontSize.s14, color: AppColors.error)),
        ],
      ),
    );
  }
}
