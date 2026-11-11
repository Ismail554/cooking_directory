# UI Modernization & Spec Mining Report: Cooking Directory

**Date**: 2026-11-10  
**Author**: UI Reference & Spec Miner (`explorer_survey2_1`)  
**Workspace**: `d:\Ismail_flutter\cooking_directory`  
**State Folder**: `d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_survey2_1`  
**Reference Benchmark**: Modern Culinary Design System (ChatGPT Share `6af28f3c-da28-83e8-a422-b3173e4950e0`, Hungry UI Kit, Kitchen Stories, NYT Cooking)

---

## 1. Executive Summary & Aesthetic Architecture

The Cooking Directory Flutter application aims to be a premier culinary companion featuring recipe discovery, meal budgeting, interactive step-by-step cooking mode with simultaneous timers, and catalog management.

While the fundamental token skeleton in `lib/core/` (warm terracotta primary `#E65100`, fresh sage secondary `#2E7D32`, warm cream background `#FBF9F6`, and ScreenUtil responsive scaling) establishes an authentic gastronomic foundation, **the current UI implementation is severely underdeveloped and disconnected from its own assets**:
1. **Asset Disconnect**: All 13 required assets (PNGs, SVGs, Lotties) exist in `assets/` and are declared in `AssetManager`, but **0 out of 13 are currently utilized in the UI screens**. The app currently renders generic Flutter Material icons and solid color placeholders instead of food photography and branded assets.
2. **Screen Stubs**: `RecipeDetailsScreen` (57 lines), `AddRecipeScreen` (53 lines), `AddExpenseScreen` (54 lines) are minimal stubs lacking ingredient checklists, instruction steps, hero banners, and category selectors.
3. **Missing Modules**: `cooking_mode` and `cooking_timer` contain only `.gitkeep` placeholders without UI screens or routing.
4. **Theme Incoherence**: Text helpers in `style_manager.dart` and reusable views (`AppEmptyView`, `AppErrorView`) hardcode light palette colors (`textPrimaryLight`, `surfaceVariantLight`), degrading legibility in Dark Mode.
5. **Modern Culinary Polish**: Missing gradient fills, warm card drop shadows, difficulty tags, star rating badges, servings scalers, and interactive ingredient checklists.

---

## Features Discovered

