# UI, Layout & Asset Audit Report: Cooking Directory

**Agent**: `explorer_survey2_2` (UI & Asset Layout Auditor)  
**Date**: 2026-11-10T16:40:00Z  
**Workspace**: `d:\Ismail_flutter\cooking_directory`  
**State Folder**: `d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_survey2_2`  
**Parent Conversation**: `71c15362-7bff-44cc-a765-bc34858e1e37`  
**Mode**: Read-Only Architecture & Layout Audit  

---

## 1. Observation

### 1.1 Complete Asset Inventory & Codebase Disconnect
- **FileSystem & Inventory**:
  `Get-ChildItem -Recurse assets` and `test/core/assets_test.dart` prove that all 13 declared assets exist on disk with non-zero size, valid binary signatures, and valid formats:
  - **Images** (`assets/images/`):
    - `app_logo.png` (93,111 bytes) — Valid 8-byte PNG header (`0x89 0x50 0x4E 0x47 0x0D 0x0A 0x1A 0x0A`)
    - `splash_bg.png` (28,920 bytes) — Valid PNG header
    - `recipe_placeholder.png` (15,863 bytes) — Valid PNG header
    - `default_avatar.png` (26,307 bytes) — Valid PNG header
    - `empty_state.png` (27,144 bytes) — Valid PNG header
  - **Icons** (`assets/icons/`):
    - `ic_timer.png` (12,744 bytes) — Valid PNG header
    - `ic_recipe.png` (4,177 bytes) — Valid PNG header
    - `ic_expense.png` (8,873 bytes) — Valid PNG header
  - **Vectors** (`assets/svgs/`):
    - `cooking_pot.svg` (1,830 bytes) — Valid XML vector (`viewBox="0 0 100 100"`)
    - `chef_hat.svg` (1,553 bytes) — Valid XML vector (`viewBox="0 0 100 100"`)
    - `no_data.svg` (3,086 bytes) — Valid XML vector (`viewBox="0 0 200 200"`)
  - **Animations** (`assets/jsons/`):
    - `cooking_anim.json` (50,965 bytes) — Valid 60fps Bodymovin specification
    - `loading.json` (23,261 bytes) — Valid 60fps Bodymovin specification
- **Registration**:
  `pubspec.yaml` lines 43–47 registers all 4 asset directories:
  ```yaml
    assets:
      - assets/images/
      - assets/icons/
      - assets/svgs/
      - assets/jsons/
  ```
- **Codebase Disconnect (Critical Finding)**:
  Executing a recursive search across all Dart files in `lib/`:
  `Get-ChildItem -Recurse -Filter "*.dart" lib | Select-String -Pattern "AssetManager|SvgPicture|Lottie|Image\.asset|assets\/"`
  reveals **AssetManager is ONLY referenced within `lib/core/managers/asset_manager.dart` (lines 3–28)**.
  **Zero (0) out of 13 assets are currently rendered in any screen or widget in `lib/`**.
  Specifically:
  - `home_screen.dart` (line 159) renders `Icon(Icons.restaurant_menu_rounded)` instead of `AssetManager.recipePlaceholder`.
  - `profile_screen.dart` (line 54) renders `Icon(Icons.person)` inside `CircleAvatar` instead of `AssetImage(AssetManager.userAvatar)`.
  - `app_shell.dart` (lines 31–55) renders standard Material Icons (`Icons.account_balance_wallet_outlined`, `Icons.menu_book_outlined`, `Icons.person_outline`) instead of `AssetManager.icExpense`, `AssetManager.icRecipe`, or `AssetManager.svgChefHat`.
  - `app_empty_view.dart` (lines 41–45) renders `Icon(icon, size: AppIconSize.s48)` instead of `AssetManager.emptyStateIllustration` or `AssetManager.svgNoData`.
  - `app_loading_view.dart` (lines 24–27) renders `CircularProgressIndicator` instead of `Lottie.asset(AssetManager.lottieLoading)` or `AssetManager.lottieCooking`.
  - `features/splash/`, `features/cooking_mode/`, `features/cooking_timer/`, and `features/authentication/` contain only empty `.gitkeep` files, completely omitting `splash_bg.png`, `app_logo.png`, `cooking_anim.json`, and `ic_timer.png`.

