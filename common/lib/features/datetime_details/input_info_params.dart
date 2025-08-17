import 'dart:core';

import 'package:common/datamodel/location.dart';
import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:lunar/lunar.dart';
import 'package:tuple/tuple.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../helpers/solar_lunar_datetime_helper.dart';
import '../../models/chinese_date_info.dart';
import '../../models/divination_datetime.dart';
import 'calculation_strategy_config.dart';
import 'processors/solar_time_processor.dart';

@JsonEnum()
enum ZiShiStrategy {
  @JsonValue('startFrom23')
  startFrom23, // 23:00 为子时开始，为次日

  @JsonValue('startFrom0')
  startFrom0, // 00:00 为子时，为次日

  @JsonValue('splitedZi')
  splitedZi, // 分早晚子时，早子时为23:00 - 00:00，晚子时为00:00 - 00:59。早子时使用当日日柱，晚子时使用次日日柱。
  // Lunar默认使用
}

@JsonEnum()
enum JieQiType {
  @JsonValue('leveling')
  leveling("平气法"), // 平气

  @JsonValue('stabilizing')
  stabilizing("定气法"); // 定气

  final String name;
  const JieQiType(this.name);
}

@JsonEnum()
enum JieQiStrategy {
  @JsonValue('day')
  day, // 节气的划分按照时间点所在的"日期"进行划分

  @JsonValue('hour')
  hour, // 节气的划分按照时间点所在的"时辰"进行划分

  @JsonValue('minute')
  minute, // 节气的划分按照时间点所在的"分秒"进行划分
}
// class YearHeader{
//   // 岁首
//   String name;
//   DateTime datetime;
//   String timezoneName;
//   DateTime utcDatetime;

// }
class DateTimeDetailsBundle {
  //
  // 当前类包含， 标准时间、UTC时间，时区，夏令时校正后时间，正太阳时，平太阳时，以及几个时间对应的中国日期信息

  // 子时策略
  final CalculationStrategyConfig calculationConfig;

  // 1. 标准出生时间(standard datetime)
  DateTime standeredDatetime;
  ChineseDateInfo standeredChineseInfo;

  // 2. utc 时间 --- 用于“国际版”的区分
  DateTime utcDatetime;
  // 时区名称 -- 用于“国际版”的区分，如“Asia/Shanghai”
  String timezoneStr;

  // 2. 根据timezone时区确定当时或者当地“国别”是否存在夏令时。如果存在夏令时则需要有校准后的时间
  //  如 1986-1991 出生在中国的人 （需要知道 timezone）
  bool? isDST;
  DateTime? removeDSTDatetime; // 输入时间移除夏令时后的时间 -- 只有isDST == true时才需要存在
  ChineseDateInfo? removeDSTChineseInfo; // 输入时间移除夏令时后的时间的中国日期信息

  // 当前经纬度，小数点地点误差对照：
  // 1 米：小数点后 5 位。
  // 10 米：小数点后 4 位。
  // 100 米：小数点后 3 位。
  // 1000 米：小数点后 2 位。

  // 3. 需要有平台太阳时（mean solar time） --- 出生地经纬度与使用的stranded time不同
  // 如出生在“重庆”，则需要有“重庆”的经纬度，才能计算出“重庆”的平太阳时，而标准时间为北京时间（“Asia/Shanghai”)
  //  mean solar time - 相差1°时间差4分钟，当前建议保留经度值小数点后3位
  Location? location; // 国内为市、县级，国外需要在省一级
  DateTime? meanSolarDatetime; // 平太阳时 - 需要提供小数点后3位的经度才有效
  ChineseDateInfo? meanSolarChineseInfo; // 平太阳时的中国日期信息

  // 4. 真太阳时（true  solar time） --- 通过给出经纬度与时间，使用当前科学天文计算，（地球公转为椭圆）等进行精准的科学计算
  // 保留当前建议保留经度值小数点3位
  Coordinates? coordinates; // 真太阳时的经纬度
  DateTime? trueSolarDatetime; // 真太阳时 - 需要提供小数点后5为的经纬度才存在价值
  ChineseDateInfo? trueSolarChineseInfo; // 真太阳时的中国日期信息

  // 私有构造函数，只能通过计算类创建
  DateTimeDetailsBundle.internal({
    required this.calculationConfig,
    required this.standeredDatetime,
    required this.standeredChineseInfo,
    required this.utcDatetime,
    required this.timezoneStr,
    this.isDST,
    this.removeDSTDatetime,
    this.removeDSTChineseInfo,
    this.location,
    this.meanSolarDatetime,
    this.meanSolarChineseInfo,
    this.coordinates,
    this.trueSolarDatetime,
    this.trueSolarChineseInfo,
    SolarTimeProcessResult? solarTimeData,
  });
}
