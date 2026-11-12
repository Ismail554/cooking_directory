import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cooking_directory/core/managers/asset_manager.dart';
import 'package:cooking_directory/core/theme/theme_provider.dart';
import 'package:cooking_directory/features/authentication/domain/entities/auth_user.dart';
import 'package:cooking_directory/features/authentication/domain/repositories/auth_repository.dart';
import 'package:cooking_directory/features/authentication/presentation/providers/auth_provider.dart';
import 'package:cooking_directory/features/profile/presentation/screens/profile_screen.dart';
import 'package:cooking_directory/features/profile/presentation/widgets/preference_dialogs.dart';
import 'package:cooking_directory/features/profile/presentation/widgets/profile_header.dart';
import 'package:cooking_directory/features/recipes/domain/entities/recipe.dart';
import 'package:cooking_directory/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:cooking_directory/features/recipes/domain/usecases/export_recipes_to_csv_usecase.dart';
import 'package:cooking_directory/features/recipes/presentation/providers/recipe_export_provider.dart';
import 'package:cooking_directory/features/recipes/presentation/providers/recipe_provider.dart';

class _StubRepo implements RecipeRepository {
  @override Future<List<Recipe>> getAllRecipes() async => [];
  @override Future<String> exportRecipesToCsv(List<Recipe> recipes) async => '';
  @override Future<Recipe> addRecipe(Recipe recipe) async => recipe;
  @override Future<List<Recipe>> importRecipesFromCsv(String csvContent) async => [];
}

class _StubAuthRepo implements AuthRepository {
  @override Stream<AuthUser?> get authStateChanges => Stream.value(null);
  @override Stream<String?> get idTokenChanges => Stream.value(null);
  @override AuthUser? get currentUser => null;
  @override Future<String?> getIdToken({bool forceRefresh = false}) async => null;
  @override Future<AuthUser?> signInWithEmail(String email, String password) async => null;
  @override Future<AuthUser?> registerWithEmail(String name, String email, String password) async => null;
  @override Future<AuthUser?> signInWithGoogle() async => null;
  @override Future<AuthUser?> signInAnonymously() async => null;
  @override Future<void> signOut() async {}
}

class _StubUseCase extends ExportRecipesToCsvUseCase {
  _StubUseCase() : super(_StubRepo());
  @override
  Future<String> call({List<Recipe>? recipes}) async => '/stub/path.csv';
}

Widget _buildTestApp(Widget child, {ThemeProvider? themeProvider}) {
  final exportProvider = RecipeExportProvider(exportUseCase: _StubUseCase());
  final recipeProvider = RecipeProvider(repository: _StubRepo());
  final authProvider = AuthProvider(repository: _StubAuthRepo());
  final tp = themeProvider ?? ThemeProvider();

  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MultiProvider(
      providers: [
        ChangeNotifierProvider<RecipeExportProvider>.value(value: exportProvider),
        ChangeNotifierProvider<RecipeProvider>.value(value: recipeProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: tp),
      ],
      child: MaterialApp(home: child),
    ),
  );
}

void main() {
  group('ProfileHeader Widget Tests', () {
    testWidgets('renders avatar, name, email, role, and PRO badge', (tester) async {
      await tester.pumpWidget(_buildTestApp(const Scaffold(body: ProfileHeader())));
      await tester.pumpAndSettle();

      expect(find.text('Chef Ismail'), findsOneWidget);
      expect(find.text('ismail@example.com'), findsOneWidget);
      expect(find.text('Executive Chef'), findsOneWidget);
      expect(find.text('PRO'), findsOneWidget);

      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.backgroundImage, isA<AssetImage>());
      expect((avatar.backgroundImage as AssetImage).assetName, AssetManager.userAvatar);
    });

    testWidgets('does not overflow with very long name and email in row layout', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_buildTestApp(const Scaffold(body: ProfileHeader(
        name: 'Chef Bartholomew Alexander The Gastronomic Master of Culinary Sciences',
        email: 'bartholomew.alexander.gastronomic.master@world-culinary-directory.org',
      ))));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('PreferenceDialogs Unit & Widget Tests', () {
    testWidgets('showDietaryPreferencesDialog displays options and saves choices', (tester) async {
      List<String>? saved;
      await tester.pumpWidget(_buildTestApp(Scaffold(body: Builder(builder: (ctx) => ElevatedButton(
        onPressed: () => PreferenceDialogs.showDietaryPreferencesDialog(ctx, selectedOptions: ['Halal'], onSave: (l) => saved = l),
        child: const Text('Open Dietary'),
      )))));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dietary'));
      await tester.pumpAndSettle();
      expect(find.text('Dietary Preferences'), findsOneWidget);
      expect(find.text('Halal'), findsOneWidget);

      await tester.tap(find.text('Vegetarian'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(saved, containsAll(['Halal', 'Vegetarian']));
    });

    testWidgets('showCurrencyBudgetDialog modifies currency and budget limit', (tester) async {
      String? savedCurr;
      double? savedBudget;
      await tester.pumpWidget(_buildTestApp(Scaffold(body: Builder(builder: (ctx) => ElevatedButton(
        onPressed: () => PreferenceDialogs.showCurrencyBudgetDialog(ctx, currentCurrency: 'USD (\$)', currentBudget: 1200.0, onSave: (c, b) {
          savedCurr = c;
          savedBudget = b;
        }),
        child: const Text('Open Currency'),
      )))));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Currency'));
      await tester.pumpAndSettle();
      expect(find.text('EUR (€)'), findsOneWidget);

      await tester.tap(find.text('EUR (€)'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '1500');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedCurr, 'EUR (€)');
      expect(savedBudget, 1500.0);
    });

    testWidgets('showSignOutDialog displays confirmation and triggers callback', (tester) async {
      var confirmed = false;
      await tester.pumpWidget(_buildTestApp(Scaffold(body: Builder(builder: (ctx) => ElevatedButton(
        onPressed: () => PreferenceDialogs.showSignOutDialog(ctx, onConfirm: () => confirmed = true),
        child: const Text('Open Sign Out'),
      )))));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Sign Out'));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure you want to sign out of your chef profile?'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Out'));
      await tester.pumpAndSettle();
      expect(confirmed, isTrue);
    });
  });

  group('ProfileScreen Integration Tests', () {
    testWidgets('renders all sections, tiles, and toggles dark theme switch', (tester) async {
      await tester.pumpWidget(_buildTestApp(const ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Chef Profile'), findsOneWidget);
      expect(find.byType(ProfileHeader), findsOneWidget);
      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Dietary Preferences'), findsOneWidget);
      expect(find.text('Currency & Budget'), findsOneWidget);
      expect(find.text('DATA & BACKUP'), findsOneWidget);
      expect(find.text('Export Recipes (CSV)'), findsOneWidget);
      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);

      final switchFinder = find.byType(SwitchListTile);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(find.text('Dark theme active'), findsOneWidget);

      await tester.ensureVisible(find.text('Sign Out'));
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure you want to sign out of your chef profile?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });
}