---

### 1.2 RenderFlex Overflow Hazards & Sizing Defects

#### Hazard 1: Unscrollable Form Columns Causing Bottom Overflow on Keyboard Open
1. **`lib/features/recipes/presentation/screens/add_recipe_screen.dart` (lines 23–49)**:
   ```dart
   body: SafeArea(
     child: Padding(
       padding: AppSpacing.screenPadding,
       child: Column(
         children: [
           TextField(decoration: InputDecoration(labelText: 'Recipe Title', ...)),
           AppSpacing.gapH16,
           TextField(maxLines: 3, decoration: InputDecoration(labelText: 'Description', ...)),
           const Spacer(),
           AppButton(text: 'Save Recipe', onPressed: () => Navigator.of(context).pop()),
         ],
       ),
     ),
   )
   ```
   - **Mechanism**: The root layout is an unscrollable `Column` containing two text fields and `const Spacer()`.
   - **Defect**: When soft keyboard opens (`resizeToAvoidBottomInset: true`), available screen height drops below ~360dp. In landscape orientation or on screens < 5.5 inches, `AppBar` (56dp) + vertical padding (32dp) + Title Field (64dp) + gap (16dp) + Description Field (96dp) + Button (48dp) = 312dp + keyboard (300+dp) exceeds viewport, triggering:  
     `A RenderFlex overflowed by xxx pixels on the bottom`.
2. **`lib/features/expenses/presentation/screens/add_expense_screen.dart` (lines 23–51)**:
   ```dart
   body: SafeArea(
     child: Padding(
       padding: AppSpacing.screenPadding,
       child: Column(
         children: [
           TextField(decoration: InputDecoration(labelText: 'Title / Description', ...)),
           AppSpacing.gapH16,
           TextField(keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Amount ($)', ...)),
           const Spacer(),
           AppButton(text: 'Save Expense', onPressed: () => Navigator.of(context).pop()),
         ],
       ),
     ),
   )
   ```
   - **Mechanism**: Identical failure pattern. Unscrollable `Column` with `const Spacer()` collapses and overflows when the numeric keyboard pops up.
3. **`lib/features/recipes/presentation/screens/recipe_details_screen.dart` (lines 30–55)**:
   ```dart
   body: SafeArea(
     child: Padding(
       padding: AppSpacing.screenPadding,
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text('Creamy Tuscan Garlic Chicken', style: getBoldStyle(...)),
           AppSpacing.gapH8,
           Text('Tender chicken breasts in a rich garlic...', style: getRegularStyle(...)),
           const Spacer(),
           AppButton(text: 'Start Cooking Mode', icon: Icons.play_arrow_rounded, onPressed: () {}),
         ],
       ),
     ),
   )
   ```
   - **Mechanism**: A non-scrollable `Column` with `Spacer()`. Any addition of recipe ingredients, step checklists, or hero images causes instant RenderFlex overflow on standard mobile screens.

#### Hazard 2: Unconstrained Horizontal Row Causing Right Overflow
- **`lib/features/profile/presentation/screens/profile_screen.dart` (lines 48–75)**:
  ```dart
  Widget _buildUserHeader() {
    return Row(
      children: [
        CircleAvatar(radius: 36, backgroundColor: AppColors.primaryContainer, child: ...),
        AppSpacing.gapW16,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chef Ismail', style: getBoldStyle(fontSize: FontSize.s18)),
            AppSpacing.gapH4,
            Text('ismail@example.com', style: getRegularStyle(fontSize: FontSize.s13, ...)),
          ],
        ),
      ],
    );
  }
  ```
  - **Mechanism**: The `Column` inside `Row` is **NOT wrapped in `Expanded` or `Flexible`**.
  - **Defect**: When a user has a long name, a long email address (e.g. `ismail.chef.kitchen@gastronomy-directory.org`), or when the device accessibility text scale factor is enlarged (> 1.2x), the `Column` expands unbounded horizontally, triggering:  
    `A RenderFlex overflowed by xxx pixels on the right`.

