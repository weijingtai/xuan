import '../constant/constants.dart' as Constants;
import '../domain/four_zhu.dart';
import '../domain/six_yao_gua.dart';
import '../utils/tiao_wen_calculator.dart';

/// 第五种，太玄取数法（1）
/// 1. 排四柱，四柱天干与地支分别配上卦
///     + 壬甲从乾数，乙癸向坤求，庚来震上里，辛在巽方留，己从离门起，戊以坎为头，丙须艮处出，丁向兑家收
///     + 亥子坎宫寅木震，巳午离门丑在坤，卯酉乾金辰是兑，未申艮宫戌巽真
/// 2. 同一柱得到的两个和为一卦，上干为上卦，下支为下挂
/// 3. 将卦配上纳甲干支，将干支配上太玄数，上卦数相加为一组下卦数相加为一组
///       + 纳甲納天干时：阳年乾卦天干配壬、阴年天干配甲
///       + 阳年坤配癸，阴年坤配乙
/// 4. 每卦每爻的干支取太玄数相加（和数为"10"则不用）
/// 5. 四卦，各上下两数 相配（上卦两位为千、百位，下卦两卦为十个位）
/// 6. 四组数分别各±96 四次
class TaiXuanEachZhu {
  final String ganzhi;
  final String ganGua;
  final String zhiGua;
  final SixYaoGua gua;
  final int topGanzhiSum;
  final int bottomGanzhiSum;
  final int baseNumber;

  const TaiXuanEachZhu({
    required this.ganzhi,
    required this.ganGua,
    required this.zhiGua,
    required this.gua,
    required this.topGanzhiSum,
    required this.bottomGanzhiSum,
    required this.baseNumber,
  });

  /// 每一爻，干支取太玄数相加（和数为"10"则不用）
  List<int> get eachYaoTaixuanSumList {
    return ganzhiList.map(calculateTaixuanGanzhiSum).toList();
  }

  /// 干支列表
  List<String> get ganzhiList => gua.topBottomGanZhiList;

  /// 生成太玄每柱实例
  static TaiXuanEachZhu generate(String ganzhi, bool isYangYear) {
    final String ganGua =
        TiaoWenNumberCalculationStrategy.tianganGuaMapper[ganzhi[0]]!;
    final String zhiGua = TiaoWenNumberCalculationStrategy
        .dizhiGuaMapper[ganzhi[ganzhi.length - 1]]!;

    final SixYaoGua gua = SixYaoGua.generateFromGuaBySpecial(
      '$ganGua$zhiGua',
      getEachYaoGan(isYangYear),
    );

    final List<String> sixyaoGanzhi = gua.topBottomGanZhiList;
    final int topGanzhiSum = calculateEachEightGuaGanzhiSum(
      sixyaoGanzhi.sublist(0, 3),
    );
    final int bottomGanzhiSum = calculateEachEightGuaGanzhiSum(
      sixyaoGanzhi.sublist(3),
    );
    final int baseNumber = int.parse('$topGanzhiSum$bottomGanzhiSum');

    return TaiXuanEachZhu(
      ganzhi: ganzhi,
      ganGua: ganGua,
      zhiGua: zhiGua,
      gua: gua,
      topGanzhiSum: topGanzhiSum,
      bottomGanzhiSum: bottomGanzhiSum,
      baseNumber: baseNumber,
    );
  }

  /// 获取每爻天干的函数
  static List<String> Function(String) getEachYaoGan(bool isYangYear) {
    return (String guaName) {
      List<String> getGanList(String gua) {
        if (isYangYear) {
          return {
            "乾": ["壬", "壬", "壬"],
            "兑": ["丁", "丁", "丁"],
            "离": ["己", "己", "己"],
            "震": ["庚", "庚", "庚"],
            "巽": ["辛", "辛", "辛"],
            "坎": ["戊", "戊", "戊"],
            "艮": ["丙", "丙", "丙"],
            "坤": ["癸", "癸", "癸"],
          }[gua]!;
        } else {
          // 阴年
          return {
            "乾": ["甲", "甲", "甲"],
            "兑": ["丁", "丁", "丁"],
            "离": ["己", "己", "己"],
            "震": ["庚", "庚", "庚"],
            "巽": ["辛", "辛", "辛"],
            "坎": ["戊", "戊", "戊"],
            "艮": ["丙", "丙", "丙"],
            "坤": ["乙", "乙", "乙"],
          }[gua]!;
        }
      }

      final List<String> topGuaGanList = getGanList(guaName[0]);
      final List<String> bottomGuaGanList = getGanList(
        guaName[guaName.length - 1],
      );

      return [...topGuaGanList, ...bottomGuaGanList];
    };
  }

