import 'package:flutter/material.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Food Expenses',
          style: getBoldStyle(
            fontSize: FontSize.s18,
            color: AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            _buildSummaryCard(),
            AppSpacing.gapH24,
            Text(
              'Recent Expenses',
              style: getBoldStyle(fontSize: FontSize.s16),
            ),
            AppSpacing.gapH12,
            _buildExpenseTile(
              title: 'Supermarket Groceries',
              category: 'Groceries',
              date: 'Today, 2:30 PM',
              amount: '\$45.80',
              iconColor: AppColors.expenseGroceries,
            ),
            AppSpacing.gapH8,
            _buildExpenseTile(
              title: 'Italian Herbs & Olive Oil',
              category: 'Ingredients',
              date: 'Yesterday',
              amount: '\$18.50',
              iconColor: AppColors.expenseSpices,
            ),
            AppSpacing.gapH8,
            _buildExpenseTile(
              title: 'Chef Knife Sharpener',
              category: 'Equipment',
              date: 'Nov 8, 2026',
              amount: '\$24.99',
              iconColor: AppColors.expenseEquipment,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      color: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r16),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Food Budget',
              style: getMediumStyle(fontSize: FontSize.s13, color: Colors.white70),
            ),
            AppSpacing.gapH4,
            Text(
              '\$420.00 / \$600.00',
              style: getBoldStyle(fontSize: FontSize.s24, color: Colors.white),
            ),
            AppSpacing.gapH12,
            ClipRRect(
              borderRadius: AppBorderRadius.circular,
              child: const LinearProgressIndicator(
                value: 0.7,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTile({
    required String title,
    required String category,
    required String date,
    required String amount,
    required Color iconColor,
  }) {
    return Card(
      elevation: AppElevation.e0,
      color: AppColors.surfaceVariantLight,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.15),
          child: Icon(Icons.shopping_bag_outlined, color: iconColor),
        ),
        title: Text(title, style: getSemiBoldStyle(fontSize: FontSize.s14)),
        subtitle: Text('$category • $date', style: getRegularStyle(fontSize: FontSize.s12, color: AppColors.textSecondaryLight)),
        trailing: Text(
          amount,
          style: getBoldStyle(fontSize: FontSize.s14, color: AppColors.primary),
        ),
      ),
    );
  }
}
