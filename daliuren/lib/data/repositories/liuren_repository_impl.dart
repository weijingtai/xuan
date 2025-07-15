// lib/data/repositories/liuren_repository_impl.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:common/module.dart';
import 'package:fpdart/fpdart.dart' hide Failure; // For Either type
import 'package:daliuren/core/errors/failures.dart'; // For Failure types
import 'package:daliuren/domain/repositories/liuren_repository.dart'; // Abstract repository
import 'package:daliuren/domain/entities/liu_ren_pan_model.dart'; // Domain entity
import 'package:daliuren/domain/entities/pan_input.dart'; // Domain entity / Input object
import 'package:daliuren/data/datasources/local/database/local_data_source.dart'; // Local data source interface
// import 'package:daliuren/data/datasources/remote/remote_data_source.dart'; // Placeholder for remote data source
import 'package:daliuren/data/datasources/local/database/drift_database.dart'; // For DBOs (Database Objects like JuMappingEntryDb)
import 'package:daliuren/data/models/ju_mapping_data_model.dart'; // DTO for Ju Mappings
import 'package:daliuren/data/models/yu_ding_da_liu_ren_data_model.dart'; // DTO for Yu Ding Entries
// Domain entities that are composed within LiuRenPan, used by mappers
import 'package:daliuren/domain/entities/liuren_gong_entity.dart';
import 'package:daliuren/domain/entities/four_class_ke_entity.dart';
import 'package:daliuren/domain/entities/three_chuan_entity.dart';
import 'package:daliuren/data/models/da_liu_ren_pan_data_model.dart'; // DTO for preset pans (source for mapping)
import 'package:daliuren/data/models/da_liu_ren_gong_data_model.dart'; // DTO for Gong (part of DaLiuRenPanDataModel)
import 'package:daliuren/data/models/four_class_data_model.dart'; // DTO for FourClass (part of DaLiuRenPanDataModel)
import 'package:daliuren/data/models/three_chuan_data_model.dart'; // DTO for ThreeChuan (part of DaLiuRenPanDataModel)
import 'package:daliuren/data/models/each_class_data_model.dart'; // DTO for EachClass (part of FourClassDataModel)
import 'package:daliuren/data/models/each_chuan_data_model.dart'; // DTO for EachChuan (part of ThreeChuanDataModel)

// Common enums and constants used for mapping and data transformation
import 'package:common/enums.dart' as common_enums;
import 'package:daliuren/domain/enums/gui_ren.dart' as domain_gui_ren;
import 'package:daliuren/domain/enums/nine_zong_men.dart'
    as domain_nine_zong_men;

/// Concrete implementation of the [LiuRenRepository].
/// This class is responsible for orchestrating data operations between the
/// local data source (Drift database) and potentially a remote data source.
/// It handles data transformation (mapping DTOs/DBOs to Domain Entities)
/// and contains placeholders for core business logic like Liu Ren pan calculation.
class LiuRenRepositoryImpl implements LiuRenRepository {
  final LiuRenLocalDataSource _localDataSource;
  // final LiuRenRemoteDataSource _remoteDataSource; // Example for future remote integration
  // final NetworkInfo _networkInfo; // Example for checking network status

  LiuRenRepositoryImpl({
    required LiuRenLocalDataSource localDataSource,
    // required LiuRenRemoteDataSource remoteDataSource, // Uncomment if using remote
    // required NetworkInfo networkInfo, // Uncomment if using network info
  }) : _localDataSource = localDataSource;
  // _remoteDataSource = remoteDataSource,
  // _networkInfo = networkInfo;

  /// Initializes the database with data from assets if not already done.
  /// Transforms raw JSON data from [initialRawData] into specific DataModels
  /// before passing them to the local data source for insertion.

