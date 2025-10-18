/// GuaYaoGanZhiHe domain models
///
/// Contains NaJia method enum, Yao detail model, and Base number model
library;

import 'package:common/enums.dart';
import '../../features/six_yao_gua/pure_six_yao_gua.dart';
import '../../repository/datamodels/tiao_wen_datamodel.dart';
import 'base_number_tiao_wen_list_model.dart';
import 'base_number_model.dart';

/// NaJia Method Enum
///
/// Defines two different NaJia assignment methods for GuaYaoGanZhiHe algorithm
enum GuaYaoGanZhiHeNaJiaMethod {
  /// Year Gan Yin-Yang method
  /// Uses year stem's yin-yang to decide Gan mapping, inner-outer for Zhi
  yearGanYinYang,

  /// Inner-Outer Gua method
  /// Uses inner-outer gua mapping for both Gan and Zhi (traditional method)
  innerOuterGua,
}

extension GuaYaoGanZhiHeNaJiaMethodExt on GuaYaoGanZhiHeNaJiaMethod {
  String get displayName {
    switch (this) {
      case GuaYaoGanZhiHeNaJiaMethod.yearGanYinYang:
        return 'Year Gan Yin-Yang NaJia';
      case GuaYaoGanZhiHeNaJiaMethod.innerOuterGua:
        return 'Inner-Outer Gua NaJia';
    }
  }

  String get description {
    switch (this) {
      case GuaYaoGanZhiHeNaJiaMethod.yearGanYinYang:
        return 'Use year stem yin-yang for Gan mapping';
      case GuaYaoGanZhiHeNaJiaMethod.innerOuterGua:
        return 'Use inner-outer gua mapping (traditional)';
    }
  }
}

/// Yao Detail for GuaYaoGanZhiHe calculation
///
/// Represents calculation details for a single yao position
class GuaYaoGanZhiHeYaoDetail {
  /// Yao position (0-5, from bottom to top)
  final int yaoPosition;

  /// Yao position name (like "chu", "er", "san", etc.)
  final String yaoPositionName;

  /// Yin-Yang of the yao
  final YinYang yinYang;

  /// NaJia assigned Heavenly Stem
  final TianGan naTianGan;

  /// NaJia assigned Earthly Branch
  final DiZhi naDiZhi;

  /// TaiXuan number for the Gan
  final int ganTaiXuanNumber;

  /// TaiXuan number for the Zhi
  final int zhiTaiXuanNumber;

  /// Sum of Gan and Zhi TaiXuan numbers
  final int yaoSum;

  /// Whether this yao is filtered (sum equals 10)
  final bool isFiltered;

  const GuaYaoGanZhiHeYaoDetail({
    required this.yaoPosition,
    required this.yaoPositionName,
    required this.yinYang,
    required this.naTianGan,
    required this.naDiZhi,
    required this.ganTaiXuanNumber,
    required this.zhiTaiXuanNumber,
    required this.yaoSum,
    required this.isFiltered,
  });

  @override
  String toString() {
    final filteredTag = isFiltered ? ' [Filtered]' : '';
    return '$yaoPositionName: ${naTianGan.name}${naDiZhi.name} = $ganTaiXuanNumber+$zhiTaiXuanNumber = $yaoSum$filteredTag';
  }
}

/// Base Number Model for GuaYaoGanZhiHe Method
///
/// Contains calculation results for one pillar (year/month/day/time)
class GuaYaoGanZhiHeBaseNumberModel extends BaseNumberTiaoWenListModel {
  /// Pillar name (year/month/day/time)
  final String pillarName;

  /// Original GanZhi for this pillar
  final JiaZi ganzhi;

  /// NaJia method used
  final GuaYaoGanZhiHeNaJiaMethod naJiaMethod;

  /// 64 Gua formed by Gan and Zhi
  final Enum64Gua gua64;

  /// Upper gua (outer gua)
  final Enum8Gua upperGua;

  /// Lower gua (inner gua)
  final Enum8Gua lowerGua;

  /// Six yao calculation details
  final List<GuaYaoGanZhiHeYaoDetail> yaoDetails;

  /// Lower gua sum (yao 1+2+3, excluding filtered)
  final int lowerGuaSum;

  /// Upper gua sum (yao 4+5+6, excluding filtered)
  final int upperGuaSum;

  /// Calculation formula string
  final String formula;

  /// Calculation detail string
  final String calculationDetail;

  const GuaYaoGanZhiHeBaseNumberModel({
    required this.pillarName,
    required this.ganzhi,
    required this.naJiaMethod,
    required this.gua64,
    required this.upperGua,
    required this.lowerGua,
    required this.yaoDetails,
    required this.lowerGuaSum,
    required this.upperGuaSum,
    required this.formula,
    required this.calculationDetail,
    required super.baseNumber,
    required super.name,
    required super.description,
    required super.source,
    required super.tiaoWenNumbers,
    required super.tiaoWenDataList,
    super.baseTiaoWen,
  });

  @override
  GuaYaoGanZhiHeBaseNumberModel copyWith({
    String? pillarName,
    JiaZi? ganzhi,
    GuaYaoGanZhiHeNaJiaMethod? naJiaMethod,
    Enum64Gua? gua64,
    Enum8Gua? upperGua,
    Enum8Gua? lowerGua,
    List<GuaYaoGanZhiHeYaoDetail>? yaoDetails,
    int? lowerGuaSum,
    int? upperGuaSum,
    String? formula,
    String? calculationDetail,
    int? baseNumber,
    String? name,
    String? description,
    BaseNumberSource? source,
    List<int>? tiaoWenNumbers,
    List<TiaoWenDataModel>? tiaoWenDataList,
    TiaoWenDataModel? baseTiaoWen,
  }) {
    return GuaYaoGanZhiHeBaseNumberModel(
      pillarName: pillarName ?? this.pillarName,
      ganzhi: ganzhi ?? this.ganzhi,
      naJiaMethod: naJiaMethod ?? this.naJiaMethod,
      gua64: gua64 ?? this.gua64,
      upperGua: upperGua ?? this.upperGua,
      lowerGua: lowerGua ?? this.lowerGua,
      yaoDetails: yaoDetails ?? this.yaoDetails,
      lowerGuaSum: lowerGuaSum ?? this.lowerGuaSum,
      upperGuaSum: upperGuaSum ?? this.upperGuaSum,
      formula: formula ?? this.formula,
      calculationDetail: calculationDetail ?? this.calculationDetail,
      baseNumber: baseNumber ?? this.baseNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      source: source ?? this.source,
      tiaoWenNumbers: tiaoWenNumbers ?? this.tiaoWenNumbers,
      tiaoWenDataList: tiaoWenDataList ?? this.tiaoWenDataList,
      baseTiaoWen: baseTiaoWen ?? this.baseTiaoWen,
    );
  }

  @override
  String toString() {
    return 'GuaYaoGanZhiHeBaseNumberModel('
        'pillarName: $pillarName, '
        'ganzhi: ${ganzhi.name}, '
        'method: ${naJiaMethod.displayName}, '
        'gua64: ${gua64.name}, '
        'baseNumber: $baseNumber, '
        'tiaoWenNumbers: $tiaoWenNumbers, '
        'detail: $calculationDetail'
        ')';
  }
}
