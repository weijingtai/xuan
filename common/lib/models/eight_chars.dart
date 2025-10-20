import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enums/enum_di_zhi.dart';
import '../enums/enum_jia_zi.dart';
import '../enums/enum_ten_gods.dart';
import '../enums/enum_tian_gan.dart';

part 'eight_chars.g.dart';

@JsonSerializable()
class EightChars extends Equatable {
  JiaZi year;
  JiaZi month;
  JiaZi day;
  JiaZi time;

  EightChars({
    required this.year,
    required this.month,
    required this.day,
    required this.time,
  });

  // Get TianGan components
  TianGan get yearTianGan => year.tianGan;
  TianGan get monthTianGan => month.tianGan;
  TianGan get dayTianGan => day.tianGan;
  TianGan get hourTianGan => time.tianGan;

  // Get DiZhi components
  DiZhi get yearDiZhi => year.diZhi;
  DiZhi get monthDiZhi => month.diZhi;
  DiZhi get dayDiZhi => day.diZhi;
  DiZhi get hourDiZhi => time.diZhi;

  // Get all TianGan and DiZhi as lists
  List<TianGan> get allTianGan =>
      [yearTianGan, monthTianGan, dayTianGan, hourTianGan];
  List<DiZhi> get allDiZhi => [yearDiZhi, monthDiZhi, dayDiZhi, hourDiZhi];
  List<JiaZi> get allJiaZi => [year, month, day, time];

  static defualtBaZi() {
    return EightChars(
      year: JiaZi.JIA_ZI,
      month: JiaZi.JIA_ZI,
      day: JiaZi.JIA_ZI,
      time: JiaZi.JIA_ZI,
    );
  }

  // Convert to string representation
  @override
  String toString() => '${year.name}年${month.name}月${day.name}日${time.name}时';
  List<String> toStrList() => [
        year.name,
        month.name,
        day.name,
        time.name,
      ];
  String toStr() => "${year.name} ${month.name} ${day.name} ${time.name}";

  factory EightChars.fromJson(Map<String, dynamic> json) =>
      _$EightCharsFromJson(json);
  Map<String, dynamic> toJson() => _$EightCharsToJson(this);

  @override
  List<Object?> get props => [year, month, day, time];

  // --- Ten Gods Calculation ---

  EnumTenGods getYearGanTenGods(TianGan dayMaster) {
    return yearTianGan.getTenGods(dayMaster);
  }

  List<EnumTenGods> getYearZhiTenGods(TianGan dayMaster) {
    return yearDiZhi.getTenGods(dayMaster);
  }

  EnumTenGods getMonthGanTenGods(TianGan dayMaster) {
    return monthTianGan.getTenGods(dayMaster);
  }

  List<EnumTenGods> getMonthZhiTenGods(TianGan dayMaster) {
    return monthDiZhi.getTenGods(dayMaster);
  }

  EnumTenGods getDayGanTenGods(TianGan dayMaster) {
    return dayTianGan.getTenGods(dayMaster);
  }

  List<EnumTenGods> getDayZhiTenGods(TianGan dayMaster) {
    return dayDiZhi.getTenGods(dayMaster);
  }

  EnumTenGods getTimeGanTenGods(TianGan dayMaster) {
    return hourTianGan.getTenGods(dayMaster);
  }

  List<EnumTenGods> getTimeZhiTenGods(TianGan dayMaster) {
    return hourDiZhi.getTenGods(dayMaster);
  }

  // --- Ten Gods Getters ---

  EnumTenGods get yearGanTenGods => getYearGanTenGods(dayTianGan);
  List<EnumTenGods> get yearZhiTenGods => getYearZhiTenGods(dayTianGan);

  EnumTenGods get monthGanTenGods => getMonthGanTenGods(dayTianGan);
  List<EnumTenGods> get monthZhiTenGods => getMonthZhiTenGods(dayTianGan);

  EnumTenGods get dayGanTenGods => getDayGanTenGods(dayTianGan);
  List<EnumTenGods> get dayZhiTenGods => getDayZhiTenGods(dayTianGan);

  EnumTenGods get timeGanTenGods => getTimeGanTenGods(dayTianGan);
  List<EnumTenGods> get timeZhiTenGods => getTimeZhiTenGods(dayTianGan);
}
