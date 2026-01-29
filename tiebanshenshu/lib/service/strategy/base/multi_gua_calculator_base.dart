/// 多卦计算器基类
///
/// 为四门法和八卦滚法提供共享的基础设施
library;

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import '../../../constant/constants.dart' as constants;
import '../../../features/six_yao_gua/pure_six_yao_gua.dart';
import '../../../utils/utils.dart';

/// 干支转数字策略枚举
enum GanZhiToNumberStrategy {
  /// 使用天干数+地支数（四门法）- 地支对应两个数
  ganZhiNumber,

  /// 使用天干数+地支数（扁平化）- 地支对应一个数
  ganZhiFlatedNumber,

  /// 使用太玄数（八卦滚法）
  taiXuanNumber,
}

/// 数字操作策略枚举
enum NumberOperationStrategy {
  /// 只保留个位
  onlyDigit,

  /// 取模运算
  mode,

  /// 减法运算
  subtract,
}

/// 数字转卦策略枚举
enum NumberConversionGuaStrategy {
  /// 转换为后天卦
  toHouTian,

  /// 转换为先天卦
  toXianTian,
}

/// 数字操作配置
class NumberConfig {
  final NumberOperationStrategy numberOperationStrategy;
  final int factorNumber; // 操作因子（如8、9等）
  final NumberConversionGuaStrategy guaConversionStrategy;
  final bool withLength; // 是否加上数字个数

  const NumberConfig({
    required this.numberOperationStrategy,
    required this.factorNumber,
    required this.guaConversionStrategy,
    this.withLength = false,
  });
}

/// 卦象生成策略
class GuaStrategy {
  /// 是否需要上下交换
  final bool needExchange;

  /// 是否需要错卦变换
  final bool needCuoGua;

  /// 卦象类型（"互"、"错"、"本"）
  final String guaType;

  /// 基础卦来源（"basic" | "first" | "second" | "third"）
  final String baseGuaSource;

  /// 是否需要变爻
  final bool needVariation;

  const GuaStrategy({
    required this.needExchange,
    required this.needCuoGua,
    required this.guaType,
    required this.baseGuaSource,
    this.needVariation = false,
  });

  /// 创建第二卦策略的便捷构造函数
  const GuaStrategy.forSecondGua({
    required bool needExchange,
    required bool needCuoGua,
    required String guaType,
  }) : this(
          needExchange: needExchange,
          needCuoGua: needCuoGua,
          guaType: guaType,
          baseGuaSource: "first",
          needVariation: true,
        );

  /// 创建第三卦策略的便捷构造函数
  const GuaStrategy.forThirdGua({
    required bool needExchange,
    required bool needCuoGua,
    required String guaType,
    required String baseGuaSource,
  }) : this(
          needExchange: needExchange,
          needCuoGua: needCuoGua,
          guaType: guaType,
          baseGuaSource: baseGuaSource,
          needVariation: false,
        );

  /// 创建第四卦策略的便捷构造函数
  const GuaStrategy.forFourthGua({
    required bool needExchange,
    required bool needCuoGua,
    required String guaType,
    required String baseGuaSource,
  }) : this(
          needExchange: needExchange,
          needCuoGua: needCuoGua,
          guaType: guaType,
          baseGuaSource: baseGuaSource,
          needVariation: false,
        );
}

/// 卦象生成配置
class GuaGenerationConfig {
  /// 第一卦生成类型
  final String firstGuaType; // "互" | "错" | "本"

  /// 第二卦生成策略
  final GuaStrategy secondGuaStrategy;

  /// 第三卦生成策略
  final GuaStrategy thirdGuaStrategy;

  /// 第四卦生成策略
  final GuaStrategy fourthGuaStrategy;

  const GuaGenerationConfig({
    required this.firstGuaType,
    required this.secondGuaStrategy,
    required this.thirdGuaStrategy,
    required this.fourthGuaStrategy,
  });
}

/// 前四卦计算结果
class FirstFourGuaResult {
  final Enum64Gua basicGua;
  final int basicNumber;
  final int variationBase;
  final List<Enum64Gua> fourGuaList;

