/// 四柱天干取数法Strategy实现
///
/// 将四柱天干取数法算法封装为标准计算策略
library;

import 'package:common/models/eight_chars.dart';
import '../../constant/constants.dart' as Constants;
import '../../utils/tiao_wen_calculator.dart';
import 'base_calculation_strategy.dart';
import 'standard_calculation_strategy.dart';
import '../../domain/models/base_number_model_result.dart';
import '../../domain/models/base_number_model.dart';
import 'tiao_wen_list_calculation.dart';

/// 四柱天干取数法计算参数
///
/// 包含执行四柱天干取数法所需的所有参数
class FourZhuTianGanStrategyParams extends BaseCalculationParams {
  /// 四柱信息
  final EightChars eightChars;

  FourZhuTianGanStrategyParams({required this.eightChars});

  @override
  String get description =>
      "四柱天干取数法计算参数：四柱信息(${eightChars.year.name} ${eightChars.month.name} ${eightChars.day.name} ${eightChars.time.name})";
}

// 四柱天干取数法现在使用MultiBaseNumberResult
// 不再需要单独的FourZhuTianGanStrategyResult类

/// 四柱天干取数法计算策略
///
/// 实现四柱天干取数法的标准计算策略
class FourZhuTianGanStrategy
    extends
        StandardCalculationStrategy<
          FourZhuTianGanStrategyParams,
          BaseNumberModelResult
        > {
  @override
  String get name => "四柱天干取数法";

  @override
  String get description => "排四柱只取天干进行配数，按月日时年顺序排列得到基本数，递加96生成条文列表";

  @override
  List<String> get detailSteps => [
    "1. 排四柱：获取年月日时的天干信息",
    "2. 天干配数：甲1、乙6、丙2、丁7、戊3、己8、庚4、辛9、壬5、癸0",
    "3. 排列组合：按照月、日、时、年的顺序排列天干配数，得到四位基本数",
    "4. 生成条文列表：以基本数为基础递加96七次，得到8个条文编号",
  ];

  @override
  String get school => "四柱天干流派";

  /// 获取默认的条文计算配置
  @override
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig {
    return GenericTiaoWenCalculationConfig.customList(
      name: "四柱天干标准配置",
      description: "基础数递加96七次：+96、+192、+288、+384、+480、+576、+672",
      customList: [0, 96, 192, 288, 384, 480, 576, 672],
      withSub: false,
    );
  }

  /// 计算条文列表（使用指定配置）
  @override
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    FourZhuTianGanStrategyParams params,
    TiaoWenCalculationConfig config,
  ) {
    // 构建计算上下文
    final context = <String, dynamic>{
      'eightChars': params.eightChars,
      'baseNumber': baseNumber,
    };

    return config.calculateTiaoWenList(baseNumber, context);
  }

  /// 获取支持的条文计算配置选项
  @override
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs {
    return [
      GenericTiaoWenCalculationConfig.customList(
        name: "四柱天干标准配置",
        description: "基础数递加96七次：+96、+192、+288、+384、+480、+576、+672",
        customList: [0, 96, 192, 288, 384, 480, 576, 672],
        withSub: false,
      ),
      GenericTiaoWenCalculationConfig.customList(
        name: "四柱天干简化配置",
        description: "基础数递加96三次：+96、+192、+288",
        customList: [0, 96, 192, 288],
        withSub: false,
      ),
      GenericTiaoWenCalculationConfig.customList(
        name: "四柱天干扩展配置",
        description: "基础数递加96十次：+96到+960",
        customList: [0, 96, 192, 288, 384, 480, 576, 672, 768, 864, 960],
        withSub: false,
      ),
    ];
  }

  @override
  String get tiaoWenCalculationDescription =>
      defaultTiaoWenCalculationConfig.description;

  @override
  BaseNumberModelResult calculate(FourZhuTianGanStrategyParams params) {
    try {
      // 获取四柱天干
      final eightChars = params.eightChars;
      final yearGan = eightChars.year.gan;
      final monthGan = eightChars.month.gan;
      final dayGan = eightChars.day.gan;
      final timeGan = eightChars.time.gan;

      // 按照月、日、时、年的顺序排列天干配数，得到四位基本数
      final monthNumber = Constants.fourZhuTianGanNumberMapper[monthGan]!;
      final dayNumber = Constants.fourZhuTianGanNumberMapper[dayGan]!;
      final timeNumber = Constants.fourZhuTianGanNumberMapper[timeGan]!;
      final yearNumber = Constants.fourZhuTianGanNumberMapper[yearGan]!;

      // 组合成四位数：月日时年
      final baseNumber =
          monthNumber * 1000 + dayNumber * 100 + timeNumber * 10 + yearNumber;

      // 创建单个基础数模型
      final baseNumberModel = BaseNumberModel.create(
        baseNumber: baseNumber,
        name: "四柱天干组合数",
        description:
            "月${monthGan.name}(${monthNumber})日${dayGan.name}(${dayNumber})时${timeGan.name}(${timeNumber})年${yearGan.name}(${yearNumber})组合：$baseNumber",
        source: BaseNumberSource.combined,
      );

      return BaseNumberModelResult.success(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        baseNumbers: [baseNumberModel],
        sourceData: {
          'eightChars': {
            'year': {'gan': yearGan.name, 'number': yearNumber},
            'month': {'gan': monthGan.name, 'number': monthNumber},
            'day': {'gan': dayGan.name, 'number': dayNumber},
            'time': {'gan': timeGan.name, 'number': timeNumber},
          },
          'baseNumber': baseNumber,
          'calculation':
              'month($monthNumber) * 1000 + day($dayNumber) * 100 + time($timeNumber) * 10 + year($yearNumber)',
        },
      );
    } catch (e) {
      return BaseNumberModelResult.error(
        algorithmName: name,
        algorithmDescription: description,
        calculationParams: params.description,
        errorMessage: "四柱天干计算失败: $e",
        sourceData: {'error': e.toString(), 'params': params.description},
      );
    }
  }
}
