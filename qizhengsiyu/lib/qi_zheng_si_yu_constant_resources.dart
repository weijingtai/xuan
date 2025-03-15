import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';

import 'enums/enum_qi_zheng.dart';
import 'enums/enum_twelve_gong.dart';
import 'models/gong_and_degree.dart';
import 'models/star_inn_gong_degree.dart';

class QiZhengSiYuConstantResources {
  // 古宿，黄道回归，未矫正
  // 黄道回归 古宿
  @JsonValue("黄道回归制古宿")
  static final Map<TwentyEightStarInn, StarInnGongDegreeInfo>
      ZodiacTropicalOriginalClassicStarsInnSystemMapper = {
    TwentyEightStarInn.Lou_Jin_Gou: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Lou_Jin_Gou,
        degreeStartAt: 15.9,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 15.9),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 26.3),
        totalDegree: 10.4),
    TwentyEightStarInn.Wei_Tu_Zhi: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Wei_Tu_Zhi,
        degreeStartAt: 26.3,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 26.3),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 11.1),
        totalDegree: 14.8),
    TwentyEightStarInn.Mao_Ri_Ji: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Mao_Ri_Ji,
        degreeStartAt: 41.1,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 11.1),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 23.2),
        totalDegree: 12.1),
    TwentyEightStarInn.Bi_Yue_Wu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Bi_Yue_Wu,
        degreeStartAt: 53.2,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 23.2),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 9),
        totalDegree: 15.8),
    TwentyEightStarInn.Zi_Huo_Hou: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Zi_Huo_Hou,
        degreeStartAt: 69,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 9),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 10),
        totalDegree: 1),
    TwentyEightStarInn.Shen_Shui_Yuan: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Shen_Shui_Yuan,
        degreeStartAt: 70,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 10),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 21.8),
        totalDegree: 11.8),
    TwentyEightStarInn.Jing_Mu_Han: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Jing_Mu_Han,
        degreeStartAt: 81.8,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 21.8),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wei, 22.3),
        totalDegree: 30.5),
    TwentyEightStarInn.Gui_Jin_Yang: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Gui_Jin_Yang,
        degreeStartAt: 112.3,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wei, 22.3),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wei, 25.2),
        totalDegree: 2.9),
    TwentyEightStarInn.Liu_Tu_Zhang: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Liu_Tu_Zhang,
        degreeStartAt: 115.2,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wei, 25.2),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 10.5),
        totalDegree: 15.3),
    TwentyEightStarInn.Xing_Ri_Ma: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Xing_Ri_Ma,
        degreeStartAt: 130.5,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 10.5),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 16.4),
        totalDegree: 5.9),
    TwentyEightStarInn.Zhang_Yue_Lu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Zhang_Yue_Lu,
        degreeStartAt: 136.4,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 16.4),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 1.4),
        totalDegree: 15),
    TwentyEightStarInn.Yi_Huo_She: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Yi_Huo_She,
        degreeStartAt: 151.4,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 1.4),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 20.1),
        totalDegree: 18.7),
    TwentyEightStarInn.Zhen_Shui_Yin: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Zhen_Shui_Yin,
        degreeStartAt: 170.1,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 20.1),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 7.2),
        totalDegree: 17.1),
    TwentyEightStarInn.Jiao_Mu_Jiao: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Jiao_Mu_Jiao,
        degreeStartAt: 187.2,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 7.2),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 20),
        totalDegree: 12.8),
    TwentyEightStarInn.Kang_Jin_Long: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Kang_Jin_Long,
        degreeStartAt: 200,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 20),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 28.9),
        totalDegree: 8.9),
    TwentyEightStarInn.Di_Tu_Lu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Di_Tu_Lu,
        degreeStartAt: 208.9,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 28.9),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 15.2),
        totalDegree: 16.3),
    TwentyEightStarInn.Fang_Ri_Tu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Fang_Ri_Tu,
        degreeStartAt: 225.2,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 15.2),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 20.6),
        totalDegree: 5.4),
    TwentyEightStarInn.Xin_Yue_Hu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Xin_Yue_Hu,
        degreeStartAt: 230.6,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 20.6),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 27),
        totalDegree: 6.4),
    TwentyEightStarInn.Wei_Huo_Hu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Wei_Huo_Hu,
        degreeStartAt: 237,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 27),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 15.6),
        totalDegree: 18.6),
    TwentyEightStarInn.Ji_Shui_Bao: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Ji_Shui_Bao,
        degreeStartAt: 255.6,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 15.6),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 26.3),
        totalDegree: 10.7),
    TwentyEightStarInn.Dou_Mu_Xie: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Dou_Mu_Xie,
        degreeStartAt: 266.3,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 26.3),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 20.1),
        totalDegree: 23.8),
    TwentyEightStarInn.Niu_Jin_Niu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Niu_Jin_Niu,
        degreeStartAt: 290.1,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 20.1),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 28),
        totalDegree: 7.9),
    TwentyEightStarInn.Nv_Tu_Fu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Nv_Tu_Fu,
        degreeStartAt: 298,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 28),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 8.9),
        totalDegree: 10.9),
    TwentyEightStarInn.Xu_Ri_Shu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Xu_Ri_Shu,
        degreeStartAt: 308.9,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 8.9),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 18.3),
        totalDegree: 9.4),
    TwentyEightStarInn.Wei_Yue_Yan: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Wei_Yue_Yan,
        degreeStartAt: 318.3,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 18.3),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 3.6),
        totalDegree: 15.3),
    TwentyEightStarInn.Shi_Huo_Zhu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Shi_Huo_Zhu,
        degreeStartAt: 333.6,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 3.6),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 19.4),
        totalDegree: 15.8),
    TwentyEightStarInn.Bi_Shui_Yu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Bi_Shui_Yu,
        degreeStartAt: 349.4,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 19.4),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 28.3),
        totalDegree: 8.9),
    TwentyEightStarInn.Kui_Mu_Lang: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Kui_Mu_Lang,
        degreeStartAt: 358.3,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 28.3),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 15.9),
        totalDegree: 17.6),
  };

  // 古宿，矫正，黄道回归制，相比较 原始《郑氏星案》偏移14.098° 这里取 14°
  // 然后就是校正古宿制，在古宿下面，勾选岁差校正，即得此制。采用黄道回归制（七政四余制）下，以太阳春分点为坐标零点（戌宫0点，黄经0度）
  // 黄道回归 古宿矫正
  @JsonValue("黄道回归制古宿矫正")
  static final Map<TwentyEightStarInn, StarInnGongDegreeInfo>
      ZodiacTropicalCorrectedClassicStarsInnSystemMapper = {
    TwentyEightStarInn.Bi_Shui_Yu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Bi_Shui_Yu,
        degreeStartAt: 3.50,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 3.50),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 12.40),
        totalDegree: 8.90),
    TwentyEightStarInn.Kui_Mu_Lang: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Kui_Mu_Lang,
        degreeStartAt: 12.40,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 12.40),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 0.00),
        totalDegree: 17.60),
    TwentyEightStarInn.Lou_Jin_Gou: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Lou_Jin_Gou,
        degreeStartAt: 30.00,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 0.00),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 10.40),
        totalDegree: 10.40),
    TwentyEightStarInn.Wei_Tu_Zhi: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Wei_Tu_Zhi,
        degreeStartAt: 40.40,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 10.40),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 25.20),
        totalDegree: 14.80),
    TwentyEightStarInn.Mao_Ri_Ji: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Mao_Ri_Ji,
        degreeStartAt: 55.20,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 25.20),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 7.30),
        totalDegree: 12.10),
    TwentyEightStarInn.Bi_Yue_Wu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Bi_Yue_Wu,
        degreeStartAt: 67.30,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 7.30),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 23.10),
        totalDegree: 15.80),
    TwentyEightStarInn.Zi_Huo_Hou: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Zi_Huo_Hou,
        degreeStartAt: 83.10,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 23.10),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 24.10),
        totalDegree: 1.00),
    TwentyEightStarInn.Shen_Shui_Yuan: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Shen_Shui_Yuan,
        degreeStartAt: 84.10,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 24.10),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wei, 5.90),
        totalDegree: 11.80),
    TwentyEightStarInn.Jing_Mu_Han: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Jing_Mu_Han,
        degreeStartAt: 95.90,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wei, 5.90),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 6.40),
        totalDegree: 30.50),
    TwentyEightStarInn.Gui_Jin_Yang: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Gui_Jin_Yang,
        degreeStartAt: 126.40,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 6.40),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 9.30),
        totalDegree: 2.90),
    TwentyEightStarInn.Liu_Tu_Zhang: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Liu_Tu_Zhang,
        degreeStartAt: 129.30,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 9.30),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 24.60),
        totalDegree: 15.30),
    TwentyEightStarInn.Xing_Ri_Ma: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Xing_Ri_Ma,
        degreeStartAt: 144.60,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 24.60),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 0.50),
        totalDegree: 5.90),
    TwentyEightStarInn.Zhang_Yue_Lu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Zhang_Yue_Lu,
        degreeStartAt: 150.50,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 0.50),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 15.50),
        totalDegree: 15.00),
    TwentyEightStarInn.Yi_Huo_She: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Yi_Huo_She,
        degreeStartAt: 165.50,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 15.50),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 4.20),
        totalDegree: 18.70),
    TwentyEightStarInn.Zhen_Shui_Yin: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Zhen_Shui_Yin,
        degreeStartAt: 184.20,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 4.20),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 21.30),
        totalDegree: 17.10),
    TwentyEightStarInn.Jiao_Mu_Jiao: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Jiao_Mu_Jiao,
        degreeStartAt: 201.30,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 21.30),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 4.10),
        totalDegree: 12.80),
    TwentyEightStarInn.Kang_Jin_Long: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Kang_Jin_Long,
        degreeStartAt: 214.10,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 4.10),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 13.00),
        totalDegree: 8.90),
    TwentyEightStarInn.Di_Tu_Lu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Di_Tu_Lu,
        degreeStartAt: 223.00,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 13.00),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 29.30),
        totalDegree: 16.30),
    TwentyEightStarInn.Fang_Ri_Tu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Fang_Ri_Tu,
        degreeStartAt: 239.30,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 29.30),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 4.70),
        totalDegree: 5.40),
    TwentyEightStarInn.Xin_Yue_Hu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Xin_Yue_Hu,
        degreeStartAt: 244.70,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 4.70),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 11.10),
        totalDegree: 6.40),
    TwentyEightStarInn.Wei_Huo_Hu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Wei_Huo_Hu,
        degreeStartAt: 251.10,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 11.10),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 29.70),
        totalDegree: 18.60),
    TwentyEightStarInn.Ji_Shui_Bao: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Ji_Shui_Bao,
        degreeStartAt: 269.70,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 29.70),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 10.40),
        totalDegree: 10.70),
    TwentyEightStarInn.Dou_Mu_Xie: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Dou_Mu_Xie,
        degreeStartAt: 280.40,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 10.40),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 4.20),
        totalDegree: 23.80),
    TwentyEightStarInn.Niu_Jin_Niu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Niu_Jin_Niu,
        degreeStartAt: 304.20,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 4.20),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 12.10),
        totalDegree: 7.90),
    TwentyEightStarInn.Nv_Tu_Fu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Nv_Tu_Fu,
        degreeStartAt: 312.10,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 12.10),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 23.00),
        totalDegree: 10.90),
    TwentyEightStarInn.Xu_Ri_Shu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Xu_Ri_Shu,
        degreeStartAt: 323.00,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 23.00),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 2.40),
        totalDegree: 9.40),
    TwentyEightStarInn.Wei_Yue_Yan: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Wei_Yue_Yan,
        degreeStartAt: 332.40,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 2.40),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 17.70),
        totalDegree: 15.30),
    TwentyEightStarInn.Shi_Huo_Zhu: StarInnGongDegreeInfo(
        starType:
            StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Shi_Huo_Zhu,
        degreeStartAt: 347.70,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 17.70),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 3.50),
        totalDegree: 15.80),
  };

  // 今宿 2024-01-01 为基准时间
  // 黄道回归 今宿
  @JsonValue("黄道回归制今宿")
  static final Map<TwentyEightStarInn, StarInnGongDegreeInfo>
      ZodiacTropicalModernStarsInnSystemMapper = {
    TwentyEightStarInn.Bi_Shui_Yu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Bi_Shui_Yu,
        degreeStartAt: 10.59,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 10.59),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 22.81),
        totalDegree: 12.22),
    TwentyEightStarInn.Kui_Mu_Lang: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Kui_Mu_Lang,
        degreeStartAt: 22.81,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 22.81),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 4.33),
        totalDegree: 11.52),
    TwentyEightStarInn.Lou_Jin_Gou: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Lou_Jin_Gou,
        degreeStartAt: 34.33,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 4.33),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 17.30),
        totalDegree: 12.97),
    TwentyEightStarInn.Wei_Tu_Zhi: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Wei_Tu_Zhi,
        degreeStartAt: 47.30,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 17.30),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 29.78),
        totalDegree: 12.48),
    TwentyEightStarInn.Mao_Ri_Ji: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Mao_Ri_Ji,
        degreeStartAt: 59.78,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 29.78),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 8.85),
        totalDegree: 9.07),
    TwentyEightStarInn.Bi_Yue_Wu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Bi_Yue_Wu,
        degreeStartAt: 68.85,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 8.85),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 24.05),
        totalDegree: 15.20),
    TwentyEightStarInn.Zi_Huo_Hou: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Zi_Huo_Hou,
        degreeStartAt: 84.05,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 24.05),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 25.05),
        totalDegree: 1.00),
    TwentyEightStarInn.Shen_Shui_Yuan: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Shen_Shui_Yuan,
        degreeStartAt: 85.05,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 25.05),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wei, 5.66),
        totalDegree: 10.62),
    TwentyEightStarInn.Jing_Mu_Han: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Jing_Mu_Han,
        degreeStartAt: 95.66,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wei, 5.66),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 6.11),
        totalDegree: 30.45),
    TwentyEightStarInn.Gui_Jin_Yang: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Gui_Jin_Yang,
        degreeStartAt: 126.11,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 6.11),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 11.10),
        totalDegree: 4.99),
    TwentyEightStarInn.Liu_Tu_Zhang: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Liu_Tu_Zhang,
        degreeStartAt: 131.10,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 11.10),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 27.08),
        totalDegree: 15.98),
    TwentyEightStarInn.Xing_Ri_Ma: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Xing_Ri_Ma,
        degreeStartAt: 147.08,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 27.08),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 5.08),
        totalDegree: 7.99),
    TwentyEightStarInn.Zhang_Yue_Lu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Zhang_Yue_Lu,
        degreeStartAt: 155.08,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 5.08),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 24.15),
        totalDegree: 19.07),
    TwentyEightStarInn.Yi_Huo_She: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Yi_Huo_She,
        degreeStartAt: 174.15,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 24.15),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 11.08),
        totalDegree: 16.93),
    TwentyEightStarInn.Zhen_Shui_Yin: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Zhen_Shui_Yin,
        degreeStartAt: 191.08,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 11.08),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 23.89),
        totalDegree: 12.81),
    TwentyEightStarInn.Jiao_Mu_Jiao: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Jiao_Mu_Jiao,
        degreeStartAt: 203.89,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 23.89),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 4.87),
        totalDegree: 10.99),
    TwentyEightStarInn.Kang_Jin_Long: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Kang_Jin_Long,
        degreeStartAt: 214.87,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 4.87),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 15.46),
        totalDegree: 10.59),
    TwentyEightStarInn.Di_Tu_Lu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Di_Tu_Lu,
        degreeStartAt: 225.46,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 15.46),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 3.31),
        totalDegree: 17.85),
    TwentyEightStarInn.Fang_Ri_Tu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Fang_Ri_Tu,
        degreeStartAt: 243.31,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 3.31),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 8.16),
        totalDegree: 4.85),
    TwentyEightStarInn.Xin_Yue_Hu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Xin_Yue_Hu,
        degreeStartAt: 248.16,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 8.16),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 16.41),
        totalDegree: 8.25),
    TwentyEightStarInn.Wei_Huo_Hu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Wei_Huo_Hu,
        degreeStartAt: 256.41,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 16.41),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 1.61),
        totalDegree: 15.20),
    TwentyEightStarInn.Ji_Shui_Bao: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Ji_Shui_Bao,
        degreeStartAt: 271.61,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 1.61),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 10.55),
        totalDegree: 8.94),
    TwentyEightStarInn.Dou_Mu_Xie: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Dou_Mu_Xie,
        degreeStartAt: 280.55,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 10.55),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 4.46),
        totalDegree: 23.92),
    TwentyEightStarInn.Niu_Jin_Niu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Niu_Jin_Niu,
        degreeStartAt: 304.46,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 4.46),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 12.13),
        totalDegree: 7.67),
    TwentyEightStarInn.Nv_Tu_Fu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Nv_Tu_Fu,
        degreeStartAt: 312.13,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 12.13),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 23.80),
        totalDegree: 11.67),
    TwentyEightStarInn.Xu_Ri_Shu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Xu_Ri_Shu,
        degreeStartAt: 323.80,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 23.80),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 3.77),
        totalDegree: 9.97),
    TwentyEightStarInn.Wei_Yue_Yan: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Wei_Yue_Yan,
        degreeStartAt: 333.77,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 3.77),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 23.84),
        totalDegree: 20.07),
    TwentyEightStarInn.Shi_Huo_Zhu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Shi_Huo_Zhu,
        degreeStartAt: 353.84,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 23.84),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 10.59),
        totalDegree: 16.75),
  };

  // 黄道恒星制

  // 黄道恒星制星宿度数映射表
  @JsonValue("黄道恒星制")
  static final Map<TwentyEightStarInn, StarInnGongDegreeInfo>
      ZodiacSiderealStarsInnSystemMapper = {
    TwentyEightStarInn.Lou_Jin_Gou: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Lou_Jin_Gou,
        degreeStartAt: 15.9,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 15.9),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 26.3),
        totalDegree: 10.4),
    TwentyEightStarInn.Wei_Tu_Zhi: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Wei_Tu_Zhi,
        degreeStartAt: 26.3,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 26.3),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 11.1),
        totalDegree: 14.8),
    TwentyEightStarInn.Mao_Ri_Ji: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Mao_Ri_Ji,
        degreeStartAt: 41.1,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 11.1),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 23.2),
        totalDegree: 12.1),
    TwentyEightStarInn.Bi_Yue_Wu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Bi_Yue_Wu,
        degreeStartAt: 53.2,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 23.2),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 9.0),
        totalDegree: 15.8),
    TwentyEightStarInn.Zi_Huo_Hou: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Zi_Huo_Hou,
        degreeStartAt: 69.0,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 9.0),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 10.0),
        totalDegree: 1.0),
    TwentyEightStarInn.Shen_Shui_Yuan: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Shen_Shui_Yuan,
        degreeStartAt: 70.0,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 10.0),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 21.8),
        totalDegree: 11.8),
    TwentyEightStarInn.Jing_Mu_Han: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Jing_Mu_Han,
        degreeStartAt: 81.8,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 21.8),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wei, 22.3),
        totalDegree: 30.5),
    TwentyEightStarInn.Gui_Jin_Yang: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Gui_Jin_Yang,
        degreeStartAt: 112.3,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wei, 22.3),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wei, 25.2),
        totalDegree: 2.9),
    TwentyEightStarInn.Liu_Tu_Zhang: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Liu_Tu_Zhang,
        degreeStartAt: 115.2,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wei, 25.2),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 10.5),
        totalDegree: 15.3),
    TwentyEightStarInn.Xing_Ri_Ma: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Xing_Ri_Ma,
        degreeStartAt: 130.5,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 10.5),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 16.4),
        totalDegree: 5.9),
    TwentyEightStarInn.Zhang_Yue_Lu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Zhang_Yue_Lu,
        degreeStartAt: 136.4,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 16.4),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 1.4),
        totalDegree: 15.0),
    TwentyEightStarInn.Yi_Huo_She: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Yi_Huo_She,
        degreeStartAt: 151.4,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 1.4),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 20.1),
        totalDegree: 18.7),
    TwentyEightStarInn.Zhen_Shui_Yin: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Zhen_Shui_Yin,
        degreeStartAt: 170.1,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 20.1),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 7.2),
        totalDegree: 17.1),
    TwentyEightStarInn.Jiao_Mu_Jiao: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Jiao_Mu_Jiao,
        degreeStartAt: 187.2,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 7.2),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 20.0),
        totalDegree: 12.8),
    TwentyEightStarInn.Kang_Jin_Long: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Kang_Jin_Long,
        degreeStartAt: 200.0,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 20.0),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 28.9),
        totalDegree: 8.9),
    TwentyEightStarInn.Di_Tu_Lu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Di_Tu_Lu,
        degreeStartAt: 208.9,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 28.9),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 15.2),
        totalDegree: 16.3),
    TwentyEightStarInn.Fang_Ri_Tu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Fang_Ri_Tu,
        degreeStartAt: 225.2,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 15.2),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 20.6),
        totalDegree: 5.4),
    TwentyEightStarInn.Xin_Yue_Hu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Xin_Yue_Hu,
        degreeStartAt: 230.6,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 20.6),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 27.0),
        totalDegree: 6.4),
    TwentyEightStarInn.Wei_Huo_Hu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Wei_Huo_Hu,
        degreeStartAt: 237.0,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 27.0),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 15.6),
        totalDegree: 18.6),
    TwentyEightStarInn.Ji_Shui_Bao: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Ji_Shui_Bao,
        degreeStartAt: 255.6,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 15.6),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 26.3),
        totalDegree: 10.7),
    TwentyEightStarInn.Dou_Mu_Xie: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Dou_Mu_Xie,
        degreeStartAt: 266.3,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 26.3),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 20.1),
        totalDegree: 23.8),
    TwentyEightStarInn.Niu_Jin_Niu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Niu_Jin_Niu,
        degreeStartAt: 290.1,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 20.1),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 28.0),
        totalDegree: 7.9),
    TwentyEightStarInn.Nv_Tu_Fu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Nv_Tu_Fu,
        degreeStartAt: 298.0,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 28.0),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 8.9),
        totalDegree: 10.9),
    TwentyEightStarInn.Xu_Ri_Shu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Xu_Ri_Shu,
        degreeStartAt: 308.9,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 8.9),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 18.3),
        totalDegree: 9.4),
    TwentyEightStarInn.Wei_Yue_Yan: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Wei_Yue_Yan,
        degreeStartAt: 318.3,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 18.3),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 3.6),
        totalDegree: 15.3),
    TwentyEightStarInn.Shi_Huo_Zhu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Shi_Huo_Zhu,
        degreeStartAt: 333.6,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 3.6),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 19.4),
        totalDegree: 15.8),
    TwentyEightStarInn.Bi_Shui_Yu: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Bi_Shui_Yu,
        degreeStartAt: 349.4,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 19.4),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 28.3),
        totalDegree: 8.9),
    TwentyEightStarInn.Kui_Mu_Lang: StarInnGongDegreeInfo(
        starType: StarPanelType.ZodiacSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Kui_Mu_Lang,
        degreeStartAt: 358.3,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 28.3),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 15.9),
        totalDegree: 17.6),
  };

  // 赤道恒星制
  // 赤道恒星制星宿度数映射表
  // 基于传统赤道28星宿度数，总度数为365.25度
  @JsonValue("赤道恒星制")
  static final Map<TwentyEightStarInn, StarInnGongDegreeInfo>
      EquatorialSiderealStarsInnSystemMapper = {
    // 东方青龙七宿 - 总度数：78度
    TwentyEightStarInn.Jiao_Mu_Jiao: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Jiao_Mu_Jiao,
        degreeStartAt: 0.0,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 0.0),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 12.75),
        totalDegree: 12.75),
    TwentyEightStarInn.Kang_Jin_Long: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Kang_Jin_Long,
        degreeStartAt: 12.75,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 12.75),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 22.5),
        totalDegree: 9.75),
    TwentyEightStarInn.Di_Tu_Lu: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Di_Tu_Lu,
        degreeStartAt: 22.5,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 22.5),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 8.75),
        totalDegree: 16.25),
    TwentyEightStarInn.Fang_Ri_Tu: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Fang_Ri_Tu,
        degreeStartAt: 38.75,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 8.75),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 14.5),
        totalDegree: 5.75),
    TwentyEightStarInn.Xin_Yue_Hu: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Xin_Yue_Hu,
        degreeStartAt: 44.5,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 14.5),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 20.5),
        totalDegree: 6.0),
    TwentyEightStarInn.Wei_Huo_Hu: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Wei_Huo_Hu,
        degreeStartAt: 50.5,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chen, 20.5),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 8.5),
        totalDegree: 18.0),
    TwentyEightStarInn.Ji_Shui_Bao: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Ji_Shui_Bao,
        degreeStartAt: 68.5,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 8.5),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 18.0),
        totalDegree: 9.5),

    // 北方玄武七宿 - 总度数：94度
    TwentyEightStarInn.Dou_Mu_Xie: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Dou_Mu_Xie,
        degreeStartAt: 78.0,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Si, 18.0),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 10.75),
        totalDegree: 22.75),
    TwentyEightStarInn.Niu_Jin_Niu: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Niu_Jin_Niu,
        degreeStartAt: 100.75,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 10.75),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 17.75),
        totalDegree: 7.0),
    TwentyEightStarInn.Nv_Tu_Fu: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Nv_Tu_Fu,
        degreeStartAt: 107.75,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 17.75),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 28.75),
        totalDegree: 11.0),
    TwentyEightStarInn.Xu_Ri_Shu: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Xu_Ri_Shu,
        degreeStartAt: 118.75,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wu, 28.75),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wei, 8.0),
        totalDegree: 9.25),
    TwentyEightStarInn.Wei_Yue_Yan: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Wei_Yue_Yan,
        degreeStartAt: 128.0,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wei, 8.0),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Wei, 24.0),
        totalDegree: 16.0),
    TwentyEightStarInn.Shi_Huo_Zhu: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Shi_Huo_Zhu,
        degreeStartAt: 144.0,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Wei, 24.0),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 12.25),
        totalDegree: 18.25),
    TwentyEightStarInn.Bi_Shui_Yu: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Bi_Shui_Yu,
        degreeStartAt: 162.25,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 12.25),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 22.0),
        totalDegree: 9.75),

    // 西方白虎七宿 - 总度数：83.5度
    TwentyEightStarInn.Kui_Mu_Lang: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Kui_Mu_Lang,
        degreeStartAt: 172.0,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Shen, 22.0),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 10.0),
        totalDegree: 18.0),
    TwentyEightStarInn.Lou_Jin_Gou: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Lou_Jin_Gou,
        degreeStartAt: 190.0,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 10.0),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 22.75),
        totalDegree: 12.75),
    TwentyEightStarInn.Wei_Tu_Zhi: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Wei_Tu_Zhi,
        degreeStartAt: 202.75,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.You, 22.75),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 8.0),
        totalDegree: 15.25),
    TwentyEightStarInn.Mao_Ri_Ji: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Mao_Ri_Ji,
        degreeStartAt: 218.0,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 8.0),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 19.0),
        totalDegree: 11.0),
    TwentyEightStarInn.Bi_Yue_Wu: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Bi_Yue_Wu,
        degreeStartAt: 229.0,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Xu, 19.0),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 5.5),
        totalDegree: 16.5),
    TwentyEightStarInn.Zi_Huo_Hou: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Zi_Huo_Hou,
        degreeStartAt: 245.5,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 5.5),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 6.0),
        totalDegree: 0.5),
    TwentyEightStarInn.Shen_Shui_Yuan: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Shen_Shui_Yuan,
        degreeStartAt: 246.0,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 6.0),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 15.5),
        totalDegree: 9.5),

    // 南方朱雀七宿 - 总度数：109.75度
    TwentyEightStarInn.Jing_Mu_Han: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Jing_Mu_Han,
        degreeStartAt: 255.5,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Hai, 15.5),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 15.75),
        totalDegree: 30.25),
    TwentyEightStarInn.Gui_Jin_Yang: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Gui_Jin_Yang,
        degreeStartAt: 285.75,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 15.75),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 18.25),
        totalDegree: 2.5),
    TwentyEightStarInn.Liu_Tu_Zhang: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Liu_Tu_Zhang,
        degreeStartAt: 288.25,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Zi, 18.25),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 1.75),
        totalDegree: 13.5),
    TwentyEightStarInn.Xing_Ri_Ma: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Xing_Ri_Ma,
        degreeStartAt: 301.75,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 1.75),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 8.5),
        totalDegree: 6.75),
    TwentyEightStarInn.Zhang_Yue_Lu: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Zhang_Yue_Lu,
        degreeStartAt: 308.5,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 8.5),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 26.25),
        totalDegree: 17.75),
    TwentyEightStarInn.Yi_Huo_She: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Yi_Huo_She,
        degreeStartAt: 326.25,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Chou, 26.25),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 16.5),
        totalDegree: 20.25),
    TwentyEightStarInn.Zhen_Shui_Yin: StarInnGongDegreeInfo(
        starType: StarPanelType.EquatorialSiderealStarsInnSystemMapper,
        starXiu: TwentyEightStarInn.Zhen_Shui_Yin,
        degreeStartAt: 346.5,
        startAtGongDegree: const GongAndDegree(EnumTwelveGong.Yin, 16.5),
        endAtGongDegree: const GongAndDegree(EnumTwelveGong.Mao, 0.0),
        totalDegree: 18.75),
  };

  static List<FiveStarWalkingType> getFullForwardList(EnumStars star) {
    switch (star) {
      case EnumStars.Mars:
      case EnumStars.Jupiter:
      case EnumStars.Mercury:
        return FiveStarWalkingType.fullForwardList([]);
      case EnumStars.Saturn:
        // 土星没有疾行与迟行
        return FiveStarWalkingType.fullForwardList(
            [FiveStarWalkingType.Fast, FiveStarWalkingType.Slow]);
      case EnumStars.Venus:
        // 金星没有疾行
        return FiveStarWalkingType.fullForwardList([FiveStarWalkingType.Fast]);
      default:
        // 日月，永远为常
        return [FiveStarWalkingType.Normal];
    }
  }
}

