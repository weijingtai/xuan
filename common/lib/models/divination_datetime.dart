import 'package:common/enums.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';

import '../datamodel/location.dart';
import '../datamodel/observer_datamodel.dart';
import 'eight_chars.dart';
import 'jie_qi_info.dart';

import 'package:equatable/equatable.dart';
part 'divination_datetime.g.dart';

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
  @JsonValue("标准时间")
  standard("标准时间"),
  @JsonValue("移除夏令时")
  removeDST("移除夏令时"),
  @JsonValue("平太阳时")
  meanSolar("平太阳时"),
  @JsonValue("真太阳时")
  trueSolar("真太阳时");

  final String name;
  const EnumDatetimeType(this.name);
}

@JsonSerializable()
// @JsonSerializable(explicitToJson: true)
class DivinationDatetimeModel extends Equatable {
  // extends DataClass with EquatableMixin {
  // 公共基础属性
  final String uuid;
  // final EnumDatetimeType type;

  // 差异化属性（声明为可空）
  // final int? hourAdjusted; // RemoveDST特有
  // final Location? location;
  // final bool isManualCalibration;
  final bool isDst;
  final bool isSeersLocation;
  final ObserverDataModel observer;

  // 合并之 Location中
  // final Address? address; // MeanSolar特有
  // final Coordinates? coordinates; // TrueSolar特有

  // 完整属性列表
  // final String queryUuid;
  // final DateTime? lastUpdatedAt;
  // final DateTime? deletedAt;
  // final String timezoneStr;
  final DateTime datetime;
  // final EightChars bazi;
  final JiaZi yearJiaZi;
  final JiaZi monthJiaZi;
  final JiaZi dayJiaZi;
  final JiaZi timeJiaZi;

  EightChars get bazi => EightChars(
        year: yearJiaZi,
        month: monthJiaZi,
        day: dayJiaZi,
        time: timeJiaZi,
      );
  final int lunarMonth;
  final bool isLeapMonth;
  final int lunarDay;
  final JieQiInfo jieQiInfo;

  String get lunarMonthStr {
    String lunarMonthStr =
        SolarLunarDateTimeHelper.intMonth2ChineseMap[lunarMonth]!;
    if (isLeapMonth) {
      return "闰${lunarMonthStr}";
    } else {
      return lunarMonthStr.toString();
    }
  }

  String get lunarDayStr {
    return SolarLunarDateTimeHelper.intDay2ChineseMap[lunarDay]!;
  }

  // 统一私有构造函数
  const DivinationDatetimeModel({
    required this.uuid,

    // required this.type,
    // this.hourAdjusted,
    // this.location,
    // this.address,
    // this.coordinates,
    // required this.timezoneStr,
    required this.observer,
    required this.datetime,
    required this.yearJiaZi,
    required this.monthJiaZi,
    required this.dayJiaZi,
    required this.timeJiaZi,
    required this.lunarMonth,
    required this.lunarDay,
    required this.jieQiInfo,
    required this.isSeersLocation,
    required this.isLeapMonth,
    required this.isDst,
    // required this.isManualCalibration,
    // required this.queryUuid,
    // this.lastUpdatedAt,
    // this.deletedAt,
  });

  /// 标准时间工厂方法
  factory DivinationDatetimeModel.standard({
    required String uuid,
    required String queryUuid,
    required String timezoneStr,
    required DateTime datetime,
    required EightChars bazi,
    required int lunarMonth,
    required int lunarDay,
    required JieQiInfo jieQiInfo,
    required bool isLeapMonth,
    required bool isSeersLocation,
    required Location? location,
    bool isDst = false,
  }) {
    return DivinationDatetimeModel(
        observer: ObserverDataModel(
          timezoneStr: timezoneStr,
          type: EnumDatetimeType.standard,
          location: location,
          coordinate: location?.coordinates,
        ),
        uuid: uuid,
        isSeersLocation: isSeersLocation,
        datetime: datetime,
        yearJiaZi: bazi.year,
        monthJiaZi: bazi.month,
        dayJiaZi: bazi.day,
        timeJiaZi: bazi.time,
        lunarMonth: lunarMonth,
        isLeapMonth: isLeapMonth,
        lunarDay: lunarDay,
        jieQiInfo: jieQiInfo,
        // isManualCalibration: false,
        isDst: isDst);
  }

