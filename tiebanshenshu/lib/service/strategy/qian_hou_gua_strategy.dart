/// 前后卦取数法Strategy实现
///
/// 将前后卦取数法算法封装为标准计算策略
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';

import '../../domain/models/base_number_model.dart';
import '../../domain/models/base_number_model_result.dart';
import '../../domain/models/qian_hou_gua_base_number_model.dart';
import '../../constant/constants.dart' as constants;
import '../../utils/tiao_wen_calculator.dart';
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';

/// 前后卦取数法计算参数
///
/// 包含执行前后卦取数法所需的所有参数
class QianHouGuaStrategyParams extends BaseCalculationParams {
  /// 四柱信息
  final EightChars eightChars;

  /// 性别（"男" / "女"）
  final Gender gender;

  /// 三元（"上" / "中" / "下"）
  final YuanYunOrder threeYuan;

  /// 出生节气后（"夏至" / "冬至"）
  final TwentyFourJieQi birthAfterZhi;

  QianHouGuaStrategyParams({
    required this.eightChars,
    required this.gender,
    required this.threeYuan,
    required this.birthAfterZhi,
  });

  @override
  String get description =>
      "前后卦取数法计算参数：四柱(${eightChars.year.ganZhiStr} ${eightChars.month.ganZhiStr} ${eightChars.day.ganZhiStr} ${eightChars.time.ganZhiStr})，性别($gender)，三元($threeYuan)，节气($birthAfterZhi)";
}

