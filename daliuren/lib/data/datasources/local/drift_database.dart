// lib/data/datasources/local/drift_database.dart

// Main Drift database definition file for the DaLiuRen application.
// This file includes:
// 1. Table definitions (e.g., for Ju Mappings, Yu Ding Entries, Preset Pans).
// 2. Custom TypeConverters for storing complex Dart objects as basic SQL types (usually JSON strings).
// 3. The AppDatabase class that extends Drift's GeneratedDatabase.
// 4. DAO registrations.
// 5. Database connection opening logic.

import 'package:drift/drift.dart';
import 'dart:io'; // For File operations
import 'package:drift/native.dart'; // For NativeDatabase (SQLite on mobile/desktop)
import 'package:path_provider/path_provider.dart'; // For finding the app's documents directory
import 'package:path/path.dart' as p; // For path manipulation
import 'dart:convert'; // For jsonEncode/Decode used in TypeConverters

// Import DAOs that will be part of this database.
import 'dao/liuren_dao.dart';

// Import Data Models (DTOs) that are used by TypeConverters to (de)serialize complex JSON structures.
import '../../models/da_liu_ren_gong_data_model.dart';
import '../../models/four_class_data_model.dart';
import '../../models/three_chuan_data_model.dart';
// NOTE: The following imports were added by the previous step for TypeConverter defaults.
// This indicates a tight coupling that might be refactored later, but is functional.
import '../../models/each_class_data_model.dart';
import '../../models/each_chuan_data_model.dart';

// NOTE: The following enum imports are placeholders due to tool limitations.
// In a real project, these would point to 'package:common/enums.dart'
// and 'package:daliuren/domain/enums/*.dart' respectively.
// enum CommonDiZhi { Zi, Chou, Yin, Mao, Chen, Si, Wu, Wei, Shen, You, Xu, Hai } // Placeholder
// enum CommonTianGan { Jia, Yi, Bing, Ding, Wu, Ji, Geng, Xin, Ren, Gui } // Placeholder
// enum GuiRen { UNKNOWN } // Placeholder
// enum NineZongMen { UNKNOWN } // Placeholder
// For actual compilation, these would need to be proper imports:
import 'package:common/enums.dart' as common_enums_actual;
import 'package:daliuren/domain/enums/gui_ren.dart' as domain_gui_ren_actual;
import 'package:daliuren/domain/enums/nine_zong_men.dart' as domain_nine_zong_men_actual;


// Auto-generated part file by Drift. Contains the _$AppDatabase class, table companion classes, etc.
part 'drift_database.g.dart';

// --------- Utility Type Converters for complex objects stored as JSON strings ---------
// These converters allow storing complex Dart objects (like Maps or custom classes)
// as simple strings (usually JSON) in the SQLite database.

/// Converts `Map<String, String>` to and from a JSON String for database storage.
class MapStringStringConverter extends TypeConverter<Map<String, String>, String> {
  const MapStringStringConverter();
  @override
  Map<String, String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return {}; // Handle empty string from DB gracefully.
    return Map<String, String>.from(json.decode(fromDb) as Map);
  }

  @override
  String toSql(Map<String, String> value) {
    return json.encode(value);
  }
}

/// Converts `Set<String>` to and from a JSON String (list) for database storage.
class SetStringConverter extends TypeConverter<Set<String>, String> {
  const SetStringConverter();
  @override
  Set<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return {};
    return (json.decode(fromDb) as List).map((item) => item as String).toSet();
  }

  @override
  String toSql(Set<String> value) {
    return json.encode(value.toList());
  }
}

/// Converts `Map<String, DaLiuRenGongDataModel>` (Heaven/Earth Plate structure)
/// to and from a JSON String for database storage.
class HeavenPlateConverter extends TypeConverter<Map<String, DaLiuRenGongDataModel>, String> {
  const HeavenPlateConverter();
  @override
  Map<String, DaLiuRenGongDataModel> fromSql(String fromDb) {
    if (fromDb.isEmpty) return {};
    final Map<String, dynamic> decoded = json.decode(fromDb) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, DaLiuRenGongDataModel.fromJson(value as Map<String, dynamic>)));
  }

  @override
  String toSql(Map<String, DaLiuRenGongDataModel> value) {
    // Serializes each DaLiuRenGongDataModel in the map to its JSON representation.
    return json.encode(value.map((key, gong) => MapEntry(key, gong.toJson())));
  }
}

/// EarthPlateConverter is structurally identical to HeavenPlateConverter.
class EarthPlateConverter extends HeavenPlateConverter {
  const EarthPlateConverter();
}