enum EclipticEquatorialType {
  /// 黄道制：以黄道面（地球绕太阳公转轨道平面）为基准划分十二宫，星体位置以黄道经度计算
  Ecliptic("黄道制", "以黄道面为基准划分十二宫，接近西方占星学体系"),

  /// 赤道制：以赤道面（地球赤道延伸至天球的平面）为基准划分十二宫，星体位置以赤道经度计算
  Equatorial("赤道制", "以赤道面为基准划分十二宫，符合中国传统阴阳五行理论"),

  /// 似黄道恒星制：表面上采用黄道划分，但实际数据通过赤道坐标投影推算
  PseudoEclipticSidereal("似黄道恒星制", "采用不等宫系统，通过赤道坐标投影推算黄道位置");

  final String name;
  final String description;

  const EclipticEquatorialType(this.name, this.description);
}

enum SiderealTropicalSystem {
  ////////////////////////////////
  ///恒星制与回归制常见于占星、天文等领域，它们有以下区别：
  /// ### 基础原理与参照体系
  ///- **恒星制**：又名郑氏星案赤道恒星制，以赤道为基础，28星宿为准 。“以虚六定子宫中”，即子宫15度对准虚日鼠6度，以此来划分12宫，每30度为一宫，对应12辰次（星纪、玄枵等）。它研究的是实际的天文现象，关注客观恒星在天空当中的位置，28星宿位置固定不变，不受岁差影响 。
  ///- **回归制**：分为黄道回归古宿制以及黄道回归今宿制，两者都基于黄道。以24节气为节点，将天空划分成12等宫（如白羊、金牛等），每30度为一宫，以时间为单位。它是一套建立在天文学规律上的数理模型，与西方占星具有一样的观测角度，并在黄道的基础上，加入赤道28星宿、12辰次 。

