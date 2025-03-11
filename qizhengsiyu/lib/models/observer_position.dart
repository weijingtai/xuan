import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lunar/calendar/Lunar.dart';
import 'package:timezone/timezone.dart' as tz;

part 'observer_position.g.dart';

@JsonSerializable()
class BaseObserverPosition {
  final double latitude;
  final double longitude;
  final double altitude;
  final String timezone;
  BaseObserverPosition(
      {this.altitude = 0,
      required this.latitude,
      required this.longitude,
      required this.timezone});

  factory BaseObserverPosition.fromJson(Map<String, dynamic> json) =>
      _$BaseObserverPositionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$BaseObserverPositionToJson(this);
}

@JsonSerializable()
class ObserverPosition extends BaseObserverPosition {
  final DateTime birthday;
  final DateTime? fateLifeDateTime;
  late final DateTime birthdayUtcTime;
  late final DateTime? fateLifeUtcTime;
  late final String fourZhuEightChar;
  late final JiaZi yearGanZhi;
  late final JiaZi monthGanZhi;
  late final JiaZi dayGanZhi;
  late final JiaZi timeGanZhi;
  ObserverPosition(
      {required this.birthday,
      required double latitude,
      required double longitude,
      required double altitude,
      required String timezone,
      this.fateLifeDateTime})
      : super(
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            timezone: timezone) {
    birthdayUtcTime = toUtcTime(timezone, birthday);
    if (fateLifeDateTime != null) {
      fateLifeUtcTime = toUtcTime(timezone, fateLifeDateTime!);
    }
    Lunar lunar = Lunar.fromDate(birthdayUtcTime);
    dayGanZhi = JiaZi.getFromGanZhiValue(lunar.getDayInGanZhi())!;
    yearGanZhi = JiaZi.getFromGanZhiValue(lunar.getYearInGanZhi())!;
    monthGanZhi = JiaZi.getFromGanZhiValue(lunar.getMonthInGanZhi())!;
    timeGanZhi = JiaZi.getFromGanZhiValue(lunar.getTimeInGanZhi())!;

    fourZhuEightChar = [
      lunar.getYearInGanZhi(),
      lunar.getMonthInGanZhi(),
      dayGanZhi,
      lunar.getTimeInGanZhi()
    ].toList().join('');
  }
  ObserverPosition.fromDateTime(
      {required DateTime datetime, required BaseObserverPosition observer})
      : this(
            birthday: datetime,
            latitude: observer.latitude,
            longitude: observer.longitude,
            altitude: observer.altitude,
            timezone: observer.timezone);
  static DateTime toUtcTime(String timezone, DateTime datetime) {
    tz.TZDateTime shanghaiTime = tz.TZDateTime(
        tz.getLocation(timezone),
        datetime.year,
        datetime.month,
        datetime.day,
        datetime.hour,
        datetime.minute);
    return shanghaiTime.toUtc();
  }

  factory ObserverPosition.fromJson(Map<String, dynamic> json) =>
      _$ObserverPositionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ObserverPositionToJson(this);
}
