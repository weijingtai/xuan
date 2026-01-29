/// 先后天八卦加则法Strategy实现(重构版)
///
/// 继承自 YuanTangBasedStrategy，复用元堂卦计算逻辑
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/enums.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_calculator.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_info.dart';
import 'package:tiebanshenshu/features/yuan_tang_gua/yuan_tang_info_ext.dart';

import '../../domain/models/base_number_model.dart';
import '../../domain/models/base_number_model_result.dart';
import '../../domain/models/xian_houtian_gua_base_number_model.dart';
import '../../utils/tiao_wen_calculator.dart';
import 'base/yuan_tang_based_strategy.dart';
import 'base/yuan_tang_derived_params.dart';
import 'base_calculation_strategy.dart';

/// 先后天八卦加则法计算参数
///
/// 继承自 YuanTangDerivedParams，支持两种计算模式：
/// 1. 从头计算：提供 EightChars + Gender + YuanYunOrder + TwentyFourJieQi
/// 2. 复用计算：提供已计算好的 YuanTangInfo
class XianHoutianJiaZeStrategyParams extends YuanTangDerivedParams {
  @override
  final EightChars eightChars;

  @override
  final Gender gender;

  @override
  final YuanYunOrder threeYuan;

  @override
  final TwentyFourJieQi birthAfterZhi;

  @override
  final YuanTangMonthType monthType;

  @override
  final CalanderType calanderType;

  @override
  YuanTangInfo? yuanTangInfo;

  XianHoutianJiaZeStrategyParams({
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
    required this.birthAfterZhi,
    this.monthType = YuanTangMonthType.monthYinYan,
    this.calanderType = CalanderType.solar,
    this.yuanTangInfo,
  });

  /// 从 YuanTangInfo 直接创建参数（复用模式）
  factory XianHoutianJiaZeStrategyParams.fromYuanTangInfo(
    YuanTangInfo yuanTangInfo, {
    required EightChars eightChars,
    required Gender gender,
    required YuanYunOrder threeYuan,
    required TwentyFourJieQi birthAfterZhi,
  }) {
    return XianHoutianJiaZeStrategyParams(
      eightChars: eightChars,
      gender: gender,
      threeYuan: threeYuan,
      birthAfterZhi: birthAfterZhi,
      yuanTangInfo: yuanTangInfo,
    );
  }
}