  ///### 星象变动情况
  ///- **恒星制**：星宿不变，但星曜会因岁差而发生变动。
  ///- **回归制**：星曜不变，然而28星宿会有岁差偏移。比如室火猪会从亥宫逆行至戌宫，并且今宿制下，丑宫无牛宿，未宫缺羊宿，与传统地支取象有所差异 。
  ///
  ///### 时间节点与应期判断
  ///- **恒星制**：太阳过宫的时间为每个月的4 - 8号之间，以月支为节点划分，判断应期主要以月支为准，和四柱八字配合使用时，重合度较高 。
  ///- **回归制**：太阳过宫在每个月约20 - 23号之间，对应每个月的第二个节气，判断应期时，需将节点放在太阳过渡的时间 。
  ///
  ///### 与地理位置的关系
  ///- **恒星制**：28星宿位置不变，对应地理位置同样不变，能够从盘中判断盘主适合前往的地方。例如立命在未，命度鬼金羊，金星落于角木蛟，按照“我克者为财”，角木蛟代表的山东西南部可能对命主的财运有帮助 。
  ///- **回归制**：今宿制下由于星宿位置受岁差影响发生偏移，导致与传统28星宿各有分野的地理位置对应出现偏差。如亢金原本在辰宫对应河南黄河以北地带，如今可能进入卯宫取代氐土的位置（氐土对应河南黄河以南） 。

