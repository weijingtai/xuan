import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';

import '../enums/enum_panel_ring.dart';
import '../enums/enum_panel_system_type.dart';
import '../enums/enum_school.dart';

part 'panel_config.g.dart';

/// 自定义配置数据模型
///
@JsonSerializable()
class PanelConfig {
  EnumQueryType queryType;

  /// 星道制式
  CoordinateSystem coordinateSystem;

  /// 星宿制式
  StarInnSystem starInnSystem;

  /// 星宿类型
  StarInnType starInnType;

  /// 批命提示流派
  EnumSchoolType schoolType;

  /// 立命方式
  EnumSettleLifeType settleLifeType;

  /// 身宫方式
  EnumSettleBodyType settleBodyType;

  /// 流派典籍
  List<String> classicBooks;

  /// 是否启动上升点
  bool withAscendant;

  /// 化曜系统
  EnumHuaYaoType huaYaoType;

  /// 命盘排列顺序
  List<EnumPanelRing> panelRingOrder;

  /// 周天度量系统
  CircularSystem circularSystem;

  PanelConfig(
      {required this.queryType,
      required this.coordinateSystem,
      required this.starInnSystem,
      required this.starInnType,
      required this.schoolType,
      required this.settleLifeType,
      required this.settleBodyType,
      required this.withAscendant,
      required this.huaYaoType,
      required this.panelRingOrder,
      required this.classicBooks,
      required this.circularSystem});
  // copy with
  PanelConfig copyWith({
    EnumQueryType? queryType,
    CoordinateSystem? coordinateSystem,
    StarInnSystem? starInnSystem,
    StarInnType? starInnType,
    EnumSchoolType? schoolType,
    EnumSettleLifeType? settleLifeType,
    EnumSettleBodyType? settleBodyType,
    List<String>? classicBooks,
    bool? withAscendant,
    EnumHuaYaoType? huaYaoType,
    List<EnumPanelRing>? panelRingOrder,
    CircularSystem? circularSystem,
  }) {
    return PanelConfig(
      queryType: queryType ?? this.queryType,
      coordinateSystem: coordinateSystem ?? this.coordinateSystem,
      starInnSystem: starInnSystem ?? this.starInnSystem,
      starInnType: starInnType ?? this.starInnType,
      schoolType: schoolType ?? this.schoolType,
      settleLifeType: settleLifeType ?? this.settleLifeType,
      settleBodyType: settleBodyType ?? this.settleBodyType,
      classicBooks: classicBooks ?? this.classicBooks,
      withAscendant: withAscendant ?? this.withAscendant,
      huaYaoType: huaYaoType ?? this.huaYaoType,
      panelRingOrder: panelRingOrder ?? this.panelRingOrder,
      circularSystem: circularSystem ?? this.circularSystem,
    );
  }

  factory PanelConfig.fromJson(Map<String, dynamic> json) =>
      _$PanelConfigFromJson(json);
  Map<String, dynamic> toJson() => _$PanelConfigToJson(this);
}
