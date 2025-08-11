import '../../constant/constants.dart' as Constants;
import '../../domain/four_zhu.dart';
import '../../domain/six_yao_gua.dart';
import '../../utils/utils.dart' as GuaUtils;
import 'huang_ji_qu_shu_base_strategy.dart';

/// 太玄每柱类
class TaiXuanEachZhu {
  final FourZhu fourZhu;
  final int correctionKeNumber;
  final String yearMonthGua;
  final String yearMonthNextGua;
  final int yearMonthBaseNumber;

  /// 构造函数
  ///
  /// [fourZhu] 四柱信息
  /// [correctionKeNumber] 六亲考刻数
  TaiXuanEachZhu({required this.fourZhu, required this.correctionKeNumber})
    : yearMonthGua = _calculateYearMonthGua(fourZhu),
      yearMonthNextGua = GuaUtils.guaToCuoGua(_calculateYearMonthGua(fourZhu)),
      yearMonthBaseNumber = _calculateYearMonthBaseNumber(fourZhu);

  /// 计算年月卦
  static String _calculateYearMonthGua(FourZhu fourZhu) {
    final yearZhuGuaNumber =
        (fourZhu.yearGanTaixuanNum + fourZhu.yearZhiTaixuanNum) % 8;
    final yearGua = Constants.xianTianNumberGuaMapper[yearZhuGuaNumber]!;
    final monthZhuGuaNumber =
        (fourZhu.monthGanTaixuanNum + fourZhu.monthZhiTaixuanNum) % 8;
    final monthGua = Constants.xianTianNumberGuaMapper[monthZhuGuaNumber]!;
    return '$monthGua$yearGua';
  }

  /// 计算年月基本数
  static int _calculateYearMonthBaseNumber(FourZhu fourZhu) {
    final yearMonthGua = _calculateYearMonthGua(fourZhu);
    final yearMonthNextGua = GuaUtils.guaToCuoGua(yearMonthGua);

    final numberString = [
      Constants.xianTianGuaNumberMapper[yearMonthGua[0]]!.toString(),
      Constants.xianTianGuaNumberMapper[yearMonthGua[1]]!.toString(),
      Constants.xianTianGuaNumberMapper[yearMonthNextGua[0]]!.toString(),
      Constants.xianTianGuaNumberMapper[yearMonthNextGua[1]]!.toString(),
    ].join();

    return int.parse(numberString);
  }

  /// 获取每爻干支
  ///
  /// [isYangYear] 是否为阳年
  static List<String> Function(String) getEachYaoGan(bool isYangYear) {
    return (String guaName) {
      List<String> getGanList(String gua) {
        if (isYangYear) {
          return {
            '乾': ['壬', '壬', '壬'],
            '兑': ['丁', '丁', '丁'],
            '离': ['己', '己', '己'],
            '震': ['庚', '庚', '庚'],
            '巽': ['辛', '辛', '辛'],
            '坎': ['戊', '戊', '戊'],
            '艮': ['丙', '丙', '丙'],
            '坤': ['癸', '癸', '癸'],
          }[gua]!;
        } else {
          // 阴年
          return {
            '乾': ['甲', '甲', '甲'],
            '兑': ['丁', '丁', '丁'],
            '离': ['己', '己', '己'],
            '震': ['庚', '庚', '庚'],
            '巽': ['辛', '辛', '辛'],
            '坎': ['戊', '戊', '戊'],
            '艮': ['丙', '丙', '丙'],
            '坤': ['乙', '乙', '乙'],
          }[gua]!;
        }
      }

      final topGuaGanList = getGanList(guaName[0]);
      final bottomGuaGanList = getGanList(guaName[guaName.length - 1]);

      return [...topGuaGanList, ...bottomGuaGanList];
    };
  }

  /// 计算太玄干支和
  ///
  /// [ganzhi] 干支字符串
  static int calculateTaixuanGanzhiSum(String ganzhi) {
    return Constants.taixuanGanNumberMapper[ganzhi[0]]! +
        Constants.taixuanZhiNumberMapper[ganzhi[1]]!;
  }

  /// 计算每八卦干支和
  ///
  /// [ganzhiList] 干支列表
  static int calculateEachEightGuaGanzhiSum(List<String> ganzhiList) {
    int sum = 0;
    for (final ganzhi in ganzhiList) {
      final tmp = calculateTaixuanGanzhiSum(ganzhi);
      if (tmp == 10) {
        continue;
      } else {
        sum += tmp;
      }
    }
    return sum;
  }
}