  /// 黄道制：以黄道面（地球绕太阳公转轨道平面）为基准划分十二宫，星体位置以黄道经度计算
  Sidereal("恒星制",
      "又名郑氏星案赤道恒星制，以赤道为基础，28 星宿为准 。“以虚六定子宫中”，即子宫 15 度对准虚日鼠 6 度，以此来划分 12 宫，每 30 度为一宫，对应 12 辰次（星纪、玄枵等）。它研究的是实际的天文现象，关注客观恒星在天空当中的位置，28 星宿位置固定不变，不受岁差影响 。"),

  Tropical("回归制",
      "分为黄道回归古宿制以及黄道回归今宿制，两者都基于黄道。以 24 节气为节点，将天空划分成 12 等宫（如白羊、金牛等），每 30 度为一宫，以时间为单位。它是一套建立在天文学规律上的数理模型，与西方占星具有一样的观测角度，并在黄道的基础上，加入赤道 28 星宿、12 辰次 。");

  final String name;
  final String description;

  const SiderealTropicalSystem(this.name, this.description);
}

/// 维度​	​       古宿制​	              ​今宿制​	              ​矫正古宿制​
/// ​符号完整性​	完整（保留丑牛未羊等）	部分断裂（丑宫无牛宿）	完整（校正后对齐）
/// 天文吻合度​	 低（未修正岁差）     	高（动态修正）      	中（部分修正）
//// ​应用场景​	  传统命理、地理分野	  天文研究、西洋占星对比    	进阶命理分析
enum ConstellationCorrectionType {
  immortal("恒星制", "恒星制下星宿不会发生变化，但会有岁差偏移，不过岁差偏移周期较长为2.6万年"),
  // 古宿
  classical("古宿",
      "沿用中国古代划分的二十八星宿固定位置，星宿与地支的对应关系遵循传统模式（如丑宫对应牛宿，未宫对应鬼宿）。其宿度数据来源于古代文献记载，未根据岁差调整"),
  // 今宿
  modern("今宿", "基于现代天文观测数据，动态调整二十八星宿位置以匹配实际天象，宿度随岁差变化修正"),
  // 古宿矫正
  classicalCorrection("古宿矫正", "在古宿制基础上，通过校正岁差使宿度刻度与当前星轨起点对齐，既保留传统划分又部分修正天文误差");

