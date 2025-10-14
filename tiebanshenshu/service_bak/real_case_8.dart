import '../domain/four_zhu.dart';

/// 皇极取数法（又名：元会运世取数）二
///
/// 实现步骤：
/// 1. 排四柱，四柱天干与地支配太玄数
/// 2. 年干+年支=元(千位)，月干+月支=会(百位)，日干+日支=运(十位)，时干+时支=世(个位)
/// 3. 年+月 互合成数顺左旋取数（也叫："元会基本数"）；日+时 互合成数逆右旋取数（也叫："运世基础数"）
/// 4. 元会基础数 + 年干太玄数(千位) = 条文数（如果条文数大于13000 则将条文数减去12000）
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
@Deprecated('使用RealCase8Refactored')
class TiaoWenNumberCalculationStrategy {
  static const String strategyName = "皇极取数二";

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
    // 当得数为个位数时则在后面补'0'
    // 创建辅助函数减少重复计算
    int calculateNumber(int ganNum, int zhiNum) {
      int sum = ganNum + zhiNum;
      return sum < 10 ? sum * 10 : sum;
    }

    yuanNumber = calculateNumber(
      fourZhu.yearGanTaixuanNum,
      fourZhu.yearZhiTaixuanNum,
    );
    monthNumber = calculateNumber(
      fourZhu.monthGanTaixuanNum,
      fourZhu.monthZhiTaixuanNum,
    );
    dayNumber = calculateNumber(
      fourZhu.dayGanTaixuanNum,
      fourZhu.dayZhiTaixuanNum,
    );
    timeNumber = calculateNumber(
      fourZhu.timeGanTaixuanNum,
      fourZhu.timeZhiTaixuanNum,
    );
    // 元会互合成数顺左旋取数
    yuanHuiNumber = int.parse('$yuanNumber$monthNumber');
    int tempNumber = yuanHuiNumber + fourZhu.yearGanTaixuanNum * 1000;
    originalPrimaryNumber = tempNumber > 13000
        ? tempNumber - 12000
        : tempNumber;
    // 运世互合成数逆右旋取数
    int yunhui_time = int.parse(
      "${"$timeNumber".split("")[1]}${"$timeNumber".split("")[0]}",
    );
    int yunhui_day = int.parse(
      "${"$dayNumber".split("")[1]}${"$dayNumber".split("")[0]}",
    );
    yunShiNumber = int.parse('$yunhui_day$yunhui_time');
    int tempSecondaryNumber = yunShiNumber + fourZhu.yearGanTaixuanNum * 1000;
    originalSecondaryNumber = tempSecondaryNumber > 13000
        ? tempSecondaryNumber - 12000
        : tempSecondaryNumber;
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
  int get primaryBaseTimes => _primaryBaseTimes ?? 1;

  /// 获取次要基础数倍数
  int get secondaryBaseTimes => _secondaryBaseTimes ?? 1;

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
    return primaryBaseNumber + fourZhu.monthGanTaixuanNum * 100;
  }

  /// 基础数一 + 日干(十位数) = 条文数
  int get tiaowenNumber2 {
    return primaryBaseNumber + fourZhu.dayGanTaixuanNum * 10;
  }

  /// 基础数一 + 时干(个位数) = 条文数
  int get tiaowenNumber3 {
    return primaryBaseNumber + fourZhu.timeGanTaixuanNum;
  }

  /// 基础数一 + 时支(个位数) = 条文数
  int get tiaowenNumber4 {
    return primaryBaseNumber + fourZhu.timeZhiTaixuanNum;
  }

  // 基础数二的条文数计算方法

  /// 基础数二 + 月干(百位数) = 条文数
  int get tiaowenNumber5 {
    return secondaryBaseNumber + fourZhu.monthGanTaixuanNum * 100;
  }

  /// 基础数二 + 日干(十位数) = 条文数
  int get tiaowenNumber6 {
    return secondaryBaseNumber + fourZhu.dayGanTaixuanNum * 10;
  }

  /// 基础数二 + 时干(个位数) = 条文数
  int get tiaowenNumber7 {
    return secondaryBaseNumber + fourZhu.timeGanTaixuanNum;
  }

  /// 基础数二 + 日干(个位数) = 条文数
  int get tiaowenNumber8 {
    return secondaryBaseNumber + fourZhu.dayGanTaixuanNum;
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
}
