import '../../constant/constants.dart' as Constants;
import '../../domain/four_zhu.dart';
import '../../utils/utils.dart' as Utils;
import '../calculation_strategy.dart';

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

/// 六亲考刻法计算参数
class LiuQinKaoKeParams {
  final FourZhu fourZhu;
  final String gender;

  LiuQinKaoKeParams({required this.fourZhu, required this.gender});
}

/// 六亲考刻法计算结果
class LiuQinKaoKeResult {
  final String xianTianBaseGua;
  final String houTianBaseGua;
  final int xianTianBaseNumber;
  final int houTianBaseNumber;
  final List<CorrectionSixQinKe> xianTianGuaStageList;
  final List<CorrectionSixQinKe> houTianGuaStageList;
  final List<int> xianTianNumberList;
  final List<int> houTianNumberList;

  LiuQinKaoKeResult({
    required this.xianTianBaseGua,
    required this.houTianBaseGua,
    required this.xianTianBaseNumber,
    required this.houTianBaseNumber,
    required this.xianTianGuaStageList,
    required this.houTianGuaStageList,
    required this.xianTianNumberList,
    required this.houTianNumberList,
  });
}

/// 条文编号计算策略类 - 六亲考刻法
class SixQinCorrectKeCalculation
    extends CalculationStrategy<LiuQinKaoKeParams, LiuQinKaoKeResult> {
  // # 1. 排四柱
  // # 2. 四柱取太玄数
  // # 3. 以先天数基本卦考六亲，干支相加 mod 8， 取先天卦
  // #  + 阳男阴女，年干支为上卦，月干支为下卦
  // #  + 阴男阳女，月干支为上卦，年干支为下卦
  // # 4. 两卦相合为「基本卦」
  // # 5. 取基本卦的「互卦」
  // # 6. 计算卦气深度
  // #  + 以两卦考取六亲，两卦均取“先天卦数”
  // #  + 基本卦上卦为”千位“，下卦为”百位“
  // #  + 互卦上卦为“十位”，下卦为”个位“
  // #  如果这个四位数对应的条文符合命主，则以此数为基本数
  // #  如果不符合，则“变化基本挂的初爻”，得出新一卦，同样进行互卦，再次组成四位数，对比是否符合命主
  // #  如果依旧不符合，则“变化基本卦的二爻”，得出新一卦，同时进行互卦，再次组成四位数，对比是否符合命主
  // # 直到找到对应的条文作为基本数
  // # 7. 根据基本数计算条文，规则如下：
  // #   + 基本数 ± (48 * n) n为 [2,4,8,16]
  // #   + 得出结果 8个条文
  // # 8. 用日柱时柱计算后天运程：
  // #   + 日干支和减去10 得数取后天卦为上卦
  // #   + 时干支和减去10 得数取后天卦为下卦
  // #   + 上下卦相合得「后天基本卦」，求取其互卦，再以基本卦与互卦用后天取数
  // #   + 基本卦上卦为千位，基本卦下卦为百位，互卦上卦为十位，互卦下卦为个位
  // #   + 以所得条文数为基础，与命主信息匹配，如果匹配，则取该数为基本数
  // #   + 如果不匹配，则将后天基本卦，初爻变，并互出一卦，再得出四位数，以此为基本卦取条文匹配
  // #   + 如此直至找到符合的 后天基本数
  // # 9. 根据基本数计算条文，规则如下：
  // #   + 基本数 ± (48 * n) n为 [2,4,8,16]
  // #   + 得出结果 8个条文
  static const List<int> _multipleList = [2, 4, 8, 16, -2, -4, -8, -16];

  @override
  String get name => "六亲考刻法";

  @override
  String get description => "通过四柱干支计算先天基本卦和后天基本卦，结合变爻位置生成条文编号的传统算法";

  @override
  List<String> get detailSteps => [
    "1. 排四柱：获取年月日时的干支信息",
    "2. 四柱取太玄数：将干支转换为太玄数值",
    "3. 计算先天基本卦：年月干支太玄数相加取模8得先天卦，根据性别和年干阴阳确定上下卦顺序",
    "4. 计算后天基本卦：日时干支太玄数减10后取后天卦，组合成基本卦",
    "5. 求取互卦：分别计算先天和后天基本卦的互卦",
    "6. 计算卦气深度（先天）：基本卦上卦为千位，下卦为百位，互卦上卦为十位，下卦为个位，组成四位数",
    "7. 先天变爻匹配：如四位数条文不符合命主，依次变化初爻、二爻等，直到找到符合的条文作为先天基本数",
    "8. 计算卦气深度（后天）：同样方式计算后天基本卦的四位数",
    "9. 后天变爻匹配：如四位数条文不符合命主，依次变化初爻等，直到找到符合的条文作为后天基本数",
    "10. 生成条文列表：基本数±(48×n)，其中n为[2,4,8,16,-2,-4,-8,-16]，得出16个条文编号",
  ];

  // @override
  // String get school => "六亲考刻流派";

  @override
  LiuQinKaoKeResult calculate(LiuQinKaoKeParams params) {
    final fourZhu = params.fourZhu;
    final gender = params.gender;

    // 计算基本卦
    final xianTianBaseGua = calculateXianTianBaseGua(fourZhu, gender);
    final houTianBaseGua = calculateHouTianBaseGua(fourZhu);

    // 初始化变量
    int xianTianBaseNumber = -1;
    int houTianBaseNumber = -1;
    List<CorrectionSixQinKe> xianTianGuaStageList = [];
    List<CorrectionSixQinKe> houTianGuaStageList = [];

    const List<List<int>> bianYaoIndexListSet = [
      [],
      [0],
      [1],
      [2],
      [3],
      [4],
      [5],
    ];

    // 计算先天基本数（第三爻变爻时为基准）
    for (int i = 0; i < bianYaoIndexListSet.length; i++) {
      CorrectionSixQinKe res = getXiantianBasenumberByYaobianlist(
        bianYaoIndexListSet[i],
        xianTianBaseGua,
      );
      xianTianGuaStageList.add(res);

      if (i == 3) {
        xianTianBaseNumber = res.baseNumber;
        break;
      }
    }

    // 计算后天基本数（初爻变爻时为基准）
    for (int i = 0; i < bianYaoIndexListSet.length; i++) {
      CorrectionSixQinKe res = getHoutianBasenumberByYaobianlist(
        bianYaoIndexListSet[i],
        houTianBaseGua,
      );
      houTianGuaStageList.add(res);

      if (i == 1) {
        houTianBaseNumber = res.baseNumber;
        break;
      }
    }

    // 生成数字列表
    final xianTianNumberList = _multipleList
        .map((x) => xianTianBaseNumber + x * 48)
        .toList();
    final houTianNumberList = _multipleList
        .map((x) => houTianBaseNumber + x * 48)
        .toList();

    return LiuQinKaoKeResult(
      xianTianBaseGua: xianTianBaseGua,
      houTianBaseGua: houTianBaseGua,
      xianTianBaseNumber: xianTianBaseNumber,
      houTianBaseNumber: houTianBaseNumber,
      xianTianGuaStageList: xianTianGuaStageList,
      houTianGuaStageList: houTianGuaStageList,
      xianTianNumberList: xianTianNumberList,
      houTianNumberList: houTianNumberList,
    );
  }

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
    } else {
      res = gender == "男" ? monthGua + yearGua : yearGua + monthGua;
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
    String xianTianBaseGua,
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
    String houTianBaseGua,
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
}

/// 测试函数
void test() {
  FourZhu fourZhu = FourZhu(
    yearGanzhi: "癸巳",
    monthGanzhi: "甲子",
    dayGanzhi: "丁酉",
    timeGanzhi: "癸卯",
  );

  SixQinCorrectKeCalculation strategy = SixQinCorrectKeCalculation();
  LiuQinKaoKeParams params = LiuQinKaoKeParams(fourZhu: fourZhu, gender: "男");

  LiuQinKaoKeResult result = strategy.calculate(params);

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
    result.xianTianNumberList.toString() == expectedXianTianList.toString(),
    'XianTian number list assertion failed',
  );
  assert(
    result.houTianNumberList.toString() == expectedHouTianList.toString(),
    'HouTian number list assertion failed',
  );

  print('测试通过！');
  print('先天数字列表: ${result.xianTianNumberList}');
  print('后天数字列表: ${result.houTianNumberList}');
}
