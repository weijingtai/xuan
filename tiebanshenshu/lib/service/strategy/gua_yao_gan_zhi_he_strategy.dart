/// GuaYaoGanZhiHe Calculation Strategy
///
/// Hexagram Yao Heavenly Stems and Earthly Branches Sum Method
/// Calculates base numbers from Four Pillars using Gua and NaJia mappings
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';

import '../../features/six_yao_gua/pure_six_yao_gua.dart';
import '../../features/six_yao_gua/six_yao_calculator.dart';
import '../../domain/models/base_number_model.dart';
import '../../domain/models/base_number_model_result.dart';
import '../../domain/models/gua_yao_gan_zhi_he_base_number_model.dart';
import '../../constant/constants.dart' as constants;
import 'gua_yao_gan_zhi_he_result.dart';
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';

/// 卦爻干支和数法
/// 1. 排四柱
/// 2. 根据天干配卦和日柱配卦诀分别将四柱干支配卦，干为上卦，支为下卦，得出年月日时四卦
/// 3. 四卦分别“纳甲”
/// 4. 将每一爻干支进行太玄取数，每爻的干支太玄数分别相加。得到一爻的“数”
/// 5. 上卦三爻和数，三数相加为上卦和数，下卦三爻和数，三数相加为下卦和数；如果某一爻干支相加为‘10’则舍弃这个数
/// 6. 将上卦和数作为千位与百位，将下卦和数作为十位个位，这样四柱一共得到四个四位数，根据这四个四位数获得对应的条文内容。
/// Strategy parameters for GuaYaoGanZhiHe calculation
class GuaYaoGanZhiHeStrategyParams extends BaseCalculationParams {
  /// Eight Characters (Four Pillars) input
  final EightChars eightChars;

  /// NaJia method to use
  final GuaYaoGanZhiHeNaJiaMethod naJiaMethod;

  GuaYaoGanZhiHeStrategyParams({
    required this.eightChars,
    required this.naJiaMethod,
  });

  @override
  String get description =>
      "GuaYaoGanZhiHe Params: ${eightChars.toString()}, Method: ${naJiaMethod.displayName}";
}