#### Hazard 3: Button Inner Row Overflow Risk
- **`lib/core/widgets/app_button.dart` (lines 85–101)**:
  ```dart
  if (icon != null) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: AppIconSize.s18, color: textColor),
        AppSpacing.gapW8,
        Text(text, style: getSemiBoldStyle(fontSize: FontSize.s15, color: textColor)),
      ],
    );
  }
  ```
  - **Mechanism**: When `AppButton` has an explicit narrow width (e.g., `width: 120.w`) or a long label, `Text` is not wrapped in `Flexible(child: Text(..., overflow: TextOverflow.ellipsis))`, causing an inner Row RenderFlex overflow.

#### Hazard 4: AppBar Title Two-Line Vertical Overflow Hazard
- **`lib/features/home/presentation/screens/home_screen.dart` (lines 17–35)**:
  `AppBar.title` contains a two-line `Column` (`Cooking Directory` + `What do you want to cook today?`) inside standard 56dp `kToolbarHeight`. On small devices with 1.3x accessibility font scaling, the text clips vertically.

---

### 1.3 Systemic Theme Incoherence & Dark Mode Contrast Failures
- **Root Cause in `lib/core/managers/style_manager.dart` (lines 28, 44, 60, 76, 92, 108)**:
  ```dart
  TextStyle getRegularStyle({double? fontSize, Color color = AppColors.textPrimaryLight, ...})
  TextStyle getMediumStyle({double? fontSize, Color color = AppColors.textPrimaryLight, ...})
  TextStyle getSemiBoldStyle({double? fontSize, Color color = AppColors.textPrimaryLight, ...})
  TextStyle getBoldStyle({double? fontSize, Color color = AppColors.textPrimaryLight, ...})
  ```
  Every single typography helper function sets its default color parameter to `AppColors.textPrimaryLight` (`#1A1A1A`).
- **Hardcoded Invocations in Screens**:
  - `home_screen.dart` (lines 24, 31): `color: AppColors.textPrimaryLight`, `color: AppColors.textSecondaryLight`
  - `recipe_details_screen.dart` (line 26): `color: AppColors.textPrimaryLight`
  - `add_recipe_screen.dart` (line 19): `color: AppColors.textPrimaryLight`
  - `expense_screen.dart` (line 21): `color: AppColors.textPrimaryLight`
  - `add_expense_screen.dart` (line 19): `color: AppColors.textPrimaryLight`
  - `profile_screen.dart` (lines 20, 81, 86): `color: AppColors.textPrimaryLight`
  - `app_empty_view.dart` (lines 38, 53, 63): `color: AppColors.surfaceVariantLight`, `AppColors.textPrimaryLight`
  - `app_error_view.dart` (lines 51, 60): `color: AppColors.textPrimaryLight`
  - `export_recipes_tile.dart` (lines 23, 29, 36): `color: AppColors.textPrimaryLight`
- **Impact in Dark Mode**:
  When user enables Dark Theme (`ThemeMode.dark`), scaffold background changes to `AppColors.backgroundDark` (`#121212`), but text remains forced to `#1A1A1A` (charcoal black). The contrast ratio drops to ~1.1:1, completely failing WCAG accessibility requirements and making text unreadable.

---

### 1.4 File Length & Clean Architecture Compliance
- We audited the line counts of all Dart files across `lib/`:
  - `lib/features/home/presentation/screens/home_screen.dart`: **189 lines** (5 lines away from the 200-line ceiling!)
  - `lib/features/recipes/data/datasources/recipe_local_datasource.dart`: **174 lines**
  - `lib/features/expenses/presentation/screens/expense_screen.dart`: **131 lines**
  - `lib/core/managers/style_manager.dart`: **112 lines**
  - `lib/core/routing/app_router.dart`: **108 lines**
  - `lib/core/widgets/app_button.dart`: **102 lines**
  - All other files: **< 90 lines**
- **Finding**: Currently, 100% of Dart files obey `< 200 lines per file`. However, `home_screen.dart` (189 lines) cannot accommodate rich cards or filters without immediately breaching 200 lines; it must be decomposed into modular widgets under `lib/features/home/presentation/widgets/`.

