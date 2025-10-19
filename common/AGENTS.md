# Repository Guidelines

## Project Structure & Module Organization
- `lib/` contains Flutter entry points (`main.dart` for routing) and feature folders (`pages/`, `widgets/`, `models/`, shared helpers in `utils/` and `fate/`).
- Domain packages sit at the workspace root (`common/`, `qimendunjia/`, `qizhengsiyu/`, `taiyishenshu/`, `daliuren/`) and are referenced via `path` dependencies in `pubspec.yaml`.
- Assets live in `assets/` (icons, lotties, planetary data, SQL dumps). Register new subfolders in `pubspec.yaml` before loading them in code.
- Tests mirror production paths in `test/`, with widget smoke tests in `widget_test.dart` and utility coverage under `test/utils/`.

## Build, Test, and Development Commands
- `flutter pub get` refreshes Flutter and local path dependencies.
- `dart run build_runner build --delete-conflicting-outputs` regenerates Drift tables, JSON adapters, and annotated outputs.
- `flutter run -d chrome` launches the web build for rapid iteration; omit `-d chrome` for device-specific runs.
- `flutter test` executes unit and widget suites; add `--coverage` to emit `lcov.info`.
- `flutter analyze` enforces the lint rules in `analysis_options.yaml`.

## Coding Style & Naming Conventions
- Follow `flutter_lints`; run `dart format .` before committing (2-space indentation, trailing commas on multiline literals).
- Use `UpperCamelCase` for widgets/models, `lowerCamelCase` for members, and `snake_case.dart` filenames aligned with feature areas (e.g., `pages/eight_chars/eight_chars_page.dart`).
- Prefer `const` constructors when possible and route side effects through explicit services; centralized logging should use the `logger` package.

## Testing Guidelines
- Keep test files beside their targets (`lib/utils/date_utils.dart` → `test/utils/date_utils_test.dart`).
- Use deterministic unit tests for calendrical and fate calculations; add widget tests for interactive flows like EightChars cards.
- Share fixtures via `setUp`/`tearDown` and mock IO-heavy services instead of hitting real ephemeris assets.

## Commit & Pull Request Guidelines
- Write concise, present-tense commits following Conventional style (e.g., `feat(widget): add animated card`).
- Group related code, assets, and localization updates into the same commit; exclude generated `build/` artifacts.
- PRs should describe the problem, summarize the solution, link issues, and include before/after screenshots or screen recordings for UI changes.
- Document manual verification steps (e.g., `flutter run -d chrome`, platform toggles) so reviewers can reproduce validation quickly.
