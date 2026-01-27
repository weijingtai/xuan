// lib/domain/enums/nine_zong_men.dart
import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

// 九宗门
enum NineZongMen {
  @JsonValue("贼克")
  ZEI_KE("贼克"), // 贼克法
  @JsonValue("比用")
  BI_YONG("比用"), // 比用法
  @JsonValue("涉害")
  SHE_HAI("涉害"), // 涉害法
  @JsonValue("遥克")
  YAO_KE("遥克"), // 遥克法
  @JsonValue("昴星")
  MAO_XING("昴星"), // 昴星法
  @JsonValue("别责")
  BIE_ZE("别责"), // 别责法
  @JsonValue("八专")
  BA_ZHUAN("八专"), // 八专法
  @JsonValue("伏吟")
  FU_YIN("伏吟"), // 伏吟法
  @JsonValue("返吟")
  FAN_YIN("返吟"), // 返吟法
  @JsonValue("未知")
  UNKNOWN("未知");

  final String name;
  const NineZongMen(this.name);

  /// 昴星课映射表：日干支 -> 干上神位置
  static const Map<JiaZi, List<DiZhi>> maoXingMapping = {
    // 甲子旬
    JiaZi.JI_SI: [DiZhi.SI], // 己巳日干上巳
    JiaZi.GENG_WU: [DiZhi.YOU], // 庚午日干上酉
    JiaZi.XIN_WEI: [DiZhi.HAI], // 辛未日干上亥

    // 甲戌旬
    JiaZi.DING_CHOU: [DiZhi.CHEN, DiZhi.XU], // 丁丑日干上辰戌
    JiaZi.WU_YIN: [DiZhi.YOU], // 戊寅日干上酉
    JiaZi.GUI_WEI: [DiZhi.YIN], // 癸未日干上寅

    // 甲申旬
    JiaZi.DING_HAI: [DiZhi.XU], // 丁亥日干上戌
    JiaZi.WU_ZI: [DiZhi.CHOU], // 戊子日干上丑
    JiaZi.JI_CHOU: [DiZhi.CHEN, DiZhi.XU], // 己丑日干上辰戌
    JiaZi.XIN_MAO: [DiZhi.WEI], // 辛卯日干上未

    // 甲辰旬
    JiaZi.YI_WEI: [DiZhi.MAO, DiZhi.YIN], // 乙未日干上卯寅
    JiaZi.WU_SHEN: [DiZhi.WU], // 戊申日干上午
    JiaZi.JI_YOU: [DiZhi.WU], // 己酉日干上午
  };

  /// 别责课映射表：日干支 -> 干上神位置
  static const Map<JiaZi, List<DiZhi>> bieZeMapping = {
    // 刚日三课
    JiaZi.WU_WU: [DiZhi.WU], // 戊午日干上午
    JiaZi.WU_CHEN: [DiZhi.WU], // 戊辰日干上午
    JiaZi.BING_CHEN: [DiZhi.WU], // 丙辰日干上午

    // 阴日六课
    JiaZi.XIN_CHOU: [DiZhi.CHOU, DiZhi.WEI], // 辛丑日干上丑未
    JiaZi.XIN_WEI: [DiZhi.CHOU, DiZhi.WEI], // 辛未日干上丑未
    JiaZi.DING_YOU: [DiZhi.SI], // 丁酉日干上巳
    JiaZi.XIN_YOU: [DiZhi.YOU], // 辛酉日干上（需要补充具体位置）
  };
}
