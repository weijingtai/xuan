import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/models/jie_qi_info.dart';
import 'package:timezone/timezone.dart' as tz;

import 'datamodel/geo_location.dart';
import 'datamodel/location.dart';
import 'features/datetime_details/calculation_strategy_config.dart';
import 'features/datetime_details/input_info_params.dart';
import 'helpers/solar_lunar_datetime_helper.dart';
import 'models/chinese_date_info.dart';
import 'models/seventy_two_phenology.dart';

class DevConstant {
  static CalculationStrategyConfig get devCalculationStrategyConfig =>
      CalculationStrategyConfig.defaultConfig;
  static DateTimeDetailsBundle get dev_usa {
    DateTime standardDatetime = DateTime(2025, 9, 6, 16, 24);
    String timezone = 'America/Los_Angeles';
    tz.TZDateTime tzDateTime =
        tz.TZDateTime.from(standardDatetime, tz.getLocation(timezone));
    // ChineseDateInfo chineseDateInfo =
    //     SolarLunarDateTimeHelper.cacluateChineseDateInfo(
    //         standardDatetime, devCalculationStrategyConfig.ziStrategy);
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

    // var meanSolarDateTimeInfo =
    //     SolarLunarDateTimeHelper.calculateMeanSolarQueryDateTimeInfo(
    //         "_tmp", tzDateTime, usa_address, false);
    var coordinates = Coordinates(
      latitude: 38.80260970,
      longitude: -116.41938900,
    );

    DateTime meanSolarDatetime = DateTime(2025, 9, 6, 15, 43, 26);
    DateTime trueSolarDatetime = DateTime(2025, 9, 6, 15, 45);
    // var trueTime = SolarLunarDateTimeHelper.calculateTrueSolarQueryDateTimeInfo(
    //     "_tmp", standardDatetime, timezone, coordinates, false);
    final chineseInfo = ChineseDateInfo(
      eightChars: EightChars(
          year: JiaZi.YI_SI,
          month: JiaZi.JIA_SHEN,
          day: JiaZi.WU_YIN,
          time: JiaZi.GENG_SHEN),
      phenology: Phenology.phenologyList.where((t) => t.order == 51).first,
      lunarMonth: 7,
      lunarDay: 15,
      isLeapMonth: false,
      jieQiInfo: JieQiInfo(
          jieQi: TwentyFourJieQi.CHU_SHU,
          startAt: DateTime(2025, 8, 23, 23, 00, 00),
          endAt: DateTime(2025, 9, 6, 22, 59, 59)),
      threeYuan: YuanYunOrder.lower,
      nineYun: NineYun.ninth,
    );
    return DateTimeDetailsBundle(
      calculationConfig: CalculationStrategyConfig.defaultConfig,
      standeredDatetime: standardDatetime,
      standeredChineseInfo: chineseInfo,
      utcDatetime: standardDatetime.toUtc(),
      timezoneStr: timezone,
      isDST: tzDateTime.timeZone.isDst,
      removeDSTDatetime: removeDSTDatetime,
      removeDSTChineseInfo: chineseInfo,
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
      meanSolarDatetime: meanSolarDatetime,
      meanSolarChineseInfo: chineseInfo,
      coordinates: coordinates,
      trueSolarDatetime: trueSolarDatetime,
      trueSolarChineseInfo: chineseInfo,
    );
  }
}