---

## 2. Logic Chain

1. **Premise 1 (Asset Verification)**: All 13 culinary assets (`.png`, `.svg`, `.json`) exist in `assets/`, are registered in `pubspec.yaml`, and pass format and integrity checks in `test/core/assets_test.dart`.
2. **Premise 2 (Presentation Disconnect)**: Because no presentation widget imports `AssetManager` or loads assets via `Image.asset`, `SvgPicture.asset`, or `Lottie.asset`, the app visually appears as a prototype with unbranded generic Flutter Material icons.
3. **Premise 3 (Keyboard Resize Mechanics)**: In Flutter, `Scaffold.resizeToAvoidBottomInset` defaults to `true`. When a soft keyboard opens inside an unscrollable `Column` containing multiple inputs and a `Spacer()`, the viewport height shrinks and cannot accommodate the content, causing `RenderFlex overflow` exceptions on `AddRecipeScreen` and `AddExpenseScreen`.
4. **Premise 4 (Flex Row Layout Rules)**: An unconstrained `Column` child inside a horizontal `Row` has an unbounded maximum width constraint (`double.infinity`). Without `Expanded` or `Flexible`, long text strings in `ProfileScreen._buildUserHeader()` cause horizontal RenderFlex overflows.
5. **Premise 5 (Theme Token Resolution)**: By defaulting font helper parameters to `AppColors.textPrimaryLight` instead of `null` or `Theme.of(context).colorScheme.onSurface`, all text widgets hardcode light mode colors, breaking visual legibility in Dark Mode.
6. **Premise 6 (Clean Architecture < 200 Lines)**: Because `home_screen.dart` is at 189 lines, implementing modern rich culinary components (hero card, category pills with count badges, difficulty chips) directly in `home_screen.dart` will violate the architectural rule. Decomposing it into standalone sub-widgets under `lib/features/home/presentation/widgets/` keeps all files strictly under 200 lines.

---

## 3. Caveats

1. **Network Image Fallbacks**: In production, recipes may fetch remote URLs from Firebase Storage. A robust widget should load network images with `Image.network` / `cached_network_image` and use `AssetManager.recipePlaceholder` as the `errorBuilder` and `loadingBuilder` fallback.
2. **ScreenUtil Initialization in Tests**: Standalone widget tests that instantiate widgets containing `.w`, `.h`, `.sp`, or `.r` must wrap the test widget in `ScreenUtilInit` with `designSize: const Size(375, 812)` to prevent null/zero dimension errors.
3. **No Unhandled Compilation Errors**: Dart analysis (`dart-mcp-server:analyze_files`) currently reports "No errors". All identified defects are layout, sizing, theming, and asset connection defects that occur at runtime.

---

## 4. Conclusion & Actionable Remediation Blueprint

### Core Defect Summary & Fix Matrix

