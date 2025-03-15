import 'package:common/data/seventy_two_phenology.dart';
import 'package:common/datamodel/basic_person_info.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/models/eight_chars.dart';
import 'package:intl/intl.dart';
import 'package:lunar/lunar.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tuple/tuple.dart';

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
  static Tuple4<EightChars, int, int, Phenology> getEighthChars(DateTime time) {
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

    return Tuple4(
        EightChars(
            year: JiaZi.getFromGanZhiValue(eightCharsStr[0])!,
            month: JiaZi.getFromGanZhiValue(eightCharsStr[1])!,
            day: JiaZi.getFromGanZhiValue(eightCharsStr[2])!,
            time: JiaZi.getFromGanZhiValue(eightCharsStr[3])!),
        lunar.getMonth(),
        lunar.getDay(),
        wuHou);
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

  static List<TZDateTime> eightChars2TZDateTime(
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

  static TZDateTime solarToTZDateTime(Solar solar, String utcTimezone) {
    // print(datetimeStr);
    // 根据 YYYY-MM-dd HH:mm.ss
    DateTime datetime = dateFormat.parse(solar.toYmdHms());
    return tz.TZDateTime.from(datetime, tz.getLocation(utcTimezone));
    // return datetime;
  }
}
