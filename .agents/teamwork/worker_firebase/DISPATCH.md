# Dispatch: Worker Firebase Project Configuration

**Role**: Firebase Configuration Specialist (`teamwork_worker`)
**Working Directory**: d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_firebase\
**Original Request**: d:\Ismail_flutter\cooking_directory\.agents\teamwork\ORIGINAL_REQUEST.md
**Firebase Survey Report**: d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_survey_3\handoff.md

## Objective
Configure Firebase for the project targeting project `cooking-directory-88438` using `flutterfire configure --project=cooking-directory-88438` to generate `lib/firebase_options.dart` and prepare Firebase initialization in `lib/bootstrap.dart`.

### Steps:
1. Add Firebase packages to `pubspec.yaml`:
   `firebase_core: ^5.1.0`
   `firebase_auth: ^7.0.1`
   `cloud_firestore: ^7.1.0`
   `firebase_storage: ^14.0.1`
   Run `flutter pub get`.
2. Update FlutterFire CLI if needed (`dart pub global activate flutterfire_cli`) to avoid interactive update prompts.
3. Execute flutterfire configure command targeting `cooking-directory-88438`:
   ```bash
   dart pub global run flutterfire_cli:flutterfire configure --project=cooking-directory-88438 --platforms=android,ios,web,windows -y
   ```
4. Verify that `lib/firebase_options.dart` is generated and present.
5. In `android/` (Kotlin DSL):
   - Ensure `android/settings.gradle.kts` includes `id("com.google.gms.google-services") version "4.4.2" apply false` in `plugins { ... }`.
   - Ensure `android/app/build.gradle.kts` includes `id("com.google.gms.google-services")` in `plugins { ... }`.
   - Verify `android/app/google-services.json` exists.
   - Ensure `<uses-permission android:name="android.permission.INTERNET"/>` is present in `android/app/src/main/AndroidManifest.xml`.
6. In `lib/bootstrap.dart`:
   - Import `package:firebase_core/firebase_core.dart` and `package:cooking_directory/firebase_options.dart`.
   - Add `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);` after `WidgetsFlutterBinding.ensureInitialized();`.
7. Verify compilation and static analysis with `flutter analyze` and run `flutter test`.
8. Write comprehensive handoff report to `handoff.md`.


## 2026-11-10T04:37:43Z
From: d8daefed-3899-4cb6-9fcb-0cfefd61f487
Content:
You are Worker: Firebase Configuration Specialist (teamwork_worker).
Your working directory is: d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_firebase\
You MUST read d:\Ismail_flutter\cooking_directory\.agents\teamwork\ORIGINAL_REQUEST.md before starting work.
Also read your assignment in d:\Ismail_flutter\cooking_directory\.agents\teamwork\worker_firebase\DISPATCH.md.
Also review the findings from:
d:\Ismail_flutter\cooking_directory\.agents\teamwork\explorer_survey_3\handoff.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Your write ownership:
- `lib/firebase_options.dart`
- `lib/bootstrap.dart`
- `android/settings.gradle.kts`
- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`
- `pubspec.yaml` (adding firebase packages)

Instructions:
1. Add `firebase_core: ^5.1.0`, `firebase_auth: ^7.0.1`, `cloud_firestore: ^7.1.0`, `firebase_storage: ^14.0.1` to `pubspec.yaml` and run `flutter pub get`.
2. Update flutterfire CLI (`dart pub global activate flutterfire_cli`) to ensure no interactive prompts.
3. Run `flutterfire configure --project=cooking-directory-88438` (or via `dart pub global run flutterfire_cli:flutterfire configure --project=cooking-directory-88438 --platforms=android,ios,web,windows -y`).
4. Ensure `lib/firebase_options.dart` is generated.
5. In Android build files, ensure Google Services plugin is configured in `android/settings.gradle.kts` and `android/app/build.gradle.kts`, and internet permission in `android/app/src/main/AndroidManifest.xml`.
6. Initialize Firebase in `lib/bootstrap.dart` using `DefaultFirebaseOptions.currentPlatform`.
7. Verify all files adhere to `< 200 lines per file`. Run `flutter analyze` and `flutter test`.
8. Write `handoff.md` with verification commands and evidence, and notify parent upon completion.
