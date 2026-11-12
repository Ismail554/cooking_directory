import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cooking_directory/core/constants/app_spacing.dart';
import 'package:cooking_directory/core/managers/app_colors.dart';
import 'package:cooking_directory/core/managers/asset_manager.dart';
import 'package:cooking_directory/core/managers/font_manager.dart';
import 'package:cooking_directory/core/managers/style_manager.dart';
import 'package:cooking_directory/core/managers/value_manager.dart';
import 'package:cooking_directory/core/routing/route_paths.dart';
import 'package:cooking_directory/core/theme/theme_provider.dart';
import 'package:cooking_directory/core/widgets/app_empty_view.dart';
import 'package:cooking_directory/core/widgets/custom_snackbar.dart';

typedef _ExpenseData = ({String title, String category, String date, double amount, IconData icon, Color color});

/// Food expenses tracking screen with dynamic budget progress, filters, and logs.
class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  static const _categories = ['All', 'Groceries', 'Dining Out', 'Kitchen Tools', 'Spices', 'Delivery', 'Snacks'];

  static const List<_ExpenseData> _seedExpenses = [
    (title: 'Supermarket Groceries', category: 'Groceries', date: 'Today, 2:30 PM', amount: 145.80, icon: Icons.local_grocery_store_outlined, color: AppColors.expenseGroceries),
    (title: 'Trattoria Pasta Dinner', category: 'Dining Out', date: 'Yesterday, 8:15 PM', amount: 68.00, icon: Icons.restaurant_outlined, color: AppColors.expenseDiningOut),
    (title: 'Chef Knife & Whetstone', category: 'Kitchen Tools', date: 'Nov 8, 2026', amount: 125.00, icon: Icons.hardware_outlined, color: AppColors.expenseEquipment),
    (title: 'Saffron & Olive Oil', category: 'Spices', date: 'Nov 5, 2026', amount: 34.20, icon: Icons.spa_outlined, color: AppColors.expenseSpices),
    (title: 'Artisan Bakery Box', category: 'Delivery', date: 'Nov 3, 2026', amount: 22.80, icon: Icons.delivery_dining_outlined, color: AppColors.accent),
    (title: 'Organic Farm Veggies', category: 'Groceries', date: 'Oct 30, 2026', amount: 84.20, icon: Icons.local_grocery_store_outlined, color: AppColors.expenseGroceries),
  ];

  late final List<_ExpenseData> _expenses = List.from(_seedExpenses);
  String _selectedCategory = 'All';

  Future<void> _openAddExpense() async {
    final result = await context.push<Map<String, dynamic>>(AppRoutePaths.addExpense);
    if (result != null && mounted) {
      final title = (result['title'] as String?) ?? 'Expense';
      final amount = (result['amount'] as num?)?.toDouble() ?? 0.0;
      final category = (result['category'] as String?) ?? 'Groceries';
      setState(() {
        _expenses.insert(0, (title: title, category: category, date: 'Just now', amount: amount, icon: Icons.receipt_long_outlined, color: AppColors.primary));
      });
      CustomSnackbar.showSuccess(context, 'Added "$title" to expenses');
    }
  }

  String _fmtWhole(double v, String sym) {
    final str = v.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$sym$str';
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider?>();
    final budget = tp?.monthlyBudget ?? 1200.0;
    final sym = tp?.currencySymbol ?? '\$';
    final spent = _expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
    final remaining = (budget - spent).clamp(0.0, double.infinity);
    final ratio = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    final list = _selectedCategory == 'All' ? _expenses : _expenses.where((e) => e.category == _selectedCategory).toList();

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
            _buildBudgetCard(budget, spent, remaining, ratio, sym),
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
                onAction: _openAddExpense,
              )
            else
              ...list.map((item) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildExpenseTile(item, sym))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_expense_fab',
        onPressed: _openAddExpense,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildBudgetCard(double budget, double spent, double remaining, double ratio, String sym) {
    final pct = (ratio * 100).round();
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: AppBorderRadius.r16, boxShadow: const [AppColors.culinaryCardShadow]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Monthly Food Budget', maxLines: 1, overflow: TextOverflow.ellipsis, style: getMediumStyle(fontSize: FontSize.s13, color: Colors.white70))),
              AppSpacing.gapW8,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: AppBorderRadius.r8),
                child: Text('$pct% spent', style: getBoldStyle(fontSize: FontSize.s11, color: Colors.white)),
              ),
            ],
          ),
          AppSpacing.gapH12,
          ClipRRect(
            borderRadius: AppBorderRadius.circular,
            child: LinearProgressIndicator(value: ratio, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 8),
          ),
          AppSpacing.gapH16,
          Row(children: [
            _metric('Total Budget', _fmtWhole(budget, sym)),
            _metric('Spent', _fmtWhole(spent, sym)),
            _metric('Remaining', _fmtWhole(remaining, sym)),
          ]),
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

  Widget _buildExpenseTile(_ExpenseData item, String sym) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: AppElevation.e0,
      color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: item.color.withValues(alpha: 0.15), child: Icon(item.icon, color: item.color)),
        title: Text(item.title, style: getSemiBoldStyle(context: context, fontSize: FontSize.s14)),
        subtitle: Text('${item.category} • ${item.date}', style: getRegularStyle(context: context, fontSize: FontSize.s12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        trailing: Text('-$sym${item.amount.toStringAsFixed(2)}', style: getBoldStyle(context: context, fontSize: FontSize.s14, color: isDark ? AppColors.primaryLight : AppColors.primary)),
      ),
    );
  }
}
