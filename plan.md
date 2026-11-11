# Master Phased Implementation Plan: Cooking Directory Production App

**Document Version**: 1.0.0  
**Target Project**: `cooking_directory`  
**Flutter SDK Target**: 3.47.5 • Dart 3.13.4  
**Firebase Project**: `cooking-directory-88438`  
**Architectural Pattern**: Feature-First Clean Architecture  
**Strict File Constraint**: Under 200 lines per file (`< 200 LOC`)  
**Design System Base**: Canvas 375x812 (`flutter_screenutil`), Warm Culinary Palette  

---

## Table of Contents
1. [Executive Summary & Architectural Foundations](#1-executive-summary--architectural-foundations)
2. [Code Layout & Clean Architecture Blueprint](#2-code-layout--clean-architecture-blueprint)
3. [Navigation Shell Architecture (AppShell)](#3-navigation-shell-architecture-appshell)
4. [Interactive Cooking Mode & Multi-Timer System](#4-interactive-cooking-mode--multi-timer-system)
5. [Backend Architecture & Offline-First Persistence](#5-backend-architecture--offline-first-persistence)
6. [Data Models & Entity Schemas](#6-data-models--entity-schemas)
7. [State Management Architecture](#7-state-management-architecture)
8. [Package Ecosystem & Dependency Roadmap](#8-package-ecosystem--dependency-roadmap)
9. [Phased Implementation Roadmap (Phases 1–6)](#9-phased-implementation-roadmap-phases-16)
10. [Quality Assurance, Line Count Audit & Verification Protocols](#10-quality-assurance-line-count-audit--verification-protocols)

---

## 1. Executive Summary & Architectural Foundations

The **Cooking Directory** is an enterprise-grade, offline-first culinary companion and household expense management application. It harmonizes recipe discovery, step-by-step interactive cooking with concurrent timers and screen wakelock, and expense tracking against monthly culinary budgets.

### Core Architectural Pillars
1. **Feature-First Clean Architecture**: Each business vertical (`recipes`, `cooking_mode`, `cooking_timer`, `expenses`, `profile`, `authentication`) is encapsulated into an autonomous module partitioned into three distinct layers:
   - `presentation/`: User interface widgets, screens, and state notifiers.
   - `domain/`: Business entities, repository interfaces, and use cases free of framework dependencies.
   - `data/`: Data models, local/remote data sources, API clients, and concrete repository implementations.
2. **Strict File Line Limit (< 200 LOC)**: Every file in `lib/` must strictly observe a maximum of 200 lines. Complex widgets, screens, models, and logic are decomposed into focused, single-responsibility components.
3. **Design System Token Centralization**: Zero inline styling or raw color literals. All styling strictly utilizes centralized managers:
   - `AppColors`: Warm Culinary Palette (Terracotta `#E65100`, Herb Green `#2E7D32`, Saffron `#FFA000`, Warm Linen `#FBF9F6`).
   - `FontManager` & `StyleManager`: 'Poppins' typeface scaled via `flutter_screenutil` (`.sp`).
   - `ValueManager`: Standardized radii (`AppRadius`), border radii (`AppBorderRadius`), icon sizes (`AppIconSize`), and elevations (`AppElevation`).
   - `AppSpacing`: Standard horizontal/vertical gaps (`AppSpacing.vGap16`, `hGap12`, etc.) and padding presets.
   - `AssetManager`: Canonical paths for all raster, vector, and animation assets.
4. **Offline-First Synchronization**: Local storage (Hive CE / Isar) serves as the immediate source of truth. Background sync manages bi-directional eventual consistency with Cloud Firestore when network connectivity is available.

---

## 2. Code Layout & Clean Architecture Blueprint

The application follows the directory structure outlined below:

```text
lib/
├── app/
│   ├── app.dart                                # MaterialApp, Theme, ScreenUtilInit
│   └── app_shell.dart                          # Persistent IndexedStack navigation shell
├── bootstrap.dart                              # Binding, Firebase, ScreenUtil, Error handlers
├── main.dart                                   # Application entry point
├── core/
│   ├── constants/
│   │   ├── app_constants.dart                  # Canvas size, durations, app metadata
│   │   ├── app_spacing.dart                    # Spacing tokens & gap widgets
│   │   └── storage_keys.dart                   # Storage key constants
│   ├── error/
│   │   ├── app_failure.dart                    # Domain failure abstractions
│   │   └── exceptions.dart                     # Custom data exceptions
│   ├── managers/
│   │   ├── app_colors.dart                     # Palette & semantic tokens
│   │   ├── asset_manager.dart                  # Centralized asset paths
│   │   ├── font_manager.dart                   # Typography metrics & Poppins family
│   │   ├── string_manager.dart                 # Localization / string tokens
│   │   ├── style_manager.dart                  # TextStyle factories
│   │   └── value_manager.dart                  # Radii, elevations, icon metrics
│   ├── network/
│   │   └── network_info.dart                   # Connectivity checker contract & impl
│   ├── storage/
│   │   ├── hive_storage_service.dart           # Local Hive CE adapter abstraction
│   │   └── storage_service.dart                # Key-value storage interface
│   ├── theme/
│   │   ├── app_theme.dart                      # Accessor for light & dark themes
│   │   ├── light_theme.dart                    # Material3 Light ThemeData (<200 LOC)
│   │   └── dark_theme.dart                     # Material3 Dark ThemeData (<200 LOC)
│   ├── utils/
│   │   └── responsive_utils.dart               # Breakpoints & responsive helpers
│   ├── validation/
│   │   └── validator.dart                      # Form & field validation logic
│   └── widgets/
│       ├── app_button.dart                     # Universal button with loading states
│       ├── app_empty_view.dart                 # Themed empty state presentation
│       ├── app_error_view.dart                 # Standard error state with retry action
│       ├── app_loading_view.dart               # Circular / Lottie progress view
│       └── custom_snackbar.dart                # Floating feedback banner
├── features/
│   ├── app_shell/                              # Navigation shell coordination
│   ├── authentication/                         # Auth flow & credential management
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── cooking_mode/                           # Fullscreen guided cooking session
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── cooking_timer/                          # Multi-timer engine & notifications
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── expenses/                               # Budgeting & expense tracking
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── home/                                   # Discovery & curated feed
│   │   └── presentation/
│   ├── profile/                                # Preferences, themes, CSV export
│   │   └── presentation/
│   └── recipes/                                # Recipe CRUD, details & catalog
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
    ├── models/                                 # Cross-cutting entity definitions
    └── widgets/                                # Shared domain-independent widgets
```

### Module Boundary Enforcement
- **Domain Layer (`domain/`)**: Pure Dart with zero Flutter UI imports (`package:flutter/material.dart` is prohibited). Depends only on Dart core libraries.
- **Data Layer (`data/`)**: Implements domain repository interfaces. Handles JSON mapping, Firestore serializations, and Hive local boxes.
- **Presentation Layer (`presentation/`)**: Consists of `screens/`, `widgets/`, and `providers/`. Communicates with domain layer exclusively through Use Cases or Repository interfaces injected via Provider.

---

## 3. Navigation Shell Architecture (AppShell)

The root navigation structure maintains persistent screen state across tab switches via `IndexedStack`.

### Shell Destinations
```
                       ┌──────────────────────────────┐
                       │     AppShell Navigation      │
                       └──────────────┬───────────────┘
                                      │
            ┌─────────────────────────┼─────────────────────────┐
            ▼                         ▼                         ▼
  ┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
  │  Tab 0: Expenses │      │ Tab 1: Recipes   │      │ Tab 2: Profile   │
  │  (Budget/Trends) │      │ (Catalog/Search) │      │ (Settings/Export)│
  └──────────────────┘      └──────────────────┘      └──────────────────┘
```

### Tab 0: Expenses Vertical
- **Monthly Food Budget Card**: Displays current month's aggregate culinary spending vs. set budget goal with `LinearProgressIndicator`. Threshold indicators:
  - Green / Normal: Spending < 80% of budget.
  - Saffron / Warning: Spending between 80% and 99%.
  - Coral / Danger: Spending >= 100% of budget.
- **Category Spend Distribution**: Breakdown across 6 categorized buckets (`expenseGroceries`, `expenseDiningOut`, `expenseEquipment`, `expenseBeverages`, `expenseSpices`, `expenseMiscellaneous`).
- **Visual Spend Trends**: Weekly comparison bar chart illustrating day-by-day kitchen expenses.
- **Expense Log List**: Chronological transaction feed with quick-swipe deletion and category badges.
- **Add Expense Dialog**: Fast-entry modal supporting amount, category selector, receipt photo attachment, and linked recipe assignment.

### Tab 1: Home & Recipe Discovery Vertical
- **App Bar & Header**: Dynamic greeting with quick search bar and active cooking banner (if session active).
- **Category Filter Carousel**: Horizontal filter chips (Breakfast, Lunch, Dinner, Desserts, Healthy, Vegan, Quick & Easy).
- **Curated Recipe Feed**: High-performance staggered grid displaying recipe cards (cover photo, prep time, difficulty badge, calories, favorite bookmark).
- **Interactive Search & Faceting**: Search by recipe name, pantry ingredients, max cook time, and dietary tags.
- **Recipe Creation Wizard**: Step-by-step creation flow (<200 LOC per step screen) with photo picker, dynamic ingredient list, and step-by-step timer configuration.

### Tab 2: Profile & Settings Vertical
- **Chef Identity Card**: User avatar, culinary skill level badge, recipe count, and saved favorites counter.
- **Personal Information**: Name, email, and password management.
- **Dietary & Allergen Preferences**: Allergen exclusion tags (Gluten-free, Nut-free, Dairy-free, Halal, Vegetarian) used to auto-tag search results.
- **Currency & Budget Settings**: Configurable currency symbol (`$`, `€`, `£`, `৳`, `₹`) and monthly default budget limit.
- **Appearance & Theme**: Toggle between Light Mode, Dark Mode, and System Theme with persistent state.
- **Recipe CSV Export Tile (Requirement R4)**: Standardized RFC 4180 CSV export for all recipes with instant `share_plus` dispatch and `CustomSnackbar` status.
- **Session Control**: Logout action with confirmation dialog, clearing cached tokens while preserving offline user recipes.

---

## 4. Interactive Cooking Mode & Multi-Timer System

The Cooking Mode is an immersion-focused, hands-free optimized experience designed for use in active kitchen environments.

```
┌──────────────────────────────────────────────────────────────┐
│                    Cooking Mode Viewport                     │
├──────────────────────────────────────────────────────────────┤
│ [Exit]                 Step 3 of 6              [Timer Tray] │
│ ══════════════════════ 50% Progress ═══════════════════════ │
│                                                              │
│  "Sear the chicken breasts in hot olive oil for 6 minutes    │
│   until golden brown on both sides."                         │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ Required Ingredients for this Step:                    │  │
│  │  [x] 2 Boneless Chicken Breasts (Scaled 1x)            │  │
│  │  [ ] 2 tbsp Extra Virgin Olive Oil                     │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  Personal Note: "Use cast iron skillet for crispier skin"    │
│                                                              │
│  ┌──────────────────────┐        ┌─────────────────────────┐ │
│  │ Active Timer: 05:42  │        │ [ Next Step ]           │ │
│  │ [ Pause ] [ +1 Min ] │        │                         │ │
│  └──────────────────────┘        └─────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

### 4.1 Step-by-Step Cooking Architecture
- **Distraction-Free Fullscreen View**: Automatically activates `WakelockPlus.enable()` on entry and `WakelockPlus.disable()` on dispose, preventing phone sleep while cooking.
- **Large-Print Instruction Cards**: Responsive typography (`FontSize.s20` to `s26`) readable from counter distances.
- **Ingredient Scaling Engine**: Dynamic scaling coefficient (e.g. 0.5x, 1x, 2x, 4x servings) recalculating ingredient quantities in real time.
- **Step Ingredient Checklists**: Interactive checkboxes for ingredients needed on the current step, with state persisted in the active `CookingSession`.
- **Step Notes & Variations**: Ephemeral and durable cook notes saved per recipe step for user tips.

### 4.2 Multi-Timer Concurrent Engine
- **Independent Timer Workers**: Each timer runs on an isolated countdown stream (`Timer.periodic(Duration(seconds: 1))`) managed by `CookingTimerNotifier`.
- **Multiple Concurrent Timers**: Supports arbitrary simultaneous timers (e.g., "Oven Roast 45m", "Pasta Boil 8m", "Garlic Sauté 3m").
- **Local & Background Notifications**: Integrated via `flutter_local_notifications`. When the app is minimized or phone locked, notifications trigger with title, step name, sound, and high-priority channel alerts.
- **Auditory & Haptic Feedback**: Completion fires distinct acoustic alert tone accompanied by vibration patterns (`vibration` / system feedback).
- **Persistent Bottom Mini-Bar**: If the user exits Cooking Mode to browse recipes or log expenses, a floating bottom mini-player displays active timers and quick-return controls.

---

## 5. Backend Architecture & Offline-First Persistence

```
┌───────────────────────────────────────────────────────────────────────────┐
│                           Data & Sync Architecture                        │
│                                                                           │
│   ┌──────────────────────────┐             ┌──────────────────────────┐   │
│   │   UI Presentation        │             │   Domain Use Cases       │   │
│   └─────────────┬────────────┘             └─────────────▲────────────┘   │
│                 │                                        │                │
│                 ▼                                        │                │
│   ┌──────────────────────────────────────────────────────┴────────────┐   │
│   │                      Repository Layer                             │   │
│   └─────────────┬────────────────────────────────────────▲────────────┘   │
│                 │                                        │                │
│       ┌─────────┴───────────────┐              ┌─────────┴────────────┐   │
│       ▼                         ▼              │                      │   │
│ ┌───────────────┐       ┌───────────────┐      │  Local Hive Storage  │   │
│ │ Connectivity  │       │ Sync Manager  │◄────►│  (Zero-latency cache)│   │
│ └───────────────┘       └───────┬───────┘      └──────────────────────┘   │
│                                 │                                         │
│                                 ▼                                         │
│                      ┌─────────────────────┐                              │
│                      │ Cloud Firestore SDK │                              │
│                      └─────────────────────┘                              │
└───────────────────────────────────────────────────────────────────────────┘
```

### 5.1 Firebase Project Configuration (`cooking-directory-88438`)
1. **Firebase Core**: Initialized in `lib/bootstrap.dart` using generated `DefaultFirebaseOptions.currentPlatform` (`lib/firebase_options.dart`).
2. **Authentication (`firebase_auth`)**:
   - Supports Email & Password registration/login, Google Sign-In, and Guest Mode.
   - User profile record stored in `users/{userId}`.
3. **Cloud Firestore Schema**:
   - `users/{userId}`: User settings, dietary preferences, default currency, monthly budget.
   - `users/{userId}/recipes/{recipeId}`: User's custom recipes and edits.
   - `public_recipes/{recipeId}`: Curated global recipe catalog for search & discovery.
   - `users/{userId}/expenses/{expenseId}`: Kitchen and grocery expense records.
   - `users/{userId}/cooking_sessions/{sessionId}`: Historical and active cooking logs.
4. **Cloud Firestore Security Rules**:
   - Strict tenant isolation: `request.auth != null && request.auth.uid == userId` for all write and private read operations.
   - Public recipes collection readable by all authenticated users, writable only by admin.
5. **Firebase Storage Schema**:
   - `users/{userId}/avatars/avatar.jpg`
   - `users/{userId}/recipes/{recipeId}/cover.jpg`
   - `users/{userId}/expenses/{expenseId}/receipt.jpg`

### 5.2 Offline-First Local Persistence Strategy
- **Local Storage Provider**: Hive CE (`hive_ce` & `hive_ce_flutter`) provides lightning-fast NoSQL key-value and typed object boxes.
- **Type Adapters**:
  - `RecipeAdapter` (Box: `recipes_box`)
  - `ExpenseAdapter` (Box: `expenses_box`)
  - `UserSettingsAdapter` (Box: `settings_box`)
  - `ActiveSessionAdapter` (Box: `session_box`)
- **Sync Protocol**:
  - Every entity includes `updatedAt` (timestamp) and `syncStatus` (`synced`, `pending_upload`, `pending_delete`).
  - Writes occur locally first (instant UI feedback), followed by a background sync job.
  - On connectivity restoration, the sync manager replays `pending_upload` mutations to Firestore and resolves collisions via Last-Write-Wins (LWW).

---

## 6. Data Models & Entity Schemas

### 6.1 Recipe Domain Entity (`lib/features/recipes/domain/entities/recipe.dart`)
```dart
class Recipe {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final int calories;
  final String difficulty; // Easy, Medium, Hard
  final List<Ingredient> ingredients;
  final List<CookingStep> steps;
  final List<String> tags;
  final String? imageUrl;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Constructor and copyWith (<70 lines)
}
```

### 6.2 Ingredient Entity (`lib/features/recipes/domain/entities/ingredient.dart`)
```dart
class Ingredient {
  final String id;
  final String name;
  final double amount;
  final String unit; // g, ml, tbsp, tsp, cup, piece
  final bool isChecked;
  final String? note;
  // Scaled quantity helper: double getScaledAmount(double factor) => amount * factor;
}
```

### 6.3 Cooking Step Entity (`lib/features/recipes/domain/entities/cooking_step.dart`)
```dart
class CookingStep {
  final int stepNumber;
  final String instruction;
  final int? timerDurationMinutes;
  final String? imageUrl;
  final String? tip;
  final List<String> stepIngredientIds;
  final bool isCompleted;
}
```

### 6.4 Cooking Timer Entity (`lib/features/cooking_timer/domain/entities/cooking_timer.dart`)
```dart
class CookingTimer {
  final String id;
  final String recipeId;
  final int stepNumber;
  final String label;
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final bool isPaused;
  final DateTime? startedAt;
  // Progress ratio getter: double get progress => remainingSeconds / totalSeconds;
}
```

### 6.5 Expense Entity (`lib/features/expenses/domain/entities/expense.dart`)
```dart
class Expense {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String category; // Groceries, Dining Out, Equipment, Beverages, Spices, Misc
  final DateTime date;
  final String? receiptImageUrl;
  final String? linkedRecipeId;
  final String? notes;
  final DateTime createdAt;
}
```

### 6.6 Budget Entity (`lib/features/expenses/domain/entities/budget.dart`)
```dart
class Budget {
  final String id;
  final String userId;
  final int month;
  final int year;
  final double monthlyLimit;
  final double currentSpending;
  // Percentage helper: double get usagePercentage => (currentSpending / monthlyLimit) * 100;
}
```

---

## 7. State Management Architecture

The project leverages `provider: ^6.1.5+1` combined with structured `ChangeNotifier` notifiers adhering to clean separation of concerns.

### 7.1 Provider Inventory & Layering
```text
Provider Hierarchy (Inherited via MultiProvider in AppShell / App):
├── ThemeNotifier              # Dark/Light/System theme mode persistence
├── AuthNotifier               # User auth status, profile details, login/logout
├── RecipeListNotifier         # Catalog search, category filters, paging
├── RecipeDetailNotifier       # Individual recipe details, favorites toggle
├── RecipeExportNotifier       # CSV export workflow & status dispatch
├── CookingSessionNotifier     # Active step progression, ingredient checklist
├── CookingTimerNotifier       # Concurrent countdown timers, sound/wakelock
├── ExpenseNotifier            # Transaction logging, category filters, delete
└── BudgetNotifier             # Monthly budget configuration, progress metrics
```

### 7.2 State Flow Cycle
1. **View / UI**: User triggers an action (e.g. taps "Export CSV" or "Start Timer").
2. **Notifier**: Dispatches request to the injected Use Case. Emits `ViewState.loading` via `notifyListeners()`.
3. **Use Case**: Coordinates domain logic, validates business rules, and invokes Repository method.
4. **Repository**: Queries local cache (Hive) or remote datasource (Firestore), maps DTO model to domain Entity, and returns `Either<AppFailure, T>` or entity result.
5. **Notifier**: Updates state (`ViewState.success` or `ViewState.error`), saves result, and invokes `notifyListeners()`.
6. **Consumer / Selector**: UI selectively rebuilds the impacted widget sub-tree.

---

## 8. Package Ecosystem & Dependency Roadmap

All dependencies have been verified against Flutter 3.47.5 and Dart 3.13.4 for version compatibility:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Design & Responsive Framework
  cupertino_icons: ^1.0.8
  flutter_screenutil: ^5.9.3
  flutter_svg: ^2.0.17
  lottie: ^3.3.1

  # State Management & DI
  provider: ^6.1.5+1

  # Backend & Cloud Services
  firebase_core: ^5.1.0
  firebase_auth: ^7.0.1
  cloud_firestore: ^7.1.0
  firebase_storage: ^14.0.1

  # Local Persistence & Storage
  hive_ce: ^2.11.0
  hive_ce_flutter: ^2.3.0
  shared_preferences: ^2.3.5

  # Hardware, Hardware Sleep & Background Notifications
  wakelock_plus: ^1.2.8
  flutter_local_notifications: ^18.0.1
  audioplayers: ^6.1.0

  # Serialization, Export & Utilities
  csv: ^6.0.0
  path_provider: ^2.1.5
  share_plus: ^10.1.3
  intl: ^0.19.0
  uuid: ^4.5.1
  connectivity_plus: ^6.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.4.15
  hive_ce_generator: ^2.0.0
  mockito: ^5.4.5
```

---

## 9. Phased Implementation Roadmap (Phases 1–6)

```
┌────────────────────────────────────────────────────────────────────────┐
│                        Phased Rollout Timeline                         │
├─────────────────┬──────────────────────────────────────────────────────┤
│ Phase 1         │ Foundation, Themed Assets & Firebase Setup           │
├─────────────────┼──────────────────────────────────────────────────────┤
│ Phase 2         │ Clean Architecture Core, Domain Entities & Hive DB   │
├─────────────────┼──────────────────────────────────────────────────────┤
│ Phase 3         │ Recipe Catalog, Discovery & Recipe CSV Export        │
├─────────────────┼──────────────────────────────────────────────────────┤
│ Phase 4         │ Cooking Mode, Multi-Timers, Notifications & Wakelock │
├─────────────────┼──────────────────────────────────────────────────────┤
│ Phase 5         │ Expense Tracker, Category Budgets & Visual Trends    │
├─────────────────┼──────────────────────────────────────────────────────┤
│ Phase 6         │ Cloud Synchronization, E2E Testing & Hardening       │
└─────────────────┴──────────────────────────────────────────────────────┘
```

---

### Phase 1: Foundation, Themed Assets & Firebase Setup
**Primary Objective**: Establish the baseline environment, register assets, configure Firebase backend, and ensure 100% build health.

#### Key Deliverables:
1. **Asset Generation & Placement**:
   - Generate all 13 required assets per `AssetManager` specification:
     - Images (`assets/images/`): `app_logo.png`, `splash_bg.png`, `recipe_placeholder.png`, `default_avatar.png`, `empty_state.png`.
     - Icons (`assets/icons/`): `ic_timer.png`, `ic_recipe.png`, `ic_expense.png`.
     - Vectors (`assets/svgs/`): `cooking_pot.svg`, `chef_hat.svg`, `no_data.svg`.
     - Animations (`assets/jsons/`): `cooking_anim.json`, `loading.json`.
2. **`pubspec.yaml` Update**:
   - Uncomment and register `assets/images/`, `assets/icons/`, `assets/svgs/`, and `assets/jsons/`.
   - Add dependencies: `flutter_svg`, `lottie`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`.
3. **Firebase Project Configuration**:
   - Run `flutterfire configure --project=cooking-directory-88438` targeting `android`, `ios`, `web`, `windows`.
   - Generate `lib/firebase_options.dart`.
   - Wire `android/settings.gradle.kts` (`id("com.google.gms.google-services") version "4.4.2" apply false`).
   - Wire `android/app/build.gradle.kts` (`id("com.google.gms.google-services")`).
   - Add internet permission to `android/app/src/main/AndroidManifest.xml`.
   - Initialize `Firebase.initializeApp` in `lib/bootstrap.dart`.

#### Verification Criteria:
- `flutter test` executes cleanly.
- `dart analyze lib/` returns 0 errors.
- All 13 asset files exist on disk with non-zero byte size.
- `lib/firebase_options.dart` exists and compiles.

---

### Phase 2: Clean Architecture Core, Domain Entities & Local Storage
**Primary Objective**: Implement the core data layer, Hive CE local storage adapters, domain models, and seed catalog.

#### Key Deliverables:
1. **Domain Entities**:
   - `lib/features/recipes/domain/entities/recipe.dart` (<70 LOC)
   - `lib/features/recipes/domain/entities/ingredient.dart` (<50 LOC)
   - `lib/features/recipes/domain/entities/cooking_step.dart` (<50 LOC)
   - `lib/features/expenses/domain/entities/expense.dart` (<60 LOC)
   - `lib/features/expenses/domain/entities/budget.dart` (<45 LOC)
2. **Data Transfer Objects & Models**:
   - `lib/features/recipes/data/models/recipe_model.dart` (<110 LOC)
   - `lib/features/recipes/data/models/ingredient_model.dart` (<70 LOC)
   - `lib/features/recipes/data/models/cooking_step_model.dart` (<70 LOC)
   - `lib/features/expenses/data/models/expense_model.dart` (<90 LOC)
3. **Local Storage Setup**:
   - `lib/core/storage/hive_storage_service.dart` (<120 LOC)
   - Initialize Hive boxes in `lib/bootstrap.dart`.
4. **Seed Catalog**:
   - `lib/features/recipes/data/datasources/recipe_local_datasource.dart` (<120 LOC) with 5 culinary master recipes (e.g. Creamy Tuscan Garlic Chicken, Classic Beef Bolognese, Lemon Herb Salmon, Thai Green Curry, Berry Chia Pudding Bowl).

#### Verification Criteria:
- Unit tests verify serialization/deserialization between JSON, Hive models, and Entities.
- Local datasource supplies 5 seed recipes out of the box.

---

### Phase 3: Recipe Catalog, Discovery & Recipe CSV Export
**Primary Objective**: Build the recipe discovery presentation, search/filtering, and complete the Recipe CSV Export feature in Settings.

#### Key Deliverables:
1. **Recipe CSV Export Engine (Requirement R4)**:
   - `lib/features/recipes/domain/repositories/recipe_repository.dart` (<35 LOC)
   - `lib/features/recipes/domain/usecases/export_recipes_to_csv_usecase.dart` (<50 LOC)
   - `lib/features/recipes/data/services/recipe_csv_converter.dart` (<80 LOC) (RFC 4180 standard escaping, headers: ID, Title, Description, Category, Prep Time, Cook Time, Servings, Calories, Difficulty, Ingredients, Steps, Created At).
   - `lib/features/recipes/data/services/recipe_file_exporter.dart` (<65 LOC) (Writes file to app documents, invokes `SharePlus.shareXFiles`).
   - `lib/features/recipes/data/repositories/recipe_repository_impl.dart` (<90 LOC).
   - `lib/features/recipes/presentation/providers/recipe_export_provider.dart` (<85 LOC).
   - `lib/features/profile/presentation/widgets/export_recipes_tile.dart` (<80 LOC).
   - Integrate `ExportRecipesTile` into `lib/features/profile/presentation/screens/profile_screen.dart` (<110 LOC).
2. **Home Screen Modularization**:
   - Refactor `lib/features/home/presentation/screens/home_screen.dart` to split child widgets into:
     - `lib/features/home/presentation/widgets/recipe_search_bar.dart` (<70 LOC)
     - `lib/features/home/presentation/widgets/category_chip_list.dart` (<75 LOC)
     - `lib/features/home/presentation/widgets/recipe_card.dart` (<110 LOC)
     - Main `home_screen.dart` brought well under 120 LOC.
3. **Recipe Detail Screen**:
   - `lib/features/recipes/presentation/screens/recipe_detail_screen.dart` (<130 LOC) with ingredient overview and "Start Cooking" CTA.

#### Verification Criteria:
- CSV export generates valid RFC 4180 file with correct headers and escapes.
- Unit test suite for `recipe_csv_converter_test.dart` and `export_recipes_to_csv_usecase_test.dart` passes 100%.
- Tapping CSV export on Profile screen triggers file sharing and displays `CustomSnackbar.showSuccess`.

---

### Phase 4: Interactive Cooking Mode & Concurrent Multi-Timer Engine
**Primary Objective**: Deliver the guided step-by-step cooking experience with ingredient scaling, multi-timer alerts, screen wakelock, and background notifications.

#### Key Deliverables:
1. **Cooking Timer Engine**:
   - `lib/features/cooking_timer/domain/entities/cooking_timer.dart` (<65 LOC)
   - `lib/features/cooking_timer/presentation/providers/cooking_timer_notifier.dart` (<140 LOC) (Starts, pauses, resets, and monitors multiple timers).
   - `lib/features/cooking_timer/data/services/timer_notification_service.dart` (<110 LOC) (`flutter_local_notifications` setup, scheduling, and cancellation).
   - `lib/features/cooking_timer/presentation/widgets/timer_card.dart` (<90 LOC).
   - `lib/features/cooking_timer/presentation/widgets/active_timers_tray.dart` (<95 LOC).
2. **Interactive Cooking Mode Screen**:
   - `lib/features/cooking_mode/presentation/screens/cooking_mode_screen.dart` (<140 LOC):
     - Activates `WakelockPlus.enable()` on initState and `disable()` on dispose.
     - Progress bar tracking current step vs. total steps.
   - `lib/features/cooking_mode/presentation/widgets/cooking_step_card.dart` (<110 LOC).
   - `lib/features/cooking_mode/presentation/widgets/step_ingredient_checklist.dart` (<90 LOC).
   - `lib/features/cooking_mode/presentation/widgets/serving_scaler_selector.dart` (<75 LOC).
   - `lib/features/cooking_mode/presentation/widgets/step_notes_input.dart` (<80 LOC).
3. **Session Persistence**:
   - `lib/features/cooking_mode/presentation/providers/cooking_session_notifier.dart` (<120 LOC) (Saves ongoing session in Hive).

#### Verification Criteria:
- Screen remains awake during cooking mode (`WakelockPlus.enabled`).
- Timers run concurrently and fire notifications upon countdown completion.
- Ingredient scaling updates quantities correctly (e.g. 2x multiplier).

---

### Phase 5: Expense Tracker, Category Budgets & Visual Trends
**Primary Objective**: Implement the complete kitchen expense tracking vertical with budget limits, visual charts, and category summaries.

#### Key Deliverables:
1. **Expense Repositories & State**:
   - `lib/features/expenses/domain/repositories/expense_repository.dart` (<45 LOC)
   - `lib/features/expenses/domain/usecases/get_monthly_expenses_usecase.dart` (<40 LOC)
   - `lib/features/expenses/domain/usecases/add_expense_usecase.dart` (<45 LOC)
   - `lib/features/expenses/data/repositories/expense_repository_impl.dart` (<95 LOC)
   - `lib/features/expenses/presentation/providers/expense_notifier.dart` (<130 LOC)
   - `lib/features/expenses/presentation/providers/budget_notifier.dart` (<110 LOC)
2. **Modular Expense UI**:
   - Refactor `lib/features/expenses/presentation/screens/expense_screen.dart` (<110 LOC).
   - Child components:
     - `lib/features/expenses/presentation/widgets/monthly_budget_card.dart` (<115 LOC)
     - `lib/features/expenses/presentation/widgets/category_spend_chart.dart` (<130 LOC)
     - `lib/features/expenses/presentation/widgets/expense_list_tile.dart` (<85 LOC)
     - `lib/features/expenses/presentation/widgets/add_expense_bottom_sheet.dart` (<140 LOC)

#### Verification Criteria:
- Adding expenses updates monthly budget progress bar and remaining balance immediately.
- Categories map to their exact `AppColors` tokens (`expenseGroceries`, `expenseDiningOut`, etc.).
- Exceeding 100% budget triggers coral warning state.

---

### Phase 6: Cloud Synchronization, E2E Testing & Hardening
**Primary Objective**: Connect Cloud Firestore synchronization, implement Firestore security rules, run full test suites, and audit line count limits.

#### Key Deliverables:
1. **Cloud Firestore Sync**:
   - `lib/core/network/sync_manager.dart` (<150 LOC) (Coordinates bi-directional sync between Hive boxes and Firestore collections).
   - Firestore security rules file `firestore.rules` deployed to project `cooking-directory-88438`.
2. **Comprehensive Test Suite**:
   - Unit tests covering all domain use cases, models, and converters.
   - Widget tests for `AppShell`, `HomeScreen`, `ExpenseScreen`, `ProfileScreen`, and `CookingModeScreen`.
   - Asset load verification test confirming 0 missing assets.
3. **Forensic Line Count Audit**:
   - Automated script verifying every `.dart` file under `lib/` has strictly `< 200 LOC`.

#### Verification Criteria:
- All unit, widget, and integration tests pass cleanly.
- `dart analyze` reports zero warnings or errors.
- Every file in `lib/` is strictly under 200 lines.

---

## 10. Quality Assurance, Line Count Audit & Verification Protocols

### 10.1 Automated Line Count Audit Verification
To guarantee adherence to the `< 200 lines per file` rule, run the following PowerShell command across the workspace:

```powershell
Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | ForEach-Object {
    $lines = (Get-Content $_.FullName | Measure-Object -Line).Lines
    if ($lines -ge 200) {
        Write-Error "VIOLATION: $($_.FullName) has $lines lines (limit: <200)"
    }
}
```

### 10.2 Asset Integrity Verification
Run the following check to ensure all declared assets in `AssetManager` are present on disk:

```powershell
$assets = @(
    "assets/images/app_logo.png",
    "assets/images/splash_bg.png",
    "assets/images/recipe_placeholder.png",
    "assets/images/default_avatar.png",
    "assets/images/empty_state.png",
    "assets/icons/ic_timer.png",
    "assets/icons/ic_recipe.png",
    "assets/icons/ic_expense.png",
    "assets/svgs/cooking_pot.svg",
    "assets/svgs/chef_hat.svg",
    "assets/svgs/no_data.svg",
    "assets/jsons/cooking_anim.json",
    "assets/jsons/loading.json"
)

foreach ($asset in $assets) {
    if (-not (Test-Path $asset)) {
        Write-Error "MISSING ASSET: $asset"
    } else {
        $len = (Get-Item $asset).Length
        if ($len -eq 0) {
            Write-Error "EMPTY ASSET: $asset"
        }
    }
}
```

### 10.3 Compilation & Static Analysis Protocols
```bash
# 1. Resolve all dependencies
flutter pub get

# 2. Run Dart static analyzer
dart analyze lib/ test/

# 3. Execute all unit and widget tests
flutter test
```

---

*Master Plan approved for implementation across milestones M2, M3, M4, M5, and M6.*
