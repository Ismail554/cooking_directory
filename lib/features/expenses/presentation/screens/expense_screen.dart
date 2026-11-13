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
import 'package:cooking_directory/core/widgets/app_loading_view.dart';
import 'package:cooking_directory/core/widgets/app_themed_background.dart';
import 'package:cooking_directory/core/widgets/custom_snackbar.dart';
import 'package:cooking_directory/features/expenses/data/datasources/expense_local_datasource.dart';
import 'package:cooking_directory/features/expenses/domain/entities/expense.dart';
import 'package:cooking_directory/features/expenses/presentation/providers/expense_provider.dart';
import 'package:cooking_directory/features/expenses/presentation/widgets/expense_budget_and_tile.dart';

/// Food expenses tracking screen with async state management, budget progress, and filters.
class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  static const _categories = ['All', 'Groceries', 'Dining Out', 'Kitchen Tools', 'Spices', 'Delivery', 'Snacks'];
  late final List<Expense> _fallbackExpenses = kSeedExpenses.map((e) => e.toEntity()).toList();
  String _fallbackCategory = 'All';

  Future<void> _openAddExpense() async {
    final result = await context.push<Map<String, dynamic>>(AppRoutePaths.addExpense);
    if (result == null || !mounted) return;
    final title = (result['title'] as String?) ?? 'Expense';
    final newExpense = Expense(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: (result['category'] as String?) ?? 'Groceries',
      dateLabel: 'Just now',
      amount: (result['amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.now(),
    );
    final provider = context.read<ExpenseProvider?>();
    if (provider != null) {
      await provider.addExpense(newExpense);
    } else {
      setState(() => _fallbackExpenses.insert(0, newExpense));
    }
    if (mounted) CustomSnackbar.showSuccess(context, 'Added "$title" to expenses');
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider?>();
    final ep = context.watch<ExpenseProvider?>();
    final budget = tp?.monthlyBudget ?? 1200.0;
    final sym = tp?.currencySymbol ?? '\$';
    final selectedCat = ep?.selectedCategory ?? _fallbackCategory;
    final allItems = ep?.allExpenses ?? _fallbackExpenses;
    final spent = ep?.totalSpent ?? allItems.fold<double>(0.0, (s, e) => s + e.amount);
    final remaining = (budget - spent).clamp(0.0, double.infinity);
    final ratio = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final list = ep != null
        ? ep.filteredExpenses
        : (selectedCat == 'All' ? allItems : allItems.where((e) => e.category == selectedCat).toList());
    final isLoading = ep?.isLoading ?? false;

    return AppThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Food Expenses', style: getBoldStyle(context: context, fontSize: FontSize.s18)),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: () async {
                final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                if (picked != null && mounted) ep?.setSelectedDate(picked);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => ep?.loadExpenses(showLoading: true),
            color: AppColors.primary,
            child: ListView(
              padding: AppSpacing.screenPadding,
              children: [
                ExpenseBudgetCard(budget: budget, spent: spent, remaining: remaining, ratio: ratio, currencySymbol: sym),
                AppSpacing.gapH20,
                _buildCategoryFilters(selectedCat, ep),
                if (ep?.selectedDate != null) ...[
                  AppSpacing.gapH8,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ActionChip(
                      avatar: const Icon(Icons.close_rounded, size: 16),
                      label: Text(
                        'Date: ${ep!.selectedDate!.year}-${ep.selectedDate!.month.toString().padLeft(2, '0')}-${ep.selectedDate!.day.toString().padLeft(2, '0')}',
                        style: getMediumStyle(context: context, fontSize: FontSize.s12),
                      ),
                      onPressed: () => ep.setSelectedDate(null),
                    ),
                  ),
                ],
                AppSpacing.gapH16,
                Text('Recent Expenses', style: getBoldStyle(context: context, fontSize: FontSize.s16)),
                AppSpacing.gapH12,
                if (isLoading && list.isEmpty)
                  const SizedBox(height: 150, child: AppLoadingView(message: 'Syncing expenses...'))
                else if (list.isEmpty)
                  AppEmptyView(
                    illustrationPath: AssetManager.svgNoData,
                    title: 'No Expenses Found',
                    message: 'No expenses logged for "$selectedCat".',
                    actionLabel: 'Add Expense',
                    onAction: _openAddExpense,
                  )
                else
                  ...list.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.16), borderRadius: AppBorderRadius.r16),
                          child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                        ),
                        onDismissed: (_) async {
                          if (ep != null) {
                            await ep.deleteExpense(item.id);
                          } else {
                            setState(() => _fallbackExpenses.removeWhere((e) => e.id == item.id));
                          }
                          if (mounted) CustomSnackbar.showSuccess(context, 'Deleted "${item.title}"');
                        },
                        child: ExpenseLogTile(item: item, currencySymbol: sym),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'add_expense_fab',
          onPressed: _openAddExpense,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(String selectedCat, ExpenseProvider? ep) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: _categories.map((cat) {
          final sel = cat == selectedCat;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => ep != null ? ep.setCategory(cat) : setState(() => _fallbackCategory = cat),
              borderRadius: AppBorderRadius.r20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : Theme.of(context).cardColor,
                  borderRadius: AppBorderRadius.r20,
                  border: Border.all(color: sel ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight)),
                ),
                child: Text(cat, style: getMediumStyle(context: context, fontSize: 12.sp, color: sel ? Colors.white : null)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
