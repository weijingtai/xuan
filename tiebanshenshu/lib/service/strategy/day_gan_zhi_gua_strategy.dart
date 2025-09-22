/// 日柱变卦取数法Strategy实现
///
/// 将日柱变卦取数法算法封装为标准计算策略
library;

import 'package:common/enums.dart';

import '../../constant/constants.dart' as Constants;
import '../../domain/pure_six_yao_gua.dart';
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';

/// 日柱变卦取数法计算参数
///
/// 包含执行日柱变卦取数法所需的所有参数
class DayGanZhiGuaStrategyParams extends BaseCalculationParams {
  /// 四柱信息
  final JiaZi dayGanZhi;

  DayGanZhiGuaStrategyParams({required this.dayGanZhi});

  @override
  String get description => "日柱变卦取数法计算参数：四柱信息(${dayGanZhi})";
}

class DayGanZhiGuaStrategyResult extends BaseCalculationResult {
  final int tiaoWenNumber;

  DayGanZhiGuaStrategyResult({required this.tiaoWenNumber});

  @override
  int get baseNumber => tiaoWenNumber;
}

/// 日柱变卦取数法计算结果
///
/// 包含日柱变卦取数法的计算结果，主要结果为条文编号
// class DayGanZhiGuaStrategyResult extends BaseCalculationResult {
//   /// 主要结果：条文编号
//   final int tiaoWenNumber;

//   /// 四柱信息
//   final FourZhu fourZhu;

//   /// 日干
//   final String dayGan;

//   /// 日支
//   final String dayZhi;

//   /// 基本卦名
//   final String baseGuaName;

//   /// 互卦名
//   final String huGuaName;

//   /// 基本数
//   final int baseNumber;

//   const DayGanZhiGuaStrategyResult({
//     required this.tiaoWenNumber,
//     required this.fourZhu,
//     required this.dayGan,
//     required this.dayZhi,
//     required this.baseGuaName,
//     required this.huGuaName,
//     required this.baseNumber,
//   });

//   @override
//   String get summary =>
//       "日柱变卦取数法结果：条文编号 $tiaoWenNumber（日柱：$dayGan$dayZhi，基本卦：$baseGuaName，互卦：$huGuaName）";
// }

/// 日柱变卦取数法计算策略
///
/// 实现日柱变卦取数法的标准计算策略
class DayGanZhiGuaStrategy
    extends
        StandardCalculationStrategy<
          DayGanZhiGuaStrategyParams,
          DayGanZhiGuaStrategyResult
        > {
  @override
  String get name => "日柱变卦取数法";

  @override
  String get description => "以日干为下卦、日支为上卦组成基本卦，计算互卦，结合后天和先天卦数得到条文编号";

  @override
  List<String> get detailSteps => [
    "1. 提取日柱：从四柱中获取日干和日支",
    "2. 组成基本卦：日干为下卦，日支为上卦",
    "3. 计算互卦：根据基本卦计算互卦",
    "4. 计算基本数：结合后天卦数和先天卦数",
    "5. 计算条文编号：根据基本数计算最终条文编号",
  ];

  @override
  String get school => "日柱变卦流派";

  @override
  DayGanZhiGuaStrategyResult calculate(DayGanZhiGuaStrategyParams params) {
    final dayGanzhi = params.dayGanZhi;

    // 计算基本卦：日支为上卦，日干为下卦
    final Enum8Gua dayDownGu = Constants.tianGanGuaMapper[dayGanzhi.gan]!;
    final Enum8Gua dayUpGu = Constants.diZhiGuaMapper[dayGanzhi.zhi]!;
    // 第一卦
    final PureSixYaoGua pure = PureSixYaoGua.by8Gua(dayUpGu, dayDownGu);

    // 第二卦
    // 计算互卦：第一卦的互卦为第二卦
    final Gua64Enum huGua = pure.hu;

    // 计算基本数：组合四位数
    final baseNumber = _calculateBaseNumber(pure.gua, huGua);

    // 封装为新的Result对象
    return DayGanZhiGuaStrategyResult(tiaoWenNumber: baseNumber);
  }

  /// 计算基本卦
  ///
  /// 日支为上卦，日干为下卦
  static Gua64Enum _calculateBaseGua(JiaZi dayGanzhi) {
    UnimplementedError("未完成");
    final Enum8Gua dayDownGu = Constants.tianGanGuaMapper[dayGanzhi.gan]!;
    final Enum8Gua dayUpGu = Constants.diZhiGuaMapper[dayGanzhi.zhi]!;
    final Gua64Enum baseGua = Gua64Enum.getBy8Gua(dayUpGu, dayDownGu);

    return baseGua;
  }

  /// 计算基本数
  ///
  /// 第一卦上卦【后天】数为千位，下卦【后天】数为百位；
  /// 第二卦上【先天】数为十位，下卦【先天】数为个位
  static int _calculateBaseNumber(Gua64Enum baseGua, Gua64Enum huGua) {
    final int firstUp = Constants.houGuaNumberMapper[baseGua.top]!;
    final int firstDown = Constants.houGuaNumberMapper[baseGua.bottom]!;

    final int secondUp = Constants.xianGuaNumberMapper[huGua.top]!;
    final int secondDown = Constants.xianGuaNumberMapper[huGua.bottom]!;

    return int.parse('$firstUp$firstDown$secondUp$secondDown');
  }
}
