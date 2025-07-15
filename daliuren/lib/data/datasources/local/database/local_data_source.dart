// lib/data/datasources/local/local_data_source.dart

import 'package:daliuren/data/datasources/local/database/dao/liuren_dao.dart';
import 'package:daliuren/data/datasources/local/database/drift_database.dart'; // For DBOs (e.g. JuMappingEntryDb) and Companions
import 'package:daliuren/data/models/ju_mapping_data_model.dart';
import 'package:daliuren/data/models/yu_ding_da_liu_ren_data_model.dart';
import 'package:daliuren/data/models/da_liu_ren_pan_data_model.dart';
// Note: Other models like DaLiuRenGongDataModel are used by TypeConverters in drift_database.dart,
// but not directly passed to/from LiuRenLocalDataSource methods here.

// Key for storing the database initialization flag.
// Versioning this key (e.g., _v1) can be useful if data reseeding logic changes in the future.
const String _dbInitializedFlagKey = 'isAssetDataLoaded_v1';

/// Abstract interface for the Liu Ren local data source.
/// Defines methods for interacting with locally stored data (via Drift).
abstract class LiuRenLocalDataSource {
  /// Retrieves a Ju Mapping entry from the local database.
  // Future<JuMappingEntryDb?> getJuMapping(
  //     String dayJiaZiName, String timeDiZhiName, String yinYangValue);

  /// Retrieves a Yu Ding Da Liu Ren entry from the local database.
  // Future<YuDingEntryDb?> getYuDingEntry(
  //     String dayJiaZiName, String ganShangJuName);

  /// Retrieves a preset Liu Ren Pan from the local database.
  Future<PresetPanEntryDb?> getPresetPan(
      String dayJiaZiName, String shiChenName, String yinYangDun);

  /// Checks if the database has been initialized with data from assets.
  Future<bool> isDatabaseInitialized();

  /// Marks the database as initialized (e.g., after successfully loading asset data).
  Future<void> markDatabaseAsInitialized();

  /// Performs a bulk insert of initial data into the database.
  /// Takes lists of DataModels (DTOs) which are then converted to Drift Companions for insertion.
  Future<void> bulkInsertInitialData({
    required List<JuMappingDataModel> juMappings,
    required List<YuDingDaLiuRenDataModel> yuDingEntries,
    required List<DaLiuRenPanDataModel>
        presetPans, // Assumes this list contains both Yang and Yin pans, differentiated by a field within DaLiuRenPanDataModel.
  });

  /// Clears all Liu Ren related data from the local database.
  /// Useful for development, testing, or allowing data re-initialization.
  Future<void> clearAllLocalData();
}

/// Concrete implementation of [LiuRenLocalDataSource] using Drift DAO ([LiuRenDao]).
class LiuRenLocalDataSourceImpl implements LiuRenLocalDataSource {
  final LiuRenDao _liuRenDao;

  LiuRenLocalDataSourceImpl({required LiuRenDao liuRenDao})
      : _liuRenDao = liuRenDao;

  @override
  Future<bool> isDatabaseInitialized() async {
    final flag = await _liuRenDao.getInitializationFlag(_dbInitializedFlagKey);
    return flag?.isSet ??
        false; // If flag doesn't exist or isSet is null, assume not initialized.
  }

  @override
  Future<void> markDatabaseAsInitialized() async {
    await _liuRenDao.setInitializationFlag(_dbInitializedFlagKey, true);
  }

