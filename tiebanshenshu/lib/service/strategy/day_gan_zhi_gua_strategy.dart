/// 日柱变卦取数法Strategy实现
///
/// 将日柱变卦取数法算法封装为标准计算策略
library;

import 'package:common/enums.dart';

import '../../constant/constants.dart' as Constants;
import '../../features/six_yao_gua/pure_six_yao_gua.dart';
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';
import '../../domain/models/base_number_model_result.dart';
import '../../domain/models/base_number_model.dart';
import 'tiao_wen_list_calculation.dart';

/// 日柱变卦取数法计算参数
///
/// 包含执行日柱变卦取数法所需的所有参数
class DayGanZhiGuaStrategyParams extends BaseCalculationParams {
  /// 四柱信息
  final JiaZi dayGanZhi;

  DayGanZhiGuaStrategyParams({required this.dayGanZhi});

  @override
  String get description => "日柱变卦取数法计算参数：四柱信息(${dayGanZhi})";
}

// 日柱变卦取数法现在使用MultiBaseNumberResult
// 不再需要单独的DayGanZhiGuaStrategyResult类

/// 日柱变卦取数法计算结果
///
/// 包含日柱变卦取数法的计算结果，主要结果为条文编号
// class DayGanZhiGuaStrategyResult extends BaseCalculationResult {
//   /// 主要结果：条文编号
//   final int tiaoWenNumber;

//   /// 四柱信息
//   final FourZhu fourZhu;

//   /// 日干
//   final String dayGan;

//   /// 日支
//   final String dayZhi;

//   /// 基本卦名
//   final String baseGuaName;

//   /// 互卦名
//   final String huGuaName;

//   /// 基本数
//   final int baseNumber;

//   const DayGanZhiGuaStrategyResult({
//     required this.tiaoWenNumber,
//     required this.fourZhu,
//     required this.dayGan,
//     required this.dayZhi,
//     required this.baseGuaName,
//     required this.huGuaName,
//     required this.baseNumber,
//   });

//   @override
//   String get summary =>
//       "日柱变卦取数法结果：条文编号 $tiaoWenNumber（日柱：$dayGan$dayZhi，基本卦：$baseGuaName，互卦：$huGuaName）";
// }

