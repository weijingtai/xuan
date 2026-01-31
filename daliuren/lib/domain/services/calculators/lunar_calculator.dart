import 'package:common/enums.dart';
import 'package:tyme/tyme.dart' hide YinYang;
import 'base_calculator.dart';

/// 农历计算器
///
/// 负责将公历时间转换为农历、计算四柱八字、确定月将、判断阴阳遁和局数
class LunarCalculator extends BaseCalculator {
  @override
  String get name => 'LunarCalculator';

  /// 计算四柱八字
  String calculateBaZi(DateTime dateTime) {
    try {
      final solarTime = SolarTime.fromYmdHms(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
        dateTime.second,
      );
      final eightChar = solarTime.getLunarHour().getEightChar();
      return [
        eightChar.getYear().getName(),
        eightChar.getMonth().getName(),
        eightChar.getDay().getName(),
        eightChar.getHour().getName(),
      ].join(" ");
    } catch (e) {
      throw Exception('Failed to calculate BaZi: $e');
    }
  }

  /// 确定月将(根据节气)
  MonthGeneral calculateMonthGeneral(DateTime dateTime) {
    try {
      final solarDay =
          SolarDay.fromYmd(dateTime.year, dateTime.month, dateTime.day);
      final term = solarDay.getTerm();
      final termJd = term.getJulianDay();
      final termTime = termJd.getSolarTime();
      final termAt = DateTime(
        termTime.getYear(),
        termTime.getMonth(),
        termTime.getDay(),
        termTime.getHour(),
        termTime.getMinute(),
        termTime.getSecond(),
      );

      // Get the previous qi (中气, even-indexed terms)
      String prevQiName;
      if (termAt.isAfter(dateTime)) {
        prevQiName = term.next(-1).getName();
      } else {
        prevQiName = term.getName();
      }
      return MonthGeneral.fromByStartAtJie(prevQiName);
    } catch (e) {
      throw Exception('Failed to calculate MonthGeneral: $e');
    }
  }

  /// 判断阴阳遁
  YinYang determineYinYangDun(bool isDayGuiRen) {
    return isDayGuiRen ? YinYang.YANG : YinYang.YIN;
  }

  /// 解析八字字符串为JiaZi列表
  List<JiaZi> parseBaZiString(String baZiStr) {
    try {
      final parts = baZiStr.trim().split(RegExp(r'\s+'));
      if (parts.length != 4) {
        throw ArgumentError(
            'Invalid BaZi format. Expected "年 月 日 时", got: $baZiStr');
      }

      return [
        JiaZi.getFromGanZhiValue(parts[0])!,
        JiaZi.getFromGanZhiValue(parts[1])!,
        JiaZi.getFromGanZhiValue(parts[2])!,
        JiaZi.getFromGanZhiValue(parts[3])!,
      ];
    } catch (e) {
      throw Exception('Failed to parse BaZi string: $e');
    }
  }
}
