## 2026-11-10T16:46:13Z

You are worker_m7, a specialized Flutter Clean Architecture worker.

Workspace: d:\Ismail_flutter\cooking_directory
State folder: d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_m7_gen2
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

EXCLUSIVE FILE OWNERSHIP (You may only modify these files):
- `lib/core/managers/app_colors.dart`
- `lib/core/managers/style_manager.dart`
- `lib/core/widgets/app_empty_view.dart`
- `lib/core/widgets/app_error_view.dart`
- `lib/core/widgets/app_loading_view.dart`
- `lib/core/widgets/app_button.dart`

REQUIREMENTS FOR MILESTONE M7 (Core Design Tokens & Theming Fixes):
1. `app_colors.dart`:
   - Add culinary gradients: `primaryGradient` (terracotta gradient: `Color(0xFFFF833A)` to `Color(0xFFE65100)`), `heroOverlayGradient` (`Colors.transparent` to `Color(0xCC000000)`), `warmCardGradient` (`Color(0xFFFFF8F1)` to `Color(0xFFFFFFFF)`).
   - Add culinary card shadows: `culinaryCardShadow` (soft shadow: `BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 6))`), `glowingOrangeShadow` (`BoxShadow(color: Color(0x33E65100), blurRadius: 12, offset: Offset(0, 4))`).
   - Add culinary semantic tokens: `ratingStar` (`Color(0xFFFFB300)`), `calorieBadge` (`Color(0xFFFFF3E0)`), `calorieText` (`Color(0xFFE65100)`), `prepTimeTag` (`Color(0xFFE8F5E9)`), `prepTimeText` (`Color(0xFF2E7D32)`).
   - Enforce < 200 lines limit.
2. `style_manager.dart`:
   - Fix dark mode text contrast: Ensure typography functions don't hardcode dark text on dark backgrounds when context/theme is available or default gracefully. Preserve full backward compatibility with existing function signatures.
   - Enforce < 200 lines limit.
3. `app_empty_view.dart`:
   - Upgrade illustration to utilize `AssetManager.emptyStateIllustration` (`assets/images/empty_state.png`) or `AssetManager.svgNoData` (`assets/svgs/no_data.svg`) while maintaining fallback if icon is passed.
   - Use theme-aware text colors (`Theme.of(context).colorScheme.onSurface`).
   - Enforce < 200 lines limit.
4. `app_error_view.dart`:
   - Ensure theme-aware text styling and clean retry button.
   - Enforce < 200 lines limit.
5. `app_loading_view.dart`:
   - Use `Lottie.asset(AssetManager.lottieLoading)` for a delightful culinary loading animation (with size, e.g. 100.w) with clean fallback.
   - Enforce < 200 lines limit.
6. `app_button.dart`:
   - Add support for gradient styling with `AppColors.primaryGradient` and subtle culinary shadow for primary buttons.
   - Enforce < 200 lines limit.

VERIFICATION:
- Run `flutter analyze` and ensure 0 errors, 0 warnings.
- Run `flutter test` and ensure all tests pass.
- Write a detailed handoff report to `d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_m7_gen2\handoff.md` detailing changes, line counts, and verification output. Send a message when complete.
