/// 先后天八卦加则法Strategy实现
///
/// 将先后天八卦加则法算法封装为标准计算策略
library;

import '../../domain/four_zhu.dart';
import '../../domain/models/base_number_model.dart';
import '../../domain/models/base_number_model_result.dart';
import '../../domain/models/xian_houtian_gua_base_number_model.dart';
import '../../utils/utils.dart' as gua_utils;
import '../../utils/tiao_wen_calculator.dart';
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';

/// 先后天八卦加则法计算参数
///
/// 包含执行先后天八卦加则法所需的所有参数
class XianHoutianJiaZeStrategyParams extends BaseCalculationParams {
  /// 四柱信息
  final FourZhu fourZhu;

  /// 性别（"男" / "女"）
  final String gender;

  /// 三元（"上" / "中" / "下"）
  final String threeYuan;

  /// 出生节气后（"夏至" / "冬至"）
  final String birthAfterZhi;

  XianHoutianJiaZeStrategyParams({
    required this.fourZhu,
    required this.gender,
    required this.threeYuan,
    required this.birthAfterZhi,
  });

  @override
  String get description =>
      "先后天八卦加则法计算参数：四柱(${fourZhu.yearGanzhi} ${fourZhu.monthGanzhi} ${fourZhu.dayGanzhi} ${fourZhu.timeGanzhi})，性别($gender)，三元($threeYuan)，节气($birthAfterZhi)";
}

