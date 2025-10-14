/// 四门变计算器模块
///
/// 本模块实现了四门变算法，用于根据四柱信息计算条文数。
/// 四门变是一种传统的数术计算方法，通过特定的卦象变化规则来推算结果。
///
/// 主要功能：
/// 1. 根据四柱信息生成基本卦
/// 2. 通过变爻规则生成四个卦象
/// 3. 计算秘数和先天数
/// 4. 生成最终的条文数列表
///
/// 作者：AI Assistant
/// 版本：2.1
/// 日期：2024

import '../constant/constants.dart' as constants;
import '../domain/four_zhu.dart';
import '../utils/utils.dart';

/// 卦象生成策略配置类
///
/// 用于定义在四门变过程中如何生成特定位置的卦象。
class GuaGenerationStrategy {
  /// 生成的卦象序号（1-4）
  final int order;

  /// 卦象类型（"互"、"错"或"本"）
  final String guaType;

  /// 是否需要交换上下卦
  final bool exchangeType;

  GuaGenerationStrategy({
    required this.order,
    required this.guaType,
    required this.exchangeType,
  }) {
    _validate();
  }

  /// 验证参数有效性
  void _validate() {
    if (order < 1 || order > 4) {
      throw ArgumentError('卦象序号必须在1-4之间，当前值：$order');
    }
    if (!['互', '错', '本'].contains(guaType)) {
      throw ArgumentError('不支持的卦象类型：$guaType');
    }
  }
}

/// 四卦计算结果类
///
/// 封装四门变算法中生成的四个卦象及相关信息。
class FourGuaResult {
  final String basicGua;
  final int basicNumber;
  final String firstGua;
  final String secondGua;
  final String thirdGua;
  final String fourthGua;

  FourGuaResult({
    required this.basicGua,
    required this.basicNumber,
    required this.firstGua,
    required this.secondGua,
    required this.thirdGua,
    required this.fourthGua,
  });

  /// 获取四个卦象的列表
  List<String> getGuaList() {
    return [firstGua, secondGua, thirdGua, fourthGua];
  }
}

/// 四门变计算器
///
/// 实现完整的四门变算法，严格按照传统算法进行计算。
/// 采用单一职责原则，每个方法只负责一个特定的计算步骤。
class FourDoorsCalculator {
  /// 默认的卦象生成策略
  static final List<GuaGenerationStrategy> defaultStrategies = [
    GuaGenerationStrategy(order: 1, guaType: "互", exchangeType: false),
    GuaGenerationStrategy(order: 2, guaType: "错", exchangeType: true),
    GuaGenerationStrategy(order: 3, guaType: "互", exchangeType: false),
    GuaGenerationStrategy(order: 4, guaType: "互", exchangeType: false),
  ];

  /// 执行完整的四门变计算
  ///
  /// [fourZhu] 四柱信息
  /// [threeYuan] 三元（"上"、"中"、"下"）
  /// [gender] 性别（"男"、"女"）
  /// [strategies] 卦象生成策略，为null时使用默认策略
  ///
  /// 返回条文数列表
  ///
  /// 抛出 [ArgumentError] 当输入参数无效时
  /// 抛出 [StateError] 当计算过程中发生错误时
  List<int> calculate(
    FourZhu fourZhu,
    String threeYuan,
    String gender, {
    List<GuaGenerationStrategy>? strategies,
  }) {
    try {
      // 1. 参数验证
      _validateInputs(threeYuan, gender);

      strategies ??= defaultStrategies;

      // 2. 计算基本卦和基本数
      final basicResult = _calculateBasicGua(fourZhu);
      final basicGua = basicResult.$1;
      final basicNumber = basicResult.$2;

      // 3. 计算变爻基数
      final variationBase = _calculateVariationBase(
        fourZhu,
        threeYuan,
        gender,
        basicNumber,
      );
      // print("基本卦：$basicGua，基本数：$basicNumber，变爻基数：$variationBase");

      // 4. 生成四个卦象
      final fourGuaResult = _generateFourGua(
        basicGua,
        basicNumber,
        variationBase,
        strategies,
      );

      // 5. 计算秘数列表
      final secretNumbers = _calculateSecretNumbers(
        fourZhu.isYangGanYear,
        fourGuaResult.getGuaList(),
      );

      // 6. 计算先天数列表
      final xiantianNumbers = _calculateXiantianNumbers(
        fourGuaResult.getGuaList(),
      );

      // 7. 计算最终条文数
      final finalTiaowenList = _calculateFinalTiaowen(
        xiantianNumbers,
        secretNumbers,
      );

      return finalTiaowenList;
    } catch (e) {
      throw StateError('四门变计算过程中发生错误：${e.toString()}');
    }
  }

