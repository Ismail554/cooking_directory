import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cooking_directory/core/routing/app_router.dart';
import 'package:cooking_directory/core/routing/route_paths.dart';
import 'package:cooking_directory/core/widgets/app_error_view.dart';
import 'package:cooking_directory/features/cooking_mode/presentation/screens/cooking_mode_screen.dart';
import 'package:cooking_directory/features/recipes/presentation/providers/recipe_export_provider.dart';

Widget _buildTestApp({required Widget child}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(home: child),
  );
}

Widget _buildRouterApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<RecipeExportProvider>(
        create: (_) => RecipeExportProvider(),
      ),
    ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp.router(routerConfig: AppRouter.router),
    ),
  );
}

void main() {
  group('AppShell NavigationBar and PopScope Tests', () {
    testWidgets('renders 3 destinations with branded assets and labels', (tester) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildRouterApp());
      AppRouter.router.go(AppRoutePaths.home);
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Recipes'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byType(PopScope), findsWidgets);
    });

    testWidgets('switching between tabs updates selected branch', (tester) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildRouterApp());
      AppRouter.router.go(AppRoutePaths.home);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Expenses'));
      await tester.pumpAndSettle();
      expect(AppRouter.router.state.matchedLocation, AppRoutePaths.expenses);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(AppRouter.router.state.matchedLocation, AppRoutePaths.profile);

      await tester.tap(find.text('Recipes'));
      await tester.pumpAndSettle();
      expect(AppRouter.router.state.matchedLocation, AppRoutePaths.home);
    });
  });

  group('CookingModeScreen Widget Tests', () {
    testWidgets('renders title, progress bar, timer chip, and first step', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const CookingModeScreen(
            recipeId: 'recipe_123',
            title: 'Tuscan Garlic Chicken',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tuscan Garlic Chicken'), findsOneWidget);
      expect(find.text('Timers'), findsOneWidget);
      expect(find.text('Step 1 of 4'), findsOneWidget);
      expect(find.text('25% Completed'), findsOneWidget);
      expect(find.text('Instruction'), findsOneWidget);
      expect(find.text('Next Step'), findsOneWidget);
      expect(find.text('Previous'), findsNothing);
    });

    testWidgets('advances steps and shows Previous / Finish buttons', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const CookingModeScreen(
            recipeId: 'recipe_123',
            title: 'Tuscan Garlic Chicken',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1 -> Step 2
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();
      expect(find.text('Step 2 of 4'), findsOneWidget);
      expect(find.text('Previous'), findsOneWidget);

      // Step 2 -> Step 3
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();
      expect(find.text('Step 3 of 4'), findsOneWidget);

      // Step 3 -> Step 4
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();
      expect(find.text('Step 4 of 4'), findsOneWidget);
      expect(find.text('Finish'), findsOneWidget);

      // Step 4 -> Step 3
      await tester.tap(find.text('Previous'));
      await tester.pumpAndSettle();
      expect(find.text('Step 3 of 4'), findsOneWidget);
      expect(find.text('Next Step'), findsOneWidget);
    });
  });

  group('AppRouter Route & ErrorBuilder Tests', () {
    testWidgets('errorBuilder renders AppErrorView with Page Not Found on unknown path', (tester) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildRouterApp());
      AppRouter.router.go('/non-existent-unknown-path');
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text('Page Not Found'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(find.byType(AppErrorView), findsNothing);
    });

    testWidgets('cookingMode route can be navigated to via GoRouter', (tester) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildRouterApp());
      AppRouter.router.go(AppRoutePaths.home);
      await tester.pumpAndSettle();

      AppRouter.router.push('${AppRoutePaths.cookingMode}?title=Roast+Duck&id=duck1');
      await tester.pumpAndSettle();

      expect(find.byType(CookingModeScreen), findsOneWidget);
      expect(find.text('Roast Duck'), findsOneWidget);

      AppRouter.router.go(AppRoutePaths.home);
      await tester.pumpAndSettle();
    });
  });
}
