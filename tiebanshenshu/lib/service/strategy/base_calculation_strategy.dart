/// 铁板神数计算策略基础接口
///
/// 定义所有计算策略的基础抽象类
/// 支持常规计算和交互式计算两种模式
library;

import 'tiao_wen_list_calculation.dart';

/// 条文计算配置接口
///
/// 定义条文计算的配置方式，支持Strategy特有的计算逻辑
abstract class TiaoWenCalculationConfig {
  /// 配置名称
  String get name;

  /// 配置描述
  String get description;

  /// 计算条文列表
  /// [baseNumber] 基础数字
  /// [context] 计算上下文（可能包含四柱信息等）
  List<int> calculateTiaoWenList(int baseNumber, Map<String, dynamic> context);
}

/// 通用的条文计算配置（兼容原有的TiaoWenListCalculationConfig）
class GenericTiaoWenCalculationConfig implements TiaoWenCalculationConfig {
  final String _name;
  final String _description;
  final List<int> calculationList;
  final bool withSub;

  const GenericTiaoWenCalculationConfig({
    required String name,
    required String description,
    required this.calculationList,
    this.withSub = false,
  }) : _name = name,
       _description = description;

  @override
  String get name => _name;

  @override
  String get description => _description;

  @override
  List<int> calculateTiaoWenList(int baseNumber, Map<String, dynamic> context) {
    List<int> result = calculationList.map((e) => baseNumber + e).toList();
    if (withSub) {
      result.addAll(calculationList.map((e) => baseNumber - e).toList());
    }
    return result;
  }

  /// 工厂方法：太玄四柱标准配置
  factory GenericTiaoWenCalculationConfig.taiXuanStandard() {
    return const GenericTiaoWenCalculationConfig(
      name: "太玄四柱标准配置",
      description: "基础数分别各±96四次：±96、±192、±384、±768",
      calculationList: [0, 96, 192, 384, 768],
      withSub: true,
    );
  }

  /// 工厂方法：自定义列表
  factory GenericTiaoWenCalculationConfig.customList({
    required String name,
    required String description,
    required List<int> customList,
    bool withSub = false,
  }) {
    return GenericTiaoWenCalculationConfig(
      name: name,
      description: description,
      calculationList: customList,
      withSub: withSub,
    );
  }

  /// 工厂方法：递增96四次
  ///
  /// 基础数递增96四次，生成5个条文编号
  /// 示例：base=3387 → [3387, 3483, 3579, 3675, 3771]
  factory GenericTiaoWenCalculationConfig.increment96x4() {
    return const GenericTiaoWenCalculationConfig(
      name: "递增96四次",
      description: "基础数递增96四次：base + [0, 96, 192, 288, 384]",
      calculationList: [0, 96, 192, 288, 384],
      withSub: false,
    );
  }

  /// 工厂方法：递减96四次
  ///
  /// 基础数递减96四次，生成5个条文编号
  /// 示例：base=2477 → [2477, 2381, 2285, 2189, 2093]
  factory GenericTiaoWenCalculationConfig.decrement96x4() {
    return const GenericTiaoWenCalculationConfig(
      name: "递减96四次",
      description: "基础数递减96四次：base + [0, -96, -192, -288, -384]",
      calculationList: [0, -96, -192, -288, -384],
      withSub: false,
    );
  }

  /// 工厂方法：加减48倍数
  ///
  /// 基础数加减48的倍数，生成9个条文编号
  /// 默认倍数为 [2, 4, 8, 16]，加上base本身共9个
  /// 示例：base=3198 → [3102, 3006, 2814, 2430, 3198, 3294, 3390, 3582, 3966]
  factory GenericTiaoWenCalculationConfig.addSub48x({
    List<int> multiples = const [2, 4, 8, 16],
    bool includeBase = true,
  }) {
    final calculationList = <int>[];
    if (includeBase) {
      calculationList.add(0);
    }
    for (final multiple in multiples) {
      calculationList.add(48 * multiple);
    }

    return GenericTiaoWenCalculationConfig(
      name: "加减48倍数",
      description: "基础数±48×倍数：base ± [48×2, 48×4, 48×8, 48×16]",
      calculationList: calculationList,
      withSub: true,
    );
  }

