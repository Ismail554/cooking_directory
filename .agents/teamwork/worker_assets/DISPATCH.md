# Dispatch: Worker Asset Generation & Registration

**Role**: Asset Generation & Registration Specialist (`teamwork_worker`)
**Working Directory**: d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_assets\
**Original Request**: d:\Ismail_flutter\cooking_directory\.agents\teamwork\ORIGINAL_REQUEST.md
**Asset Specifications**: d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_survey_2\handoff.md

## Objective
Generate and place all 13 required themed assets matching the app color palette and design tokens declared in `lib/core/managers/asset_manager.dart`, and register them in `pubspec.yaml`.

### 1. Required Asset Inventory
- Images (`assets/images/`):
  1. `app_logo.png`: 512x512, 32-bit PNG, chef hat + herb green + terracotta circular badge logo.
  2. `splash_bg.png`: 1125x2436, 24-bit PNG, subtle linen gradient with culinary watermark.
  3. `recipe_placeholder.png`: 600x400, 24-bit PNG, dish cloche dome on soft oatmeal background.
  4. `default_avatar.png`: 256x256, 32-bit PNG, chef silhouette portrait.
  5. `empty_state.png`: 500x500, 32-bit PNG, pleasant bowl/skillet empty illustration.
- Icons (`assets/icons/`):
  6. `ic_timer.png`: 128x128, 32-bit PNG, kitchen timer dial.
  7. `ic_recipe.png`: 128x128, 32-bit PNG, recipe cookbook with bookmark.
  8. `ic_expense.png`: 128x128, 32-bit PNG, grocery basket with currency accent.
- Vectors (`assets/svgs/`):
  9. `cooking_pot.svg`: Valid XML SVG (`0 0 100 100`), terracotta dutch oven pot with steam paths.
  10. `chef_hat.svg`: Valid XML SVG (`0 0 100 100`), 5-puff toque blanche with green band.
  11. `no_data.svg`: Valid XML SVG (`0 0 200 200`), empty recipe binder with sparkles.
- Lottie JSONs (`assets/jsons/`):
  12. `cooking_anim.json`: Valid Bodymovin JSON animation (bubbling cooking pot with steam).
  13. `loading.json`: Valid Bodymovin JSON animation (rotating whisk/ring loader).

### 2. Color Palette & Design Tokens
Strictly use the app palette from `lib/core/managers/app_colors.dart`:
- Terracotta: `#E65100` (Dark: `#AC1900`, Light: `#FF833A`, Peach: `#FFE0B2`)
- Herb Green: `#2E7D32` (Dark: `#005005`, Light: `#60AD5E`, Mint: `#C8E6C9`)
- Saffron Accent: `#FFA000` (Light: `#FFD54F`)
- Background: `#FBF9F6` (Linen), `#F3EFEA` (Oatmeal), `#1A1A1A` (Text Charcoal)

### 3. pubspec.yaml Registration
Update `pubspec.yaml` to:
- Declare all 4 asset folders under `flutter:`:
  ```yaml
  assets:
    - assets/images/
    - assets/icons/
    - assets/svgs/
    - assets/jsons/
  ```
- Add `flutter_svg: ^2.0.17` and `lottie: ^3.3.1` dependencies so that SVGs and animations compile and load cleanly.
- Run `flutter pub get` and verify that all assets resolve without errors.

### 4. Verification
- Verify all 13 files exist with non-zero file sizes.
- Verify image headers (PNG signature), SVG XML well-formedness, and Lottie JSON parsability.
- Write handoff report with verification commands and evidence to `handoff.md`.


## 2026-11-10T04:20:21Z
You are Worker: Asset Generation & Registration Specialist (teamwork_worker).
Your working directory is: d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_assets\
You MUST read d:\Ismail_flutter\cooking_directory\.agents\teamwork\ORIGINAL_REQUEST.md before starting work.
Also read your assignment in d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_assets\DISPATCH.md.
Also review the detailed asset specifications in:
d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_survey_2\handoff.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Your write ownership:
- `assets/images/*` (app_logo.png, splash_bg.png, recipe_placeholder.png, default_avatar.png, empty_state.png)
- `assets/icons/*` (ic_timer.png, ic_recipe.png, ic_expense.png)
- `assets/svgs/*` (cooking_pot.svg, chef_hat.svg, no_data.svg)
- `assets/jsons/*` (cooking_anim.json, loading.json)
- `pubspec.yaml` (register asset directories and add flutter_svg & lottie dependencies)

Requirements:
1. Generate high-quality, valid binary PNG images for the 5 images and 3 icons matching the color palette and dimensions specified. You can use a Python/Node/PowerShell script or graphics library to render the binary PNG files cleanly with proper PNG headers and color channels.
2. Generate clean, valid XML SVG vector files for the 3 SVGs matching the design tokens.
3. Generate valid Bodymovin/Lottie JSON animation files for the 2 animations (`cooking_anim.json` and `loading.json`) that can be parsed and rendered by `package:lottie`.
4. Update `pubspec.yaml` to register all 4 asset folders (`assets/images/`, `assets/icons/`, `assets/svgs/`, `assets/jsons/`) and add `flutter_svg: ^2.0.17` and `lottie: ^3.3.1`.
5. Run `flutter pub get` and verify that the assets are recognized.
6. Write an automated test or verification script in `test/core/assets_test.dart` to verify that all 13 declared assets in `AssetManager` exist on disk, are non-empty, and are registered in `pubspec.yaml`. Run `flutter test test/core/assets_test.dart`.

Document all verification results in `handoff.md` and notify parent upon completion.
