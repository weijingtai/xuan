// lib/domain/enums/gui_ren.dart
import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:common/shared/enums/enum_tian_gan.dart';
import 'package:common/shared/enums/enum_di_zhi.dart';
import 'package:common/shared/enums/enum_ji_xiong.dart';

enum GuiRen {
  @JsonValue("贵人")
  GUI_REN("贵人", DiZhi.WEI, JiXiongEnum.DA_JI, TianGan.JIA, "西南"), // 贵人
  @JsonValue("螣蛇")
  TENG_SHE("螣蛇", DiZhi.SI, JiXiongEnum.XIONG, TianGan.DING, "东南"), // 螣蛇
  @JsonValue("朱雀")
  ZHU_QUE("朱雀", DiZhi.WU, JiXiongEnum.XIONG, TianGan.BING, "正南"), // 朱雀
  @JsonValue("六合")
  LIU_HE("六合", DiZhi.MAO, JiXiongEnum.JI, TianGan.YI, "正东"), // 六合
  @JsonValue("勾陈")
  GOU_CHEN("勾陈", DiZhi.CHEN, JiXiongEnum.XIONG, TianGan.WU, "东南"), // 勾陈
  @JsonValue("青龙")
  QING_LONG("青龙", DiZhi.YIN, JiXiongEnum.JI, TianGan.JIA, "东北"), // 青龙
  @JsonValue("天空")
  TIAN_KONG("天空", DiZhi.XU, JiXiongEnum.XIONG, TianGan.WU, "西北"), // 天空
  @JsonValue("白虎")
  BAI_HU("白虎", DiZhi.SHEN, JiXiongEnum.XIONG, TianGan.GENG, "西南"), // 白虎
  @JsonValue("太常")
  TAI_CHANG("太常", DiZhi.WEI, JiXiongEnum.JI, TianGan.JI, "西南"), // 太常
  @JsonValue("玄武")
  XUAN_WU("玄武", DiZhi.ZI, JiXiongEnum.XIONG, TianGan.REN, "正北"), // 玄武
  @JsonValue("太阴")
  TAI_YIN("太阴", DiZhi.YOU, JiXiongEnum.JI, TianGan.XIN, "正西"), // 太阴
  @JsonValue("天后")
  TIAN_HOU("天后", DiZhi.HAI, JiXiongEnum.JI, TianGan.GUI, "西北"), // 天后
  @JsonValue("未知")
  UNKNOWN("未知", DiZhi.ZI, JiXiongEnum.WEI_ZHI, TianGan.JIA, "未知"); // 未知

  const GuiRen(
    this.name,
    this.zhi,
    this.jiXiong,
    this.shiGan,
    this.fangJiao,
  );

  final String name;
  final DiZhi zhi;
  final JiXiongEnum jiXiong;
  final TianGan shiGan;
  final String fangJiao;
  FiveXing get fiveXing => zhi.fiveXing;

  static List<GuiRen> get clockwiseList => [
        GUI_REN, // 贵人
        TENG_SHE, // 螣蛇
        ZHU_QUE, // 朱雀
        LIU_HE, // 六合
        GOU_CHEN, // 勾陈
        QING_LONG, // 青龙
        TIAN_KONG, // 天空
        BAI_HU, // 白虎
        TAI_CHANG, // 太常
        XUAN_WU, // 玄武
        TAI_YIN, // 太阴
        TIAN_HOU, // 天后
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

  // 便利方法
  bool get isJi => jiXiong.isJi();
  bool get isXiong => jiXiong.isXiong();
}