  const FirstFourGuaResult({
    required this.basicGua,
    required this.basicNumber,
    required this.variationBase,
    required this.fourGuaList,
  });
}

/// 多卦计算器抽象基类
///
/// 封装四门法和八卦滚法的共同逻辑
abstract class MultiGuaCalculatorBase {
  final NumberConfig evenNumberConfig;
  final NumberConfig oddNumberConfig;
  final GanZhiToNumberStrategy ganToNumberStrategy;
  final GanZhiToNumberStrategy zhiToNumberStrategy;
  final bool isOddAsTopGua;

  MultiGuaCalculatorBase({
    required this.evenNumberConfig,
    required this.oddNumberConfig,
    required this.ganToNumberStrategy,
    required this.zhiToNumberStrategy,
    this.isOddAsTopGua = true,
  });

  /// 获取卦象生成配置（由子类实现）
  GuaGenerationConfig getGuaGenerationConfig();

  /// 计算基本卦和基本数
  (Enum64Gua, int) calculateBasicGua(EightChars fourZhu) {
    // 根据策略获取四柱对应的数字列表
    final tianGanNumberList = _getGanNumbers(fourZhu, ganToNumberStrategy);
    final diZhiNumberList = _getZhiNumbers(fourZhu, zhiToNumberStrategy);
    final numbers = [...tianGanNumberList, ...diZhiNumberList];

    // 分别计算奇数和偶数的和
    var oddSum = numbers.where((num) => num % 2 == 1).fold(0, (a, b) => a + b);
    if (oddNumberConfig.withLength) {
      oddSum += numbers.where((num) => num % 2 == 1).length;
    }
    var evenSum = numbers.where((num) => num % 2 == 0).fold(0, (a, b) => a + b);
    if (evenNumberConfig.withLength) {
      evenSum += numbers.where((num) => num % 2 == 0).length;
    }

    // 转换为卦数
    final oddGuaNum = toGuaNum(
      oddSum,
      oddNumberConfig.numberOperationStrategy,
      oddNumberConfig.factorNumber,
    );
    final evenGuaNum = toGuaNum(
      evenSum,
      evenNumberConfig.numberOperationStrategy,
      evenNumberConfig.factorNumber,
    );

    // 数字转卦
    final oddGua = numToGua(oddGuaNum, oddNumberConfig.guaConversionStrategy);
    final evenGua = numToGua(evenGuaNum, evenNumberConfig.guaConversionStrategy);

    final upperGua = isOddAsTopGua ? oddGua : evenGua;
    final lowerGua = isOddAsTopGua ? evenGua : oddGua;

    // 组合为基本卦
    final basicGua = Enum64Gua.getBy8Gua(upperGua, lowerGua);

    // 计算基本数
    final basicNumber =
        constants.guaBasicNumberUponMapper[upperGua.name]! +
        constants.guaBasicNumberUnderMapper[lowerGua.name]!;

    return (basicGua, basicNumber);
  }

  /// 数字转卦
  Enum8Gua numToGua(int guaNum, NumberConversionGuaStrategy strategy) {
    switch (strategy) {
      case NumberConversionGuaStrategy.toXianTian:
        final guaName = constants.xianTianNumberGuaMapper[guaNum]!;
        return Enum8Gua.values.firstWhere((e) => e.name == guaName);
      case NumberConversionGuaStrategy.toHouTian:
        final guaName = constants.houTianNumberGuaMapper[guaNum]!;
        return Enum8Gua.values.firstWhere((e) => e.name == guaName);
    }
  }

  /// 数字取模/取位操作
  int toGuaNum(int number, NumberOperationStrategy strategy, int factorNumber) {
    int res = 0;
    switch (strategy) {
      case NumberOperationStrategy.onlyDigit:
        // 只保留个位数
        res = number % 10;
        // 如果是0，转换为对应的factorNumber（通常是8）
        if (res == 0) res = factorNumber;
        break;
      case NumberOperationStrategy.mode:
        res = number % factorNumber == 0 ? factorNumber : number % factorNumber;
        break;
      case NumberOperationStrategy.subtract:
        res = number - factorNumber;
        break;
    }
    return res;
  }

