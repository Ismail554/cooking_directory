# Milestone M12 Forensic Integrity Audit Report

**Auditor**: `auditor_m12` (Forensic Integrity Auditor)  
**Date**: 2026-11-10T18:30:00Z  
**Workspace**: `d:\Ismail_flutter\cooking_directory`  
**State Folder**: `d:\Ismail_flutter\cooking_directory\.agents\teamwork\auditor_m12_gen2`  
**Parent Conversation ID**: `8c5eeb85-17e1-41c1-8a10-7d0288d144fc`  
**Target**: Milestone M7 through M11 Deliverables  
**Integrity Mode**: Development Mode (from `ORIGINAL_REQUEST.md`)  
**Verdict**: **`INTEGRITY VIOLATION`** (Work Product Rejected)

---

## Forensic Audit Summary

| Check # | Audit Dimension | Status | Key Evidence / Finding |
|---|---|---|---|
| **Check 1** | Anti-Cheat Verification (`lib/`) | **PASS** | Zero mocks, fakes, dummy facades, or hardcoded return stubs in production source code (`lib/`). All entities, services, and models perform real work. |
| **Check 2** | Asset Utilization Integrity (13 Assets) | **FAIL** | Only 5 of 13 assets are rendered on active UI screens (`recipe_placeholder.png`, `default_avatar.png`, `ic_timer.png`, `ic_recipe.png`, `ic_expense.png`). 6 assets have **zero references in `lib/`** (`app_logo.png`, `splash_bg.png`, `cooking_pot.svg`, `chef_hat.svg`, `no_data.svg`, `cooking_anim.json`). 2 assets (`empty_state.png`, `loading.json`) exist only in utility widgets (`AppEmptyView`, `AppLoadingView`) that are never mounted in any screen tree. |
| **Check 3** | Architectural Constraint (< 200 LOC) | **PASS** | 56 of 56 Dart files in `lib/` strictly comply with `< 200 lines per file` (0 violations; longest is `featured_recipe_card.dart` at 185 lines). |
| **Check 4** | Defect Remediation (Explorer Survey) | **PARTIAL** | The 11 reported defects (keyboard overflows, unconstrained row in profile header, dark mode contrast, route `/cooking-mode`, `PopScope`, `errorBuilder`) were patched. However, a **new unconstrained Row RenderFlex overflow** was introduced in `expense_screen.dart:85:11` (`A RenderFlex overflowed by 71 pixels on the right`). |
| **Check 5** | Empirical Test Execution | **FAIL** | `test/widget_test.dart:15` fails with `expect(find.text('Cooking Directory'), findsOneWidget)` due to un-updated smoke test assertion after `HomeScreen` modernization. |

**Final Binary Verdict**: **`INTEGRITY VIOLATION`**  
*Per forensic protocol: If ANY check fails, the verdict is INTEGRITY VIOLATION and the work product must be rejected.*

---

## 1. Observation

### 1.1 Anti-Cheat Verification (Source Code Analysis)
- **Scan Command**:
  ```powershell
  Get-ChildItem -Path lib -Recurse -Filter *.dart | Select-String -Pattern "Mock|Fake|dummy|facade|TODO|FIXME|throw UnimplementedError|return const SizedBox\(\)"
  ```
- **Direct Output**:
  Only standard form field validation returns in `lib/core/validation/validator.dart:7,18,28` (`return null;`).
- **Inspection of Data & Presentation Layers**:
  - `RecipeLocalDataSourceImpl` (`lib/features/recipes/data/datasources/recipe_local_datasource.dart`): Real seed list of 5 culinary recipes with full ingredient and step arrays.
  - `RecipeCsvConverter` (`lib/features/recipes/data/services/recipe_csv_converter.dart`): Genuine RFC 4180 CSV serialization with 12 standard columns.
  - `RecipeFileExporter` (`lib/features/recipes/data/services/recipe_file_exporter.dart`): Real file I/O using `path_provider` and `share_plus`.
  - All screens (`HomeScreen`, `RecipeDetailsScreen`, `CookingModeScreen`, `ExpenseScreen`, `ProfileScreen`) build rich, genuine widget trees with full styling and interactivity. Zero dummy stubs or fake facades exist in `lib/`.

### 1.2 Asset Utilization Audit (13 Assets in AssetManager)
We performed an exhaustive empirical scan for every asset constant declared in `lib/core/managers/asset_manager.dart`:

```powershell
$assets = @("appLogo", "splashBackground", "recipePlaceholder", "userAvatar", "emptyStateIllustration", "icTimer", "icRecipe", "icExpense", "svgCookingPot", "svgChefHat", "svgNoData", "lottieCooking", "lottieLoading")
```

