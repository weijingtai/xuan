import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tuple/tuple.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/seventy_two_phenology.dart';
import '../helpers/solar_time_calculator.dart';
import 'eight_chars.dart';

part 'query_datetime.g.dart';

// 1. UTC（协调世界时）
// 定义 ：UTC 是全球统一的时间标准，基于原子钟与地球自转的协调，用于国际通信、航空等领域。
// 特点 ：
// 不受任何国家/地区夏令时（DST）影响，是绝对时间参考。
// 例如：2025-03-12T00:00:00Z 表示 UTC 时间的标准化写法（ISO 8601 格式）。
// 2. DST（夏令时/日光节约时）
// 定义 ：在夏季人为将时间调快 1 小时，以充分利用日光资源。
// 规则 ：
// 开始与结束时间因地而异（如美国与欧盟的 DST 切换日期不同）。
// 非强制性：部分国家/地区已取消 DST（如中国自 1992 年起不再使用）。
// 技术实现 ：通过时区数据库（如 IANA）标记 std（标准时间）和 dst（夏令时）字段。
// 3. Asia/Shanghai 时区格式
// 类型 ：属于 IANA 时区数据库 的命名格式，以“区域/地点”形式标识时区。
// 特点 ：
// 兼容历史 DST 规则 ：自动适配该地区历史上的夏令时调整（如中国在 1986-1991 年曾实施 DST）。
// 固定 UTC 偏移 ：当前中国标准时间（CST）为 UTC+8，无夏令时，但 Asia/Shanghai 仍保留历史 DST 数据。
// 对比其他格式 ：
// UTC 偏移格式 （如 UTC+08:00）：仅表示固定时差，无法处理 DST 动态调整。
// 地区命名格式 （如 Asia/Shanghai）：动态适配 DST 和历史时区变化，推荐用于跨平台开发。

enum EnumDatetimeType {
  @JsonValue("阳历")
  standard("标准时间"),
  @JsonValue("iana")
  IANA("当地时间"),
  @JsonValue("平太阳时")
  meanSolar("平太阳时"),
  @JsonValue("真太阳时")
  trueSolar("真太阳时");

  final String name;
  const EnumDatetimeType(this.name);
}

@JsonSerializable()
class QueryDateTime {
  final EnumDatetimeType type;

  final DateTime datetime;
  final EightChars bazi;
  QueryDateTime(
      {required this.type, required this.datetime, required this.bazi});

  factory QueryDateTime.fromJson(Map<String, dynamic> json) =>
      _$QueryDateTimeFromJson(json);

  Map<String, dynamic> toJson() => _$QueryDateTimeToJson(this);
}

@JsonSerializable()
class NormalQueryDateTime extends QueryDateTime {
  NormalQueryDateTime({
    required DateTime datetime,
    required EightChars bazi,
  }) : super(datetime: datetime, bazi: bazi, type: EnumDatetimeType.standard);
  factory NormalQueryDateTime.fromJson(Map<String, dynamic> json) =>
      _$NormalQueryDateTimeFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NormalQueryDateTimeToJson(this);
}

@JsonSerializable()
class TZNormalQueryDateTime extends QueryDateTime {
  late final String timezoneName;
  tz.TZDateTime get tzDateTime =>
      tz.TZDateTime.from(datetime, tz.getLocation(timezoneName));

  // final String
  TZNormalQueryDateTime({
    required this.timezoneName,
    required DateTime datetime,
    required EightChars bazi,
  }) : super(datetime: datetime, bazi: bazi, type: EnumDatetimeType.IANA) {
    // timezoneLocation = tz.getLocation(timezoneName);
  }

  factory TZNormalQueryDateTime.fromJson(Map<String, dynamic> json) =>
      _$TZNormalQueryDateTimeFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TZNormalQueryDateTimeToJson(this);
}

