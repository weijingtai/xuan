# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Module Overview

The `common` module is a shared Flutter package that provides core functionality for the xuan (玄学) divination application. It contains database models, UI widgets, astronomical calculations, location services, and shared utilities used across all divination modules (qimendunjia, qizhengsiyu, taiyishenshu, daliuren).

## Architecture

### Database Layer (Drift ORM)
- **Two separate databases**:
  - `AppDatabase` (`lib/database/app_database.dart`): Core app data including divinations, seekers, panels, skills
  - `WorldInfoDatabase` (`lib/database/world_info_database.dart`): Geographic data (regions, countries, states, cities)
- **DAO Pattern**: Each table has a dedicated DAO in `lib/database/daos/` for query operations
- **Type Converters**: Custom converters in `lib/database/converters/` handle complex types (Location, DivinationDateTime, GanZhi, JieQiInfo, Coordinates)
- **Platform Support**: Separate connection implementations for native (`native.dart`), web (`web.dart`), and unsupported platforms (`unsupported.dart`)

### Data Models
- **Divination Models** (`lib/datamodel/`): Core business objects for divination requests, types, seekers, observers
- **Enums** (`lib/enums/`): Extensive Chinese metaphysics enums (TianGan, DiZhi, FiveXing, JiaZi, TenGods, etc.)
- **JSON Serialization**: Models use `@JsonSerializable()` annotations with `.g.dart` companions

### UI Components (`lib/widgets/`)
- **Eight Characters (BaZi) Widgets**: `eight_chars_card.dart`, `four_zhu_eight_chars_card.dart`, `pillar_card.dart`
- **Input Components**: `city_picker_bottom_sheet.dart`, `divination_datetime_selection_card.dart`, `gan_zhi_picker_alert_dialog.dart`
- **Layout System**: `template_board_view.dart`, `column_reorderable_card.dart` for customizable panel layouts
- **Display Widgets**: `lunar_date_info_card.dart`, `twenty_four_jie_qi_tag.dart`, `yao_widget.dart`

## Common Commands

### Code Generation
```bash
# Regenerate Drift database code and JSON serialization
dart run build_runner build --delete-conflicting-outputs

# Watch mode for development
dart run build_runner watch --delete-conflicting-outputs
```

**Always run after modifying:**
- Drift table definitions in `lib/database/tables/tables.dart`
- DAO classes in `lib/database/daos/`
- Models with `@JsonSerializable()` annotations
- Type converters

### Development
```bash
# Install dependencies (run from common/ directory)
flutter pub get

# Run tests
flutter test

# Analyze code
flutter analyze
```

## Key Dependencies

- **drift** (^2.26.0) + **drift_flutter** (^0.2.4): Database ORM with cross-platform support
- **sweph** (^3.2.1+2.10.3): Swiss Ephemeris for astronomical calculations
- **lunar** (^1.7.3): Chinese lunar calendar
- **provider** (^6.1.4): State management
- **json_serializable** (^6.8.0): JSON serialization code generation
- **flutter_map** (^8.1.1): Map display and geolocation
- **geolocator** (^13.0.3): Location services
- **timezone** (^0.10.0): Timezone handling

## Development Notes

### Database Schema
- Primary keys use UUID strings (not auto-increment) for most tables
- Soft deletes via `deletedAt` column (nullable DateTime)
- Standard audit fields: `createdAt`, `lastUpdatedAt`, `deletedAt`
- Many-to-many relationships via mapper tables (e.g., `SeekerDivinationMappers`, `DivinationPanelMappers`)

### File Organization
```
lib/
├── database/           # Drift database, tables, DAOs, converters
├── datamodel/          # Business data models (JSON serializable)
├── datasource/         # Data sources (local, binary protobuf for geo data)
├── domain/usecases/    # Use cases for business logic
├── enums/              # Chinese metaphysics enumerations
├── models/             # Domain models (DivinationDateTime, etc.)
├── utils/              # Utility functions
└── widgets/            # Reusable UI components
```

### Assets
- Assets are loaded from parent directory: `../assets/dataset/`, `../assets/sql/`
- Geographic data stored as JSON, GeoJSON, and Protocol Buffers
- Fonts: NotoSansSC-Regular for Chinese text support

### Platform-Specific Database Connections
- Native platforms (iOS/Android): Use `drift_flutter` with `getApplicationSupportDirectory`
- Web: Uses WASM SQLite with `sqlite3.wasm` and `drift_worker.js`
- Query executor selection happens in `connection.dart` with platform-specific imports

## Common Patterns

### Creating a New DAO
1. Define table in `lib/database/tables/tables.dart`
2. Create DAO class in `lib/database/daos/` extending `DatabaseAccessor<AppDatabase>`
3. Add table to `@DriftDatabase` tables list in `app_database.dart`
4. Add DAO to `daos` list in `app_database.dart`
5. Run `dart run build_runner build --delete-conflicting-outputs`

### Adding a New Enum
1. Create enum file in `lib/enums/enum_*.dart`
2. Define enum with Chinese and English descriptions as needed
3. Add to `lib/enums.dart` barrel export
4. If used in database, create a text converter or use `textEnum<T>()`

### Creating JSON-Serializable Models
1. Add `@JsonSerializable()` annotation to class
2. Include `part 'filename.g.dart';` directive
3. Define `fromJson` and `toJson` factory methods
4. Run code generation to create `.g.dart` companion
