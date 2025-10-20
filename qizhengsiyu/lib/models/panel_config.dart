import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/enums/enum_settle_life_body.dart';
import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';

import '../enums/enum_panel_ring.dart';
import '../enums/enum_panel_system_type.dart';
import '../enums/enum_school.dart';

part 'panel_config.g.dart';

/// 自定义配置数据模型
///
@JsonSerializable()
class PanelConfig {
  /// 星道制式
  CelestialCoordinateSystem celestialCoordinateSystem;

  /// 星盘制式
  PanelSystemType panelSystemType;

  /// 星宿类型
  ConstellationSystemType constellationSystemType;

  /// 宫位划分系统
  HouseDivisionSystem houseDivisionSystem;

  /// 立命方式
  EnumSettleLifeType settleLifeType;
  EnumTwelveGong lifeCountingToGong;

  /// 身宫方式
  EnumSettleBodyType settleBodyType;
  EnumTwelveGong bodyCountingToGong;

  /// 立命宫是否以真太阳时计算, 默认以实时太阳时计算，否则根据月令不同，确定太阳所在宫位 如：“子月在寅，丑月在丑，寅月在亥。。。。"
  bool islifeGongBySunRealTimeLocation;

  /// 是否显示径向网格（用于所有环的分宫刻度）
  bool showRingGrid;
  /// UI 是否启动上升点 --- 移动至UI部分
  // bool withAscendant;

  // / UI 化曜系统 --- 移动至UI部分
  // EnumHuaYaoType displayHuaYaoType;

  /// 命盘排列顺序 --- 移动至UI部分
  // List<UIEnumPanelRing> uiPanelRingOrder;
  /// 批命提示流派 --- 移动至星盘高级部分
  // EnumSchoolType schoolType;
  /// 流派典籍 ---- 移动至星盘高级部分
  // List<String> classicBooks;

  PanelConfig({
    /// 星道制式
    required this.celestialCoordinateSystem,

    /// 宫位划分系统
    required this.houseDivisionSystem,

    /// 星宿制式
    required this.panelSystemType,

    /// 星宿类型
    required this.constellationSystemType,

    /// 立命方式
    required this.settleLifeType,

    /// 身宫方式
    required this.settleBodyType,
    required this.islifeGongBySunRealTimeLocation,
    this.lifeCountingToGong = EnumTwelveGong.Mao,
    this.bodyCountingToGong = EnumTwelveGong.You,
    this.showRingGrid = true,
  });
  // copy with
  PanelConfig copyWith({
    /// 星道制式
    CelestialCoordinateSystem? celestialCoordinateSystem,

    /// 星盘制式
    PanelSystemType? panelSystemType,

    /// 星宿类型
    ConstellationSystemType? constellationSystemType,

    /// 宫位划分系统
    HouseDivisionSystem? houseDivisionSystem,

    /// 立命方式
    EnumSettleLifeType? settleLifeType,

    /// 身宫方式
    EnumSettleBodyType? settleBodyType,
    bool? lifeGongBySunRealTimeLocation,
    bool? showRingGrid,
  }) {
    return PanelConfig(
      celestialCoordinateSystem:
          celestialCoordinateSystem ?? this.celestialCoordinateSystem,
      houseDivisionSystem: houseDivisionSystem ?? this.houseDivisionSystem,
      panelSystemType: panelSystemType ?? this.panelSystemType,
      constellationSystemType:
          constellationSystemType ?? this.constellationSystemType,
      settleLifeType: settleLifeType ?? this.settleLifeType,
      settleBodyType: settleBodyType ?? this.settleBodyType,
      islifeGongBySunRealTimeLocation:
          lifeGongBySunRealTimeLocation ?? this.islifeGongBySunRealTimeLocation,
      showRingGrid: showRingGrid ?? this.showRingGrid,
      lifeCountingToGong: lifeCountingToGong,
      bodyCountingToGong: bodyCountingToGong,
    );
  }

  factory PanelConfig.fromJson(Map<String, dynamic> json) =>
      _$PanelConfigFromJson(json);
  Map<String, dynamic> toJson() => _$PanelConfigToJson(this);
}