  final String name;
  final String description;

  const ConstellationCorrectionType(this.name, this.description);
}

/// 星盘坐标系统类型
/// 整合了黄赤道类型、恒星/回归系统以及星宿校正类型
class PanelCelesticalInfo {
  /// 黄赤道类型（黄道制/赤道制/似黄道恒星制）
  final EclipticEquatorialType eclipticEquatorialType;

  /// 恒星/回归系统
  final SiderealTropicalSystem siderealTropicalSystem;

  /// 星宿校正类型（古宿/今宿/矫正古宿）
  final ConstellationCorrectionType correctionType;

  /// 对应的星盘类型
  final StarPanelType starPanelType;

  /// 名称
  final String name;

  /// 描述
  final String description;

  /// 基准时间（用于岁差计算）
  final DateTime? referenceDate;

  const PanelCelesticalInfo({
    required this.eclipticEquatorialType,
    required this.siderealTropicalSystem,
    required this.correctionType,
    required this.starPanelType,
    required this.name,
    required this.description,
    this.referenceDate,
  });

  /// 黄道恒星古宿制
  static const PanelCelesticalInfo eclipticSiderealClassical =
      PanelCelesticalInfo(
    eclipticEquatorialType: EclipticEquatorialType.Ecliptic,
    siderealTropicalSystem: SiderealTropicalSystem.Sidereal,
    correctionType: ConstellationCorrectionType.classical,
    starPanelType:
        StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
    name: "黄道恒星古宿制",
    description: "基于《郑氏星案》的黄道恒星制，使用古代固定星宿位置，不考虑岁差影响",
  );

