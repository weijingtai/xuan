import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tuple/tuple.dart';

import 'enum_chinese_12_zodic.dart';
import 'enum_di_zhi.dart';
import 'enum_tian_gan.dart';
import 'enum_five_xing.dart';
import 'enum_tian_gan.dart';

enum NaYinFiveXing {
  HAI_ZHONG_JIN("海中金", FiveXing.JIN),
  LU_ZHONG_HUO("炉中火", FiveXing.HUO),
  DA_LIN_MU("大林木", FiveXing.MU),
  LU_PANG_TU("路旁土", FiveXing.TU),
  JIAN_FENG_JIN("剑锋金", FiveXing.JIN),
  SHAN_TOU_HUO("山头火", FiveXing.HUO),
  JIAN_XIA_SHUI("涧下水", FiveXing.SHUI),
  CHENG_TOU_TU("城头土", FiveXing.TU),
  BAI_LA_JIN("白蜡金", FiveXing.JIN),
  YANG_LIU_MU("杨柳木", FiveXing.MU),
  QUAN_ZHONG_SHUI("泉中水", FiveXing.SHUI),
  WU_SHANG_TU("屋上土", FiveXing.TU),
  PI_LI_HUO("霹雳火", FiveXing.HUO),
  SONG_BAI_MU("松柏木", FiveXing.MU),
  CHANG_LIU_SHUI("长流水", FiveXing.SHUI),
  SHA_ZHONG_JIN("沙中金", FiveXing.JIN),
  SHAN_XIA_HUO("山下火", FiveXing.HUO),
  PING_DI_MU("平地木", FiveXing.MU),
  BI_SHANG_TU("壁上土", FiveXing.TU),
  JIN_BO_JIN("金箔金", FiveXing.JIN),
  FU_DENG_HUO("覆灯火", FiveXing.HUO),
  TIAN_HE_SHUI("天河水", FiveXing.SHUI),
  DA_YI_TU("大驿土", FiveXing.TU),
  CHAI_CHUAN_JIN("钗钏金", FiveXing.JIN),
  SANG_ZHE_MU("桑柘木", FiveXing.MU),
  DA_XI_SHUI("大溪水", FiveXing.SHUI),
  SHA_ZHONG_TU("沙中土", FiveXing.TU),
  TIAN_SHANG_HUO("天上火", FiveXing.HUO),
  SHI_LIU_MU("石榴木", FiveXing.MU),
  DA_HAI_SHUI("大海水", FiveXing.SHUI);

  final String name;
  final FiveXing fiveXing;
  const NaYinFiveXing(this.name, this.fiveXing);

  static NaYinFiveXing? getFromValue(String value) {
    for (var element in NaYinFiveXing.values) {
      if (element.name == value) {
        return element;
      }
    }
    return null;
  }

  // We'll add the fiveXing getter after defining JiaZiIndexMapper
}

