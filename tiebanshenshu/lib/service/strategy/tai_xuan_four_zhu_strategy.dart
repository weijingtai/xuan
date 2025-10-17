/// 太玄取数法（1）Strategy实现
///
/// 将太玄取数法（1）算法封装为标准计算策略
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import '../../features/six_yao_gua/pure_six_yao_gua.dart';

import '../../constant/constants.dart' as Constants;
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';
import '../../domain/models/base_number_model_result.dart';
import '../../domain/models/base_number_model.dart';
import '../../domain/models/tai_xuan_base_number_model.dart';

/// 太玄取数法（1）计算参数
///
/// 包含执行太玄取数法（1）所需的所有参数
class TaiXuanFourZhuStrategyParams extends BaseCalculationParams {
  /// 四柱信息
  final EightChars eightChars;

  /// 纳甲方法（默认为年干阴阳纳甲）
  final TaiXuanNaJiaMethod naJiaMethod;

  TaiXuanFourZhuStrategyParams({
    required this.eightChars,
    this.naJiaMethod = TaiXuanNaJiaMethod.yearGanYinYang,
  });

  @override
  String get description =>
      "太玄取数法（1）计算参数：四柱信息(${eightChars.year.name} ${eightChars.month.name} ${eightChars.day.name} ${eightChars.time.name})，纳甲方法(${naJiaMethod.name})";
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
      final List<TaiXuanBaseNumberModel> results = [];

      // 四柱循环
      final pillars = [
        (params.eightChars.year, '年柱', BaseNumberSource.yearZhu),
        (params.eightChars.month, '月柱', BaseNumberSource.monthZhu),
        (params.eightChars.day, '日柱', BaseNumberSource.dayZhu),
        (params.eightChars.time, '时柱', BaseNumberSource.timeZhu),
      ];

      for (final (pillar, pillarName, source) in pillars) {
        TaiXuanBaseNumberModel result;

        // 根据纳甲方法选择计算逻辑
        switch (params.naJiaMethod) {
          case TaiXuanNaJiaMethod.yearGanYinYang:
            final isYangYear = params.eightChars.year.gan.isYang;
            result = _calculateByYearGanYinYang(
              pillar,
              pillarName,
              source,
              isYangYear,
            );
            break;

          case TaiXuanNaJiaMethod.innerOuterGua:
            result = _calculateByInnerOuterGua(pillar, pillarName, source);
            break;
        }

        results.add(result);
      }