  /// 黄道回归矫正古宿制
  static const PanelCelesticalInfo eclipticTropicalCorrectedClassical =
      PanelCelesticalInfo(
    eclipticEquatorialType: EclipticEquatorialType.Ecliptic,
    siderealTropicalSystem: SiderealTropicalSystem.Tropical,
    correctionType: ConstellationCorrectionType.classicalCorrection,
    starPanelType:
        StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper,
    name: "黄道回归矫正古宿制",
    description: "在古宿基础上进行岁差校正，以春分点为零点，偏移约14度",
  );

  /// 黄道回归今宿制
  static final PanelCelesticalInfo eclipticTropicalModern = PanelCelesticalInfo(
    eclipticEquatorialType: EclipticEquatorialType.Ecliptic,
    siderealTropicalSystem: SiderealTropicalSystem.Tropical,
    correctionType: ConstellationCorrectionType.modern,
    starPanelType: StarPanelType.ZodiacTropicalModernStarsInnSystemMapper,
    name: "黄道回归今宿制",
    description: "采用现代天文观测数据，以2024年1月1日为基准时间，角宿位于戌宫6.5度起",
    referenceDate: DateTime(2024, 1, 1),
  );

  /// 赤道恒星古宿制
  static const PanelCelesticalInfo equatorialSiderealClassical =
      PanelCelesticalInfo(
    eclipticEquatorialType: EclipticEquatorialType.Equatorial,
    siderealTropicalSystem: SiderealTropicalSystem.Sidereal,
    correctionType: ConstellationCorrectionType.classical,
    starPanelType:
        StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper,
    name: "赤道恒星古宿制",
    description: "以赤道面划分十二宫，结合固定恒星位置，确保四象与地支方位严格对应",
  );

