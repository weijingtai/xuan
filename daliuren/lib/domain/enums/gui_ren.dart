// lib/domain/enums/gui_ren.dart
import 'package:json_annotation/json_annotation.dart';

enum GuiRen {
  @JsonValue("贵人")
  GUI_REN, // 贵人
  @JsonValue("螣蛇")
  TENG_SHE, // 螣蛇
  @JsonValue("朱雀")
  ZHU_QUE, // 朱雀
  @JsonValue("六合")
  LIU_HE, // 六合
  @JsonValue("勾陈")
  GOU_CHEN, // 勾陈
  @JsonValue("青龙")
  QING_LONG, // 青龙
  @JsonValue("天空")
  TIAN_KONG, // 天空
  @JsonValue("白虎")
  BAI_HU, // 白虎
  @JsonValue("太常")
  TAI_CHANG, // 太常
  @JsonValue("玄武")
  XUAN_WU, // 玄武
  @JsonValue("太阴")
  TAI_YIN, // 太阴
  @JsonValue("天后")
  TIAN_HOU, // 天后
  @JsonValue("未知")
  UNKNOWN, // 未知
}
