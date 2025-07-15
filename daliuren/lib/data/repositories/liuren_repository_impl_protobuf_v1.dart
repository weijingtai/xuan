// lib/data/repositories/liuren_repository_impl_protobuf.dart

import 'dart:typed_data';
import 'package:daliuren/domain/entities/raw_pan_info_model.dart';
import 'package:flutter/services.dart';
import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:fpdart/fpdart.dart' hide Failure;
import 'package:daliuren/core/errors/failures.dart';
import 'package:daliuren/domain/repositories/liuren_repository.dart';
import 'package:daliuren/domain/entities/liu_ren_pan_model.dart';
import 'package:daliuren/domain/entities/pan_input.dart';
import 'package:daliuren/data/datasources/local/protobuf/jia_wu_geng_niu_yang.pb.dart';
import 'package:daliuren/domain/enums/gui_ren.dart' as domain_gui_ren;
import 'package:daliuren/domain/enums/nine_zong_men.dart'
    as domain_nine_zong_men;

import '../../domain/entities/four_class_ke_entity.dart';
import '../../domain/entities/liuren_gong_entity.dart';
import '../../domain/entities/three_chuan_entity.dart';
import '../../model/da_liu_ren_ke_pan.dart';
import 'liuren_repository_impl.dart';

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
  Future<Either<Failure, LiuRenPanModel>> getPan(
      EnumDayNight dayNight, JiaZi dayGanZhi, DiZhi ganShangZhi) async {
    // Initialize if needed
    final initResult = await _initializeIfNeeded();
    if (initResult.isLeft()) {
      return Left(initResult.fold(
          (l) => l, (r) => GenericFailure("Initialization failed")));
    }

    try {
      // Determine which data list to use based on dayNight (阳遁/阴遁)
      final dataList = dayNight == EnumDayNight.day
          ? _dataBundle?.yangList
          : _dataBundle?.yinList;

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
      final liuRenPan = _mapProtobufDataToEntity(matchedData, dayNight);
      return Right(liuRenPan);
    } catch (e, s) {
      print("ProtobufRepository: Failed to get LiuRenPan: $e\n$s");
      return Left(GenericFailure(
          "Failed to process LiuRenPan request: ${e.toString()}", s));
    }
  }

  /// Maps protobuf data to domain entity
  LiuRenPanModel _mapProtobufDataToEntity(
      XuanDaLiuRenData data, EnumDayNight dayNight) {
    // Map four classes
    final fourClasses = _mapFourClassFromProtobuf(data.fourClass);

    // Map three chuans
    final threeChuans = _mapThreeChuanFromProtobuf(data.threeChuan);

    // Parse JiaZi from string
    final dayJiaZiEnum = JiaZi.getFromGanZhiValue(data.dayJiaZi);
    final shiChenEnum = DiZhi.getFromValue(data.shiChen);

    return LiuRenPanModel(
      dayJiaZi: data.dayJiaZi,
      dayGanZhi: data.dayJiaZi,
      timeGanZhi: data.shiChen,
      shiChenZhiName: data.shiChen,
      yueJiangName: "月将", // This should be derived from the data
      guiRenType: dayNight == EnumDayNight.day ? "阳贵" : "阴贵",
      fourClasses: fourClasses,
      threeChuans: threeChuans,
      nineZongMen: _parseNineZongMen(data.fourClass),
      keTiComplement: _parseKeTiComplement(data.fourClass),
      sourceDescription: "Protobuf Data (${data.juNumberName})",
      dayJiaZiEnum: dayJiaZiEnum,
      shiChenEnum: shiChenEnum,
      dayNightUsed: dayNight,
      juUsed: data.juNumber,
    );
  }

  /// Maps FourClass from protobuf to domain entities
  List<FourClassKeEntity> _mapFourClassFromProtobuf(FourClass? fourClass) {
    if (fourClass == null) return [];

    final classes = <FourClassKeEntity>[];

    if (fourClass.hasFirst()) {
      classes.add(_mapClassInfoToEntity(fourClass.first, "第一课"));
    }
    if (fourClass.hasSecond()) {
      classes.add(_mapClassInfoToEntity(fourClass.second, "第二课"));
    }
    if (fourClass.hasThird()) {
      classes.add(_mapClassInfoToEntity(fourClass.third, "第三课"));
    }
    if (fourClass.hasFourth()) {
      classes.add(_mapClassInfoToEntity(fourClass.fourth, "第四课"));
    }

    return classes;
  }

  /// Maps ThreeChuan from protobuf to domain entities
  List<ThreeChuanEntity> _mapThreeChuanFromProtobuf(ThreeChuan? threeChuan) {
    if (threeChuan == null) return [];

    final chuans = <ThreeChuanEntity>[];

    if (threeChuan.hasFirst()) {
      chuans.add(_mapChuanInfoToEntity(threeChuan.first, "初传"));
    }
    if (threeChuan.hasSecond()) {
      chuans.add(_mapChuanInfoToEntity(threeChuan.second, "中传"));
    }
    if (threeChuan.hasThird()) {
      chuans.add(_mapChuanInfoToEntity(threeChuan.third, "末传"));
    }

    return chuans;
  }

  /// Maps ClassInfo to FourClassKeEntity
  FourClassKeEntity _mapClassInfoToEntity(
      ClassInfo classInfo, String className) {
    return FourClassKeEntity(
      className: className,
      skyBranch: classInfo.sky,
      groundBranch: classInfo.ground,
      tianGan: classInfo.tianGan,
      guiRen: _parseGuiRen(classInfo.guiRen),
      keType: "课型", // This should be derived from protobuf data
      keDescription: "课体描述", // This should be derived from protobuf data
    );
  }

  /// Maps ChuanInfo to ThreeChuanEntity
  ThreeChuanEntity _mapChuanInfoToEntity(
      ChuanInfo chuanInfo, String chuanName) {
    return ThreeChuanEntity(
      chuanName: chuanName,
      diZhi: chuanInfo.diZhi,
      tianGan: chuanInfo.tianGan,
      guiRen: _parseGuiRen(chuanInfo.guiRen),
      chuanDescription: "传体描述",
      liuQin: _parseLiuQin(chuanInfo.liuQin), // Parse from protobuf
    );
  }

  /// Parses GuiRen string to domain enum
  domain_gui_ren.GuiRen _parseGuiRen(String guiRenStr) {
    try {
      return domain_gui_ren.GuiRen.values.firstWhere(
        (gr) => gr.singleName == guiRenStr || gr.name == guiRenStr,
        orElse: () => domain_gui_ren.GuiRen.GUI_REN,
      );
    } catch (e) {
      return domain_gui_ren.GuiRen.GUI_REN;
    }
  }

  /// Parses NineZongMen from FourClass protobuf data
  domain_nine_zong_men.NineZongMen _parseNineZongMen(FourClass? fourClass) {
    if (fourClass == null) return domain_nine_zong_men.NineZongMen.UNKNOWN;

    // This should be derived from the fourClass布象信息
    // For now, return UNKNOWN as placeholder
    return domain_nine_zong_men.NineZongMen.UNKNOWN;
  }

  /// Parses KeTi complement information from FourClass
  List<String> _parseKeTiComplement(FourClass? fourClass) {
    if (fourClass == null) return [];

    final complement = <String>[];

    // Add complement information based on fourClass properties
    if (fourClass.isQuanBeiKe) complement.add("全备课");
    if (fourClass.isSanCaiKe) complement.add("三才课");
    if (fourClass.isFuYin) complement.add("伏吟");
    if (fourClass.isFanYin) complement.add("反吟");

    return complement;
  }

  /// Parses LiuQin from string (placeholder implementation)
  String? _parseLiuQin(String liuQinStr) {
    if (liuQinStr.isEmpty) return null;
    return liuQinStr;
  }
}
