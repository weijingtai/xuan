/// 先后天卦取数Strategy实现
///
/// 将先后天卦取数算法封装为标准计算策略
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';

import '../../domain/four_zhu.dart';
import '../../constant/constants.dart' as constants;
import '../../domain/models/base_number_model.dart';
import '../../domain/models/base_number_model_result.dart';
import '../../domain/models/xian_houtian_qu_shu_base_number_model.dart';
import '../../utils/utils.dart' as gua_utils;
import '../../utils/yuan_tang_gua_helper.dart';
import 'yuan_tang_strategy.dart';
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';

/// 先后天卦取数计算参数
///
/// 包含执行先后天卦取数所需的所有参数
class XianHoutianQuShuStrategyParams extends BaseCalculationParams {
  /// 四柱信息
  final EightChars eightChars;

  /// 性别（"男" / "女"）
  final String gender;

  /// 三元（"上" / "中" / "下"）
  final String threeYuan;

  /// 出生节气后（"夏至" / "冬至"）
  final String birthAfterZhi;

  XianHoutianQuShuStrategyParams({
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
    required this.birthAfterZhi,
  });

  @override
  String get description =>
      "先后天卦取数计算参数：四柱(${eightChars.year.name} ${eightChars.month.name} ${eightChars.day.name} ${eightChars.time.name})，性别($gender)，三元($threeYuan)，节气($birthAfterZhi)";
}

