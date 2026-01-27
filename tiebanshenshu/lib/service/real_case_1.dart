import '../constant/constants.dart' as Constants;
import '../domain/four_zhu.dart';
import '../utils/utils.dart' as Utils;

/// 六亲考刻修正类
class CorrectionSixQinKe {
  final String baseGua;
  final String rootGua;
  final String baseGuaHu;
  final List<int> bianYaoIndexList;
  final int baseNumber;
  final bool isAccepted;

  CorrectionSixQinKe({
    required this.baseGua,
    required this.rootGua,
    required this.baseGuaHu,
    required this.bianYaoIndexList,
    required this.baseNumber,
    required this.isAccepted,
  });

  @override
  String toString() {
    return 'CorrectionSixQinKe(baseGua: $baseGua, rootGua: $rootGua, baseGuaHu: $baseGuaHu, bianYaoIndexList: $bianYaoIndexList, baseNumber: $baseNumber, isAccepted: $isAccepted)';
  }
}

/// 条文编号计算策略类 - 六亲考刻法
@Deprecated("请使用SixQinCorrectKeCalculation")
class SixQinCorrectKeStrategy {
  static const List<int> _multipleList = [2, 4, 8, 16, -2, -4, -8, -16];

  final String strategyName = "六亲考刻法";
  final FourZhu fourZhu;
  final String gender;
  final String xianTianBaseGua;
  final String houTianBaseGua;

  int xianTianBaseNumber = -1;
  int houTianBaseNumber = -1;
  List<CorrectionSixQinKe> xianTianGuaStageList = [];
  List<CorrectionSixQinKe> houTianGuaStageList = [];

  SixQinCorrectKeStrategy({required this.fourZhu, required this.gender})
    : xianTianBaseGua = calculateXianTianBaseGua(fourZhu, gender),
      houTianBaseGua = calculateHouTianBaseGua(fourZhu);

  /// 计算先天基本卦
  static String calculateXianTianBaseGua(FourZhu fourZhu, String gender) {
    int yearTaixuanNumSum =
        fourZhu.yearZhiTaixuanNum + fourZhu.yearGanTaixuanNum;
    int yearGuaNum = yearTaixuanNumSum % 8;
    if (yearGuaNum == 0) {
      yearGuaNum = 8;
    }
    String yearGua = Constants.xianTianNumberGuaMapper[yearGuaNum]!;

    int monthTaixuanNumSum =
        fourZhu.monthZhiTaixuanNum + fourZhu.monthGanTaixuanNum;
    int monthGuaNum = monthTaixuanNumSum % 8;
    if (monthGuaNum == 0) {
      monthGuaNum = 8;
    }
    String monthGua = Constants.xianTianNumberGuaMapper[monthGuaNum]!;

    String res;
    if (fourZhu.isYangGanYear) {
      res = gender == "男" ? yearGua + monthGua : monthGua + yearGua;
      // if (gender == "男") {
      //   return yearGua + monthGua;
      // } else {
      //   return monthGua + yearGua;
      // }
    } else {
      res = gender == "男" ? monthGua + yearGua : yearGua + monthGua;
      // if (gender == "男") {
      //   return monthGua + yearGua;
      // } else {
      //   return yearGua + monthGua;
      // }
    }
    return res;
  }

  /// 计算后天基本卦
  static String calculateHouTianBaseGua(FourZhu fourZhu) {
    int dayTaixuanNumSum = fourZhu.dayZhiTaixuanNum + fourZhu.dayGanTaixuanNum;
    int dayGuaNum = dayTaixuanNumSum - 10;
    String dayGua = Constants.houTianNumberGuaMapper[dayGuaNum]!;

    int timeTaixuanNumSum =
        fourZhu.timeZhiTaixuanNum + fourZhu.timeGanTaixuanNum;
    int timeGuaNum = timeTaixuanNumSum - 10;
    String timeGua = Constants.houTianNumberGuaMapper[timeGuaNum]!;

    return dayGua + timeGua;
  }

  /// 根据变爻列表获取先天基本数
  CorrectionSixQinKe getXiantianBasenumberByYaobianlist(
    List<int> bianYaoIndexList,
  ) {
    String gua;

    if (bianYaoIndexList.isEmpty) {
      gua = xianTianBaseGua;
    } else {
      List<int> guaBinList = Utils.guaToBinaryList(xianTianBaseGua);
      guaBinList = guaBinList.reversed.toList();

      for (int index in bianYaoIndexList) {
        if (guaBinList[index] == 0) {
          guaBinList[index] = 1;
        } else {
          guaBinList[index] = 0;
        }
      }

      guaBinList = guaBinList.reversed.toList();
      gua = Utils.binaryListToGua(guaBinList);
    }

    String huGua = Utils.guaToHuGua(gua);
    int firstNum = Constants.xianTianGuaNumberMapper[gua[0]]!;
    int lastNum = Constants.xianTianGuaNumberMapper[gua[gua.length - 1]]!;
    int firstHuNum = Constants.xianTianGuaNumberMapper[huGua[0]]!;
    int lastHuNum = Constants.xianTianGuaNumberMapper[huGua[huGua.length - 1]]!;

    return CorrectionSixQinKe(
      baseGua: xianTianBaseGua,
      rootGua: gua,
      baseGuaHu: huGua,
      bianYaoIndexList: bianYaoIndexList,
      baseNumber: int.parse('$firstNum$lastNum$firstHuNum$lastHuNum'),
      isAccepted: false,
    );
  }

