import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cooking_directory/core/managers/asset_manager.dart';
import 'package:cooking_directory/core/widgets/app_button.dart';
import 'package:cooking_directory/features/recipes/data/services/recipe_image_service.dart';
import 'package:cooking_directory/features/recipes/domain/entities/recipe.dart';
import 'package:cooking_directory/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:cooking_directory/features/recipes/presentation/providers/recipe_provider.dart';
import 'package:cooking_directory/features/recipes/presentation/screens/add_recipe_screen.dart';
import 'package:cooking_directory/features/recipes/presentation/widgets/csv_import_dialog.dart';

class _FakeRecipeImageService extends RecipeImageService {
  @override
  Future<String?> pickAndUploadImage(ImageSource source) async {
    return AssetManager.recipePlaceholder;
  }
}

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

    testWidgets('adds instruction step with # note and displays note tag', (tester) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(const AddRecipeScreen()));
      await tester.pumpAndSettle();

      final instField = find.widgetWithText(TextField, 'Step instruction (e.g. Crisp guanciale in pan)');
      final noteField = find.widgetWithText(TextField, 'Optional note / #tag (e.g. # Chef Tip: Render slowly)');

      await tester.enterText(instField, 'Crisp guanciale in skillet');
      await tester.enterText(noteField, '# Chef Tip: Render slowly on low heat');
      await tester.tap(find.text('Add Step to Recipe'));
      await tester.pumpAndSettle();

      expect(find.text('Instructions / Steps (1)'), findsOneWidget);
      expect(find.text('Crisp guanciale in skillet'), findsOneWidget);
      expect(find.text('# Chef Tip: Render slowly on low heat'), findsOneWidget);
    });

    testWidgets('supports selecting multiple quick tag chips and auto-commits pending step on Save', (tester) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = _FakeRecipeRepo();
      final provider = RecipeProvider(repository: fakeRepo);
      await tester.pumpWidget(_buildTestApp(const AddRecipeScreen(), provider: provider));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Recipe Title'), 'Authentic Carbonara');
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. 200g spaghetti'),
        '200g Spaghetti',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Step instruction (e.g. Crisp guanciale in pan)'),
        'Toss pasta with egg and pecorino off heat',
      );

      await tester.tap(find.widgetWithText(FilterChip, '# Low Heat'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Save Recipe'));
      await tester.pumpAndSettle();

      expect(fakeRepo.added, hasLength(1));
      expect(fakeRepo.added.first.ingredients, ['200g Spaghetti']);
      expect(fakeRepo.added.first.steps.first, contains('# Low Heat'));
    });

    testWidgets('uploads recipe photo from Gallery and saves imageUrl on Recipe', (tester) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = _FakeRecipeRepo();
      final provider = RecipeProvider(repository: fakeRepo);
      await tester.pumpWidget(
        _buildTestApp(
          AddRecipeScreen(imageService: _FakeRecipeImageService()),
          provider: provider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upload Recipe Photo'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Image URL'), findsOneWidget);

      await tester.tap(find.text('Gallery'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('remove_recipe_image_button')), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextFormField, 'Recipe Title'), 'Margherita Pizza');
      await tester.enterText(find.widgetWithText(TextField, 'e.g. 200g spaghetti'), 'Fresh Mozzarella');
      await tester.enterText(
        find.widgetWithText(TextField, 'Step instruction (e.g. Crisp guanciale in pan)'),
        'Bake at 250C for 8 minutes',
      );

      await tester.tap(find.widgetWithText(AppButton, 'Save Recipe'));
      await tester.pumpAndSettle();

      expect(fakeRepo.added, hasLength(1));
      expect(fakeRepo.added.first.imageUrl, AssetManager.recipePlaceholder);
    });
  });
}