  @override
  Future<void> bulkInsertInitialData({
    required List<JuMappingDataModel> juMappings,
    required List<YuDingDaLiuRenDataModel> yuDingEntries,
    required List<DaLiuRenPanDataModel> presetPans,
  }) async {
    // Convert JuMappingDataModel list to List<JuMappingsCompanion> for Drift batch insert.
    final juMappingCompanions = juMappings.map((model) {
      return JuMappingsCompanion.insert(
        dayJiaZiName: model.dayJiaZiName,
        timeDiZhiName: model.timeDiZhiName,
        yinYangValue: model.yinYangValue, // Expects "yang" or "yin"
        juNumber: model.juNumber,
      );
    }).toList();
    if (juMappingCompanions.isNotEmpty) {
      await _liuRenDao.bulkInsertJuMappings(juMappingCompanions);
    }

    // Convert YuDingDaLiuRenDataModel list to List<YuDingEntriesCompanion>.
    final yuDingCompanions = yuDingEntries.map((model) {
      return YuDingEntriesCompanion.insert(
        dayJiaZiName: model.dayJiaZi
            .name, // Assumes enum has a .name property for string storage
        juName: model.juName.name, // Assumes enum has a .name property
        juNumber: model.juNumber,
        detailsJson: model
            .details, // TypeConverter handles Map<String,String> to JSON String
        booksJson: model
            .books, // TypeConverter handles Map<String,String> to JSON String
        bodyJson:
            model.body, // TypeConverter handles Set<String> to JSON String
        meaning: model.meaning,
        explain: model.explain,
        predication: model.predication,
      );
    }).toList();
    if (yuDingCompanions.isNotEmpty) {
      await _liuRenDao.bulkInsertYuDingEntries(yuDingCompanions);
    }

    // Convert DaLiuRenPanDataModel list to List<PresetPansCompanion>.
    final presetPanCompanions = presetPans.map((model) {
      // The `DaLiuRenPanDataModel` now includes `yinYangDun` field.
      // This field is crucial for the primary key of the PresetPans table.
      // The `InitializeDatabaseUseCase` is responsible for populating this `yinYangDun`
      // in each `DaLiuRenPanDataModel` instance based on the source JSON file (yang/yin).
      return PresetPansCompanion.insert(
        dayJiaZiName: model.dayJiaZi.name,
        shiChenName: model.shiChen.name,
        yinYangDun: model.yinYangDun.name, // Uses the name of the YinYang enum
        juNumberName: model.juNumberName,
        // heavenPlateJson: model.heavenPlate, // TypeConverter handles complex Map
        // earthPlateJson: model.earthPlate, // TypeConverter handles complex Map
        fourClassJson:
            model.fourClass, // TypeConverter handles FourClassDataModel
        threeChuanJson:
            model.threeChuan, // TypeConverter handles ThreeChuanDataModel
        nineZongMenName:
            model.nineZongMenName.name, // Uses the name of the NineZongMen enum
      );
    }).toList();
    if (presetPanCompanions.isNotEmpty) {
      await _liuRenDao.bulkInsertPresetPans(presetPanCompanions);
    }
    print("LocalDataSource: Bulk data insertion complete.");
  }

  @override
  Future<JuMappingEntryDb?> getJuMapping(
      String dayJiaZiName, String timeDiZhiName, String yinYangValue) {
    return _liuRenDao.findJuMapping(
      dayJiaZiName: dayJiaZiName,
      timeDiZhiName: timeDiZhiName,
      yinYangValue: yinYangValue,
    );
  }

  @override
  Future<YuDingEntryDb?> getYuDingEntry(
      String dayJiaZiName, String ganShangJuName) {
    return _liuRenDao.findYuDingEntry(
      dayJiaZiName: dayJiaZiName,
      juName: ganShangJuName,
    );
  }

  @override
  Future<PresetPanEntryDb?> getPresetPan(
      String dayJiaZiName, String shiChenName, String yinYangDun) {
    return _liuRenDao.findPresetPan(
      dayJiaZiName: dayJiaZiName,
      shiChenName: shiChenName,
      yinYangDun: yinYangDun,
    );
  }

  @override
  Future<void> clearAllLocalData() async {
    await _liuRenDao.clearAllData();
    // Ensure the initialization flag is also cleared to allow re-initialization.
    await _liuRenDao.setInitializationFlag(_dbInitializedFlagKey, false);
    print("LocalDataSource: All local data cleared.");
  }
}
