import 'base_gua_calculator.dart';
import '../../utils/utils.dart';
import '../gun_fa.dart';

/// 八卦滚法计算器V2
///
/// 继承基类，实现八卦滚法特有的前四卦生成逻辑
class EightGuaGunFaCalculatorV2 extends BaseGuaCalculationStrategy {
  late final NumberCalculator _numberCalculator = NumberCalculator();

  EightGuaGunFaCalculatorV2({
    required super.fourZhu,
    required super.evenNumberConfig,
    required super.oddNumberConfig,
    required super.isOddAsTopGua,
    required super.ganToNumberStrategy,
    required super.zhiToNumberStrategy,
  });

  /// 八卦滚法的卦象生成配置
  @override
  GuaGenerationConfig getGuaGenerationConfig() {
    return GuaGenerationConfig(
      firstGuaType: "互", // 第一卦：基本卦的互卦
      secondGuaStrategy: GuaStrategy(
        needExchange: false, // 八卦滚法需要上下交换
        needCuoGua: false, // 八卦滚法需要错卦
        guaType: "本", // 变爻后保持本卦
        baseGuaSource: 'first',
        needVariation: true,
      ),
      thirdGuaStrategy: GuaStrategy(
        needExchange: false,
        needCuoGua: false,
        guaType: "互",
        baseGuaSource: 'first',
      ),
      fourthGuaStrategy: GuaStrategy(
        needExchange: false,
        needCuoGua: false,
        guaType: "互",
        baseGuaSource: 'second', // 变爻后保持本卦
      ), // 第四卦：第二卦的互卦
    );
  }

  /// 执行完整的八卦滚法计算
  List<int> calculate(GetFirstFourParams params) {
    try {
      // 1. 参数验证
      _validateInputs(params.gender, params.threeYuan);
      // 2. 生成前四卦
      final firstFourResult = generateFirstFourGua(
        params.fourZhu,
        params.threeYuan,
        params.gender,
      );
      // 3. 生成后四卦（八卦滚法特有）
      final lastFourGua = _generateLastFourGua(
        firstFourResult.fourGuaList,
        firstFourResult.variationBase,
      );
      // 4. 合并八个卦
      final eightGuaList = [...firstFourResult.fourGuaList, ...lastFourGua];
      // 5. 计算条文数
      final tiaowenNumbers = _calculateTiaowenNumbers(eightGuaList);
      // return (eightGuaList, tiaowenNumbers);
      return tiaowenNumbers;
    } catch (e) {
      throw StateError('八卦滚法计算过程中发生错误：${e.toString()}');
    }
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

  /// 生成后四个卦（八卦滚法特有逻辑）
  List<String> _generateLastFourGua(
    List<String> firstFour,
    int bianYaoBaseNumber,
  ) {
    final result = <String>[];

    // 第五卦的变爻数
    final fifthBianYaoNum = bianYaoBaseNumber % 6;
    final bianYaoPositions = getChangePositions(fifthBianYaoNum);
    // 第五到第八卦：分别对前四卦进行变爻和上下交换
    for (final gua in firstFour) {
      final changedGua = _generateGuaWithExchange(gua, bianYaoPositions);
      result.add(changedGua);
    }

    return result;
  }

  /// 生成变爻并上下交换的卦
  String _generateGuaWithExchange(
    String originalGua,
    List<int> bianYaoPositions,
  ) {
    final binaryList = guaToBinaryList(originalGua);
    final changedBinary = yaoBianGua(binaryList, bianYaoPositions);
    final changedGua = binaryListToGua(changedBinary);
    // 上下交换
    return changedGua[1] + changedGua[0];
  }

  @override
  String get description => "八卦滚法";

  @override
  List<String> get detailSteps => [];

  @override
  String get name => "八卦滚";
}
