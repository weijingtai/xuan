import 'dart:math';

import 'package:sweph/sweph.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:qizhengsiyu/domain/entities/models/observer_position.dart';
import 'package:qizhengsiyu/domain/entities/models/stars_angle.dart';

class AstroService {
  StarsAngle calculateAllStarsAngleOnZodiac(
      BaseObserverPosition observerPosition, DateTime datetime) {
    double roundHelper(double number) {
      // 保留小数点后两位，四舍五入
      num factor = pow(10, 2);
      return ((number * factor).round() / factor);
    }

    double ziQi() {
      // # moria 软件中
      // # 2013-04-09 02:57 am 紫炁在戌0°
      // # 2013-04-10 02:57 am 紫炁在戌0°02′07″处
      // # 每24小时运行 02′07″ 或 0.0352° 度 28年运行一周，一年以365.2422天为准
      // # 紫炁的运行规律为 一日行三分五十七秒，一宫住二十八个月，二十八年行一周天，一日行3分57秒（百进制）

      // TODO:  replace timeZone from Fixed to TimeZone
      tz.TZDateTime baseShangHaiTime =
          tz.TZDateTime(tz.getLocation('Asia/Shanghai'), 2013, 4, 9, 2, 58);
      // BASE_SHANG_HAI_TIME.toUtc();

      const angleForEachMinutes = 0.0352 / (24 * 60);
      // final localTime = tz.TZDateTime(
      //     tz.getLocation(observerPosition.timezone),
      //     datetime.year,
      //     datetime.month,
      //     datetime.day,
      //     datetime.hour,
      //     datetime.minute);
      // final targetTime = tz.TZDateTime.from(localTime, tz.getLocation('Asia/Shanghai'));
      //
      // if (targetTime.isAtSameMomentAs(BASE_SHANG_HAI_TIME)){
      //   return 0;
      // }
      //
      // var diffInMinutes = targetTime.isBefore(BASE_SHANG_HAI_TIME)
      //     ? BASE_SHANG_HAI_TIME.difference(targetTime)
      //     : targetTime.difference(BASE_SHANG_HAI_TIME);
      if (datetime.isAtSameMomentAs(baseShangHaiTime)) {
        return 0;
      }

      var diffInMinutes = datetime.isBefore(baseShangHaiTime)
          ? baseShangHaiTime.difference(datetime)
          : datetime.difference(baseShangHaiTime);

      // minutes_difference = delta.total_seconds() // 60
      double result = diffInMinutes.inMinutes * angleForEachMinutes;
      if (result >= 360) {
        result -= 360;
      }

      return result;
    }

    // 设置观察者的位置
    Sweph.swe_set_topo(observerPosition.longitude, observerPosition.latitude,
        observerPosition.altitude);
    DateTime utcTime = datetime;

    final double julianDay = Sweph.swe_julday(
        utcTime.year,
        utcTime.month,
        utcTime.day,
        utcTime.hour + utcTime.minute / 60,
        CalendarType.SE_GREG_CAL);

    var lunar =
        Sweph.swe_calc(julianDay, HeavenlyBody.SE_MOON, SwephFlag.SEFLG_SWIEPH);
    var sun =
        Sweph.swe_calc(julianDay, HeavenlyBody.SE_SUN, SwephFlag.SEFLG_SWIEPH);

    var Venus = Sweph.swe_calc(julianDay, HeavenlyBody.SE_VENUS,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
    var Jupiter = Sweph.swe_calc(julianDay, HeavenlyBody.SE_JUPITER,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
    var water = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MERCURY,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
    var Mars = Sweph.swe_calc(julianDay, HeavenlyBody.SE_MARS,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);
    var Saturn = Sweph.swe_calc(julianDay, HeavenlyBody.SE_SATURN,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED);

    // 计算北交点的黄道角度
    var northNode = Sweph.swe_calc(
        julianDay, HeavenlyBody.SE_MEAN_NODE, SwephFlag.SEFLG_SWIEPH);
    double northNodeAngle = northNode.longitude;
    // 计算南交点的黄道角度
    double southNodeAngle = (northNodeAngle + 180) % 360;
    var lilith = Sweph.swe_calc(
        julianDay, HeavenlyBody.SE_MEAN_APOG, SwephFlag.SEFLG_SWIEPH);

    return StarsAngle(
        moon: roundHelper(lunar.longitude),
        sun: roundHelper(sun.longitude),
        venus: roundHelper(Venus.longitude),
        venusSpeed: roundHelper(Venus.speedInLongitude),
        jupiter: roundHelper(Jupiter.longitude),
        jupiterSpeed: roundHelper(Jupiter.speedInLongitude),
        water: roundHelper(water.longitude),
        waterSpeed: roundHelper(water.speedInLongitude),
        mars: roundHelper(Mars.longitude),
        marsSpeed: roundHelper(Mars.speedInLongitude),
        saturn: roundHelper(Saturn.longitude),
        saturnSpeed: roundHelper(Saturn.speedInLongitude),
        northNode: roundHelper(northNodeAngle),
        southNode: roundHelper(southNodeAngle),
        lilith: roundHelper(lilith.longitude),
        qi: roundHelper(ziQi()));
  }
}
