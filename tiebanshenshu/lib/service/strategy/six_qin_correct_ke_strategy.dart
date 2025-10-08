/// 六亲考刻法策略实现
///
/// 将六亲考刻法算法封装为标准计算策略
library;

import 'package:common/enums.dart';
import 'package:tiebanshenshu/domain/models/base_number_model.dart';
import 'package:tiebanshenshu/domain/models/base_number_model_result.dart';

import 'package:tiebanshenshu/domain/pure_six_yao_gua.dart';
import 'package:tiebanshenshu/utils/utils.dart';

import '../../constant/constants.dart' as Constants;
import '../../domain/four_zhu.dart';
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';
import 'tiao_wen_list_calculation.dart';

/// 六亲考刻法计算参数
///
/// 包含执行六亲考刻法所需的所有参数
class SixQinCorrectKeStrategyParams extends BaseCalculationParams {
  final FourZhu fourZhu;
  final Gender gender;

  SixQinCorrectKeStrategyParams({required this.fourZhu, required this.gender});

  @override
  String get description => "六亲考刻法计算参数：四柱(${fourZhu}), 性别(${gender.name})";
}

/// 六亲考刻修正类
class CorrectionSixQinKe {
  final String baseGua;
  final String rootGua;
  final String baseGuaHu;
  final List<int> bianYaoIndexList;
  final int baseNumber;
  final bool isAccepted;

  CorrectionSixQinKe({
    required this.baseGua,
    required this.rootGua,
    required this.baseGuaHu,
    required this.bianYaoIndexList,
    required this.baseNumber,
    required this.isAccepted,
  });

  @override
  String toString() {
    return 'CorrectionSixQinKe(baseGua: $baseGua, rootGua: $rootGua, baseGuaHu: $baseGuaHu, bianYaoIndexList: $bianYaoIndexList, baseNumber: $baseNumber, isAccepted: $isAccepted)';
  }
}

