/// 第七种，皇极取数法（又名：元会运世取数）
/// 1. 排四柱，四柱天干与地支配太玄数
/// 2. 年干+年支=元(千位)，月干+月支=会(百位)，日干+日支=运(十位)，时干+时支=世(个位)
/// 3. 年+月 互合成数顺左旋取数（也叫："元会基本数"）；日+时 互合成数逆右旋取数（也叫："运世基础数"）
///  如： + 年元数为"9"，月会数为"18"，元会互合成数为9018
///      + 日运数为12，时世数为11， 逆右旋取数，运世互合成数为2111 并非"1211"
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

import '../constant/constants.dart' as Constants;
import '../domain/four_zhu.dart';
import '../domain/six_yao_gua.dart';
import '../utils/utils.dart' as GuaUtils;

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

  /// 每一爻，干支取太玄数相加（和数为"10"则不用）
  List<int> get eachYaoTaixuanSumList {
    return ganzhiList
        .map((ganzhi) => calculateTaixuanGanzhiSum(ganzhi))
        .toList();
  }

  /// 干支列表
  List<String> get ganzhiList {
    // This would need to be implemented based on the gua property
    // which seems to be missing from the constructor
    throw UnimplementedError('ganzhiList getter needs gua property');
  }

  /// 生成太玄每柱实例
  ///
  /// [ganzhi] 干支字符串
  /// [isYangYear] 是否为阳年
  static TaiXuanEachZhu generate(String ganzhi, bool isYangYear) {
    final ganGua =
        TiaoWenNumberCalculationStrategy.tianganGuaMapper[ganzhi[0]]!;
    final zhiGua = TiaoWenNumberCalculationStrategy
        .dizhiGuaMapper[ganzhi[ganzhi.length - 1]]!;
    final gua = SixYaoGua.generateFromGuaBySpecial(
      '$ganGua$zhiGua',
      getEachYaoGan(isYangYear),
    );
    final sixyaoGanzhi = gua.ganzhiList;
    final topGanzhiSum = calculateEachEightGuaGanzhiSum(
      sixyaoGanzhi.sublist(0, 3),
    );
    final bottomGanzhiSum = calculateEachEightGuaGanzhiSum(
      sixyaoGanzhi.sublist(3),
    );
    final baseNumber = int.parse('$topGanzhiSum$bottomGanzhiSum');

    // Note: This would need a different constructor or factory method
    // as the current constructor expects FourZhu and correctionKeNumber
    throw UnimplementedError('generate method needs refactoring');
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

/// 条文数计算策略类
///
/// 皇极取数一
@Deprecated('使用RealCase7Refactored')
class TiaoWenNumberCalculationStrategy {
  static const String strategyName = '皇极取数一';

  /// 天干卦映射
  static const Map<String, String> tianganGuaMapper = {
    // This would need to be defined based on the original implementation
  };

  /// 地支卦映射
  static const Map<String, String> dizhiGuaMapper = {
    // This would need to be defined based on the original implementation
  };

  final FourZhu fourZhu;
  final int yuanNumber;
  final int monthNumber;
  final int dayNumber;
  final int timeNumber;
  final int yuanHuiNumber;
  final int originalPrimaryNumber;
  int primaryBaseNumber;
  int primaryBaseTimes;
  final int yunShiNumber;
  final int originalSecondaryNumber;
  int secondaryBaseNumber;
  int secondaryBaseTimes;

  /// 构造函数
  ///
  /// [fourZhu] 四柱信息
  TiaoWenNumberCalculationStrategy(this.fourZhu)
    : yuanNumber = fourZhu.yearGanTaixuanNum + fourZhu.yearZhiTaixuanNum,
      monthNumber = fourZhu.monthGanTaixuanNum + fourZhu.monthZhiTaixuanNum,
      dayNumber = fourZhu.dayGanTaixuanNum + fourZhu.dayZhiTaixuanNum,
      timeNumber = fourZhu.timeGanTaixuanNum + fourZhu.timeZhiTaixuanNum,
      yuanHuiNumber = _calculateYuanHuiNumber(fourZhu),
      originalPrimaryNumber = _calculateOriginalPrimaryNumber(fourZhu),
      primaryBaseNumber = _calculateOriginalPrimaryNumber(fourZhu),
      primaryBaseTimes = 0,
      yunShiNumber = _calculateYunShiNumber(fourZhu),
      originalSecondaryNumber = _calculateOriginalSecondaryNumber(fourZhu),
      secondaryBaseNumber = _calculateOriginalSecondaryNumber(fourZhu),
      secondaryBaseTimes = 0;

  /// 计算元会数
  static int _calculateYuanHuiNumber(FourZhu fourZhu) {
    final yuanNumber = fourZhu.yearGanTaixuanNum + fourZhu.yearZhiTaixuanNum;
    final monthNumber = fourZhu.monthGanTaixuanNum + fourZhu.monthZhiTaixuanNum;

    int tmpYuanNumber = yuanNumber;
    if (tmpYuanNumber < 10) {
      tmpYuanNumber = tmpYuanNumber * 10;
    }
    int tmpMonthNumber = monthNumber;
    if (tmpMonthNumber < 10) {
      tmpMonthNumber = tmpMonthNumber * 10;
    }

    // 左旋
    int yuanHuiNumber = int.parse('$tmpYuanNumber$tmpMonthNumber');
    if (yuanHuiNumber > 13000) {
      yuanHuiNumber = yuanHuiNumber - 12000;
    }
    return yuanHuiNumber;
  }

  /// 计算原始主要数字
  static int _calculateOriginalPrimaryNumber(FourZhu fourZhu) {
    final yuanHuiNumber = _calculateYuanHuiNumber(fourZhu);
    int originalPrimaryNumber =
        yuanHuiNumber + fourZhu.yearGanTaixuanNum * 1000;

    // 如果基本数大于13000 则减去12000
    if (originalPrimaryNumber > 13000) {
      originalPrimaryNumber -= 12000;
    }
    return originalPrimaryNumber;
  }

  /// 计算运世数
  static int _calculateYunShiNumber(FourZhu fourZhu) {
    final dayNumber = fourZhu.dayGanTaixuanNum + fourZhu.dayZhiTaixuanNum;
    final timeNumber = fourZhu.timeGanTaixuanNum + fourZhu.timeZhiTaixuanNum;

    int tmpDayNumber = dayNumber;
    if (dayNumber < 10) {
      tmpDayNumber = tmpDayNumber * 10;
    }

    // 右旋
    final tmpDayStr = tmpDayNumber.toString();
    tmpDayNumber = int.parse(
      '${tmpDayStr[tmpDayStr.length - 1]}${tmpDayStr.substring(0, tmpDayStr.length - 1)}',
    );

    int tmpTimeNumber = timeNumber;
    if (timeNumber < 10) {
      tmpTimeNumber = tmpTimeNumber * 10;
    }
    final tmpTimeStr = tmpTimeNumber.toString();
    tmpTimeNumber = int.parse(
      '${tmpTimeStr[tmpTimeStr.length - 1]}${tmpTimeStr.substring(0, tmpTimeStr.length - 1)}',
    );

    return int.parse('$tmpDayNumber$tmpTimeNumber');
  }

  /// 计算原始次要数字
  static int _calculateOriginalSecondaryNumber(FourZhu fourZhu) {
    final yunShiNumber = _calculateYunShiNumber(fourZhu);
    int originalSecondaryNumber =
        yunShiNumber + fourZhu.yearGanTaixuanNum * 1000;
    if (originalSecondaryNumber > 13000) {
      originalSecondaryNumber -= 12000;
    }
    return originalSecondaryNumber;
  }

  /// 设定元会的基本数当originalPrimaryBaseNumber条文不符命主时
  ///
  /// [primaryBaseNumber] 主要基本数
  /// [primaryBaseTimes] 主要基本次数
  void setPrimaryBaseNumber(int primaryBaseNumber, int primaryBaseTimes) {
    this.primaryBaseNumber = primaryBaseNumber;
    this.primaryBaseTimes = primaryBaseTimes;
  }

  /// 设定运世的基本数，当originalSecondaryBaseNumber条文不符命主时
  ///
  /// [secondaryBaseNumber] 次要基本数
  /// [secondaryBaseTimes] 次要基本次数
  void setSecondaryBaseNumber(int secondaryBaseNumber, int secondaryBaseTimes) {
    this.secondaryBaseNumber = secondaryBaseNumber;
    this.secondaryBaseTimes = secondaryBaseTimes;
  }

  /// 次条文数为初刻数，如果符合则将此条文数作为基础数计算，如不符合则按照"30"递减直到找到对应的
  ///
  /// [originalBaseNumber] 获取为primaryBaseNumber(元会)或secondaryBaseNumber(运世)
  /// [total] "向前"取total个
  /// [baseFactor] 默认递减的数
  List<int> previousTiaowenNumberList(
    int originalBaseNumber,
    int total, {
    int baseFactor = 31,
  }) {
    final res = <int>[];
    for (int i = 0; i < total; i++) {
      res.add(originalBaseNumber - i * baseFactor);
    }
    return res;
  }

  /// 次条文数为初刻数，如果符合则将此条文数作为基础数计算，如不符合则按照"30"递增直到找到对应的
  ///
  /// [originalBaseNumber] 获取为primaryBaseNumber(元会)或secondaryBaseNumber(运世)
  /// [total] "向后"取total个
  /// [baseFactor] 默认递增的数
  List<int> nextTiaowenNumberList(
    int originalBaseNumber,
    int total, {
    int baseFactor = 31,
  }) {
    final res = <int>[];
    for (int i = 0; i < total; i++) {
      res.add(originalBaseNumber + i * baseFactor);
    }
    return res;
  }

  /// 获取向前第n个数字
  ///
  /// [originalBaseNumber] 原始基本数
  /// [n] 第n个
  /// [baseFactor] 基本因子
  int getPreviousNumberByN(
    int originalBaseNumber,
    int n, {
    int baseFactor = 31,
  }) {
    return originalBaseNumber - n * baseFactor;
  }

  /// 获取向后第n个数字
  ///
  /// [originalBaseNumber] 原始基本数
  /// [n] 第n个
  /// [baseFactor] 基本因子
  int getNextNumberByN(int originalBaseNumber, int n, {int baseFactor = 31}) {
    return originalBaseNumber + n * baseFactor;
  }

  /// 基础数+年支千位=条文数
  int get tiaowenNumber => primaryBaseNumber + fourZhu.yearGanTaixuanNum * 1000;

  /// 基础数+月干百位数=条文数
  int get tiaowenNumber1 =>
      primaryBaseNumber + fourZhu.monthGanTaixuanNum * 100;

  /// 基础数+月支干百位数=条文数
  int get tiaowenNumber2 =>
      primaryBaseNumber + fourZhu.monthZhiTaixuanNum * 100;

  /// 基础数+日支干合数=条文数
  int get tiaowenNumber3 =>
      primaryBaseNumber +
      fourZhu.dayGanTaixuanNum * 10 +
      fourZhu.dayZhiTaixuanNum;

  /// 基础数+时干合数=条文数
  int get tiaowenNumber4 => primaryBaseNumber + fourZhu.timeGanTaixuanNum;

  /// 基础数+时支合数=条文数
  int get tiaowenNumber4Alt => primaryBaseNumber + fourZhu.timeZhiTaixuanNum;

  /// 基础数+日干支互合数+时支合数=条文数
  int get tiaowenNumber5 =>
      primaryBaseNumber +
      int.parse('${fourZhu.dayGanTaixuanNum}${fourZhu.dayZhiTaixuanNum}') +
      fourZhu.timeZhiTaixuanNum;

  /// 基础数+日干支互合数+时干合数=条文数
  int get tiaowenNumber6 =>
      primaryBaseNumber +
      int.parse('${fourZhu.dayGanTaixuanNum}${fourZhu.dayZhiTaixuanNum}') +
      fourZhu.timeGanTaixuanNum;

  /// 运世基础数+日干支互合数=条文数
  int get tiaowenNumber8 =>
      yunShiNumber +
      int.parse('${fourZhu.dayGanTaixuanNum}${fourZhu.dayZhiTaixuanNum}');

  /// 运世基础数+时干=条文数
  int get tiaowenNumber9 => yunShiNumber + fourZhu.timeGanTaixuanNum;

  /// 运世基础数+时支=条文数
  int get tiaowenNumber10 => yunShiNumber + fourZhu.timeZhiTaixuanNum;

  /// 运世基础数+日干支互合数+时干=条文数
  int get tiaowenNumber11 =>
      yunShiNumber +
      int.parse('${fourZhu.dayGanTaixuanNum}${fourZhu.dayZhiTaixuanNum}') +
      fourZhu.timeGanTaixuanNum;

  /// 运世基础数+日干支互合数+时支=条文数
  int get tiaowenNumber12 =>
      yunShiNumber +
      int.parse('${fourZhu.dayGanTaixuanNum}${fourZhu.dayZhiTaixuanNum}') +
      fourZhu.timeZhiTaixuanNum;
}