  @override
  Future<Either<Failure, void>> initializeDatabase(
      Map<String, List<Map<String, dynamic>>> initialRawData) async {
    try {
      bool isInitialized = await _localDataSource.isDatabaseInitialized();

      if (!isInitialized) {
        if (kIsWeb) {
          // Web 环境：每次都重新初始化内存数据库
          print("Web environment: Initializing in-memory database");
        } else {
          print("Native environment: Initializing file database");
        }

        // Transform raw JSON data (List<Map<String, dynamic>>) into typed DataModel lists.
        final List<JuMappingDataModel> juMappings =
            (initialRawData['ju_mapper'] ?? [])
                .map((json) => JuMappingDataModel.fromJson(json))
                .toList();

        final List<YuDingDaLiuRenDataModel> yuDingEntries =
            (initialRawData['yuding_daliuren'] ?? [])
                .map((json) => YuDingDaLiuRenDataModel.fromJson(json))
                .toList();

        // For PresetPans, inject 'yinYangDun' based on the source file identifier (map key).
        // This is crucial as DaLiuRenPanDataModel now expects this field.
        final List<DaLiuRenPanDataModel> presetPans = [];
        (initialRawData['甲午庚牛羊_阳'] ?? []).forEach((json) {
          final Map<String, dynamic> mutableJson =
              Map<String, dynamic>.from(json);
          mutableJson['yinYangDun'] =
              common_enums.YinYang.YANG.name; // Store as string name of enum
          presetPans.add(DaLiuRenPanDataModel.fromJson(mutableJson));
        });
        (initialRawData['甲午庚牛羊_阴'] ?? []).forEach((json) {
          final Map<String, dynamic> mutableJson =
              Map<String, dynamic>.from(json);
          mutableJson['yinYangDun'] =
              common_enums.YinYang.YIN.name; // Store as string name of enum
          presetPans.add(DaLiuRenPanDataModel.fromJson(mutableJson));
        });

        // Call local data source to perform bulk insertion.
        await _localDataSource.bulkInsertInitialData(
          juMappings: juMappings,
          yuDingEntries: yuDingEntries,
          presetPans: presetPans,
        );
        await _localDataSource.markDatabaseAsInitialized();
        print("Repository: Database initialized successfully.");
        return const Right(null);
      } else {
        print("Repository: Database already initialized.");
        return const Right(null);
      }
    } catch (e, s) {
      print("Repository: Database initialization failed: $e \n$s");
      // 将 StackTrace 转换为字符串，避免 Web 环境的问题
      return Left(
          DatabaseFailure("Database initialization failed: ${e.toString()}"));
    }
  }