/// 皇极取数法一策略类
///
/// 第七种，皇极取数法（又名：元会运世取数）
/// 1. 排四柱，四柱天干与地支配太玄数
/// 2. 年干+年支=元(千位)，月干+月支=会(百位)，日干+日支=运(十位)，时干+时支=世(个位)
/// 3. 年+月 互合成数顺左旋取数（也叫："元会基本数"）；日+时 互合成数逆右旋取数（也叫："运世基础数"）
/// 4. 元会基础数 + 年干太玄数 = 条文数（如果条文数大于13000 则将条文数减去12000）
/// 5. 次条文数为初刻数，如果符合则将此条文数作为基础数计算，如不符合则按照"30"递加或递减 直到找到对应的
/// 6. 得到基础数后进行如下操作：
///   + 基础数 + 月干(百位数） = 条文数
///   + 基础数 + 月支(百位数) = 条文数
///   + 基础数 + 月干支互数(干为十位+支为个位) = 条文数
///   + 基础数 + 时干(个位数） = 条文数
///   + 基础数 + 时支(个位数) = 条文数
///   + 基础数 + 日干支互合数(干为十位+支为个位) + 时干个位数 = 条文数
///   + 基础数 + 日干支互合数(干为十位+支为个位) + 时支个位数 = 条文数
///   + 基础数 + 年支(千位数) = 条文数
///   + 运世基础数 + 日干支互合数 = 条文数
///   + 运世基础数 + 时干个位数 = 条文数
///   + 运世基础数 + 时支个位数 = 条文数
///   + 运世基础数 + 日干支互合数 + 时干个位数 = 条文数
///   + 运世基础数 + 日干支互合数 + 时支个位数 = 条文数
class HuangJi1Calcaulation extends HuangJiBaseCalculation {
  static const String strategyName = '皇极取数一';
  HuangJi1Calcaulation(super.fourZhu);

  @override
  String get name => strategyName;

  @override
  String get description => "皇极取数法第一种变体，使用元会基础数和运世基础数分别计算13个条文数";

  @override
  List<String> get detailSteps => [
    "排四柱，四柱天干与地支配太玄数",
    "年干+年支=元(千位)，月干+月支=会(百位)，日干+日支=运(十位)，时干+时支=世(个位)",
    "年+月 互合成数顺左旋取数（元会基本数）；日+时 互合成数逆右旋取数（运世基础数）",
    "元会基础数 + 年干太玄数 = 基础数一（如果大于13000则减去12000）",
    "运世基础数 + 年干太玄数 = 基础数二（如果大于13000则减去12000）",
    "基础数一分别加月干百位、月支百位、日干支合数、时干个位、时支个位等生成8个条文数",
    "运世基础数分别加日干支合数、时干个位、时支个位等生成5个条文数",
    "共生成13个条文数",
  ];

