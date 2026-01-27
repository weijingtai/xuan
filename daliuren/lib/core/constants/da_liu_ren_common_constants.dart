import 'package:common/enums.dart';

import '../../domain/enums/pan_type.dart';

class DaLiuRenCommonConstants {
  /// 十干寄宫映射表
  /// 根据口诀："甲课寅兮乙课辰，丙戊课巳不需论，丁己课未庚申上，辛戌壬亥是其真，癸课原来丑宫坐，分明不用四正神"
  static const Map<TianGan, DiZhi> tianGanJiGongMapper = {
    TianGan.JIA: DiZhi.YIN, // 甲寄寅
    TianGan.YI: DiZhi.CHEN, // 乙寄辰
    TianGan.BING: DiZhi.SI, // 丙寄巳
    TianGan.DING: DiZhi.WEI, // 丁寄未
    TianGan.WU: DiZhi.SI, // 戊寄巳
    TianGan.JI: DiZhi.WEI, // 己寄未
    TianGan.GENG: DiZhi.SHEN, // 庚寄申
    TianGan.XIN: DiZhi.XU, // 辛寄戌
    TianGan.REN: DiZhi.HAI, // 壬寄亥
    TianGan.GUI: DiZhi.CHOU, // 癸寄丑
  };
  static final diZhiJiMapper = {
    DiZhi.YIN: [TianGan.JIA],
    DiZhi.CHEN: [TianGan.YI],
    DiZhi.SI: [TianGan.BING, TianGan.WU],
    DiZhi.WEI: [TianGan.DING, TianGan.JI],
    DiZhi.SHEN: [TianGan.GENG],
    DiZhi.XU: [TianGan.XIN],
    DiZhi.HAI: [TianGan.REN],
    DiZhi.CHOU: [TianGan.GUI],
  };

  // 通过子宫上支，获取PanType
  static const Map<DiZhi, PanType> ziGongUponPanTypeMapper = {
    DiZhi.ZI: PanType.fuYin,
    DiZhi.HAI: PanType.tui_lianRu,
    DiZhi.XU: PanType.tui_jianChua,
    DiZhi.YOU: PanType.bingTai,
    DiZhi.SHEN: PanType.ni_sanHe,
    DiZhi.WEI: PanType.siJue,
    DiZhi.WU: PanType.fanYin,
    DiZhi.SI: PanType.siMuFuSheng,
    DiZhi.CHEN: PanType.shun_sanHe,
    DiZhi.MAO: PanType.shengTai,
    DiZhi.YIN: PanType.shun_jianChuan,
    DiZhi.CHOU: PanType.luoWang
  };

  // key 为日干支，value为 第一局的干上神
  // 如：甲子日，干上寅 甲子第一居；甲子日，干上丑为甲子第二局，以此类推，所有的干上都为逆排地支
  static const Map<JiaZi, DiZhi> juMapper = {
    JiaZi.JIA_ZI: DiZhi.YIN,
    JiaZi.YI_CHOU: DiZhi.CHEN,
    JiaZi.BING_YIN: DiZhi.SI,
    JiaZi.DING_MAO: DiZhi.WEI,
    JiaZi.WU_CHEN: DiZhi.SI,
    JiaZi.JI_SI: DiZhi.WEI,
    JiaZi.GENG_WU: DiZhi.SHEN,
    JiaZi.XIN_WEI: DiZhi.XU,
    JiaZi.REN_SHEN: DiZhi.HAI,
    JiaZi.GUI_YOU: DiZhi.CHOU,
    JiaZi.JIA_XU: DiZhi.YIN,
    JiaZi.YI_HAI: DiZhi.CHEN,
    JiaZi.BING_ZI: DiZhi.SI,
    JiaZi.DING_CHOU: DiZhi.WEI,
    JiaZi.WU_YIN: DiZhi.SI,
    JiaZi.JI_MAO: DiZhi.WEI,
    JiaZi.GENG_CHEN: DiZhi.SHEN,
    JiaZi.XIN_SI: DiZhi.XU,
    JiaZi.REN_WU: DiZhi.HAI,
    JiaZi.GUI_WEI: DiZhi.CHOU,
    JiaZi.JIA_SHEN: DiZhi.YIN,
    JiaZi.YI_YOU: DiZhi.CHEN,
    JiaZi.BING_XU: DiZhi.SI,
    JiaZi.DING_HAI: DiZhi.WEI,
    JiaZi.WU_ZI: DiZhi.SI,
    JiaZi.JI_CHOU: DiZhi.WEI,
    JiaZi.GENG_YIN: DiZhi.SHEN,
    JiaZi.XIN_MAO: DiZhi.XU,
    JiaZi.REN_CHEN: DiZhi.HAI,
    JiaZi.GUI_SI: DiZhi.CHOU,
    JiaZi.JIA_WU: DiZhi.YIN,
    JiaZi.YI_WEI: DiZhi.CHEN,
    JiaZi.BING_SHEN: DiZhi.SI,
    JiaZi.DING_YOU: DiZhi.WEI,
    JiaZi.WU_XU: DiZhi.SI,
    JiaZi.JI_HAI: DiZhi.WEI,
    JiaZi.GENG_ZI: DiZhi.SHEN,
    JiaZi.XIN_CHOU: DiZhi.XU,
    JiaZi.REN_YIN: DiZhi.HAI,
    JiaZi.GUI_MAO: DiZhi.CHOU,
    JiaZi.JIA_CHEN: DiZhi.YIN,
    JiaZi.YI_SI: DiZhi.CHEN,
    JiaZi.BING_WU: DiZhi.SI,
    JiaZi.DING_WEI: DiZhi.WEI,
    JiaZi.WU_SHEN: DiZhi.SI,
    JiaZi.JI_YOU: DiZhi.WEI,
    JiaZi.GENG_XU: DiZhi.SHEN,
    JiaZi.XIN_HAI: DiZhi.XU,
    JiaZi.REN_ZI: DiZhi.HAI,
    JiaZi.GUI_CHOU: DiZhi.CHOU,
    JiaZi.JIA_YIN: DiZhi.YIN,
    JiaZi.YI_MAO: DiZhi.CHEN,
    JiaZi.BING_CHEN: DiZhi.SI,
    JiaZi.DING_SI: DiZhi.WEI,
    JiaZi.WU_WU: DiZhi.SI,
    JiaZi.JI_WEI: DiZhi.WEI,
    JiaZi.GENG_SHEN: DiZhi.SHEN,
    JiaZi.XIN_YOU: DiZhi.XU,
    JiaZi.REN_XU: DiZhi.HAI,
    JiaZi.GUI_HAI: DiZhi.CHOU,
  };
  
}