class JiaZiIndexMapper {
  static const Map<TianGan, Map<DiZhi, JiaZi>> jiaZiMapper = {
    TianGan.JIA: {
      DiZhi.ZI: JiaZi.JIA_ZI,
      DiZhi.XU: JiaZi.JIA_XU,
      DiZhi.SHEN: JiaZi.JIA_SHEN,
      DiZhi.WU: JiaZi.JIA_WU,
      DiZhi.CHEN: JiaZi.JIA_CHEN,
      DiZhi.YIN: JiaZi.JIA_YIN,
    },
    TianGan.YI: {
      DiZhi.CHOU: JiaZi.YI_CHOU,
      DiZhi.HAI: JiaZi.YI_HAI,
      DiZhi.YOU: JiaZi.YI_YOU,
      DiZhi.WEI: JiaZi.YI_WEI,
      DiZhi.SI: JiaZi.YI_SI,
      DiZhi.MAO: JiaZi.YI_MAO,
    },
    TianGan.BING: {
      DiZhi.YIN: JiaZi.BING_YIN,
      DiZhi.ZI: JiaZi.BING_ZI,
      DiZhi.XU: JiaZi.BING_XU,
      DiZhi.WU: JiaZi.BING_WU,
      DiZhi.CHEN: JiaZi.BING_CHEN,
      DiZhi.SHEN: JiaZi.BING_SHEN,
    },
    TianGan.DING: {
      DiZhi.MAO: JiaZi.DING_MAO,
      DiZhi.CHOU: JiaZi.DING_CHOU,
      DiZhi.HAI: JiaZi.DING_HAI,
      DiZhi.WEI: JiaZi.DING_WEI,
      DiZhi.SI: JiaZi.DING_SI,
      DiZhi.YOU: JiaZi.DING_YOU,
    },
    TianGan.WU: {
      DiZhi.CHEN: JiaZi.WU_CHEN,
      DiZhi.YIN: JiaZi.WU_YIN,
      DiZhi.XU: JiaZi.WU_XU,
      DiZhi.WU: JiaZi.WU_WU,
      DiZhi.SHEN: JiaZi.WU_SHEN,
      DiZhi.ZI: JiaZi.WU_ZI,
    },
    TianGan.JI: {
      DiZhi.SI: JiaZi.JI_SI,
      DiZhi.MAO: JiaZi.JI_MAO,
      DiZhi.HAI: JiaZi.JI_HAI,
      DiZhi.WEI: JiaZi.JI_WEI,
      DiZhi.YOU: JiaZi.JI_YOU,
      DiZhi.CHOU: JiaZi.JI_CHOU,
    },
    TianGan.GENG: {
      DiZhi.WU: JiaZi.GENG_WU,
      DiZhi.CHEN: JiaZi.GENG_CHEN,
      DiZhi.YIN: JiaZi.GENG_YIN,
      DiZhi.XU: JiaZi.GENG_XU,
      DiZhi.SHEN: JiaZi.GENG_SHEN,
      DiZhi.ZI: JiaZi.GENG_ZI,
    },
    TianGan.XIN: {
      DiZhi.WEI: JiaZi.XIN_WEI,
      DiZhi.SI: JiaZi.XIN_SI,
      DiZhi.YOU: JiaZi.XIN_YOU,
      DiZhi.CHOU: JiaZi.XIN_CHOU,
      DiZhi.HAI: JiaZi.XIN_HAI,
      DiZhi.MAO: JiaZi.XIN_MAO,
    },
    TianGan.REN: {
      DiZhi.SHEN: JiaZi.REN_SHEN,
      DiZhi.WU: JiaZi.REN_WU,
      DiZhi.CHEN: JiaZi.REN_CHEN,
      DiZhi.YIN: JiaZi.REN_YIN,
      DiZhi.XU: JiaZi.REN_XU,
      DiZhi.ZI: JiaZi.REN_ZI,
    },
    TianGan.GUI: {
      DiZhi.YOU: JiaZi.GUI_YOU,
      DiZhi.CHOU: JiaZi.GUI_CHOU,
      DiZhi.HAI: JiaZi.GUI_HAI,
      DiZhi.SI: JiaZi.GUI_SI,
      DiZhi.WEI: JiaZi.GUI_WEI,
      DiZhi.MAO: JiaZi.GUI_MAO,
    },
  };