@JsonSerializable()
class MeanSolarQueryDateTime extends QueryDateTime {
  late final Location location;
  Coordinates get coordinates => location.coordinates;

  MeanSolarQueryDateTime({
    required this.location,
    required DateTime datetime,
    required EightChars bazi,
  }) : super(datetime: datetime, bazi: bazi, type: EnumDatetimeType.meanSolar);

  factory MeanSolarQueryDateTime.fromJson(Map<String, dynamic> json) =>
      _$MeanSolarQueryDateTimeFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MeanSolarQueryDateTimeToJson(this);
}

@JsonSerializable()
class TrueSolarQueryDateTime extends QueryDateTime {
  final Coordinates coordinates;
  TrueSolarQueryDateTime({
    required this.coordinates,
    required DateTime datetime,
    required EightChars bazi,
  }) : super(datetime: datetime, bazi: bazi, type: EnumDatetimeType.trueSolar);
  factory TrueSolarQueryDateTime.fromJson(Map<String, dynamic> json) =>
      _$TrueSolarQueryDateTimeFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TrueSolarQueryDateTimeToJson(this);
}

// class QueryDatetime {
//   // 1. 普通时间，需要明确时区，使用UTC自动处理夏令时问题，如：中国1986-1991
//   // 1.1. 明确的时区字段
//   final DateTime datetime;
//   final String timezone;

//   // 2. 农历日期，普通时间进行的转换，如：`甲子年 二月廿三`
//   final int traditionalMonth;
//   final int traditionalDay;

//   String get traditionalYear => bazi.year.ganZhiStr;
//   String get traditionalTime => bazi.hour.diZhi.value;

//   // 3. 八字
//   final EightChars bazi;

//   // 平太阳时
//   // 平太阳时=标准时间+4×(当地经度−120°）分钟
//   final DateTime meanSolar;
//   final EightChars meanSolarBaZi;

//   // 观测点经纬度

//   // 真太阳时
//   final DateTime trueSolar;
//   final EightChars trueSolarBaZi;

//   QueryDatetime({
//     required this.datetime,
//     required this.timezone,
//     required this.traditionalMonth,
//     required this.traditionalDay,
//     required this.bazi,
//     required this.meanSolar,
//     required this.meanSolarBaZi,
//     required this.trueSolar,
//     required this.trueSolarBaZi,
//   });
// }

// class QueryDatetimeFactory {
//   static QueryDatetime createByDateTime(
//       DateTime datetime, String timezone, Coordinates coordinates) {
//     Tuple4<EightChars, int, int, Phenology> tuple4 =
//         SolarLunarDateTimeHelper.getEighthChars(datetime);

//     EightChars eightChars = tuple4.item1;
//     int traditionalMonth = tuple4.item2;
//     int traditionalDay = tuple4.item3;
//     Phenology phenology = tuple4.item4;
//     SolarTimeCalculator solarTimeCalculator = SolarTimeCalculator(
//       dateTime: datetime,
//       longitude: coordinates.longitude,
//     );

//     DateTime meanSolar = solarTimeCalculator.meanSolarTime;
//     EightChars meanSolarEightChars =
//         SolarLunarDateTimeHelper.getEighthChars(meanSolar).item1;
//     DateTime trueSolar = solarTimeCalculator.getTrueSolarTime();
//     EightChars trueSolarEightChars =
//         SolarLunarDateTimeHelper.getEighthChars(trueSolar).item1;

//     return QueryDatetime(
//         datetime: datetime,
//         timezone: timezone,
//         traditionalMonth: traditionalMonth,
//         traditionalDay: traditionalDay,
//         bazi: eightChars,
//         meanSolar: meanSolar,
//         meanSolarBaZi: meanSolarEightChars,
//         trueSolar: trueSolar,
//         trueSolarBaZi: trueSolarEightChars);
//     // return QueryDatetime(
//     //   datetime: datetime,
//     //   timezone: timezone,
//     // );
//   }
// }