**Verbatim Scan Results**:
1. `appLogo` (`assets/images/app_logo.png`):
   - `lib/` references: **0**.
   - UI screen usage: **NONE**. `lib/features/splash/presentation/screens/` contains only an empty `.gitkeep`.
2. `splashBackground` (`assets/images/splash_bg.png`):
   - `lib/` references: **0**.
   - UI screen usage: **NONE**.
3. `recipePlaceholder` (`assets/images/recipe_placeholder.png`):
   - `lib/` references: **3** (`featured_recipe_card.dart:30`, `recipe_grid_card.dart:26`, `recipe_details_screen.dart:102`).
   - UI screen usage: Rendered as hero and card image with `AppColors.heroOverlayGradient`.
4. `userAvatar` (`assets/images/default_avatar.png`):
   - `lib/` references: **3** (`app_shell.dart:49`, `home_header.dart:21`, `profile_header.dart:48`).
   - UI screen usage: Rendered in bottom nav bar, home header, and profile header.
5. `emptyStateIllustration` (`assets/images/empty_state.png`):
   - `lib/` references: **1** (`app_empty_view.dart:87`).
   - UI screen usage: **NONE**. `AppEmptyView` is defined but **never instantiated or mounted** in any screen in `lib/`.
6. `icTimer` (`assets/icons/ic_timer.png`):
   - `lib/` references: **1** (`cooking_mode_screen.dart:116`).
   - UI screen usage: Rendered in `ActionChip` inside `CookingModeScreen` AppBar.
7. `icRecipe` (`assets/icons/ic_recipe.png`):
   - `lib/` references: **2** (`app_shell.dart:112, 117`).
   - UI screen usage: Rendered in `AppShell` bottom navigation tab.
8. `icExpense` (`assets/icons/ic_expense.png`):
   - `lib/` references: **2** (`app_shell.dart:99, 104`).
   - UI screen usage: Rendered in `AppShell` bottom navigation tab.
9. `svgCookingPot` (`assets/svgs/cooking_pot.svg`):
   - `lib/` references: **0**.
   - UI screen usage: **NONE**.
10. `svgChefHat` (`assets/svgs/chef_hat.svg`):
    - `lib/` references: **0**.
    - UI screen usage: **NONE**.
11. `svgNoData` (`assets/svgs/no_data.svg`):
    - `lib/` references: **0**.
    - UI screen usage: **NONE**.
12. `lottieCooking` (`assets/jsons/cooking_anim.json`):
    - `lib/` references: **0**.
    - UI screen usage: **NONE**.
13. `lottieLoading` (`assets/jsons/loading.json`):
    - `lib/` references: **1** (`app_loading_view.dart:39`).
    - UI screen usage: **NONE**. `AppLoadingView` is defined but **never instantiated or mounted** in any screen in `lib/`.

**Finding**: Check 2 explicitly mandated: *"Verify that all 13 assets in AssetManager are genuinely utilized across the UI screens"*. Only 5 of the 13 assets are utilized on active UI screens; 6 assets have 0 references in `lib/`, and 2 assets reside in unmounted utility views.

### 1.3 Architectural Constraint Audit (< 200 Lines Per File)
- **Scan Command**:
  ```powershell
  Get-ChildItem -Path lib -Recurse -Filter *.dart | Where-Object { (Get-Content $_.FullName).Count -ge 200 }
  ```
- **Direct Output**:
  `Total files >= 200 lines: 0` (Total Dart files in `lib/`: 56).
- **Distribution**:
  - `featured_recipe_card.dart`: 185 lines (PASS)
  - `cooking_mode_screen.dart`: 181 lines (PASS)
  - `recipe_local_datasource.dart`: 174 lines (PASS)
  - `expense_screen.dart`: 158 lines (PASS)
  - `recipe_details_screen.dart`: 155 lines (PASS)
  - `recipe_stats_bar.dart`: 155 lines (PASS)
  - `app_button.dart`: 153 lines (PASS)
  - `ingredients_checklist.dart`: 151 lines (PASS)
  - `profile_screen.dart`: 144 lines (PASS)
  - `home_search_bar.dart`: 142 lines (PASS)
  - All other 46 files: < 140 lines.
- **Finding**: 100% compliance with `< 200 lines per file`.