| Defect # | Target File & Lines | Severity | Exact Defect | Actionable Remediation |
|---|---|---|---|---|
| **D1** | `lib/features/recipes/presentation/screens/add_recipe_screen.dart:23–49` | High | RenderFlex bottom overflow when soft keyboard opens (unscrollable `Column` + `Spacer()`). | Wrap body in `SingleChildScrollView(physics: BouncingScrollPhysics())` or `CustomScrollView`, replace `Spacer()` with `AppSpacing.gapH24`. |
| **D2** | `lib/features/expenses/presentation/screens/add_expense_screen.dart:23–51` | High | RenderFlex bottom overflow when numeric keyboard opens (unscrollable `Column` + `Spacer()`). | Wrap body in `SingleChildScrollView`, add category dropdown selector with `AppColors.expense*` color dots. |
| **D3** | `lib/features/recipes/presentation/screens/recipe_details_screen.dart:30–55` | High | Unscrollable `Column` + `Spacer()`; stub lacks image, ingredients checklist, and step timeline. | Refactor to `CustomScrollView` with `SliverAppBar` featuring `AssetManager.recipePlaceholder`, add ingredients checklist and step cards. |
| **D4** | `lib/features/profile/presentation/screens/profile_screen.dart:48–75` | High | Horizontal RenderFlex overflow on right for long name/email (unconstrained `Column` inside `Row`). | Wrap `Column` in `Expanded`, replace generic icon with `CircleAvatar(backgroundImage: AssetImage(AssetManager.userAvatar))`. |
| **D5** | `lib/core/widgets/app_button.dart:85–101` | Medium | Inner `Row` RenderFlex overflow when button width is constrained. | Wrap `Text(text, ...)` in `Flexible(child: Text(text, overflow: TextOverflow.ellipsis))`. |
| **D6** | `lib/features/home/presentation/screens/home_screen.dart:152–165` | Medium | Recipe card renders flat peach box with `Icons.restaurant_menu_rounded` instead of food photography. | Replace with `ClipRRect(borderRadius: AppBorderRadius.r12, child: Image.asset(AssetManager.recipePlaceholder, fit: BoxFit.cover, height: 160))`. |
| **D7** | `lib/features/app_shell/presentation/screens/app_shell.dart:31–55` | Medium | Bottom navigation tabs use generic Material icons instead of branded asset icons. | Use `Image.asset(AssetManager.icExpense, width: 24, height: 24)` and `AssetManager.icRecipe`. |
| **D8** | `lib/core/widgets/app_empty_view.dart:41–45` | Medium | Uses generic `Icon(icon)` instead of culinary illustrations. | Support `AssetManager.emptyStateIllustration` and `AssetManager.svgNoData` via `SvgPicture.asset`. |
| **D9** | `lib/core/widgets/app_loading_view.dart:24–27` | Medium | Uses default `CircularProgressIndicator` instead of animated culinary Lottie. | Render `Lottie.asset(AssetManager.lottieLoading, width: 120, height: 120)` with fallback. |
| **D10** | `lib/core/managers/style_manager.dart:28,44,60,76` | High | Default parameter `color = AppColors.textPrimaryLight` breaks Dark Mode text contrast. | Change default color to `null` and allow inheritance from `Theme.of(context).colorScheme.onSurface`. |
| **D11** | `lib/features/home/presentation/screens/home_screen.dart:1–189` | Medium | Approaching 200-line ceiling (189 lines). | Extract `HomeSearchBar`, `HomeCategoryPills`, `FeaturedRecipeCard`, and `HomeHeader` into `features/home/presentation/widgets/`. |

---

## 5. Verification Method

1. **Static Analysis & Diagnostics**:
   Execute `dart-mcp-server:analyze_files` on `file:///d:/Ismail_flutter/cooking_directory`. Ensure zero errors and zero warnings.
2. **Asset Resolution Verification**:
   Verify every asset referenced by path resolves cleanly via `rootBundle.load()` in `test/core/assets_test.dart`.
3. **Line Count Verification Script**:
   Run in PowerShell:
   ```powershell
   Get-ChildItem -Recurse -Filter "*.dart" lib | ForEach-Object {
       $cnt = (Get-Content $_.FullName | Measure-Object -Line).Lines
       if ($cnt -ge 200) { [PSCustomObject]@{ File = $_.FullName; Lines = $cnt } }
   }
   ```
   Must return 0 records (all files strictly < 200 lines).
4. **Layout & Keyboard Overflow Verification**:
   Pump `AddRecipeScreen` and `AddExpenseScreen` inside a test widget with small viewport (`Size(320, 480)`) and simulated bottom inset (`viewInsets: EdgeInsets.only(bottom: 280)`):
   ```dart
   tester.view.physicalSize = const Size(1080, 1920);
   tester.view.viewInsets = const FakeViewPadding(bottom: 800);
   await tester.pumpWidget(const MaterialApp(home: AddRecipeScreen()));
   expect(tester.takeException(), isNull);
   ```
5. **Dark Mode Text Contrast Verification**:
   Render `ProfileScreen`, `HomeScreen`, and `AppEmptyView` under `ThemeMode.dark`. Verify that `DefaultTextStyle` or text elements inherit `AppColors.textPrimaryDark` (`#EEEEEE`) and maintain a contrast ratio >= 4.5:1 against `AppColors.backgroundDark` (`#121212`).
