/// 太玄取数法（1）Strategy实现
///
/// 将太玄取数法（1）算法封装为标准计算策略
library;

import 'package:collection/collection.dart';
import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import '../../domain/pure_six_yao_gua.dart';

import '../../constant/constants.dart' as Constants;
import '../../domain/four_zhu.dart';
import '../../utils/tiao_wen_calculator.dart';
import '../classic/tai_xuan_four_zhu_calculation.dart';
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';
import '../../domain/models/base_number_model_result.dart';
import '../../domain/models/base_number_model.dart';

/// 太玄取数法（1）计算参数
///
/// 包含执行太玄取数法（1）所需的所有参数
class TaiXuanFourZhuStrategyParams extends BaseCalculationParams {
  /// 四柱信息
  final EightChars eightChars;

  TaiXuanFourZhuStrategyParams({required this.eightChars});

  @override
  String get description =>
      "太玄取数法（1）计算参数：四柱信息(${eightChars.year.name} ${eightChars.month.name} ${eightChars.day.name} ${eightChars.time.name})";
}

// 太玄取数法（1）现在使用MultiBaseNumberResult
// 不再需要单独的TaiXuanFourZhuStrategyResult类

/// 太玄取数法（1）计算策略
///
/// 实现太玄取数法（1）的标准计算策略
class TaiXuanFourZhuStrategy
    extends
        StandardCalculationStrategy<
          TaiXuanFourZhuStrategyParams,
          BaseNumberModelResult
        > {
  @override
  String get name => "太玄取数法（1）";

  @override
  String get description => "排四柱天干地支分别配卦，纳甲配太玄数，上下卦数相配组成四位数，各加减96生成条文列表";

  @override
  List<String> get detailSteps => [
    "1. 排四柱：获取年月日时的干支信息",
    "2. 天干地支配卦：天干配卦法（壬甲从乾数，乙癸向坤求，庚来震上里，辛在巽方留，己从离门起，戊以坎为头，丙须艮处出，丁向兑家收）；地支配卦法（亥子坎宫寅木震，巳午离门丑在坤，卯酉乾金辰是兑，未申艮宫戌巽真）",
    "3. 组卦：同一柱的天干为上卦，地支为下卦，组成一个完整的卦",
    "4. 纳甲配干支：将卦配上纳甲干支，阳年乾卦天干配壬、阴年天干配甲；阳年坤配癸，阴年坤配乙",
    "5. 太玄数计算：每卦每爻的干支取太玄数相加（和数为10则不用），上卦数相加为一组，下卦数相加为一组",
    "6. 四位数组成：四卦各上下两数相配（上卦两位为千、百位，下卦两位为十、个位）",
    "7. 生成条文列表：四组数分别各±96四次，得到所有条文编号",
  ];

  @override
  String get school => "太玄取数流派";

  @override
  BaseNumberModelResult calculate(TaiXuanFourZhuStrategyParams params) {
    try {
      // 从 EightChars 创建 FourZhu
      final fourZhu = FourZhu(
        yearGanzhi: params.eightChars.year.name,
        monthGanzhi: params.eightChars.month.name,
        dayGanzhi: params.eightChars.day.name,
        timeGanzhi: params.eightChars.time.name,
      );

      final isYangYear = params.eightChars.year.gan.isYang;

      // 生成四柱的太玄数据
      final yearZhuBaseNumber = _generateTaiXuanEachZhu(
        params.eightChars.year,
        isYangYear,
      );
      final monthZhuBaseNumber = _generateTaiXuanEachZhu(
        params.eightChars.month,
        isYangYear,
      );
      final dayZhuBaseNumber = _generateTaiXuanEachZhu(
        params.eightChars.day,
        isYangYear,
      );
      final timeZhuBaseNumber = _generateTaiXuanEachZhu(
        params.eightChars.time,
        isYangYear,
      );

      // 创建基础数模型列表
      final baseNumbers = [
        BaseNumberModel.create(
          baseNumber: yearZhuBaseNumber,
          name: "年柱太玄数",
          description: "年柱${params.eightChars.year.name}的太玄计算结果",
          source: BaseNumberSource.yearZhu,
        ),
        BaseNumberModel.create(
          baseNumber: monthZhuBaseNumber,
          name: "月柱太玄数",
          description: "月柱${params.eightChars.month.name}的太玄计算结果",
          source: BaseNumberSource.monthZhu,
        ),
        BaseNumberModel.create(
          baseNumber: dayZhuBaseNumber,
          name: "日柱太玄数",
          description: "日柱${params.eightChars.day.name}的太玄计算结果",
          source: BaseNumberSource.dayZhu,
        ),
        BaseNumberModel.create(
          baseNumber: timeZhuBaseNumber,
          name: "时柱太玄数",
          description: "时柱${params.eightChars.time.name}的太玄计算结果",
          source: BaseNumberSource.timeZhu,
        ),
      ];

      return BaseNumberModelResult.success(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        baseNumbers: baseNumbers,
        sourceData: {
          'fourZhu': fourZhu,
          'isYangYear': isYangYear,
          'baseNumbers': [
            yearZhuBaseNumber,
            monthZhuBaseNumber,
            dayZhuBaseNumber,
            timeZhuBaseNumber,
          ],
        },
      );
    } catch (e) {
      return BaseNumberModelResult.error(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        errorMessage: "太玄四柱计算失败: $e",
        sourceData: {'error': e.toString(), 'params': params.description},
      );
    }
  }

  /// 生成太玄每柱实例
  /// 生成每柱的太玄数据
  ///
  /// 步骤说明:
  /// 1. 从干支中提取天干和地支，并映射到对应的卦
  /// 2. 根据天干卦和地支卦生成六爻卦
  /// 3. 获取六爻卦的干支列表
  /// 4. 分别计算上卦和下卦的干支和
  /// 5. 将上下卦数字组合成基础数
  int _generateTaiXuanEachZhu(JiaZi ganzhi, bool isYangYear) {
    // 步骤1: 获取天干对应的卦和地支对应的卦
    final Enum8Gua ganGua = Constants.tianGanGuaMapper[ganzhi.gan]!;
    final Enum8Gua zhiGua = Constants.diZhiGuaMapper[ganzhi.zhi]!;

    var pura = PureSixYaoGua.by8Gua(ganGua, zhiGua);

    // 步骤3: 分上下3爻分别进行计算
    var botYaoList = pura.yaoList.sublist(0, 3); // 获取前三个爻
    var topYaoList = pura.yaoList.sublist(3); // 获取后三个爻

    // 对每爻进行纳甲[阴阳]、纳支
    final Map<Enum8Gua, List<TianGan>> ganMapper;
    if (isYangYear) {
      ganMapper = Constants.yangGuaYaoTianGan;
    } else {
      ganMapper = Constants.yinGuaYaoTianGan;
    }

    // 下卦纳甲纳支
    for (var i = 0; i < botYaoList.length; i++) {
      botYaoList[i].naJia = ganMapper[pura.bottomGua]![i];
      botYaoList[i].naZhi = Constants.innerGuaYaoDiZhi[pura.bottomGua]![i];
    }

    // 上卦纳甲纳支
    for (var i = 0; i < topYaoList.length; i++) {
      topYaoList[i].naJia = ganMapper[pura.topGua]![i];
      topYaoList[i].naZhi = Constants.outerGuaYaoDiZhi[pura.topGua]![i];
    }

    // 分别计算每个爻的干支太玄数取数，并求和（排除和为10的情况）
    List<int> botSums = botYaoList
        .map(
          (y) =>
              Constants.taiXuanGanNumberMapper[y.naJia!]! +
              Constants.taiXuanZhiNumberMapper[y.naZhi!]!,
        )
        .where((t) => t != 10) // 修正过滤条件
        .toList();

    List<int> topSums = topYaoList
        .map(
          (y) =>
              Constants.taiXuanGanNumberMapper[y.naJia!]! +
              Constants.taiXuanZhiNumberMapper[y.naZhi!]!,
        )
        .where((t) => t != 10) // 修正过滤条件
        .toList();

    // 计算总和，如果没有有效数字则为0
    int botSum = botSums.isEmpty ? 0 : botSums.reduce((a, b) => a + b);
    int topSum = topSums.isEmpty ? 0 : topSums.reduce((a, b) => a + b);

    return topSum * 100 + botSum;
  }

  /// 计算太玄干支和
  int _calculateTaixuanGanzhiSum(String ganzhi) {
    return Constants.taixuanGanNumberMapper[ganzhi[0]]! +
        Constants.taixuanZhiNumberMapper[ganzhi[1]]!;
  }

  /// 计算每个八卦干支和
  int _calculateEachEightGuaGanzhiSum(List<String> ganzhiList) {
    int sum = 0;
    for (final String ganzhi in ganzhiList) {
      final int tmp = _calculateTaixuanGanzhiSum(ganzhi);
      if (tmp == 10) {
        continue;
      } else {
        sum += tmp;
      }
    }
    return sum;
  }
}
