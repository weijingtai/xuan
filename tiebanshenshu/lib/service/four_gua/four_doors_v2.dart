import '../../constant/constants.dart' as constants;
import 'base_gua_calculator.dart';
import '../../domain/four_zhu.dart';

/// 四门法计算器V2
///
/// 继承基类，实现四门法特有的前四卦生成逻辑
class FourDoorsCalculatorV2 extends BaseGuaCalculationStrategy {
  FourDoorsCalculatorV2({
    required super.fourZhu,
    required super.isOddAsTopGua,
    required super.ganToNumberStrategy,
    required super.zhiToNumberStrategy,
    required super.evenNumberConfig,
    required super.oddNumberConfig,
  });

  /// 四门法的卦象生成配置
  @override
  GuaGenerationConfig getGuaGenerationConfig() {
    return GuaGenerationConfig(
      firstGuaType: "互", // 第一卦：基本卦的互卦
      secondGuaStrategy: GuaStrategy.forSecondGua(
        needExchange: false, // 四门法默认不交换
        needCuoGua: false, // 四门法默认不错卦
        guaType: "本", // 变爻后保持本卦
      ),
      thirdGuaStrategy: GuaStrategy.forThirdGua(
        needExchange: false, // 四门法默认不交换
        needCuoGua: false, // 四门法默认不错卦
        guaType: "互",
        baseGuaSource: 'first', // 变爻后保持本卦
      ), // 第三卦：第一卦的互卦
      fourthGuaStrategy: GuaStrategy.forFourthGua(
        baseGuaSource: "second",
        needExchange: false, // 四门法默认不交换
        needCuoGua: false, // 四门法默认不错卦
        guaType: "互", // 变爻后保持本卦
      ),
    );
  }

  /// 执行完整的四门法计算
  List<int> calculate(
    GetFirstFourParams params, {
    GuaGenerationConfig? customConfig,
  }) {
    try {
      // 1. 参数验证
      _validateInputs(params.threeYuan, params.gender);

      // 2. 如果提供了自定义配置，临时使用
      final originalConfig = getGuaGenerationConfig();
      if (customConfig != null) {
        // 这里可以实现配置覆盖逻辑
      }

      // 3. 生成前四卦
      final firstFourResult = generateFirstFourGua(
        params.fourZhu,
        params.threeYuan,
        params.gender,
      );

      // 4. 计算秘数列表
      final secretNumbers = _calculateSecretNumbers(
        params.fourZhu.isYangGanYear,
        firstFourResult.fourGuaList,
      );

      // 5. 计算先天数列表
      final xiantianNumbers = _calculateXiantianNumbers(
        firstFourResult.fourGuaList,
      );

      // 6. 计算最终条文数
      final finalTiaowenList = _calculateFinalTiaowen(
        xiantianNumbers,
        secretNumbers,
      );

      return finalTiaowenList;
    } catch (e) {
      throw StateError('四门法计算过程中发生错误：${e.toString()}');
    }
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

  /// 验证输入参数的有效性
  void _validateInputs(String threeYuan, String gender) {
    if (!['上', '中', '下'].contains(threeYuan)) {
      throw ArgumentError('三元必须是\'上\'、\'中\'或\'下\'，当前值：$threeYuan');
    }
    if (!['男', '女'].contains(gender)) {
      throw ArgumentError('性别必须是\'男\'或\'女\'，当前值：$gender');
    }
  }

  @override
  String get description => "由基本卦生出四卦";

  @override
  List<String> get detailSteps => [
    "1. 根据四柱信息生成基本卦",
    "2. 通过变爻规则生成四个卦象",
    "3. 计算秘数和先天数",
    "4. 生成最终的条文数列表",
  ];

  @override
  String get name => '四门法';
}