  /// 基础数+年干千位数=条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber => HuangJiTiaoWenNumberInfo(
    number: primaryBaseNumber,
    description: "基础数+年干千位数=条文数",
    base: originalPrimaryNumber,
    added: fourZhu.yearGanTaixuanNum * 1000,
  );

  /// 基础数+月干百位数=条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber1 => HuangJiTiaoWenNumberInfo(
    number: primaryBaseNumber + fourZhu.monthGanTaixuanNum * 100,
    description: "基础数+月干百位数=条文数",
    base: primaryBaseNumber,
    added: fourZhu.monthGanTaixuanNum * 100,
  );

  /// 基础数+月支干百位数=条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber2 => HuangJiTiaoWenNumberInfo(
    number: primaryBaseNumber + fourZhu.monthZhiTaixuanNum * 100,
    description: "基础数+月支干百位数=条文数",
    base: primaryBaseNumber,
    added: fourZhu.monthZhiTaixuanNum * 100,
  );

  /// 基础数+日支干合数=条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber3 => HuangJiTiaoWenNumberInfo(
    number:
        primaryBaseNumber +
        fourZhu.dayGanTaixuanNum * 10 +
        fourZhu.dayZhiTaixuanNum,
    description: "基础数+日支干合数=条文数",
    base: primaryBaseNumber,
    added: fourZhu.dayGanTaixuanNum * 10 + fourZhu.dayZhiTaixuanNum,
  );

  /// 基础数+时干合数=条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber4 => HuangJiTiaoWenNumberInfo(
    number: primaryBaseNumber + fourZhu.timeGanTaixuanNum,
    description: "基础数+时干合数=条文数",
    base: primaryBaseNumber,
    added: fourZhu.timeGanTaixuanNum,
  );

  /// 基础数+时支合数=条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber4Alt => HuangJiTiaoWenNumberInfo(
    number: primaryBaseNumber + fourZhu.timeZhiTaixuanNum,
    description: "基础数+时支合数=条文数",
    base: primaryBaseNumber,
    added: fourZhu.timeZhiTaixuanNum,
  );

  /// 基础数+日干支互合数+时支合数=条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber5 => HuangJiTiaoWenNumberInfo(
    number:
        primaryBaseNumber +
        int.parse('${fourZhu.dayGanTaixuanNum}${fourZhu.dayZhiTaixuanNum}') +
        fourZhu.timeZhiTaixuanNum,
    description: "基础数+日干支互合数+时支合数=条文数",
    base: primaryBaseNumber,
    added:
        int.parse('${fourZhu.dayGanTaixuanNum}${fourZhu.dayZhiTaixuanNum}') +
        fourZhu.timeZhiTaixuanNum,
  );

  /// 基础数+日干支互合数+时干合数=条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber6 => HuangJiTiaoWenNumberInfo(
    number:
        primaryBaseNumber +
        int.parse('${fourZhu.dayGanTaixuanNum}${fourZhu.dayZhiTaixuanNum}') +
        fourZhu.timeGanTaixuanNum,
    description: "基础数+日干支互合数+时干合数=条文数",
    base: primaryBaseNumber,
    added:
        int.parse('${fourZhu.dayGanTaixuanNum}${fourZhu.dayZhiTaixuanNum}') +
        fourZhu.timeGanTaixuanNum,
  );

  /// 运世基础数+日干支互合数=条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber8 => HuangJiTiaoWenNumberInfo(
    number:
        yunShiNumber +
        int.parse('${fourZhu.dayGanTaixuanNum}${fourZhu.dayZhiTaixuanNum}'),
    description: "运世基础数+日干支互合数=条文数",
    base: yunShiNumber,
    added: int.parse('${fourZhu.dayGanTaixuanNum}${fourZhu.dayZhiTaixuanNum}'),
  );

  /// 运世基础数+时干=条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber9 => HuangJiTiaoWenNumberInfo(
    number: yunShiNumber + fourZhu.timeGanTaixuanNum,
    description: "运世基础数+时干=条文数",
    base: yunShiNumber,
    added: fourZhu.timeGanTaixuanNum,
  );

  /// 运世基础数+时支=条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber10 => HuangJiTiaoWenNumberInfo(
    number: yunShiNumber + fourZhu.timeZhiTaixuanNum,
    description: "运世基础数+时支=条文数",
    base: yunShiNumber,
    added: fourZhu.timeZhiTaixuanNum,
  );

  /// 运世基础数+日干支互合数+时干=条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber11 => HuangJiTiaoWenNumberInfo(
    number:
        yunShiNumber +
        int.parse('${fourZhu.dayGanTaixuanNum}${fourZhu.dayZhiTaixuanNum}') +
        fourZhu.timeGanTaixuanNum,
    description: "运世基础数+日干支互合数+时干=条文数",
    base: yunShiNumber,
    added:
        int.parse('${fourZhu.dayGanTaixuanNum}${fourZhu.dayZhiTaixuanNum}') +
        fourZhu.timeGanTaixuanNum,
  );

  /// 运世基础数+日干支互合数+时支=条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber12 => HuangJiTiaoWenNumberInfo(
    number:
        yunShiNumber +
        int.parse('${fourZhu.dayGanTaixuanNum}${fourZhu.dayZhiTaixuanNum}') +
        fourZhu.timeZhiTaixuanNum,
    description: "运世基础数+日干支互合数+时支=条文数",
    base: yunShiNumber,
    added:
        int.parse('${fourZhu.dayGanTaixuanNum}${fourZhu.dayZhiTaixuanNum}') +
        fourZhu.timeZhiTaixuanNum,
  );

  /// 获取所有条文数列表
  List<HuangJiTiaoWenNumberInfo> get allTiaoWenInfoList => [
    tiaowenNumber1,
    tiaowenNumber2,
    tiaowenNumber3,
    tiaowenNumber4,
    tiaowenNumber4Alt,
    tiaowenNumber5,
    tiaowenNumber6,
    tiaowenNumber8,
    tiaowenNumber9,
    tiaowenNumber10,
    tiaowenNumber11,
    tiaowenNumber12,
  ];
  @override
  List<int> get allTiaowenNumbers =>
      allTiaoWenInfoList.map((e) => e.normalizedNumber).toList();
}