  /// 验证输入参数的有效性
  void _validateInputs(String threeYuan, String gender) {
    if (!['上', '中', '下'].contains(threeYuan)) {
      throw ArgumentError('三元必须是\'上\'、\'中\'或\'下\'，当前值：$threeYuan');
    }
    if (!['男', '女'].contains(gender)) {
      throw ArgumentError('性别必须是\'男\'或\'女\'，当前值：$gender');
    }
  }

  /// 计算基本卦和基本数
  ///
  /// 算法说明：
  /// 1. 将四柱干支转换为数字
  /// 2. 奇数相加作为上卦，偶数相加作为下卦
  /// 3. 对8取模得到卦象
  /// 4. 查表得到基本数
  ///
  /// [fourZhu] 四柱信息
  ///
  /// 返回 (基本卦, 基本数) 的元组
  (String, int) _calculateBasicGua(FourZhu fourZhu) {
    // 获取四柱对应的数字列表
    final numbers = _getGanzhiNumbers(fourZhu);

    // 分别计算奇数和偶数的和
    final oddSum = numbers
        .where((num) => num % 2 == 1)
        .fold(0, (a, b) => a + b);
    final evenSum = numbers
        .where((num) => num % 2 == 0)
        .fold(0, (a, b) => a + b);

    // 对8取模，余0取8
    final upperGuaNum = oddSum % 8 == 0 ? 8 : oddSum % 8;
    final lowerGuaNum = evenSum % 8 == 0 ? 8 : evenSum % 8;

    // 根据数字获取卦名
    final upperGua = constants.houTianNumberGuaMapper[upperGuaNum]!;
    final lowerGua = constants.houTianNumberGuaMapper[lowerGuaNum]!;
    final basicGua = upperGua + lowerGua;

    // 计算基本数
    final basicNumber =
        constants.guaBasicNumberUponMapper[upperGua]! +
        constants.guaBasicNumberUnderMapper[lowerGua]!;

    return (basicGua, basicNumber);
  }

  /// 获取四柱干支对应的数字列表
  ///
  /// [fourZhu] 四柱信息
  ///
  /// 返回干支数字列表
  List<int> _getGanzhiNumbers(FourZhu fourZhu) {
    final numbers = <int>[];

    // 添加天干数字
    final ganList = [
      fourZhu.yearGan,
      fourZhu.monthGan,
      fourZhu.dayGan,
      fourZhu.timeGan,
    ];
    numbers.addAll(ganList.map((gan) => constants.tianGanNumberMapper[gan]!));

    // 添加地支数字
    final zhiList = [
      fourZhu.yearZhi,
      fourZhu.monthZhi,
      fourZhu.dayZhi,
      fourZhu.timeZhi,
    ];
    for (final zhi in zhiList) {
      numbers.addAll(constants.diZhiNumberMapper[zhi]!);
    }

    return numbers;
  }

  /// 计算变爻基数
  ///
  /// [fourZhu] 四柱信息
  /// [threeYuan] 三元（"上"、"中"、"下"）
  /// [gender] 性别（"男"、"女"）
  /// [basicNumber] 基本数
  ///
  /// 返回变爻基数
  int _calculateVariationBase(
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

    // print("三元：$threeYuan，性别：$gender，是否阳年：$isYangYear");
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

    // print("天干系数：$ganFactor，地支系数：$zhiFactor，天干系数：$ganTaixuan，地支系数：$zhiTaixuan");

    final baseNumber = ganTaixuan * ganFactor + zhiTaixuan * zhiFactor;
    // print("基本数：$basicNumber，变爻基数：$baseNumber");
    return baseNumber + basicNumber;
  }