/// 先后天八卦加则法计算策略
///
/// 实现先后天八卦加则法的标准计算策略
///
/// 计算步骤：
/// 1. 生成天地卦（使用GuaUtils.generateTianDiGua）
/// 2. 生成先后天卦（使用GuaUtils.generateXiantianGua）
/// 3. 计算先天卦互卦
/// 4. 计算后天卦互卦
/// 5. 先天卦加则法计算基础数
/// 6. 后天卦加则法计算基础数
/// 7. 条文扩展：先天卦递增96四次，后天卦递减96四次
///
/// 算法特点：
/// - 复用GuaUtils工具类进行天地卦和先后天卦生成
/// - 先天卦和后天卦分别计算基础数
/// - 先天卦使用递增扩展，后天卦使用递减扩展
class XianHoutianJiaZeStrategy extends StandardCalculationStrategy<
    XianHoutianJiaZeStrategyParams, BaseNumberModelResult> {
  @override
  String get name => "先后天八卦加则法";

  @override
  String get description =>
      "基于天地卦生成先后天卦，使用加则法计算先后天卦基础数，先天卦递增96四次，后天卦递减96四次";

  @override
  List<String> get detailSteps => [
        "1. 生成天地卦：四柱天干数列表、四柱地支数列表，计算奇数和、偶数和，模运算得天数、地数，配天卦、地卦",
        "2. 生成先后天卦：根据年份阴阳和性别决定上下卦位置，形成先天卦和后天卦",
        "3. 计算先天卦互卦：由先天卦2,3,4爻（上互）和3,4,5爻（下互）组成",
        "4. 计算后天卦互卦：由后天卦2,3,4爻（上互）和3,4,5爻（下互）组成",
        "5. 先天卦加则法：使用加则法计算先天卦基础数",
        "6. 后天卦加则法：使用加则法计算后天卦基础数",
        "7. 条文扩展：先天卦递增96四次[0,96,192,288,384]，后天卦递减96四次[0,-96,-192,-288,-384]",
      ];

  @override
  String get school => "先后天八卦加则法流派";

  @override
  BaseNumberModelResult calculate(XianHoutianJiaZeStrategyParams params) {
    try {
      // 步骤1：生成天地卦（使用GuaUtils工具方法）
      final yearYinYang = params.fourZhu.isYangGanYear ? "阳" : "阴";

      final (tianGua, diGua, ganNumList, zhiNumList, oddNumTotal, evenNumTotal,
              tianGuaNum, diGuaNum, usedThreeYuanWuGong) =
          gua_utils.generateTianDiGua(
        yearGan: params.fourZhu.yearGan,
        monthGan: params.fourZhu.monthGan,
        dayGan: params.fourZhu.dayGan,
        timeGan: params.fourZhu.timeGan,
        yearZhi: params.fourZhu.yearZhi,
        monthZhi: params.fourZhu.monthZhi,
        dayZhi: params.fourZhu.dayZhi,
        timeZhi: params.fourZhu.timeZhi,
        yearYinYang: yearYinYang,
        gender: params.gender,
        threeYuan: params.threeYuan,
      );

      // 步骤2：生成先后天卦（使用GuaUtils工具方法）
      // 注意：在先后天八卦加则法中，先天卦和后天卦是同一个卦
      // 这里的"后天卦"仅用于数据模型的完整性，实际上与先天卦相同
      final (xiantianGua, upperGua, lowerGua, xiantianUpperGuaNumber,
              xiantianLowerGuaNumber) =
          gua_utils.generateXiantianGua(
        tianGua: tianGua,
        diGua: diGua,
        yearYinYang: yearYinYang,
        gender: params.gender,
      );

      // 在先后天八卦加则法中，后天卦等于先天卦（不涉及爻变）
      final houtianGua = xiantianGua;
      final houtianUpperGuaNumber = xiantianUpperGuaNumber;
      final houtianLowerGuaNumber = xiantianLowerGuaNumber;

      // 步骤3：计算先天卦互卦
      final xiantianGuaHu = gua_utils.guaToHuGua(xiantianGua);

      // 步骤4：计算后天卦互卦（实际上与先天卦互卦相同）
      final houtianGuaHu = gua_utils.guaToHuGua(houtianGua);

      // 步骤5：先天卦加则法计算基础数
      // ignore: deprecated_member_use_from_same_package
      final xiantianBaseNumber =
          TiaowenCalculator.getTiaowenNumberByJiaZe(xiantianGua);

      // 步骤6：后天卦加则法计算基础数（实际上与先天卦基础数相同）
      // ignore: deprecated_member_use_from_same_package
      final houtianBaseNumber =
          TiaowenCalculator.getTiaowenNumberByJiaZe(houtianGua);

      // 步骤7：条文扩展
      // 先天卦：递增96四次
      final xiantianConfig = GenericTiaoWenCalculationConfig.increment96x4();
      final xiantianTiaoWenNumbers =
          xiantianConfig.calculateTiaoWenList(xiantianBaseNumber, {});
      final xiantianCalculationFormula =
          "先天卦基础数$xiantianBaseNumber + [0, 96, 192, 288, 384] = $xiantianTiaoWenNumbers";

      // 后天卦：递减96四次
      final houtianConfig = GenericTiaoWenCalculationConfig.decrement96x4();
      final houtianTiaoWenNumbers =
          houtianConfig.calculateTiaoWenList(houtianBaseNumber, {});
      final houtianCalculationFormula =
          "后天卦基础数$houtianBaseNumber + [0, -96, -192, -288, -384] = $houtianTiaoWenNumbers";

      // 创建 XianHoutianGuaBaseNumberModel
      final baseNumber = xiantianBaseNumber; // 使用先天卦基础数作为主基础数

      final xianHoutianModel = XianHoutianGuaBaseNumberModel(
        baseNumber: baseNumber,
        name: "先后天八卦加则法",
        description:
            "先后天八卦加则法计算（性别:${params.gender}，三元:${params.threeYuan}，节气:${params.birthAfterZhi}）",
        source: BaseNumberSource.yearZhu, // 使用yearZhu作为来源标识
        // 输入参数
        fourZhu: params.fourZhu,
        gender: params.gender,
        threeYuan: params.threeYuan,
        birthAfterZhi: params.birthAfterZhi,
        // 步骤1: 天地卦
        ganNumList: ganNumList,
        zhiNumList: zhiNumList,
        oddNumTotal: oddNumTotal,
        evenNumTotal: evenNumTotal,
        tianGuaNum: tianGuaNum,
        diGuaNum: diGuaNum,
        tianGua: tianGua,
        diGua: diGua,
        usedThreeYuanWuGong: usedThreeYuanWuGong,
        // 步骤2: 先后天卦
        yearYinYang: yearYinYang,
        upperGua: upperGua,
        lowerGua: lowerGua,
        xiantianGua: xiantianGua,
        houtianGua: houtianGua,
        xiantianUpperGuaNumber: xiantianUpperGuaNumber,
        xiantianLowerGuaNumber: xiantianLowerGuaNumber,
        houtianUpperGuaNumber: houtianUpperGuaNumber,
        houtianLowerGuaNumber: houtianLowerGuaNumber,
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
          'fourZhu': params.fourZhu.toString(),
          'gender': params.gender,
          'threeYuan': params.threeYuan,
          'birthAfterZhi': params.birthAfterZhi,
          'tianGua': tianGua,
          'diGua': diGua,
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
        errorMessage: "先后天八卦加则法计算失败: $e",
        sourceData: {
          'error': e.toString(),
          'stackTrace': stackTrace.toString(),
          'params': params.description
        },
      );
    }
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
