# Asset and Design System Exploration Report

## 1. Observation

### 1.1 Declared Assets in Codebase
In `lib/core/managers/asset_manager.dart` (lines 3-30), the centralized asset contract is defined as follows:
```dart
abstract final class AssetManager {
  static const String _iconsPath = 'assets/icons';
  static const String _imagesPath = 'assets/images';
  static const String _svgsPath = 'assets/svgs';
  static const String _jsonsPath = 'assets/jsons';

  // Images
  static const String appLogo = '$_imagesPath/app_logo.png';
  static const String splashBackground = '$_imagesPath/splash_bg.png';
  static const String recipePlaceholder = '$_imagesPath/recipe_placeholder.png';
  static const String userAvatar = '$_imagesPath/default_avatar.png';
  static const String emptyStateIllustration = '$_imagesPath/empty_state.png';

  // Icons
  static const String icTimer = '$_iconsPath/ic_timer.png';
  static const String icRecipe = '$_iconsPath/ic_recipe.png';
  static const String icExpense = '$_iconsPath/ic_expense.png';

  // SVGs
  static const String svgCookingPot = '$_svgsPath/cooking_pot.svg';
  static const String svgChefHat = '$_svgsPath/chef_hat.svg';
  static const String svgNoData = '$_svgsPath/no_data.svg';

  // Lottie JSONs
  static const String lottieCooking = '$_jsonsPath/cooking_anim.json';
  static const String lottieLoading = '$_jsonsPath/loading.json';
}
```

### 1.2 Disk Inspection of `assets/` Directory
Directory search using PowerShell command `Get-ChildItem -Path "assets" -Recurse -File` returned **zero files**.
The directory structure exists on disk:
- `assets/icons/` (Directory exists, 0 files)
- `assets/images/` (Directory exists, 0 files)
- `assets/jsons/` (Directory exists, 0 files)
- `assets/svgs/` (Directory exists, 0 files)

**Status**: Exactly 0 of 13 declared assets exist. All 13 assets are missing.

### 1.3 pubspec.yaml Assets Configuration & Dependencies
Inspection of `pubspec.yaml` (lines 12-37):
```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  flutter_screenutil: ^5.9.3
  provider: ^6.1.5+1

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^6.0.0

flutter:

  uses-material-design: true

  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg
```
Key observations:
1. Asset registrations are entirely commented out. Neither `assets/images/`, `assets/icons/`, `assets/svgs/`, nor `assets/jsons/` are declared.
2. The packages `flutter_svg` and `lottie` are **not installed** in `dependencies`. Any widget rendering `AssetManager.svg*` or `AssetManager.lottie*` would fail to compile or require a renderer.

### 1.4 Design Tokens & Color Palette
In `lib/core/managers/app_colors.dart` (lines 5-73), the palette is defined as:

| Token | Hex | Int Value | Semantic Role |
|-------|-----|-----------|---------------|
| `primary` | `#E65100` | `0xFFE65100` | Warm Culinary Terracotta / Deep Orange (main brand) |
| `primaryDark` | `#AC1900` | `0xFFAC1900` | Deep Terracotta Shade |
| `primaryLight` | `#FF833A` | `0xFFFF833A` | Soft Warm Terracotta Tint |
| `primaryContainer` | `#FFE0B2` | `0xFFFFE0B2` | Pale Terracotta Peach / Container |
| `onPrimary` | `#FFFFFF` | `0xFFFFFFFF` | White text/icon on primary |
| `secondary` | `#2E7D32` | `0xFF2E7D32` | Fresh Herb / Sage Green |
| `secondaryDark` | `#005005` | `0xFF005005` | Deep Forest Green |
| `secondaryLight` | `#60AD5E` | `0xFF60AD5E` | Light Herb Green |
| `secondaryContainer` | `#C8E6C9` | `0xFFC8E6C9` | Pale Sage Tint / Container |
| `onSecondary` | `#FFFFFF` | `0xFFFFFFFF` | White text/icon on secondary |
| `accent` | `#FFA000` | `0xFFFFA000` | Golden Saffron & Warm Honey |
| `accentLight` | `#FFD54F` | `0xFFFFD54F` | Light Saffron |
| `backgroundLight` | `#FBF9F6` | `0xFFFBF9F6` | Warm Linen / Cream Scaffold Background |
| `surfaceLight` | `#FFFFFF` | `0xFFFFFFFF` | Crisp White Surface |
| `cardLight` | `#FFFFFF` | `0xFFFFFFFF` | Card Surface |
| `surfaceVariantLight` | `#F3EFEA` | `0xFFF3EFEA` | Soft Muted Oatmeal Container |
| `backgroundDark` | `#121212` | `0xFF121212` | Dark Background |
| `surfaceDark` | `#1E1E1E` | `0xFF1E1E1E` | Dark Surface |
| `cardDark` | `#252525` | `0xFF252525` | Dark Card Surface |
| `surfaceVariantDark` | `#2C2C2C` | `0xFF2C2C2C` | Dark Surface Variant |
| `textPrimaryLight` | `#1A1A1A` | `0xFF1A1A1A` | Charcoal Near-Black Main Text |
| `textSecondaryLight`| `#6C6C6C` | `0xFF6C6C6C` | Neutral Grey Subtitle Text |
| `borderLight` | `#E5E0D8` | `0xFFE5E0D8` | Warm Grey Outline / Border |
| `expenseGroceries` | `#4CAF50` | `0xFF4CAF50` | Groceries Category Green |
| `expenseDiningOut` | `#FF7043` | `0xFFFF7043` | Dining Out Category Coral |
| `expenseEquipment` | `#42A5F5` | `0xFF42A5F5` | Equipment Category Sky Blue |
| `expenseBeverages` | `#AB47BC` | `0xFFAB47BC` | Beverages Category Violet |
| `expenseSpices` | `#FFCA28` | `0xFFFFCA28` | Spices Category Warm Amber |
| `expenseMiscellaneous` | `#78909C` | `0xFF78909C` | Miscellaneous Category Slate |

