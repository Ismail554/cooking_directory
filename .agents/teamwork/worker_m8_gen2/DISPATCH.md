## 2026-11-10T16:59:18Z
You are worker_m8, a specialized Flutter Clean Architecture worker.

Workspace: d:\Ismail_flutter\cooking_directory
State folder: d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_m8_gen2
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
- `lib/features/app_shell/presentation/screens/app_shell.dart`
- `lib/core/routing/app_router.dart`
- `lib/features/cooking_mode/presentation/screens/cooking_mode_screen.dart`

REQUIREMENTS FOR MILESTONE M8 (Shell & Asset Adoption):
1. `app_shell.dart`:
   - Replace generic Material icons in `NavigationBar` destinations with branded culinary assets from `AssetManager`:
     - Expenses: `AssetManager.icExpense` (`assets/icons/ic_expense.png`) with color filter / tinting or clean image icon, with fallback to `Icons.account_balance_wallet_rounded`.
     - Recipes/Home: `AssetManager.icRecipe` (`assets/icons/ic_recipe.png`) with fallback to `Icons.restaurant_menu_rounded`.
     - Profile: `AssetManager.userAvatar` (`assets/images/default_avatar.png`) or `AssetManager.svgChefHat` (`assets/svgs/chef_hat.svg`) with fallback to `Icons.person_rounded`.
   - Wrap in Flutter's `PopScope` to handle system back navigation gracefully on Android:
     - If user is on Expenses (index 0) or Profile (index 2), back navigation switches back to Home/Recipes (index 1).
     - If user is already on Home (index 1), allows the pop.
   - Enforce strict < 200 lines per file discipline.
2. `cooking_mode_screen.dart`:
   - Create `CookingModeScreen` in `lib/features/cooking_mode/presentation/screens/cooking_mode_screen.dart`.
   - Accepts optional `String? recipeId` and `String? title`.
   - Clean Scaffold with AppBar, back button, step placeholder, and culinary theme tokens.
   - Enforce strict < 200 lines per file discipline.
3. `app_router.dart`:
   - Register route `/cooking-mode` (`AppRoutePaths.cookingMode`, name `AppRouteNames.cookingMode`) as a root pushed route pushing `CookingModeScreen` via `PageTransitions.cupertino`.
   - Add `errorBuilder: (context, state) => Scaffold(body: AppErrorView(title: 'Page Not Found', message: state.error?.message ?? 'The requested page was not found.', onRetry: () => context.go(AppRoutePaths.home)))`.
   - Ensure clean imports and zero warnings.
   - Enforce strict < 200 lines per file discipline.

VERIFICATION:
- Run `flutter analyze` and ensure 0 errors, 0 warnings.
- Run `flutter test` and ensure all tests pass (add shell tests in `test/features/` if appropriate).
- Write a detailed handoff report to `d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_m8_gen2\handoff.md` detailing changes, line counts, and verification output. Send a message when complete.
