# Implementation Plan: Cooking Directory Production Setup & Features

## Objective
Execute the four core requirements from Round 1 and the UI & Asset Polish + E2E Verification requirements from Round 2.

## Round 1 Milestones (Completed)
- M1: Technical Survey & Codebase Exploration (DONE)
- M2: Master Application Implementation Plan (DONE)
- M3: Themed Asset Generation & Registration (DONE)
- M4: Firebase Configuration (`cooking-directory-88438`) (DONE)
- M5: Recipe CSV Export Feature in Settings (<200 LOC/file) (DONE)
- M6: Quality Verification, Review, Adversarial & Forensic Audit (DONE)

## Round 2 Milestones (To Execute in Generation 2)
- M7: Core Design Tokens & Theming Fixes (Culinary gradients, drop shadows, theme-aware typography, Lottie loader, dark mode contrast)
- M8: Shell & Asset Adoption (`AppShell` branded tab icons, Android `PopScope`, `AppRouter` `/cooking-mode` & `errorBuilder`)
- M9: Home Screen Modernization (<200 LOC modular decomposition: `HomeHeader`, `HomeSearchBar`, `HomeCategoryPills`, `FeaturedRecipeCard`, `RecipeGridCard`, using `AssetManager.recipePlaceholder`)
- M10: Recipe Details & Interactive Cooking Mode (`RecipeDetailsScreen` Sliver header, servings scaler, ingredient checklist, step timeline; `CookingModeScreen` with wakelock & timers; `AddRecipeScreen` keyboard overflow fix)
- M11: Expenses & Profile Polish (`ExpenseScreen` budget card & category pills; `AddExpenseScreen` keyboard overflow fix; `ProfileScreen` expanded header, avatar, active theme switch & settings dialogs)
- M12: Final Production E2E Verification & Forensic Audit (`flutter analyze` 0 errors/0 warnings, `flutter test` 100% passing, 2 Reviewers, 2 Challengers, 1 Forensic Auditor)