  /// 移除夏令时工厂方法
  factory DivinationDatetimeModel.removeDST({
    required String uuid,
    required String queryUuid,
    required int hourAdjusted,
    required String timezoneStr,
    required DateTime datetime,
    required EightChars bazi,
    required bool isLeapMonth,
    required int lunarMonth,
    required int lunarDay,
    required JieQiInfo jieQiInfo,
    required bool isSeersLocation,
    required Location? location,
  }) {
    assert(hourAdjusted != 0, "移除夏令时必须提供有效的hourAdjusted参数");

    return DivinationDatetimeModel(
      uuid: uuid,
      isSeersLocation: isSeersLocation,
      // queryUuid: queryUuid,
      observer: ObserverDataModel(
        timezoneStr: timezoneStr,
        type: EnumDatetimeType.removeDST,
        location: location,
        hourAdjusted: hourAdjusted,
        coordinate: location?.coordinates,
      ),
      datetime: datetime,
      yearJiaZi: bazi.year,
      monthJiaZi: bazi.month,
      dayJiaZi: bazi.day,
      timeJiaZi: bazi.time,
      lunarMonth: lunarMonth,
      isLeapMonth: isLeapMonth,
      lunarDay: lunarDay,
      jieQiInfo: jieQiInfo,
      // isManualCalibration: false,
      isDst: false,
    );
  }

  /// 平太阳时工厂方法
  factory DivinationDatetimeModel.meanSolar({
    required String uuid,
    required String queryUuid,
    required Address address,
    required String timezoneStr,
    required DateTime datetime,
    required EightChars bazi,
    required int lunarMonth,
    required bool isLeapMonth,
    required int lunarDay,
    required JieQiInfo jieQiInfo,
    required bool isSeersLocation,
  }) {
    return DivinationDatetimeModel(
      uuid: uuid,
      // queryUuid: queryUuid,
      isSeersLocation: isSeersLocation,
      observer: ObserverDataModel(
          timezoneStr: timezoneStr,
          type: EnumDatetimeType.meanSolar,
          location: Location(address: address),
          coordinate:
              address.city?.coordinates ?? address.province.coordinates),
      datetime: datetime,
      lunarMonth: lunarMonth,
      lunarDay: lunarDay,
      jieQiInfo: jieQiInfo,
      // isManualCalibration: false,
      isDst: false,
      isLeapMonth: isLeapMonth,
      yearJiaZi: bazi.year,
      monthJiaZi: bazi.month,
      dayJiaZi: bazi.day,
      timeJiaZi: bazi.time,
    );
  }

  /// 真太阳时工厂方法
  factory DivinationDatetimeModel.trueSolar(
      {required String uuid,
      required String queryUuid,
      required Coordinates coordinates,
      required String timezoneStr,
      required DateTime datetime,
      required EightChars bazi,
      required int lunarMonth,
      required bool isLeapMonth,
      required int lunarDay,
      required JieQiInfo jieQiInfo,
      required bool isSeersLocation,
      Address? address}) {
    return DivinationDatetimeModel(
      observer: ObserverDataModel(
        timezoneStr: timezoneStr,
        type: EnumDatetimeType.trueSolar,
        location: Location(preciseCoordinates: coordinates, address: address),
        coordinate: coordinates,
      ),
      uuid: uuid,
      isSeersLocation: isSeersLocation,
      datetime: datetime,
      yearJiaZi: bazi.year,
      monthJiaZi: bazi.month,
      dayJiaZi: bazi.day,
      timeJiaZi: bazi.time,
      lunarMonth: lunarMonth,
      isLeapMonth: isLeapMonth,
      lunarDay: lunarDay,
      jieQiInfo: jieQiInfo,
      // isManualCalibration: false,
      isDst: false,
    );
  }

  @override
  List<Object?> get props => [uuid, observer, bazi, datetime];

  // clone
  DivinationDatetimeModel clone({
    String? uuid,
    String? queryUuid,
    // EnumDatetimeType? type,
    // int? hourAdjusted,
    // Location? location,
    // String? timezoneStr,
    ObserverDataModel? observer,
    DateTime? datetime,
    EightChars? bazi,
    int? lunarMonth,
    int? lunarDay,
    JieQiInfo? jieQiInfo,
    bool? isLeapMonth,
    bool? isDst,
    bool? isManualCalibration,
    bool? isSeersLocation,
  }) {
    return DivinationDatetimeModel(
      uuid: uuid ?? this.uuid,
      // queryUuid: queryUuid ?? this.queryUuid,
      observer: observer ?? this.observer,
      isSeersLocation: isSeersLocation ?? this.isSeersLocation,
      datetime: datetime ?? this.datetime,
      yearJiaZi: yearJiaZi,
      monthJiaZi: monthJiaZi,
      dayJiaZi: dayJiaZi,
      timeJiaZi: timeJiaZi,
      lunarMonth: lunarMonth ?? this.lunarMonth,
      isLeapMonth: isLeapMonth ?? this.isLeapMonth,
      lunarDay: lunarDay ?? this.lunarDay,
      jieQiInfo: jieQiInfo ?? this.jieQiInfo,
      isDst: isDst ?? this.isDst,
      // isManualCalibration: isManualCalibration ?? this.isManualCalibration,
      // lastUpdatedAt: lastUpdatedAt,
      // deletedAt: deletedAt,
    );
  }

  factory DivinationDatetimeModel.fromJson(Map<String, dynamic> json) =>
      _$DivinationDatetimeModelFromJson(json);

  Map<String, dynamic> toJson() => _$DivinationDatetimeModelToJson(this);
}