| # | Category | Feature | Description | Inputs | Outputs | Error Behavior | Discovered Via |
|---|----------|---------|-------------|--------|---------|----------------|----------------|
| 1 | Core Design System | Culinary Color Palette (`AppColors`) | Centralized color palette featuring terracotta `#E65100`, sage green `#2E7D32`, saffron `#FFA000`, cream light `#FBF9F6`, dark surface `#1E1E1E`, and 6 expense category colors. | Constant color getters | `Color` values | N/A | `lib/core/managers/app_colors.dart` |
| 2 | Core Design System | Typography & Font Scaling (`FontManager`, `StyleManager`) | Poppins font family, weights from w300 to w800, ScreenUtil `.sp` font sizes s10-s40, and style helpers `getRegularStyle()`, `getBoldStyle()`, etc. | `fontSize`, `fontWeight`, `color`, `height` | `TextStyle` | Fallback to system sans if font missing; hardcodes light text color if unspecified | `lib/core/managers/font_manager.dart`, `style_manager.dart` |
| 3 | Core Design System | Spacing & Border Radii (`AppSpacing`, `ValueManager`) | Centralized spacing tokens `s2`-`s64`, gap widgets (`gapW8`, `gapH16`), padding presets, and border radii `r4`-`r32`, `circular`. | Numeric dimensions | `EdgeInsets`, `SizedBox`, `BorderRadius` | Non-negative constraint | `lib/core/constants/app_spacing.dart`, `value_manager.dart` |
| 4 | Core Design System | Asset Inventory (`AssetManager`) | Centralized paths for 5 images (`app_logo.png`, `splash_bg.png`, `recipe_placeholder.png`, `default_avatar.png`, `empty_state.png`), 3 icons (`ic_timer.png`, `ic_recipe.png`, `ic_expense.png`), 3 SVGs (`cooking_pot.svg`, `chef_hat.svg`, `no_data.svg`), 2 Lotties (`cooking_anim.json`, `loading.json`). | Asset paths | String paths | Throws `FlutterError` if asset missing from bundle | `lib/core/managers/asset_manager.dart` |
| 5 | Navigation | App Shell Navigation (`AppShell`) | Stateful navigation shell with 3 branches: Expenses (Index 0), Recipes/Home (Index 1), Profile (Index 2). | `navigationShell` branch index | Bottom `NavigationBar` | Index clamped 0-2 | `lib/features/app_shell/presentation/screens/app_shell.dart` |
| 6 | Navigation | Declarative Router (`AppRouter`) | GoRouter configuration with `StatefulShellRoute.indexedStack` and sub-routes for details and add screens. | URI path, query parameters | Screen transitions (Cupertino push & modal) | Unknown route defaults to initialLocation | `lib/core/routing/app_router.dart` |
| 7 | Recipes | Home / Discover Feed (`HomeScreen`) | Browse screen with greeting, search input, horizontal category chips (`Breakfast`, `Lunch`, `Dinner`, `Desserts`, `Healthy`), single popular recipe card, and FAB. | User tap, search text | Filtered views, pushed routes | Line count 195 (near 200-line ceiling) | `lib/features/home/presentation/screens/home_screen.dart` |
| 8 | Recipes | Recipe Details (`RecipeDetailsScreen`) | Detail view showing title, description, and "Start Cooking Mode" button. Currently a 57-line stub. | `recipeId`, `title` | Scaffold view | Button action is no-op lambda | `lib/features/recipes/presentation/screens/recipe_details_screen.dart` |
| 9 | Recipes | Add Recipe (`AddRecipeScreen`) | Form screen with Title and Description text fields. 53-line stub. | User text input | Pop navigator | Does not persist recipe to repository | `lib/features/recipes/presentation/screens/add_recipe_screen.dart` |
| 10 | Expenses | Food Expense Tracker (`ExpenseScreen`) | Budget overview card (spent vs budget with LinearProgressIndicator) and recent expense list tiles. | User scroll, tap | Visual budget & list | Hardcoded mock data | `lib/features/expenses/presentation/screens/expense_screen.dart` |
| 11 | Expenses | Add Expense (`AddExpenseScreen`) | Form screen with Description and Amount text fields. 54-line stub. | Text, numeric input | Pop navigator | Does not validate currency format | `lib/features/expenses/presentation/screens/add_expense_screen.dart` |
| 12 | Profile | Chef Profile & Settings (`ProfileScreen`) | Chef Ismail header, settings list tiles, theme option, and CSV export integration. | User tap | Triggers navigation or export action | Some tiles are no-op | `lib/features/profile/presentation/screens/profile_screen.dart` |
| 13 | Profile / Data | Recipe CSV Export (`ExportRecipesTile`) | Settings tile with `RecipeExportProvider` hook to trigger RFC 4180 recipe export with loading indicator and SnackBar. | Tap | Generates CSV file via `path_provider` & `share_plus` | Shows `CustomSnackbar.showError` on failure | `lib/features/profile/presentation/widgets/export_recipes_tile.dart` |
| 14 | Core UI Components | Standard App Button (`AppButton`) | Primary and Outlined button with built-in loading spinner (`CircularProgressIndicator`). | `text`, `onPressed`, `isLoading`, `isOutlined`, `icon` | Material button widget | Disabled when `isLoading = true` | `lib/core/widgets/app_button.dart` |
| 15 | Core UI Components | Empty State View (`AppEmptyView`) | Centered illustration/icon, title, message, and optional action button. | `title`, `message`, `icon`, `actionLabel`, `onAction` | Centered column | Hardcodes light mode colors | `lib/core/widgets/app_empty_view.dart` |
| 16 | Core UI Components | Error State View (`AppErrorView`) | Error badge, title, error description, and retry action button. | `title`, `message`, `onRetry`, `retryLabel` | Centered column | Hardcodes light mode colors | `lib/core/widgets/app_error_view.dart` |
| 17 | Core UI Components | Loading State View (`AppLoadingView`) | Reusable progress indicator with optional loading message. | `message`, `color` | Centered column with spinner | Uses CircularProgressIndicator instead of Lottie | `lib/core/widgets/app_loading_view.dart` |
| 18 | Core UI Components | Custom Feedback SnackBar (`CustomSnackbar`) | Floating snackbar with success, error, warning, info color and icon variants. | `context`, `message`, `type`, `duration`, `actionLabel` | Floating SnackBar | Hides existing snackbar before showing | `lib/core/widgets/custom_snackbar.dart` |

