## 2026-11-10T17:46:57Z
You are worker_m11, a specialized Flutter Clean Architecture worker.

Workspace: d:\Ismail_flutter\cooking_directory
State folder: d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_m11_gen2
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
- `lib/features/expenses/presentation/screens/expense_screen.dart`
- `lib/features/expenses/presentation/screens/add_expense_screen.dart`
- `lib/features/profile/presentation/screens/profile_screen.dart`
- `lib/features/profile/presentation/widgets/profile_header.dart`
- `lib/features/profile/presentation/widgets/preference_dialogs.dart`

REQUIREMENTS FOR MILESTONE M11 (Expenses & Profile Polish):
1. `expense_screen.dart`:
   - Monthly budget card with total budget ($1,200), spent ($480), remaining ($720), and stylized `LinearProgressIndicator` with percentage. Uses `AppColors.warmCardGradient` or `culinaryCardShadow`.
   - Category filter pills (All, Groceries, Dining Out, Kitchen Tools, Spices, Delivery) with interactive selection.
   - Expense list items with category icon, title, date, amount, and theme-aware styling.
   - Calendar button in AppBar and FAB navigating to `AppRoutePaths.addExpense`.
   - Strictly < 200 lines.
2. `add_expense_screen.dart`:
   - Fix RenderFlex keyboard overflow hazard by wrapping the entire form layout in `SingleChildScrollView`.
   - Title/Description, Amount ($) with number keyboard, Category selector dropdown/chips, Date selector.
   - Primary "Save Expense" and Outlined "Cancel" buttons with `AppButton`. Form validation.
   - Strictly < 200 lines.
3. `profile_screen.dart`:
   - Replace generic icon avatar with `AssetManager.userAvatar` (`assets/images/default_avatar.png`) with clean fallback.
   - Fix unconstrained Row overflow in profile header by wrapping text Column in `Expanded`/`Flexible`.
   - Interactive settings tiles:
     - Theme mode toggle tile.
     - Dietary preferences tile opening a multi-select dialog (Vegetarian, Halal, Gluten-Free, Vegan, Keto).
     - Currency and monthly budget selector dialog (USD $, EUR €, GBP £, BDT ৳).
     - Keep `ExportRecipesTile` intact for recipe CSV export.
     - Sign Out tile with confirmation dialog.
   - Extract `profile_header.dart` and `preference_dialogs.dart` under `lib/features/profile/presentation/widgets/` to ensure `profile_screen.dart` and every single file is strictly < 200 lines.
4. Architectural Constraints:
   - EVERY file strictly < 200 lines.
   - All text in Rows wrapped in `Flexible` or `Expanded` to prevent RenderFlex overflows.
   - Use centralized design tokens throughout.

VERIFICATION:
- Run `flutter analyze` and ensure 0 errors, 0 warnings.
- Run `flutter test` (add widget tests in `test/features/expenses/expense_screen_test.dart` and `test/features/profile/profile_screen_test.dart`).
- Write a detailed handoff report to `d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_m11_gen2\handoff.md` detailing changes, line counts, and verification output. Send a message when complete.
