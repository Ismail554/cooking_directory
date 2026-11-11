---
name: flutter-clean-feature
description: 'Senior-level Flutter feature development with strict Clean Architecture (UI → Provider → Service/Controller → Repository → ApiClient/Dio), feature-based folder structure, centralized managers (colors/assets/fonts/styles), repository-level API validation, offline handling, shimmer loading, pagination, and a 200-line-per-file discipline. Use this any time the user asks to build, scaffold, refactor, or review a Flutter feature, screen, or module — even if they just say "add a screen for X" or "hook up this API" rather than naming the architecture explicitly. Also use it when reviewing existing Flutter code for architecture violations, performance issues, or code smells.'
---

# Flutter Senior Feature Development (Clean Architecture + Provider)

Build or refactor Flutter features to a senior-engineer standard: strict layer
separation, a scalable feature-based folder structure, minimal rebuilds, safe
typed data, and production-quality UX for every screen state.

This skill assumes REST APIs via Dio, Provider-style state management, secure
token storage, and a feature-based architecture. If the project already uses
something different (Riverpod, Bloc, GetX, a different folder convention),
adapt the layer rules to fit rather than forcing a rewrite — the architecture
principles matter more than the exact package names.

## Reference files

This SKILL.md covers the workflow and the rules you need for almost every
task. Reach for these only when the task calls for that depth of detail:

- `references/layers-deep-dive.md` — full responsibilities, code examples, and
  anti-patterns for each layer (UI, Provider, Service, Repository, ApiClient),
  plus JSON parsing safety and SOLID principles. Read this before writing
  Repository or Service code for the first time in a session.
- `references/folder-structure.md` — the complete `lib/` and `test/` scaffold,
  plus a worked example feature.
- `references/managers-and-services.md` — the core managers (colors, assets,
  fonts, styles, values) and core services (auth token, cache, connectivity,
  storage, permissions, Dio), plus dependencies and env/secrets handling.
- `references/ui-state-patterns.md` — state class design, rebuild
  optimization (`Selector`/`context.select()`), every required screen state
  (loading/empty/error/offline/retry/success), lists/pagination/shimmer,
  navigation, form & password validation, snackbars, and performance rules.
- `references/testing-and-checklists.md` — what to test per layer, plus the
  self-testing and code-review checklists to run before delivering.
- `references/templates.md` — the feature-generation template, clarification
  questions, hard-stop conditions, and final delivery format.

## Why this level of rigor

Flutter apps that skip this discipline tend to accumulate the same failure
modes: screens that silently crash on a missing JSON key, providers stuffed
with business logic that can't be tested, 800-line God widgets, and rebuild
storms from `context.watch()` on a whole provider. Every rule below exists to
prevent one of these specific, recurring failures — not for its own sake.

## Before writing code: collect the inputs

Ask for whatever isn't already given. Don't guess on things that would change
the architecture (see `references/templates.md` for the full clarification
list and hard-stop conditions), but don't stall on things you can placeholder.

1. **Feature name** — snake_case folder (`match_details`), UpperCamelCase
   classes (`MatchDetailsProvider`).
2. **Screens & entry points** — which screens, and how users reach them
   (bottom nav, deep link, notification tap, etc.).
3. **API endpoints** — method, path, auth requirement, sample success/error
   JSON, pagination shape. Coding against an unknown response shape is the
   single most common source of rework later.
4. **Empty-state rules** — what counts as "no data" for this specific
   feature (no matches, no favorites, empty search, etc.).
5. **Permissions** — camera, location, storage, notifications, etc.
6. **State management & navigation** — default to Provider and plain
   Navigator; only introduce `go_router` if the feature needs deep links,
   auth guards, shell routes, or web URL sync — ask before switching an
   existing project's approach.

If the user says to proceed without full details, build with clearly marked
placeholders (e.g., a `// TODO: confirm empty-state rule` comment) rather than
inventing production assumptions.

## The architecture, in one line

```
UI → Provider → Service/Controller → Repository → ApiClient/DioService
```

No layer calls past its neighbor — UI never touches Repository or ApiClient
directly, Provider never parses JSON or calls Dio, Service never touches
`BuildContext`. See `references/layers-deep-dive.md` for the full rules and
why each boundary matters.

Quick responsibility map:

| Layer | Owns | Never does |
|---|---|---|
| UI | Rendering, input capture, calling Provider intent methods | API calls, JSON parsing, business rules |
| Provider | State only, exposes `load()/refresh()/retry()/loadMore()` | Parsing, Dio calls, snackbars, navigation |
| Service/Controller | Business rules, combining repositories (`Future.wait`) | Rendering, `BuildContext`, navigation |
| Repository | Connectivity check, calling ApiClient, validating & typing the response | Passing raw JSON upward |
| ApiClient/DioService | Dio setup, headers, auth token, interceptors | Feature-specific business rules |

JSON parsing happens **only** inside model `fromJson()`/`toJson()` methods —
never in a screen, provider, service, or widget file.

## Folder structure (short form)

```
lib/
  core/            # constants, managers, theme, routing, network, services, validation, utils, shared widgets
  features/
    feature_name/
      data/        # models/, repositories/
      business/    # service or controller
      state/       # provider + state class
      ui/          # screens/, widgets/
```

Full scaffold with every file, plus the matching `test/` layout, is in
`references/folder-structure.md`.

## Default implementation order

1. Constants/managers the feature needs (or confirm they already exist)
2. Model(s)
3. Repository
4. Service/Controller
5. State class
6. Provider
7. Reusable widgets
8. Screen UI
9. Route registration
10. Tests or a testing checklist
11. Self-review (see `references/testing-and-checklists.md`)

## Non-negotiables worth remembering without a reference lookup

- **No hardcoded values** — colors, asset paths, fonts, route names, API
  paths, storage keys, and repeated strings all go through a centralized
  manager or constants file. This isn't style pedantry — it's what makes a
  rebrand or endpoint change a one-file diff instead of a grep-and-pray.
- **200 lines per Dart file, strictly.** Plan the split once a file hits
  ~180 lines. Split screens into screen+widgets, large providers into
  state+provider, large services into smaller domain services.
- **Empty vs. error are different states.** `null`, `[]`, `""`, and missing
  keys are empty data, not errors — handle them in the Repository and never
  show error UI for them.
- **Every screen handles**: loading (shimmer, never a blank screen), empty,
  error, offline, retry, and success. Details in
  `references/ui-state-patterns.md`.
- **Minimize rebuilds** — prefer `context.select()` or `Selector` over
  `context.watch()` on an entire provider; use `ListView.builder` for any
  dynamic list; dispose every controller.
- **No junk left behind** — dead code, unused imports, stray `print()`
  (use `if (kDebugMode) debugPrint(...)` instead), and commented-out old code
  all get removed before delivery.

## Delivering the result

For anything beyond a trivial change, deliver in this order so the person can
review incrementally rather than getting a wall of code:

1. Assumptions made
2. Folder structure (only the new/changed parts)
3. New dependencies needed, if any, with a one-line reason each
4. Core files (constants/managers/models), then feature files, by layer
5. State-flow explanation (what triggers what)
6. How error/empty/loading/offline/retry are handled
7. Performance notes if anything non-obvious was done
8. Testing checklist
9. Risks or open questions

For large features, split the response by layer rather than dumping
everything at once — see `references/templates.md` for the full delivery
template and the hard-stop conditions where you should pause and ask instead
of guessing.
