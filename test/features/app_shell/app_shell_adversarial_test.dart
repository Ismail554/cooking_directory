import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cooking_directory/core/routing/app_router.dart';
import 'package:cooking_directory/core/routing/route_paths.dart';
import 'package:cooking_directory/core/widgets/app_error_view.dart';
import 'package:cooking_directory/features/cooking_mode/presentation/screens/cooking_mode_screen.dart';
import 'package:cooking_directory/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:cooking_directory/features/expenses/presentation/screens/expense_screen.dart';
import 'package:cooking_directory/features/home/presentation/screens/home_screen.dart';
import 'package:cooking_directory/features/profile/presentation/screens/profile_screen.dart';
import 'package:cooking_directory/features/profile/presentation/widgets/export_recipes_tile.dart';
import 'package:cooking_directory/features/recipes/presentation/providers/recipe_export_provider.dart';
import 'package:cooking_directory/features/recipes/presentation/screens/add_recipe_screen.dart';
import 'package:cooking_directory/features/recipes/presentation/screens/recipe_details_screen.dart';

Widget _buildAdversarialApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<RecipeExportProvider>(
        create: (_) => RecipeExportProvider(),
      ),
    ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp.router(
        routerConfig: AppRouter.router,
      ),
    ),
  );
}

void main() {
  group('Adversarial Navigation & Route Verification', () {
    testWidgets('all 7 routes resolve and render expected screen widgets', (tester) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildAdversarialApp());
      AppRouter.router.go(AppRoutePaths.home);
      await tester.pumpAndSettle();

      // Route 1: Home
      expect(find.byType(HomeScreen), findsOneWidget);

      // Route 2: Expenses
      AppRouter.router.go(AppRoutePaths.expenses);
      await tester.pumpAndSettle();
      expect(find.byType(ExpenseScreen), findsOneWidget);

      // Route 3: Profile
      AppRouter.router.go(AppRoutePaths.profile);
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);

      // Route 4: Recipe Details
      AppRouter.router.push('${AppRoutePaths.recipeDetails}?id=sample_42');
      await tester.pumpAndSettle();
      expect(find.byType(RecipeDetailsScreen), findsOneWidget);

      // Route 5: Cooking Mode
      AppRouter.router.push('${AppRoutePaths.cookingMode}?id=sample_42&title=Sourdough+Bread');
      await tester.pumpAndSettle();
      expect(find.byType(CookingModeScreen), findsOneWidget);
      expect(find.text('Sourdough Bread'), findsOneWidget);

      // Route 6: Add Recipe
      AppRouter.router.push(AppRoutePaths.addRecipe);
      await tester.pumpAndSettle();
      expect(find.byType(AddRecipeScreen), findsOneWidget);

      // Route 7: Add Expense
      AppRouter.router.push(AppRoutePaths.addExpense);
      await tester.pumpAndSettle();
      expect(find.byType(AddExpenseScreen), findsOneWidget);

      // Return to home
      AppRouter.router.go(AppRoutePaths.home);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('errorBuilder displays AppErrorView on arbitrary invalid path and retries to home', (tester) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildAdversarialApp());
      AppRouter.router.go('/deep/nested/404/invalid/endpoint');
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text('Page Not Found'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorView), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('PopScope on Expenses and Profile tabs redirects to Home tab', (tester) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildAdversarialApp());
      AppRouter.router.go(AppRoutePaths.home);
      await tester.pumpAndSettle();

      // Go to Expenses tab
      await tester.tap(find.text('Expenses'));
      await tester.pumpAndSettle();
      expect(AppRouter.router.state.matchedLocation, AppRoutePaths.expenses);

      // Trigger back button gesture via PopScope
      final dynamic popScopeWidget = tester.widget(find.byType(PopScope).last);
      expect(popScopeWidget.canPop, isFalse);
      popScopeWidget.onPopInvokedWithResult(false, null);
      await tester.pumpAndSettle();

      expect(AppRouter.router.state.matchedLocation, AppRoutePaths.home);

      // Go to Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(AppRouter.router.state.matchedLocation, AppRoutePaths.profile);

      // Trigger back button gesture on Profile tab
      final dynamic popScopeProfile = tester.widget(find.byType(PopScope).last);
      expect(popScopeProfile.canPop, isFalse);
      popScopeProfile.onPopInvokedWithResult(false, null);
      await tester.pumpAndSettle();

      expect(AppRouter.router.state.matchedLocation, AppRoutePaths.home);

      // On Home tab, canPop should be true
      final dynamic popScopeHome = tester.widget(find.byType(PopScope).last);
      expect(popScopeHome.canPop, isTrue);
    });

    testWidgets('ExportRecipesTile operates safely without RecipeExportProvider in ancestor tree', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, _) => const MaterialApp(
            home: Scaffold(body: ExportRecipesTile()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Export Recipes (CSV)'), findsOneWidget);

      // Tap when provider is null does not throw
      await tester.tap(find.text('Export Recipes (CSV)'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
