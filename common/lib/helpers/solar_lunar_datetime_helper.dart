import 'package:common/datamodel/basic_person_info.dart' as my;
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/helpers/solar_time_calculator.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/models/jie_qi_info.dart';
import 'package:common/models/divination_datetime.dart';
import 'package:common/models/seventy_two_phenology.dart';
import 'package:intl/intl.dart';
import 'package:lunar/lunar.dart';
import 'package:sweph/sweph.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import '../datamodel/location.dart' as my;
import '../enums/enum_twenty_four_jie_qi.dart';

class SolarLunarDateTimeHelper {
  static DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  bool checkIsSummerTime(DateTime datetime, String timezone) {
    final tzLocation = tz.getLocation(timezone);
    // 创建时区时间对象（2023-07-01 12:00）
    final tzDatetime = tz.TZDateTime.from(datetime, tzLocation);
    // tzDatetime.timeZone.
    final offset = tzDatetime.timeZoneOffset;
    final standardOffset = tzLocation.currentTimeZone.offset;
    final isDST = offset != standardOffset;
    return isDST;
  }

  // item1 八字
  // item2 月份
  // item3 日期
  static Tuple4<EightChars, Lunar, Phenology, JieQiInfo> getEighthChars(
      DateTime time) {
    /// 当时间为23点时 算作第二天的子时

    var lunar = Lunar.fromDate(time);
    if (time.hour == 23) {
      // copy this time
      DateTime time0 = DateTime.parse(dateFormat.format(time));
      DateTime newTime = time0.add(const Duration(hours: 1));
      lunar = Lunar.fromDate(newTime);
    }
    List<String> eightCharsStr = lunar.getBaZi();

    int wuHouIndex = WU_HOU.indexOf(lunar.getWuHou());
    Phenology wuHou = Phenology.phenologyList[wuHouIndex];
    String jieQi;
    DateTime jieQiDateTime;
    DateTime jieQiEndAt;
    // final DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    if (lunar.getCurrentJieQi() == null) {
      jieQi = lunar.getPrevJieQi().getName();
      jieQiDateTime =
          dateFormat.parse(lunar.getPrevJieQi().getSolar().toYmdHms());
      jieQiEndAt = dateFormat.parse(lunar.getNextJieQi().getSolar().toYmdHms());
    } else {
      jieQi = lunar.getCurrentJieQi()!.getName();
      jieQiDateTime =
          dateFormat.parse(lunar.getCurrentJieQi()!.getSolar().toYmdHms());
      // 如果当天是节气，getNextJieQi() 还是当前这个，所以需要加2天时间再取
      jieQiEndAt = dateFormat.parse(lunar
          .getCurrentJieQi()!
          .getSolar()
          .next(2)
          .getLunar()
          .getNextJieQi()
          .getSolar()
          .toYmdHms());
    }

    // print("${jieQi} ${jieQiDateTime} - ${jieQiEndAt} ${lunar.getPrevJieQi()} ${lunar.getCurrentJieQi()==null}");
    // print("节气时间：${jieQiDateTime}");

