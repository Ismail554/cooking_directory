import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cooking_directory/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:cooking_directory/features/expenses/presentation/screens/expense_screen.dart';

Widget _buildTestApp(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('ExpenseScreen Widget Tests', () {
    testWidgets('renders budget card with total, spent, remaining, and progress',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(const ExpenseScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Food Expenses'), findsOneWidget);
      expect(find.text('Monthly Food Budget'), findsOneWidget);
      expect(find.text('40% spent'), findsOneWidget);
      expect(find.text('\$1,200'), findsOneWidget);
      expect(find.text('\$480'), findsOneWidget);
      expect(find.text('\$720'), findsOneWidget);

      final progressFinder = find.byType(LinearProgressIndicator);
      expect(progressFinder, findsOneWidget);
      final indicator = tester.widget<LinearProgressIndicator>(progressFinder);
      expect(indicator.value, 0.40);
    });

    testWidgets('renders all category filter pills and filters expenses on tap',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(const ExpenseScreen()));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Dining Out'), findsOneWidget);
      expect(find.text('Kitchen Tools'), findsOneWidget);
      expect(find.text('Spices'), findsOneWidget);
      expect(find.text('Delivery'), findsOneWidget);

      // In initial 'All' state, all expense tiles are visible
      expect(find.text('Supermarket Groceries'), findsOneWidget);
      expect(find.text('Trattoria Pasta Dinner'), findsOneWidget);

      // Tap Dining Out filter
      await tester.tap(find.text('Dining Out'));
      await tester.pumpAndSettle();

      expect(find.text('Trattoria Pasta Dinner'), findsOneWidget);
      expect(find.text('Supermarket Groceries'), findsNothing);
    });

    testWidgets('renders empty state when filter category has no items',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(const ExpenseScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Snacks'));
      await tester.pumpAndSettle();

      expect(find.text('No Expenses Found'), findsOneWidget);
      expect(find.text('No expenses logged for "Snacks".'), findsOneWidget);
    });

    testWidgets('renders calendar action button and FAB', (tester) async {
      await tester.pumpWidget(_buildTestApp(const ExpenseScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });
  });

  group('AddExpenseScreen Widget Tests', () {
    testWidgets('renders form fields, labels, and buttons', (tester) async {
      await tester.pumpWidget(_buildTestApp(const AddExpenseScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Add Expense'), findsOneWidget);
      expect(find.text('Title / Description'), findsOneWidget);
      expect(find.text('Amount (\$)'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Expense Date'), findsOneWidget);
      expect(find.text('Save Expense'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('validates required fields on Save Expense tap', (tester) async {
      await tester.pumpWidget(_buildTestApp(const AddExpenseScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a description'), findsOneWidget);
      expect(find.text('Please enter an amount'), findsOneWidget);
    });

    testWidgets('submits valid expense data and pops screen', (tester) async {
      Map<String, dynamic>? resultData;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, _) => MaterialApp(
            home: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  final res = await Navigator.of(ctx).push<Map<String, dynamic>>(
                    MaterialPageRoute(
                      builder: (_) => const AddExpenseScreen(),
                    ),
                  );
                  resultData = res;
                },
                child: const Text('Open Add'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Add'));
      await tester.pumpAndSettle();

      // Fill in valid fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title / Description'),
        'Artisan Sourdough Loaf',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Amount (\$)'),
        '8.50',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();

      expect(resultData, isNotNull);
      expect(resultData!['title'], 'Artisan Sourdough Loaf');
      expect(resultData!['amount'], 8.50);
      expect(resultData!['category'], 'Groceries');
    });

    testWidgets('does not overflow when keyboard simulates bottom insets',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.viewInsets = const FakeViewPadding(bottom: 400);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpWidget(_buildTestApp(const AddExpenseScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
