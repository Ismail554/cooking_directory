import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/asset_manager.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';
import 'package:cooking_directory/core/routing/route_paths.dart';
import 'package:cooking_directory/core/widgets/app_empty_view.dart';

typedef _ExpenseData = ({String title, String category, String date, double amount, IconData icon, Color color});

/// Food expenses tracking screen with budget progress, filters, and logs.
class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  static const _categories = ['All', 'Groceries', 'Dining Out', 'Kitchen Tools', 'Spices', 'Delivery', 'Snacks'];

  static const List<_ExpenseData> _allExpenses = [
    (title: 'Supermarket Groceries', category: 'Groceries', date: 'Today, 2:30 PM', amount: 145.80, icon: Icons.local_grocery_store_outlined, color: AppColors.expenseGroceries),
    (title: 'Trattoria Pasta Dinner', category: 'Dining Out', date: 'Yesterday, 8:15 PM', amount: 68.00, icon: Icons.restaurant_outlined, color: AppColors.expenseDiningOut),
    (title: 'Chef Knife & Whetstone', category: 'Kitchen Tools', date: 'Nov 8, 2026', amount: 125.00, icon: Icons.hardware_outlined, color: AppColors.expenseEquipment),
    (title: 'Saffron & Olive Oil', category: 'Spices', date: 'Nov 5, 2026', amount: 34.20, icon: Icons.spa_outlined, color: AppColors.expenseSpices),
    (title: 'Artisan Bakery Box', category: 'Delivery', date: 'Nov 3, 2026', amount: 22.80, icon: Icons.delivery_dining_outlined, color: AppColors.accent),
    (title: 'Organic Farm Veggies', category: 'Groceries', date: 'Oct 30, 2026', amount: 84.20, icon: Icons.local_grocery_store_outlined, color: AppColors.expenseGroceries),
  ];

  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final list = _selectedCategory == 'All'
        ? _allExpenses
        : _allExpenses.where((e) => e.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Food Expenses', style: getBoldStyle(context: context, fontSize: FontSize.s18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            _buildBudgetCard(),
            AppSpacing.gapH20,
            _buildCategoryFilters(),
            AppSpacing.gapH20,
            Text('Recent Expenses', style: getBoldStyle(context: context, fontSize: FontSize.s16)),
            AppSpacing.gapH12,
            if (list.isEmpty)
              AppEmptyView(
                illustrationPath: AssetManager.svgNoData,
                title: 'No Expenses Found',
                message: 'No expenses logged for "$_selectedCategory".',
                actionLabel: 'Add Expense',
                onAction: () => context.push(AppRoutePaths.addExpense),
              )
            else
              ...list.map((item) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildExpenseTile(item))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_expense_fab',
        onPressed: () => context.push(AppRoutePaths.addExpense),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildBudgetCard() {
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
              Expanded(
                child: Text(
                  'Monthly Food Budget',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getMediumStyle(fontSize: FontSize.s13, color: Colors.white70),
                ),
              ),
              AppSpacing.gapW8,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: AppBorderRadius.r8),
                child: Text('40% spent', style: getBoldStyle(fontSize: FontSize.s11, color: Colors.white)),
              ),
            ],
          ),
          AppSpacing.gapH12,
          ClipRRect(
            borderRadius: AppBorderRadius.circular,
            child: const LinearProgressIndicator(
              value: 0.40,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          AppSpacing.gapH16,
          Row(
            children: [
              _metric('Total Budget', '\$1,200'),
              _metric('Spent', '\$480'),
              _metric('Remaining', '\$720'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: getRegularStyle(fontSize: FontSize.s11, color: Colors.white70)),
          AppSpacing.gapH2,
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: getBoldStyle(fontSize: FontSize.s16, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: AppColors.primary,
              labelStyle: getMediumStyle(fontSize: FontSize.s12, color: isSelected ? Colors.white : null),
              onSelected: (_) => setState(() => _selectedCategory = cat),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpenseTile(_ExpenseData item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: AppElevation.e0,
      color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.color.withValues(alpha: 0.15),
          child: Icon(item.icon, color: item.color),
        ),
        title: Text(item.title, style: getSemiBoldStyle(context: context, fontSize: FontSize.s14)),
        subtitle: Text('${item.category} • ${item.date}', style: getRegularStyle(context: context, fontSize: FontSize.s12, color: AppColors.textSecondaryLight)),
        trailing: Text('-\$${item.amount.toStringAsFixed(2)}', style: getBoldStyle(context: context, fontSize: FontSize.s14, color: AppColors.primary)),
      ),
    );
  }
}