/// GuaYaoGanZhiHe Calculation Strategy
///
/// Implements the Hexagram Yao Gan-Zhi Sum algorithm:
/// 1. Map each pillar's Gan+Zhi to 64 Gua
/// 2. Install NaJia for all 6 yaos
/// 3. Calculate TaiXuan sums for each yao (filtering sum=10)
/// 4. Generate base number: upperSum*100 + lowerSum
class GuaYaoGanZhiHeStrategy extends StandardCalculationStrategy<
    GuaYaoGanZhiHeStrategyParams, BaseNumberModelResult> {

  @override
  String get name => "GuaYaoGanZhiHe Method";

  @override
  String get description =>
      "Hexagram Yao Heavenly Stems and Earthly Branches Sum Method";

  @override
  String get school => "GuaYaoGanZhiHe School";

  @override
  List<String> get detailSteps => [
    "1. Map each pillar's Gan+Zhi to 64 Gua",
    "2. Install NaJia for all 6 yaos using specified method",
    "3. Calculate TaiXuan sums for each yao",
    "4. Filter yaos where Gan+Zhi sum equals 10",
    "5. Generate base number: upperSum*100 + lowerSum",
  ];

  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    return GenericTiaoWenCalculationConfig.customList(
      name: "卦爻干支和数法无扩展配置",
      description: "不扩展条文列表，直接使用基础数作为条文编号",
      customList: [0],
      withSub: false,
    );
  }

  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs {
    return [defaultTiaoWenCalculationConfig];
  }

  @override
  String get tiaoWenCalculationDescription =>
      defaultTiaoWenCalculationConfig.description;

  @override
  BaseNumberModelResult calculate(GuaYaoGanZhiHeStrategyParams params) {
    try {
      final fourPillars = [
        ('Year', params.eightChars.year),
        ('Month', params.eightChars.month),
        ('Day', params.eightChars.day),
        ('Time', params.eightChars.time),
      ];

      final baseNumbers = <BaseNumberModel>[];

      // Determine isYangYear for yearGanYinYang method
      final isYangYear = params.naJiaMethod == GuaYaoGanZhiHeNaJiaMethod.yearGanYinYang
          ? params.eightChars.year.gan.isYang
          : null;

      for (final (pillarName, jiaZi) in fourPillars) {
        // Get gua64 from Gan+Zhi mapping
        final ganGua = constants.tianGanGuaMapper[jiaZi.gan]!;
        final zhiGua = constants.diZhiGuaMapper[jiaZi.zhi]!;
        final gua64 = Enum64Gua.getBy8Gua(ganGua, zhiGua);

        // Calculate using static method
        final result = calculateFromGua64(
          gua64,
          params.naJiaMethod,
          isYangYear,
        );

        // Build BaseNumberModel
        final model = GuaYaoGanZhiHeBaseNumberModel(
          pillarName: pillarName,
          ganzhi: jiaZi,
          naJiaMethod: params.naJiaMethod,
          gua64: gua64,
          upperGua: result.upperGua,
          lowerGua: result.lowerGua,
          yaoDetails: result.yaoDetails,
          lowerGuaSum: result.lowerGuaSum,
          upperGuaSum: result.upperGuaSum,
          formula: result.formula,
          calculationDetail: result.description,
          baseNumber: result.tiaoWenNumber,
          name: '$pillarName-${params.naJiaMethod.displayName}',
          description: result.description,
          source: BaseNumberSource.yearZhu,
          tiaoWenNumbers: [result.tiaoWenNumber],
          tiaoWenDataList: const [], // Will be filled by UseCase
        );

        baseNumbers.add(model);
      }

      return BaseNumberModelResult(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: 'EightChars: ${params.eightChars}, Method: ${params.naJiaMethod.displayName}',
        baseNumbers: baseNumbers,
        calculationTime: DateTime.now(),
        sourceData: {
          'eightChars': params.eightChars.toString(),
          'naJiaMethod': params.naJiaMethod.toString(),
        },
      );
    } catch (e, stackTrace) {
      return BaseNumberModelResult.error(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.toString(),
        errorMessage: 'Calculation failed: $e',
        sourceData: {
          'error': e.toString(),
          'stackTrace': stackTrace.toString(),
        },
      );
    }
  }

  /// Static method for KaoKe integration
  ///
  /// Calculates GuaYaoGanZhiHe result directly from a 64 Gua
  /// [gua64] The 64 Gua to calculate from
  /// [naJiaMethod] NaJia assignment method to use
  /// [isYangYear] Required for yearGanYinYang method, ignored for innerOuterGua
  static GuaYaoGanZhiHeResult calculateFromGua64(
    Enum64Gua gua64,
    GuaYaoGanZhiHeNaJiaMethod naJiaMethod,
    bool? isYangYear,
  ) {
    // Create PureSixYaoGua from 64 Gua
    final pureSixYaoGua = PureSixYaoGua.by8Gua(gua64.top, gua64.bottom);

    // Install NaJia based on method
    _installNaJia(pureSixYaoGua, gua64.top, gua64.bottom, naJiaMethod, isYangYear);

    // Calculate sums and get yao details
    final (yaoDetails, calcLowerSum, calcUpperSum) = _calculateSums(pureSixYaoGua);

    // Generate base number
    final baseNumber = calcUpperSum * 100 + calcLowerSum;

    // Build formula string
    final formula = '${gua64.top.name}${gua64.bottom.name}: $calcUpperSum*100 + $calcLowerSum = $baseNumber';

    // Build description
    final description = '64Gua: ${gua64.name}, Method: ${naJiaMethod.displayName}, '
        'LowerSum: $calcLowerSum, UpperSum: $calcUpperSum';

    return GuaYaoGanZhiHeResult(
      pureSixYaoGua: pureSixYaoGua,
      gua64: gua64,
      upperGua: gua64.top,
      lowerGua: gua64.bottom,
      yaoDetails: yaoDetails,
      lowerGuaSum: calcLowerSum,
      upperGuaSum: calcUpperSum,
      formula: formula,
      tiaoWenNumber: baseNumber,
      naJiaMethod: naJiaMethod,
      description: description,
    );
  }

  /// Install NaJia for all yaos based on the specified method
  static void _installNaJia(
    PureSixYaoGua gua,
    Enum8Gua upperGua,
    Enum8Gua lowerGua,
    GuaYaoGanZhiHeNaJiaMethod naJiaMethod,
    bool? isYangYear,
  ) {
    switch (naJiaMethod) {
      case GuaYaoGanZhiHeNaJiaMethod.yearGanYinYang:
        _installNaJiaByYearGan(gua, upperGua, lowerGua, isYangYear!);
        break;
      case GuaYaoGanZhiHeNaJiaMethod.innerOuterGua:
        _installNaJiaByInnerOuter(gua, upperGua, lowerGua);
        break;
    }
  }

  /// Install NaJia using year Gan yin-yang method
  ///
  /// - Gan mapping: Uses innerGuaYaoTianGan for lower gua, outerGuaYaoTianGan for upper gua
  /// - Zhi mapping: Uses INNER-OUTER gua method (same as innerOuterGua method)
  /// - Year yin-yang parameter is not used in this method (kept for interface compatibility)
  static void _installNaJiaByYearGan(
    PureSixYaoGua gua,
    Enum8Gua upperGua,
    Enum8Gua lowerGua,
    bool isYangYear,
  ) {
    // Get Gan mappings for inner and outer gua
    final List<TianGan> lowerGuaGan = constants.innerGuaYaoTianGan[lowerGua]!;
    final List<TianGan> upperGuaGan = constants.outerGuaYaoTianGan[upperGua]!;

    // Combine: upper gua Gan (3 yaos) + lower gua Gan (3 yaos), top->bottom order
    final ganListTopBottom = [...upperGuaGan, ...lowerGuaGan];

    // Use traditional inner-outer gua for Zhi mapping
    final zhiListTopBottom = SixYaoCalculator.najiaZhuangGua(gua.gua);

    // Reverse to get bottom->top order (matching yaoList indexing)
    final ganListBottomTop = ganListTopBottom.reversed.toList();
    final zhiListBottomTop = zhiListTopBottom.reversed.toList();

    for (int i = 0; i < 6; i++) {
      final yao = gua.yaoList[i];
      yao.naJia = ganListBottomTop[i];
      yao.naZhi = zhiListBottomTop[i];
    }
  }

  /// Install NaJia using traditional inner-outer gua method
  ///
  /// Both Gan and Zhi mappings use inner-outer gua
  static void _installNaJiaByInnerOuter(
    PureSixYaoGua gua,
    Enum8Gua upperGua,
    Enum8Gua lowerGua,
  ) {
    // Use SixYaoCalculator to get Gan list (top->bottom order)
    final ganListTopBottom = SixYaoCalculator.najiaGanZhuangGua(gua.gua);

    // Use SixYaoCalculator to get Zhi list (top->bottom order)
    final zhiListTopBottom = SixYaoCalculator.najiaZhuangGua(gua.gua);

    // Reverse to get bottom->top order (matching yaoList indexing)
    final ganListBottomTop = ganListTopBottom.reversed.toList();
    final zhiListBottomTop = zhiListTopBottom.reversed.toList();

    for (int i = 0; i < 6; i++) {
      final yao = gua.yaoList[i];
      yao.naJia = ganListBottomTop[i];
      yao.naZhi = zhiListBottomTop[i];
    }
  }

  /// Calculate sums for six yaos, filtering those where sum equals 10
  ///
  /// Returns: (yaoDetails, lowerSum, upperSum)
  static (List<GuaYaoGanZhiHeYaoDetail>, int, int) _calculateSums(
    PureSixYaoGua gua,
    {bool filterSum10 = true}  // Add parameter to control filtering
  ) {
    final yaoDetails = <GuaYaoGanZhiHeYaoDetail>[];
    int lowerSum = 0;
    int upperSum = 0;

    for (int i = 0; i < 6; i++) {
      final yao = gua.yaoList[i];

      // Get TaiXuan numbers
      final ganNum = constants.taiXuanGanNumberMapper[yao.naJia]!;
      final zhiNum = constants.taiXuanZhiNumberMapper[yao.naZhi]!;
      final sum = ganNum + zhiNum;

      // Check if filtered (sum equals 10)
      final isFiltered = filterSum10 && (sum == 10);

      // Add to sums if not filtered
      if (!isFiltered) {
        if (i < 3) {
          lowerSum += sum;
        } else {
          upperSum += sum;
        }
      }

      // Create yao detail
      final yaoDetail = GuaYaoGanZhiHeYaoDetail(
        yaoPosition: i,
        yaoPositionName: yao.order.name,
        yinYang: yao.yinYang,
        naTianGan: yao.naJia!,
        naDiZhi: yao.naZhi!,
        ganTaiXuanNumber: ganNum,
        zhiTaiXuanNumber: zhiNum,
        yaoSum: sum,
        isFiltered: isFiltered,
      );

      yaoDetails.add(yaoDetail);
    }

    return (yaoDetails, lowerSum, upperSum);
  }
}