---

## Edge Cases

| # | Feature | Input | Observed Behavior |
|---|---------|-------|-------------------|
| 1 | Dark Mode Switching | System switches from Light to Dark Mode | `AppEmptyView`, `AppErrorView`, `AppLoadingView`, `HomeScreen`, `ProfileScreen` display dark text on dark surfaces because `getRegularStyle()` defaults to `AppColors.textPrimaryLight` (`#1A1A1A`) instead of `Theme.of(context).colorScheme.onSurface`. |
| 2 | Asset Usage in Cards | Recipe card rendered on `HomeScreen` | Card renders a flat colored `Container` with `Icons.restaurant_menu_rounded` instead of loading `AssetManager.recipePlaceholder` (`assets/images/recipe_placeholder.png`). |
| 3 | Navigation to Cooking Mode | Tap "Start Cooking Mode" in `RecipeDetailsScreen` | No-op (`onPressed: () {}`). Route `/cooking-mode` is defined in `route_paths.dart` but omitted from `AppRouter.router`. |
| 4 | Screen Length Discipline | Add new widgets to `home_screen.dart` | Currently at 195 lines; adding any inline widget immediately violates the `< 200 lines per file` rule. Requires widget extraction into `features/home/presentation/widgets/`. |
| 5 | Navigation Bar Branded Assets | App Shell bottom tabs rendered | Uses basic Material 3 icons (`Icons.account_balance_wallet_outlined`, `Icons.menu_book_outlined`) rather than `AssetManager.icExpense` and `AssetManager.icRecipe`. |
| 6 | Servings Adjustment | Dynamic recipe serving scaling in `RecipeDetailsScreen` | Missing widget; ingredient amounts are static or absent entirely. |
| 7 | Ingredient Checkboxes | Check off ingredients in `RecipeDetailsScreen` | Checklist is completely unimplemented; screen contains only title, description, and button. |
| 8 | Multi-Timer Execution | Cooking timers in `cooking_timer/` | No UI or service implemented; folder contains only `.gitkeep`. |
| 9 | High-DPI Image Loading | Image displayed on various device densities | Raw `Image.asset` without explicit `cacheWidth`/`cacheHeight` or `fit: BoxFit.cover` risks memory spikes on low-end devices. |

---

## 2. Complete UI Modernization Specification

### A. Culinary Design System Enhancement (`lib/core/`)

#### 1. Color Palette Additions (`app_colors.dart`)
Add the following gastronomic gradient, shadow, and semantic status tokens:
```dart
// Culinary Gradients
static const LinearGradient primaryGradient = LinearGradient(
  colors: [Color(0xFFFF833A), Color(0xFFE65100)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

static const LinearGradient heroOverlayGradient = LinearGradient(
  colors: [Colors.transparent, Color(0xCC000000)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

static const LinearGradient warmCardGradient = LinearGradient(
  colors: [Color(0xFFFFF8F1), Color(0xFFFFFFFF)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

// Culinary Card Drop Shadows
static const BoxShadow culinaryCardShadow = BoxShadow(
  color: Color(0x0F000000),
  blurRadius: 16,
  offset: Offset(0, 6),
  spreadRadius: 0,
);

static const BoxShadow glowingOrangeShadow = BoxShadow(
  color: Color(0x33E65100),
  blurRadius: 12,
  offset: Offset(0, 4),
);

// Culinary Difficulty & Meta Badges
static const Color difficultyEasy = Color(0xFF2E7D32);    // Fresh Herb Green
static const Color difficultyMedium = Color(0xFFFFA000);  // Saffron Amber
static const Color difficultyHard = Color(0xFFD32F2F);    // Cayenne Red
static const Color ratingStar = Color(0xFFFFB300);        // Golden Amber
static const Color calorieBadge = Color(0xFFFF7043);      // Warm Tangerine
```

