import '../domain/four_zhu.dart';

/// 皇极取数法（又名：元会运世取数）三
///
/// 实现步骤：
/// 1. 排四柱，四柱天干与地支配太玄数
/// 2. 年干+年支=元(千位)，月干+月支=会(百位)，日干+日支=运(十位)，时干+时支=世(个位)
/// 3. 年+月 互合成数顺左旋取数（也叫："元会基本数"）；日+时 互合成数逆右旋取数（也叫："运世基础数"）
/// 4. 元会基础数 + 年干太玄数(千位) = 条文数（如果条文数大于13000 则将条文数减去12000）
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
@Deprecated('使用RealCase9Refactored')
class TiaoWenNumberCalculationStrategy {
  static const String strategyName = "皇极取数三";

  final FourZhu fourZhu;
  late final int yuanNumber;
  late final int monthNumber;
  late final int dayNumber;
  late final int timeNumber;
  late final int yuanHuiNumber;
  late final int originalPrimaryNumber;
  late final int yunShiNumber;
  late final int originalSecondaryNumber;

  int? _primaryBaseNumber;
  int? _primaryBaseTimes;
  int? _secondaryBaseNumber;
  int? _secondaryBaseTimes;

  TiaoWenNumberCalculationStrategy(this.fourZhu) {
    _initializeNumbers();
  }

  void _initializeNumbers() {
    // 计算元、会、运、世数
    yuanNumber = fourZhu.yearGanTaixuanNum + fourZhu.yearZhiTaixuanNum;
    monthNumber = fourZhu.monthGanTaixuanNum + fourZhu.monthZhiTaixuanNum;
    dayNumber = fourZhu.dayGanTaixuanNum + fourZhu.dayZhiTaixuanNum;
    timeNumber = fourZhu.timeGanTaixuanNum + fourZhu.timeZhiTaixuanNum;

    // 处理元数和月数（确保至少两位数）
    int tmpYuanNumber = yuanNumber;
    if (tmpYuanNumber < 10) {
      tmpYuanNumber = tmpYuanNumber * 10;
    }
    int tmpMonthNumber = monthNumber;
    if (tmpMonthNumber < 10) {
      tmpMonthNumber = tmpMonthNumber * 10;
    }

    // 元会互合成数顺左旋取数
    yuanHuiNumber = int.parse('$tmpYuanNumber$tmpMonthNumber');
    if (yuanHuiNumber > 13000) {
      yuanHuiNumber = yuanHuiNumber - 12000;
    }

    int tempPrimaryNumber = yuanHuiNumber + fourZhu.yearGanTaixuanNum * 1000;
    // 如果基本数大于13000 则减去12000
    if (tempPrimaryNumber > 13000) {
      tempPrimaryNumber -= 12000;
    }
    originalPrimaryNumber = tempPrimaryNumber;

    // 处理日数和时数（右旋）
    int tmpDayNumber = dayNumber;
    if (dayNumber < 10) {
      tmpDayNumber = tmpDayNumber * 10;
    }
    // 右旋
    String tmpDayStr = tmpDayNumber.toString();
    tmpDayNumber = int.parse(
      '${tmpDayStr.substring(tmpDayStr.length - 1)}${tmpDayStr.substring(0, tmpDayStr.length - 1)}',
    );

    int tmpTimeNumber = timeNumber;
    if (timeNumber < 10) {
      tmpTimeNumber = tmpTimeNumber * 10;
    }
    String tmpTimeStr = tmpTimeNumber.toString();
    tmpTimeNumber = int.parse(
      '${tmpTimeStr.substring(tmpTimeStr.length - 1)}${tmpTimeStr.substring(0, tmpTimeStr.length - 1)}',
    );

    yunShiNumber = int.parse('$tmpDayNumber$tmpTimeNumber');
    int tempSecondaryNumber = yunShiNumber + fourZhu.yearGanTaixuanNum * 1000;
    if (tempSecondaryNumber > 13000) {
      tempSecondaryNumber -= 12000;
    }
    originalSecondaryNumber = tempSecondaryNumber;
  }

  /// 设置主要基础数（基础数一）
  void setPrimaryBaseNumber(int primaryBaseNumber, int primaryBaseTimes) {
    _primaryBaseNumber = primaryBaseNumber;
    _primaryBaseTimes = primaryBaseTimes;
  }

  /// 设置次要基础数（基础数二）
  void setSecondaryBaseNumber(int secondaryBaseNumber, int secondaryBaseTimes) {
    _secondaryBaseNumber = secondaryBaseNumber;
    _secondaryBaseTimes = secondaryBaseTimes;
  }

  /// 获取主要基础数（基础数一）
  int get primaryBaseNumber => _primaryBaseNumber ?? originalPrimaryNumber;

  /// 获取次要基础数（基础数二）
  int get secondaryBaseNumber =>
      _secondaryBaseNumber ?? originalSecondaryNumber;

  /// 获取主要基础数倍数
  int get primaryBaseTimes => _primaryBaseTimes ?? 0;