/// Converts `FourClassDataModel` to and from a JSON String for database storage.
class FourClassConverter extends TypeConverter<FourClassDataModel, String> {
  const FourClassConverter();
  @override
  FourClassDataModel fromSql(String fromDb) {
    if (fromDb.isEmpty) {
      // Provides a default FourClassDataModel if the DB string is empty.
      // This prevents errors if data is unexpectedly missing.
      // Uses actual imported enums for defaults.
      final defaultEachClass = EachClassDataModel(
          order: 0,
          sky: common_enums_actual.DiZhi.Zi,
          ground: common_enums_actual.DiZhi.Zi,
          guiRen: domain_gui_ren_actual.GuiRen.UNKNOWN,
          isFirstClass: true);
      return FourClassDataModel(
          first: defaultEachClass,
          firstClassDayGan: common_enums_actual.TianGan.Jia,
          second: defaultEachClass.copyWith(order: 1, isFirstClass: false),
          third: defaultEachClass.copyWith(order: 2, isFirstClass: false),
          fourth: defaultEachClass.copyWith(order: 3, isFirstClass: false)
        );
    }
    return FourClassDataModel.fromJson(json.decode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(FourClassDataModel value) {
    return json.encode(value.toJson());
  }
}

/// Converts `ThreeChuanDataModel` to and from a JSON String for database storage.
class ThreeChuanConverter extends TypeConverter<ThreeChuanDataModel, String> {
  const ThreeChuanConverter();
  @override
  ThreeChuanDataModel fromSql(String fromDb) {
     if (fromDb.isEmpty) {
        // Provides a default ThreeChuanDataModel.
        final defaultEachChuan = EachChuanDataModel(
            diZhi: common_enums_actual.DiZhi.Zi,
            guiRen: domain_gui_ren_actual.GuiRen.UNKNOWN,
            liuQin: common_enums_actual.LiuQin.FuMu); // Assuming FuMu as a general default
        return ThreeChuanDataModel(
            first: defaultEachChuan,
            second: defaultEachChuan,
            third: defaultEachChuan,
            nineZongMen: domain_nine_zong_men_actual.NineZongMen.UNKNOWN
        );
     }
    return ThreeChuanDataModel.fromJson(json.decode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(ThreeChuanDataModel value) {
    return json.encode(value.toJson());
  }
}


// --------- Table Definitions ---------
// Each class extending `Table` defines a table in the SQLite database.
// `@DataClassName` specifies the name of the generated data class for query results.

/// Table for storing Ju Mappings (局数映射).
/// Maps Day GanZhi, Time DiZhi, and YinYang Dun to a Ju Number.
@DataClassName('JuMappingEntryDb')
class JuMappings extends Table {
  TextColumn get dayJiaZiName => text()();
  TextColumn get timeDiZhiName => text()();
  TextColumn get yinYangValue => text()(); // Stores "yang" or "yin"
  IntColumn get juNumber => integer()();

  @override
  Set<Column> get primaryKey => {dayJiaZiName, timeDiZhiName, yinYangValue};
}

/// Table for storing entries from "御定大六壬" (Yu Ding Da Liu Ren).
@DataClassName('YuDingEntryDb')
class YuDingEntries extends Table {
  TextColumn get dayJiaZiName => text()();
  TextColumn get juName => text()(); // Represents 干上神 (DiZhi on Day Gan)
  IntColumn get juNumber => integer()(); // The Ju number for this entry

  // Complex fields stored as JSON strings using TypeConverters.
  TextColumn get detailsJson => text().map(const MapStringStringConverter())(); // Map<String, String>
  TextColumn get booksJson => text().map(const MapStringStringConverter())();   // Map<String, String>
  TextColumn get bodyJson => text().map(const SetStringConverter())();      // Set<String>

  TextColumn get meaning => text()();     // 课义
  TextColumn get explain => text()();     // 解曰
  TextColumn get predication => text()(); // 断曰

  @override
  Set<Column> get primaryKey => {dayJiaZiName, juName}; // Assumed primary key based on lookup logic
}

/// Table for storing pre-calculated/preset Liu Ren Pans (e.g., from 甲午庚牛羊 JSONs).
@DataClassName('PresetPanEntryDb')
class PresetPans extends Table {
  TextColumn get dayJiaZiName => text()();
  TextColumn get shiChenName => text()(); // DiZhi name of the ShiChen
  TextColumn get yinYangDun => text()(); // "yang" or "yin"

  TextColumn get juNumberName => text()(); // e.g., "一局"

  // Complex pan structures stored as JSON strings.
  TextColumn get heavenPlateJson => text().map(const HeavenPlateConverter())();
  TextColumn get earthPlateJson => text().map(const EarthPlateConverter())();
  TextColumn get fourClassJson => text().map(const FourClassConverter())();
  TextColumn get threeChuanJson => text().map(const ThreeChuanConverter())();

  TextColumn get nineZongMenName => text()(); // Name of the NineZongMen KeTi

  @override
  Set<Column> get primaryKey => {dayJiaZiName, shiChenName, yinYangDun};
}

/// Table for storing flags, e.g., whether initial asset data has been loaded.
@DataClassName('DbInitializationFlag')
class DbInitializationFlags extends Table {
  /// The key for the flag, e.g., "isAssetDataLoaded_v1". Using version in key allows for future data reseeding.
  TextColumn get flagKey => text().clientDefault(() => 'isAssetDataLoaded_v1')();
  /// Boolean value of the flag.
  BoolColumn get isSet => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {flagKey};
}


// --------- Database Class Definition ---------
/// The main database class for the application, built with Drift.
/// It lists all tables and DAOs that are part of this database.
@DriftDatabase(
  tables: [
    JuMappings,
    YuDingEntries,
    PresetPans,
    DbInitializationFlags,
  ],
  daos: [
    LiuRenDao, // DAO for Liu Ren specific operations
  ]
)
class AppDatabase extends _$AppDatabase {
  /// Default constructor. Opens the database connection.
  AppDatabase() : super(_openConnection());

  /// Constructor for testing purposes, allowing a custom [connection].
  AppDatabase.forTesting(DatabaseConnection connection) : super(connection);

  @override
  int get schemaVersion => 1; // Increment this when table structures change.

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      // Creates all tables when the database is first created.
      await m.createAll();
      // It's good practice to also insert the initial state of any flags if needed.
      // For example, ensuring the 'isAssetDataLoaded_v1' flag exists and is false.
      // However, clientDefault and withDefault on the table column should handle this.
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Handles database schema upgrades.
      // Example:
      // if (from < 2) { // If upgrading from version 1 to 2
      //   await m.addColumn(juMappings, juMappings.someNewColumn);
      // }
      // Remember to update schemaVersion after adding migration logic.
    },
  );
}

/// Opens the database connection.
/// Uses [LazyDatabase] to open the connection on first use, potentially in a background isolate.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'daliuren_db.sqlite'));
    // For debugging: print("Database file path: ${file.path}");
    return NativeDatabase.createInBackground(file);
  });
}

