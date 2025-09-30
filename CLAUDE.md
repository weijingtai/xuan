# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application called "xuan" (玄学), focused on Chinese metaphysics and divination systems. The app contains multiple divination modules implemented as separate Flutter packages:

- **qimendunjia** (奇门遁甲) - Qimen Dunjia divination
- **qizhengsiyu** (七政四余) - Seven Luminaries Four Residues astrology
- **taiyishenshu** (太乙神数) - Taiyi Sacred Numbers
- **daliuren** (大六壬) - Da Liu Ren divination
- **common** - Shared utilities, models, and UI components

## Architecture

The app follows a modular architecture with:

- **Main App** (`lib/main.dart`): Entry point with multi-provider setup including databases, repositories, and view models
- **Module Structure**: Each divination system is a separate Flutter package with its own models, views, and business logic
- **Shared Components**: The `common` package contains shared database models, UI widgets, astronomical calculations, and location services
- **Database**: Uses Drift ORM for local data persistence with separate databases for app data and world info
- **State Management**: Provider pattern for state management across the app
- **Navigation**: Custom route generation with support for web URLs

## Common Commands

### Development
```bash
# Install dependencies
flutter pub get

# Run the app (development)
flutter run

# Build for production
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web

# Run tests
flutter test

# Analyze code
flutter analyze

# Generate code (for json_serializable, drift, etc.)
flutter packages pub run build_runner build

# Clean generated files and rebuild
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Code Generation

The project heavily uses code generation for:
- JSON serialization (`json_serializable`)
- Database models and DAOs (`drift`)
- Data classes with `.g.dart` files

Always run `flutter packages pub run build_runner build` after modifying:
- Classes with `@JsonSerializable()` annotations
- Drift database tables or DAOs
- Any files that generate `.g.dart` companions

## Key Dependencies

- **Flutter SDK**: 3.0.2+
- **lunar**: Chinese calendar calculations
- **sweph**: Swiss Ephemeris for astronomical calculations
- **drift**: Database ORM and query builder
- **provider**: State management
- **lottie**: Animations
- **responsive_framework**: Responsive design
- **json_serializable**: JSON serialization code generation

## Project Structure

- `/lib/`: Main app source code
- `/common/`: Shared module for all divination systems
- `/qimendunjia/`, `/qizhengsiyu/`, `/taiyishenshu/`, `/daliuren/`: Individual divination modules
- `/assets/`: Static assets including JSON data files, images, and astronomical data
- `/build/`: Generated build artifacts (ignored in git)

## Development Notes

- The app supports multiple platforms: Android, iOS, and Web
- Uses Chinese lunar calendar and astronomical calculations for divination
- Contains extensive JSON datasets for geographical data, astronomical ephemeris, and divination rules
- Main entry route is configurable in `main.dart` (currently set to `/qizhengsiyu/panel`)
- Database initialization and seeding happens on app startup
- Location services and timezone handling are built-in for astronomical calculations

## Working with Modules

Each divination module (`qimendunjia`, `qizhengsiyu`, etc.) is a separate Flutter package. To work on a specific module:

1. Navigate to the module directory
2. Run `flutter pub get` in that directory
3. The module can be developed independently but relies on the `common` package
4. Changes to shared models in `common` may require rebuilding all dependent modules