/// 八卦滚法计算器
///
/// 本模块实现了铁板神数中的八卦滚法计算功能，包括：
/// 1. 基本卦的生成
/// 2. 八卦滚法的核心计算逻辑
/// 3. 卦象变换的辅助功能
///
/// 主要功能：
/// - 根据四柱信息计算基本卦
/// - 生成八个卦的完整序列
/// - 计算每个卦的条文数
///
/// 作者：从tiaowen_number_calculator.py中提取并重构
/// 版本：2.0

import '../constant/constants.dart';
import '../domain/four_zhu.dart';

/// 八卦滚法计算器主类
///
/// 负责协调整个八卦滚法的计算流程，遵循高内聚低耦合的设计原则。
class EightGuaGunFaCalculator {
  late final GuaConverter _guaConverter;
  late final NumberCalculator _numberCalculator;
  late final GuaGenerator _guaGenerator;

  /// 初始化计算器
  EightGuaGunFaCalculator() {
    _guaConverter = GuaConverter();
    _numberCalculator = NumberCalculator();
    _guaGenerator = GuaGenerator(_guaConverter);
  }

  /// 执行八卦滚法计算
  ///
  /// [fourZhu] 四柱信息
  /// [gender] 性别（"男" 或 "女"）
  /// [threeYuan] 三元（"上"、"中"、"下"）
  ///
  /// 返回 (八个卦的列表, 对应的条文数列表)
  ///
  /// 抛出 [ArgumentError] 当输入参数无效时
  (List<String>, List<int>) calculate(
    FourZhu fourZhu,
    String gender,
    String threeYuan,
  ) {
    _validateInputs(gender, threeYuan);

    // 1. 计算基本卦和基本数
    final (basicGua, basicNumber) = _calculateBasicGua(fourZhu);

    print('基本卦: $basicGua');
    print('基本数: $basicNumber');

    // 2. 计算变爻基数
    final bianYaoBaseNumber = _calculateBianYaoBaseNumber(
      fourZhu,
      gender,
      threeYuan,
      basicNumber,
    );
    print('变爻基数: $bianYaoBaseNumber');

    // 3. 生成八个卦
    final eightGuaList = _guaGenerator.generateEightGua(
      basicGua,
      bianYaoBaseNumber,
    );
    print('八个卦: $eightGuaList');

    // 4. 计算条文数
    final tiaowenNumbers = _calculateTiaowenNumbers(eightGuaList);

    return (eightGuaList, tiaowenNumbers);
  }

  /// 验证输入参数
  void _validateInputs(String gender, String threeYuan) {
    if (gender != "男" && gender != "女") {
      throw ArgumentError('性别必须是"男"或"女"，当前值：$gender');
    }
    if (threeYuan != "上" && threeYuan != "中" && threeYuan != "下") {
      throw ArgumentError('三元必须是"上"、"中"或"下"，当前值：$threeYuan');
    }
  }

  /// 计算基本卦和基本数
  (String, int) _calculateBasicGua(FourZhu fourZhu) {
    return _numberCalculator.fourZhuToBasicGua(
      fourZhu,
      EnumGanZhiNumberStrategy.taiXuan,
      8,
      houTianNumberGuaMapper,
    );
  }

  /// 计算变爻基数
  int _calculateBianYaoBaseNumber(
    FourZhu fourZhu,
    String gender,
    String threeYuan,
    int basicNumber,
  ) {
    final (baseGan, baseZhi) = _numberCalculator.calculateBaseBianNumbers(
      fourZhu.yearGanTaixuanNum,
      fourZhu.yearZhiTaixuanNum,
      fourZhu.isYangGanYear,
      threeYuan,
      gender,
    );
    return baseGan + baseZhi + basicNumber;
  }

  /// 计算八个卦的条文数
  List<int> _calculateTiaowenNumbers(List<String> eightGuaList) {
    final tiaowenNumbers = <int>[];
    for (final gua in eightGuaList) {
      final (a, b, c) = _numberCalculator.getGuaThreeNumbers(gua);
      final guaTiaowen = _numberCalculator.calculateGuaTiaowenList(a, b, c);
      tiaowenNumbers.addAll(guaTiaowen);
    }
    return tiaowenNumbers;
  }
}

