import '../../domain/four_zhu.dart';
import 'huang_ji_qu_shu_base_strategy.dart';

/// 皇极取数法（又名：元会运世取数）二
///
/// 实现步骤：
/// 1. 排四柱，四柱天干与地支配太玄数
/// 2. 年干+年支=元(千位)，月干+月支=会(百位)，日干+日支=运(十位)，时干+时支=世(个位)
/// 3. 年+月 互合成数顺左旋取数（也叫："元会基本数"）；日+时 互合成数逆右旋取数（也叫："运世基础数"）
/// 4. 元会基础数 + 年干太玄数 = 条文数（如果条文数大于13000 则将条文数减去12000）
/// 5. 次条文数为初刻数，如果符合则将此条文数作为基础数计算，如不符合则按照"30"递加或递减 直到找到对应的
/// 基本数二 = 运世基础数 + 年干太玄数 = 条文数
/// 6. 得到基础数后进行如下操作：
///   + 基础数一 + 月干(百位数） = 条文数
///   + 基础数一 + 日干(十位数) = 条文数
///   + 基础数一 + 时干(个位数） = 条文数
///   + 基础数一 + 时支(个位数) = 条文数
///   + 基础数二 + 月干(百位数) = 条文数
///   + 基础数二 + 日干(十位数)= 条文数
///   + 基础数二 + 时干个位数 = 条文数
///   + 基础数二 + 日干个位数 = 条文数
class HuangJi2Calcaulation extends HuangJiBaseCalculation {
  static const String strategyName = "皇极取数二";

  HuangJi2Calcaulation(super.fourZhu);

  @override
  String get name => strategyName;

  @override
  String get description => "皇极取数法第二种变体，使用两个基础数分别计算条文数";

  @override
  List<String> get detailSteps => [
    "排四柱，四柱天干与地支配太玄数",
    "年干+年支=元(千位)，月干+月支=会(百位)，日干+日支=运(十位)，时干+时支=世(个位)",
    "年+月 互合成数顺左旋取数；日+时 互合成数逆右旋取数",
    "元会基础数 + 年干太玄数 = 基础数一",
    "运世基础数 + 年干太玄数 = 基础数二",
    "基础数一分别加月干百位、日干十位、时干个位、时支个位得到4个条文数",
    "基础数二分别加月干百位、日干十位、时干个位、日干个位得到4个条文数",
    "共生成8个条文数",
  ];

  // 基础数一的条文数计算方法

  /// 基础数一 + 月干(百位数) = 条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber1 => HuangJiTiaoWenNumberInfo(
    number: primaryBaseNumber + fourZhu.monthGanTaixuanNum * 100,
    description: "基础数一 + 月干(百位数) = 条文数",
    base: primaryBaseNumber,
    added: fourZhu.monthGanTaixuanNum * 100,
  );

  /// 基础数一 + 日干(十位数) = 条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber2 => HuangJiTiaoWenNumberInfo(
    number: primaryBaseNumber + fourZhu.dayGanTaixuanNum * 10,
    description: "基础数一 + 日干(十位数) = 条文数",
    base: primaryBaseNumber,
    added: fourZhu.dayGanTaixuanNum * 10,
  );

  /// 基础数一 + 时干(个位数) = 条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber3 => HuangJiTiaoWenNumberInfo(
    number: primaryBaseNumber + fourZhu.timeGanTaixuanNum,
    description: "基础数一 + 时干(个位数) = 条文数",
    base: primaryBaseNumber,
    added: fourZhu.timeGanTaixuanNum,
  );

  /// 基础数一 + 时支(个位数) = 条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber4 => HuangJiTiaoWenNumberInfo(
    number: primaryBaseNumber + fourZhu.timeZhiTaixuanNum,
    description: "基础数一 + 时支(个位数) = 条文数",
    base: primaryBaseNumber,
    added: fourZhu.timeZhiTaixuanNum,
  );

  // 基础数二的条文数计算方法

  /// 基础数二 + 月干(百位数) = 条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber5 => HuangJiTiaoWenNumberInfo(
    number: secondaryBaseNumber + fourZhu.monthGanTaixuanNum * 100,
    description: "基础数二 + 月干(百位数) = 条文数",
    base: secondaryBaseNumber,
    added: fourZhu.monthGanTaixuanNum * 100,
  );

  /// 基础数二 + 日干(十位数) = 条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber6 => HuangJiTiaoWenNumberInfo(
    number: secondaryBaseNumber + fourZhu.dayGanTaixuanNum * 10,
    description: "基础数二 + 日干(十位数) = 条文数",
    base: secondaryBaseNumber,
    added: fourZhu.dayGanTaixuanNum * 10,
  );

  /// 基础数二 + 时干(个位数) = 条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber7 => HuangJiTiaoWenNumberInfo(
    number: secondaryBaseNumber + fourZhu.timeGanTaixuanNum,
    description: "基础数二 + 时干(个位数) = 条文数",
    base: secondaryBaseNumber,
    added: fourZhu.timeGanTaixuanNum,
  );

  /// 基础数二 + 日干(个位数) = 条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber8 => HuangJiTiaoWenNumberInfo(
    number: secondaryBaseNumber + fourZhu.dayGanTaixuanNum,
    description: "基础数二 + 日干(个位数) = 条文数",
    base: secondaryBaseNumber,
    added: fourZhu.dayGanTaixuanNum,
  );

  /// 获取所有条文数列表
  List<HuangJiTiaoWenNumberInfo> get allTiaoWenInfoList => [
    tiaowenNumber1,
    tiaowenNumber2,
    tiaowenNumber3,
    tiaowenNumber4,
    tiaowenNumber5,
    tiaowenNumber6,
    tiaowenNumber8,
  ];
  @override
  List<int> get allTiaowenNumbers =>
      allTiaoWenInfoList.map((e) => e.normalizedNumber).toList();
}
