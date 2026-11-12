import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cooking_directory/features/profile/presentation/widgets/export_recipes_tile.dart';
import 'package:cooking_directory/features/recipes/domain/entities/recipe.dart';
import 'package:cooking_directory/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:cooking_directory/features/recipes/domain/usecases/export_recipes_to_csv_usecase.dart';
import 'package:cooking_directory/features/recipes/presentation/providers/recipe_export_provider.dart';

class StubRepository implements RecipeRepository {
  @override
  Future<List<Recipe>> getAllRecipes() async => [];

  @override
  Future<String> exportRecipesToCsv(List<Recipe> recipes) async => '';

  @override
  Future<Recipe> addRecipe(Recipe recipe) async => recipe;

  @override
  Future<List<Recipe>> importRecipesFromCsv(String csvContent) async => [];
}

class FakeExportUseCase extends ExportRecipesToCsvUseCase {
  final Future<String> Function() onCall;

  FakeExportUseCase(this.onCall) : super(StubRepository());

  @override
  Future<String> call({List<Recipe>? recipes}) => onCall();
}

Widget buildTestableTile({required RecipeExportProvider provider}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, child) {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<RecipeExportProvider>.value(
            value: provider,
            child: const ExportRecipesTile(),
          ),
        ),
      );
    },
  );
}

void main() {
  group('ExportRecipesTile Widget Tests', () {
    testWidgets('renders tile elements in initial idle state', (tester) async {
      final provider = RecipeExportProvider(
        exportUseCase: FakeExportUseCase(() async => '/fake/recipes_export.csv'),
      );

      await tester.pumpWidget(buildTestableTile(provider: provider));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.file_download_outlined), findsOneWidget);
      expect(find.text('Export Recipes (CSV)'), findsOneWidget);
      expect(
        find.text('Export culinary catalog in standard CSV format'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows loading spinner during export and snackbar on success',
        (tester) async {
      final completer = Completer<String>();
      final provider = RecipeExportProvider(
        exportUseCase: FakeExportUseCase(() => completer.future),
      );

      await tester.pumpWidget(buildTestableTile(provider: provider));
      await tester.pumpAndSettle();

      // Tap tile to trigger export
      await tester.tap(find.text('Export Recipes (CSV)'));
      await tester.pump(); // Start export frame

      // Loading state: spinner visible, chevron hidden
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);

      // Complete the export
      completer.complete('/storage/recipes_export_20261110_120000.csv');
      await tester.pumpAndSettle();

      // Success snackbar is displayed
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.textContaining('recipes_export_20261110_120000.csv'),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('displays error snackbar when export fails', (tester) async {
      final provider = RecipeExportProvider(
        exportUseCase: FakeExportUseCase(
          () async => throw StateError('No recipes available to export'),
        ),
      );

      await tester.pumpWidget(buildTestableTile(provider: provider));
      await tester.pumpAndSettle();

      // Tap tile to trigger export
      await tester.tap(find.text('Export Recipes (CSV)'));
      await tester.pumpAndSettle();

      // Error snackbar appears
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('No recipes available to export'),
        findsOneWidget,
      );
    });
  });
}