/// 卦象转换器
///
/// 负责卦象与二进制列表之间的转换，以及各种卦象变换操作。
class GuaConverter {
  /// 将卦名转换为二进制列表
  ///
  /// [gua] 卦名（如"坤乾"）
  ///
  /// 返回 六位二进制列表，从上爻到下爻
  List<int> toBinaryList(String gua) {
    if (gua.length == 2) {
      return [...guaBinaryMapper[gua[0]]!, ...guaBinaryMapper[gua[1]]!];
    } else {
      return guaBinaryMapper[gua[0]]!;
    }
  }

  /// 将二进制列表转换为卦名
  ///
  /// [binaryList] 六位二进制列表
  ///
  /// 返回 卦名（如"坤乾"）
  String fromBinaryList(List<int> binaryList) {
    final upperBinary = binaryList.sublist(0, 3).join();
    final lowerBinary = binaryList.sublist(3).join();
    return binaryStrGuaMapper[upperBinary]! + binaryStrGuaMapper[lowerBinary]!;
  }

  /// 对卦进行爻变
  ///
  /// [binaryList] 原始二进制列表
  /// [yaoPositions] 变爻位置列表（0-5，对应上爻到下爻）
  ///
  /// 返回 变爻后的二进制列表
  List<int> changeYao(List<int> binaryList, List<int> yaoPositions) {
    final result = List<int>.from(binaryList);
    for (final pos in yaoPositions) {
      result[pos] = 1 - result[pos]; // 0变1，1变0
    }
    return result;
  }

  /// 计算互卦
  ///
  /// 互卦规则：取本卦的2、3、4爻为上卦，3、4、5爻为下卦
  ///
  /// [guaName] 本卦名
  ///
  /// 返回 互卦名
  String toHuGua(String guaName) {
    final binaryList = toBinaryList(guaName);
    final upperHu = binaryList.sublist(1, 4); // 2、3、4爻
    final lowerHu = binaryList.sublist(2, 5); // 3、4、5爻

    final upperBinaryStr = upperHu.join();
    final lowerBinaryStr = lowerHu.join();

    final upperGua = binaryStrGuaMapper[upperBinaryStr]!;
    final lowerGua = binaryStrGuaMapper[lowerBinaryStr]!;

    return upperGua + lowerGua;
  }

  /// 计算错卦
  ///
  /// 错卦规则：阳爻变阴爻，阴爻变阳爻
  ///
  /// [guaName] 本卦名
  ///
  /// 返回 错卦名
  String toCuoGua(String guaName) {
    final binaryList = toBinaryList(guaName);
    final cuoBinary = binaryList.map((x) => 1 - x).toList(); // 全部取反
    return fromBinaryList(cuoBinary);
  }
}

/// 数字计算器
///
/// 负责各种数字计算功能，包括干支转数字、基本卦计算等。
class NumberCalculator {
  /// 四柱转基本卦
  ///
  /// 计算步骤：
  /// 1. 将四柱干支转换为数字
  /// 2. 奇数相加为上卦，偶数相加为下卦
  /// 3. 取模后映射为卦名
  /// 4. 计算基本数
  ///
  /// [fourZhu] 四柱信息
  /// [numberType] 干支转数字的策略
  /// [modNum] 取模数
  /// [numberToGuaMapper] 数字到卦的映射
  /// [withOddNumber] 是否包含奇数个数
  ///
  /// 返回 (基本卦名, 基本数)
  (String, int) fourZhuToBasicGua(
    FourZhu fourZhu,
    EnumGanZhiNumberStrategy numberType,
    int modNum,
    Map<int, String> numberToGuaMapper, {
    bool withOddNumber = false,
  }) {
    // 1. 四柱转数字列表
    final numberList = _convertFourZhuToNumbers(fourZhu, numberType);

    // 2. 如果需要，添加奇数个数
    final finalNumberList = List<int>.from(numberList);
    if (withOddNumber) {
      final oddCount = numberList.where((num) => num % 2 == 1).length;
      finalNumberList.add(oddCount);
    }

    // 3. 分别计算奇数和偶数的和
    final oddSum = finalNumberList
        .where((num) => num % 2 == 1)
        .fold(0, (a, b) => a + b);
    final evenSum = finalNumberList
        .where((num) => num % 2 == 0)
        .fold(0, (a, b) => a + b);

    // 4. 取模得到上下卦
    final upperGuaNum = oddSum % modNum == 0
        ? modNum
        : oddSum % modNum; // 余数为0时取modNum
    final lowerGuaNum = evenSum % modNum == 0 ? modNum : evenSum % modNum;

    // 5. 映射为卦名
    final basicGua =
        numberToGuaMapper[upperGuaNum]! + numberToGuaMapper[lowerGuaNum]!;

    // 6. 计算基本数
    final basicNumber =
        (guaBasicNumberUponMapper[basicGua[0]]! +
        guaBasicNumberUnderMapper[basicGua[1]]!);

    return (basicGua, basicNumber);
  }

