import 'package:common/enums.dart';
import 'package:lunar/calendar/Lunar.dart';
import 'base_calculator.dart';

/// 农历计算器
///
/// 负责将公历时间转换为农历、计算四柱八字、确定月将、判断阴阳遁和局数
class LunarCalculator extends BaseCalculator {
  @override
  String get name => 'LunarCalculator';

  /// 计算四柱八字
  ///
  /// [dateTime] 公历时间
  /// Returns: 四柱八字字符串,格式为 "年柱 月柱 日柱 时柱"
  ///
  /// Example:
  /// ```dart
  /// final baZi = calculator.calculateBaZi(DateTime(2025, 9, 30, 14, 30));
  /// print(baZi); // "乙巳 乙酉 甲子 辛未"
  /// ```
  String calculateBaZi(DateTime dateTime) {
    try {
      final lunar = Lunar.fromDate(dateTime);
      final baZi = lunar.getBaZi();
      return baZi.join(" ");
    } catch (e) {
      throw Exception('Failed to calculate BaZi: $e');
    }
  }

  /// 确定月将(根据节气)
  ///
  /// 月将是根据节气确定的月建,用于生成天盘
  ///
  /// [dateTime] 公历时间
  /// Returns: 对应的月将
  ///
  /// 月将对应关系:
  /// - 立春-惊蛰: 寅(正月)
  /// - 惊蛰-清明: 卯(二月)
  /// - 清明-立夏: 辰(三月)
  /// - 立夏-芒种: 巳(四月)
  /// - 芒种-小暑: 午(五月)
  /// - 小暑-立秋: 未(六月)
  /// - 立秋-白露: 申(七月)
  /// - 白露-寒露: 酉(八月)
  /// - 寒露-立冬: 戌(九月)
  /// - 立冬-大雪: 亥(十月)
  /// - 大雪-小寒: 子(十一月)
  /// - 小寒-立春: 丑(十二月)
  MonthGeneral calculateMonthGeneral(DateTime dateTime) {
    try {
      final lunar = Lunar.fromDate(dateTime);
      final prevJieQi = lunar.getPrevQi(); // 获取前一个节气
      final jieQiName = prevJieQi.getName();
      return MonthGeneral.fromByStartAtJie(jieQiName);
    } catch (e) {
      throw Exception('Failed to calculate MonthGeneral: $e');
    }
  }

  /// 判断阴阳遁
  ///
  /// 根据时辰判断是阳遁还是阴遁:
  /// - 白天(卯、辰、巳、午、未、申): 判断昼贵人 → 阳遁
  /// - 夜晚(酉、戌、亥、子、丑、寅): 判断夜贵人 → 阴遁
  ///
  /// [isDayGuiRen] 是否为昼贵人
  /// Returns: 阳遁或阴遁
  YinYang determineYinYangDun(bool isDayGuiRen) {
    return isDayGuiRen ? YinYang.YANG : YinYang.YIN;
  }

  /// 解析八字字符串为JiaZi列表
  ///
  /// [baZiStr] 八字字符串,格式为 "年柱 月柱 日柱 时柱"
  /// Returns: [年JiaZi, 月JiaZi, 日JiaZi, 时JiaZi]
  List<JiaZi> parseBaZiString(String baZiStr) {
    try {
      final parts = baZiStr.trim().split(RegExp(r'\s+'));
      if (parts.length != 4) {
        throw ArgumentError('Invalid BaZi format. Expected "年 月 日 时", got: $baZiStr');
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