#### 2. Theme-Aware Typography (`style_manager.dart`)
Refactor style helpers so they can adapt to the ambient theme:
```dart
TextStyle getThemeAwareStyle(
  BuildContext context, {
  required double fontSize,
  FontWeight fontWeight = FontWeightManager.regular,
  Color? color,
  double? height,
  double? letterSpacing,
}) {
  final defaultColor = Theme.of(context).colorScheme.onSurface;
  return _getTextStyle(
    fontSize,
    fontWeight,
    color ?? defaultColor,
    height: height,
    letterSpacing: letterSpacing,
  );
}
```

#### 3. Centralized Theme Data Upgrades (`light_theme.dart` & `dark_theme.dart`)
Include complete component themes:
- `navigationBarTheme`: Height 64.h, indicatorColor `AppColors.primaryContainer`, labelBehavior `NavigationDestinationLabelBehavior.alwaysShow`.
- `chipTheme`: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)), selectedColor `AppColors.primary`, padding EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h).
- `cardTheme`: Shape `RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r))`, elevation 2.
- `floatingActionButtonTheme`: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)), backgroundColor `AppColors.primary`.

---

### B. Screen-by-Screen UI Modernization Blueprint

#### 1. Persistent App Shell (`app_shell.dart`)
- **Container**: Floating or soft-elevated navigation bar with top border (`borderLight`/`borderDark`) and rounded top corners (20.r).
- **Icons**:
  - Tab 0 (Expenses): `Image.asset(AssetManager.icExpense, width: 24.r, height: 24.r, color: isSelected ? AppColors.primary : unselectedColor)`
  - Tab 1 (Recipes): `Image.asset(AssetManager.icRecipe, width: 24.r, height: 24.r, color: isSelected ? AppColors.primary : unselectedColor)`
  - Tab 2 (Profile): Chef hat or user avatar `CircleAvatar(radius: 12.r, backgroundImage: AssetImage(AssetManager.userAvatar))`

#### 2. Home / Discover Feed (`HomeScreen` & Widgets)
Decompose `home_screen.dart` into modular sub-widgets under `lib/features/home/presentation/widgets/`:
1. **`home_header.dart`**:
   - Greeting ("Good morning, Chef!"), Subtitle ("What are we creating today?").
   - Trailing row with Bookmark counter icon and mini Chef Avatar (`AssetManager.userAvatar`).
2. **`home_search_bar.dart`**:
   - Capsule search field (radius 24.r) with `Icons.search_rounded` in `AppColors.primary`.
   - Filter button (`Icons.tune_rounded`) triggering a dietary filter bottom sheet.
3. **`home_category_pills.dart`**:
   - Horizontal scrollable row of food categories with emojis and badge counts:
     - 🍳 All (128)
     - 🥞 Breakfast (24)
     - 🥗 Lunch (36)
     - 🍲 Dinner (48)
     - 🍰 Desserts (20)
     - ⏱️ Quick & Easy (18)
   - Pill animation: Selected pill expands slightly with gradient fill `primaryGradient` and white text.
4. **`featured_recipe_card.dart`**:
   - Prominent hero card (height ~200.h, radius 20.r).
   - Full-bleed image background using `Image.asset(AssetManager.recipePlaceholder, fit: BoxFit.cover)`.
   - Dark gradient scrim (`heroOverlayGradient`) ensuring 100% text contrast.
   - "Editor's Pick" golden badge, recipe title in 18sp Bold, cooking time badge (30m), and favorite bookmark heart icon.
5. **`recipe_grid_card.dart`**:
   - 2-column or clean stacked cards for "Popular Recipes".
   - Image header with top radius 16.r.
   - Meta info bar: Rating (`★ 4.8`), Time (`25m`), Calories (`420 kcal`), and Difficulty chip (`Easy`).

#### 3. Recipe Details Screen (`RecipeDetailsScreen` & Widgets)
Decompose into `lib/features/recipes/presentation/widgets/`:
1. **`recipe_hero_sliver.dart`**:
   - `SliverAppBar` with collapsible image header (height 280.h).
   - Uses `Hero(tag: 'recipe_image_${recipe.id}')`.
   - Translucent frosted glass circular action buttons for Back and Bookmark (`BackdropFilter`).