  /// 获取天干数字列表
  List<int> _getGanNumbers(EightChars fourZhu, GanZhiToNumberStrategy strategy) {
    final allTianGanList = [
      fourZhu.year.gan,
      fourZhu.month.gan,
      fourZhu.day.gan,
      fourZhu.time.gan,
    ];

    switch (strategy) {
      case GanZhiToNumberStrategy.ganZhiNumber:
      case GanZhiToNumberStrategy.ganZhiFlatedNumber:
        return allTianGanList
            .map((t) => constants.tianGanNumberMapper[t.name]!)
            .toList();
      case GanZhiToNumberStrategy.taiXuanNumber:
        return allTianGanList
            .map((t) => constants.taixuanGanNumberMapper[t.name]!)
            .toList();
    }
  }

  /// 获取地支数字列表
  List<int> _getZhiNumbers(EightChars fourZhu, GanZhiToNumberStrategy strategy) {
    final allDiZhiList = [
      fourZhu.year.zhi,
      fourZhu.month.zhi,
      fourZhu.day.zhi,
      fourZhu.time.zhi,
    ];

    switch (strategy) {
      case GanZhiToNumberStrategy.ganZhiNumber:
        return allDiZhiList
            .expand((t) => constants.diZhiNumberMapper[t.name]!)
            .toList();
      case GanZhiToNumberStrategy.ganZhiFlatedNumber:
        return allDiZhiList
            .map((t) => constants.diZhiFlatedNumberMapper[t.name]!)
            .toList();
      case GanZhiToNumberStrategy.taiXuanNumber:
        return allDiZhiList
            .map((t) => constants.taixuanZhiNumberMapper[t.name]!)
            .toList();
    }
  }

  /// 计算变爻基数
  int calculateVariationBase(
    EightChars fourZhu,
    YuanYunOrder threeYuan,
    Gender gender,
    int basicNumber,
  ) {
    final ganTaixuan = constants.taixuanGanNumberMapper[fourZhu.year.gan.name]!;
    final zhiTaixuan = constants.taixuanZhiNumberMapper[fourZhu.year.zhi.name]!;
    final isYangYear = fourZhu.year.gan.yinYang == YinYang.YANG;

    // 根据三元和性别计算系数
    int ganFactor, zhiFactor;

    if (threeYuan == YuanYunOrder.upper) {
      ganFactor = 10;
      zhiFactor = 1;
    } else if (threeYuan == YuanYunOrder.lower) {
      ganFactor = 1;
      zhiFactor = 10;
    } else {
      // 中元
      if (isYangYear) {
        if (gender == Gender.male) {
          ganFactor = 100;
          zhiFactor = 10;
        } else {
          ganFactor = 10;
          zhiFactor = 100;
        }
      } else {
        if (gender == Gender.male) {
          ganFactor = 10;
          zhiFactor = 100;
        } else {
          ganFactor = 100;
          zhiFactor = 10;
        }
      }
    }

    final baseNumber = ganTaixuan * ganFactor + zhiTaixuan * zhiFactor;
    return baseNumber + basicNumber;
  }

  /// 生成前四卦（模板方法）
  FirstFourGuaResult generateFirstFourGua(
    EightChars fourZhu,
    YuanYunOrder threeYuan,
    Gender gender,
  ) {
    // 1. 计算基本卦和基本数
    final (basicGua, basicNumber) = calculateBasicGua(fourZhu);

    // 2. 计算变爻基数
    final variationBase = calculateVariationBase(
      fourZhu,
      threeYuan,
      gender,
      basicNumber,
    );

    // 3. 获取生成配置
    final config = getGuaGenerationConfig();

    // 4. 生成四个卦
    final fourGuaList = _generateFourGuaWithConfig(
      basicGua,
      variationBase,
      config,
    );

    return FirstFourGuaResult(
      basicGua: basicGua,
      basicNumber: basicNumber,
      variationBase: variationBase,
      fourGuaList: fourGuaList,
    );
  }

