// common/lib/models/chinese_date_info.dart
import 'package:common/models/eight_chars.dart';
import 'package:common/models/jie_qi_info.dart';
import 'package:common/models/seventy_two_phenology.dart';
import 'package:common/enums.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lunar/lunar.dart';

import '../features/datetime_details/input_info_params.dart';

part 'chinese_date_info.g.dart';

/// 封装了与中国传统历法相关的综合信息
@JsonSerializable()
class ChineseDateInfo extends Equatable {
  /// 四柱八字
  final EightChars eightChars;

  /// 七十二物候
  final Phenology phenology;

  /// 节气信息
  final JieQiInfo jieQiInfo;

  /// 三元
  final YuanYunOrder threeYuan;

  /// 九运
  final NineYun nineYun;

  final int lunarMonth;
  final int lunarDay;
  final bool isLeapMonth;

  const ChineseDateInfo({
    required this.eightChars,
    required this.phenology,
    required this.lunarMonth,
    required this.lunarDay,
    required this.isLeapMonth,
    required this.jieQiInfo,
    required this.threeYuan,
    required this.nineYun,
  });

  @override
  List<Object?> get props => [
        eightChars,
        lunarMonth,
        lunarDay,
        isLeapMonth,
        phenology,
        jieQiInfo,
        threeYuan,
        nineYun
      ];
  factory ChineseDateInfo.fromJson(Map<String, dynamic> json) =>
      _$ChineseDateInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ChineseDateInfoToJson(this);
}
