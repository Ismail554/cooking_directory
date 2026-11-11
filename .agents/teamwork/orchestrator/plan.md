# Implementation Plan: Cooking Directory Production Setup & Features

## Objective
Execute the four core requirements:
1. R1: Comprehensive Application Implementation Plan (/plan) document for Cooking Directory.
2. R2: Themed Asset Generation & Registration in `pubspec.yaml` matching `AssetManager`.
3. R3: Firebase Project Configuration for `cooking-directory-88438` via `flutterfire configure`.
4. R4: Recipe CSV Export in Settings following Clean Architecture and <200 lines/file.

## Milestones & Work Breakdown

### Milestone 1: Technical Survey & Codebase Exploration
- Dispatch Explorers to inspect:
  - Existing app structure, dependencies in `pubspec.yaml`, Flutter version, existing core managers (`AppColors`, `AssetManager`, `FontManager`, `StyleManager`, `ValueManager`, `AppSpacing`).
  - Current settings/profile screen, models, repositories, and navigation (`AppShell`).
  - Existing Firebase setup or flutterfire CLI availability.
  - Required asset paths, formats, dimensions, color tokens.

### Milestone 2: Comprehensive Application Implementation Plan (/plan)
- Synthesize technical survey and requirements into a detailed, structured implementation plan document (`docs/plan.md` or as designated by `/plan`).
- Cover:
  - Persistent shell navigation (`AppShell`) with Expenses, Home/Recipes, Profile/Settings.
  - Interactive Cooking Mode & Cooking Timers with step-by-step instructions, ingredient checklists, personal notes, multiple active timers, local notifications, `wakelock_plus`.
  - Backend integration (Firebase Auth, Cloud Firestore, Firebase Storage) & offline-first persistence (Hive CE / Isar).
  - Feature-First Clean Architecture (`presentation/`, `domain/`, `data/`) and <200 lines/file rule.
  - Phased rollout, data models, state management, dependency graph.

### Milestone 3: Themed Asset Generation & Registration
- Dispatch Worker to generate/acquire themed assets:
  - Images (`assets/images/`): `app_logo.png`, `splash_bg.png`, `recipe_placeholder.png`, `default_avatar.png`, `empty_state.png`.
  - Icons (`assets/icons/`): `ic_timer.png`, `ic_recipe.png`, `ic_expense.png`.
  - Vectors (`assets/svgs/`): `cooking_pot.svg`, `chef_hat.svg`, `no_data.svg`.
  - Animations (`assets/jsons/`): `cooking_anim.json`, `loading.json`.
- Ensure assets match `AppColors` palette and design tokens.
- Register all asset directories in `pubspec.yaml`.
- Dispatch Worker/Reviewer to verify asset resolution and test loading.

### Milestone 4: Firebase Configuration (cooking-directory-88438)
- Dispatch Worker to configure Firebase targeting project `cooking-directory-88438` using `flutterfire configure --project=cooking-directory-88438`.
- Ensure `lib/firebase_options.dart` is generated and verify Firebase initialization preparedness.

### Milestone 5: Recipe CSV Export Feature in Settings
- Dispatch Worker with domain skill `flutter-clean-feature`.
- Follow strict Clean Architecture:
  - Domain: `RecipeExportEntity`, `ExportRecipesUseCase`.
  - Data: `RecipeExportRepository`, `CsvExportService` (or data source).
  - Presentation: Controller/Cubit/Notifier + Settings Export UI widget / button.
- Ensure centralized managers are used (`AppColors`, `FontManager`, `StyleManager`, etc.).
- Enforce strict < 200 lines per file discipline.
- Handle CSV generation with standard/demo recipe columns (title, description, ingredients, steps, prep time, cook time, servings) and file saving/sharing.

### Milestone 6: Quality Verification, Review, Adversarial & Forensic Audit
- Dispatch Reviewers to inspect code quality, architecture adherence, <200 lines/file.
- Dispatch Challengers to run tests, asset verification, CSV export functionality tests, build check.
- Dispatch Forensic Auditor for integrity verification.
- Final gate verification and reporting back to parent.
