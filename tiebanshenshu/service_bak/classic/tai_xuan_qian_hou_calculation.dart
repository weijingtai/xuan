import '../../constant/constants.dart' as Constants;
import '../../domain/four_zhu.dart';
import '../../utils/tiao_wen_calculator.dart';
import '../../utils/utils.dart' as GuaUtils;
import '../calculation_strategy.dart';

/// 太玄取数法（2）计算参数
class TaiXuanQianHouParams {
  final FourZhu fourZhu;
  final int correctionKeNumber;

  TaiXuanQianHouParams({
    required this.fourZhu,
    required this.correctionKeNumber,
  });
}

/// 太玄取数法（2）计算结果
class TaiXuanQianHouResult {
  final FourZhu fourZhu;
  final int correctionKeNumber;
  final String yearMonthGua;
  final String yearMonthCuoGua;
  final int yearMonthBaseNumber;
  final int firstNumber;
  final List<int> firstTiaoWenList;
  final String dayTimeGua;
  final String dayTimeCuoGua;
  final int dayTimeBaseNumber;
  final int secondNumber;
  final List<int> secondTiaoWenList;
  final List<int> allTiaoWenNumberList;

  TaiXuanQianHouResult({
    required this.fourZhu,
    required this.correctionKeNumber,
    required this.yearMonthGua,
    required this.yearMonthCuoGua,
    required this.yearMonthBaseNumber,
    required this.firstNumber,
    required this.firstTiaoWenList,
    required this.dayTimeGua,
    required this.dayTimeCuoGua,
    required this.dayTimeBaseNumber,
    required this.secondNumber,
    required this.secondTiaoWenList,
    required this.allTiaoWenNumberList,
  });
}

