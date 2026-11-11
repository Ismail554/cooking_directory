## 2026-11-10T18:41:48Z

You are worker_remedy, a specialized Flutter Clean Architecture worker tasked with executing the comprehensive remediation for the Forensic Audit and Challenger findings.

Workspace: d:\Ismail_flutter\cooking_directory
State folder: d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_remedy_gen2
Domain Skill: C:\Users\ismai\.gemini\config\skills\flutter-clean-feature\SKILL.md

MANDATORY FIRST STEPS:
1. Read user request: `d:\Ismail_flutter\cooking_directory\.agents\teamwork\ORIGINAL_REQUEST.md`
2. Read project scope: `d:\Ismail_flutter\cooking_directory\.agents\teamwork\orchestrator_gen2\PROJECT.md`
3. Read the Auditor's report: `d:\Ismail_flutter\cooking_directory\.agents\teamwork\auditor_m12_gen2\handoff.md`
4. Read all three remediation explorer handoff reports:
   - `d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_remedy_1_gen2\handoff.md` (Asset Utilization)
   - `d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_remedy_2_gen2\handoff.md` (Layout Overflow & Flex Safety)
   - `d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_remedy_3_gen2\handoff.md` (Test Suite & Provider Scoping)

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

EXCLUSIVE FILE OWNERSHIP (You may modify/create these files):
- `lib/features/expenses/presentation/screens/expense_screen.dart`
- `lib/features/cooking_mode/presentation/screens/cooking_mode_screen.dart`
- `lib/features/cooking_mode/presentation/widgets/cooking_celebration_dialog.dart`
- `lib/features/home/presentation/widgets/home_header.dart`
- `lib/features/home/presentation/widgets/featured_recipe_card.dart`
- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/features/profile/presentation/widgets/profile_header.dart`
- `lib/features/profile/presentation/widgets/export_recipes_tile.dart`
- `lib/features/profile/presentation/screens/profile_screen.dart`
- `lib/app/app.dart`
- `test/widget_test.dart`
- `test/features/app_shell/app_shell_test.dart`
- `test/features/expenses/expense_screen_test.dart`

YOUR REMEDIATION TASKS:

1. REMEDIATION 1: COMPLETE ASSET ADOPTION ACROSS ACTIVE UI
Genuinely utilize all 13 assets across active UI screens:
- `cooking_anim.json` (`AssetManager.lottieCooking`): Create `lib/features/cooking_mode/presentation/widgets/cooking_celebration_dialog.dart` (render `Lottie.asset(AssetManager.lottieCooking)` with fallback) and invoke it when the user completes cooking in `CookingModeScreen`.
- `cooking_pot.svg` (`AssetManager.svgCookingPot`): Mount `SvgPicture.asset(AssetManager.svgCookingPot)` in `CookingModeScreen` instruction card header and/or `HomeHeader`.
- `chef_hat.svg` (`AssetManager.svgChefHat`): Mount `SvgPicture.asset(AssetManager.svgChefHat)` in `ProfileHeader` role badge next to "Executive Chef".
- `app_logo.png` (`AssetManager.appLogo`): Mount in `HomeHeader` brand crest and/or in `ProfileScreen` app branding card.
- `splash_bg.png` (`AssetManager.splashBackground`): Mount in `ProfileScreen` app branding card backdrop.
- `no_data.svg` (`AssetManager.svgNoData`): Mount `AppEmptyView(illustrationPath: AssetManager.svgNoData)` in `ExpenseScreen` when category filter has no expenses.
- `empty_state.png` (`AssetManager.emptyStateIllustration`): Mount `AppEmptyView` in `HomeScreen` when recipe search / category has no recipes.
- `loading.json` (`AssetManager.lottieLoading`): Mount `AppLoadingView` in `HomeScreen` or refresh states.

2. REMEDIATION 2: ELIMINATE RENDERFLEX OVERFLOW & HARDEN FLEX SAFETY
- In `expense_screen.dart:85:11`: In `_buildBudgetCard()`, wrap `Text('Monthly Food Budget')` in `Expanded(child: Text(..., maxLines: 1, overflow: TextOverflow.ellipsis))` and add `AppSpacing.gapW8`.
- In `cooking_mode_screen.dart`: In the step progress row, wrap `Text('Step ${_currentStep + 1} of $totalSteps')` in `Expanded` with ellipsis. Wrap quick timer dialog title in `Flexible`.
- In `featured_recipe_card.dart`: Convert badge Row to `Wrap(spacing: 8.w, runSpacing: 4.h, ...)` for complete overflow immunity.

3. REMEDIATION 3: TEST SUITE & PROVIDER SCOPING
- In `test/widget_test.dart:15`: Update smoke test assertion to match the modernized UI (`find.text('Hello, Chef Ismail')` or `find.byType(HomeHeader)`).
- In `lib/app/app.dart`: Provide `RecipeExportProvider` at the root `MultiProvider` so all screens and shell branches inherit it.
- In `export_recipes_tile.dart`: Make provider lookup safe using `Provider.of<RecipeExportProvider?>(context)` or graceful fallback if provider is not present in isolated test harnesses.
- In `featured_recipe_card.dart`: Safe `onTap` using `try { context.push(AppRoutePaths.recipeDetails); } catch (_) {}` and reorder Stack so bookmark favorite button reliably receives tap events.
- In `app_shell_test.dart` and `expense_screen_test.dart`: Ensure test wrappers pump cleanly without provider errors or overflow assertions.

STRICT CONSTRAINT:
EVERY single file MUST remain strictly < 200 lines! Check every line count.

VERIFICATION:
- Run `flutter analyze` and ensure 0 errors, 0 warnings.
- Run `flutter test` and ensure all tests pass.
- Write a detailed handoff report to `d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_remedy_gen2\handoff.md`.