  /// 转换为TiaoWenListCalculationConfig以兼容旧的模型系统
  TiaoWenListCalculationConfig toTiaoWenListCalculationConfig() {
    return TiaoWenListCalculationConfig.listAdd(
      customList: calculationList,
      withSub: withSub,
    );
  }
}

/// 皇极取数法专用条文计算配置
class HuangJiTiaoWenCalculationConfig implements TiaoWenCalculationConfig {
  @override
  String get name => "皇极取数法专用配置";

  @override
  String get description => "基于四柱信息的12种复杂计算规则";

  @override
  List<int> calculateTiaoWenList(int baseNumber, Map<String, dynamic> context) {
    // 从context中获取四柱信息
    final eightChars = context['eightChars'];
    if (eightChars == null) {
      throw ArgumentError('皇极取数法需要四柱信息(eightChars)');
    }

    // 这里应该调用皇极取数法的具体计算逻辑
    // 为了示例，这里返回一个简化的实现
    return _calculateHuangJiFinalNumbers(baseNumber, eightChars);
  }

  List<int> _calculateHuangJiFinalNumbers(int baseNumber, dynamic eightChars) {
    // 这里应该是皇极取数法的12种计算规则的实现
    // 暂时返回一个示例
    return [
      baseNumber + 100, // 示例：基础数 + 月干(百位数)
      baseNumber + 200, // 示例：基础数 + 月支(百位数)
      // ... 其他10种规则
    ];
  }
}

/// 策略分类枚举
///
/// 用于区分不同类型的计算策略
enum StrategyCategory {
  /// 常规策略 - 无需用户交互的一次性计算
  standard,

  /// 交互式策略 - 需要用户交互确认的计算
  interactive,
}

/// 所有计算策略的基础抽象类
///
/// 定义了计算策略的基本接口
/// 所有具体的计算策略都应该继承此类
abstract class BaseCalculationStrategy<P, R> {
  /// 策略名称
  String get name;

  /// 策略描述
  String get description;

  /// 策略详细步骤
  List<String> get detailSteps;

  /// 所属流派
  String get school;

  /// 策略分类标识
  StrategyCategory get category;

  /// 是否为交互式策略
  bool get isInteractive => category == StrategyCategory.interactive;

  /// 获取默认的条文计算配置
  ///
  /// 每个Strategy提供自己的默认条文计算方式
  /// 这个配置可以被用户在UI中选择和修改
  TiaoWenCalculationConfig get defaultTiaoWenCalculationConfig;

  /// 计算条文列表（使用默认配置）
  ///
  /// [baseNumber] 基础数字
  /// [params] 原始计算参数
  /// 返回条文数字列表
  List<int> calculateTiaoWenList(int baseNumber, P params) {
    return calculateTiaoWenListWithConfig(
      baseNumber,
      params,
      defaultTiaoWenCalculationConfig,
    );
  }

  /// 计算条文列表（使用指定配置）
  ///
  /// [baseNumber] 基础数字
  /// [params] 原始计算参数
  /// [config] 条文计算配置（可以是默认配置或用户自定义配置）
  /// 返回条文数字列表
  List<int> calculateTiaoWenListWithConfig(
    int baseNumber,
    P params,
    TiaoWenCalculationConfig config,
  );

  /// 获取该Strategy支持的条文计算配置选项
  ///
  /// 返回用户可以选择的预设配置列表
  List<TiaoWenCalculationConfig> get supportedTiaoWenCalculationConfigs;

  /// 获取条文计算的描述信息
  ///
  /// 返回该Strategy条文计算方法的描述
  String get tiaoWenCalculationDescription;
}

/// 所有算法参数的基础抽象类
abstract class BaseCalculationParams {
  /// 参数描述
  String get description;
}

/// 所有算法结果的基础抽象类
abstract class BaseCalculationResult {
  // /// 结果摘要
  // int get baseNumber;
}
