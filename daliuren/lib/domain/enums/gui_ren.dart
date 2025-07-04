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
  UNKNOWN; // 未知

  static List<GuiRen> get clockwiseList => [
        GUI_REN, // 贵人
        TENG_SHE, // 螣蛇
        ZHU_QUE, // 朱雀
        LIU_HE, // 六合
        GOU_CHEN, // 勾陈
        TIAN_KONG, // 天空
        BAI_HU, // 白虎
        TAI_CHANG, // 太常
        XUAN_WU, // 玄武
        TAI_YIN, // 太阴
        TIAN_HOU,
      ];
  static List<GuiRen> get antiClockwiseList => clockwiseList.reversed.toList();
  
  /// 根据单个字符获取对应的贵人
  /// 用于解析字符串序列如 "龙勾合雀腾贵后阴玄常虎空"
  static GuiRen getBySingleName(String singleChar) {
    switch (singleChar) {
      case '贵':
        return GUI_REN;
      case '腾':
        return TENG_SHE;
      case '雀':
        return ZHU_QUE;
      case '合':
        return LIU_HE;
      case '勾':
        return GOU_CHEN;
      case '龙':
        return QING_LONG;
      case '空':
        return TIAN_KONG;
      case '虎':
        return BAI_HU;
      case '常':
        return TAI_CHANG;
      case '玄':
        return XUAN_WU;
      case '阴':
        return TAI_YIN;
      case '后':
        return TIAN_HOU;
      default:
        return UNKNOWN;
    }
  }
}