/// 六亲考刻法计算策略
///
/// 实现六亲考刻法的标准计算策略
class SixQinCorrectKeStrategy extends StandardCalculationStrategy<
    SixQinCorrectKeStrategyParams, BaseNumberModelResult> {
  @override
  String get name => "六亲考刻法";

  @override
  String get description => "通过四柱干支计算先天基本卦和后天基本卦，结合变爻位置生成条文编号的传统算法";

  @override
  List<String> get detailSteps => [
        "1. 排四柱：获取年月日时的干支信息",
        "2. 四柱取太玄数：将干支转换为太玄数值",
        "3. 计算先天基本卦：年月干支太玄数相加取模8得先天卦，根据性别和年干阴阳确定上下卦顺序",
        "4. 计算后天基本卦：日时干支太玄数减10后取后天卦，组合成基本卦",
        "5. 求取互卦：分别计算先天和后天基本卦的互卦",
        "6. 计算卦气深度（先天）：基本卦上卦为千位，下卦为百位，互卦上卦为十位，下卦为个位，组成四位数",
        "7. 先天变爻匹配：如四位数条文不符合命主，依次变化初爻、二爻等，直到找到符合的条文作为先天基本数",
        "8. 计算卦气深度（后天）：同样方式计算后天基本卦的四位数",
        "9. 后天变爻匹配：如四位数条文不符合命主，依次变化初爻等，直到找到符合的条文作为后天基本数",
        "10. 生成条文列表：基本数±(48×n)，其中n为[2,4,8,16]，得出8个条文编号",
      ];

  @override
  String get school => "六亲考刻流派";

  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    return GenericTiaoWenCalculationConfig.customList(
      name: "六亲考刻标准配置",
      description: "基本数 ± (48 * n), n in [2, 4, 8, 16]",
      customList: [2 * 48, 4 * 48, 8 * 48, 16 * 48],
      withSub: true,
    );
  }

  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs {
    return [
      defaultTiaoWenCalculationConfig,
    ];
  }

  @override
  String get tiaoWenCalculationDescription =>
      defaultTiaoWenCalculationConfig.description;

  @override
  BaseNumberModelResult calculate(SixQinCorrectKeStrategyParams params) {
    try {
      final fourZhu = params.fourZhu;
      final gender = params.gender;

      // 计算基本卦
      final xianTianBaseGuaName = _calculateXianTianBaseGua(fourZhu, gender);
      final houTianBaseGuaName = _calculateHouTianBaseGua(fourZhu);

      final xianTianBaseGua = Gua64Enum.fromFullName(xianTianBaseGuaName);
      final houTianBaseGua = Gua64Enum.fromFullName(houTianBaseGuaName);

      // 计算先天基本数（第三爻变爻时为基准）
      final xianTianResult = _getBasenumberByYaobianlist(
        [3],
        xianTianBaseGua,
        true, // isXianTian
      );

      // 计算后天基本数（初爻变爻时为基准）
      final houTianResult = _getBasenumberByYaobianlist(
        [0], // 1st yao
        houTianBaseGua,
        false, // isHouTian
      );

      final xianTianBaseNumberModel = BaseNumberModel.create(
        baseNumber: xianTianResult.baseNumber,
        name: "先天考刻数",
        description:
            "先天考刻数计算：基本卦$xianTianBaseGuaName，变爻${xianTianResult.bianYaoIndexList}, 基础数${xianTianResult.baseNumber}",
        source: BaseNumberSource.sixQinCorrectKe,
      );

      final houTianBaseNumberModel = BaseNumberModel.create(
        baseNumber: houTianResult.baseNumber,
        name: "后天考刻数",
        description:
            "后天考刻数计算：基本卦$houTianBaseGuaName，变爻${houTianResult.bianYaoIndexList}, 基础数${houTianResult.baseNumber}",
        source: BaseNumberSource.sixQinCorrectKe,
      );

      return BaseNumberModelResult.success(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        baseNumbers: [xianTianBaseNumberModel, houTianBaseNumberModel],
        sourceData: {
          'fourZhu': fourZhu.toString(),
          'gender': gender.name,
          'xianTianBaseGua': xianTianBaseGuaName,
          'houTianBaseGua': houTianBaseGuaName,
          'xianTianBaseNumber': xianTianResult.baseNumber,
          'houTianBaseNumber': houTianResult.baseNumber,
        },
      );
    } catch (e) {
      return BaseNumberModelResult.error(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        errorMessage: "六亲考刻计算失败: $e",
        sourceData: {'error': e.toString(), 'params': params.description},
      );
    }
  }

  /// 计算先天基本卦
  String _calculateXianTianBaseGua(FourZhu fourZhu, Gender gender) {
    int yearTaixuanNumSum =
        fourZhu.yearZhiTaixuanNum + fourZhu.yearGanTaixuanNum;
    int yearGuaNum = yearTaixuanNumSum % 8;
    if (yearGuaNum == 0) {
      yearGuaNum = 8;
    }
    String yearGua = Constants.xianTianNumberGuaMapper[yearGuaNum]!;

    int monthTaixuanNumSum =
        fourZhu.monthZhiTaixuanNum + fourZhu.monthGanTaixuanNum;
    int monthGuaNum = monthTaixuanNumSum % 8;
    if (monthGuaNum == 0) {
      monthGuaNum = 8;
    }
    String monthGua = Constants.xianTianNumberGuaMapper[monthGuaNum]!;

    String res;
    if (fourZhu.isYangGanYear) {
      res = gender == Gender.male ? yearGua + monthGua : monthGua + yearGua;
    } else {
      res = gender == Gender.male ? monthGua + yearGua : yearGua + monthGua;
    }
    return res;
  }

  /// 计算后天基本卦
  String _calculateHouTianBaseGua(FourZhu fourZhu) {
    int dayTaixuanNumSum = fourZhu.dayZhiTaixuanNum + fourZhu.dayGanTaixuanNum;
    int dayGuaNum = (dayTaixuanNumSum - 10).abs();
    String dayGua = Constants.houTianNumberGuaMapper[dayGuaNum]!;

    int timeTaixuanNumSum =
        fourZhu.timeZhiTaixuanNum + fourZhu.timeGanTaixuanNum;
    int timeGuaNum = (timeTaixuanNumSum - 10).abs();
    String timeGua = Constants.houTianNumberGuaMapper[timeGuaNum]!;

    return dayGua + timeGua;
  }

  CorrectionSixQinKe _getBasenumberByYaobianlist(
    List<int> bianYaoIndexList,
    Gua64Enum baseGua,
    bool isXianTian,
  ) {
    Gua64Enum bianGua;

    if (bianYaoIndexList.isEmpty) {
      bianGua = baseGua;
    } else {
      List<int> guaBinList = guaToBinaryList(baseGua.name);
      guaBinList = guaBinList.reversed.toList();

      for (int index in bianYaoIndexList) {
        if (guaBinList[index] == 0) {
          guaBinList[index] = 1;
        } else {
          guaBinList[index] = 0;
        }
      }
      guaBinList = guaBinList.reversed.toList();
      String bianGuaName = binaryListToGua(guaBinList);
      bianGua = Gua64Enum.fromFullName(bianGuaName);
    }

    final huGua = PureSixYaoGua.by8Gua(bianGua.top, bianGua.bottom).hu;

    final int baseNumber;
    if (isXianTian) {
      final int firstUp = Constants.xianGuaNumberMapper[bianGua.top]!;
      final int firstDown = Constants.xianGuaNumberMapper[bianGua.bottom]!;
      final int secondUp = Constants.xianGuaNumberMapper[huGua.top]!;
      final int secondDown = Constants.xianGuaNumberMapper[huGua.bottom]!;
      baseNumber = int.parse('$firstUp$firstDown$secondUp$secondDown');
    } else {
      final int firstUp = Constants.houGuaNumberMapper[bianGua.top]!;
      final int firstDown = Constants.houGuaNumberMapper[bianGua.bottom]!;
      final int secondUp = Constants.houGuaNumberMapper[huGua.top]!;
      final int secondDown = Constants.houGuaNumberMapper[huGua.bottom]!;
      baseNumber = int.parse('$firstUp$firstDown$secondUp$secondDown');
    }

    return CorrectionSixQinKe(
      baseGua: bianGua.name,
      rootGua: baseGua.name,
      baseGuaHu: huGua.name,
      bianYaoIndexList: bianYaoIndexList,
      baseNumber: baseNumber,
      isAccepted: false,
    );
  }
}