import 'package:common/enums.dart';
import 'package:common/models/divination_datetime.dart';
import 'package:daliuren/domain/services/calculate_month_general_service.dart';

class CalculateDayNightGuiRen {
  EnumDayNight calculate(
      DayNightBoundaryType dayNightType, DivinationDatetimeModel datetimeModel,
      {EnumDayNight dayNight = EnumDayNight.day}) {
    switch (dayNightType) {
      case DayNightBoundaryType.maoYou:
        // 卯->申 为昼
        // 酉->亥 为夜
        return [
          DiZhi.MAO,
          DiZhi.CHEN,
          DiZhi.SI,
          DiZhi.WU,
          DiZhi.WEI,
          DiZhi.SHEN
        ].contains(datetimeModel.timeJiaZi.diZhi)
            ? EnumDayNight.day
            : EnumDayNight.night;
      case DayNightBoundaryType.manual:
        return dayNight;
      case DayNightBoundaryType.season4:
      case DayNightBoundaryType.sunRiseSet:
        throw UnimplementedError();
    }
  }
}
