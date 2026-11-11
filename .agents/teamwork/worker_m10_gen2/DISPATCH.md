## 2026-11-10T17:29:14Z

You are worker_m10, a specialized Flutter Clean Architecture worker.

Workspace: d:\Ismail_flutter\cooking_directory
State folder: d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_m10_gen2
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
- `lib/features/recipes/presentation/screens/recipe_details_screen.dart`
- `lib/features/recipes/presentation/screens/add_recipe_screen.dart`
- `lib/features/recipes/presentation/widgets/recipe_stats_bar.dart`
- `lib/features/recipes/presentation/widgets/ingredients_checklist.dart`
- `lib/features/recipes/presentation/widgets/instructions_timeline.dart`
- `lib/features/cooking_mode/presentation/screens/cooking_mode_screen.dart`

REQUIREMENTS FOR MILESTONE M10 (Recipe Details & Cooking Mode):
1. `recipe_details_screen.dart`:
   - Replace the 57-line stub with a rich culinary details screen using `CustomScrollView` and `SliverAppBar` with `AssetManager.recipePlaceholder`, hero gradient overlay, back button, and bookmark toggle button.
   - Decompose into modular widgets under `lib/features/recipes/presentation/widgets/`:
     - `recipe_stats_bar.dart`: Displays prep time (`AppColors.prepTimeTag`, `prepTimeText`), cook time, calories (`AppColors.calorieBadge`, `calorieText`), rating (`AppColors.ratingStar`), and difficulty badge (`AppColors.difficultyMedium`).
     - `ingredients_checklist.dart`: Interactive checklist of ingredients with checkboxes, servings stepper (- / +), and strike-through on check.
     - `instructions_timeline.dart`: Step-by-step cooking steps with circular numbered badges, instruction text, and timer suggestions.
   - Prominent bottom CTA button `AppButton` ("Start Cooking Mode", icon `Icons.play_arrow_rounded`, gradient `AppColors.primaryGradient`, shadow `AppColors.glowingOrangeShadow`) that navigates to `AppRoutePaths.cookingMode` with `id` and `title`.
   - Strictly < 200 lines for every single file.
2. `add_recipe_screen.dart`:
   - Fix the RenderFlex keyboard overflow hazard identified in the audit by wrapping the entire form layout in `SingleChildScrollView`.
   - Title, Description, Prep Time, Cook Time, Servings fields with culinary input decoration and validation.
   - Primary "Save Recipe" and Outlined "Cancel" buttons using `AppButton`.
   - Strictly < 200 lines.
3. `cooking_mode_screen.dart`:
   - Polish `CookingModeScreen` with wakelock management (wrap `WakelockPlus.enable()` and `disable()` in try/catch to be robust in headless/test environments), interactive timer chip, step advancement, and finish completion dialog.
   - Strictly < 200 lines.
4. Architectural Constraints:
   - EVERY file strictly < 200 lines.
   - All text in Rows wrapped in `Flexible` or `Expanded` to prevent RenderFlex overflows.
   - Centralized design tokens used throughout.

VERIFICATION:
- Run `flutter analyze` and ensure 0 errors, 0 warnings.
- Run `flutter test` (add widget tests in `test/features/recipes/recipe_details_test.dart`).
- Write a detailed handoff report to `d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_m10_gen2\handoff.md` detailing changes, line counts, and verification output. Send a message when complete.
