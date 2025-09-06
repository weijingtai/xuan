import 'package:timezone/timezone.dart' as tz;

import 'datamodel/geo_location.dart';
import 'datamodel/location.dart';
import 'features/datetime_details/calculation_strategy_config.dart';
import 'features/datetime_details/input_info_params.dart';
import 'helpers/solar_lunar_datetime_helper.dart';
import 'models/chinese_date_info.dart';

class DevConstant {
  static CalculationStrategyConfig get devCalculationStrategyConfig =>
      CalculationStrategyConfig.defaultConfig;
  static DateTimeDetailsBundle get dev_usa {
    DateTime standardDatetime = DateTime(2025, 9, 6, 16, 24);
    String timezone = 'America/Los_Angles';
    tz.TZDateTime tzDateTime =
        tz.TZDateTime.from(standardDatetime, tz.getLocation(timezone));
    ChineseDateInfo chineseDateInfo =
        SolarLunarDateTimeHelper.cacluateChineseDateInfo(
            standardDatetime, devCalculationStrategyConfig.ziStrategy);
    DateTime removeDSTDatetime = DateTime(
      standardDatetime.year,
      standardDatetime.month,
      standardDatetime.day,
      standardDatetime.hour,
      standardDatetime.minute,
      standardDatetime.second,
      standardDatetime.millisecond,
      standardDatetime.microsecond,
    );
    if (tzDateTime.timeZone.isDst) {
      removeDSTDatetime = removeDSTDatetime.subtract(Duration(hours: 1));
    }
    var usa_address = Address(
        countryName: "USA",
        countryId: 233,
        regionId: 1458,
        province: GeoLocation(
          code: "1458",
          parentCode: "233",
          level: GeoLevel.province,
          name: "Nevada",
          latitude: 38.80260970,
          longitude: -116.41938900,
        ),
        timezone: timezone);

    var meanSolarDateTimeInfo =
        SolarLunarDateTimeHelper.calculateMeanSolarQueryDateTimeInfo(
            "_tmp", tzDateTime, usa_address, false);
    var coordinates = Coordinates(
      latitude: 38.80260970,
      longitude: -116.41938900,
    );
    var trueTime = SolarLunarDateTimeHelper.calculateTrueSolarQueryDateTimeInfo(
        "_tmp", standardDatetime, timezone, coordinates, false);

    return DateTimeDetailsBundle(
      calculationConfig: CalculationStrategyConfig.defaultConfig,
      standeredDatetime: standardDatetime,
      standeredChineseInfo: chineseDateInfo,
      utcDatetime: standardDatetime.toUtc(),
      timezoneStr: timezone,
      isDST: tzDateTime.timeZone.isDst,
      removeDSTDatetime: removeDSTDatetime,
      removeDSTChineseInfo: SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          tzDateTime, devCalculationStrategyConfig.ziStrategy),
      location: Location(
          address: Address(
              countryName: "USA",
              countryId: 233,
              regionId: 1458,
              province: GeoLocation(
                code: "1458",
                parentCode: "233",
                level: GeoLevel.province,
                name: "Nevada",
                latitude: 38.80260970,
                longitude: -116.41938900,
              ),
              timezone: timezone)),
      meanSolarDatetime: meanSolarDateTimeInfo.datetime,
      meanSolarChineseInfo: SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          meanSolarDateTimeInfo.datetime,
          devCalculationStrategyConfig.ziStrategy),
      coordinates: coordinates,
      trueSolarDatetime: trueTime.datetime,
      trueSolarChineseInfo: SolarLunarDateTimeHelper.cacluateChineseDateInfo(
          trueTime.datetime, devCalculationStrategyConfig.ziStrategy),
    );
  }
}