  static const List<JiaZi> jiaZiList = [
    JiaZi.JIA_ZI,
    JiaZi.YI_CHOU,
    JiaZi.BING_YIN,
    JiaZi.DING_MAO,
    JiaZi.WU_CHEN,
    JiaZi.JI_SI,
    JiaZi.GENG_WU,
    JiaZi.XIN_WEI,
    JiaZi.REN_SHEN,
    JiaZi.GUI_YOU,
    JiaZi.JIA_XU,
    JiaZi.YI_HAI,
    JiaZi.BING_ZI,
    JiaZi.DING_CHOU,
    JiaZi.WU_YIN,
    JiaZi.JI_MAO,
    JiaZi.GENG_CHEN,
    JiaZi.XIN_SI,
    JiaZi.REN_WU,
    JiaZi.GUI_WEI,
    JiaZi.JIA_SHEN,
    JiaZi.YI_YOU,
    JiaZi.BING_XU,
    JiaZi.DING_HAI,
    JiaZi.WU_ZI,
    JiaZi.JI_CHOU,
    JiaZi.GENG_YIN,
    JiaZi.XIN_MAO,
    JiaZi.REN_CHEN,
    JiaZi.GUI_SI,
    JiaZi.JIA_WU,
    JiaZi.YI_WEI,
    JiaZi.BING_SHEN,
    JiaZi.DING_YOU,
    JiaZi.WU_XU,
    JiaZi.JI_HAI,
    JiaZi.GENG_ZI,
    JiaZi.XIN_CHOU,
    JiaZi.REN_YIN,
    JiaZi.GUI_MAO,
    JiaZi.JIA_CHEN,
    JiaZi.YI_SI,
    JiaZi.BING_WU,
    JiaZi.DING_WEI,
    JiaZi.WU_SHEN,
    JiaZi.JI_YOU,
    JiaZi.GENG_XU,
    JiaZi.XIN_HAI,
    JiaZi.REN_ZI,
    JiaZi.GUI_CHOU,
    JiaZi.JIA_YIN,
    JiaZi.YI_MAO,
    JiaZi.BING_CHEN,
    JiaZi.DING_SI,
    JiaZi.WU_WU,
    JiaZi.JI_WEI,
    JiaZi.GENG_SHEN,
    JiaZi.XIN_YOU,
    JiaZi.REN_XU,
    JiaZi.GUI_HAI,
  ];

  static const Map<NaYinFiveXing, FiveXing> nayin_fivexing_mapper = {
    NaYinFiveXing.HAI_ZHONG_JIN: FiveXing.JIN,
    NaYinFiveXing.JIAN_FENG_JIN: FiveXing.JIN,
    NaYinFiveXing.BAI_LA_JIN: FiveXing.JIN,
    NaYinFiveXing.JIN_BO_JIN: FiveXing.JIN,
    NaYinFiveXing.CHAI_CHUAN_JIN: FiveXing.JIN,
    NaYinFiveXing.SHA_ZHONG_JIN: FiveXing.JIN,
    NaYinFiveXing.LU_ZHONG_HUO: FiveXing.HUO,
    NaYinFiveXing.SHAN_TOU_HUO: FiveXing.HUO,
    NaYinFiveXing.PI_LI_HUO: FiveXing.HUO,
    NaYinFiveXing.FU_DENG_HUO: FiveXing.HUO,
    NaYinFiveXing.SHAN_XIA_HUO: FiveXing.HUO,
    NaYinFiveXing.TIAN_SHANG_HUO: FiveXing.HUO,
    NaYinFiveXing.DA_LIN_MU: FiveXing.MU,
    NaYinFiveXing.YANG_LIU_MU: FiveXing.MU,
    NaYinFiveXing.SONG_BAI_MU: FiveXing.MU,
    NaYinFiveXing.SANG_ZHE_MU: FiveXing.MU,
    NaYinFiveXing.SHI_LIU_MU: FiveXing.MU,
    NaYinFiveXing.PING_DI_MU: FiveXing.MU,
    NaYinFiveXing.CHENG_TOU_TU: FiveXing.TU,
    NaYinFiveXing.LU_PANG_TU: FiveXing.TU,
    NaYinFiveXing.WU_SHANG_TU: FiveXing.TU,
    NaYinFiveXing.BI_SHANG_TU: FiveXing.TU,
    NaYinFiveXing.SHA_ZHONG_TU: FiveXing.TU,
    NaYinFiveXing.DA_YI_TU: FiveXing.TU,
    NaYinFiveXing.CHANG_LIU_SHUI: FiveXing.SHUI,
    NaYinFiveXing.QUAN_ZHONG_SHUI: FiveXing.SHUI,
    NaYinFiveXing.TIAN_HE_SHUI: FiveXing.SHUI,
    NaYinFiveXing.DA_XI_SHUI: FiveXing.SHUI,
    NaYinFiveXing.DA_HAI_SHUI: FiveXing.SHUI,
    NaYinFiveXing.JIAN_XIA_SHUI: FiveXing.SHUI,
  };
}