  /// 获取对应的星宿映射表
  Map<TwentyEightStarInn, StarInnGongDegreeInfo> get starXiuMapper =>
      starPanelType.mapper;

  /// 根据给定的参数获取对应的星盘坐标系统类型
  static PanelCelesticalInfo? fromTypes({
    required EclipticEquatorialType eclipticEquatorialType,
    required SiderealTropicalSystem siderealTropicalSystem,
    required ConstellationCorrectionType correctionType,
  }) {
    if (eclipticEquatorialType == EclipticEquatorialType.Ecliptic) {
      if (siderealTropicalSystem == SiderealTropicalSystem.Sidereal) {
        if (correctionType == ConstellationCorrectionType.classical) {
          return eclipticSiderealClassical;
        }
      } else if (siderealTropicalSystem == SiderealTropicalSystem.Tropical) {
        if (correctionType == ConstellationCorrectionType.classicalCorrection) {
          return eclipticTropicalCorrectedClassical;
        } else if (correctionType == ConstellationCorrectionType.modern) {
          return eclipticTropicalModern;
        }
      }
    } else if (eclipticEquatorialType == EclipticEquatorialType.Equatorial) {
      if (siderealTropicalSystem == SiderealTropicalSystem.Sidereal) {
        if (correctionType == ConstellationCorrectionType.classical) {
          return equatorialSiderealClassical;
        }
      }
    }

    return null; // 返回null表示没有找到匹配的类型
  }
}