/// 前后卦取数法计算策略
///
/// 实现前后卦取数法的标准计算策略
///
/// 算法原理：
/// 1. 排四柱
/// 2. 四柱干支分别取太玄数
/// 3. 年柱和月柱相合化为前卦：年柱干支太玄数相加 mod 8 得上卦，月柱同理得下卦
/// 4. 日柱和时柱相合化为后卦：方法同年月柱
/// 5. 前后卦分别使用加则法计算基础数
/// 6. 前卦基础数递增96四次，后卦基础数递减96四次
/// 7. 得出8条条文
class QianHouGuaStrategy
    extends
        StandardCalculationStrategy<
          QianHouGuaStrategyParams,
          BaseNumberModelResult
        > {
  @override
  String get name => "前后卦取数法";

  @override
  String get description => "根据四柱干支太玄数，年月柱组合为前卦，日时柱组合为后卦，分别使用加则法计算基础数";

  @override
  List<String> get detailSteps => [
    "1. 排四柱：获取年月日时的干支信息",
    "2. 取太玄数：四柱干支分别取太玄数",
    "3. 年月柱化前卦：年柱干支太玄数相加 mod 8 得上卦，月柱同理得下卦",
    "4. 日时柱化后卦：日柱干支太玄数相加 mod 8 得上卦，时柱同理得下卦",
    "5. 前卦加则法：使用加则法计算前卦基础数",
    "6. 后卦加则法：使用加则法计算后卦基础数",
    "7. 条文扩展：前卦递增96四次（5个数），后卦递减96四次（5个数）",
  ];

  @override
  String get school => "前后卦取数流派";

  @override
  BaseNumberModelResult calculate(QianHouGuaStrategyParams params) {
    try {
      // 步骤1-2：获取四柱干支太玄数
      final yearGanNum =
          constants.taiXuanGanNumberMapper[params.eightChars.year.gan]!;
      final yearZhiNum =
          constants.taiXuanZhiNumberMapper[params.eightChars.year.zhi]!;
      final monthGanNum =
          constants.taiXuanGanNumberMapper[params.eightChars.month.gan]!;
      final monthZhiNum =
          constants.taiXuanZhiNumberMapper[params.eightChars.month.zhi]!;
      final dayGanNum =
          constants.taiXuanGanNumberMapper[params.eightChars.day.gan]!;
      final dayZhiNum =
          constants.taiXuanZhiNumberMapper[params.eightChars.day.zhi]!;
      final timeGanNum =
          constants.taiXuanGanNumberMapper[params.eightChars.time.gan]!;
      final timeZhiNum =
          constants.taiXuanZhiNumberMapper[params.eightChars.time.zhi]!;

      final ganNumList = [yearGanNum, monthGanNum, dayGanNum, timeGanNum];
      final zhiNumList = [
        [yearZhiNum],
        [monthZhiNum],
        [dayZhiNum],
        [timeZhiNum],
      ];

      // 步骤3：年月柱化前卦
      // 年柱：干支太玄数相加 mod 8，得后天卦数
      int yearSum = yearGanNum + yearZhiNum;
      int yearHouTianNum = yearSum % 8;
      if (yearHouTianNum == 0) yearHouTianNum = 8;

      // 月柱：干支太玄数相加 mod 8，得后天卦数
      int monthSum = monthGanNum + monthZhiNum;
      int monthHouTianNum = monthSum % 8;
      if (monthHouTianNum == 0) monthHouTianNum = 8;

      // 根据后天数查卦名
      final qianGuaUpperGua = constants.numberHouGuaMapper[yearHouTianNum]!;
      final qianGuaLowerGua = constants.numberHouGuaMapper[monthHouTianNum]!;
      final qianGuaName = Enum64Gua.getBy8Gua(qianGuaUpperGua, qianGuaLowerGua);

      // 步骤4：日时柱化后卦
      // 日柱：干支太玄数相加 mod 8，得后天卦数
      int daySum = dayGanNum + dayZhiNum;
      int dayHouTianNum = daySum % 8;
      if (dayHouTianNum == 0) dayHouTianNum = 8;

      // 时柱：干支太玄数相加 mod 8，得后天卦数
      int timeSum = timeGanNum + timeZhiNum;
      int timeHouTianNum = timeSum % 8;
      if (timeHouTianNum == 0) timeHouTianNum = 8;

      // 根据后天数查卦名
      final houGuaUpperGua = constants.numberHouGuaMapper[dayHouTianNum]!;
      final houGuaLowerGua = constants.numberHouGuaMapper[timeHouTianNum]!;
      final houGuaName = Enum64Gua.getBy8Gua(houGuaUpperGua, houGuaLowerGua);

      // 步骤5：前卦加则法计算基础数
      // ignore: deprecated_member_use_from_same_package
      final qianGuaBaseNumber = TiaowenCalculator.getTiaowenNumberByJiaZe(
        qianGuaName,
      );

      // 步骤6：后卦加则法计算基础数
      // ignore: deprecated_member_use_from_same_package
      final houGuaBaseNumber = TiaowenCalculator.getTiaowenNumberByJiaZe(
        houGuaName,
      );

      // 步骤7：条文扩展
      // 前卦：递增96四次 [0, 96, 192, 288, 384]
      final qianGuaTiaoWenNumbers = _generateQianGuaTiaoWenNumbers(
        qianGuaBaseNumber,
      );
      final qianGuaFormula = _buildQianGuaFormula(qianGuaBaseNumber);

      // 后卦：递减96四次 [0, -96, -192, -288, -384]
      final houGuaTiaoWenNumbers = _generateHouGuaTiaoWenNumbers(
        houGuaBaseNumber,
      );
      final houGuaFormula = _buildHouGuaFormula(houGuaBaseNumber);

      // 创建数据模型（复用原有Model结构）
      // 注意：这里的字段含义与原来不同，但保持接口兼容
      // final fullBaseNumber = qianGuaBaseNumber * 100 + houGuaBaseNumber;
      final model = QianHouGuaBaseNumberModel(
        baseNumber: -1,
        name: "前后卦取数法",
        description:
            "前后卦取数法计算（性别:${params.gender}，三元:${params.threeYuan}，节气:${params.birthAfterZhi}）",
        source: BaseNumberSource.yearZhu,
        eightChars: params.eightChars,
        gender: params.gender,
        threeYuan: params.threeYuan,
        birthAfterZhi: params.birthAfterZhi,
        // 干支太玄数（用于调试显示）
        ganNumList: ganNumList,
        zhiNumList: zhiNumList,
        oddNumTotal: 0, // 此算法不使用奇偶和
        evenNumTotal: 0,
        tianGuaNum: 0, // 此算法不使用天地卦
        diGuaNum: 0,
        tianGua: "不适用",
        diGua: "不适用",
        usedThreeYuanWuGong: false,
        // 先后天卦字段（复用字段名，实际是前后卦）
        yearYinYang: params.eightChars.year.gan.yinYang,
        upperGua: qianGuaUpperGua, // 前卦上卦
        lowerGua: qianGuaLowerGua, // 前卦下卦
        xiantianGua: qianGuaName, // 前卦
        houtianGua: houGuaName, // 后卦
        xiantianUpperGuaNumber: yearHouTianNum, // 前卦上卦后天数
        xiantianLowerGuaNumber: monthHouTianNum, // 前卦下卦后天数
        houtianUpperGuaNumber: dayHouTianNum, // 后卦上卦后天数
        houtianLowerGuaNumber: timeHouTianNum, // 后卦下卦后天数
        // 互卦（此算法不使用互卦）
        xiantianGuaHu: null,
        houtianGuaHu: null,
        // 前卦取数字段
        qianGuaName: qianGuaName,
        qianGuaUpperNumber: yearHouTianNum,
        qianGuaLowerNumber: monthHouTianNum,
        qianGuaBaseNumber: qianGuaBaseNumber,
        // 后卦取数字段
        houGuaName: houGuaName,
        houGuaUpperNumber: dayHouTianNum,
        houGuaLowerNumber: timeHouTianNum,
        houGuaBaseNumber: houGuaBaseNumber,
        // 条文扩展字段
        qianGuaTiaoWenNumbers: qianGuaTiaoWenNumbers,
        houGuaTiaoWenNumbers: houGuaTiaoWenNumbers,
        qianGuaCalculationFormula: qianGuaFormula,
        houGuaCalculationFormula: houGuaFormula,
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
          'qianGuaName': qianGuaName,
          'houGuaName': houGuaName,
          'qianGuaBaseNumber': qianGuaBaseNumber,
          'houGuaBaseNumber': houGuaBaseNumber,
          'fullBaseNumber': -1,
        },
      );
    } catch (e, stackTrace) {
      return BaseNumberModelResult.error(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        errorMessage: "前后卦取数法计算失败: $e",
        sourceData: {
          'error': e.toString(),
          'stackTrace': stackTrace.toString(),
          'params': params.description,
        },
      );
    }
  }

  /// 生成前卦条文编号列表
  ///
  /// 前卦递增96四次：[baseNumber, baseNumber+96, baseNumber+192, baseNumber+288, baseNumber+384]
  List<int> _generateQianGuaTiaoWenNumbers(int baseNumber) {
    return [
      baseNumber,
      baseNumber + 96,
      baseNumber + 192,
      baseNumber + 288,
      baseNumber + 384,
    ];
  }

  /// 生成后卦条文编号列表
  ///
  /// 后卦递减96四次：[baseNumber, baseNumber-96, baseNumber-192, baseNumber-288, baseNumber-384]
  List<int> _generateHouGuaTiaoWenNumbers(int baseNumber) {
    return [
      baseNumber,
      baseNumber - 96,
      baseNumber - 192,
      baseNumber - 288,
      baseNumber - 384,
    ];
  }

  /// 构建前卦计算公式
  String _buildQianGuaFormula(int baseNumber) {
    return "前卦基础数$baseNumber + [0, 96, 192, 288, 384]";
  }

  /// 构建后卦计算公式
  String _buildHouGuaFormula(int baseNumber) {
    return "后卦基础数$baseNumber + [0, -96, -192, -288, -384]";
  }

  /// 获取默认的条文计算配置
  ///
  /// 前卦：递增96四次
  /// 后卦：递减96四次
  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    return GenericTiaoWenCalculationConfig.customList(
      name: "前后卦递增减96",
      description: "前卦递增96四次，后卦递减96四次",
      customList: [0, 96, 192, 288, 384, -96, -192, -288, -384],
      withSub: false,
    );
  }

  /// 计算条文列表（使用指定配置）
  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    QianHouGuaStrategyParams params,
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
}
