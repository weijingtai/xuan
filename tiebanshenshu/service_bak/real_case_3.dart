import '../domain/four_zhu.dart';
import '../utils/tiao_wen_calculator.dart';

/// 案例3：四柱天干取数法
/// 1. 排四柱，只取天干，进行天干配数 甲1、丙2、戊3、庚4、壬5、乙6、丁7、巳8、辛9、癸0
/// 2. 按照 月，日，时，年，进行排列得到四位数，此数为基本数
/// 3. 以次数为基础递加96七次，得到8个数为条文列表
@Deprecated("请使用FourZhuTianGanCalculation")
class TiaoWenNumberCalculationStrategy {
  static const String strategyName = "四柱天干取数";

  /// 天干数字映射表
  static const Map<String, int> ganNumberMapper = {
    "甲": 1,
    "乙": 6,
    "丙": 2,
    "丁": 7,
    "戊": 3,
    "己": 8,
    "庚": 4,
    "辛": 9,
    "壬": 5,
    "癸": 0,
  };

  final FourZhu fourZhu;
  final int baseNumber;

  /// 构造函数
  ///
  /// [fourZhu] 四柱信息
  TiaoWenNumberCalculationStrategy(this.fourZhu)
    : baseNumber = _calculateBaseNumber(fourZhu);

  /// 计算基本数
  ///
  /// 按照月、日、时、年的顺序排列天干配数
  static int _calculateBaseNumber(FourZhu fourZhu) {
    final List<String> tmpGanList = [
      fourZhu.monthGan,
      fourZhu.dayGan,
      fourZhu.timeGan,
      fourZhu.yearGan,
    ];

    final List<int> tmpGanNumberList = tmpGanList
        .map((gan) => ganNumberMapper[gan]!)
        .toList();

    return int.parse(tmpGanNumberList.join());
  }

  /// 获取条文数字列表
  ///
  /// 以基本数为基础递加96七次，得到8个数
  List<int> getTiaoWenNumberList() {
    return TiaowenCalculator.calculateTiaoWenListByAddFactorTimes(
      baseNumber,
      7,
      returnWithBase: true,
    );
  }
}
