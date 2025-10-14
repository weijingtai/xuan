import '../../domain/four_zhu.dart';
import 'huang_ji_qu_shu_base_strategy.dart';

/// 皇极取数法（又名：元会运世取数）三
///
/// 实现步骤：
/// 1. 排四柱，四柱天干与地支配太玄数
/// 2. 年干+年支=元(千位)，月干+月支=会(百位)，日干+日支=运(十位)，时干+时支=世(个位)
/// 3. 年+月 互合成数顺左旋取数（也叫："元会基本数"）；日+时 互合成数逆右旋取数（也叫："运世基础数"）
/// 4. 元会基础数 + 年干太玄数 = 条文数（如果条文数大于13000 则将条文数减去12000）
/// 5. 次条文数为初刻数，如果符合则将此条文数作为基础数计算，如不符合则按照"30"递加或递减 直到找到对应的
/// 6. 得到基础数后进行如下操作：
///   + 基础数一 + 月干(百位数） = 条文数
///   + 基础数一 + 月支(百位数) = 条文数
///   基础数二 = 基础数一 + 日干支合数（日干十位、日支个位）
///   + 基本数二 + 时干个位 = 条文数
///   + 基本数二 + 时支个位 = 条文数
///   基础数三 = 运世基本数 + 年干太玄千位
///   + 基础数三 + 月干百位 = 条文数
///   + 基础数三 + 月支百位 = 条文数
///   基本数四 = 基础数三 + 日干十位 + 日支个位（日干支合数）
///   + 基础数四 + 时干(个位数）= 条文数
///   + 基础数四 + 时支(个位数) = 条文数
class HuangJi3Calcaulation extends HuangJiBaseCalculation {
  static const String strategyName = "皇极取数三";

  HuangJiBasicNumberInfo get primaryNextBaseNumberInfo =>
      HuangJiBasicNumberInfo(
        order: 1,
        number:
            primaryBaseNumberInfo.number +
            (dayGanTaiXuanNum * 10 + dayZhiTaiXuanNum),
        base: primaryBaseNumberInfo.number,
        baseDesc: '基本数一 (元会基本数 + 千位年干太玄数)',
        added: (dayGanTaiXuanNum * 10 + dayZhiTaiXuanNum),
        addedDesc: '日干支合数（日干十位、日支个位）',
        description: '基本数一 + 日干支合数 = 基础数二',
      );
  HuangJiBasicNumberInfo get secondaryNextBaseNumberInfo =>
      HuangJiBasicNumberInfo(
        order: 2,
        number:
            secondaryBaseNumberInfo.number +
            (dayGanTaiXuanNum * 10 + dayZhiTaiXuanNum),
        base: secondaryBaseNumberInfo.number,
        baseDesc: '基本数二',
        added: (dayGanTaiXuanNum * 10 + dayZhiTaiXuanNum),
        addedDesc: '日干支合数（日干十位、日支个位）',
        description: '基本数二 + 日干支合数',
      );

  HuangJi3Calcaulation(super.fourZhu);

  @override
  String get name => strategyName;

  @override
  String get description => "皇极取数法第三种变体，使用四个基础数分别计算条文数";

  @override
  List<String> get detailSteps => [
    "排四柱，四柱天干与地支配太玄数",
    "年干+年支=元(千位)，月干+月支=会(百位)，日干+日支=运(十位)，时干+时支=世(个位)",
    "年+月 互合成数顺左旋取数；日+时 互合成数逆右旋取数",
    "元会基础数 + 年干太玄数 = 基础数一",
    "基础数二 = 基础数一 + 日干支合数",
    "基础数三 = 运世基本数 + 年干太玄千位",
    "基础数四 = 基础数三 + 日干支合数",
    "四个基础数分别计算条文数，共生成8个条文数",
  ];
  // 基础数一的条文数计算方法

  /// 基础数一 + 月干(百位数) = 条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber1 => HuangJiTiaoWenNumberInfo(
    number: primaryBaseNumber + monthGanTaiXuanNum * 100,
    description: "基础数一 + 月干(百位数) = 条文数",
    base: primaryBaseNumber,
    added: monthGanTaiXuanNum * 100,
  );

  /// 基础数一 + 月支(百位数) = 条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber2 => HuangJiTiaoWenNumberInfo(
    number: primaryBaseNumber + fourZhu.monthZhiTaixuanNum * 100,
    description: "基础数一 + 月支(百位数) = 条文数",
    base: primaryBaseNumber,
    added: fourZhu.monthZhiTaixuanNum * 100,
  );

  // 基础数二的条文数计算方法

  /// 基础数二 + 时干个位 = 条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber3 => HuangJiTiaoWenNumberInfo(
    number: primaryNextBaseNumberInfo.number + timeGanTaiXuanNum,
    description: "基础数一派生数 + 时干个位 = 条文数",
    base: primaryNextBaseNumberInfo.number,
    added: timeGanTaiXuanNum,
  );

  /// 基础数二 + 时支个位 = 条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber4 => HuangJiTiaoWenNumberInfo(
    number: primaryNextBaseNumberInfo.number + timeZhiTaiXuanNum,
    description: "基础数一派生数 + 时支个位 = 条文数",
    base: primaryNextBaseNumberInfo.number,
    added: fourZhu.timeZhiTaixuanNum,
  );

  // 基础数三的条文数计算方法

  /// 基础数三 + 月干百位 = 条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber5 => HuangJiTiaoWenNumberInfo(
    number: secondaryBaseNumberInfo.number + monthGanTaiXuanNum * 100,
    description: "基础数二 + 月干百位 = 条文数",
    base: secondaryBaseNumberInfo.number,
    added: monthGanTaiXuanNum * 100,
  );

  /// 基础数三 + 月支百位 = 条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber6 => HuangJiTiaoWenNumberInfo(
    number: secondaryBaseNumberInfo.number + monthZhiTaiXuanNum * 100,
    description: "基础数二 + 月支百位 = 条文数",
    base: secondaryBaseNumberInfo.number,
    added: monthZhiTaiXuanNum * 100,
  );

  // 基础数四的条文数计算方法

  /// 基础数四 + 时干(个位数) = 条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber7 => HuangJiTiaoWenNumberInfo(
    number: secondaryBaseNumberInfo.number + timeGanTaiXuanNum,
    description: "基础数二派生数 + 时干(个位数) = 条文数",
    base: secondaryBaseNumberInfo.number,
    added: timeGanTaiXuanNum,
  );

  /// 基础数四 + 时支(个位数) = 条文数
  HuangJiTiaoWenNumberInfo get tiaowenNumber8 => HuangJiTiaoWenNumberInfo(
    number: secondaryBaseNumberInfo.number + timeZhiTaiXuanNum,
    description: "基础数二派生数 + 时支(个位数) = 条文数",
    base: secondaryBaseNumberInfo.number,
    added: timeZhiTaiXuanNum,
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

  /// 获取所有条文数列表
  @override
  List<int> get allTiaowenNumbers =>
      allTiaoWenInfoList.map((e) => e.normalizedNumber).toList();
}
