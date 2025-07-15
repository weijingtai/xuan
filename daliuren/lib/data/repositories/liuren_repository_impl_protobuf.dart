// lib/data/repositories/liuren_repository_impl_protobuf.dart

import 'dart:typed_data';
import 'package:daliuren/domain/entities/raw_pan_info_model.dart';
import 'package:flutter/services.dart';
import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:fpdart/fpdart.dart' hide Failure;
import 'package:daliuren/core/errors/failures.dart';
import 'package:daliuren/domain/repositories/liuren_repository.dart';
import 'package:daliuren/data/datasources/local/protobuf/jia_wu_geng_niu_yang.pb.dart';
import 'package:daliuren/domain/enums/gui_ren.dart' as domain_gui_ren;
import 'package:daliuren/domain/services/calculate_month_general_service.dart';

/// Protobuf-based implementation of the [LiuRenRepository].
/// This class loads and parses data from protobuf asset files instead of using a database.
/// It provides the same interface as the database implementation but with different data source.
class LiuRenRepositoryImplProtobuf implements LiuRenRepository {
  // Cache for loaded protobuf data
  XuanDaLiuRenDataListBundle? _dataBundle;
  bool _isInitialized = false;

  /// Constructor
  LiuRenRepositoryImplProtobuf();

  /// Initializes the repository by loading protobuf data from assets.
  /// This method loads both 阳遁 and 阴遁 data from the protobuf files.
  Future<Either<Failure, void>> _initializeIfNeeded() async {
    if (_isInitialized) {
      return const Right(null);
    }

    try {
      // Load protobuf data from assets
      final ByteData byteData =
          await rootBundle.load('assets/da_liu_ren/jia_wu_geng_niu_yang.pro');
      final Uint8List bytes = byteData.buffer.asUint8List();

      // Parse the protobuf data as XuanDaLiuRenDataListBundle
      _dataBundle = XuanDaLiuRenDataListBundle.fromBuffer(bytes);

      _isInitialized = true;
      print(
          "ProtobufRepository: Data loaded successfully from protobuf assets.");
      return const Right(null);
    } catch (e, s) {
      print("ProtobufRepository: Failed to load protobuf data: $e\n$s");
      return Left(
          DatabaseFailure("Failed to load protobuf data: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, void>> initializeDatabase(
      Map<String, List<Map<String, dynamic>>> initialData) async {
    // For protobuf implementation, we don't use the JSON initialData
    // Instead, we load directly from protobuf assets
    return await _initializeIfNeeded();
  }

  @override
  Future<Either<Failure, RawPan>> getPan(
      EnumDayNight dayNight, JiaZi dayGanZhi, DiZhi ganShangZhi) async {
    // Initialize if needed
    final initResult = await _initializeIfNeeded();
    if (initResult.isLeft()) {
      return Left(initResult.fold(
          (l) => l, (r) => GenericFailure("Initialization failed")));
    }

    try {
      if (_dataBundle == null) {
        return Left(NotFoundFailure("Data bundle not loaded"));
      }

      // Determine which data list to use based on dayNight (阳遁/阴遁)
      final dataList = dayNight == EnumDayNight.day
          ? _dataBundle!.yangList
          : _dataBundle!.yinList;

      if (dataList == null) {
        return Left(
            NotFoundFailure("Data list not loaded for ${dayNight.name}"));
      }

      // Search for matching data based on dayGanZhi
      final dayJiaZiName = dayGanZhi.name;
      final ganShangZhiName = ganShangZhi.value;

      XuanDaLiuRenData? matchedData;
      for (final data in dataList.dataList) {
        if (data.dayJiaZi == dayJiaZiName) {
          // For now, we take the first match
          // In a real implementation, you might need additional criteria
          matchedData = data;
          break;
        }
      }

      if (matchedData == null) {
        return Left(NotFoundFailure(
            "No data found for day: $dayJiaZiName, ganShangZhi: $ganShangZhiName"));
      }

      // Convert protobuf data to domain entity
      final rawPan = _mapProtobufDataToRawPan(
          matchedData, dayNight, dayGanZhi, ganShangZhi);
      return Right(rawPan);
    } catch (e, s) {
      print("ProtobufRepository: Failed to get RawPan: $e\n$s");
      return Left(GenericFailure(
          "Failed to process RawPan request: ${e.toString()}", s));
    }
  }

  /// Maps protobuf data to RawPan domain entity
  RawPan _mapProtobufDataToRawPan(XuanDaLiuRenData data, EnumDayNight dayNight,
      JiaZi dayGanZhi, DiZhi ganShangZhi) {
    // Map four classes
    final fourClasses = _mapFourClassFromProtobuf(data.fourClass);

    // Map three chuans
    final threeChuans = _mapThreeChuanFromProtobuf(data.threeChuan);

    // Map gong information
    final gongMapper = <DiZhi, RawEachGong>{};
    for (final entry in data.gongMapper.entries) {
      final diZhi = _parseStringToDiZhi(entry.key);
      if (diZhi != null) {
        gongMapper[diZhi] = _mapGongInfoToRawEachGong(entry.value);
      }
    }

    // Determine GuiRenType based on dayNight
    final guiRenType =
        dayNight == EnumDayNight.day ? GuiRenType.YANG_GUI : GuiRenType.YIN_GUI;

    return RawPan(
      dayGanZhi: dayGanZhi,
      uponGan: ganShangZhi,
      guiRenType: guiRenType,
      fourClass: fourClasses,
      threeChuan: threeChuans,
      gongMapper: gongMapper,
    );
  }

  /// Maps FourClass from protobuf to domain entities
  List<RawEachClass> _mapFourClassFromProtobuf(FourClass? fourClass) {
    if (fourClass == null) return [];

    final classes = <RawEachClass>[];

    if (fourClass.hasFirst()) {
      classes.add(_mapClassInfoToRawEachClass(fourClass.first, 1));
    }
    if (fourClass.hasSecond()) {
      classes.add(_mapClassInfoToRawEachClass(fourClass.second, 2));
    }
    if (fourClass.hasThird()) {
      classes.add(_mapClassInfoToRawEachClass(fourClass.third, 3));
    }
    if (fourClass.hasFourth()) {
      classes.add(_mapClassInfoToRawEachClass(fourClass.fourth, 4));
    }

    return classes;
  }

  /// Maps ThreeChuan from protobuf to domain entities
  List<RawEachChuan> _mapThreeChuanFromProtobuf(ThreeChuan? threeChuan) {
    if (threeChuan == null) return [];

    final chuans = <RawEachChuan>[];

    if (threeChuan.hasFirst()) {
      chuans.add(_mapChuanInfoToRawEachChuan(threeChuan.first, 1));
    }
    if (threeChuan.hasSecond()) {
      chuans.add(_mapChuanInfoToRawEachChuan(threeChuan.second, 2));
    }
    if (threeChuan.hasThird()) {
      chuans.add(_mapChuanInfoToRawEachChuan(threeChuan.third, 3));
    }

    return chuans;
  }

  /// Maps ClassInfo to RawEachClass
  RawEachClass _mapClassInfoToRawEachClass(ClassInfo classInfo, int order) {
    final sky = _parseStringToDiZhi(classInfo.sky) ?? DiZhi.ZI;
    final ground = _parseStringToDiZhi(classInfo.ground) ?? DiZhi.ZI;
    final guiRen = _parseGuiRen(classInfo.guiRen);

    // Check if this is the first class and has tianGan
    if (order == 1 && classInfo.hasTianGan()) {
      final tianGan = _parseStringToTianGan(classInfo.tianGan) ?? TianGan.JIA;
      return RawFirstClass(
        sky: sky,
        ground: ground,
        guiRen: guiRen,
        tianGan: tianGan,
      );
    } else {
      return RawEachClass(
        order: order,
        sky: sky,
        ground: ground,
        guiRen: guiRen,
      );
    }
  }

  /// Maps ChuanInfo to RawEachChuan
  RawEachChuan _mapChuanInfoToRawEachChuan(ChuanInfo chuanInfo, int order) {
    final diZhi = _parseStringToDiZhi(chuanInfo.diZhi) ?? DiZhi.ZI;
    final guiRen = _parseGuiRen(chuanInfo.guiRen);
    final liuQin = _parseStringToLiuQin(chuanInfo.liuQin) ?? LiuQin.JI_SHEN;

    return RawEachChuan(
      order: order,
      diZhi: diZhi,
      guiRen: guiRen,
      liuQin: liuQin,
    );
  }

  /// Maps GongInfo to RawEachGong
  RawEachGong _mapGongInfoToRawEachGong(GongInfo gongInfo) {
    final groundPanDiZhi =
        _parseStringToDiZhi(gongInfo.groundPanDiZhi) ?? DiZhi.ZI;
    final skyPanDiZhi = _parseStringToDiZhi(gongInfo.skyPanDiZhi) ?? DiZhi.ZI;
    final guiRen = _parseGuiRen(gongInfo.guiRen);

    return RawEachGong(
      groundPanDiZhi: groundPanDiZhi,
      skyPanDiZhi: skyPanDiZhi,
      guiRen: guiRen,
    );
  }

  /// Parses GuiRen string to domain enum
  domain_gui_ren.GuiRen _parseGuiRen(String guiRenStr) {
    try {
      return domain_gui_ren.GuiRen.values.firstWhere(
        (gr) => gr.value == guiRenStr || gr.name == guiRenStr,
        orElse: () => domain_gui_ren.GuiRen.GUI_REN,
      );
    } catch (e) {
      return domain_gui_ren.GuiRen.GUI_REN;
    }
  }

  /// Parses string to DiZhi enum
  DiZhi? _parseStringToDiZhi(String diZhiStr) {
    try {
      return DiZhi.values.firstWhere(
        (dz) => dz.value == diZhiStr || dz.name == diZhiStr,
        orElse: () => DiZhi.ZI,
      );
    } catch (e) {
      return null;
    }
  }

  /// Parses string to TianGan enum
  TianGan? _parseStringToTianGan(String tianGanStr) {
    try {
      return TianGan.values.firstWhere(
        (tg) => tg.value == tianGanStr || tg.name == tianGanStr,
        orElse: () => TianGan.JIA,
      );
    } catch (e) {
      return null;
    }
  }

  /// Parses string to LiuQin enum
  LiuQin? _parseStringToLiuQin(String liuQinStr) {
    try {
      return LiuQin.values.firstWhere(
        (lq) => lq.value == liuQinStr || lq.name == liuQinStr,
        orElse: () => LiuQin.JI_SHEN,
      );
    } catch (e) {
      return null;
    }
  }
}
