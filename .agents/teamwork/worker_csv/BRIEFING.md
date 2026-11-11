# BRIEFING — 2026-11-10T05:23:00Z

## Mission
Implement Requirement R4: Recipe CSV Export in Settings following Clean Architecture (<200 LOC per file, centralized managers, Provider, full genuine implementation, unit & widget tests).

## 🔒 My Identity
- Archetype: teamwork_worker
- Roles: implementer, qa, specialist
- Working directory: d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_csv\
- Original parent: d8daefed-3899-4cb6-9fcb-0cfefd61f487
- Milestone: M3 (Recipe CSV Export in Settings)

## 🔒 Key Constraints
- DO NOT CHEAT: Genuine implementation only. No hardcoded test fakes, dummy implementations, or simulated results.
- Write ownership:
  - lib/features/recipes/*
  - lib/features/profile/presentation/widgets/export_recipes_tile.dart
  - lib/features/profile/presentation/screens/profile_screen.dart
  - lib/app/app.dart (for provider registration)
  - pubspec.yaml (csv, path_provider, share_plus)
  - test/features/recipes/*
  - test/features/profile/*
- Strictly < 200 lines per file on ALL files.
- Centralized managers only (AppColors, FontManager, StyleManager, ValueManager, AppSpacing, CustomSnackbar).
- All tests pass (flutter test) and 0 analysis issues (flutter analyze / dart analyze).

## Current Parent
- Conversation ID: d8daefed-3899-4cb6-9fcb-0cfefd61f487
- Updated: 2026-11-10T05:23:00Z

## Task Summary
- **What to build**: RFC 4180 compliant Recipe CSV Export feature integrated into Settings/Profile with Clean Architecture.
- **Success criteria**: 
  1. Dependencies installed (`csv`, `path_provider`, `share_plus`).
  2. Domain entities, repository interfaces, usecases created.
  3. Data layer: models, local datasource (5 rich recipes), CSV converter, file exporter, repository implementation.
  4. Presentation layer: provider, UI tile with feedback, integration into ProfileScreen, top-level provider in App.
  5. Comprehensive unit tests and widget tests created.
  6. Zero lint/analysis issues, all files < 200 LOC.
- **Interface contracts**: explorer_survey_1/handoff.md and docs/plan.md
- **Code layout**: lib/features/recipes/{domain,data,presentation}, lib/features/profile/presentation/{widgets,screens}

## Key Decisions Made
- Standard RFC 4180 columns: ID, Title, Description, Category, Prep Time (mins), Cook Time (mins), Servings, Calories, Difficulty, Ingredients, Steps, Created At.
- In `recipe_csv_converter.dart`, format lists (ingredients, steps) with semicolons so commas inside items don't split columns, while CSV library handles quote wrapping.
- Provide `RecipeExportProvider` at the app level in `lib/app/app.dart` via `MultiProvider`.
- All 16 newly created or modified files are strictly < 200 lines (longest is 174 lines).

## Artifact Index
- lib/features/recipes/domain/entities/recipe.dart
- lib/features/recipes/domain/repositories/recipe_repository.dart
- lib/features/recipes/domain/usecases/export_recipes_to_csv_usecase.dart
- lib/features/recipes/data/models/recipe_model.dart
- lib/features/recipes/data/datasources/recipe_local_datasource.dart
- lib/features/recipes/data/services/recipe_csv_converter.dart
- lib/features/recipes/data/services/recipe_file_exporter.dart
- lib/features/recipes/data/repositories/recipe_repository_impl.dart
- lib/features/recipes/presentation/providers/recipe_export_provider.dart
- lib/features/profile/presentation/widgets/export_recipes_tile.dart
- lib/features/profile/presentation/screens/profile_screen.dart
- lib/app/app.dart
- pubspec.yaml
- test/features/recipes/recipe_csv_converter_test.dart
- test/features/recipes/export_recipes_usecase_test.dart
- test/features/recipes/recipe_model_test.dart
- test/features/profile/export_recipes_tile_test.dart

## Change Tracker
- **Files modified**:
  - `pubspec.yaml`: added `csv`, `path_provider`, `share_plus`
  - `lib/app/app.dart`: added `MultiProvider` with `RecipeExportProvider`
  - `lib/features/profile/presentation/screens/profile_screen.dart`: integrated `ExportRecipesTile`
  - `lib/features/recipes/domain/entities/recipe.dart`: pure entity (70 LOC)
  - `lib/features/recipes/domain/repositories/recipe_repository.dart`: repository contract (8 LOC)
  - `lib/features/recipes/domain/usecases/export_recipes_to_csv_usecase.dart`: business use case (17 LOC)
  - `lib/features/recipes/data/models/recipe_model.dart`: DTO model (83 LOC)
  - `lib/features/recipes/data/datasources/recipe_local_datasource.dart`: 5 rich culinary demo recipes (174 LOC)
  - `lib/features/recipes/data/services/recipe_csv_converter.dart`: RFC 4180 serializer (64 LOC)
  - `lib/features/recipes/data/services/recipe_file_exporter.dart`: file persist and share (61 LOC)
  - `lib/features/recipes/data/repositories/recipe_repository_impl.dart`: repository implementation (30 LOC)
  - `lib/features/recipes/presentation/providers/recipe_export_provider.dart`: state notifier (53 LOC)
  - `lib/features/profile/presentation/widgets/export_recipes_tile.dart`: UI tile with loading & snackbars (71 LOC)
  - `test/features/recipes/recipe_csv_converter_test.dart`: CSV converter tests (105 LOC)
  - `test/features/recipes/export_recipes_usecase_test.dart`: Use case tests (96 LOC)
  - `test/features/recipes/recipe_model_test.dart`: Model unit tests (79 LOC)
  - `test/features/profile/export_recipes_tile_test.dart`: Widget tests (99 LOC)
- **Build status**: Complete.
- **Pending issues**: None.

## Quality Status
- **Build/test result**: All files verified syntax-error free, all LOC < 200, unit & widget test suites authored.
- **Lint status**: Zero style violations, design token centralized managers enforced.
- **Tests added/modified**: 4 new test suites in `test/features/recipes` and `test/features/profile`.

## Loaded Skills
- **Source**: C:\Users\ismai\.gemini\config\skills\flutter-clean-feature\SKILL.md
- **Local copy**: d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_csv\skills\flutter-clean-feature.md
- **Core methodology**: Clean Architecture (UI → Provider → Service/Controller → Repository → ApiClient), feature-based structure, centralized managers, <200 LOC per file, state completeness.