  /// 生成四个卦象
  ///
  /// [basicGua] 基本卦
  /// [basicNumber] 基本数
  /// [variationBase] 变爻基数
  /// [strategies] 卦象生成策略列表
  ///
  /// 返回四卦结果对象
  FourGuaResult _generateFourGua(
    String basicGua,
    int basicNumber,
    int variationBase,
    List<GuaGenerationStrategy> strategies,
  ) {
    final result = <String>[];

    // 第一卦：根据策略生成（通常是互卦）
    String firstGua;
    if (strategies[0].guaType == "错") {
      firstGua = guaToCuoGua(basicGua);
    } else {
      firstGua = guaToHuGua(basicGua);
    }
    result.add(firstGua);

    // 第二卦：第一卦变爻
    final secondGuaBianNumber = variationBase % 9;

    // print("变爻基数：$variationBase，变爻余数：$secondGuaBianNumber");
    final bianYaoList = _getChangePositions(secondGuaBianNumber);

    final firstGuaBinary = guaToBinaryList(firstGua);
    final secondGuaBinary = yaoBianGua(firstGuaBinary, bianYaoList);
    String secondGua = binaryListToGua(secondGuaBinary);

    // 根据策略处理第二卦
    if (strategies[1].exchangeType) {
      secondGua = secondGua.substring(1) + secondGua.substring(0, 1); // 交换上下卦
    }

    if (strategies[1].guaType == "错") {
      secondGua = guaToCuoGua(secondGua);
    }

    result.add(secondGua);

    // 第三卦：根据策略生成（通常是第一卦的互卦）
    String thirdGua;
    if (strategies[2].guaType == "互") {
      thirdGua = guaToHuGua(firstGua);
    } else {
      thirdGua = guaToCuoGua(firstGua);
    }
    result.add(thirdGua);

    // 第四卦：根据策略生成（通常是第二卦的互卦）
    String fourthGua;
    if (strategies[3].guaType == "互") {
      fourthGua = guaToHuGua(secondGua);
    } else {
      fourthGua = guaToCuoGua(secondGua);
    }
    result.add(fourthGua);

    return FourGuaResult(
      basicGua: basicGua,
      basicNumber: basicNumber,
      firstGua: result[0],
      secondGua: result[1],
      thirdGua: result[2],
      fourthGua: result[3],
    );
  }