### 1.4 Defect Remediation & Active Layout Violations
We verified all 11 defects noted by `explorer_survey2_2` and `explorer_survey2_3`:
1. `AddRecipeScreen` keyboard overflow: **FIXED**. Wrapped in `SingleChildScrollView(physics: BouncingScrollPhysics())`, `Spacer()` removed (`add_recipe_screen.dart:77`).
2. `AddExpenseScreen` keyboard overflow: **FIXED**. Wrapped in `SingleChildScrollView`, `Spacer()` removed, validation added (`add_expense_screen.dart:42`).
3. `ProfileHeader` unconstrained row: **FIXED**. Text Column wrapped in `Expanded`, Name wrapped in `Flexible` (`profile_header.dart:53, 60`).
4. `StyleManager` dark mode contrast: **FIXED**. Default color changed from `AppColors.textPrimaryLight` to `null` with dynamic `Theme.of(context).colorScheme.onSurface` resolution (`style_manager.dart:25-169`).
5. `HomeScreen` line count: **FIXED**. Decomposed into 5 modular sub-widgets (`home_header.dart`, `home_search_bar.dart`, `home_category_pills.dart`, `featured_recipe_card.dart`, `recipe_grid_card.dart`), reducing `home_screen.dart` from 195 to 113 lines.
6. Unregistered `/cooking-mode` route: **FIXED**. Registered in `app_router.dart:102-117` with Cupertino transitions.
7. Missing `errorBuilder` in `AppRouter`: **FIXED**. Registered at `app_router.dart:29-35` rendering `AppErrorView`.
8. Missing `PopScope` in `AppShell`: **FIXED**. Wrapped at `app_shell.dart:82-89`, redirecting back-press to index 1 (Home).
9. `RecipeDetailsScreen` stub: **FIXED**. Upgraded with `CustomScrollView`, `SliverAppBar`, `RecipeStatsBar`, `IngredientsChecklist`, `InstructionsTimeline`, and CTA.
10. `AppButton` inner row overflow risk: **FIXED**. Inner text wrapped in `Flexible(child: Text(..., overflow: TextOverflow.ellipsis))` (`app_button.dart:138`).
11. Missing asset illustrations in `AppEmptyView` & `AppLoadingView`: **FIXED in widgets**. Connected to `emptyStateIllustration` and `lottieLoading`.

**Active Layout Violation Discovered in M11 Deliverable**:
- **Location**: `lib/features/expenses/presentation/screens/expense_screen.dart:85:11`
- **Code**:
  ```dart
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text('Monthly Food Budget', style: getMediumStyle(fontSize: FontSize.s13, color: Colors.white70)),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        decoration: BoxDecoration(color: Colors.white24, borderRadius: AppBorderRadius.r8),
        child: Text('40% spent', style: getBoldStyle(fontSize: FontSize.s11, color: Colors.white)),
      ),
    ],
  )
  ```
- **Violation**: `Text('Monthly Food Budget')` inside `Row` is **NOT wrapped in `Expanded` or `Flexible`**.
- **Empirical Failure**: On small screens and widget tests, this triggers:
  ```
  A RenderFlex overflowed by 71 pixels on the right.
  Row:file:///D:/Ismail_flutter/cooking_directory/lib/features/expenses/presentation/screens/expense_screen.dart:85:11
  ```
  This breaches layout rule `PROJECT.md:60`: *"Any text Column inside a Row must be wrapped in Expanded or Flexible"*.

### 1.5 Test Suite Regression Discovery
- **Location**: `test/widget_test.dart:15`
- **Code**:
  ```dart
  expect(find.text('Cooking Directory'), findsOneWidget);
  ```
- **Empirical Failure**: `HomeScreen` modernization replaced the `'Cooking Directory'` AppBar title with `HomeHeader` ("Hello, Chef Ismail" and "What are we cooking today?"). Running `widget_test.dart` fails because `'Cooking Directory'` no longer exists on screen.

---

## 2. Logic Chain

1. **Premise 1 (Ground-Truth Dispatch Constraints)**:
   The auditor's dispatch assignment mandates:
   - Check 1: Anti-cheat verification (genuine implementations, no mocks/dummy returns).
   - Check 2: Asset Integrity: *"Verify that all 13 assets in AssetManager are genuinely utilized across the UI screens"*.
   - Check 3: Line count compliance: `< 200 lines per file`.
   - Check 4: Defect matrix remediation across all explorer survey findings.
   - Core forensic rule: *"If ANY check fails, your verdict is INTEGRITY VIOLATION and you MUST reject the work product."*