enum JiaZi {
  @JsonValue("甲子")
  JIA_ZI(TianGan.JIA, DiZhi.ZI, 1, NaYinFiveXing.HAI_ZHONG_JIN),
  @JsonValue("乙丑")
  YI_CHOU(TianGan.YI, DiZhi.CHOU, 2, NaYinFiveXing.HAI_ZHONG_JIN),
  @JsonValue("丙寅")
  BING_YIN(TianGan.BING, DiZhi.YIN, 3, NaYinFiveXing.LU_ZHONG_HUO),
  @JsonValue("丁卯")
  DING_MAO(TianGan.DING, DiZhi.MAO, 4, NaYinFiveXing.LU_ZHONG_HUO),
  @JsonValue("戊辰")
  WU_CHEN(TianGan.WU, DiZhi.CHEN, 5, NaYinFiveXing.DA_LIN_MU),

  @JsonValue("己巳")
  JI_SI(TianGan.JI, DiZhi.SI, 6, NaYinFiveXing.DA_LIN_MU),
  @JsonValue("庚午")
  GENG_WU(TianGan.GENG, DiZhi.WU, 7, NaYinFiveXing.LU_PANG_TU),
  @JsonValue("辛未")
  XIN_WEI(TianGan.XIN, DiZhi.WEI, 8, NaYinFiveXing.LU_PANG_TU),
  @JsonValue("壬申")
  REN_SHEN(TianGan.REN, DiZhi.SHEN, 9, NaYinFiveXing.JIAN_FENG_JIN),
  @JsonValue("癸酉")
  GUI_YOU(TianGan.GUI, DiZhi.YOU, 10, NaYinFiveXing.JIAN_FENG_JIN),

  @JsonValue("甲戌")
  JIA_XU(TianGan.JIA, DiZhi.XU, 11, NaYinFiveXing.SHAN_TOU_HUO),
  @JsonValue("乙亥")
  YI_HAI(TianGan.YI, DiZhi.HAI, 12, NaYinFiveXing.SHAN_TOU_HUO),
  @JsonValue("丙子")
  BING_ZI(TianGan.BING, DiZhi.ZI, 13, NaYinFiveXing.JIAN_XIA_SHUI),
  @JsonValue("丁丑")
  DING_CHOU(TianGan.DING, DiZhi.CHOU, 14, NaYinFiveXing.JIAN_XIA_SHUI),
  @JsonValue("戊寅")
  WU_YIN(TianGan.WU, DiZhi.YIN, 15, NaYinFiveXing.CHENG_TOU_TU),

  @JsonValue("己卯")
  JI_MAO(TianGan.JI, DiZhi.MAO, 16, NaYinFiveXing.CHENG_TOU_TU),
  @JsonValue("庚辰")
  GENG_CHEN(TianGan.GENG, DiZhi.CHEN, 17, NaYinFiveXing.BAI_LA_JIN),
  @JsonValue("辛巳")
  XIN_SI(TianGan.XIN, DiZhi.SI, 18, NaYinFiveXing.BAI_LA_JIN),
  @JsonValue("壬午")
  REN_WU(TianGan.REN, DiZhi.WU, 19, NaYinFiveXing.YANG_LIU_MU),
  @JsonValue("癸未")
  GUI_WEI(TianGan.GUI, DiZhi.WEI, 20, NaYinFiveXing.YANG_LIU_MU),

  @JsonValue("甲申")
  JIA_SHEN(TianGan.JIA, DiZhi.SHEN, 21, NaYinFiveXing.QUAN_ZHONG_SHUI),
  @JsonValue("乙酉")
  YI_YOU(TianGan.YI, DiZhi.YOU, 22, NaYinFiveXing.QUAN_ZHONG_SHUI),
  @JsonValue("丙戌")
  BING_XU(TianGan.BING, DiZhi.XU, 23, NaYinFiveXing.WU_SHANG_TU),
  @JsonValue("丁亥")
  DING_HAI(TianGan.DING, DiZhi.HAI, 24, NaYinFiveXing.WU_SHANG_TU),
  @JsonValue("戊子")
  WU_ZI(TianGan.WU, DiZhi.ZI, 25, NaYinFiveXing.PI_LI_HUO),
  @JsonValue("己丑")
  JI_CHOU(TianGan.JI, DiZhi.CHOU, 26, NaYinFiveXing.PI_LI_HUO),
  @JsonValue("庚寅")
  GENG_YIN(TianGan.GENG, DiZhi.YIN, 27, NaYinFiveXing.SONG_BAI_MU),
  @JsonValue("辛卯")
  XIN_MAO(TianGan.XIN, DiZhi.MAO, 28, NaYinFiveXing.SONG_BAI_MU),
  @JsonValue("壬辰")
  REN_CHEN(TianGan.REN, DiZhi.CHEN, 29, NaYinFiveXing.CHANG_LIU_SHUI),
  @JsonValue("癸巳")
  GUI_SI(TianGan.GUI, DiZhi.SI, 30, NaYinFiveXing.CHANG_LIU_SHUI),