/// 条文编号计算策略类 - 太玄取数法（2）
class TaiXuanQianHouCalculation
    extends CalculationStrategy<TaiXuanQianHouParams, TaiXuanQianHouResult> {
  // # 第六种，太玄取数法（2）
  // # 1. 排四柱，四柱天干与地支配太玄数
  // # 2. 年柱月柱和为前卦-用先天卦：年柱干支相加模"8"取余，取先天卦作为下卦；月柱同理，做为上挂
  // # 3. 取错卦。上卦为千位、下卦为百位、错卦上为十、错下为各 -- 用先天卦数
  // # 4. 取六亲考刻中已考订的基本数，余其相加，次数为年月基本数，加减96各四次共8各条文数
  // # -------
  // # 5. 日柱 时柱 用后天卦 ----- 遇"10"不用，只取个位
  // # 6. 取其错卦 作为第二卦
  // # 7. 上卦为千位，下卦为百位，二上为十，而下为个  --- 用后天数
  // # 8. 取六亲考刻中已考订的基本数，余其相加，次数为年月基本数，加减96各四次共8各条文数

  @override
  String get name => "太玄前后卦";

  @override
  String get description => "排四柱配太玄数，年月用先天卦，日时用后天卦，分别取错卦组合四位数，加六亲考刻数生成条文列表";

  @override
  List<String> get detailSteps => [
    "1. 排四柱：获取年月日时的干支信息，配上太玄数",
    "2. 年月卦计算：年柱干支相加模8取余得先天卦作为下卦，月柱同理作为上卦",
    "3. 年月错卦：取年月卦的错卦，上卦为千位、下卦为百位、错卦上为十位、错卦下为个位（用先天卦数）",
    "4. 年月条文：取六亲考刻中已考订的基本数，与年月基本数相加，加减96各四次共8个条文数",
    "5. 日时卦计算：日柱时柱用后天卦，遇10不用只取个位",
    "6. 日时错卦：取日时卦的错卦作为第二卦",
    "7. 日时四位数：上卦为千位，下卦为百位，错卦上为十位，错卦下为个位（用后天数）",
    "8. 日时条文：取六亲考刻中已考订的基本数，与日时基本数相加，加减96各四次共8个条文数",
  ];

  @override
  String get school => "太玄取数流派";

  @override
  TaiXuanQianHouResult calculate(TaiXuanQianHouParams params) {
    final fourZhu = params.fourZhu;
    final correctionKeNumber = params.correctionKeNumber;

    // 计算年月卦（用先天卦）
    final yearMonthGua = _calculateYearMonthGua(fourZhu);
    final yearMonthCuoGua = GuaUtils.guaToCuoGua(yearMonthGua);
    final yearMonthBaseNumber = _calculateYearMonthBaseNumber(fourZhu);
    final firstNumber = yearMonthBaseNumber + correctionKeNumber;

    // 生成年月条文列表：加减96各四次共8个条文数
    final firstTiaoWenList = TiaowenCalculator.calculateTiaowenNumberList96(
      firstNumber,
      4,
      withBaseNumber: true,
    );

    // 计算日时卦（用后天卦）
    final dayTimeGua = _calculateDayTimeGua(fourZhu);
    final dayTimeCuoGua = GuaUtils.guaToCuoGua(dayTimeGua);
    final dayTimeBaseNumber = _calculateDayTimeBaseNumber(fourZhu);
    final secondNumber = dayTimeBaseNumber + correctionKeNumber;

    // 生成日时条文列表：加减96各四次共8个条文数
    final secondTiaoWenList = TiaowenCalculator.calculateTiaowenNumberList96(
      secondNumber,
      4,
      withBaseNumber: true,
    );

    // 合并所有条文列表
    final allTiaoWenNumberList = [...firstTiaoWenList, ...secondTiaoWenList];

    return TaiXuanQianHouResult(
      fourZhu: fourZhu,
      correctionKeNumber: correctionKeNumber,
      yearMonthGua: yearMonthGua,
      yearMonthCuoGua: yearMonthCuoGua,
      yearMonthBaseNumber: yearMonthBaseNumber,
      firstNumber: firstNumber,
      firstTiaoWenList: firstTiaoWenList,
      dayTimeGua: dayTimeGua,
      dayTimeCuoGua: dayTimeCuoGua,
      dayTimeBaseNumber: dayTimeBaseNumber,
      secondNumber: secondNumber,
      secondTiaoWenList: secondTiaoWenList,
      allTiaoWenNumberList: allTiaoWenNumberList,
    );
  }

  /// 计算年月卦（用先天卦）
  ///
  /// 年柱干支相加模8取余，取先天卦作为下卦；月柱同理，做为上卦
  static String _calculateYearMonthGua(FourZhu fourZhu) {
    final yearZhuGuaNumber =
        (fourZhu.yearGanTaixuanNum + fourZhu.yearZhiTaixuanNum) % 8;
    final yearGua = Constants
        .xianTianNumberGuaMapper[yearZhuGuaNumber == 0 ? 8 : yearZhuGuaNumber]!;

    final monthZhuGuaNumber =
        (fourZhu.monthGanTaixuanNum + fourZhu.monthZhiTaixuanNum) % 8;
    final monthGua =
        Constants.xianTianNumberGuaMapper[monthZhuGuaNumber == 0
            ? 8
            : monthZhuGuaNumber]!;

    return '$monthGua$yearGua';
  }

  /// 计算年月基本数（用先天卦数）
  ///
  /// 上卦为千位、下卦为百位、错卦上为十位、错卦下为个位
  static int _calculateYearMonthBaseNumber(FourZhu fourZhu) {
    final yearMonthGua = _calculateYearMonthGua(fourZhu);
    final yearMonthCuoGua = GuaUtils.guaToCuoGua(yearMonthGua);

    final numberString = [
      Constants.xianTianGuaNumberMapper[yearMonthGua[0]]!.toString(),
      Constants.xianTianGuaNumberMapper[yearMonthGua[1]]!.toString(),
      Constants.xianTianGuaNumberMapper[yearMonthCuoGua[0]]!.toString(),
      Constants.xianTianGuaNumberMapper[yearMonthCuoGua[1]]!.toString(),
    ].join();

    return int.parse(numberString);
  }

  /// 计算日时卦（用后天卦，遇10不用只取个位）
  static String _calculateDayTimeGua(FourZhu fourZhu) {
    // 日柱干支相加，遇10不用只取个位
    final daySum = fourZhu.dayGanTaixuanNum + fourZhu.dayZhiTaixuanNum;
    final dayZhuGuaNumber = daySum == 10 ? 0 : daySum % 10;
    final dayGua = Constants
        .houTianNumberGuaMapper[dayZhuGuaNumber == 0 ? 8 : dayZhuGuaNumber]!;

    // 时柱干支相加，遇10不用只取个位
    final timeSum = fourZhu.timeGanTaixuanNum + fourZhu.timeZhiTaixuanNum;
    final timeZhuGuaNumber = timeSum == 10 ? 0 : timeSum % 10;
    final timeGua = Constants
        .houTianNumberGuaMapper[timeZhuGuaNumber == 0 ? 8 : timeZhuGuaNumber]!;

    return '$timeGua$dayGua';
  }

  /// 计算日时基本数（用后天数）
  ///
  /// 上卦为千位，下卦为百位，错卦上为十位，错卦下为个位
  static int _calculateDayTimeBaseNumber(FourZhu fourZhu) {
    final dayTimeGua = _calculateDayTimeGua(fourZhu);
    final dayTimeCuoGua = GuaUtils.guaToCuoGua(dayTimeGua);

    final numberString = [
      Constants.houTianGuaNumberMapper[dayTimeGua[0]]!.toString(),
      Constants.houTianGuaNumberMapper[dayTimeGua[1]]!.toString(),
      Constants.houTianGuaNumberMapper[dayTimeCuoGua[0]]!.toString(),
      Constants.houTianGuaNumberMapper[dayTimeCuoGua[1]]!.toString(),
    ].join();

    return int.parse(numberString);
  }
}

/// 测试函数
void test() {
  // 创建测试用的四柱
  final fourZhu = FourZhu(
    yearGanzhi: "甲子",
    monthGanzhi: "丙寅",
    dayGanzhi: "戊辰",
    timeGanzhi: "庚午",
  );

  final strategy = TaiXuanQianHouCalculation();
  final params = TaiXuanQianHouParams(
    fourZhu: fourZhu,
    correctionKeNumber: 123, // 示例六亲考刻数
  );

  final result = strategy.calculate(params);

  print('测试通过！');
  print('四柱信息: ${result.fourZhu}');
  print('六亲考刻数: ${result.correctionKeNumber}');
  print('年月卦: ${result.yearMonthGua}');
  print('年月错卦: ${result.yearMonthCuoGua}');
  print('年月基本数: ${result.yearMonthBaseNumber}');
  print('第一个数字: ${result.firstNumber}');
  print('年月条文列表长度: ${result.firstTiaoWenList.length}');
  print('日时卦: ${result.dayTimeGua}');
  print('日时错卦: ${result.dayTimeCuoGua}');
  print('日时基本数: ${result.dayTimeBaseNumber}');
  print('第二个数字: ${result.secondNumber}');
  print('日时条文列表长度: ${result.secondTiaoWenList.length}');
  print('所有条文列表长度: ${result.allTiaoWenNumberList.length}');
}
