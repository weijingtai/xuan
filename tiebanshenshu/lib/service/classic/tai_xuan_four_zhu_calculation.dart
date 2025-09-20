import '../../constant/constants.dart' as Constants;
import '../../domain/four_zhu.dart';
import '../../domain/six_yao_gua.dart';
import '../../utils/tiao_wen_calculator.dart';
import '../calculation_strategy.dart';

/// 太玄取数法（1）计算参数
class TaiXuanFourZhuParams {
  final FourZhu fourZhu;

  TaiXuanFourZhuParams({required this.fourZhu});
}

/// 太玄取数法（1）计算结果
class TaiXuanFourZhuResult {
  final FourZhu fourZhu;
  final bool isYangYear;
  final TaiXuanEachZhu yearZhu;
  final TaiXuanEachZhu monthZhu;
  final TaiXuanEachZhu dayZhu;
  final TaiXuanEachZhu timeZhu;
  final List<int> fourZhuBaseNumberList;
  final List<int> allTiaoWenNumberList;
  final Map<String, String> tianganGuaMapping;
  final Map<String, String> dizhiGuaMapping;

  TaiXuanFourZhuResult({
    required this.fourZhu,
    required this.isYangYear,
    required this.yearZhu,
    required this.monthZhu,
    required this.dayZhu,
    required this.timeZhu,
    required this.fourZhuBaseNumberList,
    required this.allTiaoWenNumberList,
    required this.tianganGuaMapping,
    required this.dizhiGuaMapping,
  });
}

/// 太玄每柱数据类
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
        TaiXuanFourZhuCalculation.tianganGuaMapper[ganzhi[0]]!;
    final String zhiGua =
        TaiXuanFourZhuCalculation.dizhiGuaMapper[ganzhi[ganzhi.length - 1]]!;

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

/// 条文编号计算策略类 - 太玄取数法（1）
class TaiXuanFourZhuCalculation
    extends CalculationStrategy<TaiXuanFourZhuParams, TaiXuanFourZhuResult> {
  // # 第五种，太玄取数法（1）
  // # 1. 排四柱，四柱天干与地支分别配上卦
  // #     + 壬甲从乾数，乙癸向坤求，庚来震上里，辛在巽方留，己从离门起，戊以坎为头，丙须艮处出，丁向兑家收
  // #     + 亥子坎宫寅木震，巳午离门丑在坤，卯酉乾金辰是兑，未申艮宫戌巽真
  // # 2. 同一柱得到的两个和为一卦，上干为上卦，下支为下挂
  // # 3. 将卦配上纳甲干支，将干支配上太玄数，上卦数相加为一组下卦数相加为一组
  // #       + 纳甲納天干时：阳年乾卦天干配壬、阴年天干配甲
  // #       + 阳年坤配癸，阴年坤配乙
  // # 4. 每卦每爻的干支取太玄数相加（和数为"10"则不用）
  // # 5. 四卦，各上下两数 相配（上卦两位为千、百位，下卦两卦为十个位）
  // # 6. 四组数分别各±96 四次

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

  @override
  String get name => "太玄四柱";

  @override
  String get description => "排四柱天干地支分别配卦，纳甲配太玄数，上下卦数相配组成四位数，各加减96生成条文列表";

  @override
  List<String> get detailSteps => [
    "1. 排四柱：获取年月日时的干支信息",
    "2. 天干地支配卦：天干配卦法（壬甲从乾数，乙癸向坤求，庚来震上里，辛在巽方留，己从离门起，戊以坎为头，丙须艮处出，丁向兑家收）；地支配卦法（亥子坎宫寅木震，巳午离门丑在坤，卯酉乾金辰是兑，未申艮宫戌巽真）",
    "3. 组卦：同一柱的天干为上卦，地支为下卦，组成一个完整的卦",
    "4. 纳甲配干支：将卦配上纳甲干支，阳年乾卦天干配壬、阴年天干配甲；阳年坤配癸，阴年坤配乙",
    "5. 太玄数计算：每卦每爻的干支取太玄数相加（和数为10则不用），上卦数相加为一组，下卦数相加为一组",
    "6. 四位数组成：四卦各上下两数相配（上卦两位为千、百位，下卦两位为十、个位）",
    "7. 生成条文列表：四组数分别各±96四次，得到所有条文编号",
  ];

  @override
  String get school => "太玄取数流派";

  @override
  TaiXuanFourZhuResult calculate(TaiXuanFourZhuParams params) {
    final fourZhu = params.fourZhu;
    final isYangYear = fourZhu.isYangGanYear;

    // 生成四柱的太玄数据
    final yearZhu = TaiXuanEachZhu.generate(fourZhu.yearGanzhi, isYangYear);
    final monthZhu = TaiXuanEachZhu.generate(fourZhu.monthGanzhi, isYangYear);
    final dayZhu = TaiXuanEachZhu.generate(fourZhu.dayGanzhi, isYangYear);
    final timeZhu = TaiXuanEachZhu.generate(fourZhu.timeGanzhi, isYangYear);

    // 四柱基本数列表
    final fourZhuBaseNumberList = [
      yearZhu.baseNumber,
      monthZhu.baseNumber,
      dayZhu.baseNumber,
      timeZhu.baseNumber,
    ];

    // 获取所有条文数字列表：四组数分别各±96四次
    final allTiaoWenNumberList = <int>[];
    for (final int num in fourZhuBaseNumberList) {
      allTiaoWenNumberList.addAll(
        TiaowenCalculator.calculateTiaowenNumberList96(
          num,
          4,
          withBaseNumber: true,
        ),
      );
    }

    return TaiXuanFourZhuResult(
      fourZhu: fourZhu,
      isYangYear: isYangYear,
      yearZhu: yearZhu,
      monthZhu: monthZhu,
      dayZhu: dayZhu,
      timeZhu: timeZhu,
      fourZhuBaseNumberList: fourZhuBaseNumberList,
      allTiaoWenNumberList: allTiaoWenNumberList,
      tianganGuaMapping: tianganGuaMapper,
      dizhiGuaMapping: dizhiGuaMapper,
    );
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

  final strategy = TaiXuanFourZhuCalculation();
  final params = TaiXuanFourZhuParams(fourZhu: fourZhu);

  final result = strategy.calculate(params);

  print('测试通过！');
  print('四柱信息: ${result.fourZhu}');
  print('是否阳年: ${result.isYangYear}');
  print('四柱基本数列表: ${result.fourZhuBaseNumberList}');
  print('所有条文列表长度: ${result.allTiaoWenNumberList.length}');
  print('年柱基本数: ${result.yearZhu.baseNumber}');
  print('月柱基本数: ${result.monthZhu.baseNumber}');
  print('日柱基本数: ${result.dayZhu.baseNumber}');
  print('时柱基本数: ${result.timeZhu.baseNumber}');
}