  /// Retrieves or calculates a Liu Ren Pan.
  /// If input is GanZhi-based and matches a preset pan, it's fetched and mapped.
  /// If input is Time-based, or a preset GanZhi pan is not found, it currently
  /// returns a placeholder. The actual calculation logic is a TODO.
  @override
  Future<Either<Failure, LiuRenPanModel>> getLiuRenPan(
      DivinationInfoModel input) async {
    return Future.value(Failure.notImplemented());
    // try {
    //   // Handle GanZhi input for preset pans
    //   if (input.inputType == PanInputType.GANZHI_INPUT &&
    //       input.dayJiaZi != null &&
    //       input.timeJiaZi !=
    //           null && // timeJiaZi is used to derive ShiChen DiZhi
    //       input.yinYangDun != null) {
    //     // Extract DiZhi from timeJiaZi string (e.g., "甲子" -> "子")
    //     // This assumes timeJiaZi is a valid JiaZi string.
    //     // PanInput already asserts that dayJiaZi is not null.
    //     String timeDiZhiName = input.timeJiaZi!.substring(1);

    //     final presetPanDbo = await _localDataSource.getPresetPan(
    //         input.dayJiaZi!, timeDiZhiName, input.yinYangDun!);

    //     if (presetPanDbo != null) {
    //       return Right(_mapPresetPanDboToEntity(presetPanDbo));
    //     } else {
    //       print(
    //           "Preset pan not found for Day: ${input.dayJiaZi}, Time Branch: $timeDiZhiName, Dun: ${input.yinYangDun}. Calculation would be needed.");
    //       // TODO: Implement fallback to LiuRenCalculationService if preset not found for GANZH_INPUT,
    //       // or if input.juNumber is provided, indicating a different type of GanZhi lookup/calculation.
    //       // For now, this path will lead to the GenericFailure at the end of the try block.
    //     }
    //   }

    //   // Handle Time-based input (currently a placeholder for full calculation)
    //   if (input.inputType == PanInputType.TIME_INPUT) {
    //     print(
    //         "Calculating LiuRenPan for time: ${input.dateTime} (Placeholder - Calculation Not Implemented)");
    //     // TODO: CRITICAL - Implement actual LiuRen calculation logic.
    //     // This should ideally involve calling a dedicated LiuRenCalculationService.
    //     // Example of how it might look:
    //     // final calculationService = LiuRenCalculationServiceImpl(); // Or get from DI via constructor
    //     // final pan = await calculationService.calculatePanFromTime(input.dateTime!);
    //     // return Right(pan);

    //     await Future.delayed(
    //         const Duration(milliseconds: 100)); // Simulate async work
    //     // Return a dummy pan for now
    //     return Right(LiuRenPan(
    //       panDateTime: input.dateTime ?? DateTime.now(),
    //       dayJiaZiName: "甲子 (Calc)",
    //       dayGanZhi: "甲子",
    //       timeGanZhi: "甲子",
    //       shiChenZhiName: "子",
    //       yueJiangName: "登明 (Calc)",
    //       guiRenType: "阳贵 (Calc)",
    //       // heavenPlate: {},
    //       // earthPlate: {},
    //       fourClasses: [],
    //       threeChuans: [],
    //       nineZongMen: domain_nine_zong_men.NineZongMen.UNKNOWN,
    //       keTiComplement: ["计算课 (Placeholder)"],
    //       sourceDescription: "Calculated from Time (Placeholder)",
    //     ));
    //   }

    //   // If no specific path handled or calculation not implemented.
    //   return Left(GenericFailure(
    //       "LiuRenPan processing for the given input is not fully implemented or no data found."));
    // } catch (e, s) {
    //   print("Repository: Failed to get LiuRenPan: $e \n$s");
    //   return Left(GenericFailure(
    //       "Failed to process LiuRenPan request: ${e.toString()}", s));
    // }
  }

  /// Fetches a Yu Ding interpretation entry from the local data source and maps it to a domain entity.
  // @override
  // Future<Either<Failure, YuDingEntry>> getYuDingEntry(
  //     String dayJiaZiName, String ganShangDiZhiName) async {
  //   try {
  //     final entryDbo = await _localDataSource.getYuDingEntry(
  //         dayJiaZiName, ganShangDiZhiName);
  //     if (entryDbo != null) {
  //       return Right(_mapYuDingDboToEntity(entryDbo));
  //     } else {
  //       // Return a specific failure type if entry is not found.
  //       return Left(NotFoundFailure(
  //           "YuDing entry not found for $dayJiaZiName, $ganShangDiZhiName"));
  //     }
  //   } catch (e, s) {
  //     print("Repository: Failed to get YuDingEntry: $e \n$s");
  //     return Left(
  //         DatabaseFailure("Failed to get YuDingEntry: ${e.toString()}", s));
  //   }
  // }

  // --- Mapper Functions ---
  // These private helper methods convert Data Layer Objects (DBOs from Drift, which are
  // based on DataModels/DTOs after TypeConversion) into Domain Layer Entities.
  // This is a core responsibility of the Repository to decouple layers.

