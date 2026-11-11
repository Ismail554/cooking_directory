# Project: Cooking Directory Production Setup & Features

## Architecture
Feature-First Clean Architecture with Flutter 3.47.5:
```
lib/
├── app/               # App configuration, theme binding, root AppShell
├── bootstrap.dart     # System initialization (Firebase, ScreenUtil, bindings)
├── core/              # Centralized design tokens (AppColors, AppSpacing, StyleManager, ValueManager, FontManager, AssetManager, AppRouter)
├── features/
│   ├── app_shell/     # Bottom navigation shell (Expenses, Recipes, Profile) with branded assets & PopScope
│   ├── expenses/      # Expense tracking, categories, monthly budgets, analytics
│   ├── home/          # Recipe discovery, modular sub-widgets (<200 LOC), search, category filters
│   ├── recipes/       # Recipe CRUD, rich details (Sliver, checklist, steps), CSV export
│   ├── cooking_mode/  # Interactive cooking step-by-step, wakelock, multi-timer integration
│   ├── cooking_timer/ # Multi-timer engine, background/local notifications
│   ├── profile/       # Chef profile, preferences, export options, theme toggle, auth
│   └── authentication/# Firebase Auth, login/register, session management
└── shared/            # Shared models, widgets, utilities
```

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Master Implementation Plan (/plan) | Detailed architecture, roadmap, models, state management, phased rollout | M2 | R1 (Round 1) |
| 2 | Themed Asset Generation | 13 PNG/SVG/Lottie assets matching AppColors & design tokens | M3 | R2 (Round 1) |
| 3 | Asset Registration in pubspec | Register asset folders & add flutter_svg + lottie | M3 | R2 (Round 1) |
| 4 | Firebase Project Configuration | Configure cooking-directory-88438, generate firebase_options.dart, setup Android Gradle & bootstrap | M4 | R3 (Round 1) |
| 5 | Recipe Domain & Data Models | Recipe entity, RecipeModel with JSON/CSV mapping, seed catalog | M5 | R4 (Round 1) |
| 6 | Recipe CSV Converter & Exporter | RFC 4180 CSV serialization, file writing, share_plus export | M5 | R4 (Round 1) |
| 7 | Recipe Export Provider & UI Tile | State notifier and Settings/Profile export button with CustomSnackbar | M5 | R4 (Round 1) |
| 8 | Multi-layer Verification & Integrity Audit | Reviewers, Challengers, and Forensic Auditor verification | M6 | Acceptance Criteria |
| 9 | Core Design Tokens & Theming Polish | Add culinary gradients, drop shadows, rating/calorie badges to AppColors; make StyleManager & core views theme-aware; fix dark mode text contrast | M7 | Survey R1/R2 |
| 10 | Asset Adoption across UI & Shell | Connect AssetManager in AppShell (icExpense, icRecipe, userAvatar), AppEmptyView, AppLoadingView (Lottie); wire GoRouter PopScope & errorBuilder | M8 | Survey R1/R2 |
| 11 | Home Screen Modernization (<200 LOC) | Decompose HomeScreen into HomeHeader, HomeSearchBar, HomeCategoryPills, FeaturedRecipeCard, RecipeGridCard; use recipe_placeholder.png | M9 | Survey R1/R2 |
| 12 | Recipe Details & Interactive Cooking Mode | Rich RecipeDetailsScreen (Sliver, checklist, timeline); implement CookingModeScreen with step progress & wakelock; wire /cooking-mode route; fix AddRecipe overflow | M10 | Survey R1/R2 |
| 13 | Expenses & Profile Polish | ExpenseScreen budget card & category pills; fix AddExpense keyboard overflow; ProfileScreen expanded header, avatar, active theme switch & preference dialogs | M11 | Survey R1/R2 |
| 14 | Production E2E Verification & Forensic Audit | Run flutter analyze (0 errors, 0 warnings), flutter test (100% pass), Reviewers, Challengers, and Forensic Auditor verification | M12 | Acceptance Criteria |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Technical Survey (Round 1) | 3 Explorers inspecting codebase, assets, and Firebase | None | DONE |
| M2 | Master Implementation Plan | Comprehensive /plan document adhering to architecture & line limits | M1 | DONE |
| M3 | Asset Generation & Registration | Generate 13 themed assets, update pubspec.yaml, add flutter_svg/lottie | M1 | DONE |
| M4 | Firebase Project Configuration | flutterfire configure for cooking-directory-88438, bootstrap wiring | M1 | DONE |
| M5 | Recipe CSV Export in Settings | Clean Architecture CSV export feature in Profile/Settings (<200 lines/file) | M1 | DONE |
| M6 | Quality Verification & Forensic Audit | 2 Reviewers, 2 Challengers, 1 Forensic Auditor (Round 1) | M2, M3, M4, M5 | DONE |
| M7 | Core Design Tokens & Theming Fixes | Culinary gradients, shadows, theme-aware typography, Lottie loader, dark mode contrast | None | PLANNED |
| M8 | Shell & Asset Adoption | AppShell branded icons, PopScope, GoRouter /cooking-mode & errorBuilder | M7 | PLANNED |
| M9 | Home Screen Modernization | Decompose into sub-widgets (<200 LOC), hero cards, category pills, search bar | M7, M8 | PLANNED |
| M10 | Recipe Details & Cooking Mode | Sliver header, checklists, step timeline, CookingModeScreen with wakelock & timers | M7, M8 | PLANNED |
| M11 | Expenses & Profile Polish | Budget card, category pills, keyboard overflow fixes, Profile expanded header & dialogs | M7, M8 | PLANNED |
| M12 | Final E2E Verification & Forensic Audit | 2 Reviewers, 2 Challengers, 1 Forensic Auditor, flutter analyze, flutter test | M7-M11 | PLANNED |

## Interface Contracts & Layout Rules
- **Line limits**: Strict < 200 lines per file discipline across all Dart files.
- **Centralized tokens**: Use `AppColors`, `AppSpacing`, `StyleManager`, `FontManager`, `ValueManager`, `AssetManager`.
- **Keyboard overflow safety**: All input forms must be wrapped in `SingleChildScrollView`.
- **Row flex safety**: Any text Column inside a Row must be wrapped in `Expanded` or `Flexible`.
- **Dark Mode compatibility**: Text colors must adapt to `Theme.of(context).colorScheme.onSurface` or resolve from theme tokens.