// Helper extension for EachClassDataModel to make copyWith available for defaults.
// This is used by TypeConverters to create default instances if JSON data is empty from DB.
// This was defined in the previous version of the file due to tool limitations.
// It's generally better if DataModels have their own copyWith if needed,
// or if TypeConverters handle null/empty inputs without needing full default objects.
// For robustness, ensuring TypeConverters can handle empty/null strings from DB and return
// a valid (even if "empty" or "default") DataModel is important.
extension on EachClassDataModel {
  EachClassDataModel copyWith({
    int? order,
    common_enums_actual.DiZhi? sky,
    common_enums_actual.DiZhi? ground,
    domain_gui_ren_actual.GuiRen? guiRen,
    bool? isFirstClass,
    bool? isSkyKeDayGan,
    bool? isSkySameYinYangWithDayGan,
    int? sheHaiTimes,
    List<int>? otherSameSkyGroundIndexList,
  }) {
    return EachClassDataModel(
      order: order ?? this.order,
      sky: sky ?? this.sky,
      ground: ground ?? this.ground,
      guiRen: guiRen ?? this.guiRen,
      isFirstClass: isFirstClass ?? this.isFirstClass,
      isSkyKeDayGan: isSkyKeDayGan ?? this.isSkyKeDayGan,
      isSkySameYinYangWithDayGan: isSkySameYinYangWithDayGan ?? this.isSkySameYinYangWithDayGan,
      sheHaiTimes: sheHaiTimes ?? this.sheHaiTimes,
      otherSameSkyGroundIndexList: otherSameSkyGroundIndexList ?? this.otherSameSkyGroundIndexList,
    );
  }
}

// Removed the HACK placeholder enums as proper imports are now used at the top.
// enum CommonDiZhi { Zi, Chou, Yin, Mao, Chen, Si, Wu, Wei, Shen, You, Xu, Hai }
// enum CommonTianGan { Jia, Yi, Bing, Ding, Wu, Ji, Geng, Xin, Ren, Gui }
// enum GuiRen { UNKNOWN }
// enum NineZongMen { UNKNOWN }