      return BaseNumberModelResult.success(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        baseNumbers: results,
        sourceData: {
          'naJiaMethod': params.naJiaMethod.name,
          'eightChars': params.eightChars.toString(),
          'pillarCount': 4,
        },
      );
    } catch (e, stackTrace) {
      return BaseNumberModelResult.error(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        errorMessage: "太玄四柱计算失败: $e",
        sourceData: {
          'error': e.toString(),
          'stackTrace': stackTrace.toString(),
          'params': params.description,
        },
      );
    }
  }

  /// 年干阴阳纳甲法计算
  ///
  /// 根据年干阴阳决定纳甲天干配置
  /// - 阳年：使用 yangGuaYaoTianGan
  /// - 阴年：使用 yinGuaYaoTianGan
  ///
  /// [ganzhi] 当前柱的干支
  /// [pillarName] 柱名称（年柱/月柱/日柱/时柱）
  /// [source] 基础数来源
  /// [isYangYear] 是否为阳年
  TaiXuanBaseNumberModel _calculateByYearGanYinYang(
    JiaZi ganzhi,
    String pillarName,
    BaseNumberSource source,
    bool isYangYear,
  ) {
    // 步骤1: 获取天干对应的卦和地支对应的卦
    final Enum8Gua ganGua = Constants.tianGanGuaMapper[ganzhi.gan]!;
    final Enum8Gua zhiGua = Constants.diZhiGuaMapper[ganzhi.zhi]!;

    var pura = PureSixYaoGua.by8Gua(ganGua, zhiGua);

    // 步骤2: 根据年干阴阳选择天干配置
    final Map<Enum8Gua, List<TianGan>> ganMapper;
    if (isYangYear) {
      ganMapper = Constants.yangGuaYaoTianGan;
    } else {
      ganMapper = Constants.yinGuaYaoTianGan;
    }

    // 步骤3: 分别计算下卦和上卦
    final List<TaiXuanYaoDetail> yaoDetails = [];
    int lowerSum = 0;

    // 下卦纳甲纳支（初、二、三爻）
    for (var i = 0; i < 3; i++) {
      final yao = pura.yaoList[i];
      final tianGan = ganMapper[pura.bottomGua]![i];
      final diZhi = Constants.innerGuaYaoDiZhi[pura.bottomGua]![i];

      yao.naJia = tianGan;
      yao.naZhi = diZhi;

      final ganNum = Constants.taiXuanGanNumberMapper[tianGan]!;
      final zhiNum = Constants.taiXuanZhiNumberMapper[diZhi]!;
      final sum = ganNum + zhiNum;

      // 和为10则不计入总和
      if (sum != 10) {
        lowerSum += sum;
      }

      yaoDetails.add(
        TaiXuanYaoDetail(
          position: i,
          positionLabel: ['初', '二', '三'][i],
          tianGan: tianGan,
          diZhi: diZhi,
          taiXuanGanNumber: ganNum,
          taiXuanZhiNumber: zhiNum,
          taiXuanNumber: sum,
          yinYang: yao.yinYang == YinYang.YANG ? '阳' : '阴',
          isFiltered: sum == 10,
        ),
      );
    }

    // 上卦纳甲纳支（四、五、上爻）
    int upperSum = 0;

    for (var i = 3; i < 6; i++) {
      final yao = pura.yaoList[i];
      final tianGan = ganMapper[pura.topGua]![i - 3];
      final diZhi = Constants.outerGuaYaoDiZhi[pura.topGua]![i - 3];

      yao.naJia = tianGan;
      yao.naZhi = diZhi;

      final ganNum = Constants.taiXuanGanNumberMapper[tianGan]!;
      final zhiNum = Constants.taiXuanZhiNumberMapper[diZhi]!;
      final sum = ganNum + zhiNum;

      if (sum != 10) {
        upperSum += sum;
      }

      yaoDetails.add(
        TaiXuanYaoDetail(
          position: i,
          positionLabel: ['四', '五', '上'][i - 3],
          tianGan: tianGan,
          diZhi: diZhi,
          taiXuanGanNumber: ganNum,
          taiXuanZhiNumber: zhiNum,
          taiXuanNumber: sum,
          yinYang: yao.yinYang == YinYang.YANG ? '阳' : '阴',
          isFiltered: sum == 10,
        ),
      );
    }

    // 计算基础数
    final baseNumber = upperSum * 100 + lowerSum;

    // 后天卦数
    final upperGuaNumber = Constants.houGuaNumberMapper[ganGua]!;
    final lowerGuaNumber = Constants.houGuaNumberMapper[zhiGua]!;

    // 生成公式
    final formula = '上卦: $upperSum, 下卦: $lowerSum, 基础数: $baseNumber';

    return TaiXuanBaseNumberModel(
      baseNumber: baseNumber,
      name: '$pillarName-年干阴阳纳甲',
      description: '$pillarName${ganzhi.name}年干阴阳纳甲计算',
      source: source,
      pillarName: pillarName,
      ganzhi: ganzhi,
      upperGua: ganGua,
      lowerGua: zhiGua,
      upperGuaNumber: upperGuaNumber,
      lowerGuaNumber: lowerGuaNumber,
      naJiaMethod: TaiXuanNaJiaMethod.yearGanYinYang,
      upperGuaSum: upperSum,
      lowerGuaSum: lowerSum,
      yaoDetails: yaoDetails,
      formula: formula,
    );
  }

  /// 传统内外卦纳甲法计算
  ///
  /// 根据内外卦位置决定纳甲天干配置（传统六爻纳甲规则）
  /// - 内卦（下卦）：使用 innerGuaYaoTianGan
  /// - 外卦（上卦）：使用 outerGuaYaoTianGan
  ///
  /// [ganzhi] 当前柱的干支
  /// [pillarName] 柱名称（年柱/月柱/日柱/时柱）
  /// [source] 基础数来源
  TaiXuanBaseNumberModel _calculateByInnerOuterGua(
    JiaZi ganzhi,
    String pillarName,
    BaseNumberSource source,
  ) {
    // 步骤1: 获取天干对应的卦和地支对应的卦
    final Enum8Gua ganGua = Constants.tianGanGuaMapper[ganzhi.gan]!;
    final Enum8Gua zhiGua = Constants.diZhiGuaMapper[ganzhi.zhi]!;

    var pura = PureSixYaoGua.by8Gua(ganGua, zhiGua);

    // 步骤2: 使用传统内外卦纳甲规则（关键区别）
    // 内卦（下卦）使用 innerGuaYaoTianGan
    final Map<Enum8Gua, List<TianGan>> lowerGanMapper =
        Constants.innerGuaYaoTianGan;

    // 外卦（上卦）使用 outerGuaYaoTianGan
    final Map<Enum8Gua, List<TianGan>> upperGanMapper =
        Constants.outerGuaYaoTianGan;

    // 步骤3: 分别计算下卦和上卦
    final List<TaiXuanYaoDetail> yaoDetails = [];
    int lowerSum = 0;

    // 下卦纳甲纳支（初、二、三爻）
    for (var i = 0; i < 3; i++) {
      final yao = pura.yaoList[i];
      final tianGan = lowerGanMapper[pura.bottomGua]![i];
      final diZhi = Constants.innerGuaYaoDiZhi[pura.bottomGua]![i];

      yao.naJia = tianGan;
      yao.naZhi = diZhi;

      final ganNum = Constants.taiXuanGanNumberMapper[tianGan]!;
      final zhiNum = Constants.taiXuanZhiNumberMapper[diZhi]!;
      final sum = ganNum + zhiNum;

      if (sum != 10) {
        lowerSum += sum;
      }

      yaoDetails.add(
        TaiXuanYaoDetail(
          position: i,
          positionLabel: ['初', '二', '三'][i],
          tianGan: tianGan,
          diZhi: diZhi,
          taiXuanGanNumber: ganNum,
          taiXuanZhiNumber: zhiNum,
          taiXuanNumber: sum,
          yinYang: yao.yinYang == YinYang.YANG ? '阳' : '阴',
          isFiltered: sum == 10,
        ),
      );
    }

    // 上卦纳甲纳支（四、五、上爻）
    int upperSum = 0;

    for (var i = 3; i < 6; i++) {
      final yao = pura.yaoList[i];
      final tianGan = upperGanMapper[pura.topGua]![i - 3];
      final diZhi = Constants.outerGuaYaoDiZhi[pura.topGua]![i - 3];

      yao.naJia = tianGan;
      yao.naZhi = diZhi;

      final ganNum = Constants.taiXuanGanNumberMapper[tianGan]!;
      final zhiNum = Constants.taiXuanZhiNumberMapper[diZhi]!;
      final sum = ganNum + zhiNum;

      if (sum != 10) {
        upperSum += sum;
      }

      yaoDetails.add(
        TaiXuanYaoDetail(
          position: i,
          positionLabel: ['四', '五', '上'][i - 3],
          tianGan: tianGan,
          diZhi: diZhi,
          taiXuanGanNumber: ganNum,
          taiXuanZhiNumber: zhiNum,
          taiXuanNumber: sum,
          yinYang: yao.yinYang == YinYang.YANG ? '阳' : '阴',
          isFiltered: sum == 10,
        ),
      );
    }

    // 计算基础数
    final baseNumber = upperSum * 100 + lowerSum;

    // 后天卦数
    final upperGuaNumber = Constants.houGuaNumberMapper[ganGua]!;
    final lowerGuaNumber = Constants.houGuaNumberMapper[zhiGua]!;

    // 生成公式
    final formula = '上卦: $upperSum, 下卦: $lowerSum, 基础数: $baseNumber';

    return TaiXuanBaseNumberModel(
      baseNumber: baseNumber,
      name: '$pillarName-传统内外卦纳甲',
      description: '$pillarName${ganzhi.name}传统内外卦纳甲计算',
      source: source,
      pillarName: pillarName,
      ganzhi: ganzhi,
      upperGua: ganGua,
      lowerGua: zhiGua,
      upperGuaNumber: upperGuaNumber,
      lowerGuaNumber: lowerGuaNumber,
      naJiaMethod: TaiXuanNaJiaMethod.innerOuterGua,
      upperGuaSum: upperSum,
      lowerGuaSum: lowerSum,
      yaoDetails: yaoDetails,
      formula: formula,
    );
  }

  /// 获取默认的条文计算配置
  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    return GenericTiaoWenCalculationConfig.taiXuanStandard();
  }

  /// 计算条文列表（使用指定配置）
  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    TaiXuanFourZhuStrategyParams params,
    TiaoWenCalculationConfig config,
  ) {
    // 构建计算上下文
    final context = <String, dynamic>{'eightChars': params.eightChars};

    return config.calculateTiaoWenList(baseNumber, context);
  }

  /// 获取支持的条文计算配置选项
  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs {
    return [
      GenericTiaoWenCalculationConfig.taiXuanStandard(),
      GenericTiaoWenCalculationConfig.customList(
        name: "简化配置",
        description: "仅±96：±96",
        customList: [0, 96],
        withSub: true,
      ),
      GenericTiaoWenCalculationConfig.customList(
        name: "扩展配置",
        description: "基础数分别各±96六次：±96、±192、±384、±768、±1536、±3072",
        customList: [0, 96, 192, 384, 768, 1536, 3072],
        withSub: true,
      ),
    ];
  }

  @override
  String get tiaoWenCalculationDescription =>
      defaultTiaoWenCalculationConfig.description;
}