/// 先后天卦取数计算策略
///
/// 实现先后天卦取数的标准计算策略
///
/// 算法原理：
/// 1. 排四柱
/// 2. 根据元堂卦法取先天卦和后天卦
/// 3. 计算先天基础数（四位拼接）：上卦先天数为千位、下卦先天数为百位、互卦上卦先天数为十位、互卦下卦先天数为个位
/// 4. 计算后天基础数（四位拼接）：上卦后天数为千位、下卦后天数为百位、互卦上卦后天数为十位、互卦下卦后天数为个位
/// 5. 条文扩展：基础数使用±48×倍数扩展：±96, ±192, ±384, ±768（倍数为2,4,8,16），得到8个数
/// 6. （可选）对先天卦与后天卦进行六爻纳甲与干支和数计算，作为参考
class XianHoutianQuShuStrategy
    extends
        StandardCalculationStrategy<
          XianHoutianQuShuStrategyParams,
          BaseNumberModelResult
        > {
  @override
  String get name => "先后天卦取数";

  @override
  String get description =>
      "根据元堂卦法取先天卦和后天卦：先天基础数按四位拼接（上卦先天数为千位、下卦先天数为百位、互卦上卦先天数为十位、互卦下卦先天数为个位）；后天基础数按四位拼接（上卦后天数为千位、下卦后天数为百位、互卦上卦后天数为十位、互卦下卦后天数为个位）。并保留六爻纳甲与干支和数作为参考，最终对基础数进行±48×倍数扩展";

  @override
  List<String> get detailSteps => [
    "1. 排四柱：获取年月日时的干支信息",
    "2. 元堂卦法：生成天地卦并取先天卦与后天卦",
    "3. 计算先天基础数：四位拼接（上卦先天数→千位、下卦先天数→百位、互卦上卦先天数→十位、互卦下卦先天数→个位）",
    "4. 计算后天基础数：四位拼接（上卦后天数→千位、下卦后天数→百位、互卦上卦后天数→十位、互卦下卦后天数→个位）",
    "5. （可选）六爻纳甲：为两卦配置天干地支并计算每爻干支太玄数之和，提供参考",
    "6. 条文扩展：先天与后天基础数分别使用±48×倍数扩展（2,4,8,16），各得到8个条文编号",
  ];

  @override
  String get school => "先后天卦取数流派";

  @override
  BaseNumberModelResult calculate(XianHoutianQuShuStrategyParams params) {
    try {
      // 步骤1-2：生成天地卦和先天卦（使用YuanTangGuaHelper）
      final (
        tianGua,
        diGua,
        ganNumList,
        zhiNumList,
        oddNumTotal,
        evenNumTotal,
        tianGuaNum,
        diGuaNum,
        usedThreeYuanWuGong,
      ) = YuanTangGuaHelper.generateTianDiGua(
        eightChars: params.eightChars,
        gender: params.gender,
        threeYuan: params.threeYuan,
      );

      final (
        yearYinYang,
        upperGua,
        lowerGua,
        xiantianGua,
        xiantianUpperGuaNumber,
        xiantianLowerGuaNumber,
      ) = YuanTangGuaHelper.generateXiantianGua(
        eightChars: params.eightChars,
        gender: params.gender,
        tianGua: tianGua,
        diGua: diGua,
      );

      // 步骤3：元堂装卦（获取元堂爻）
      final (
        yuantangYaoIndex,
        yuantangYaoLabel,
        zhiList,
        timeGanzhi,
        timeYinYang,
        totalYangYao,
        totalYinYao,
      ) = YuanTangGuaHelper.yuantangZhuanggua(
        eightChars: params.eightChars,
        xiantianGua: xiantianGua,
        gender: params.gender,
        birthAfterZhi: params.birthAfterZhi,
      );

      // 步骤4：生成后天卦（元堂爻变 + 上下卦互换）
      final birthMonth = YuanTangStrategyParams.getMonthNumberFromZhi(
        params.eightChars.month.zhi.name,
      );
      final (
        houtianGua,
        houtianUpperGuaNumber,
        houtianLowerGuaNumber,
      ) = YuanTangGuaHelper.generateHoutianGua(
        xiantianGua: xiantianGua,
        yuantangYaoIndex: yuantangYaoIndex,
        birthMonth: birthMonth,
      );

      // 步骤3-4：先天卦六爻纳甲和干支和数计算
      final (
        xiantianBaseNumberByLiuYao,
        xiantianYaoTianGanList,
        xiantianYaoDiZhiList,
        xiantianYaoSumList,
        xiantianUpperSum,
        xiantianLowerSum,
      ) = _calculateLiuYaoSum(
        xiantianGua,
      );

      // 使用"取先天卦，上卦先天数为千位，下卦先天数为百位，互卦上卦先天数为十位，互卦下卦先天数为个位"公式重算先天基础数
      final xiantianBaseNumber = _calculateXiantianBaseNumberByGua(xiantianGua);

      // 步骤5-6：后天卦六爻纳甲和干支和数计算
      final (
        houtianBaseNumberByLiuYao,
        houtianYaoTianGanList,
        houtianYaoDiZhiList,
        houtianYaoSumList,
        houtianUpperSum,
        houtianLowerSum,
      ) = _calculateLiuYaoSum(
        houtianGua,
      );

      // 使用“取后天卦，上卦后天数为千位，下卦后天数为百位，互卦上卦后天数为十位，互卦下卦后天数为个位”公式重算后天基础数
      final houtianBaseNumber = _calculateHoutianBaseNumberByGua(houtianGua);

      // 创建数据模型
      final model = XianHoutianQuShuBaseNumberModel.create(
        baseNumber: xiantianBaseNumber, // 使用先天卦基础数作为主基础数（也可以选择后天卦）
        name: "先后天卦取数",
        description:
            "先后天卦取数计算（性别:${params.gender}，三元:${params.threeYuan}，节气:${params.birthAfterZhi}）",
        source: BaseNumberSource.yearZhu, // 使用yearZhu作为来源标识
        eightChars: params.eightChars,
        gender: params.gender,
        threeYuan: params.threeYuan,
        birthAfterZhi: params.birthAfterZhi,
        // 天地卦字段
        ganNumList: ganNumList,
        zhiNumList: zhiNumList,
        oddNumTotal: oddNumTotal,
        evenNumTotal: evenNumTotal,
        tianGuaNum: tianGuaNum,
        diGuaNum: diGuaNum,
        tianGua: tianGua,
        diGua: diGua,
        usedThreeYuanWuGong: usedThreeYuanWuGong,
        // 先后天卦字段
        yearYinYang: yearYinYang,
        upperGua: upperGua,
        lowerGua: lowerGua,
        xiantianGua: xiantianGua,
        houtianGua: houtianGua,
        xiantianUpperGuaNumber: xiantianUpperGuaNumber,
        xiantianLowerGuaNumber: xiantianLowerGuaNumber,
        houtianUpperGuaNumber: houtianUpperGuaNumber,
        houtianLowerGuaNumber: houtianLowerGuaNumber,
        // 先天卦六爻纳甲字段
        xiantianYaoTianGanList: xiantianYaoTianGanList,
        xiantianYaoDiZhiList: xiantianYaoDiZhiList,
        xiantianYaoSumList: xiantianYaoSumList,
        xiantianUpperSum: xiantianUpperSum,
        xiantianLowerSum: xiantianLowerSum,
        xiantianBaseNumber: xiantianBaseNumber,
        // 后天卦六爻纳甲字段
        houtianYaoTianGanList: houtianYaoTianGanList,
        houtianYaoDiZhiList: houtianYaoDiZhiList,
        houtianYaoSumList: houtianYaoSumList,
        houtianUpperSum: houtianUpperSum,
        houtianLowerSum: houtianLowerSum,
        houtianBaseNumber: houtianBaseNumber,
      );

      return BaseNumberModelResult.success(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        baseNumbers: [model],
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'gender': params.gender,
          'threeYuan': params.threeYuan,
          'birthAfterZhi': params.birthAfterZhi,
          'xiantianGua': xiantianGua,
          'houtianGua': houtianGua,
          'xiantianBaseNumber': xiantianBaseNumber,
          'houtianBaseNumber': houtianBaseNumber,
        },
      );
    } catch (e, stackTrace) {
      return BaseNumberModelResult.error(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        errorMessage: "先后天卦取数计算失败: $e",
        sourceData: {
          'error': e.toString(),
          'stackTrace': stackTrace.toString(),
          'params': params.description,
        },
      );
    }
  }

  /// 为六爻配置天干（纳甲）
  ///
  /// 使用传统六爻纳甲规则：
  /// - 内卦（下卦）使用 innerGuaYaoTianGan
  /// - 外卦（上卦）使用 outerGuaYaoTianGan
  ///
  /// [guaName] 卦名（如"震坤"）
  ///
  /// 返回: `List<String>` (6个天干，从初爻到上爻)
  List<String> _najiaTianGan(String guaName) {
    // 拆分成上下卦
    final upperGuaName = guaName[0];
    final lowerGuaName = guaName[1];

    // 转换为Enum8Gua
    final Enum8Gua upperGua = _stringToEnum8Gua(upperGuaName);
    final Enum8Gua lowerGua = _stringToEnum8Gua(lowerGuaName);

    // 获取纳甲天干配置
    final List<TianGan> lowerTianGanList =
        constants.innerGuaYaoTianGan[lowerGua]!; // 内卦（下卦）
    final List<TianGan> upperTianGanList =
        constants.outerGuaYaoTianGan[upperGua]!; // 外卦（上卦）

    // 组合成六爻（从初爻到上爻：下卦3爻 + 上卦3爻）
    final result = <String>[];
    for (var tianGan in lowerTianGanList) {
      result.add(tianGan.name);
    }
    for (var tianGan in upperTianGanList) {
      result.add(tianGan.name);
    }

    return result;
  }

  /// 为六爻配置地支（纳甲）
  ///
  /// 使用传统六爻纳甲规则：
  /// - 内卦（下卦）使用 innerGuaYaoDiZhi
  /// - 外卦（上卦）使用 outerGuaYaoDiZhi
  ///
  /// [guaName] 卦名（如"震坤"）
  ///
  /// 返回: `List<String>` (6个地支，从初爻到上爻)
  List<String> _najiaDiZhi(String guaName) {
    // 拆分成上下卦
    final upperGuaName = guaName[0];
    final lowerGuaName = guaName[1];

    // 转换为Enum8Gua
    final Enum8Gua upperGua = _stringToEnum8Gua(upperGuaName);
    final Enum8Gua lowerGua = _stringToEnum8Gua(lowerGuaName);

    // 获取纳甲地支配置
    final List<DiZhi> lowerDiZhiList =
        constants.innerGuaYaoDiZhi[lowerGua]!; // 内卦（下卦）
    final List<DiZhi> upperDiZhiList =
        constants.outerGuaYaoDiZhi[upperGua]!; // 外卦（上卦）

    // 组合成六爻（从初爻到上爻：下卦3爻 + 上卦3爻）
    final result = <String>[];
    for (var diZhi in lowerDiZhiList) {
      result.add(diZhi.name);
    }
    for (var diZhi in upperDiZhiList) {
      result.add(diZhi.name);
    }

    return result;
  }

  /// 获取天干或地支的太玄数
  ///
  /// [ganOrZhi] 天干或地支字符串
  /// 返回: int (太玄数 1-10，但实际映射范围是4-9)
  int _getTaixuanNumber(String ganOrZhi) {
    // 优先尝试天干映射
    if (constants.taixuanGanNumberMapper.containsKey(ganOrZhi)) {
      return constants.taixuanGanNumberMapper[ganOrZhi]!;
    }

    // 尝试地支映射
    if (constants.taixuanZhiNumberMapper.containsKey(ganOrZhi)) {
      return constants.taixuanZhiNumberMapper[ganOrZhi]!;
    }

    // 如果都不存在，抛出异常
    throw ArgumentError('无法找到 $ganOrZhi 对应的太玄数');
  }

  /// 计算单爻干支太玄数之和
  ///
  /// 规则：天干太玄数 + 地支太玄数，如果和==10则返回0（不计）
  ///
  /// [tianGan] 天干字符串
  /// [diZhi] 地支字符串
  /// 返回: int (如果和==10则返回0，否则返回和)
  int _calculateYaoGanZhiSum(String tianGan, String diZhi) {
    final ganNum = _getTaixuanNumber(tianGan);
    final zhiNum = _getTaixuanNumber(diZhi);
    final sum = ganNum + zhiNum;

    // 和为10不计
    if (sum == 10) {
      return 0;
    }

    return sum;
  }

  /// 计算六爻干支和数，组成四位数
  ///
  /// 步骤：
  /// 1. 调用 _najiaTianGan() 获取六个天干
  /// 2. 调用 _najiaDiZhi() 获取六个地支
  /// 3. 对每一爻调用 _calculateYaoGanZhiSum()
  /// 4. 上三爻（4-6爻，即索引3-5）和数作为千百位
  /// 5. 下三爻（1-3爻，即索引0-2）和数作为十位个位
  /// 6. 组合成四位基础数
  ///
  /// [guaName] 卦名（如"震坤"）
  /// 返回: (baseNumber, tianGanList, diZhiList, yaoSumList, upperSum, lowerSum)
  (int, List<String>, List<String>, List<int>, int, int) _calculateLiuYaoSum(
    String guaName,
  ) {
    // 步骤1-2：获取六爻纳甲配置
    final tianGanList = _najiaTianGan(guaName);
    final diZhiList = _najiaDiZhi(guaName);

    // 步骤3：计算每一爻的干支和数
    final yaoSumList = <int>[];
    for (var i = 0; i < 6; i++) {
      final sum = _calculateYaoGanZhiSum(tianGanList[i], diZhiList[i]);
      yaoSumList.add(sum);
    }

    // 步骤4：下三爻（初、二、三爻，索引0-2）和数作为十位个位
    final lowerSum = yaoSumList[0] + yaoSumList[1] + yaoSumList[2];

    // 步骤5：上三爻（四、五、上爻，索引3-5）和数作为千百位
    final upperSum = yaoSumList[3] + yaoSumList[4] + yaoSumList[5];

    // 步骤6：组合成四位基础数
    // 千百位（上三爻） + 十位个位（下三爻）
    final baseNumber = upperSum * 100 + lowerSum;

    return (baseNumber, tianGanList, diZhiList, yaoSumList, upperSum, lowerSum);
  }

  /// 先天基础数拼接：
  /// 千位=上卦先天数，百位=下卦先天数，十位=互卦上卦先天数，个位=互卦下卦先天数
  int _calculateXiantianBaseNumberByGua(String guaName) {
    final upper = guaName[0];
    final lower = guaName[1];
    final huGua = gua_utils.guaToHuGua(guaName);
    final huUpper = huGua[0];
    final huLower = huGua[1];

    final thousands = constants.xianTianGuaNumberMapper[upper]!;
    final hundreds = constants.xianTianGuaNumberMapper[lower]!;
    final tens = constants.xianTianGuaNumberMapper[huUpper]!;
    final ones = constants.xianTianGuaNumberMapper[huLower]!;

    return thousands * 1000 + hundreds * 100 + tens * 10 + ones;
  }

  /// 后天基础数拼接：
  /// 千位=上卦后天数，百位=下卦后天数，十位=互卦上卦后天数，个位=互卦下卦后天数
  int _calculateHoutianBaseNumberByGua(String guaName) {
    final upper = guaName[0];
    final lower = guaName[1];
    final huGua = gua_utils.guaToHuGua(guaName);
    final huUpper = huGua[0];
    final huLower = huGua[1];

    final thousands = constants.houTianGuaNumberMapper[upper]!;
    final hundreds = constants.houTianGuaNumberMapper[lower]!;
    final tens = constants.houTianGuaNumberMapper[huUpper]!;
    final ones = constants.houTianGuaNumberMapper[huLower]!;

    return thousands * 1000 + hundreds * 100 + tens * 10 + ones;
  }

  /// 获取默认的条文计算配置
  ///
  /// 先天卦和后天卦都使用±48×倍数扩展：±96, ±192, ±384, ±768（倍数为2,4,8,16）
  /// 每个卦生成8个条文编号
  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    return GenericTiaoWenCalculationConfig.addSub48x(multiples: [2, 4, 8, 16]);
  }

  /// 计算条文列表（使用指定配置）
  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    XianHoutianQuShuStrategyParams params,
    TiaoWenCalculationConfig config,
  ) {
    if (config is GenericTiaoWenCalculationConfig) {
      // 使用calculationList进行递加
      return config.calculationList
          .map((offset) => baseNumber + offset)
          .toList();
    }
    // 降级处理：直接返回基础数
    return [baseNumber];
  }

  /// 获取支持的条文计算配置选项
  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs {
    return [defaultTiaoWenCalculationConfig];
  }

  @override
  String get tiaoWenCalculationDescription =>
      defaultTiaoWenCalculationConfig.description;

  // ========== 辅助方法 ==========

  /// 将卦名字符串转换为Enum8Gua枚举
  Enum8Gua _stringToEnum8Gua(String guaName) {
    switch (guaName) {
      case "乾":
        return Enum8Gua.Qian;
      case "坤":
        return Enum8Gua.Kun;
      case "震":
        return Enum8Gua.Zhen;
      case "巽":
        return Enum8Gua.Xun;
      case "坎":
        return Enum8Gua.Kan;
      case "离":
        return Enum8Gua.Li;
      case "艮":
        return Enum8Gua.Gen;
      case "兑":
        return Enum8Gua.Dui;
      default:
        throw ArgumentError('未知的卦名: $guaName');
    }
  }
}
