import 'package:qimendunjia/enums/enum_arrange_plate_type.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';
import 'package:qimendunjia/model/shi_jia_qi_men.dart';
import '../entities/qimen_pan.dart';
import '../entities/shi_jia_ju.dart';

/// 奇门计算器仓储接口
///
/// 负责计算局数和排盘的业务逻辑
abstract class QiMenCalculatorRepository {
  /// 计算局数
  ///
  /// [dateTime] 起盘时间
  /// [arrangeType] 起盘方式（拆补/置润/茅山/阴盘）
  ///
  /// 返回计算好的局信息
  ///
  /// 抛出 [QiMenCalculationException] 当计算失败时
  Future<ShiJiaJu> calculateJu({
    required DateTime dateTime,
    required ArrangeType arrangeType,
  });

  /// 排盘
  ///
  /// [ju] 局信息
  /// [plateType] 盘类型（转盘/飞盘）
  /// [settings] 排盘设置
  ///
  /// 返回完整的奇门盘
  ///
  /// 抛出 [QiMenCalculationException] 当排盘失败时
  Future<QiMenPan> arrangePan({
    required ShiJiaJu ju,
    required PlateType plateType,
    required PanSettings settings,
  });
}

/// 排盘设置
class PanSettings {
  /// 起盘方式
  final ArrangeType arrangeType;

  /// 中宫寄宫类型
  final CenterGongJiGongType jiGong;

  /// 星月令类型
  final MonthTokenTypeEnum starMonthTokenType;

  /// 星四维宫类型
  final GongTypeEnum starFourWeiGongType;

  /// 门四维宫类型
  final GongTypeEnum doorFourWeiGongType;

  /// 神宫类型
  final GodWithGongTypeEnum godWithGongType;

  /// 干宫类型
  final GanGongTypeEnum ganGongType;

  const PanSettings({
    required this.arrangeType,
    required this.jiGong,
    required this.starMonthTokenType,
    required this.starFourWeiGongType,
    required this.doorFourWeiGongType,
    required this.godWithGongType,
    required this.ganGongType,
  });

  /// 默认设置
  factory PanSettings.defaultSettings() {
    return const PanSettings(
      arrangeType: ArrangeType.CHAI_BU,
      jiGong: CenterGongJiGongType.KUN_GEN_GONG,
      starMonthTokenType: MonthTokenTypeEnum.ZHU_QI,
      starFourWeiGongType: GongTypeEnum.GONG_GUA,
      doorFourWeiGongType: GongTypeEnum.GONG_GUA,
      godWithGongType: GodWithGongTypeEnum.GONG_GUA_ONLY,
      ganGongType: GanGongTypeEnum.WANG_MU,
    );
  }
}

/// 奇门计算异常
class QiMenCalculationException implements Exception {
  final String message;

  QiMenCalculationException(this.message);

  @override
  String toString() => 'QiMenCalculationException: $message';
}

