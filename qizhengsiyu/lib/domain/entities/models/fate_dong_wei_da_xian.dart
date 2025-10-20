import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../models/fate_year_month_pair.dart'; // DongWeiDaXianMingGongCountingType 枚举定义在这里
import '../../../enums/enum_twelve_gong.dart';


part 'fate_dong_wei_da_xian.g.dart';

@JsonSerializable()
class DaXianGong {
  int order;
  EnumDestinyTwelveGong destinyGong;
  EnumTwelveGong gong;
  YearMonth start;
  YearMonth end;
  YearMonth totalYears;

  DaXianGong(
      {required this.order,
      required this.destinyGong,
      required this.gong,
      required this.start,
      required this.end,
      required this.totalYears});

  factory DaXianGong.fromJson(Map<String, dynamic> json) =>
      _$DaXianGongFromJson(json);
  Map<String, dynamic> toJson() => _$DaXianGongToJson(this);
}

@JsonSerializable()
class DaXianFeiXianGong {
  int order;
  EnumTwelveGong gong;
  YearMonth start;
  YearMonth end;
  YearMonth totalYears;

  DaXianFeiXianGong(
      {required this.order,
      required this.gong,
      required this.start,
      required this.end,
      required this.totalYears});

  factory DaXianFeiXianGong.fromJson(Map<String, dynamic> json) =>
      _$DaXianFeiXianGongFromJson(json);
  Map<String, dynamic> toJson() => _$DaXianFeiXianGongToJson(this);
}

@JsonSerializable()
class DongWeiFate {
  final DongWeiDaXianMingGongCountingType type;
  List<DaXianGong> daXianGongs;

  DongWeiFate({
    required this.type,
    required this.daXianGongs,
  });

  factory DongWeiFate.fromJson(Map<String, dynamic> json) =>
      _$DongWeiFateFromJson(json);
  Map<String, dynamic> toJson() => _$DongWeiFateToJson(this);
}