  @JsonValue("甲午")
  JIA_WU(TianGan.JIA, DiZhi.WU, 31, NaYinFiveXing.SHA_ZHONG_JIN),
  @JsonValue("乙未")
  YI_WEI(TianGan.YI, DiZhi.WEI, 32, NaYinFiveXing.SHA_ZHONG_JIN),
  @JsonValue("丙申")
  BING_SHEN(TianGan.BING, DiZhi.SHEN, 33, NaYinFiveXing.SHAN_XIA_HUO),
  @JsonValue("丁酉")
  DING_YOU(TianGan.DING, DiZhi.YOU, 34, NaYinFiveXing.SHAN_XIA_HUO),
  @JsonValue("戊戌")
  WU_XU(TianGan.WU, DiZhi.XU, 35, NaYinFiveXing.PING_DI_MU),
  @JsonValue("己亥")
  JI_HAI(TianGan.JI, DiZhi.HAI, 36, NaYinFiveXing.PING_DI_MU),
  @JsonValue("庚子")
  GENG_ZI(TianGan.GENG, DiZhi.ZI, 37, NaYinFiveXing.BI_SHANG_TU),
  @JsonValue("辛丑")
  XIN_CHOU(TianGan.XIN, DiZhi.CHOU, 38, NaYinFiveXing.BI_SHANG_TU),
  @JsonValue("壬寅")
  REN_YIN(TianGan.REN, DiZhi.YIN, 39, NaYinFiveXing.JIN_BO_JIN),
  @JsonValue("癸卯")
  GUI_MAO(TianGan.GUI, DiZhi.MAO, 40, NaYinFiveXing.JIN_BO_JIN),

  @JsonValue("甲辰")
  JIA_CHEN(TianGan.JIA, DiZhi.CHEN, 41, NaYinFiveXing.FU_DENG_HUO),
  @JsonValue("乙巳")
  YI_SI(TianGan.YI, DiZhi.SI, 42, NaYinFiveXing.FU_DENG_HUO),
  @JsonValue("丙午")
  BING_WU(TianGan.BING, DiZhi.WU, 43, NaYinFiveXing.TIAN_HE_SHUI),
  @JsonValue("丁未")
  DING_WEI(TianGan.DING, DiZhi.WEI, 44, NaYinFiveXing.TIAN_HE_SHUI),
  @JsonValue("戊申")
  WU_SHEN(TianGan.WU, DiZhi.SHEN, 45, NaYinFiveXing.DA_YI_TU),

  @JsonValue("己酉")
  JI_YOU(TianGan.JI, DiZhi.YOU, 46, NaYinFiveXing.DA_YI_TU),
  @JsonValue("庚戌")
  GENG_XU(TianGan.GENG, DiZhi.XU, 47, NaYinFiveXing.CHAI_CHUAN_JIN),
  @JsonValue("辛亥")
  XIN_HAI(TianGan.XIN, DiZhi.HAI, 48, NaYinFiveXing.CHAI_CHUAN_JIN),
  @JsonValue("壬子")
  REN_ZI(TianGan.REN, DiZhi.ZI, 49, NaYinFiveXing.SANG_ZHE_MU),
  @JsonValue("癸丑")
  GUI_CHOU(TianGan.GUI, DiZhi.CHOU, 50, NaYinFiveXing.SANG_ZHE_MU),