  /// 计算太玄干支和
  static int calculateTaixuanGanzhiSum(String ganzhi) {
    return Constants.taixuanGanNumberMapper[ganzhi[0]]! +
        Constants.taixuanZhiNumberMapper[ganzhi[1]]!;
  }

  /// 计算每个八卦干支和
  static int calculateEachEightGuaGanzhiSum(List<String> ganzhiList) {
    int sum = 0;
    for (final String ganzhi in ganzhiList) {
      final int tmp = calculateTaixuanGanzhiSum(ganzhi);
      if (tmp == 10) {
        continue;
      } else {
        sum += tmp;
      }
    }
    return sum;
  }
}

/// 太玄取数法策略类
@Deprecated("请使用TaiXuanFourZhuCalculation")
class TiaoWenNumberCalculationStrategy {
  static const String strategyName = "太玄取一数";

  /// 天干卦映射表
  static const Map<String, String> tianganGuaMapper = {
    '甲': "乾",
    '壬': "乾",
    "乙": "坤",
    "癸": "坤",
    "丙": "艮",
    "丁": "兑",
    "戊": "坎",
    "己": "离",
    "庚": "震",
    "辛": "巽",
  };

  /// 地支卦映射表
  /// 亥子坎宫寅震木，巳午离宫丑在坤
  /// 卯酉乾金辰是兑，未申艮宫戌巽真。
  static const Map<String, String> dizhiGuaMapper = {
    "子": "坎",
    "亥": "坎",
    "丑": "坤",
    "寅": "震",
    "卯": "乾",
    "辰": "兑",
    "巳": "离",
    "午": "离",
    "未": "艮",
    "申": "艮",
    "酉": "乾",
    "戌": "巽",
  };

  final bool isYangYear;
  final FourZhu fourZhu;
  final TaiXuanEachZhu yearZhu;
  final TaiXuanEachZhu monthZhu;
  final TaiXuanEachZhu dayZhu;
  final TaiXuanEachZhu timeZhu;

  /// 构造函数
  TiaoWenNumberCalculationStrategy(this.fourZhu)
    : isYangYear = fourZhu.isYangGanYear,
      yearZhu = TaiXuanEachZhu.generate(
        fourZhu.yearGanzhi,
        fourZhu.isYangGanYear,
      ),
      monthZhu = TaiXuanEachZhu.generate(
        fourZhu.monthGanzhi,
        fourZhu.isYangGanYear,
      ),
      dayZhu = TaiXuanEachZhu.generate(
        fourZhu.dayGanzhi,
        fourZhu.isYangGanYear,
      ),
      timeZhu = TaiXuanEachZhu.generate(
        fourZhu.timeGanzhi,
        fourZhu.isYangGanYear,
      );

  /// 年柱基本数
  int get yearBaseNumber => yearZhu.baseNumber;

  /// 月柱基本数
  int get monthBaseNumber => monthZhu.baseNumber;

  /// 日柱基本数
  int get dayBaseNumber => dayZhu.baseNumber;

  /// 时柱基本数
  int get timeBaseNumber => timeZhu.baseNumber;

  /// 四柱基本数列表
  List<int> get fourZhuBaseNumberList => [
    yearBaseNumber,
    monthBaseNumber,
    dayBaseNumber,
    timeBaseNumber,
  ];

  /// 获取所有条文数字列表
  ///
  /// 四组数分别各±96四次
  List<int> getAllTiaoWenNumberList() {
    final List<int> allNumbers = [];
    for (final int num in fourZhuBaseNumberList) {
      allNumbers.addAll(
        TiaowenCalculator.calculateTiaowenNumberList96(
          num,
          4,
          withBaseNumber: true,
        ),
      );
    }
    return allNumbers;
  }
}