  /// Maps a [PresetPanEntryDb] (database object for preset pans) to a [LiuRenPanModel] domain entity.
  LiuRenPanModel _mapPresetPanDboToEntity(PresetPanEntryDb dbo) {
    // Helper to map nested DaLiuRenGongDataModel (from JSON in DBO) to LiuRenGongEntity
    Map<String, LiuRenGongEntity> mapHeavenPlate(
        Map<String, DaLiuRenGongDataModel> plateDataModel) {
      return plateDataModel
          .map((key, value) => MapEntry(key, _mapGongDataModelToEntity(value)));
    }

    Map<String, LiuRenGongEntity> mapEarthPlate(
        Map<String, DaLiuRenGongDataModel> plateDataModel) {
      return plateDataModel
          .map((key, value) => MapEntry(key, _mapGongDataModelToEntity(value)));
    }

    // Helper to map nested FourClassDataModel to List<FourClassKeEntity>
    List<FourClassKeEntity> mapFourClass(FourClassDataModel fcModel) {
      return [
        _mapEachClassDataModelToKeEntity(
            fcModel.first, fcModel.firstClassDayGan),
        _mapEachClassDataModelToKeEntity(fcModel.second),
        _mapEachClassDataModelToKeEntity(fcModel.third),
        _mapEachClassDataModelToKeEntity(fcModel.fourth),
      ];
    }

    // Helper to map nested ThreeChuanDataModel to List<ThreeChuanChuanEntity>
    List<ThreeChuanEntity> mapThreeChuan(ThreeChuanDataModel tcModel) {
      return [
        _mapEachChuanDataModelToChuanEntity(tcModel.first),
        _mapEachChuanDataModelToChuanEntity(tcModel.second),
        _mapEachChuanDataModelToChuanEntity(tcModel.third),
      ];
    }

    // Convert string from DBO to NineZongMen enum safely.
    domain_nine_zong_men.NineZongMen nineZongMenEnum = domain_nine_zong_men
        .NineZongMen.values
        .firstWhere((e) => e.name == dbo.nineZongMenName, orElse: () {
      // Log a warning if an unknown NineZongMen name is encountered.
      print(
          "Warning: Unknown NineZongMen name '${dbo.nineZongMenName}' found in DBO. Defaulting to UNKNOWN.");
      return domain_nine_zong_men.NineZongMen.UNKNOWN;
    });

    // Convert string representations of enums from DBO to actual enum types.
    common_enums.JiaZi dayJiaZiEnum =
        common_enums.JiaZi.getFromGanZhiValue(dbo.dayJiaZiName)!;
    common_enums.DiZhi shiChenEnum =
        common_enums.DiZhi.getFromValue(dbo.shiChenName)!;
    common_enums.YinYang yinYangEnum = (dbo.yinYangDun.startsWith("阳")
        ? common_enums.YinYang.YANG
        : common_enums.YinYang.YIN);

    // Convert Chinese number string for Ju (e.g., "一局") to an integer.
    int? juNumber;
    // Find the key (integer) in ConstResourcesMapper.chineseNumberMapper where value matches the juNumberName (after removing "局").

    final juNumKeyEntry = ConstResourcesMapper.chineseNumberMapper.entries
        .firstWhere(
            (entry) => entry.value == dbo.juNumberName.replaceAll("局", ""),
            orElse: () =>
                const MapEntry(-1, "")); // Return a dummy entry if not found

    if (juNumKeyEntry.key != -1) {
      // Check if a valid entry was found
      juNumber = juNumKeyEntry.key;
    }

    return LiuRenPanModel(
      panDateTime:
          null, // Preset pans from JSON typically don't have a specific original cast time.
      dayJiaZi: dbo.dayJiaZiName,
      dayGanZhi:
          dbo.dayJiaZiName, // Assuming dayJiaZiName is the full GanZhi string.
      // Construct time GanZhi: Day's TianGan + ShiChen's DiZhi.
      timeGanZhi: "${dayJiaZiEnum.tianGan.name}${dbo.shiChenName}",
      shiChenZhiName: dbo.shiChenName,
      yueJiangName:
          null, // Preset pans might not explicitly store YueJiang; could be derived if needed.
      guiRenType: dbo.yinYangDun == "yang"
          ? "阳贵"
          : "阴贵", // Simplified mapping for GuiRen type.

      // heavenPlate: mapHeavenPlate(dbo
      // .heavenPlateJson), // DBO field is Map<String, DaLiuRenGongDataModel> due to TypeConverter
      // earthPlate: mapEarthPlate(dbo.earthPlateJson),
      fourClasses: mapFourClass(dbo.fourClassJson!),
      threeChuans: mapThreeChuan(dbo.threeChuanJson!),

      nineZongMen: nineZongMenEnum,
      keTiComplement: [
        dbo.nineZongMenName
      ], // Initially use the raw name as a complement; can be expanded.
      sourceDescription:
          "Loaded from Preset ${dbo.yinYangDun.toUpperCase()} Pan",
      dayJiaZiEnum: dayJiaZiEnum,
      shiChenEnum: shiChenEnum,
      yinYangDunUsed: yinYangEnum,
      juUsed: juNumber,
    );
  }

