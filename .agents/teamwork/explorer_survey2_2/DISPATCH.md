# Dispatch: explorer_survey2_2

## Task Objective
You are the **UI & Asset Layout Auditor**. Your mission is to audit all UI screens, widgets, layout structures, and asset references across the Cooking Directory Flutter app to detect rendering defects, overflows, styling inconsistencies, and asset issues.

## Scope & Instructions
1. Read `d:\Ismail_flutter\cooking_directory\.agents\teamwork\ORIGINAL_REQUEST.md`.
2. Inspect every screen and widget under `lib/features/`:
   - `app_shell/`
   - `home/`
   - `recipes/`
   - `expenses/`
   - `cooking_mode/`
   - `cooking_timer/`
   - `profile/`
   - `authentication/`
3. Audit for:
   - RenderFlex overflow risks (unbounded height in scroll views/columns, missing Flexible/Expanded, missing SingleChildScrollView)
   - Layout defects (misaligned cards, squished text, bad padding/margins)
   - Asset references: check all usages of `AssetManager`, `Image.asset`, `SvgPicture.asset`, `Lottie.asset` across the codebase to ensure every single referenced asset exists in `assets/` and is registered in `pubspec.yaml`
   - Check if any asset fails to render or has broken aspect ratio / missing styling
   - Check file length (<200 lines per file discipline)
4. Maintain your heartbeat in `.agents/teamwork/explorer_survey2_2/progress.md`.
5. Write your comprehensive findings to `.agents/teamwork/explorer_survey2_2/handoff.md`.


## 2026-11-10T16:26:59Z
You are the UI & Asset Layout Auditor for the Cooking Directory Flutter app.
Read d:\Ismail_flutter\cooking_directory\.agents\teamwork\ORIGINAL_REQUEST.md.
Task details are in d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_survey2_2\DISPATCH.md.
Audit all UI screens and widgets under lib/features/ (app_shell, home, recipes, expenses, cooking_mode, cooking_timer, profile, authentication).
Check for RenderFlex overflows, sizing defects, misaligned layouts, and asset references (images, SVGs, JSONs). Check file line limits (<200 lines/file).
Working directory: d:\Ismail_flutter\cooking_directory
State folder: d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_survey2_2
Update your progress heartbeat at d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_survey2_2\progress.md.
Deliver your final report at d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_survey2_2\handoff.md and notify me via send_message.


## 2026-11-10T16:38:51Z
**Context**: UI & Asset Layout Audit
**Content**: Checking in on your final report. Explorers 1 and 3 have completed their handoffs.
**Action**: Please deliver your findings in handoff.md and send completion message.