/// 先后天八卦加则法计算策略(重构版)
///
/// 继承自 YuanTangBasedStrategy，消除了重复的元堂卦计算代码
///
/// 计算步骤：
/// 1. 获取 YuanTangInfo（懒加载或复用）
/// 2. 从 YuanTangInfo 提取先天卦和后天卦
/// 3. 先天卦加则法计算基础数
/// 4. 后天卦加则法计算基础数
/// 5. 条文扩展：先天卦递增96四次，后天卦递减96四次
///
/// 算法特点：
/// - 复用 YuanTangInfo 计算结果，避免重复计算
/// - 先天卦和后天卦分别计算基础数
/// - 先天卦使用递增扩展，后天卦使用递减扩展
class XianHoutianJiaZeStrategy extends YuanTangBasedStrategy<
    XianHoutianJiaZeStrategyParams, BaseNumberModelResult> {
  @override
  String get name => "先后天八卦加则法";

  @override
  String get description =>
      "基于元堂卦信息，使用加则法计算先后天卦基础数，先天卦递增96四次，后天卦递减96四次";

  @override
  List<String> get detailSteps => [
        "1. 获取元堂卦信息（包含天地卦、先天卦、后天卦、元堂爻等）",
        "2. 先天卦加则法：使用加则法计算基础数",
        "3. 后天卦加则法：使用加则法计算基础数",
        "4. 条文扩展：先天卦递增96四次[0,96,192,288,384]，后天卦递减96四次[0,-96,-192,-288,-384]",
      ];

  @override
  String get school => "先后天八卦加则法流派";

  @override
  BaseNumberModelResult calculateWithYuanTangInfo(
    XianHoutianJiaZeStrategyParams params,
    YuanTangInfo yuanTangInfo,
  ) {
    // 步骤1：从 YuanTangInfo 提取先天卦和后天卦
    final xiantianGua = getXiantianGua(yuanTangInfo);
    final houtianGua = getHoutianGua(yuanTangInfo);

    // 步骤2：计算先天卦互卦
    final xiantianGuaHu = yuanTangInfo.xianTanGua.hu;

    // 步骤3：计算后天卦互卦
    final houtianGuaHu = yuanTangInfo.houTianGua.hu;

    // 步骤4：先天卦加则法计算基础数
    // ignore: deprecated_member_use_from_same_package
    final xiantianBaseNumber = TiaowenCalculator.getTiaowenNumberByJiaZe(
      xiantianGua,
    );

    // 步骤5：后天卦加则法计算基础数
    // ignore: deprecated_member_use_from_same_package
    final houtianBaseNumber = TiaowenCalculator.getTiaowenNumberByJiaZe(
      houtianGua,
    );

    // 步骤6：条文扩展
    // 先天卦：递增96四次
    final xiantianConfig = GenericTiaoWenCalculationConfig.increment96x4();
    final xiantianTiaoWenNumbers = xiantianConfig.calculateTiaoWenList(
      xiantianBaseNumber,
      {},
    );
    final xiantianCalculationFormula =
        "先天卦基础数$xiantianBaseNumber + [0, 96, 192, 288, 384] = $xiantianTiaoWenNumbers";

    // 后天卦：递减96四次
    final houtianConfig = GenericTiaoWenCalculationConfig.decrement96x4();
    final houtianTiaoWenNumbers = houtianConfig.calculateTiaoWenList(
      houtianBaseNumber,
      {},
    );
    final houtianCalculationFormula =
        "后天卦基础数$houtianBaseNumber + [0, -96, -192, -288, -384] = $houtianTiaoWenNumbers";

    // 步骤7：创建 XianHoutianGuaBaseNumberModel
    // 从 YuanTangInfo 中提取天地卦数据
    if (yuanTangInfo.tianDiGuaData == null) {
      throw StateError(
        '天地卦数据不存在，请确保 YuanTangCalculator.calculate() 正确返回了 tianDiGuaData',
      );
    }

    final tianDiGuaDataSource = yuanTangInfo.tianDiGuaData!;
    final tianDiGuaData = yuanTangInfo.toBaseNumberModel(
      tianDiGuaData: tianDiGuaDataSource,
      tiaowenNumbers: TiaowenNumbers(
        jiazeXiantian: xiantianBaseNumber,
        jiazeHoutian: houtianBaseNumber,
        najiaTaixuanXiantian: 0,
        najiaTaixuanHoutian: 0,
        benhuXiantian: 0,
        benhuHoutian: 0,
        guahuListXiantian: [],
        guahuListHoutian: [],
      ),
      baseNumber: xiantianBaseNumber,
      name: name,
      description: description,
      source: BaseNumberSource.yearZhu,
    );

    final xianHoutianModel = XianHoutianGuaBaseNumberModel(
      baseNumber: xiantianBaseNumber,
      name: "先后天八卦加则法",
      description:
          "先后天八卦加则法计算（性别:${params.gender}，三元:${params.threeYuan}，节气:${params.birthAfterZhi}）",
      source: BaseNumberSource.yearZhu,
      // 输入参数
      eightChars: params.eightChars,
      gender: params.gender,
      threeYuan: params.threeYuan,
      birthAfterZhi: params.birthAfterZhi,
      // 步骤1: 天地卦（从YuanTangInfo提取）
      ganNumList: tianDiGuaData.ganNumList,
      zhiNumList: tianDiGuaData.zhiNumList,
      oddNumTotal: tianDiGuaData.oddNumTotal,
      evenNumTotal: tianDiGuaData.evenNumTotal,
      tianGuaNum: tianDiGuaData.tianGuaNum,
      diGuaNum: tianDiGuaData.diGuaNum,
      tianGua: tianDiGuaData.tianGua,
      diGua: tianDiGuaData.diGua,
      usedThreeYuanWuGong: tianDiGuaData.usedThreeYuanWuGong,
      // 步骤2: 先后天卦
      yearYinYang: tianDiGuaData.yearYinYang,
      upperGua: yuanTangInfo.xianTanGua.gua.top,
      lowerGua: yuanTangInfo.xianTanGua.gua.bottom,
      xiantianGua: xiantianGua,
      houtianGua: houtianGua,
      xiantianUpperGuaNumber: tianDiGuaData.xiantianUpperGuaNumber,
      xiantianLowerGuaNumber: tianDiGuaData.xiantianLowerGuaNumber,
      houtianUpperGuaNumber: tianDiGuaData.houtianUpperGuaNumber,
      houtianLowerGuaNumber: tianDiGuaData.houtianLowerGuaNumber,
      // 步骤3: 互卦
      xiantianGuaHu: xiantianGuaHu,
      houtianGuaHu: houtianGuaHu,
      // 步骤4: 基础数
      xiantianBaseNumber: xiantianBaseNumber,
      houtianBaseNumber: houtianBaseNumber,
      // 步骤5: 条文扩展
      xiantianTiaoWenNumbers: xiantianTiaoWenNumbers,
      houtianTiaoWenNumbers: houtianTiaoWenNumbers,
      xiantianCalculationFormula: xiantianCalculationFormula,
      houtianCalculationFormula: houtianCalculationFormula,
    );

    return BaseNumberModelResult.success(
      algorithmName: name,
      algorithmDescription: description,
      calculationParams: params.description,
      baseNumbers: [xianHoutianModel],
      sourceData: {
        'eightChars': params.eightChars.toString(),
        'gender': params.gender,
        'threeYuan': params.threeYuan,
        'birthAfterZhi': params.birthAfterZhi,
        'tianGua': tianDiGuaData.tianGua,
        'diGua': tianDiGuaData.diGua,
        'xiantianGua': xiantianGua,
        'houtianGua': houtianGua,
        'xiantianBaseNumber': xiantianBaseNumber,
        'houtianBaseNumber': houtianBaseNumber,
        'calculationMode': getCalculationModeDescription(params),
      },
    );
  }

  @override
  BaseNumberModelResult handleError(
    XianHoutianJiaZeStrategyParams params,
    Object error,
    StackTrace stackTrace,
  ) {
    return BaseNumberModelResult.error(
      algorithmName: name,
      algorithmDescription: description,
      calculationParams: params.description,
      errorMessage: "先后天八卦加则法计算失败: $error",
      sourceData: {
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
        'params': params.description,
      },
    );
  }

  /// 获取默认的条文计算配置
  ///
  /// 先后天八卦加则法使用自定义列表配置：
  /// - 先天卦：递增96四次 [0, 96, 192, 288, 384]
  /// - 后天卦：递减96四次 [0, -96, -192, -288, -384]
  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    // 返回先天卦的递增配置作为默认配置
    return GenericTiaoWenCalculationConfig.increment96x4();
  }

  /// 计算条文列表（使用指定配置）
  ///
  /// 注意：在先后天八卦加则法中，需要分别处理先天卦和后天卦的条文扩展
  /// 此方法仅用于单一基础数的扩展
  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    XianHoutianJiaZeStrategyParams params,
    TiaoWenCalculationConfig config,
  ) {
    return config.calculateTiaoWenList(baseNumber, {});
  }

  /// 获取支持的条文计算配置选项
  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs {
    return [
      GenericTiaoWenCalculationConfig.increment96x4(),
      GenericTiaoWenCalculationConfig.decrement96x4(),
      GenericTiaoWenCalculationConfig.customList(
        name: "自定义列表",
        description: "使用自定义偏移量列表",
        customList: [0],
        withSub: false,
      ),
    ];
  }

  @override
  String get tiaoWenCalculationDescription =>
      "先天卦递增96四次，后天卦递减96四次，分别生成5个条文编号";
}
