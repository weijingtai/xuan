import 'package:common/models/chinese_date_info.dart';

import '../constant/constants.dart' as Constants;

extension ChineseDateInfoExtension on ChineseDateInfo {
  // 年干是否为阳干
  bool get isYangGanYear {
    return eightChars.yearTianGan.isYang;
  }

  // 日干是否为阳干
  bool get isYangGanDay {
    return eightChars.dayTianGan.isYang;
  }

  // 年干太玄数
  int get yearGanTaixuanNum {
    return Constants.taixuanGanNumberMapper[eightChars.yearTianGan.name]!;
  }

  // 月干太玄数
  int get monthGanTaixuanNum {
    return Constants.taixuanGanNumberMapper[eightChars.monthTianGan.name]!;
  }

  // 日干太玄数
  int get dayGanTaixuanNum {
    return Constants.taixuanGanNumberMapper[eightChars.dayTianGan.name]!;
  }

  // 时干太玄数
  int get timeGanTaixuanNum {
    return Constants.taixuanGanNumberMapper[eightChars.hourTianGan.name]!;
  }

  // 年支太玄数
  int get yearZhiTaixuanNum {
    return Constants.taixuanZhiNumberMapper[eightChars.yearDiZhi.name]!;
  }

  // 月支太玄数
  int get monthZhiTaixuanNum {
    return Constants.taixuanZhiNumberMapper[eightChars.monthDiZhi.name]!;
  }

  // 日支太玄数
  int get dayZhiTaixuanNum {
    return Constants.taixuanZhiNumberMapper[eightChars.dayDiZhi.name]!;
  }

  // 时支太玄数
  int get timeZhiTaixuanNum {
    return Constants.taixuanZhiNumberMapper[eightChars.hourDiZhi.name]!;
  }

  // 便捷的干支字符串获取方法
  String get yearGanzhi => eightChars.year.name;
  String get monthGanzhi => eightChars.month.name;
  String get dayGanzhi => eightChars.day.name;
  String get timeGanzhi => eightChars.time.name;

  String get yearGan => eightChars.yearTianGan.name;
  String get yearZhi => eightChars.yearDiZhi.name;
  String get monthGan => eightChars.monthTianGan.name;
  String get monthZhi => eightChars.monthDiZhi.name;
  String get dayGan => eightChars.dayTianGan.name;
  String get dayZhi => eightChars.dayDiZhi.name;
  String get timeGan => eightChars.hourTianGan.name;
  String get timeZhi => eightChars.hourDiZhi.name;
}
