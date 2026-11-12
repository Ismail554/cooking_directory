import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cooking_directory/core/widgets/app_button.dart';
import 'package:cooking_directory/features/recipes/domain/entities/recipe.dart';
import 'package:cooking_directory/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:cooking_directory/features/recipes/presentation/providers/recipe_provider.dart';
import 'package:cooking_directory/features/recipes/presentation/screens/add_recipe_screen.dart';
import 'package:cooking_directory/features/recipes/presentation/widgets/csv_import_dialog.dart';

class _FakeRecipeRepo implements RecipeRepository {
  final List<Recipe> added = [];
  @override
  Future<List<Recipe>> getAllRecipes() async => added;
  @override
  Future<Recipe> addRecipe(Recipe recipe) async {
    added.add(recipe);
    return recipe;
  }
  @override
  Future<List<Recipe>> importRecipesFromCsv(String csv) async => [];
  @override
  Future<String> exportRecipesToCsv(List<Recipe> recipes) async => '';
}

Widget _buildTestApp(Widget child, {RecipeProvider? provider}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => ChangeNotifierProvider<RecipeProvider>.value(
      value: provider ?? RecipeProvider(repository: _FakeRecipeRepo()),
      child: MaterialApp(home: child),
    ),
  );
}

void main() {
  group('AddRecipeScreen Functional Tests', () {
    testWidgets('renders all 7 recipe fields and Import CSV button', (tester) async {
      await tester.pumpWidget(_buildTestApp(const AddRecipeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Add New Recipe'), findsOneWidget);
      expect(find.text('Import CSV'), findsOneWidget);
      expect(find.text('Recipe Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
      expect(find.text('Ingredients (0)'), findsOneWidget);
      expect(find.text('Instructions / Steps (0)'), findsOneWidget);
      expect(find.text('Notes / Description'), findsOneWidget);
      expect(find.text('Prep Time (m)'), findsOneWidget);
      expect(find.text('Cook Time (m)'), findsOneWidget);
      expect(find.text('Servings'), findsOneWidget);
    });

    testWidgets('validates required fields and shows feedback', (tester) async {
      await tester.pumpWidget(_buildTestApp(const AddRecipeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Save Recipe'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter recipe title'), findsOneWidget);
    });

    testWidgets('opens CsvImportDialog when tapping Import CSV', (tester) async {
      await tester.pumpWidget(_buildTestApp(const AddRecipeScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Import CSV'));
      await tester.pumpAndSettle();

      expect(find.byType(CsvImportDialog), findsOneWidget);
      expect(find.text('Load Sample'), findsOneWidget);
    });
  });
}

