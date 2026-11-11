## 2026-11-10T17:14:50Z

You are worker_m9, a specialized Flutter Clean Architecture worker.

Workspace: d:\Ismail_flutter\cooking_directory
State folder: d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_m9_gen2
Domain Skill: C:\Users\ismai\.gemini\config\skills\flutter-clean-feature\SKILL.md

MANDATORY FIRST STEPS:
1. Read the user request: `d:\Ismail_flutter\cooking_directory\.agents\teamwork\ORIGINAL_REQUEST.md`
2. Read the project scope: `d:\Ismail_flutter\cooking_directory\.agents\teamwork\orchestrator_gen2\PROJECT.md`
3. Read the explorer reports:
   - `d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_survey2_1\handoff.md`
   - `d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_survey2_2\handoff.md`
   - `d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_survey2_3\handoff.md`
4. Read your domain skill: `C:\Users\ismai\.gemini\config\skills\flutter-clean-feature\SKILL.md`

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

EXCLUSIVE FILE OWNERSHIP (You may only modify/create these files):
- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/features/home/presentation/widgets/home_header.dart`
- `lib/features/home/presentation/widgets/home_search_bar.dart`
- `lib/features/home/presentation/widgets/home_category_pills.dart`
- `lib/features/home/presentation/widgets/featured_recipe_card.dart`
- `lib/features/home/presentation/widgets/recipe_grid_card.dart`

REQUIREMENTS FOR MILESTONE M9 (Home Screen Modernization):
1. Decompose `home_screen.dart` (which was near the 200 LOC limit) into clean, focused sub-widgets in `lib/features/home/presentation/widgets/`:
   - `home_header.dart`: Displays greeting ("Hello, Chef Ismail"), inspirational culinary subtitle ("What are we cooking today?"), and user avatar using `AssetManager.userAvatar` (`assets/images/default_avatar.png`) with clean fallback. Theme-aware typography and padding.
   - `home_search_bar.dart`: Interactive search bar with search prefix icon, text controller, clear button, and filter tune button (`Icons.tune_rounded`). Uses `AppColors.culinaryCardShadow` or theme card color.
   - `home_category_pills.dart`: Horizontal category list (`All`, `Breakfast`, `Lunch`, `Dinner`, `Desserts`, `Healthy`) with interactive state selection, active pill gradient/background (`AppColors.primaryGradient` or `primary`), and theme-aware text.
   - `featured_recipe_card.dart`: Gastronomic hero card utilizing `AssetManager.recipePlaceholder` (`assets/images/recipe_placeholder.png`) with `AppColors.heroOverlayGradient`, rating star badge (`AppColors.ratingStar`, e.g. "4.9 (128)"), prep time badge (`AppColors.prepTimeTag`, `prepTimeText`, "25 min"), difficulty badge (`AppColors.difficultyMedium`), title, description, and bookmark/favorite button. Tapping navigates to `AppRoutePaths.recipeDetails`.
   - `recipe_grid_card.dart`: Compact recipe card with image, title, calories badge (`AppColors.calorieBadge`, `calorieText`), prep time, and tap navigation.
   - `home_screen.dart`: Assembles the decomposed widgets in a clean `CustomScrollView` / `ListView` with `RefreshIndicator` and FAB (`Icons.add_rounded`, label "New Recipe") navigating to `AppRoutePaths.addRecipe`. Keep `home_screen.dart` strictly < 150 lines!
2. Strict Architectural Constraints:
   - EVERY single file MUST be strictly < 200 lines.
   - Text widgets inside horizontal `Row`s must be wrapped in `Expanded` or `Flexible` to completely prevent any RenderFlex overflows.
   - Use centralized design tokens (`AppColors`, `AppSpacing`, `StyleManager`, `FontManager`, `ValueManager`, `AssetManager`).

VERIFICATION:
- Run `flutter analyze` and ensure 0 errors, 0 warnings.
- Run `flutter test` (add home screen widget tests in `test/features/home/home_screen_test.dart`).
- Write a detailed handoff report to `d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_m9_gen2\handoff.md` detailing changes, line counts, and verification output. Send a message when complete.