enum StarPanelType {
  @JsonValue("黄道回归制古宿")
  ZodiacTropicalOriginalClassicStarsInnSystemMapper("黄道回归古宿", 0, []),
  @JsonValue("黄道回归制矫正古宿")
  ZodiacTropicalCorrectedClassicStarsInnSystemMapper("黄道回归矫正古宿", 0, []),
  @JsonValue("赤道恒星制")
  EquatorialSiderealStarsInnSystemMapper("赤道恒星制", 0, []),
  @JsonValue("黄道恒星制")
  ZodiacSiderealStarsInnSystemMapper("黄道恒星制", 0, []),
  // ZodiacTropicalModernStarsInnSystemMapper("黄道回归今宿",0,[]);
  // 角木蛟 6.5° 为 戌宫0°
  @JsonValue("黄道回归制今宿")
  ZodiacTropicalModernStarsInnSystemMapper("黄道回归今宿", 6.5, [
    TwentyEightStarInn.Shi_Huo_Zhu,
    TwentyEightStarInn.Bi_Shui_Yu,
    TwentyEightStarInn.Kui_Mu_Lang,
    TwentyEightStarInn.Lou_Jin_Gou,
    TwentyEightStarInn.Wei_Tu_Zhi,
    TwentyEightStarInn.Mao_Ri_Ji,
    TwentyEightStarInn.Bi_Yue_Wu,
    TwentyEightStarInn.Zi_Huo_Hou,
    TwentyEightStarInn.Shen_Shui_Yuan,
    TwentyEightStarInn.Jing_Mu_Han,
    TwentyEightStarInn.Gui_Jin_Yang,
    TwentyEightStarInn.Liu_Tu_Zhang,
    TwentyEightStarInn.Xing_Ri_Ma,
    TwentyEightStarInn.Zhang_Yue_Lu,
    TwentyEightStarInn.Yi_Huo_She,
    TwentyEightStarInn.Zhen_Shui_Yin,
    TwentyEightStarInn.Jiao_Mu_Jiao,
    TwentyEightStarInn.Kang_Jin_Long,
    TwentyEightStarInn.Di_Tu_Lu,
    TwentyEightStarInn.Fang_Ri_Tu,
    TwentyEightStarInn.Xin_Yue_Hu,
    TwentyEightStarInn.Wei_Huo_Hu,
    TwentyEightStarInn.Ji_Shui_Bao,
    TwentyEightStarInn.Dou_Mu_Xie,
    TwentyEightStarInn.Niu_Jin_Niu,
    TwentyEightStarInn.Nv_Tu_Fu,
    TwentyEightStarInn.Xu_Ri_Shu,
    TwentyEightStarInn.Wei_Yue_Yan,
  ]);

  final String name;
  final List<TwentyEightStarInn> starInnOrder;
  final double firstAtZeroDegree;
  const StarPanelType(this.name, this.firstAtZeroDegree, this.starInnOrder);
  Map<TwentyEightStarInn, StarInnGongDegreeInfo> get mapper {
    switch (this) {
      case StarPanelType.ZodiacTropicalOriginalClassicStarsInnSystemMapper:
        return QiZhengSiYuConstantResources
            .ZodiacTropicalOriginalClassicStarsInnSystemMapper;
      case StarPanelType.ZodiacTropicalCorrectedClassicStarsInnSystemMapper:
        return QiZhengSiYuConstantResources
            .ZodiacTropicalCorrectedClassicStarsInnSystemMapper;
      case StarPanelType.ZodiacTropicalModernStarsInnSystemMapper:
        return QiZhengSiYuConstantResources
            .ZodiacTropicalModernStarsInnSystemMapper;
      case StarPanelType.EquatorialSiderealStarsInnSystemMapper:
        return QiZhengSiYuConstantResources
            .EquatorialSiderealStarsInnSystemMapper;
      case StarPanelType.ZodiacSiderealStarsInnSystemMapper:
        // TODO: Handle this case.
        return QiZhengSiYuConstantResources
            .EquatorialSiderealStarsInnSystemMapper;
    }
  }

  static Map<TwentyEightStarInn, StarInnGongDegreeInfo> getStarXiuMapper(
      PanelCelesticalInfo panelCelesticalInfo) {
    if (panelCelesticalInfo.eclipticEquatorialType ==
        EclipticEquatorialType.Ecliptic) {
      if (panelCelesticalInfo.siderealTropicalSystem ==
              SiderealTropicalSystem.Sidereal ||
          panelCelesticalInfo.correctionType ==
              ConstellationCorrectionType.immortal) {
        throw UnimplementedError(
            "安身立命时，确定命度。位置的命盘制式，[赤道制、黄道制、似黄道回归制]，当前进提供<黄道制>没有黄道恒星制");
      } else {
        if (panelCelesticalInfo.correctionType ==
            ConstellationCorrectionType.classical) {
          /// 古宿
          return QiZhengSiYuConstantResources
              .ZodiacTropicalOriginalClassicStarsInnSystemMapper;
        } else if (panelCelesticalInfo.correctionType ==
            ConstellationCorrectionType.classicalCorrection) {
          /// 古宿矫正
          return QiZhengSiYuConstantResources
              .ZodiacTropicalCorrectedClassicStarsInnSystemMapper;
        } else if (panelCelesticalInfo.correctionType ==
            ConstellationCorrectionType.modern) {
          /// 今宿
          return QiZhengSiYuConstantResources
              .ZodiacTropicalModernStarsInnSystemMapper;
        }
      }
    } else if (panelCelesticalInfo.eclipticEquatorialType ==
        EclipticEquatorialType.Equatorial) {
      throw UnimplementedError("安身立命时，确定命度。当前并没有提供<赤道制>");
    } else if (panelCelesticalInfo.eclipticEquatorialType ==
        EclipticEquatorialType.PseudoEclipticSidereal) {
      throw UnimplementedError("安身立命时，确定命度。当前并没有提供<似黄道回归制>");
    } else {
      throw UnimplementedError(
          "安身立命时，确定命度。位置的命盘制式，[赤道制、黄道制、似黄道回归制]，当前进提供<黄道制>");
    }
    throw UnimplementedError("安身立命时，确定命度。 未找到任何制式的星宿信息");
  }
}
