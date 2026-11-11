# Dispatch: Worker Recipe CSV Export in Settings

**Role**: Clean Architecture Flutter Feature Developer (`teamwork_worker`)
**Working Directory**: d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_csv\
**Original Request**: d:\Ismail_flutter\cooking_directory\.agents\teamwork\ORIGINAL_REQUEST.md
**Architecture Specifications**:
- d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_survey_1\handoff.md
- d:\Ismail_flutter\cooking_directory\docs\plan.md
**Domain Skill**: C:\Users\ismai\.gemini\config\skills\flutter-clean-feature\SKILL.md

## Objective
Implement Requirement R4: Add an option in Settings/Profile allowing users to export all recipes at once to a CSV file in a standard/demo format, following strict Clean Architecture (`flutter-clean-feature`) and maintaining strict `< 200 lines per file` discipline.

### 1. Dependencies
Add to `pubspec.yaml`:
- `csv: ^6.0.0`
- `path_provider: ^2.1.5`
- `share_plus: ^10.1.3`
Run `flutter pub get`.

### 2. Domain Layer
- `lib/features/recipes/domain/entities/recipe.dart`:
  - Fields: `id`, `title`, `description`, `category`, `prepTimeMinutes`, `cookTimeMinutes`, `servings`, `calories`, `difficulty`, `ingredients` (List<String>), `steps` (List<String>), `isFavorite`, `createdAt`.
- `lib/features/recipes/domain/repositories/recipe_repository.dart`:
  - Abstract interface: `Future<List<Recipe>> getAllRecipes();` and `Future<String> exportRecipesToCsv(List<Recipe> recipes);`.
- `lib/features/recipes/domain/usecases/export_recipes_to_csv_usecase.dart`:
  - Retrieves recipes, validates non-empty list, calls repository export, returns result path.

### 3. Data Layer
- `lib/features/recipes/data/models/recipe_model.dart`:
  - DTO extending/converting to `Recipe` entity, with `fromJson`, `toJson`, `toEntity`, `fromEntity`.
- `lib/features/recipes/data/datasources/recipe_local_datasource.dart`:
  - Provides rich seed catalog of at least 5 standard culinary recipes (e.g. Creamy Tuscan Garlic Chicken, Classic Beef Bolognese, Mediterranean Quinoa Salad, Berry Avocado Smoothie Bowl, Homemade Margherita Pizza).
- `lib/features/recipes/data/services/recipe_csv_converter.dart`:
  - Serializes list of recipes into RFC 4180 CSV string with headers:
    `ID`, `Title`, `Description`, `Category`, `Prep Time (mins)`, `Cook Time (mins)`, `Servings`, `Calories`, `Difficulty`, `Ingredients`, `Steps`, `Created At`.
  - Properly formats ingredients and steps (e.g., delimited or quoted) so commas do not corrupt columns.
- `lib/features/recipes/data/services/recipe_file_exporter.dart`:
  - Saves CSV string to device directory (via `path_provider`) with timestamped name `recipes_export_YYYYMMDD_HHmmss.csv` and triggers `share_plus` file dialog (with fallback to returning file path).
- `lib/features/recipes/data/repositories/recipe_repository_impl.dart`:
  - Implements `RecipeRepository` connecting datasource, CSV converter, and file exporter.

### 4. Presentation Layer
- `lib/features/recipes/presentation/providers/recipe_export_provider.dart`:
  - `ChangeNotifier` state: `ExportStatus { initial, exporting, success, error }`, `String? exportedFilePath`, `String? errorMessage`.
  - Method: `Future<bool> exportAllRecipes()`.
- `lib/features/profile/presentation/widgets/export_recipes_tile.dart`:
  - UI ListTile adhering to centralized design tokens (`AppColors`, `FontManager`, `StyleManager`, `ValueManager`, `AppSpacing`).
  - Loading indicator during export; displays `CustomSnackbar.showSuccess` with file path on success, or `CustomSnackbar.showError` on failure.
- `lib/features/profile/presentation/screens/profile_screen.dart`:
  - Integrate `ExportRecipesTile` into settings options list.
- Provide `RecipeExportProvider` at the top level or feature level (e.g., in `MultiProvider` in `lib/app/app.dart` or within `ProfileScreen`).

### 5. Automated Verification & Testing
- Write unit tests in `test/features/recipes/recipe_csv_converter_test.dart` verifying RFC 4180 compliance, header correctness, row counts, and comma handling.
- Write unit tests in `test/features/recipes/export_recipes_usecase_test.dart`.
- Write widget tests in `test/features/profile/export_recipes_tile_test.dart` verifying tile rendering and user interaction.
- Run `flutter test` and `flutter analyze` to ensure zero warnings or errors.

### 6. Strict Discipline
- EVERY file must be strictly `< 200 lines`.
- Use centralized managers exclusively: `AppColors`, `FontManager`, `StyleManager`, `ValueManager`, `AppSpacing`, `CustomSnackbar`.
- No dummy/facade implementations.


## 2026-11-10T05:01:39Z
You are Worker: Clean Architecture Flutter Feature Developer (teamwork_worker).
Your working directory is: d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_csv\
You MUST read d:\Ismail_flutter\cooking_directory\.agents\teamwork\ORIGINAL_REQUEST.md before starting work.
Also read your assignment in d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_csv\DISPATCH.md.
Also read the domain skill:
C:\Users\ismai\.gemini\config\skills\flutter-clean-feature\SKILL.md
and the architectural design in:
d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_survey_1\handoff.md
d:\Ismail_flutter\cooking_directory\docs\plan.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Your write ownership:
- `lib/features/recipes/*`
- `lib/features/profile/presentation/widgets/export_recipes_tile.dart`
- `lib/features/profile/presentation/screens/profile_screen.dart`
- `lib/app/app.dart` (if registering providers)
- `pubspec.yaml` (adding csv, path_provider, share_plus)
- `test/features/recipes/*`
- `test/features/profile/*`