  /// 计算基础变数
  ///
  /// 根据三元和性别的不同组合，计算干支的基础变数。
  ///
  /// [ganTaixuanNum] 年干太玄数
  /// [zhiTaixuanNum] 年支太玄数
  /// [isYangYear] 是否阳年
  /// [threeYuan] 三元（上、中、下）
  /// [gender] 性别
  ///
  /// 返回 (干基础变数, 支基础变数)
  (int, int) calculateBaseBianNumbers(
    int ganTaixuanNum,
    int zhiTaixuanNum,
    bool isYangYear,
    String threeYuan,
    String gender,
  ) {
    if (threeYuan == "上") {
      return (ganTaixuanNum * 10, zhiTaixuanNum * 1);
    } else if (threeYuan == "下") {
      return (ganTaixuanNum * 1, zhiTaixuanNum * 10);
    } else {
      // 中元
      if ((isYangYear && gender == "男") || (!isYangYear && gender == "女")) {
        return (ganTaixuanNum * 100, zhiTaixuanNum * 10);
      } else {
        return (ganTaixuanNum * 10, zhiTaixuanNum * 100);
      }
    }
  }

  /// 根据变爻数获取变爻位置
  ///
  /// [bianYaoNum] 变爻数（0-8）
  ///
  /// 返回 变爻位置列表
  List<int> getBianYaoPositions(int bianYaoNum) {
    const positionMap = {
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
    return positionMap[bianYaoNum] ?? [];
  }

  /// 获取卦的三个基本数
  ///
  /// [guaName] 卦名（如"坤坎"）
  ///
  /// 返回 (先天八卦顺序, 先天洛书数, 后天洛书数)
  (int, int, int) getGuaThreeNumbers(String guaName) {
    final upperGua = guaName[0];
    final lowerGua = guaName[1];

    // 先天八卦顺序
    final a = int.parse(
      '${xianTianGuaNumberMapper[upperGua]}${xianTianGuaNumberMapper[lowerGua]}',
    );

    // 先天洛书数
    final b = int.parse(
      '${xiantianGuaLuoshuNumberMapper[upperGua]}${xiantianGuaLuoshuNumberMapper[lowerGua]}',
    );

    // 后天洛书数
    final c = int.parse(
      '${houtianGuaLuoshuNumberMapper[upperGua]}${houtianGuaLuoshuNumberMapper[lowerGua]}',
    );

    return (a, b, c);
  }

  /// 计算卦的条文列表
  ///
  /// 根据三个基本数计算六个条文数：
  /// a*100+b, a*100+c, b*100+a, b*100+c, c*100+a, c*100+b
  ///
  /// [a], [b], [c] 三个基本数
  ///
  /// 返回 六个条文数
  List<int> calculateGuaTiaowenList(int a, int b, int c) {
    return [
      a * 100 + b,
      a * 100 + c,
      b * 100 + a,
      b * 100 + c,
      c * 100 + a,
      c * 100 + b,
    ];
  }

  /// 将四柱转换为数字列表
  List<int> _convertFourZhuToNumbers(
    FourZhu fourZhu,
    EnumGanZhiNumberStrategy numberType,
  ) {
    switch (numberType) {
      case EnumGanZhiNumberStrategy.ganZhi:
        final result = [
          tianGanNumberMapper[fourZhu.yearGan]!,
          tianGanNumberMapper[fourZhu.monthGan]!,
          tianGanNumberMapper[fourZhu.dayGan]!,
          tianGanNumberMapper[fourZhu.timeGan]!,
        ];
        // 添加地支数字
        for (final zhi in [
          fourZhu.yearZhi,
          fourZhu.monthZhi,
          fourZhu.dayZhi,
          fourZhu.timeZhi,
        ]) {
          result.addAll(diZhiNumberMapper[zhi]!);
        }
        return result;

      case EnumGanZhiNumberStrategy.flatedGanZhi:
        return [
          tianGanNumberMapper[fourZhu.yearGan]!,
          tianGanNumberMapper[fourZhu.monthGan]!,
          tianGanNumberMapper[fourZhu.dayGan]!,
          tianGanNumberMapper[fourZhu.timeGan]!,
          diZhiFlatedNumberMapper[fourZhu.yearZhi]!,
          diZhiFlatedNumberMapper[fourZhu.monthZhi]!,
          diZhiFlatedNumberMapper[fourZhu.dayZhi]!,
          diZhiFlatedNumberMapper[fourZhu.timeZhi]!,
        ];

      case EnumGanZhiNumberStrategy.taiXuan:
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
  }
}

/// 卦生成器
///
/// 负责生成八卦滚法中的八个卦。
class GuaGenerator {
  final GuaConverter _converter;
  final NumberCalculator _numberCalc;

  /// 初始化卦生成器
  GuaGenerator(this._converter) : _numberCalc = NumberCalculator();

  /// 生成八个卦
  ///
  /// [basicGua] 基本卦
  /// [bianYaoBaseNumber] 变爻基数
  ///
  /// 返回 八个卦的列表
  List<String> generateEightGua(String basicGua, int bianYaoBaseNumber) {
    // 生成前四个卦
    final firstFour = _generateFirstFourGua(basicGua, bianYaoBaseNumber);

    // 生成后四个卦
    final lastFour = _generateLastFourGua(firstFour, bianYaoBaseNumber);

    return [...firstFour, ...lastFour];
  }

  /// 生成前四个卦
  List<String> _generateFirstFourGua(String basicGua, int bianYaoBaseNumber) {
    final result = <String>[];

    // 第一卦：基本卦的互卦
    final firstGua = _converter.toHuGua(basicGua);
    result.add(firstGua);

    // 第二卦：第一卦变爻后错卦并上下交换
    final secondGua = _generateSecondGua(firstGua, bianYaoBaseNumber);
    print(secondGua);
    result.add(secondGua);

    // 第三卦：第一卦的互卦
    final thirdGua = _converter.toHuGua(firstGua);
    result.add(thirdGua);

    // 第四卦：第二卦的互卦
    final fourthGua = _converter.toHuGua(secondGua);
    result.add(fourthGua);

    return result;
  }

  /// 生成第二卦
  String _generateSecondGua(String firstGua, int bianYaoBaseNumber) {
    // 计算变爻
    final bianYaoNum = bianYaoBaseNumber % 9;
    print('变爻数: $bianYaoNum');
    final bianYaoPositions = _numberCalc.getBianYaoPositions(bianYaoNum);

    // 第一卦变爻
    final binaryList = _converter.toBinaryList(firstGua);
    final changedBinary = _converter.changeYao(binaryList, bianYaoPositions);
    final changedGua = _converter.fromBinaryList(changedBinary);

    // 上下交换
    final exchangedGua = changedGua[1] + changedGua[0];

    // 错卦
    return _converter.toCuoGua(exchangedGua);
  }

  /// 生成后四个卦
  List<String> _generateLastFourGua(
    List<String> firstFour,
    int bianYaoBaseNumber,
  ) {
    final result = <String>[];

    // 第五卦的变爻数
    final fifthBianYaoNum = bianYaoBaseNumber % 6;
    final bianYaoPositions = _numberCalc.getBianYaoPositions(fifthBianYaoNum);

    // 第五卦：第一卦变爻后上下交换
    final fifthGua = _generateGuaWithExchange(firstFour[0], bianYaoPositions);
    result.add(fifthGua);

    // 第六卦：第二卦变爻后上下交换
    final sixthGua = _generateGuaWithExchange(firstFour[1], bianYaoPositions);
    result.add(sixthGua);

    // 第七卦：第三卦变爻后上下交换
    final seventhGua = _generateGuaWithExchange(firstFour[2], bianYaoPositions);
    result.add(seventhGua);

    // 第八卦：第四卦变爻后上下交换
    final eighthGua = _generateGuaWithExchange(firstFour[3], bianYaoPositions);
    result.add(eighthGua);

    return result;
  }

  /// 生成变爻并上下交换的卦
  String _generateGuaWithExchange(
    String originalGua,
    List<int> bianYaoPositions,
  ) {
    final binaryList = _converter.toBinaryList(originalGua);
    final changedBinary = _converter.changeYao(binaryList, bianYaoPositions);
    final changedGua = _converter.fromBinaryList(changedBinary);

    // 上下交换
    return changedGua[1] + changedGua[0];
  }
}

/// 卦生成策略类
///
/// 用于配置卦的生成方式，支持不同的变换策略。
class GuaGenerationStrategy {
  /// 生成的卦是第几个
  final int order;

  /// 生成的卦的类型（"互"、"错"、"本"）
  final String guaType;

  /// 是否要上下卦交换
  final bool exchangeType;

  /// 初始化生成策略
  ///
  /// [order] 生成的卦是第几个
  /// [guaType] 生成的卦的类型（"互"、"错"、"本"）
  /// [exchangeType] 是否要上下卦交换
  GuaGenerationStrategy(this.order, this.guaType, this.exchangeType);
}

// 便利函数，保持向后兼容

/// 八卦滚法计算便利函数
///
/// [fourZhu] 四柱信息
/// [gender] 性别
/// [threeYuan] 三元
///
/// 返回 (八个卦的列表, 条文数列表)
(List<String>, List<int>) eightGuaGunfa(
  FourZhu fourZhu,
  String gender,
  String threeYuan,
) {
  final calculator = EightGuaGunFaCalculator();
  return calculator.calculate(fourZhu, gender, threeYuan);
}

/// 获取卦的三个基本数（便利函数）
///
/// [guaName] 卦名
///
/// 返回 (先天八卦顺序, 先天洛书数, 后天洛书数)
(int, int, int) gunFaEachGuaThreeNumber(String guaName) {
  final calculator = NumberCalculator();
  return calculator.getGuaThreeNumbers(guaName);
}

/// 测试八卦滚法功能
void testEightGuaGunFa() {
  print("=== 八卦滚法测试 ===");

  // 测试基本功能
  try {
    // 测试gunFaEachGuaThreeNumber函数
    final (a1, b1, c1) = gunFaEachGuaThreeNumber("巽艮");
    assert(a1 == 57, '巽艮卦a值错误：期望57，实际$a1');
    assert(b1 == 26, '巽艮卦b值错误：期望26，实际$b1');
    assert(c1 == 48, '巽艮卦c值错误：期望48，实际$c1');
    print("✓ 巽艮卦测试通过");

    final (a2, b2, c2) = gunFaEachGuaThreeNumber("坤坎");
    assert(a2 == 86, '坤坎卦a值错误：期望86，实际$a2');
    assert(b2 == 17, '坤坎卦b值错误：期望17，实际$b2');
    assert(c2 == 21, '坤坎卦c值错误：期望21，实际$c2');
    print("✓ 坤坎卦测试通过");

    // 测试完整计算流程
    final fourZhu = FourZhu(
      yearGanzhi: "丙戌",
      monthGanzhi: "庚寅",
      dayGanzhi: "丁亥",
      timeGanzhi: "辛亥",
    );
    final (eightGuaList, tiaowenNumbers) = eightGuaGunfa(fourZhu, "女", "下");

    assert(eightGuaList.length == 8, '八卦数量错误：期望8，实际${eightGuaList.length}');
    print('✓ 八卦生成测试通过，生成卦：$eightGuaList');

    print("\n=== 所有测试通过！ ===");
  } catch (e) {
    print('✗ 测试失败：$e');
    rethrow;
  }
}

void main() {
  // testEightGuaGunFa();
  final res = eightGuaGunfa(
    FourZhu(
      yearGanzhi: "丙戌",
      monthGanzhi: "庚寅",
      dayGanzhi: "丁亥",
      timeGanzhi: "辛亥",
    ),
    "女",
    "下",
  );
  print(res);
}
