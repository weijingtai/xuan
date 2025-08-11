import 'package:tiebanshenshu/service/calculation_strategy.dart';

import '../../constant/constants.dart';
import '../../constant/constants.dart' as constants;
import '../../domain/four_zhu.dart';
import '../../utils/utils.dart';

/// 干支转数字策略枚举
enum GanZhiToNumberStrategy {
  /// 使用干支数（四门法）
  ganZhiNumber, // 天干数，与地支对应 -- 地支数为一个地支对应两个数 如：亥子一六
  ganZhiFlatedNumber, // 同上，但地支不在一个对应两个而是 亥1子6
  /// 使用太玄数（八卦滚法）
  taiXuanNumber,
}

enum NumberOperationStrategy {
  onlyDigit, // 忽略十位，只保留个位
  mode, // 取余数，“取模”
  subtract, // 当数大于“N”时，则减去N
}

enum NumberConversionGuaStrategy {
  toHouTian, // 转换为后天数
  toXianTian, // 转换为先天数
}

class GetFirstFourParams {
  final FourZhu fourZhu;
  final String threeYuan;
  final String gender;
  GetFirstFourParams({
    required this.fourZhu,
    required this.threeYuan,
    required this.gender,
  });
}

/// 卦象生成配置策略
class GuaGenerationConfig {
  /// 数字转换策略
  // final GanZhiConversionNumberStrategy numberStrategy;

  /// 第一卦生成策略
  final String firstGuaType; // "互" | "错" | "本"

  /// 第二卦生成策略
  final GuaStrategy secondGuaStrategy;

  /// 第三卦生成策略
  final GuaStrategy thirdGuaStrategy;

  /// 第四卦生成策略
  final GuaStrategy fourthGuaStrategy;

  GuaGenerationConfig({
    // required this.numberStrategy,
    required this.firstGuaType,
    required this.secondGuaStrategy,
    required this.thirdGuaStrategy,
    required this.fourthGuaStrategy,
  });
}

/// 卦象生成策略（统一策略类）
class GuaStrategy {
  /// 是否需要上下交换
  final bool needExchange;

  /// 是否需要错卦变换
  final bool needCuoGua;

  /// 卦象类型（"互"、"错"、"本"）
  final String guaType;

  /// 基础卦来源（"basic" | "first" | "second" | "third"）
  /// - "basic": 使用基本卦
  /// - "first": 使用第一卦
  /// - "second": 使用第二卦
  /// - "third": 使用第三卦
  final String baseGuaSource;

  /// 是否需要变爻（仅对第二卦有效）
  final bool needVariation;

  GuaStrategy({
    required this.needExchange,
    required this.needCuoGua,
    required this.guaType,
    required this.baseGuaSource,
    this.needVariation = false,
  });

