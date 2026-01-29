/// 八卦加则取数法Strategy实现
///
/// 将八卦加则取数法算法封装为标准计算策略
/// 支持两种装卦方法：爻序法和纳甲法
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';

import '../../constant/constants.dart' as constants;
import '../../features/six_yao_gua/pure_six_yao_gua.dart';
import '../../domain/models/base_number_model.dart';
import '../../domain/models/base_number_model_result.dart';
import '../../domain/models/ba_gua_jia_ze_base_number_model.dart';
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';
import 'ba_gua_jia_ze_result.dart';

/// 八卦加则取数法计算参数
///
/// 包含执行八卦加则取数法所需的所有参数
class BaGuaJiaZeStrategyParams extends BaseCalculationParams {
  /// 八字信息
  final EightChars eightChars;

  BaGuaJiaZeStrategyParams({required this.eightChars});

  @override
  String get description =>
      "八卦加则取数法计算参数：八字信息(${eightChars.year.name} ${eightChars.month.name} ${eightChars.day.name} ${eightChars.time.name})";
}

/// 八卦加则取数法计算策略
///
/// 实现八卦加则取数法的标准计算策略
/// 四柱分别计算，每柱使用两种装卦方法（爻序法、纳甲法），产生8个基础数
class BaGuaJiaZeStrategy
    extends
        StandardCalculationStrategy<
          BaGuaJiaZeStrategyParams,
          BaseNumberModelResult
        > {
  @override
  String get name => "八卦加则取数法";

  @override
  String get description => "排四柱天干地支分别配卦，装配六爻地支，上卦数作千位加总数减下卦数得条文数";

  @override
  List<String> get detailSteps => [
    "1. 取四柱：获取年月日时的干支信息",
    "2. 干支配卦：天干为上卦，地支为下卦",
    "3. 装卦方法A-爻序法：阳爻依次配子寅辰午申戌，阴爻依次配丑卯巳未酉亥",
    "4. 装卦方法B-纳甲法：使用传统六爻纳甲规则（不区分年干阴阳）",
    "5. 六爻配数：每爻地支对应数字相加得总数",
    "6. 计算条文数：上卦后天数×1000 + 总数 - 下卦后天数",
    "7. 四柱各产生2个条文（爻序法1个+纳甲法1个），共8个条文",
  ];

  @override
  String get school => "八卦加则流派";

  /// 获取默认的条文计算配置（八卦加则不扩展条文列表）
  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    return GenericTiaoWenCalculationConfig.customList(
      name: "八卦加则无扩展配置",
      description: "不扩展条文列表，直接使用基础数作为条文编号",
      customList: [0],
      withSub: false,
    );
  }

  /// 计算条文列表（八卦加则不使用此功能）
  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    BaGuaJiaZeStrategyParams params,
    TiaoWenCalculationConfig config,
  ) {
    // 八卦加则不扩展条文列表，直接返回基础数
    return [baseNumber];
  }

  /// 获取支持的条文计算配置选项（八卦加则只有一种）
  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs {
    return [defaultTiaoWenCalculationConfig];
  }

  @override
  String get tiaoWenCalculationDescription =>
      defaultTiaoWenCalculationConfig.description;

  // ========== 公开的静态方法 ==========

  /// 使用爻序法计算八卦加则
  ///
  /// 只需传入64卦,返回完整的计算结果
  ///
  /// [gua64] 64卦枚举
  ///
  /// 返回: [BaGuaJiaZeResult] 包含六爻卦、中间结果和最终条文数
  static BaGuaJiaZeResult calculateByYaoSequenceFromGua64(Enum64Gua gua64) {
    // 从64卦提取上下卦
    final upperGua = gua64.top; // Enum8Gua
    final lowerGua = gua64.bottom; // Enum8Gua

    // 生成六爻卦
    final gua = PureSixYaoGua.by8Gua(upperGua, lowerGua);

    // 阳爻地支序列
    final yangDiZhi = [
      DiZhi.ZI,
      DiZhi.YIN,
      DiZhi.CHEN,
      DiZhi.WU,
      DiZhi.SHEN,
      DiZhi.XU,
    ];

    // 阴爻地支序列
    final yinDiZhi = [
      DiZhi.CHOU,
      DiZhi.MAO,
      DiZhi.SI,
      DiZhi.WEI,
      DiZhi.YOU,
      DiZhi.HAI,
    ];

    int yangIndex = 0;
    int yinIndex = 0;
    int sum = 0;

    // 从下到上装配地支（索引0是初爻，索引5是上爻）
    for (int i = 0; i < 6; i++) {
      final yao = gua.yaoList[i];
      DiZhi? diZhi;

      if (yao.yinYang == YinYang.YANG) {
        if (yangIndex < yangDiZhi.length) {
          diZhi = yangDiZhi[yangIndex++];
        }
      } else {
        if (yinIndex < yinDiZhi.length) {
          diZhi = yinDiZhi[yinIndex++];
        }
      }

      // 将地支配到爻上
      if (diZhi != null) {
        yao.naZhi = diZhi;
        // 累加数字
        sum += constants.yaoDiZhiNumberMapper[diZhi]!;
      }
    }

    // 计算基础数
    final upperNum = constants.houGuaNumberMapper[upperGua]!;
    final lowerNum = constants.houGuaNumberMapper[lowerGua]!;
    final baseNumber = upperNum * 1000 + sum - lowerNum;

    // 生成计算公式
    final formula = '${upperNum}000 + $sum - $lowerNum = $baseNumber';

    return BaGuaJiaZeResult(
      pureSixYaoGua: gua,
      upperGua: upperGua,
      lowerGua: lowerGua,
      upperGuaNumber: upperNum,
      lowerGuaNumber: lowerNum,
      yaoSum: sum,
      formula: formula,
      tiaoWenNumber: baseNumber,
      methodName: '爻序法',
      description: '${gua64.name}爻序法计算：上卦${upperGua.name}($upperNum)，下卦${lowerGua.name}($lowerNum)，六爻总和$sum',
    );
  }

  /// 使用纳甲法计算八卦加则
  ///
  /// 只需传入64卦,返回完整的计算结果
  ///
  /// [gua64] 64卦枚举
  ///
  /// 返回: [BaGuaJiaZeResult] 包含六爻卦、中间结果和最终条文数
  static BaGuaJiaZeResult calculateByNaJiaFromGua64(Enum64Gua gua64) {
    // 从64卦提取上下卦
    final upperGua = gua64.top; // Enum8Gua
    final lowerGua = gua64.bottom; // Enum8Gua

    // 生成六爻卦
    final gua = PureSixYaoGua.by8Gua(upperGua, lowerGua);

    int sum = 0;

    // 下卦纳支（初爻、二爻、三爻）
    for (var i = 0; i < 3; i++) {
      final diZhi = constants.innerGuaYaoDiZhi[lowerGua]![i];
      gua.yaoList[i].naZhi = diZhi;
      sum += constants.yaoDiZhiNumberMapper[diZhi]!;
    }

    // 上卦纳支（四爻、五爻、上爻）
    for (var i = 3; i < 6; i++) {
      final diZhi = constants.outerGuaYaoDiZhi[upperGua]![i - 3];
      gua.yaoList[i].naZhi = diZhi;
      sum += constants.yaoDiZhiNumberMapper[diZhi]!;
    }

    // 计算基础数
    final upperNum = constants.houGuaNumberMapper[upperGua]!;
    final lowerNum = constants.houGuaNumberMapper[lowerGua]!;
    final baseNumber = upperNum * 1000 + sum - lowerNum;

    // 生成计算公式
    final formula = '${upperNum}000 + $sum - $lowerNum = $baseNumber';

    return BaGuaJiaZeResult(
      pureSixYaoGua: gua,
      upperGua: upperGua,
      lowerGua: lowerGua,
      upperGuaNumber: upperNum,
      lowerGuaNumber: lowerNum,
      yaoSum: sum,
      formula: formula,
      tiaoWenNumber: baseNumber,
      methodName: '纳甲法',
      description: '${gua64.name}纳甲法计算：上卦${upperGua.name}($upperNum)，下卦${lowerGua.name}($lowerNum)，六爻总和$sum',
    );
  }

  // ========== 原有的私有方法 ==========

  @override
  BaseNumberModelResult calculate(BaGuaJiaZeStrategyParams params) {
    try {
      final results = <BaGuaJiaZeBaseNumberModel>[];

      // 四柱循环
      final pillars = [
        (params.eightChars.year, '年柱', BaseNumberSource.yearZhu),
        (params.eightChars.month, '月柱', BaseNumberSource.monthZhu),
        (params.eightChars.day, '日柱', BaseNumberSource.dayZhu),
        (params.eightChars.time, '时柱', BaseNumberSource.timeZhu),
      ];

      for (final (pillar, pillarName, source) in pillars) {
        // 干支配卦
        final upperGua = constants.tianGanGuaMapper[pillar.gan]!;
        final lowerGua = constants.diZhiGuaMapper[pillar.zhi]!;

        // 生成六爻卦（为每种方法创建独立副本）
        final guaForYaoSeq = PureSixYaoGua.by8Gua(upperGua, lowerGua);
        final guaForNaJia = PureSixYaoGua.by8Gua(upperGua, lowerGua);

        // 方案A: 爻序法
        final resultA = _calculateByYaoSequence(
          pillar,
          pillarName,
          source,
          guaForYaoSeq,
          upperGua,
          lowerGua,
        );
        results.add(resultA);

        // 方案B: 纳甲法
        final resultB = _calculateByNaJia(
          pillar,
          pillarName,
          source,
          guaForNaJia,
          upperGua,
          lowerGua,
        );
        results.add(resultB);
      }

      return BaseNumberModelResult.success(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        baseNumbers: results,
        sourceData: {
          'eightChars': {
            'year': params.eightChars.year.name,
            'month': params.eightChars.month.name,
            'day': params.eightChars.day.name,
            'time': params.eightChars.time.name,
          },
          'methodCount': 2,
          'pillarCount': 4,
          'totalResults': 8,
          'methods': ['爻序法', '纳甲法'],
        },
      );
    } catch (e) {
      return BaseNumberModelResult.error(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        errorMessage: "八卦加则计算失败: $e",
        sourceData: {'error': e.toString(), 'params': params.description},
      );
    }
  }

  /// 爻序法计算
  ///
  /// 阳爻依次配子寅辰午申戌，阴爻依次配丑卯巳未酉亥
  BaGuaJiaZeBaseNumberModel _calculateByYaoSequence(
    JiaZi pillar,
    String pillarName,
    BaseNumberSource source,
    PureSixYaoGua gua,
    Enum8Gua upperGua,
    Enum8Gua lowerGua,
  ) {
    // 阳爻地支序列
    final yangDiZhi = [
      DiZhi.ZI,
      DiZhi.YIN,
      DiZhi.CHEN,
      DiZhi.WU,
      DiZhi.SHEN,
      DiZhi.XU,
    ];

    // 阴爻地支序列
    final yinDiZhi = [
      DiZhi.CHOU,
      DiZhi.MAO,
      DiZhi.SI,
      DiZhi.WEI,
      DiZhi.YOU,
      DiZhi.HAI,
    ];

    int yangIndex = 0;
    int yinIndex = 0;
    int sum = 0;

    // 从下到上装配地支（索引0是初爻，索引5是上爻）
    for (int i = 0; i < 6; i++) {
      final yao = gua.yaoList[i];
      DiZhi? diZhi;

      if (yao.yinYang == YinYang.YANG) {
        if (yangIndex < yangDiZhi.length) {
          diZhi = yangDiZhi[yangIndex++];
        }
      } else {
        if (yinIndex < yinDiZhi.length) {
          diZhi = yinDiZhi[yinIndex++];
        }
      }

      // 将地支配到爻上
      if (diZhi != null) {
        yao.naZhi = diZhi;
        // 累加数字
        sum += constants.yaoDiZhiNumberMapper[diZhi]!;
      }
    }

    // 计算基础数
    final upperNum = constants.houGuaNumberMapper[upperGua]!;
    final lowerNum = constants.houGuaNumberMapper[lowerGua]!;
    final baseNumber = upperNum * 1000 + sum - lowerNum;

    // 生成计算公式
    final formula = '${upperNum}000 + $sum - $lowerNum = $baseNumber';

    return BaGuaJiaZeBaseNumberModel.create(
      baseNumber: baseNumber,
      name: '$pillarName-爻序法',
      description:
          '$pillarName${pillar.name}爻序法计算：上卦${upperGua.name}($upperNum)，下卦${lowerGua.name}($lowerNum)，六爻总和$sum',
      source: source,
      method: '爻序法',
      pillarName: pillarName,
      ganZhi: pillar,
      guaData: gua,
      upperGua: upperGua,
      lowerGua: lowerGua,
      upperGuaNumber: upperNum,
      lowerGuaNumber: lowerNum,
      yaoSum: sum,
      formula: formula,
    );
  }

  /// 纳甲法计算
  ///
  /// 使用传统六爻纳甲规则进行配置（不区分年干阴阳）
  BaGuaJiaZeBaseNumberModel _calculateByNaJia(
    JiaZi pillar,
    String pillarName,
    BaseNumberSource source,
    PureSixYaoGua gua,
    Enum8Gua upperGua,
    Enum8Gua lowerGua,
  ) {
    int sum = 0;

    // 下卦纳支（初爻、二爻、三爻）
    for (var i = 0; i < 3; i++) {
      final diZhi = constants.innerGuaYaoDiZhi[lowerGua]![i];
      gua.yaoList[i].naZhi = diZhi;
      sum += constants.yaoDiZhiNumberMapper[diZhi]!;
    }

    // 上卦纳支（四爻、五爻、上爻）
    for (var i = 3; i < 6; i++) {
      final diZhi = constants.outerGuaYaoDiZhi[upperGua]![i - 3];
      gua.yaoList[i].naZhi = diZhi;
      sum += constants.yaoDiZhiNumberMapper[diZhi]!;
    }

    // 计算基础数
    final upperNum = constants.houGuaNumberMapper[upperGua]!;
    final lowerNum = constants.houGuaNumberMapper[lowerGua]!;
    final baseNumber = upperNum * 1000 + sum - lowerNum;

    // 生成计算公式
    final formula = '${upperNum}000 + $sum - $lowerNum = $baseNumber';

    return BaGuaJiaZeBaseNumberModel.create(
      baseNumber: baseNumber,
      name: '$pillarName-纳甲法',
      description:
          '$pillarName${pillar.name}纳甲法计算：上卦${upperGua.name}($upperNum)，下卦${lowerGua.name}($lowerNum)，六爻总和$sum',
      source: source,
      method: '纳甲法',
      pillarName: pillarName,
      ganZhi: pillar,
      guaData: gua,
      upperGua: upperGua,
      lowerGua: lowerGua,
      upperGuaNumber: upperNum,
      lowerGuaNumber: lowerNum,
      yaoSum: sum,
      formula: formula,
    );
  }
}