2. **`recipe_meta_summary.dart`**:
   - 4-card metric row with warm containers:
     - ⏱️ Prep Time (15m)
     - 🍳 Cook Time (25m)
     - 🔥 Calories (450 kcal)
     - 📊 Difficulty (Intermediate)
3. **`recipe_servings_selector.dart`**:
   - Interactive counter: `[-] 4 Servings [+]` which scales ingredient quantities dynamically.
4. **`recipe_ingredients_checklist.dart`**:
   - Interactive items: tap checkbox to strike-through ingredient text.
   - Quantity badge in primary container ("500g", "2 tbsp", "1 cup").
5. **`recipe_steps_timeline.dart`**:
   - Numbered step cards with vertical connector line.
   - Direct "Start Step Timer" button if the step specifies a duration (e.g. "Simmer sauce for 10 minutes").
6. **`recipe_bottom_cta.dart`**:
   - Sticky bottom bar with full-width `AppButton` ("Start Interactive Cooking Mode", icon: `Icons.play_circle_fill_rounded`).

#### 4. Interactive Cooking Mode Screen (`CookingModeScreen`)
Create under `lib/features/cooking_mode/presentation/screens/cooking_mode_screen.dart`:
- Distraction-free full-screen UI with large high-contrast typography (20sp-24sp).
- Top step progress indicator ("Step 3 of 6 • 50%").
- Screen wakelock indicator (prevents screen timeout while user's hands are cooking).
- Large swipeable step instructions card.
- Floating multi-timer drawer showing active timers with live countdown.
- Ingredients checklist quick-access sheet.

#### 5. Cooking Timer Floating Widget (`CookingTimerWidget`)
Create under `lib/features/cooking_timer/presentation/widgets/cooking_timer_widget.dart`:
- Circular countdown indicator using `AppColors.primary` and `AppColors.accent`.
- Controls: Play, Pause, Reset, +1 Min, +5 Min.
- Support for multiple concurrent labeled timers (e.g. "Pasta", "Sauce").

#### 6. Expenses Screen (`ExpenseScreen`)
- Gourmet terracotta-gradient budget summary card with circular spending progress.
- Category pills with colored dot indicators (`Groceries`, `Beverages`, `Equipment`, `Spices`, `Dining Out`).
- Modern expense list items with category icon in soft tinted circular container.

#### 7. Profile Screen (`ProfileScreen`)
- Chef Ismail avatar header with `AssetManager.userAvatar` and gold border.
- Grouped iOS-style card sections (Preferences, Appearance, Export Recipes, Account).
- Active Dark Mode switch modifying app theme mode.

---

## 3. Five-Component Handoff Report

### 1. Observation
1. **Asset Disconnect**: In `lib/core/managers/asset_manager.dart`, 13 assets are defined:
   - Lines 10-14: `appLogo`, `splashBackground`, `recipePlaceholder`, `userAvatar`, `emptyStateIllustration`.
   - Lines 17-19: `icTimer`, `icRecipe`, `icExpense`.
   - Lines 22-24: `svgCookingPot`, `svgChefHat`, `svgNoData`.
   - Lines 27-28: `lottieCooking`, `lottieLoading`.
   Running `Get-ChildItem -Path lib -Recurse | Select-String "AssetManager"` reveals `AssetManager` is **only referenced within `asset_manager.dart` itself**. No UI screen imports or loads any of these assets.
2. **Missing UI Implementations**:
   - `lib/features/recipes/presentation/screens/recipe_details_screen.dart` is 57 lines, containing only static text and a no-op button on line 49: `onPressed: () {}`.
   - `lib/features/cooking_mode/` contains only `.gitkeep` files in `presentation/providers/`, `screens/`, `widgets/`.
   - `lib/features/cooking_timer/` contains only `.gitkeep` files in `data/`, `domain/`, `presentation/`.
   - `lib/features/splash/` contains only `.gitkeep` files.
3. **Hardcoded Theme Violations**:
   - `lib/core/widgets/app_empty_view.dart:38`: `color: AppColors.surfaceVariantLight`.
   - `lib/core/widgets/app_empty_view.dart:54`: `color: AppColors.textPrimaryLight`.
   - `lib/core/widgets/app_error_view.dart:51`: `color: AppColors.textPrimaryLight`.
   - `lib/core/widgets/app_loading_view.dart:35`: `color: AppColors.textSecondaryLight`.
   - `lib/core/managers/style_manager.dart:28,44,60,76`: default parameter `color = AppColors.textPrimaryLight`.
   When the app switches to Dark Theme (`ThemeMode.dark`), these widgets do not switch to dark text colors, creating unreadable low-contrast text.
4. **File Length Warnings**:
   - `lib/features/home/presentation/screens/home_screen.dart` is currently **195 lines** (only 5 lines below the strict < 200 lines per file Clean Architecture rule). Adding any rich cards or headers directly into this file will cause an architecture violation.
5. **Asset Disk Status**:
   `test/core/assets_test.dart` passes and proves all 13 assets exist in `assets/` with valid PNG headers, valid SVG XML structures, and non-empty Lottie files.

### 2. Logic Chain
- Step 1: The user request mandates: "Fix the UI and app assets across the entire cooking directory Flutter application and verify the proper end-to-end app flow for production readiness, taking rich UI reference from the reference link."
- Step 2: The assets were properly generated in `assets/` and registered in `pubspec.yaml`, but the presentation layer was never updated to consume them.
- Step 3: By replacing raw icon placeholders with `AssetManager` references (`recipe_placeholder.png`, `userAvatar`, `icRecipe`, `icExpense`, `svgChefHat`, `lottieLoading`), the application immediately gains high-fidelity culinary branding.
- Step 4: Decomposing `home_screen.dart` (195 lines) into modular sub-widgets (`home_header.dart`, `home_search_bar.dart`, `home_category_pills.dart`, `featured_recipe_card.dart`, `recipe_grid_card.dart`) satisfies the < 200 lines per file discipline while enabling rich culinary cards with ratings, cook times, and hero images.
- Step 5: Completing `RecipeDetailsScreen` with hero headers, servings scalers, ingredient checklists, and step timelines directly unblocks the transition into `CookingModeScreen` and fulfills Requirement R1 of `ORIGINAL_REQUEST.md`.
- Step 6: Refactoring `style_manager.dart` and core widgets to use `Theme.of(context).colorScheme` prevents dark mode contrast breakage.

### 3. Caveats
1. **Network Image Caching**: The current design uses local placeholder assets (`AssetManager.recipePlaceholder`). When real network images are hooked up from Firestore, `cached_network_image` will need to be added or `Image.network` wrapped with error and loading builders.
2. **Audio / Haptic Feedback**: While timer completion and step progression benefit from haptics and sounds, local audio assets are not currently defined in `AssetManager`.
3. **Screen Size Constraints**: ScreenUtil is configured for `375 x 812`. Tablet or landscape views will need `ResponsiveUtils` to prevent card stretching.

### 4. Conclusion
The application has an excellent architectural backbone and valid asset files, but the UI is currently in an unstyled prototype state where none of the branded assets are connected and core screens (`RecipeDetails`, `CookingMode`, `CookingTimer`) are stubs or missing. Modernizing the app requires:
1. Connecting `AssetManager` across `AppShell`, `HomeScreen`, `ProfileScreen`, and core widgets.
2. Decomposing `home_screen.dart` into modular sub-widgets under 200 lines.
3. Implementing complete culinary presentation widgets: Hero header, category pills with emojis, recipe cards with badges, interactive ingredient checklists, and step-by-step cooking timelines.
4. Implementing the missing `CookingModeScreen` and `CookingTimerWidget` with wakelock and active countdowns.
5. Making typography and core widgets fully theme-aware for light and dark modes.

### 5. Verification Method
1. **Asset Verification**:
   Run `flutter test test/core/assets_test.dart` to verify asset file existence and binary integrity.
2. **Static Analysis**:
   Run `flutter analyze` to ensure zero errors, warnings, or lints across all modified and newly created files.
3. **File Length Compliance**:
   Run PowerShell script:
   `Get-ChildItem -Path lib -Recurse -Filter *.dart | Where-Object { (Get-Content $_.FullName).Count -ge 200 }`
   Verify that zero files exceed 199 lines.
4. **Theme Verification**:
   Toggle `themeMode` between `ThemeMode.light` and `ThemeMode.dark` in `CookingDirectoryApp` and verify that text and card backgrounds maintain high contrast and correct color semantics.