  /// Maps [DaLiuRenGongDataModel] (DTO) to [LiuRenGongEntity] (Domain Entity).
  LiuRenGongEntity _mapGongDataModelToEntity(DaLiuRenGongDataModel model) {
    return LiuRenGongEntity(
      groundPanDiZhi: model.groundPanDiZhi,
      skyPanDiZhi: model.skyPanDiZhi,
      tianGan: model.tianGan,
      guiRen: model.guiRen,
      jiaZi: model.jiaZi,
    );
  }

  /// Maps [EachClassDataModel] (DTO) to [FourClassKeEntity] (Domain Entity).
  /// Optionally takes the [dayGan] for the first Ke.
  FourClassKeEntity _mapEachClassDataModelToKeEntity(EachClassDataModel model,
      [common_enums.TianGan? dayGan]) {
    return FourClassKeEntity(
      order: model.order,
      sky: model.sky,
      ground: model.ground,
      guiRen: model.guiRen,
      dayGan: model.isFirstClass
          ? dayGan
          : null, // Day Gan is only relevant for the first Ke.
    );
  }

  /// Maps [EachChuanDataModel] (DTO) to [ThreeChuanEntity] (Domain Entity).
  ThreeChuanEntity _mapEachChuanDataModelToChuanEntity(
      EachChuanDataModel model) {
    return ThreeChuanEntity(
      diZhi: model.diZhi,
      tianGan: model.tianGan,
      guiRen: model.guiRen,
      liuQin: model.liuQin,
    );
  }

  @override
  Future<Either<Failure, LiuRenPanModel>> getPan(
      common_enums.YinYang yinYangDun,
      common_enums.JiaZi dayGanZhi,
      common_enums.DiZhi ganShangZhi) {
    // TODO: implement getPan
    throw UnimplementedError();
  }

  /// Maps [YuDingEntryDb] (database object) to a [YuDingEntry] domain entity.
  // YuDingEntry _mapYuDingDboToEntity(YuDingEntryDb dbo) {
  //   // Constructs a user-friendly title for the YuDingEntry.
  //   String title = "${dbo.dayJiaZiName}日 ";
  //   // Safely access the Chinese number string for Ju, defaulting to the number itself if not found.
  //   title +=
  //       "${dbo.chineseNumberMapper[dbo.juNumber] ?? dbo.juNumber.toString()}局 ";
  //   title += "干上${dbo.juName}";

  //   return YuDingEntry(
  //     title: title,
  //     raw: dbo.bodyJson
  //         .toList(), // Set<String> from DBO's TypeConverter converted to List<String>
  //     meaning: dbo.meaning,
  //     explanation: dbo.explain,
  //     perdiction: dbo.predication,
  //     otherDetails:
  //         dbo.detailsJson, // Map<String, String> from DBO's TypeConverter
  //     ancientsBookTextMapper:
  //         dbo.booksJson, // Map<String, String> from DBO's TypeConverter
  //   );
  // }
}

// Custom Failure types specific to this repository or domain, if not already in core/errors.
// These help in providing more specific error information to the upper layers.

/// Failure type indicating that a requested entry or data was not found in the data source.
class NotFoundFailure extends Failure {
  NotFoundFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

// GenericFailure is already defined in core/errors/failures.dart, so no need to redefine here
// unless a repository-specific generic failure is desired.
// class GenericFailure extends Failure {
//   GenericFailure(String message, [StackTrace? stackTrace]) : super(message, stackTrace);
// }
