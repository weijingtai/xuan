/// 第六种，太玄取数法（2）
/// 1. 排四柱，四柱天干与地支配太玄数
/// 2. 年柱月柱和为前卦-用先天卦：年柱干支相加模"8"取余，取先天卦作为下卦；月柱同理，做为上挂
/// 3. 取错卦。上卦为千位、下卦为百位、错卦上为十、错下为各 -- 用先天卦数
/// 4. 取六亲考刻中已考订的基本数，余其相加，次数为年月基本数，加减96各四次共8各条文数
/// -------
/// 5. 日柱 时柱 用后天卦 ----- 遇"10"不用，只取个位
/// 6. 取其错卦 作为第二卦
/// 7. 上卦为千位，下卦为百位，二上为十，而下为个  --- 用后天数
/// 8. 取六亲考刻中已考订的基本数，余其相加，次数为年月基本数，加减96各四次共8各条文数

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
/// 这种方法，目前以及存在两种处理方式
/// 1. 年月 太玄取先天上下卦；日时太玄取后天上下卦
@Deprecated("TaiXuanQianHouCalculation")
class TiaoWenNumberCalculationStrategy {
  static const String strategyName = '太玄取数二';

  /// 天干卦映射
  static const Map<String, String> tianganGuaMapper = {
    // This would need to be defined based on the original implementation
  };

  /// 地支卦映射
  static const Map<String, String> dizhiGuaMapper = {
    // This would need to be defined based on the original implementation
  };

  final FourZhu fourZhu;
  final int correctionKeNumber;
  final String yearMonthGua;
  final String yearMonthNextGua;
  final int yearMonthBaseNumber;
  final String dayTimeGua;
  final String dayTimeNextGua;
  final int dayTimeBaseNumber;

  /// 构造函数
  ///
  /// [fourZhu] 四柱信息
  /// [correctionKeNumber] 六亲考刻数
  TiaoWenNumberCalculationStrategy({
    required this.fourZhu,
    required this.correctionKeNumber,
  }) : yearMonthGua = _calculateYearMonthGua(fourZhu),
       yearMonthNextGua = GuaUtils.guaToCuoGua(_calculateYearMonthGua(fourZhu)),
       yearMonthBaseNumber = _calculateYearMonthBaseNumber(fourZhu),
       dayTimeGua = _calculateDayTimeGua(fourZhu),
       dayTimeNextGua = GuaUtils.guaToCuoGua(_calculateDayTimeGua(fourZhu)),
       dayTimeBaseNumber = _calculateDayTimeBaseNumber(fourZhu);

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

  /// 计算日时卦
  static String _calculateDayTimeGua(FourZhu fourZhu) {
    final dayZhuGuaNumber = int.parse(
      (fourZhu.dayGanTaixuanNum + fourZhu.dayZhiTaixuanNum)
          .toString()
          .substring(
            (fourZhu.dayGanTaixuanNum + fourZhu.dayZhiTaixuanNum)
                    .toString()
                    .length -
                1,
          ),
    );
    final dayGua = Constants.houTianNumberGuaMapper[dayZhuGuaNumber]!;
    final timeZhuGuaNumber = int.parse(
      (fourZhu.timeGanTaixuanNum + fourZhu.timeZhiTaixuanNum)
          .toString()
          .substring(
            (fourZhu.timeGanTaixuanNum + fourZhu.timeZhiTaixuanNum)
                    .toString()
                    .length -
                1,
          ),
    );
    final timeGua = Constants.houTianNumberGuaMapper[timeZhuGuaNumber]!;
    return '$timeGua$dayGua';
  }

  /// 计算日时基本数
  static int _calculateDayTimeBaseNumber(FourZhu fourZhu) {
    final dayTimeGua = _calculateDayTimeGua(fourZhu);
    final dayTimeNextGua = GuaUtils.guaToCuoGua(dayTimeGua);

    final numberString = [
      Constants.houTianGuaNumberMapper[dayTimeGua[0]]!.toString(),
      Constants.houTianGuaNumberMapper[dayTimeGua[1]]!.toString(),
      Constants.houTianGuaNumberMapper[dayTimeNextGua[0]]!.toString(),
      Constants.houTianGuaNumberMapper[dayTimeNextGua[1]]!.toString(),
    ].join();

    return int.parse(numberString);
  }

  /// 第一个数字
  int get firstNumber => yearMonthBaseNumber + correctionKeNumber;

  /// 第二个数字
  int get secondNumber => dayTimeBaseNumber + correctionKeNumber;

  /// 四柱基本数字列表
  List<int> get fourZhuBaseNumberList {
    // Note: The original code references properties that don't exist in this class
    // This would need to be implemented based on the actual requirements
    throw UnimplementedError(
      'fourZhuBaseNumberList needs proper implementation',
    );
  }
}
