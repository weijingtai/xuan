import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'package:common/module.dart';
import 'world_info_daos/city_dao.dart';
import 'world_info_daos/country_dao.dart';
import 'world_info_daos/region_dao.dart';
import 'world_info_daos/state_dao.dart';
import 'world_info_daos/subregion_dao.dart';

part 'world_info_database.g.dart';

@DataClassName('RegionDataModel')
class Regions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 100)();
  TextColumn get translations => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get flag => integer().withDefault(const Constant(1))();
  TextColumn get wikiDataId => text().nullable()();
}

@DataClassName('SubregionDataModel')
class Subregions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 100)();
  TextColumn get translations => text().nullable()();
  IntColumn get regionId => integer().references(Regions, #id,
      onUpdate: KeyAction.noAction, onDelete: KeyAction.noAction)();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get flag => integer().withDefault(const Constant(1))();
  TextColumn get wikiDataId => text().nullable()();
}

@DataClassName('CountryDataModel')
class Countries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 100)();
  TextColumn get iso3 => text().withLength(max: 3).nullable()();
  TextColumn get numericCode => text().withLength(max: 3).nullable()();
  TextColumn get iso2 => text().withLength(max: 2).nullable()();
  TextColumn get phonecode => text().nullable()();
  TextColumn get capital => text().nullable()();
  TextColumn get currency => text().nullable()();
  TextColumn get currencyName => text().nullable()();
  TextColumn get currencySymbol => text().nullable()();
  TextColumn get tld => text().nullable()();
  TextColumn get native => text().nullable()();
  TextColumn get region => text().nullable()();
  IntColumn get regionId => integer().nullable().references(Regions, #id,
      onUpdate: KeyAction.noAction, onDelete: KeyAction.noAction)();
  TextColumn get subregion => text().nullable()();
  IntColumn get subregionId => integer().nullable().references(Subregions, #id,
      onUpdate: KeyAction.noAction, onDelete: KeyAction.noAction)();
  TextColumn get nationality => text().nullable()();
  TextColumn get timezones => text().nullable()();
  TextColumn get translations => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get emoji => text().withLength(max: 191).nullable()();
  TextColumn get emojiU => text().withLength(max: 191).nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get flag => integer().withDefault(const Constant(1))();
  TextColumn get wikiDataId => text().nullable()();
}

@DataClassName('StateDataModel')
class States extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 255)();
  IntColumn get countryId => integer().references(Countries, #id,
      onUpdate: KeyAction.noAction, onDelete: KeyAction.noAction)();
  TextColumn get countryCode => text().withLength(max: 2)();
  TextColumn get fipsCode => text().nullable()();
  TextColumn get iso2 => text().nullable()();
  TextColumn get type => text().withLength(max: 191).nullable()();
  IntColumn get level => integer().nullable()();
  IntColumn get parentId => integer().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get flag => integer().withDefault(const Constant(1))();
  TextColumn get wikiDataId => text().nullable()();
}

@DataClassName('CityDataModel')
class Cities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 255)();
  IntColumn get stateId => integer().references(States, #id,
      onUpdate: KeyAction.noAction, onDelete: KeyAction.noAction)();
  TextColumn get stateCode => text().withLength(max: 255)();
  IntColumn get countryId => integer().references(Countries, #id,
      onUpdate: KeyAction.noAction, onDelete: KeyAction.noAction)();
  TextColumn get countryCode => text().withLength(max: 2)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(Constant(DateTime(2014, 1, 1, 12, 1, 1)))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get flag => integer().withDefault(const Constant(1))();
  TextColumn get wikiDataId => text().nullable()();
}

// 定义数据库类
@DriftDatabase(
    tables: [Regions, Subregions, Countries, States, Cities],
    daos: [CityDao, CountryDao, RegionDao, StateDao, SubregionDao])
class WorldInfoDatabase extends _$WorldInfoDatabase {
  // WorldInfoDatabase() : super(_openWorldInfoConnection());
  WorldInfoDatabase([QueryExecutor? e])
      : super(
          e ??
              driftDatabase(
                name: 'world',
                native: const DriftNativeOptions(
                  databaseDirectory: getApplicationSupportDirectory,
                ),
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                  onResult: (result) {
                    if (result.missingFeatures.isNotEmpty) {
                      logger.i(
                        'Using ${result.chosenImplementation} due to unsupported '
                        'browser features: ${result.missingFeatures}',
                      );
                    }
                  },
                ),
              ),
        );

  @override
  int get schemaVersion => 1;
}

// LazyDatabase _openWorldInfoConnection() {
//   return LazyDatabase(() async {
//     if (kIsWeb) {
//       // Web 环境：使用 IndexedDB 持久化
//       return WebDatabase(
//         'world',
//         // migrateFromIndexedDb: true,
//         // inWebWorker: false,
//       );
//     } else {
//       // 移动端/桌面端：原生 SQLite
//       final path = p.join((await getApplicationDocumentsDirectory()).path,
//           'dataset/world.sqlite');
//       return NativeDatabase(File(path));
//     }
//   });
// }
