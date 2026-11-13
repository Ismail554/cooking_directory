import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cooking_directory/core/routing/app_router.dart';
import 'package:cooking_directory/core/routing/route_paths.dart';
import 'package:cooking_directory/features/home/presentation/screens/home_screen.dart';
import 'package:cooking_directory/features/home/presentation/widgets/featured_recipe_card.dart';
import 'package:cooking_directory/features/home/presentation/widgets/home_category_pills.dart';
import 'package:cooking_directory/features/home/presentation/widgets/home_header.dart';
import 'package:cooking_directory/features/home/presentation/widgets/home_search_bar.dart';
import 'package:cooking_directory/features/home/presentation/widgets/recipe_grid_card.dart';

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
  group('HomeScreen Sub-Widgets Rendering Tests', () {
    testWidgets('HomeHeader renders greeting, subtitle, and avatar', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const Scaffold(body: HomeHeader()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hello, Chef Ismail'), findsOneWidget);
      expect(find.text('What are we cooking today?'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('HomeSearchBar renders hint, icons, and handles input and clear', (tester) async {
      String typed = '';
      await tester.pumpWidget(
        _buildTestApp(
          Scaffold(
            body: HomeSearchBar(
              onChanged: (val) => typed = val,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search recipes, ingredients...'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsNothing);

      await tester.enterText(find.byType(TextField), 'Pasta');
      await tester.pumpAndSettle();

      expect(typed, 'Pasta');
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Pasta'), findsNothing);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('HomeCategoryPills renders categories and handles selection', (tester) async {
      String selected = 'All';
      await tester.pumpWidget(
        _buildTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: HomeCategoryPills(
                  selectedCategory: selected,
                  onCategorySelected: (cat) => setState(() => selected = cat),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);

      await tester.tap(find.text('Breakfast'));
      await tester.pumpAndSettle();

      expect(selected, 'Breakfast');
    });

    testWidgets('FeaturedRecipeCard renders metadata, rating, and toggles favorite', (tester) async {
      bool? favState;
      await tester.pumpWidget(
        _buildTestApp(
          Scaffold(
            body: FeaturedRecipeCard(
              onFavoriteToggle: (fav) => favState = fav,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Creamy Tuscan Garlic Chicken'), findsOneWidget);
      expect(find.text('25 min'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);

      // Tap favorite button to toggle
      await tester.tap(find.byIcon(Icons.bookmark_rounded));
      await tester.pumpAndSettle();

      expect(favState, isFalse);
      expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
    });

    testWidgets('RecipeGridCard renders compact details', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _buildTestApp(
          Scaffold(
            body: RecipeGridCard(
              title: 'Beef Bolognese',
              prepTime: '20 min',
              calories: 550,
              rating: 4.8,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Beef Bolognese'), findsOneWidget);
      expect(find.text('550 kcal'), findsOneWidget);
      expect(find.text('20 min'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);

      await tester.tap(find.byType(RecipeGridCard));
      expect(tapped, isTrue);
    });
  });

  group('HomeScreen Integration & Navigation Tests', () {
    testWidgets('HomeScreen integrates all sub-widgets and FAB with New Recipe label', (tester) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, _) => MaterialApp.router(
            routerConfig: AppRouter.router,
          ),
        ),
      );
      AppRouter.router.go(AppRoutePaths.home);
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(HomeHeader), findsOneWidget);
      expect(find.byType(HomeSearchBar), findsOneWidget);
      expect(find.byType(HomeCategoryPills), findsOneWidget);
      expect(find.byType(FeaturedRecipeCard), findsOneWidget);
      expect(find.byType(RecipeGridCard), findsNWidgets(2));
      expect(find.text('New Recipe'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Verify FAB navigates to add recipe screen
      await tester.tap(find.text('New Recipe'));
      await tester.pumpAndSettle();

      expect(AppRouter.router.state.matchedLocation, AppRoutePaths.addRecipe);

      // Return to home
      AppRouter.router.go(AppRoutePaths.home);
      await tester.pumpAndSettle();
    });
  });
}