2. **Premise 2 (Empirical Asset Analysis)**:
   Observation 1.2 proves that only 5 of 13 assets are utilized on active UI screens (`recipe_placeholder.png`, `default_avatar.png`, `ic_timer.png`, `ic_recipe.png`, `ic_expense.png`).
   6 assets (`app_logo.png`, `splash_bg.png`, `cooking_pot.svg`, `chef_hat.svg`, `no_data.svg`, `cooking_anim.json`) have 0 references across the entire production codebase in `lib/`.
   2 assets (`empty_state.png`, `loading.json`) are only referenced in `AppEmptyView` and `AppLoadingView`, which are completely unmounted utility widgets.
   Therefore, Check 2 definitively fails.

3. **Premise 3 (Layout Overflow Safety Violation)**:
   Observation 1.4 proves that `lib/features/expenses/presentation/screens/expense_screen.dart:85:11` contains an unconstrained `Text` inside a horizontal `Row`, causing an active `RenderFlex overflowed by 71 pixels on the right`. This violates the explicit architectural rule in `PROJECT.md:60` and the user requirement that screens render without layout overflows.

4. **Premise 4 (Test Suite Regression)**:
   Observation 1.5 proves that `test/widget_test.dart:15` contains a failing assertion due to un-updated text matchers following `HomeScreen` refactoring.

5. **Conclusion**:
   Because Check 2 fails (incomplete asset adoption across UI screens), a new layout overflow exists in `ExpenseScreen`, and `test/widget_test.dart` fails, the forensic integrity criteria are not satisfied. The mandatory binary verdict is **`INTEGRITY VIOLATION`**.

---

## 3. Caveats

1. **Worker Intent & Milestone Scope**:
   The workers for M7, M8, M9, M10, and M11 accurately delivered the specific sub-tasks assigned to them by the orchestrator. They did not fabricate results or install deliberate backdoors. The failure to adopt all 13 assets stems from orchestrator milestone scheduling (which omitted tasks to wire `app_logo.png`, `splash_bg.png`, `cooking_pot.svg`, `chef_hat.svg`, `no_data.svg`, and `cooking_anim.json` into screens), conflicting with the comprehensive audit mission constraint.
2. **Static Analysis & Architecture**:
   Static analysis (`dart-mcp-server:analyze_files`) reports 0 errors and 0 warnings. All 56 Dart files in `lib/` are strictly < 200 lines. The code quality, Clean Architecture layering, and CSV export functionality are genuine and high-grade.

---

## 4. Conclusion & Required Remediations

The work product submitted for Milestone M12 is **REJECTED** with verdict **`INTEGRITY VIOLATION`**.

To achieve a **`CLEAN`** verdict, the following 3 remediation items must be completed:

1. **Remediation 1 (Asset Utilization)**:
   - Wire `AssetManager.appLogo` and `splashBackground` into a splash view or `AppShell` header.
   - Wire `AssetManager.svgCookingPot` or `svgChefHat` into `HomeScreen` or `CookingModeScreen`.
   - Wire `AssetManager.svgNoData` or `emptyStateIllustration` via `AppEmptyView` into `ExpenseScreen` or recipe search when no items match.
   - Wire `AssetManager.lottieCooking` into `CookingModeScreen` or `AppLoadingView`.
2. **Remediation 2 (ExpenseScreen Flex Safety)**:
   - In `lib/features/expenses/presentation/screens/expense_screen.dart:85–107`, wrap `Text('Monthly Food Budget')` in `Expanded(child: Text(...))` to eliminate the 71px RenderFlex right overflow.
3. **Remediation 3 (Widget Smoke Test Update)**:
   - Update `test/widget_test.dart:15` to assert for `'Hello, Chef Ismail'` or `HomeHeader` instead of the deprecated static title `'Cooking Directory'`.

---

## 5. Verification Method

To independently reproduce every finding:

1. **Verify Asset Absence in `lib/`**:
   ```powershell
   Get-ChildItem -Path lib -Recurse -Filter *.dart | Select-String -Pattern "appLogo|splashBackground|svgCookingPot|svgChefHat|svgNoData|lottieCooking"
   ```
   *Expected Output*: Only definitions in `lib/core/managers/asset_manager.dart` appear. Zero usages in screens.

2. **Verify Line Count Compliance (< 200 lines)**:
   ```powershell
   Get-ChildItem -Path lib -Recurse -Filter *.dart | Where-Object { (Get-Content $_.FullName).Count -ge 200 }
   ```
   *Expected Output*: 0 records returned.

3. **Verify ExpenseScreen RenderFlex Overflow**:
   Inspect line 85 of `lib/features/expenses/presentation/screens/expense_screen.dart` and note that `Text('Monthly Food Budget')` is not enclosed in `Expanded` or `Flexible`.

4. **Verify Smoke Test Failure**:
   Inspect `test/widget_test.dart:15` matching against `'Cooking Directory'` and note that `home_screen.dart` no longer renders this string.
