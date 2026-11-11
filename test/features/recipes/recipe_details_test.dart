import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cooking_directory/core/widgets/app_button.dart';
import 'package:cooking_directory/features/cooking_mode/presentation/screens/cooking_mode_screen.dart';
import 'package:cooking_directory/features/recipes/presentation/screens/add_recipe_screen.dart';
import 'package:cooking_directory/features/recipes/presentation/screens/recipe_details_screen.dart';
import 'package:cooking_directory/features/recipes/presentation/widgets/ingredients_checklist.dart';
import 'package:cooking_directory/features/recipes/presentation/widgets/instructions_timeline.dart';
import 'package:cooking_directory/features/recipes/presentation/widgets/recipe_stats_bar.dart';

Widget _buildTestApp(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(home: child),
  );
}

void main() {
  group('RecipeStatsBar Widget Tests', () {
    testWidgets('renders all culinary stats and badges correctly', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const Scaffold(
            body: RecipeStatsBar(
              prepTimeMinutes: 15,
              cookTimeMinutes: 20,
              calories: 450,
              rating: 4.8,
              difficulty: 'Medium',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('15 m'), findsOneWidget);
      expect(find.text('20 m'), findsOneWidget);
      expect(find.text('450'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
    });
  });

  group('IngredientsChecklist Widget Tests', () {
    testWidgets('renders items and handles servings stepper and checkbox toggle', (tester) async {
      int? updatedServings;
      await tester.pumpWidget(
        _buildTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: IngredientsChecklist(
                ingredients: const ['2 chicken breasts', '1 cup heavy cream'],
                initialServings: 4,
                onServingsChanged: (val) => updatedServings = val,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ingredients (2)'), findsOneWidget);
      expect(find.text('4 serv'), findsOneWidget);
      expect(find.text('2 chicken breasts'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(updatedServings, 5);
      expect(find.text('5 serv'), findsOneWidget);

      await tester.tap(find.text('2 chicken breasts'));
      await tester.pumpAndSettle();
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox).first);
      expect(checkbox.value, isTrue);
    });
  });

  group('InstructionsTimeline Widget Tests', () {
    testWidgets('renders timeline steps and duration timer chips', (tester) async {
      int? timerMinutes;
      await tester.pumpWidget(
        _buildTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: InstructionsTimeline(
                steps: const [
                  'Preheat oven to 200C.',
                  'Simmer sauce for 10 minutes gently.',
                ],
                onStartTimer: (step, mins) => timerMinutes = mins,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Step Timer: 10 min'), findsOneWidget);

      await tester.tap(find.text('Step Timer: 10 min'));
      await tester.pumpAndSettle();
      expect(timerMinutes, 10);
    });
  });

  group('RecipeDetailsScreen Widget Tests', () {
    testWidgets('renders rich header, stats, checklist, and CTA button', (tester) async {
      await tester.pumpWidget(_buildTestApp(const RecipeDetailsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(RecipeStatsBar), findsOneWidget);
      expect(find.byType(IngredientsChecklist), findsOneWidget);
      expect(find.byType(InstructionsTimeline), findsOneWidget);
      expect(find.text('Start Cooking Mode'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.bookmark_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
    });
  });

  group('AddRecipeScreen Overflow & Validation Tests', () {
    testWidgets('wraps layout in SingleChildScrollView and validates input', (tester) async {
      await tester.pumpWidget(_buildTestApp(const AddRecipeScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Add New Recipe'), findsOneWidget);
      expect(find.text('Save Recipe'), findsOneWidget);

      await tester.tap(find.widgetWithText(AppButton, 'Save Recipe'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter recipe title'), findsOneWidget);
    });
  });

  group('CookingModeScreen Tests', () {
    testWidgets('navigates steps, triggers timers dialog, and shows completion dialog', (tester) async {
      await tester.pumpWidget(_buildTestApp(const CookingModeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 4'), findsOneWidget);
      expect(find.text('Next Step'), findsOneWidget);

      await tester.tap(find.text('Timers'));
      await tester.pumpAndSettle();
      expect(find.text('Quick Timer'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();
      expect(find.text('Step 2 of 4'), findsOneWidget);
      expect(find.text('Previous'), findsOneWidget);

      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();
      expect(find.text('Finish'), findsOneWidget);

      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();
      expect(find.text('Bon Appétit! 🎉'), findsOneWidget);
    });
  });
}