  /// 根据余数获取需要变化的爻位置
  ///
  /// [remainder] 变爻余数（0-8）
  ///
  /// 返回需要变化的爻位置列表（0表示上爻，5表示初爻）
  List<int> _getChangePositions(int remainder) {
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

  /// 计算秘数列表
  ///
  /// [isYangYear] 是否为阳年
  /// [fourGuaList] 四个卦象列表
  ///
  /// 返回秘数列表
  List<int> _calculateSecretNumbers(bool isYangYear, List<String> fourGuaList) {
    final secretNumbers = <int>[];

    for (final gua in fourGuaList) {
      // 将卦转换为干支
      final ganZhi = _guaToGanzhi(gua, isYangYear);
      final gan = ganZhi.$1;
      final zhi = ganZhi.$2;

      // 获取太玄数
      final ganTaixuan = constants.taixuanGanNumberMapper[gan]!;
      final zhiTaixuan = constants.taixuanZhiNumberMapper[zhi]!;

      // 计算秘数
      int secretNum;
      if (isYangYear) {
        secretNum = int.parse('$ganTaixuan$zhiTaixuan');
      } else {
        secretNum = int.parse('$zhiTaixuan$ganTaixuan');
      }

      secretNumbers.add(secretNum);
    }

    return secretNumbers;
  }

  /// 将卦转换为干支
  ///
  /// [gua] 卦象
  /// [isYangYear] 是否为阳年
  ///
  /// 返回 (天干, 地支) 的元组
  (String, String) _guaToGanzhi(String gua, bool isYangYear) {
    final upperGua = gua[0];
    final lowerGua = gua[1];

    // 获取天干
    final ganOptions = constants.guaTianganMapper[upperGua]!;
    String gan;
    if (ganOptions is List) {
      // 根据年干阴阳选择
      gan = isYangYear ? ganOptions[0] : ganOptions[1];
    } else {
      gan = ganOptions as String;
    }

    // 获取地支
    final zhiOptions = constants.guaDizhiMapper[lowerGua]!;
    String zhi;
    if (zhiOptions is List) {
      // 根据年干阴阳选择
      zhi = isYangYear ? zhiOptions[0] : zhiOptions[1];
    } else {
      zhi = zhiOptions as String;
    }

    return (gan, zhi);
  }

  /// 计算先天数列表
  ///
  /// [fourGuaList] 四个卦象列表
  ///
  /// 返回先天数列表
  List<int> _calculateXiantianNumbers(List<String> fourGuaList) {
    final xiantianNumbers = <int>[];

    for (final gua in fourGuaList) {
      final upperGua = gua[0];
      final lowerGua = gua[1];

      final upperNum = constants.xianTianGuaNumberMapper[upperGua]!;
      final lowerNum = constants.xianTianGuaNumberMapper[lowerGua]!;

      // 上卦为十位，下卦为个位
      final xiantianNum = int.parse('$upperNum$lowerNum');
      xiantianNumbers.add(xiantianNum);
    }

    return xiantianNumbers;
  }

  /// 计算最终条文数
  ///
  /// [xiantianNumbers] 先天数列表
  /// [secretNumbers] 秘数列表
  ///
  /// 返回最终条文数列表
  List<int> _calculateFinalTiaowen(
    List<int> xiantianNumbers,
    List<int> secretNumbers,
  ) {
    final finalTiaowenList = <int>[];

    // 将所有秘数展开为一维列表
    final allSecretNumbers = <int>[];
    for (final secretNum in secretNumbers) {
      // 使用原始的秘数计算公式
      const constants = [19, 37, 53, 79, 103, 237];
      final List<int> tiaowenNumbers = constants
          .map((consts) => secretNum * consts - 7)
          .toList();
      allSecretNumbers.addAll(tiaowenNumbers);
    }

    // 计算最终条文数
    for (final xiantianNum in xiantianNumbers) {
      for (final secretTiaowen in allSecretNumbers) {
        // 使用原始公式：先天数 * 47 + 秘数条文
        int eachNum = xiantianNum * 47 + secretTiaowen;

        // 调整范围到1000-13000之间
        if (eachNum < 1000) {
          finalTiaowenList.add(eachNum + 12000);
        } else if (eachNum > 13000) {
          final tmpRes = eachNum - 12000;
          if (tmpRes > 13000) {
            finalTiaowenList.add(tmpRes - 12000);
          } else {
            finalTiaowenList.add(tmpRes);
          }
        } else {
          finalTiaowenList.add(eachNum);
        }
      }
    }

    return finalTiaowenList;
  }
}

/// 四门变计算便利函数
///
/// 这是一个便利函数，用于保持与旧版本代码的兼容性。
/// 建议新代码直接使用 FourDoorsCalculator 类。
///
/// [fourZhu] 四柱信息
/// [threeYuan] 三元（"上"、"中"、"下"）
/// [gender] 性别（"男"、"女"）
///
/// 返回条文数列表
List<int> fourDoors(FourZhu fourZhu, String threeYuan, String gender) {
  final calculator = FourDoorsCalculator();
  return calculator.calculate(fourZhu, threeYuan, gender);
}

/// 测试四门变功能
///
/// 这个函数用于验证四门变算法的正确性。
void testFourDoors() {
  print('=== 四门变测试 ===');

  // 创建测试用的四柱
  final testFourZhu = FourZhu(
    yearGanzhi: "丙子",
    monthGanzhi: "壬辰",
    dayGanzhi: "庚申",
    timeGanzhi: "甲申",
  );

  try {
    // 测试四门变计算
    final result = fourDoors(testFourZhu, "中", "男");
    print(
      '四柱：${testFourZhu.yearGan}${testFourZhu.yearZhi} '
      '${testFourZhu.monthGan}${testFourZhu.monthZhi} '
      '${testFourZhu.dayGan}${testFourZhu.dayZhi} '
      '${testFourZhu.timeGan}${testFourZhu.timeZhi}',
    );
    print('三元：中，性别：男');
    print('计算结果：$result');
    print('条文数量：${result.length}');

    // 测试不同策略
    final calculator = FourDoorsCalculator();
    final customStrategies = [
      GuaGenerationStrategy(order: 1, guaType: "互", exchangeType: false),
      GuaGenerationStrategy(order: 2, guaType: "错", exchangeType: true),
      GuaGenerationStrategy(order: 3, guaType: "互", exchangeType: false),
      GuaGenerationStrategy(order: 4, guaType: "互", exchangeType: false),
    ];

    final resultCustom = calculator.calculate(
      testFourZhu,
      "中",
      "男",
      strategies: customStrategies,
    );
    print('\n使用自定义策略的结果：$resultCustom');
    print('自定义策略条文数量：${resultCustom.length}');
  } catch (e) {
    print('测试失败：$e');
  }
}
