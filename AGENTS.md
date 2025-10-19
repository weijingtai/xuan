# Repository Guidelines

## Project Structure & Module Organization
- `lib/` holds application code: `main.dart` wires routing, with feature folders such as `pages/`, `widgets/`, `models/`, and shared helpers under `utils/` and `fate/`.
- Domain packages live at the workspace root (`common/`, `qimendunjia/`, `qizhengsiyu/`, `taiyishenshu/`, `daliuren/`) and are pulled via `path` dependencies in `pubspec.yaml`; update those modules before wiring them into `lib/`.
- UI/animation assets and datasets are under `assets/` (icons, lotties, planetary data, SQL, etc.)—register new folders in `pubspec.yaml` to make them loadable.
- Tests sit in `test/`, with widget smoke tests in `widget_test.dart` and focused utilities in `test/utils/`; mirror production paths when adding coverage.

## Build, Test, and Development Commands
- `flutter pub get` – install or refresh all Flutter and local path dependencies.
- `dart run build_runner build --delete-conflicting-outputs` – regenerate Drift tables, JSON adapters, and any annotated sources.
- `flutter run -d chrome` (web) / `flutter run` (mobile) – launch the app for manual verification; prefer Chrome for rapid iteration.
- `flutter test` – execute unit and widget tests; add `--coverage` when you need a lcov report.
- `flutter analyze` – run the analyzer with the lint set defined in `analysis_options.yaml`.

## Coding Style & Naming Conventions
- Follow `flutter_lints`; rely on `dart format .` before committing (2-space indentation, trailing commas on multiline literals).
- Use `UpperCamelCase` for widgets/models, `lowerCamelCase` for members, and `snake_case.dart` for files; align folder names with feature areas (`pages/eight_chars/` etc.).
- Prefer `const` constructors where possible, surface side effects via dedicated services, and keep logging behind the `logger` package for consistency.

## Testing Guidelines
- Place new tests beside their targets (e.g., `lib/utils/date_utils.dart` → `test/utils/date_utils_test.dart`); name files `*_test.dart`.
- Cover deterministic calculations (calendar, fate math) with unit tests and add widget tests for interactive flows such as EightChars cards.
- Use `setUp`/`tearDown` for shared fixtures, and mock IO-heavy services rather than hitting real ephemeris assets.

## Commit & Pull Request Guidelines
- Match the existing history by writing concise, present-tense summaries; prefer Conventional style (`feat(widget): add animated card`) when scoping changes.
- Group related changes per commit, include localized strings/assets together, and avoid committing generated `build/` artifacts.
- PRs should describe the problem, outline the solution, link issues, and attach before/after screenshots or screen recordings for UI-facing work.
- Note any manual test steps (`flutter run -d chrome`, platform toggles) so reviewers can reproduce your validation quickly.
