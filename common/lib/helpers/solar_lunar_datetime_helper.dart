import 'package:common/data/seventy_two_phenology.dart';
import 'package:common/datamodel/basic_person_info.dart' as my;
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/helpers/solar_time_calculator.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/models/jie_qi_info.dart';
import 'package:common/models/query_datetime.dart';
import 'package:intl/intl.dart';
import 'package:lunar/lunar.dart';
import 'package:sweph/sweph.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
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
  static Tuple5<EightChars, String, String,Phenology,JieQiInfo> getEighthChars(DateTime time) {
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
    if (lunar.getCurrentJieQi()==null){
      jieQi = lunar.getPrevJieQi().getName();
      jieQiDateTime = dateFormat.parse(lunar.getPrevJieQi().getSolar().toYmdHms());
      jieQiEndAt = dateFormat.parse(lunar.getNextJieQi().getSolar().toYmdHms());
    }else{
      jieQi = lunar.getCurrentJieQi()!.getName();
      jieQiDateTime = dateFormat.parse(lunar.getCurrentJieQi()!.getSolar().toYmdHms());
      // 如果当天是节气，getNextJieQi() 还是当前这个，所以需要加2天时间再取
      jieQiEndAt = dateFormat.parse(lunar.getCurrentJieQi()!.getSolar().next(2).getLunar().getNextJieQi().getSolar().toYmdHms());
    }

    // print("${jieQi} ${jieQiDateTime} - ${jieQiEndAt} ${lunar.getPrevJieQi()} ${lunar.getCurrentJieQi()==null}");
    // print("节气时间：${jieQiDateTime}");

    return Tuple5(
        EightChars(
            year: JiaZi.getFromGanZhiValue(eightCharsStr[0])!,
            month: JiaZi.getFromGanZhiValue(eightCharsStr[1])!,
            day: JiaZi.getFromGanZhiValue(eightCharsStr[2])!,
            time: JiaZi.getFromGanZhiValue(eightCharsStr[3])!),
        lunar.getMonthInChinese(),
        lunar.getDayInChinese(),
        wuHou,
      JieQiInfo(
        jieQi: TwentyFourJieQi.fromName(jieQi),
        startAt: jieQiDateTime,
        endAt: jieQiEndAt,
      )
    );
  }
  static QueryDatetimeModel calculateNormalQueryDateTimeInfo(
      String queryUuid,
      DateTime dateTime,
      String timezoneStr,
      bool isDST,
      ){

    Tuple5<EightChars, String, String, Phenology,JieQiInfo> eightChars = getEighthChars(dateTime);
    return QueryDatetimeModel.standard(
      uuid: Uuid().v4(),
      queryUuid: queryUuid,
      createdAt: DateTime.now(),
        datetime: dateTime,
        timezoneStr: timezoneStr,
        bazi: eightChars.item1,
        lunarMonth: eightChars.item2,
        lunarDay: eightChars.item3,
        jieQiInfo: eightChars.item5,
      isDst:isDST,

    );
  }
  // @params : dateTime 需要时校正后的时间
  static QueryDatetimeModel calculateRemoveDSTQueryDateTimeInfo(
      String queryUuid,
      DateTime dateTime,String timezoneStr,int hourAdjusted){
    Tuple5<EightChars, String, String, Phenology,JieQiInfo> eightChars = getEighthChars(dateTime);
    return QueryDatetimeModel.removeDST(
        uuid: Uuid().v4(),
        queryUuid: queryUuid,
        createdAt: DateTime.now(),
      hourAdjusted: hourAdjusted,
        datetime: dateTime,
        timezoneStr: timezoneStr,
        bazi: eightChars.item1,
        lunarMonth: eightChars.item2,
        lunarDay: eightChars.item3,
        jieQiInfo: eightChars.item5
    );
  }


  static QueryDatetimeModel calculateMeanSolarQueryDateTimeInfo(
      String queryUuid,
      tz.TZDateTime tzDateTime,my.Location location){
    // 1. 获取这个时间，时区归属的经纬度
    final tzMeanDateTime = calculateMeanSolarTZDateTime(tzDateTime, location.coordinates.longitude);
    // print("tzMeanDateTime: $tzMeanDateTime");
    final meanDateTime = tzMeanDateTime.toDateTime();
    // print("meanDateTime: $meanDateTime");
    Tuple5<EightChars, String, String,Phenology,JieQiInfo> eightChars = getEighthChars(meanDateTime);

    return QueryDatetimeModel.meanSolar(
        uuid: Uuid().v4(),
        queryUuid: queryUuid,
        createdAt: DateTime.now(),
        datetime: meanDateTime,
        timezoneStr: tzDateTime.timeZoneName,
        bazi: eightChars.item1,
        lunarMonth: eightChars.item2,
        lunarDay: eightChars.item3,
      location: location,
        jieQiInfo: eightChars.item5
    );
  }

  /// 方法将会自动处理夏令时，即，将时间调整到夏令时前的时间
  static tz.TZDateTime calculateMeanSolarTZDateTime(tz.TZDateTime tzDatetime,double longtitude) {
    if (tzDatetime.timeZone.isDst){
      tzDatetime = tzDatetime.subtract(Duration(hours: 1));
    }
    final dateTime = tzDatetime.toUtc().toDateTime();
    print("calculate ${dateTime}");
    final longitudeHour = longtitude / 15.0;
    // print("longtitude: $longtitude, hour: $longitudeHour, " );
    // print("new ${dateTime.add(Duration(minutes: (longitudeHour * 60).toInt()))}");
    // tz.timeZoneDatabase.locations.keys.map((tzn)=>print(tzn));
    // print(tz.timeZoneDatabase.locations.keys);
    return tz.TZDateTime.from(
        dateTime.add(Duration(minutes: (longitudeHour * 60).toInt())),
        tzDatetime.location);
  }

  DateTime calculateMeanSolarTime(tz.TZDateTime datetime,double longitude) {
    final utcNow = DateTime.now().toUtc();
    // 计算经度时间偏移（东经为正，西经为负）
    final hoursOffset = longitude / 15;
    final totalSeconds = (hoursOffset * 3600).round();
    return utcNow.add(Duration(seconds: totalSeconds));
  }
  static QueryDatetimeModel calculateTrueSolarQueryDateTimeInfo(String queryUuid,DateTime meanDateTime,String timezoneStr,my.Coordinates coordinates){
    DateTime trueSolarTime = calculateTrueSolarTimeByMeanSolarTime(meanDateTime,coordinates.longitude);
    Tuple5<EightChars, String, String,Phenology,JieQiInfo> eightChars = getEighthChars(trueSolarTime);
    return QueryDatetimeModel.trueSolar(
        uuid: Uuid().v4(),
        queryUuid: queryUuid,
        createdAt: DateTime.now(),
      datetime: trueSolarTime,
      timezoneStr: timezoneStr,
      bazi: eightChars.item1,
      lunarMonth: eightChars.item2,
      lunarDay: eightChars.item3,
      coordinates: coordinates,
        jieQiInfo: eightChars.item5
    );
  }

  static DateTime calculateTrueSolarTimeByMeanSolarTime(DateTime meanSolarTime,double longitude){
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
  DateTime toDateTime() {
    final df =  DateFormat("yyyy-MM-dd HH:mm:ss");
    print("tzDateTime ${df.format(this)}");
    print("${year}-${month}-${day} ${hour}:${minute}:${second}");
    return df.parse(df.format(this));
  }
}