### 1.5 Typography, Shapes, and Radii Tokens
- **Font Family**: `FontConstants.fontFamily = 'Poppins'` (`lib/core/managers/font_manager.dart`, line 6).
- **Corner Radii** (`lib/core/managers/value_manager.dart`):
  - Card & Container Radius: `r12` (12.r), `r16` (16.r), `r20` (20.r), `r24` (24.r), `circular` (999.r).
- **Design Size Canvas**: `AppConstants.designSize = Size(375, 812)` (`lib/core/constants/app_constants.dart`, line 8).

---

## 2. Logic Chain

1. **Step 1: Contract Analysis**
   - Observation 1.1 proves that `AssetManager` acts as the single source of truth for all asset paths in the application.
   - Any widget referencing an asset will look for these 13 specific file paths under `assets/images/`, `assets/icons/`, `assets/svgs/`, and `assets/jsons/`.

2. **Step 2: Gap Verification**
   - Observation 1.2 proves that while the four directories exist, they are completely empty.
   - Attempting to load any asset declared in `AssetManager` at runtime will trigger an `AssetNotFoundException` / `Unable to load asset` crash in Flutter.

3. **Step 3: Asset Registration and Dependency Gap**
   - Observation 1.3 shows that `pubspec.yaml` does not declare the `assets/` folders under the `flutter:` block. Flutter’s build tool does not bundle assets unless registered in `pubspec.yaml`.
   - Furthermore, `flutter_svg` and `lottie` are missing from `dependencies`. While the app can load PNGs with `Image.asset()`, loading SVGs and Lottie JSONs requires `flutter_svg` and `lottie`.

4. **Step 4: Design Harmony for Asset Generation**
   - Observations 1.4 and 1.5 provide the exact palette and theme tokens: warm culinary aesthetic anchored by Terracotta (`#E65100`), Herb Green (`#2E7D32`), and Saffron (`#FFA000`) on a Warm Linen (`#FBF9F6`) base.
   - Generated assets must strictly adhere to these color codes to avoid jarring visual inconsistencies between generated graphics and Flutter widget styling.

---

## 3. Actionable Specifications for Required Assets

### 3.1 Bitmap Images (`assets/images/`)

| File Name | Resolution | Format | Visual Specification & Palette |
|-----------|------------|--------|--------------------------------|
| `app_logo.png` | 512x512 | 32-bit PNG (transparent) | Warm circular badge logo. Stylized chef hat in white (`#FFFFFF`) with a warm terracotta (`#E65100`) base, overlaid on an herb green leaf (`#2E7D32`) and golden saffron accent ring (`#FFA000`). Crisp, modern vector-rendered iconography. |
| `splash_bg.png` | 1125x2436 | 24-bit PNG | Splash screen background matching mobile canvas aspect ratio (9:19.5). Soft vertical gradient from `#FBF9F6` (Warm Linen) to `#FFE0B2` (Peach Tint) with faint culinary watermark line art (pots, utensils, leaves, steam swirls) at 6% opacity. |
| `recipe_placeholder.png` | 600x400 | 24-bit PNG | Default placeholder for recipes without cover photos. Soft `#F3EFEA` background with rounded container, centered minimalist cloche (serving plate dome) with fork and spoon silhouette in `#FFE0B2` / `#E65100`. |
| `default_avatar.png` | 256x256 | 32-bit PNG (transparent) | Circular profile avatar. Background circle `#FFE0B2`, chef portrait silhouette with toque and scarf in `#E65100` and `#2E7D32`. |
| `empty_state.png` | 500x500 | 32-bit PNG (transparent) | Empty state illustration. Clean ceramic bowl/skillet with steam swirls, floating culinary elements (olive leaf, pepper grain) and pleasant friendly motif using `#E65100`, `#2E7D32`, `#FFA000`, `#6C6C6C`. |

### 3.2 Icon Assets (`assets/icons/`)