  /// 根据变爻列表获取后天基本数
  CorrectionSixQinKe getHoutianBasenumberByYaobianlist(
    List<int> bianYaoIndexList,
  ) {
    String gua;

    if (bianYaoIndexList.isEmpty) {
      gua = houTianBaseGua;
    } else {
      List<int> guaBinList = Utils.guaToBinaryList(houTianBaseGua);
      guaBinList = guaBinList.reversed.toList();

      for (int index in bianYaoIndexList) {
        if (guaBinList[index] == 0) {
          guaBinList[index] = 1;
        } else {
          guaBinList[index] = 0;
        }
      }

      guaBinList = guaBinList.reversed.toList();
      gua = Utils.binaryListToGua(guaBinList);
    }

    String huGua = Utils.guaToHuGua(gua);
    int firstNum = Constants.houTianGuaNumberMapper[gua[0]]!;
    int lastNum = Constants.houTianGuaNumberMapper[gua[gua.length - 1]]!;
    int firstHuNum = Constants.houTianGuaNumberMapper[huGua[0]]!;
    int lastHuNum = Constants.houTianGuaNumberMapper[huGua[huGua.length - 1]]!;

    return CorrectionSixQinKe(
      baseGua: houTianBaseGua,
      rootGua: gua,
      baseGuaHu: huGua,
      bianYaoIndexList: bianYaoIndexList,
      baseNumber: int.parse('$firstNum$lastNum$firstHuNum$lastHuNum'),
      isAccepted: false,
    );
  }

  /// 先天数字列表
  List<int> get xianTianNumberList {
    return _multipleList.map((x) => xianTianBaseNumber + x * 48).toList();
  }

  /// 后天数字列表
  List<int> get houTianNumberList {
    return _multipleList.map((x) => houTianBaseNumber + x * 48).toList();
  }
}

/// 测试函数
void test() {
  const List<List<int>> bianYaoIndexListSet = [
    [],
    [0],
    [1],
    [2],
    [3],
    [4],
    [5],
  ];

  FourZhu fourZhu = FourZhu(
    yearGanzhi: "癸巳",
    monthGanzhi: "甲子",
    dayGanzhi: "丁酉",
    timeGanzhi: "癸卯",
  );

  SixQinCorrectKeStrategy tiaoWenCalculator = SixQinCorrectKeStrategy(
    fourZhu: fourZhu,
    gender: "男",
  );

  List<String> yaoNameMapper = ["无", "初爻", "二爻", "三爻", "四爻", "五爻", "上爻"];

  // 第三爻变爻时为y
  for (int i = 0; i < bianYaoIndexListSet.length; i++) {
    CorrectionSixQinKe res = tiaoWenCalculator
        .getHoutianBasenumberByYaobianlist(bianYaoIndexListSet[i]);
    tiaoWenCalculator.xianTianGuaStageList.add(res);

    if (i == 3) {
      tiaoWenCalculator.xianTianBaseNumber = res.baseNumber;
      break;
    }
  }

  for (int i = 0; i < bianYaoIndexListSet.length; i++) {
    CorrectionSixQinKe res = tiaoWenCalculator
        .getHoutianBasenumberByYaobianlist(bianYaoIndexListSet[i]);
    tiaoWenCalculator.houTianGuaStageList.add(res);

    if (i == 1) {
      tiaoWenCalculator.houTianBaseNumber = res.baseNumber;
      break;
    }
  }

  // 断言验证
  List<int> expectedXianTianList = [
    2533,
    2629,
    2821,
    3205,
    2341,
    2245,
    2053,
    1669,
  ];
  List<int> expectedHouTianList = [
    2819,
    2915,
    3107,
    3491,
    2627,
    2531,
    2339,
    1955,
  ];

  assert(
    tiaoWenCalculator.xianTianNumberList.toString() ==
        expectedXianTianList.toString(),
    'XianTian number list assertion failed',
  );
  assert(
    tiaoWenCalculator.houTianNumberList.toString() ==
        expectedHouTianList.toString(),
    'HouTian number list assertion failed',
  );

  print('测试通过！');
  print('先天数字列表: ${tiaoWenCalculator.xianTianNumberList}');
  print('后天数字列表: ${tiaoWenCalculator.houTianNumberList}');
}