    return Tuple4(
        EightChars(
            year: JiaZi.getFromGanZhiValue(eightCharsStr[0])!,
            month: JiaZi.getFromGanZhiValue(eightCharsStr[1])!,
            day: JiaZi.getFromGanZhiValue(eightCharsStr[2])!,
            time: JiaZi.getFromGanZhiValue(eightCharsStr[3])!),
        lunar,
        wuHou,
        JieQiInfo(
          jieQi: TwentyFourJieQi.fromName(jieQi),
          startAt: jieQiDateTime,
          endAt: jieQiEndAt,
        ));
  }

  static DivinationDatetimeModel calculateNormalQueryDateTimeInfo(
      String queryUuid,
      DateTime dateTime,
      String timezoneStr,
      bool isDST,
      bool isSeersLocation) {
    Tuple4<EightChars, Lunar, Phenology, JieQiInfo> eightChars =
        getEighthChars(dateTime);

    final Lunar lunar = eightChars.item2;
    bool isLeapMonth =
        LunarMonth.fromYm(lunar.getYear(), lunar.getMonth())!.isLeap();
    final result = DivinationDatetimeModel.standard(
      uuid: Uuid().v4(),
      queryUuid: queryUuid,
      datetime: dateTime,
      timezoneStr: timezoneStr,
      bazi: eightChars.item1,
      lunarMonth: monthMap[eightChars.item2.getMonthInChinese()]!,
      lunarDay: dayMap[eightChars.item2.getDayInChinese()]!,
      isLeapMonth: isLeapMonth,
      isSeersLocation: isSeersLocation,
      jieQiInfo: eightChars.item4,
      isDst: isDST,
    );

    print(result.toJson());
    return result;
  }

  // @params : dateTime 需要时校正后的时间
  static DivinationDatetimeModel calculateRemoveDSTQueryDateTimeInfo(
      String queryUuid,
      DateTime dateTime,
      String timezoneStr,
      int hourAdjusted,
      bool isSeersLocation) {
    Tuple4<EightChars, Lunar, Phenology, JieQiInfo> eightChars =
        getEighthChars(dateTime);
    final Lunar lunar = eightChars.item2;
    bool isLeapMonth =
        LunarMonth.fromYm(lunar.getYear(), lunar.getMonth())!.isLeap();
    return DivinationDatetimeModel.removeDST(
        uuid: Uuid().v4(),
        queryUuid: queryUuid,
        hourAdjusted: hourAdjusted,
        datetime: dateTime,
        timezoneStr: timezoneStr,
        bazi: eightChars.item1,
        lunarMonth: monthMap[eightChars.item2.getMonthInChinese()]!,
        lunarDay: dayMap[eightChars.item2.getDayInChinese()]!,
        isLeapMonth: isLeapMonth,
        isSeersLocation: isSeersLocation,
        jieQiInfo: eightChars.item4);
  }

  static DivinationDatetimeModel calculateMeanSolarQueryDateTimeInfo(
      String queryUuid,
      tz.TZDateTime tzDateTime,
      my.Address address,
      bool isSeersLocation) {
    // 1. 获取这个时间，时区归属的经纬度
    final tzMeanDateTime =
        calculateMeanSolarTZDateTime(tzDateTime, address.coordinates.longitude);
    // print("tzMeanDateTime: $tzMeanDateTime");
    final meanDateTime = tzMeanDateTime.toDateTime();
    // print("meanDateTime: $meanDateTime");
    Tuple4<EightChars, Lunar, Phenology, JieQiInfo> eightChars =
        getEighthChars(meanDateTime);
    final Lunar lunar = eightChars.item2;
    bool isLeapMonth =
        LunarMonth.fromYm(lunar.getYear(), lunar.getMonth())!.isLeap();

    return DivinationDatetimeModel.meanSolar(
        uuid: Uuid().v4(),
        queryUuid: queryUuid,
        datetime: meanDateTime,
        timezoneStr: tzDateTime.timeZoneName,
        bazi: eightChars.item1,
        lunarMonth: monthMap[eightChars.item2.getMonthInChinese()]!,
        lunarDay: dayMap[eightChars.item2.getDayInChinese()]!,
        isLeapMonth: isLeapMonth,
        isSeersLocation: isSeersLocation,
        address: address,
        jieQiInfo: eightChars.item4);
  }

  /// 方法将会自动处理夏令时，即，将时间调整到夏令时前的时间
  static tz.TZDateTime calculateMeanSolarTZDateTime(
      tz.TZDateTime tzDatetime, double longtitude) {
    if (tzDatetime.timeZone.isDst) {
      tzDatetime = tzDatetime.subtract(Duration(hours: 1));
    }
    final dateTime = tzDatetime.toUtc().toDateTime();
    final longitudeHour = longtitude / 15.0;
    // print("longtitude: $longtitude, hour: $longitudeHour, " );
    // print("new ${dateTime.add(Duration(minutes: (longitudeHour * 60).toInt()))}");
    // tz.timeZoneDatabase.locations.keys.map((tzn)=>print(tzn));
    // print(tz.timeZoneDatabase.locations.keys);
    return tz.TZDateTime.from(
        dateTime.add(Duration(minutes: (longitudeHour * 60).toInt())),
        tzDatetime.location);
  }

  DateTime calculateMeanSolarTime(tz.TZDateTime datetime, double longitude) {
    final utcNow = DateTime.now().toUtc();
    // 计算经度时间偏移（东经为正，西经为负）
    final hoursOffset = longitude / 15;
    final totalSeconds = (hoursOffset * 3600).round();
    return utcNow.add(Duration(seconds: totalSeconds));
  }

  static DivinationDatetimeModel calculateTrueSolarQueryDateTimeInfo(
      String queryUuid,
      DateTime meanDateTime,
      String timezoneStr,
      my.Coordinates coordinates,
      bool isSeersLocation) {
    DateTime trueSolarTime = calculateTrueSolarTimeByMeanSolarTime(
        meanDateTime, coordinates.longitude);
    Tuple4<EightChars, Lunar, Phenology, JieQiInfo> eightChars =
        getEighthChars(trueSolarTime);
    final Lunar lunar = eightChars.item2;
    bool isLeapMonth =
        LunarMonth.fromYm(lunar.getYear(), lunar.getMonth())!.isLeap();
    return DivinationDatetimeModel.trueSolar(
        uuid: Uuid().v4(),
        queryUuid: queryUuid,
        datetime: trueSolarTime,
        timezoneStr: timezoneStr,
        bazi: eightChars.item1,
        lunarMonth: monthMap[eightChars.item2.getMonthInChinese()]!,
        lunarDay: dayMap[eightChars.item2.getDayInChinese()]!,
        isLeapMonth: isLeapMonth,
        isSeersLocation: isSeersLocation,
        coordinates: coordinates,
        jieQiInfo: eightChars.item4);
  }

  static DateTime calculateTrueSolarTimeByMeanSolarTime(
      DateTime meanSolarTime, double longitude) {
    // 返回结果“1”为TT时间（地球时间），“2”为UT1(世界时间)的儒略历
    final List<double> jdResult = Sweph.swe_utc_to_jd(
        meanSolarTime.year,
        meanSolarTime.month,
        meanSolarTime.day,
        meanSolarTime.hour,
        meanSolarTime.minute,
        meanSolarTime.second.toDouble(),
        CalendarType.SE_GREG_CAL);

    // TT 时间用于天体计算，UT时间用于修正本地,
    // 计算真太阳时使用 UT
    final double jd = jdResult[1];
    final double eotMinutes = Sweph.swe_time_equ(jd);

    // 4. 计算地方平太阳时（LMST）[[7]]
    // 5. 真太阳时 = LMST + EoT
    return meanSolarTime.add(Duration(minutes: eotMinutes.toInt()));
  }

  static const List<String> WU_HOU = [
    '蚯蚓结',
    '麋角解',
    '水泉动',
    '雁北乡',
    '鹊始巢',
    '雉始雊',
    '鸡始乳',
    '征鸟厉疾',
    '水泽腹坚',
    '东风解冻',
    '蛰虫始振',
    '鱼陟负冰',
    '獭祭鱼',
    '候雁北',
    '草木萌动',
    '桃始华',
    '仓庚鸣',
    '鹰化为鸠',
    '玄鸟至',
    '雷乃发声',
    '始电',
    '桐始华',
    '田鼠化为鴽',
    '虹始见',
    '萍始生',
    '鸣鸠拂奇羽',
    '戴胜降于桑',
    '蝼蝈鸣',
    '蚯蚓出',
    '王瓜生',
    '苦菜秀',
    '靡草死',
    '麦秋至',
    '螳螂生',
    '鵙始鸣',
    '反舌无声',
    '鹿角解',
    '蜩始鸣',
    '半夏生',
    '温风至',
    '蟋蟀居壁',
    '鹰始挚',
    '腐草为萤',
    '土润溽暑',
    '大雨行时',
    '凉风至',
    '白露降',
    '寒蝉鸣',
    '鹰乃祭鸟',
    '天地始肃',
    '禾乃登',
    '鸿雁来',
    '玄鸟归',
    '群鸟养羞',
    '雷始收声',
    '蛰虫坯户',
    '水始涸',
    '鸿雁来宾',
    '雀入大水为蛤',
    '菊有黄花',
    '豺乃祭兽',
    '草木黄落',
    '蛰虫咸俯',
    '水始冰',
    '地始冻',
    '雉入大水为蜃',
    '虹藏不见',
    '天气上升地气下降',
    '闭塞而成冬',
    '鹖鴠不鸣',
    '虎始交',
    '荔挺出'
  ];

  static const intMonth2ChineseMap = {
    1: '正',
    2: '二',
    3: '三',
    4: '四',
    5: '五',
    6: '六',
    7: '七',
    8: '八',
    9: '九',
    10: '十',
    11: '十一',
    12: '腊',
  };
  static const intDay2ChineseMap = {
    1: '初一',
    2: '初二',
    3: '初三',
    4: '初四',
    5: '初五',
    6: '初六',
    7: '初七',
    8: '初八',
    9: '初九',
    10: '初十',
    11: '十一',
    12: '十二',
    13: '十三',
    14: '十四',
    15: '十五',
    16: '十六',
    17: '十七',
    18: '十八',
    19: '十九',
    20: '二十',
    21: '廿一',
    22: '廿二',
    23: '廿三',
    24: '廿四',
    25: '廿五',
    26: '廿六',
    27: '廿七',
    28: '廿八',
    29: '廿九',
    30: '三十',
    31: '卅一'
  };
  // 月份映射表：将中文月份转换为数字（1-12）
  static const monthMap = {
    '正月': 1,
    '一月': 1,
    '二月': 2,
    '三月': 3,
    '四月': 4,
    '五月': 5,
    '六月': 6,
    '七月': 7,
    '八月': 8,
    '九月': 9,
    '十月': 10,
    '十一月': 11,
    '十二月': 12,
    '一': 1,
    '二': 2,
    '三': 3,
    '四': 4,
    '五': 5,
    '六': 6,
    '七': 7,
    '八': 8,
    '九': 9,
    '十': 10,
    '十一': 11,
    '十二': 12,
    "腊月": 12,
  };
  static const dayMap = {
    '一': 1,
    '初一': 1,
    '二': 2,
    '初二': 2,
    '三': 3,
    '初三': 3,
    '四': 4,
    '初四': 4,
    '五': 5,
    '初五': 5,
    '六': 6,
    '初六': 6,
    '七': 7,
    '初七': 7,
    '八': 8,
    '初八': 8,
    '九': 9,
    '初九': 9,
    '十': 10,
    '初十': 10,
    '十一': 11,
    '十二': 12,
    '十三': 13,
    '十四': 14,
    '十五': 15,
    '十六': 16,
    '十七': 17,
    '十八': 18,
    '十九': 19,
    '二十': 20,
    '二十一': 21,
    '廿一': 21,
    '二十二': 22,
    '廿二': 22,
    '二十三': 23,
    '廿三': 23,
    '二十四': 24,
    '廿四': 24,
    '二十五': 25,
    '廿五': 25,
    '二十六': 26,
    '廿六': 26,
    '二十七': 27,
    '廿七': 27,
    '二十八': 28,
    '廿八': 28,
    '二十九': 29,
    '廿九': 29,
    '三十': 30,
    '三十一': 31,
    '卅一': 31,
  };

  static List<DateTime> eightChars2DateTime(EightChars eightChars) {
    List<Solar> solarList = Solar.fromBaZi(eightChars.year.name,
        eightChars.month.name, eightChars.day.name, eightChars.time.name);
    return solarList.map((e) => solarToDateTime(e)).toList();
  }

  static List<tz.TZDateTime> eightChars2TZDateTime(
      EightChars eightChars, String utcTimezone) {
    List<Solar> solarList = Solar.fromBaZi(eightChars.year.name,
        eightChars.month.name, eightChars.day.name, eightChars.time.name);
    return solarList.map((e) => solarToTZDateTime(e, utcTimezone)).toList();
  }

  static DateTime solarToDateTime(Solar solar) {
    String datetimeStr = solar.toYmdHms();
    // print(datetimeStr);
    // 根据 YYYY-MM-dd HH:mm.ss
    final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    DateTime datetime = dateFormat.parse(datetimeStr);
    return datetime;
  }

  static tz.TZDateTime solarToTZDateTime(Solar solar, String utcTimezone) {
    // print(datetimeStr);
    // 根据 YYYY-MM-dd HH:mm.ss
    DateTime datetime = dateFormat.parse(solar.toYmdHms());
    return tz.TZDateTime.from(datetime, tz.getLocation(utcTimezone));
    // return datetime;
  }
}

extension TZDateTimeExt on tz.TZDateTime {
  static final df = DateFormat("yyyy-MM-dd HH:mm:ss");
  DateTime toDateTime() {
    return df.parse(df.format(this));
  }
}