  /// 根据配置生成四个卦
  List<Enum64Gua> _generateFourGuaWithConfig(
    Enum64Gua basicGua,
    int variationBase,
    GuaGenerationConfig config,
  ) {
    final result = <Enum64Gua>[];
    final guaMap = <String, Enum64Gua>{"basic": basicGua};

    // 第一卦：根据配置生成
    Enum64Gua firstGua;
    switch (config.firstGuaType) {
      case "互":
        firstGua = guaToHuGua(basicGua);
        break;
      case "错":
        firstGua = guaToCuoGua(basicGua);
        break;
      case "本":
        firstGua = basicGua;
        break;
      default:
        throw ArgumentError('不支持的第一卦类型：${config.firstGuaType}');
    }
    result.add(firstGua);
    guaMap["first"] = firstGua;

    // 第二卦：根据策略生成
    final secondGua = _generateGuaWithStrategy(
      guaMap,
      variationBase,
      config.secondGuaStrategy,
    );
    result.add(secondGua);
    guaMap["second"] = secondGua;

    // 第三卦：根据策略生成
    final thirdGua = _generateGuaWithStrategy(
      guaMap,
      variationBase,
      config.thirdGuaStrategy,
    );
    result.add(thirdGua);
    guaMap["third"] = thirdGua;

    // 第四卦：根据策略生成
    final fourthGua = _generateGuaWithStrategy(
      guaMap,
      variationBase,
      config.fourthGuaStrategy,
    );
    result.add(fourthGua);

    return result;
  }

  /// 根据统一策略生成卦象
  Enum64Gua _generateGuaWithStrategy(
    Map<String, Enum64Gua> guaMap,
    int variationBase,
    GuaStrategy strategy,
  ) {
    // 获取基础卦
    final baseGua = guaMap[strategy.baseGuaSource];
    if (baseGua == null) {
      throw ArgumentError('无效的基础卦来源：${strategy.baseGuaSource}');
    }

    Enum64Gua resultGua = baseGua;

    // 如果需要变爻
    if (strategy.needVariation) {
      final bianYaoNum = variationBase % 9;
      final bianYaoPositions = getChangePositions(bianYaoNum);

      final guaBinary = guaToBinaryList(resultGua);
      final changedBinary = yaoBianGua(guaBinary, bianYaoPositions);

      // 将二进制列表转换为二进制字符串
      final binaryStr = changedBinary.join('');

      // 转换回Enum64Gua
      resultGua = Enum64Gua.fromBinaryStr(binaryStr);
    }

    // 根据策略处理
    if (strategy.needExchange) {
      // 上下交换
      resultGua = Enum64Gua.getBy8Gua(resultGua.bottom, resultGua.top);
    }

    if (strategy.needCuoGua) {
      resultGua = guaToCuoGua(resultGua);
    }

    // 根据卦象类型处理
    switch (strategy.guaType) {
      case "互":
        resultGua = guaToHuGua(resultGua);
        break;
      case "错":
        resultGua = guaToCuoGua(resultGua);
        break;
      case "本":
        // 保持不变
        break;
      default:
        throw ArgumentError('不支持的卦象类型：${strategy.guaType}');
    }

    return resultGua;
  }

  /// 根据余数获取需要变化的爻位置
  List<int> getChangePositions(int remainder) {
    const changeMap = {
      1: [5], // 初爻变
      2: [4], // 二爻变
      3: [3], // 三爻变
      4: [2], // 四爻变
      5: [1], // 五爻变
      6: [0], // 上爻变
      7: [5, 2], // 初爻、四爻变
      8: [4, 1], // 二爻、五爻变
      0: [3, 0], // 三爻、上爻变
    };

    if (!changeMap.containsKey(remainder)) {
      throw ArgumentError('无效的变爻余数：$remainder');
    }

    return changeMap[remainder]!;
  }
}
