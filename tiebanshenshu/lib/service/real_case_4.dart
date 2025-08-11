import '../constant/constants.dart' as Constants;
import '../utils/tiao_wen_calculator.dart';
import '../utils/utils.dart' as Utils;

/// 第四种，日柱变卦取数法
/// 1. 排四柱，日柱配卦法，和天干配卦法，将日柱配上卦
///     + 壬甲从乾数，乙癸向坤求，庚来震上里，辛在巽方留，己从离门起，戊以坎为头，丙须艮处出，丁向兑家收
///     + 亥子坎宫寅木震，巳午离门丑在坤，卯酉乾金辰是兑，未申艮宫戌巽真
/// 2. 日支为上卦，日干为下卦 为第一卦
/// 3. 第一卦互卦为第二卦
/// 4. 第一卦上卦【后天】数为千位，下卦【后天】数为百位；第二卦上【先天】数为十位，下卦【先天】数为个位
/// 5. 四位数 加减 96各四次 得出8组数
@Deprecated("请使用DayGanZhiGuaCalculation")
class TiaoWenNumberCalculationStrategy {
  static const String strategyName = "日柱变卦取数法";

  final String dayGanzhi;
  final String baseGua;
  final String huGua;
  final int baseNumber;

  /// 构造函数
  ///
  /// [dayGanzhi] 日柱干支，如"丁酉"
  TiaoWenNumberCalculationStrategy(this.dayGanzhi)
    : baseGua = _calculateBaseGua(dayGanzhi),
      huGua = _calculateHuGua(dayGanzhi),
      baseNumber = _calculateBaseNumber(dayGanzhi);

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
  static String _calculateHuGua(String dayGanzhi) {
    final String baseGua = _calculateBaseGua(dayGanzhi);
    return Utils.guaToHuGua(baseGua);
  }

  /// 计算基本数
  ///
  /// 第一卦上卦【后天】数为千位，下卦【后天】数为百位；
  /// 第二卦上【先天】数为十位，下卦【先天】数为个位
  static int _calculateBaseNumber(String dayGanzhi) {
    final String baseGua = _calculateBaseGua(dayGanzhi);
    final String huGua = _calculateHuGua(dayGanzhi);

    final int firstUp = Constants.houTianGuaNumberMapper[baseGua[0]]!;
    final int firstDown =
        Constants.houTianGuaNumberMapper[baseGua[baseGua.length - 1]]!;

    final int secondUp = Constants.xianTianGuaNumberMapper[huGua[0]]!;
    final int secondDown =
        Constants.xianTianGuaNumberMapper[huGua[huGua.length - 1]]!;

    return int.parse('$firstUp$firstDown$secondUp$secondDown');
  }

  /// 获取条文数字列表
  ///
  /// 四位数加减96各四次得出9组数（包含基本数）
  List<int> getTiaoWenNumberList() {
    return TiaowenCalculator.calculateTiaowenNumberList96(
      baseNumber,
      4,
      withBaseNumber: true,
    );
  }
}