  @JsonValue("甲寅")
  JIA_YIN(TianGan.JIA, DiZhi.YIN, 51, NaYinFiveXing.DA_XI_SHUI),
  @JsonValue("乙卯")
  YI_MAO(TianGan.YI, DiZhi.MAO, 52, NaYinFiveXing.DA_XI_SHUI),
  @JsonValue("丙辰")
  BING_CHEN(TianGan.BING, DiZhi.CHEN, 53, NaYinFiveXing.SHA_ZHONG_TU),
  @JsonValue("丁巳")
  DING_SI(TianGan.DING, DiZhi.SI, 54, NaYinFiveXing.SHA_ZHONG_TU),
  @JsonValue("戊午")
  WU_WU(TianGan.WU, DiZhi.WU, 55, NaYinFiveXing.TIAN_SHANG_HUO),
  @JsonValue("己未")
  JI_WEI(TianGan.JI, DiZhi.WEI, 56, NaYinFiveXing.TIAN_SHANG_HUO),
  @JsonValue("庚申")
  GENG_SHEN(TianGan.GENG, DiZhi.SHEN, 57, NaYinFiveXing.SHI_LIU_MU),
  @JsonValue("辛酉")
  XIN_YOU(TianGan.XIN, DiZhi.YOU, 58, NaYinFiveXing.SHI_LIU_MU),
  @JsonValue("壬戌")
  REN_XU(TianGan.REN, DiZhi.XU, 59, NaYinFiveXing.DA_HAI_SHUI),
  @JsonValue("癸亥")
  GUI_HAI(TianGan.GUI, DiZhi.HAI, 60, NaYinFiveXing.DA_HAI_SHUI);

  final TianGan tianGan;
  final DiZhi diZhi;
  final int number;
  final NaYinFiveXing naYin;

  const JiaZi(this.tianGan, this.diZhi, this.number, this.naYin);
  int getNumber() => number;
  NaYinFiveXing getNaYin() => naYin;
  String get naYinStr => naYin.name;
  (TianGan, DiZhi) get ganZhi => (tianGan, diZhi);
  String get name => tianGan.value + diZhi.value;
  TianGan get gan => tianGan;
  DiZhi get zhi => diZhi;
  String get ganZhiStr => tianGan.value + diZhi.value;

  JiaZi get xunHeader => getXunHeader();

  /// 返回当前干支孙在旬首
  JiaZi getXunHeader() {
    if (number <= JiaZi.GUI_YOU.number) {
      return JiaZi.JIA_ZI;
    } else if (number > JiaZi.GUI_YOU.number &&
        number <= JiaZi.GUI_WEI.number) {
      return JiaZi.JIA_XU;
    } else if (number > JiaZi.GUI_WEI.number && number <= JiaZi.GUI_SI.number) {
      return JiaZi.JIA_SHEN;
    } else if (number > JiaZi.GUI_SI.number && number <= JiaZi.GUI_MAO.number) {
      return JiaZi.JIA_WU;
    } else if (number > JiaZi.GUI_MAO.number &&
        number <= JiaZi.GUI_CHOU.number) {
      return JiaZi.JIA_CHEN;
    } else {
      return JiaZi.JIA_YIN;
    }
  }

  // 获取空亡
  Tuple2<DiZhi, DiZhi> getKongWang() {
    if (number <= JiaZi.GUI_YOU.number) {
      return const Tuple2(DiZhi.XU, DiZhi.HAI);
    } else if (number > JiaZi.GUI_YOU.number &&
        number <= JiaZi.GUI_WEI.number) {
      return const Tuple2(DiZhi.SHEN, DiZhi.YOU);
    } else if (number > JiaZi.GUI_WEI.number && number <= JiaZi.GUI_SI.number) {
      return const Tuple2(DiZhi.WU, DiZhi.WEI);
    } else if (number > JiaZi.GUI_SI.number && number <= JiaZi.GUI_MAO.number) {
      return const Tuple2(DiZhi.CHEN, DiZhi.SI);
    } else if (number > JiaZi.GUI_MAO.number &&
        number <= JiaZi.GUI_CHOU.number) {
      return const Tuple2(DiZhi.YIN, DiZhi.MAO);
    } else {
      return const Tuple2(DiZhi.ZI, DiZhi.CHOU);
    }
  }

