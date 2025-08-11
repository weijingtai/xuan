import '../../constant/constants.dart' as Constants;
import '../../domain/four_zhu.dart';
import '../../utils/tiao_wen_calculator.dart';
import '../../utils/utils.dart' as Utils;
import '../calculation_strategy.dart';

/// 日柱变卦取数法计算参数
class DayGanZhiGuaParams {
  final FourZhu fourZhu;

  DayGanZhiGuaParams({required this.fourZhu});
}

/// 日柱变卦取数法计算结果
class DayGanZhiGuaResult {
  final FourZhu fourZhu;
  final String dayGanzhi;
  final String baseGua;
  final String huGua;
  final int baseNumber;
  final List<int> tiaoWenNumberList;
  final Map<String, String> tianganGuaMapping;
  final Map<String, String> dizhiGuaMapping;

  DayGanZhiGuaResult({
    required this.fourZhu,
    required this.dayGanzhi,
    required this.baseGua,
    required this.huGua,
    required this.baseNumber,
    required this.tiaoWenNumberList,
    required this.tianganGuaMapping,
    required this.dizhiGuaMapping,
  });
}

/// 条文编号计算策略类 - 日柱变卦取数法
class DayGanZhiGuaCalculation
    extends CalculationStrategy<DayGanZhiGuaParams, DayGanZhiGuaResult> {
  // # 第四种，日柱变卦取数法
  // # 1. 排四柱，日柱配卦法，和天干配卦法，将日柱配上卦
  // #     + 壬甲从乾数，乙癸向坤求，庚来震上里，辛在巽方留，己从离门起，戊以坎为头，丙须艮处出，丁向兑家收
  // #     + 亥子坎宫寅木震，巳午离门丑在坤，卯酉乾金辰是兑，未申艮宫戌巽真
  // # 2. 日支为上卦，日干为下卦 为第一卦
  // # 3. 第一卦互卦为第二卦
  // # 4. 第一卦上卦【后天】数为千位，下卦【后天】数为百位；第二卦上【先天】数为十位，下卦【先天】数为个位
  // # 5. 四位数 加减 96各四次 得出8组数

  @override
  String get name => "日柱变卦取数法";

  @override
  String get description => "排四柱取日柱配卦，日支为上卦日干为下卦得第一卦，求互卦为第二卦，组合四位数加减96生成条文列表";

  @override
  List<String> get detailSteps => [
    "1. 排四柱：获取日柱干支信息",
    "2. 日柱配卦：天干配卦法（壬甲从乾数，乙癸向坤求，庚来震上里，辛在巽方留，己从离门起，戊以坎为头，丙须艮处出，丁向兑家收）；地支配卦法（亥子坎宫寅木震，巳午离门丑在坤，卯酉乾金辰是兑，未申艮宫戌巽真）",
    "3. 第一卦生成：日支为上卦，日干为下卦，组成第一卦",
    "4. 第二卦生成：第一卦的互卦为第二卦",
    "5. 四位数组成：第一卦上卦【后天】数为千位，下卦【后天】数为百位；第二卦上卦【先天】数为十位，下卦【先天】数为个位",
    "6. 生成条文列表：四位数加减96各四次，得出9组数（包含基本数）",
  ];

  @override
  String get school => "日柱变卦流派";

  @override
  DayGanZhiGuaResult calculate(DayGanZhiGuaParams params) {
    final fourZhu = params.fourZhu;
    final dayGanzhi = fourZhu.dayGanzhi;

    // 计算基本卦：日支为上卦，日干为下卦
    final baseGua = _calculateBaseGua(dayGanzhi);

    // 计算互卦：第一卦的互卦为第二卦
    final huGua = _calculateHuGua(baseGua);

    // 计算基本数：组合四位数
    final baseNumber = _calculateBaseNumber(baseGua, huGua);

    // 生成条文列表：四位数加减96各四次得出9组数
    final tiaoWenNumberList = TiaowenCalculator.calculateTiaowenNumberList96(
      baseNumber,
      4,
      withBaseNumber: true,
    );

    return DayGanZhiGuaResult(
      fourZhu: fourZhu,
      dayGanzhi: dayGanzhi,
      baseGua: baseGua,
      huGua: huGua,
      baseNumber: baseNumber,
      tiaoWenNumberList: tiaoWenNumberList,
      tianganGuaMapping: Constants.tianganGuaMapper,
      dizhiGuaMapping: Constants.dizhiGuaMapper,
    );
  }

  /// 计算基本卦
  ///
  /// 日支为上卦，日干为下卦
  static String _calculateBaseGua(String dayGanzhi) {
    final String dayGan = dayGanzhi[0]; // 日干
    final String dayZhi = dayGanzhi[dayGanzhi.length - 1]; // 日支

    final String dayDownGu = Constants.tianganGuaMapper[dayGan]!;
    final String dayUpGu = Constants.dizhiGuaMapper[dayZhi]!;

    return dayUpGu + dayDownGu;
  }

  /// 计算互卦
  static String _calculateHuGua(String baseGua) {
    return Utils.guaToHuGua(baseGua);
  }

  /// 计算基本数
  ///
  /// 第一卦上卦【后天】数为千位，下卦【后天】数为百位；
  /// 第二卦上【先天】数为十位，下卦【先天】数为个位
  static int _calculateBaseNumber(String baseGua, String huGua) {
    final int firstUp = Constants.houTianGuaNumberMapper[baseGua[0]]!;
    final int firstDown =
        Constants.houTianGuaNumberMapper[baseGua[baseGua.length - 1]]!;

    final int secondUp = Constants.xianTianGuaNumberMapper[huGua[0]]!;
    final int secondDown =
        Constants.xianTianGuaNumberMapper[huGua[huGua.length - 1]]!;

    return int.parse('$firstUp$firstDown$secondUp$secondDown');
  }
}

/// 测试函数
void test() {
  // 创建测试用的四柱
  final fourZhu = FourZhu(
    yearGanzhi: "甲子",
    monthGanzhi: "丙寅",
    dayGanzhi: "丁酉",
    timeGanzhi: "庚午",
  );

  final strategy = DayGanZhiGuaCalculation();
  final params = DayGanZhiGuaParams(fourZhu: fourZhu);

  final result = strategy.calculate(params);

  print('测试通过！');
  print('四柱信息: ${result.fourZhu}');
  print('日柱干支: ${result.dayGanzhi}');
  print('基本卦: ${result.baseGua}');
  print('互卦: ${result.huGua}');
  print('基本数: ${result.baseNumber}');
  print('条文列表: ${result.tiaoWenNumberList}');
}
