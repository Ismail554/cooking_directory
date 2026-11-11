# BRIEFING — 2026-11-10T18:41:00Z

## Mission
Investigate test suite and provider scoping remediation (smoke test regression, ProfileScreen RecipeExportProvider scoping, FeaturedRecipeCard GoRouter fallback) and formulate precise, concrete fix specifications.

## 🔒 My Identity
- Archetype: explorer
- Roles: investigation, synthesis
- Working directory: d:\Ismail_flutter\cooking_directory
- State folder: d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_remedy_3_gen2
- Original parent: 8c5eeb85-17e1-41c1-8a10-7d0288d144fc
- Milestone: Remediation 3 (Test Suite & Provider Scoping)

## 🔒 Key Constraints
- Read-only investigation — do NOT implement code changes in the project codebase.
- Write analysis and specifications to `.agents/teamwork/explorer_remedy_3_gen2/` only.

## Current Parent
- Conversation ID: 8c5eeb85-17e1-41c1-8a10-7d0288d144fc
- Updated: 2026-11-10T18:41:00Z

## Investigation State
- **Explored paths**: `test/widget_test.dart`, `lib/app/app.dart`, `lib/bootstrap.dart`, `lib/core/routing/app_router.dart`, `lib/features/profile/presentation/screens/profile_screen.dart`, `lib/features/profile/presentation/widgets/export_recipes_tile.dart`, `test/features/app_shell/app_shell_test.dart`, `test/features/profile/profile_screen_test.dart`, `test/features/profile/export_recipes_tile_test.dart`, `lib/features/home/presentation/widgets/featured_recipe_card.dart`, `test/features/home/home_screen_test.dart`.
- **Key findings**:
  1. `test/widget_test.dart:15` fails because `'Cooking Directory'` was replaced with `HomeHeader` ("Hello, Chef Ismail").
  2. `ProviderNotFoundException` occurs in `app_shell_test.dart` because tests pumped `MaterialApp.router(routerConfig: AppRouter.router)` without root `MultiProvider(RecipeExportProvider)`. Furthermore, `ExportRecipesTile` uses non-nullable `context.watch<RecipeExportProvider>()`.
  3. In `FeaturedRecipeCard`, full-card `InkWell` at the end of the `Stack` intercepts clicks intended for the bookmark button, and when tapped outside GoRouter context, throws `assert(debugCheckHasGoRouter(context))`.
- **Unexplored areas**: None. All root causes, file locations, line numbers, and concrete fix snippets are determined.

## Key Decisions Made
- Formulate 3-pronged remediation plan:
  1. Update `test/widget_test.dart:15` to match `HomeHeader` ("Hello, Chef Ismail") and `HomeScreen`.
  2. Make `ExportRecipesTile` defensively use `Provider.of<RecipeExportProvider?>(context)` and wrap `MaterialApp.router` in `test/features/app_shell/app_shell_test.dart` with `MultiProvider` containing `RecipeExportProvider`.
  3. Reorder `FeaturedRecipeCard` `Stack` so full-card `InkWell` sits beneath interactive elements, wrap non-interactive labels in `IgnorePointer`, and add safe navigation handler using `GoRouter.maybeOf(context)` and `try/catch`.

## Artifact Index
- DISPATCH.md — incoming dispatch record
- BRIEFING.md — persistent state
- progress.md — liveness heartbeat
- handoff.md — final handoff report