| File Name | Resolution | Format | Visual Specification & Palette |
|-----------|------------|--------|--------------------------------|
| `ic_timer.png` | 128x128 | 32-bit PNG (transparent) | Modern culinary timer / stopwatch with top plunger, dial markings in `#E65100` and small green checkmark accent in `#2E7D32`. |
| `ic_recipe.png` | 128x128 | 32-bit PNG (transparent) | Hardcover cookbook with ribbon bookmark. Cover in `#E65100`, bookmark in `#FFA000`, chef hat symbol embossed on cover in `#FFE0B2`. |
| `ic_expense.png` | 128x128 | 32-bit PNG (transparent) | Minimalist shopping grocery bag with coin / dollar symbol and fresh carrot/herb peeking out, using `#2E7D32`, `#E65100`, `#4CAF50`. |

### 3.3 Vector SVGs (`assets/svgs/`)

| File Name | ViewBox | Visual Specification & XML Structure |
|-----------|---------|--------------------------------------|
| `cooking_pot.svg` | `0 0 100 100` | Heavy dutch oven pot (`#E65100`), side handles (`#AC1900`), lid handle (`#FFA000`), with three curved steam paths (`#FFE0B2` / `#E65100` with 60% opacity) rising above the lid. |
| `chef_hat.svg` | `0 0 100 100` | Classic puffed chef toque blanche with 5 clean billows in `#FBF9F6` outlined in `#1A1A1A` / `#E65100`, structured band with horizontal green accent stripe `#2E7D32`. |
| `no_data.svg` | `0 0 200 200` | Clean flat vector showing an empty open recipe binder or clean pantry plate with gentle shadow (`#E5E0D8`), small magnifying glass and delicate sparkles in `#FFA000`. |

### 3.4 Lottie Animations (`assets/jsons/`)

| File Name | Frame Rate / Loop | Visual Specification & Lottie Bodymovin Schema |
|-----------|-------------------|------------------------------------------------|
| `cooking_anim.json` | 60 fps, 120 frames, looping | Standard Bodymovin JSON v5.5+. A bubbling pot on a subtle burner stove with rising and evaporating steam particles and a gently tilting lid. Colors: pot `#E65100`, lid `#AC1900`, steam `#FFA000` / `#FFE0B2`. |
| `loading.json` | 60 fps, 90 frames, looping | Standard Bodymovin JSON v5.5+. Seamless circular loader: a whisk rotating around a bowl or a spinning ring of culinary ingredients (herbs, carrots, spices) transitioning with easing between `#E65100` and `#2E7D32`. |

---

## 4. pubspec.yaml Recommendations

### 4.1 Asset Registration Diff
In `pubspec.yaml`, under `flutter:`, replace commented lines 34-36 with:
```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/icons/
    - assets/svgs/
    - assets/jsons/
```

### 4.2 Required Dependency Additions
To render the SVGs and Lottie files defined in `AssetManager`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_screenutil: ^5.9.3
  provider: ^6.1.5+1
  flutter_svg: ^2.0.10+1   # REQUIRED for svgCookingPot, svgChefHat, svgNoData
  lottie: ^3.1.2           # REQUIRED for lottieCooking, lottieLoading
```

---

## 5. Caveats

1. **No Assets Currently Exist**: Assets have not yet been placed on disk; doing so is an implementation task for the asset generation phase.
2. **Missing Rendering Libraries**: Even once the files are placed on disk, the project cannot render `.svg` and `.json` Lottie files without adding `flutter_svg` and `lottie` to `pubspec.yaml`.
3. **ScreenUtil Initialization**: The app utilizes `flutter_screenutil` (`375 x 812` base). Image assets should be high DPI (e.g. 2x/3x equivalent or vector SVGs) to avoid pixelation on high-density devices.

---

## 6. Conclusion

- The design tokens in `lib/core/` are well-structured, consistent, and cleanly organized across `app_colors.dart`, `font_manager.dart`, `style_manager.dart`, `value_manager.dart`, and `app_spacing.dart`.
- The asset contract in `lib/core/managers/asset_manager.dart` specifies 13 distinct assets (5 PNG images, 3 PNG icons, 3 SVG vectors, 2 Lottie animations).
- Zero assets currently exist on disk; all 13 are missing.
- `pubspec.yaml` must be updated to register the four asset folders (`assets/images/`, `assets/icons/`, `assets/svgs/`, `assets/jsons/`) and add `flutter_svg` and `lottie` dependencies.
- Detailed visual and technical specifications matching the exact hexadecimal design tokens have been compiled above to enable direct, high-fidelity asset generation.

---

## 7. Verification Method

To independently verify these findings:
1. **Verify Asset Absence**:
   ```powershell
   Get-ChildItem -Path "assets" -Recurse -File
   ```
   *Expected outcome*: 0 files returned.
2. **Verify Asset Contract**:
   Inspect `lib/core/managers/asset_manager.dart` lines 10-28 to confirm all 13 declared constant strings.
3. **Verify pubspec.yaml Asset Exclusions**:
   Inspect `pubspec.yaml` lines 30-37 to confirm assets are commented out and `flutter_svg`/`lottie` are absent.
4. **Post-Implementation Asset Verification**:
   After generation, run a Flutter asset test or:
   ```powershell
   Get-ChildItem -Path "assets" -Recurse -File | Select-Object Name, Length
   ```
   *Expected outcome*: 13 files present with non-zero byte lengths matching the declared names.
