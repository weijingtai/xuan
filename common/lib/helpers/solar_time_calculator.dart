import 'package:sweph/sweph.dart';
import 'package:timezone/timezone.dart' as tz;

class SolarTimeCalculator {
  late final DateTime dateTime;
  late final DateTime meanSolarTime;
  final double longitude;

  SolarTimeCalculator({required this.dateTime, required this.longitude}) {
    final longitudeHour = longitude / 15.0;
    meanSolarTime =
        dateTime.add(Duration(minutes: (longitudeHour * 60).toInt()));
  }
  // static tz.TZDateTime calculateTrueSolarTime(
  //     tz.TZDateTime meanSolarTime, double longitude) {
  // }
  DateTime getTrueSolarTime() {
    // 1. 获取设备位置和时区
    // final position = await _getCurrentPosition();
    // final timeZone = await FlutterNativeTimezone.getLocalTimezone();

    // 2. 转换当前时间到 UTC 儒略日（JD）

    /// 在1582年10月4日之前使用 SE_JUL_CAL
    /// 在1582年10月15日之后使用 SE_GREG_CAL
    ///
    ///
    // 检测是否传入参数为utc

    // 返回结果“1”为TT时间（地球时间），“2”为UT1(世界时间)的儒略历
    final List<double> jdResult = Sweph.swe_utc_to_jd(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
        dateTime.second.toDouble(),
        CalendarType.SE_GREG_CAL);

    // TT 时间用于天体计算，UT时间用于修正本地,
    // 计算真太阳时使用 UT
    final double jd = jdResult[1];
    final double eotMinutes = Sweph.swe_time_equ(jd);

    // 4. 计算地方平太阳时（LMST）[[7]]
    // 5. 真太阳时 = LMST + EoT
    return meanSolarTime.add(Duration(minutes: eotMinutes.toInt()));
  }

  static bool checkIsDST(DateTime datetime, String timezone) {
    final tzLocation = tz.getLocation(timezone);
    // 创建时区时间对象
    final tz.TZDateTime tzDatetime = tz.TZDateTime.from(datetime, tzLocation);
    return tzLocation.timeZone(tzDatetime.millisecondsSinceEpoch).isDst;
  }

  static int calculateTimeZoneLatitude(tz.TZDateTime tzDate){
    // tz.TZDateTime tzDate = tz.TZDateTime.now(tz.getLocation("Asia/Shanghai"));
    // print(tzDate.timeZoneOffset);
    // print(tzDate2.timeZoneOffset);
    int inHours = tzDate.timeZoneOffset.inHours;
    if (tzDate.timeZone.isDst){
      if (inHours > 0){
        inHours += 1;
      }else{
        inHours -= 1;
      }
    }
    return  15 * inHours;
  }
}