  JiaZi getPrevious() {
    if (number == 1) {
      return JiaZi.GUI_HAI;
    } else {
      return JiaZiIndexMapper.jiaZiList[number - 2];
    }
  }

  JiaZi getNext() {
    if (number == 60) {
      return JiaZi.JIA_ZI;
    } else {
      return JiaZiIndexMapper.jiaZiList[number];
    }
  }

  static List<JiaZi> getSix(TianGan gan) {
    return JiaZiIndexMapper.jiaZiMapper[gan]!.values.toList();
  }

  static JiaZi? getFromGanZhiValue(String value) {
    var gan = TianGan.getFromValue(value[0]);
    var zhi = DiZhi.getFromValue(value[1]);
    return gan != null && zhi != null
        ? JiaZiIndexMapper.jiaZiMapper[gan]![zhi]
        : null;
  }

  static JiaZi getByNumber(int number) {
    return JiaZiIndexMapper.jiaZiList[number - 1];
  }

  static JiaZi getFromGanZhiEnum(TianGan gan, DiZhi zhi) {
    return JiaZiIndexMapper.jiaZiMapper[gan]![zhi]!;
  }

  static List<JiaZi> get listAll {
    return JiaZiIndexMapper.jiaZiList;
  }

  static List<JiaZi> getTenXunByXunHeader(JiaZi xunHeadJiaZi) {
    if (xunHeadJiaZi == JiaZi.JIA_ZI) {
      return [
        JIA_ZI,
        YI_CHOU,
        BING_YIN,
        DING_MAO,
        WU_CHEN,
        JI_SI,
        GENG_WU,
        XIN_WEI,
        REN_SHEN,
        GUI_YOU,
      ];
    } else if (xunHeadJiaZi == JiaZi.JIA_XU) {
      return [
        JIA_XU,
        YI_HAI,
        BING_ZI,
        DING_CHOU,
        WU_YIN,
        JI_MAO,
        GENG_CHEN,
        XIN_SI,
        REN_WU,
        GUI_WEI
      ];
    } else if (xunHeadJiaZi == JiaZi.JIA_SHEN) {
      return [
        JIA_SHEN,
        YI_YOU,
        BING_XU,
        DING_HAI,
        WU_ZI,
        JI_CHOU,
        GENG_YIN,
        XIN_MAO,
        REN_CHEN,
        GUI_SI,
      ];
    } else if (xunHeadJiaZi == JiaZi.JIA_WU) {
      return [
        JIA_WU,
        YI_WEI,
        BING_SHEN,
        DING_YOU,
        WU_XU,
        JI_HAI,
        GENG_ZI,
        XIN_CHOU,
        REN_YIN,
        GUI_MAO,
      ];
    } else if (xunHeadJiaZi == JiaZi.JIA_CHEN) {
      return [
        JIA_CHEN,
        YI_SI,
        BING_WU,
        DING_WEI,
        WU_SHEN,
        JI_YOU,
        GENG_XU,
        XIN_HAI,
        REN_ZI,
        GUI_CHOU,
      ];
    } else if (xunHeadJiaZi == JiaZi.JIA_YIN) {
      return [
        JIA_YIN,
        YI_MAO,
        BING_CHEN,
        DING_SI,
        WU_WU,
        JI_WEI,
        GENG_SHEN,
        XIN_YOU,
        REN_XU,
        GUI_HAI
      ];
    } else {
      throw Exception("Unknown xunHeadJiaZi: $xunHeadJiaZi");
    }
  }

  EnumChinese12Zodiac get chinese12Zodiac =>
      EnumChinese12Zodiac.fromDiZhi(diZhi);
}

// Now we can add the fiveXing getter to NaYinFiveXing
extension FiveXingGetter on NaYinFiveXing {
  FiveXing get fiveXing {
    return JiaZiIndexMapper.nayin_fivexing_mapper[this]!;
  }
}