  /// 获取次要基础数倍数
  int get secondaryBaseTimes => _secondaryBaseTimes ?? 0;

  /// 基础数二 = 基础数一 + 日干支合数（日干十位、日支个位）
  int get baseNumber2 {
    int dayGanZhiCombined =
        fourZhu.dayGanTaixuanNum * 10 + fourZhu.dayZhiTaixuanNum;
    int result = primaryBaseNumber + dayGanZhiCombined;
    return result > 13000 ? result - 12000 : result;
  }

  /// 基础数三 = 运世基本数 + 年干太玄千位
  int get baseNumber3 {
    int result = yunShiNumber + fourZhu.yearGanTaixuanNum * 1000;
    return result > 13000 ? result - 12000 : result;
  }

  /// 基础数四 = 基础数三 + 日干十位 + 日支个位（日干支合数）
  int get baseNumber4 {
    int dayGanZhiCombined =
        fourZhu.dayGanTaixuanNum * 10 + fourZhu.dayZhiTaixuanNum;
    int result = baseNumber3 + dayGanZhiCombined;
    return result > 13000 ? result - 12000 : result;
  }

  /// 获取向前的条文数列表
  List<int> previousTiaowenNumberList(
    int originalBaseNumber,
    int total, [
    int baseFactor = 31,
  ]) {
    List<int> result = [];
    for (int i = 0; i < total; i++) {
      result.add(originalBaseNumber - i * baseFactor);
    }
    return result;
  }

  /// 获取向后的条文数列表
  List<int> nextTiaowenNumberList(
    int originalBaseNumber,
    int total, [
    int baseFactor = 31,
  ]) {
    List<int> result = [];
    for (int i = 0; i < total; i++) {
      result.add(originalBaseNumber + i * baseFactor);
    }
    return result;
  }

  /// 获取向前第n个数
  int getPreviousNumberByN(
    int originalBaseNumber,
    int n, [
    int baseFactor = 31,
  ]) {
    return originalBaseNumber - n * baseFactor;
  }

  /// 获取向后第n个数
  int getNextNumberByN(int originalBaseNumber, int n, [int baseFactor = 31]) {
    return originalBaseNumber + n * baseFactor;
  }

  // 基础数一的条文数计算方法

  /// 基础数一 + 月干(百位数) = 条文数
  int get tiaowenNumber1 {
    int result = primaryBaseNumber + fourZhu.monthGanTaixuanNum * 100;
    return result > 13000 ? result - 12000 : result;
  }

  /// 基础数一 + 月支(百位数) = 条文数
  int get tiaowenNumber2 {
    int result = primaryBaseNumber + fourZhu.monthZhiTaixuanNum * 100;
    return result > 13000 ? result - 12000 : result;
  }

  // 基础数二的条文数计算方法

  /// 基础数二 + 时干个位 = 条文数
  int get tiaowenNumber3 {
    int result = baseNumber2 + fourZhu.timeGanTaixuanNum;
    return result > 13000 ? result - 12000 : result;
  }

  /// 基础数二 + 时支个位 = 条文数
  int get tiaowenNumber4 {
    int result = baseNumber2 + fourZhu.timeZhiTaixuanNum;
    return result > 13000 ? result - 12000 : result;
  }

  // 基础数三的条文数计算方法

  /// 基础数三 + 月干百位 = 条文数
  int get tiaowenNumber5 {
    int result = baseNumber3 + fourZhu.monthGanTaixuanNum * 100;
    return result > 13000 ? result - 12000 : result;
  }

  /// 基础数三 + 月支百位 = 条文数
  int get tiaowenNumber6 {
    int result = baseNumber3 + fourZhu.monthZhiTaixuanNum * 100;
    return result > 13000 ? result - 12000 : result;
  }

  // 基础数四的条文数计算方法

  /// 基础数四 + 时干(个位数) = 条文数
  int get tiaowenNumber7 {
    int result = baseNumber4 + fourZhu.timeGanTaixuanNum;
    return result > 13000 ? result - 12000 : result;
  }

  /// 基础数四 + 时支(个位数) = 条文数
  int get tiaowenNumber8 {
    int result = baseNumber4 + fourZhu.timeZhiTaixuanNum;
    return result > 13000 ? result - 12000 : result;
  }

  /// 获取所有条文数列表
  List<int> get allTiaowenNumbers {
    return [
      tiaowenNumber1,
      tiaowenNumber2,
      tiaowenNumber3,
      tiaowenNumber4,
      tiaowenNumber5,
      tiaowenNumber6,
      tiaowenNumber7,
      tiaowenNumber8,
    ];
  }

  /// 获取四柱基础数列表
  List<int> get fourZhuBaseNumberList {
    return [yuanNumber, monthNumber, dayNumber, timeNumber];
  }

  /// 获取所有基础数列表
  List<int> get allBaseNumbers {
    return [primaryBaseNumber, baseNumber2, baseNumber3, baseNumber4];
  }
}