/// 日柱变卦取数法计算策略
///
/// 实现日柱变卦取数法的标准计算策略
class DayGanZhiGuaStrategy
    extends
        StandardCalculationStrategy<
          DayGanZhiGuaStrategyParams,
          BaseNumberModelResult
        > {
  @override
  String get name => "日柱变卦取数法";

  @override
  String get description => "以日干为下卦、日支为上卦组成基本卦，计算互卦，结合后天和先天卦数得到条文编号";

  @override
  List<String> get detailSteps => [
    "1. 提取日柱：从四柱中获取日干和日支",
    "2. 组成基本卦：日干为下卦，日支为上卦",
    "3. 计算互卦：根据基本卦计算互卦",
    "4. 计算基本数：结合后天卦数和先天卦数",
    "5. 计算条文编号：根据基本数计算最终条文编号",
  ];

  @override
  String get school => "日柱变卦流派";

  /// 获取默认的条文计算配置
  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    return GenericTiaoWenCalculationConfig.customList(
      name: "日柱变卦标准配置",
      description: "基础数±1000：±1000",
      customList: [0, 1000],
      withSub: true,
    );
  }

  /// 计算条文列表（使用指定配置）
  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    DayGanZhiGuaStrategyParams params,
    TiaoWenCalculationConfig config,
  ) {
    // 构建计算上下文
    final context = <String, dynamic>{
      'dayGanZhi': params.dayGanZhi,
      'baseNumber': baseNumber,
    };

    return config.calculateTiaoWenList(baseNumber, context);
  }

  /// 获取支持的条文计算配置选项
  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs {
    return [
      GenericTiaoWenCalculationConfig.customList(
        name: "日柱变卦标准配置",
        description: "基础数±1000：±1000",
        customList: [0, 1000],
        withSub: true,
      ),
      GenericTiaoWenCalculationConfig.customList(
        name: "日柱变卦简化配置",
        description: "仅基础数：无变化",
        customList: [0],
        withSub: false,
      ),
      GenericTiaoWenCalculationConfig.customList(
        name: "日柱变卦扩展配置",
        description: "基础数±500、±1000、±2000：多层变化",
        customList: [0, 500, 1000, 2000],
        withSub: true,
      ),
    ];
  }

  @override
  String get tiaoWenCalculationDescription =>
      defaultTiaoWenCalculationConfig.description;

  @override
  BaseNumberModelResult calculate(DayGanZhiGuaStrategyParams params) {
    try {
      final dayGanzhi = params.dayGanZhi;

      // 计算基本卦：日支为上卦，日干为下卦
      final Enum8Gua dayDownGu = Constants.tianGanGuaMapper[dayGanzhi.gan]!;
      final Enum8Gua dayUpGu = Constants.diZhiGuaMapper[dayGanzhi.zhi]!;
      // 第一卦
      final PureSixYaoGua pure = PureSixYaoGua.by8Gua(dayUpGu, dayDownGu);

      // 第二卦
      // 计算互卦：第一卦的互卦为第二卦
      final Enum64Gua huGua = pure.hu;

      // 计算基本数：组合四位数
      final baseNumber = _calculateBaseNumber(pure.gua, huGua);

      // 创建基础数模型
      final baseNumberModel = BaseNumberModel.create(
        baseNumber: baseNumber,
        name: "日柱变卦数",
        description:
            "日柱${dayGanzhi.name}变卦计算：基本卦${pure.gua.name}，互卦${huGua.name}，基础数$baseNumber",
        source: BaseNumberSource.dayZhu,
      );

      return BaseNumberModelResult.success(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        baseNumbers: [baseNumberModel],
        sourceData: {
          'dayGanzhi': dayGanzhi.name,
          'dayGan': dayGanzhi.gan.name,
          'dayZhi': dayGanzhi.zhi.name,
          'dayDownGua': dayDownGu.name,
          'dayUpGua': dayUpGu.name,
          'baseGua': pure.gua.name,
          'huGua': huGua.name,
          'baseNumber': baseNumber,
          'calculation': {
            'firstUp': Constants.houGuaNumberMapper[pure.gua.top],
            'firstDown': Constants.houGuaNumberMapper[pure.gua.bottom],
            'secondUp': Constants.xianGuaNumberMapper[huGua.top],
            'secondDown': Constants.xianGuaNumberMapper[huGua.bottom],
          },
        },
      );
    } catch (e) {
      return BaseNumberModelResult.error(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        errorMessage: "日柱变卦计算失败: $e",
        sourceData: {'error': e.toString(), 'params': params.description},
      );
    }
  }

  /// 计算基本卦
  ///
  /// 日支为上卦，日干为下卦
  static Enum64Gua _calculateBaseGua(JiaZi dayGanzhi) {
    UnimplementedError("未完成");
    final Enum8Gua dayDownGu = Constants.tianGanGuaMapper[dayGanzhi.gan]!;
    final Enum8Gua dayUpGu = Constants.diZhiGuaMapper[dayGanzhi.zhi]!;
    final Enum64Gua baseGua = Enum64Gua.getBy8Gua(dayUpGu, dayDownGu);

    return baseGua;
  }

  /// 计算基本数
  ///
  /// 第一卦上卦【后天】数为千位，下卦【后天】数为百位；
  /// 第二卦上【先天】数为十位，下卦【先天】数为个位
  static int _calculateBaseNumber(Enum64Gua baseGua, Enum64Gua huGua) {
    final int firstUp = Constants.houGuaNumberMapper[baseGua.top]!;
    final int firstDown = Constants.houGuaNumberMapper[baseGua.bottom]!;

    final int secondUp = Constants.xianGuaNumberMapper[huGua.top]!;
    final int secondDown = Constants.xianGuaNumberMapper[huGua.bottom]!;

    return int.parse('$firstUp$firstDown$secondUp$secondDown');
  }
}
