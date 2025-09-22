/// 四柱天干取数法Strategy实现
///
/// 将四柱天干取数法算法封装为标准计算策略
library;

import 'package:common/models/eight_chars.dart';
import 'package:common/shared/enums/enum_tian_gan.dart';
import '../../constant/constants.dart' as Constants;
import '../../domain/four_zhu.dart';
import '../../utils/tiao_wen_calculator.dart';
import '../classic/four_zhu_tian_gan_calculatioin.dart';
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';

/// 四柱天干取数法计算参数
///
/// 包含执行四柱天干取数法所需的所有参数
class FourZhuTianGanStrategyParams extends BaseCalculationParams {
  /// 四柱信息
  final EightChars eightChars;

  FourZhuTianGanStrategyParams({required this.eightChars});

  @override
  String get description =>
      "四柱天干取数法计算参数：四柱信息(${eightChars.year.name} ${eightChars.month.name} ${eightChars.day.name} ${eightChars.time.name})";
}

/// 四柱天干取数法计算结果
///
/// 包含四柱天干取数法的计算结果，主要结果为条文编号
class FourZhuTianGanStrategyResult extends BaseCalculationResult {
  /// 主要结果：条文编号（列表中的第一个）
  final int tiaoWenNumber;

  /// 基础数字
  int get baseNumber => tiaoWenNumber;

  FourZhuTianGanStrategyResult({required this.tiaoWenNumber});
}

/// 四柱天干取数法计算策略
///
/// 实现四柱天干取数法的标准计算策略
class FourZhuTianGanStrategy
    extends
        StandardCalculationStrategy<
          FourZhuTianGanStrategyParams,
          FourZhuTianGanStrategyResult
        > {
  @override
  String get name => "四柱天干取数法";

  @override
  String get description => "排四柱只取天干进行配数，按月日时年顺序排列得到基本数，递加96生成条文列表";

  @override
  List<String> get detailSteps => [
    "1. 排四柱：获取年月日时的天干信息",
    "2. 天干配数：甲1、乙6、丙2、丁7、戊3、己8、庚4、辛9、壬5、癸0",
    "3. 排列组合：按照月、日、时、年的顺序排列天干配数，得到四位基本数",
    "4. 生成条文列表：以基本数为基础递加96七次，得到8个条文编号",
  ];

  @override
  String get school => "四柱天干流派";

  @override
  FourZhuTianGanStrategyResult calculate(FourZhuTianGanStrategyParams params) {
    // 天干数字映射表

    // 获取四柱天干
    final eightChars = params.eightChars;
    final yearGan = eightChars.year.gan;
    final monthGan = eightChars.month.gan;
    final dayGan = eightChars.day.gan;
    final timeGan = eightChars.time.gan;

    // 按照月、日、时、年的顺序排列天干配数，得到四位基本数
    final monthNumber = Constants.fourZhuTianGanNumberMapper[monthGan]!;
    final dayNumber = Constants.fourZhuTianGanNumberMapper[dayGan]!;
    final timeNumber = Constants.fourZhuTianGanNumberMapper[timeGan]!;
    final yearNumber = Constants.fourZhuTianGanNumberMapper[yearGan]!;

    // 组合成四位数：月日时年
    final baseNumber =
        monthNumber * 1000 + dayNumber * 100 + timeNumber * 10 + yearNumber;

    // // 以基本数为基础递加96七次，得到8个条文编号
    // final tiaoWenNumberList =
    //     TiaowenCalculator.calculateTiaoWenListByAddFactorTimes(
    //       baseNumber,
    //       7,
    //       defaultFactor: 96,
    //       returnWithBase: true,
    //     );

    // // 提取第一个条文编号作为主要结果
    // final tiaoWenNumber = tiaoWenNumberList.isNotEmpty
    //     ? tiaoWenNumberList.first
    //     : baseNumber;

    return FourZhuTianGanStrategyResult(tiaoWenNumber: baseNumber);
  }
}