  /// 创建第二卦策略的便捷构造函数
  GuaStrategy.forSecondGua({
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
  GuaStrategy.forThirdGua({
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
  GuaStrategy.forFourthGua({
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

/// 前四卦计算结果
class FirstFourGuaResult {
  final String basicGua;
  final int basicNumber;
  final int variationBase;
  final List<String> fourGuaList;

  FirstFourGuaResult({
    required this.basicGua,
    required this.basicNumber,
    required this.variationBase,
    required this.fourGuaList,
  });
}

class NumberConfig {
  NumberOperationStrategy numberOperationStrategy; // 偶数 数字操作的规则
  int factorNumber; // 偶数 数字操作的因子 8、9等
  NumberConversionGuaStrategy guaConversionStrategy; // 数字转换为卦象的规则
  bool withLength = false; // 偶数相加是否需要再加偶数的个数

  NumberConfig({
    required this.numberOperationStrategy,
    required this.factorNumber,
    required this.guaConversionStrategy,
  });
}

/// 前四卦计算抽象基类
///
/// 封装四门法和八卦滚法的共同逻辑，通过配置策略实现差异化
abstract class BaseGuaCalculationStrategy
    extends CalculationStrategy<GetFirstFourParams, List<int>> {
  NumberConfig evenNumberConfig; // 数字操作的规则
  NumberConfig oddNumberConfig; // 数字操作的规则

  // NumberOperationStrategy evenNumberOperationStrategy; // 偶数 数字操作的规则
  // NumberOperationStrategy oddNumberOperationStrategy; // 奇数 数字操作的规则
  // int evenFactorNumber; // 偶数 数字操作的因子 8、9等
  // int oddFactorNumber; // 奇数 数字操作的因子 8、9 等

  // NumberConversionGuaStrategy topGuaConversionStrategy; // 数字转换为卦象的规则
  // NumberConversionGuaStrategy bottomGuaConversionStrategy; // 数字转换为卦象的规则

  // bool withEvenLength = false; // 偶数相加是否需要再加偶数的个数
  // bool withOddLength = false; // 奇数相加是否需要再加奇数的个数

  GanZhiToNumberStrategy ganToNumberStrategy; // 数字操作的规则
  GanZhiToNumberStrategy zhiToNumberStrategy; // 数字操作的规则

  bool isOddAsTopGua = true; // 奇数是否为上卦
  FourZhu fourZhu;

  late final String baseGua;
  late final int baseNumber;
  BaseGuaCalculationStrategy({
    required this.fourZhu,
    // required this.evenNumberOperationStrategy,
    // required this.oddNumberOperationStrategy,
    // required this.evenFactorNumber,
    // required this.oddFactorNumber,
    // required this.topGuaConversionStrategy,
    // required this.bottomGuaConversionStrategy,
    required this.evenNumberConfig,
    required this.oddNumberConfig,
    required this.isOddAsTopGua,
    // required this.withEvenLength,
    // required this.withOddLength,
    required this.ganToNumberStrategy,
    required this.zhiToNumberStrategy,
  }) {
    final res = calculateBasicGua(fourZhu);
    baseGua = res.$1;
    baseNumber = res.$2;
  }

  /// 获取卦象生成配置
  GuaGenerationConfig getGuaGenerationConfig();

  /// 计算基本卦和基本数（共同逻辑，但支持不同的数字转换策略）
  (String, int) calculateBasicGua(FourZhu fourZhu) {
    final config = getGuaGenerationConfig();

    // 根据策略获取四柱对应的数字列表
    List<int> tianGanNumberList = _getGanNumbers(fourZhu, ganToNumberStrategy);
    List<int> diZhiNumberList = _getZhiNumbers(fourZhu, zhiToNumberStrategy);
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

    var oddGuaNum = toGuaNum(
      oddSum,
      oddNumberConfig.numberOperationStrategy,
      oddNumberConfig.factorNumber,
    );
    var evenGuaNum = toGuaNum(
      evenSum,
      evenNumberConfig.numberOperationStrategy,
      evenNumberConfig.factorNumber,
    );
    var oddGua = numToGua(oddGuaNum, oddNumberConfig.guaConversionStrategy);
    var evenGua = numToGua(evenGuaNum, evenNumberConfig.guaConversionStrategy);

    var upperGua = isOddAsTopGua ? oddGua : evenGua;
    var lowerGua = isOddAsTopGua ? evenGua : oddGua;
    // var upperGuaNum = isOddAsTopGua ? oddGuaNum : evenGuaNum;
    // var lowerGuaNum = isOddAsTopGua ? evenGuaNum : oddGuaNum;
    // var upperGua = numToGua(upperGuaNum, topGuaConversionStrategy);
    // var lowerGua = numToGua(lowerGuaNum, bottomGuaConversionStrategy);

    // 根据数字获取卦名
    final basicGua = upperGua + lowerGua;

    // 计算基本数
    final basicNumber =
        guaBasicNumberUponMapper[upperGua]! +
        guaBasicNumberUnderMapper[lowerGua]!;

    return (basicGua, basicNumber);
  }

  String numToGua(int num, NumberConversionGuaStrategy strategy) {
    switch (strategy) {
      case NumberConversionGuaStrategy.toXianTian:
        return constants.xianTianNumberGuaMapper[num]!;
      case NumberConversionGuaStrategy.toHouTian:
        return constants.houTianNumberGuaMapper[num]!;
    }
  }

  int toGuaNum(int number, NumberOperationStrategy strategy, int factorNumber) {
    int res = 0;
    switch (strategy) {
      case NumberOperationStrategy.onlyDigit:
        if (number > 10) {
          res = number % 10;
        } else {
          res = number;
        }
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

  List<int> _getGanNumbers(FourZhu fourZhu, GanZhiToNumberStrategy strategy) {
    final allTianGanList = [
      fourZhu.yearGan,
      fourZhu.monthGan,
      fourZhu.dayGan,
      fourZhu.timeGan,
    ];
    switch (strategy) {
      case GanZhiToNumberStrategy.ganZhiNumber:
      case GanZhiToNumberStrategy.ganZhiFlatedNumber:
        return allTianGanList
            .map((t) => constants.tianGanNumberMapper[t]!)
            .toList();
      case GanZhiToNumberStrategy.taiXuanNumber:
        return allTianGanList
            .map((t) => constants.taixuanGanNumberMapper[t]!)
            .toList();
    }
  }

  List<int> _getZhiNumbers(FourZhu fourZhu, GanZhiToNumberStrategy strategy) {
    final allTianGanList = [
      fourZhu.yearZhi,
      fourZhu.monthZhi,
      fourZhu.dayZhi,
      fourZhu.timeZhi,
    ];
    switch (strategy) {
      case GanZhiToNumberStrategy.ganZhiNumber:
        return allTianGanList
            .map((t) => constants.dizhiNumberMapper[t]!)
            .toList();
      case GanZhiToNumberStrategy.ganZhiFlatedNumber:
        return allTianGanList
            .map((t) => constants.diZhiFlatedNumberMapper[t]!)
            .toList();
      case GanZhiToNumberStrategy.taiXuanNumber:
        return allTianGanList
            .map((t) => constants.taixuanZhiNumberMapper[t]!)
            .toList();
    }
  }

  /// 计算变爻基数（共同逻辑）
  int calculateVariationBase(
    FourZhu fourZhu,
    String threeYuan,
    String gender,
    int basicNumber,
  ) {
    final ganTaixuan = fourZhu.yearGanTaixuanNum;
    final zhiTaixuan = fourZhu.yearZhiTaixuanNum;
    final isYangYear = fourZhu.isYangGanYear;

    // 根据三元和性别计算系数
    int ganFactor, zhiFactor;

    if (threeYuan == "上") {
      ganFactor = 10;
      zhiFactor = 1;
    } else if (threeYuan == "下") {
      ganFactor = 1;
      zhiFactor = 10;
    } else {
      // 中元
      if (isYangYear) {
        if (gender == "男") {
          ganFactor = 100;
          zhiFactor = 10;
        } else {
          ganFactor = 10;
          zhiFactor = 100;
        }
      } else {
        if (gender == "男") {
          ganFactor = 10;
          zhiFactor = 100;
        } else {
          ganFactor = 100;
          zhiFactor = 10;
        }
      }
    }
    final baseNumber = ganTaixuan * ganFactor + zhiTaixuan * zhiFactor;
    // print("$ganTaixuan $zhiTaixuan ");
    // print("${ganTaixuan * ganFactor} ${zhiTaixuan * zhiFactor}");
    return baseNumber + basicNumber;
  }

  /// 生成前四卦（模板方法）
  FirstFourGuaResult generateFirstFourGua(
    FourZhu fourZhu,
    String threeYuan,
    String gender,
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

  /// 获取四柱干支数（四门法使用）
  List<int> _getGanZhiNumbers(FourZhu fourZhu) {
    final numbers = <int>[];

    // 添加天干数字
    final ganList = [
      fourZhu.yearGan,
      fourZhu.monthGan,
      fourZhu.dayGan,
      fourZhu.timeGan,
    ];
    numbers.addAll(ganList.map((gan) => tianGanNumberMapper[gan]!));

    // 添加地支数字
    final zhiList = [
      fourZhu.yearZhi,
      fourZhu.monthZhi,
      fourZhu.dayZhi,
      fourZhu.timeZhi,
    ];
    for (final zhi in zhiList) {
      numbers.addAll(diZhiNumberMapper[zhi]!);
    }

    return numbers;
  }

  /// 获取四柱太玄数（八卦滚法使用）
  List<int> _getTaiXuanNumbers(FourZhu fourZhu) {
    return [
      fourZhu.yearGanTaixuanNum,
      fourZhu.yearZhiTaixuanNum,
      fourZhu.monthGanTaixuanNum,
      fourZhu.monthZhiTaixuanNum,
      fourZhu.dayGanTaixuanNum,
      fourZhu.dayZhiTaixuanNum,
      fourZhu.timeGanTaixuanNum,
      fourZhu.timeZhiTaixuanNum,
    ];
  }

  /// 根据配置生成四个卦
  List<String> _generateFourGuaWithConfig(
    String basicGua,
    int variationBase,
    GuaGenerationConfig config,
  ) {
    final result = <String>[];
    final guaMap = <String, String>{"basic": basicGua};

    // 第一卦：根据配置生成
    String firstGua;
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
    print("fisrt: $firstGua");

    // 第二卦：根据策略生成
    final secondGua = _generateGuaWithStrategy(
      guaMap,
      variationBase,
      config.secondGuaStrategy,
    );
    result.add(secondGua);
    guaMap["second"] = secondGua;
    print("$secondGua, $variationBase");

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
  String _generateGuaWithStrategy(
    Map<String, String> guaMap,
    int variationBase,
    GuaStrategy strategy,
  ) {
    // 获取基础卦
    final baseGua = guaMap[strategy.baseGuaSource];
    if (baseGua == null) {
      throw ArgumentError('无效的基础卦来源：${strategy.baseGuaSource}');
    }
    print("-----${variationBase}");

    String resultGua = baseGua;

    // 如果需要变爻（仅对第二卦）
    if (strategy.needVariation) {
      final bianYaoNum = variationBase % 9;
      print("~~~~~$bianYaoNum");
      final bianYaoPositions = getChangePositions(bianYaoNum);

      final guaBinary = guaToBinaryList(resultGua);
      print(guaBinary);
      final changedBinary = yaoBianGua(guaBinary, bianYaoPositions);
      print(changedBinary);
      resultGua = binaryListToGua(changedBinary);
    }
    print(resultGua);

    // 根据策略处理
    if (strategy.needExchange) {
      resultGua = resultGua.substring(1) + resultGua.substring(0, 1); // 上下交换
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
