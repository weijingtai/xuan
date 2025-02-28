import 'package:tuple/tuple.dart';

import 'enums/enum_twelve_gong.dart';
import 'enums/enum_twenty_eight_xing_xiu.dart';
import 'models/star_xiu_type.dart';

class QiZhengSiYuConstantResources {
  // 古宿，黄道恒星制，《郑式星案恒星制》
  // 古宿，黄道回归，未矫正
  static final Map<TwentyEightStarInn, StarXiuType>
      ZodiacalSiderealOldStarsMapper = {
    TwentyEightStarInn.Lou_Jin_Gou: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Lou_Jin_Gou,
        degreeStartAt: 15.9,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Xu, 15.9),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Xu, 26.3),
        totalDegree: 10.4),
    TwentyEightStarInn.Wei_Tu_Zhi: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Wei_Tu_Zhi,
        degreeStartAt: 26.3,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Xu, 26.3),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 11.1),
        totalDegree: 14.8),
    TwentyEightStarInn.Mao_Ri_Ji: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Mao_Ri_Ji,
        degreeStartAt: 41.1,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 11.1),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 23.2),
        totalDegree: 12.1),
    TwentyEightStarInn.Bi_Yue_Wu: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Bi_Yue_Wu,
        degreeStartAt: 53.2,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 23.2),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 9),
        totalDegree: 15.8),
    TwentyEightStarInn.Zi_Huo_Hou: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Zi_Huo_Hou,
        degreeStartAt: 69,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 9),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 10),
        totalDegree: 1),
    TwentyEightStarInn.Shen_Shui_Yuan: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Shen_Shui_Yuan,
        degreeStartAt: 70,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 10),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 21.8),
        totalDegree: 11.8),
    TwentyEightStarInn.Jing_Mu_Han: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Jing_Mu_Han,
        degreeStartAt: 81.8,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 21.8),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wei, 22.3),
        totalDegree: 30.5),
    TwentyEightStarInn.Gui_Jin_Yang: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Gui_Jin_Yang,
        degreeStartAt: 112.3,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wei, 22.3),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wei, 25.2),
        totalDegree: 2.9),
    TwentyEightStarInn.Liu_Tu_Zhang: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Liu_Tu_Zhang,
        degreeStartAt: 115.2,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wei, 25.2),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wu, 10.5),
        totalDegree: 15.3),
    TwentyEightStarInn.Xing_Ri_Ma: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Xing_Ri_Ma,
        degreeStartAt: 130.5,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wu, 10.5),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wu, 16.4),
        totalDegree: 5.9),
    TwentyEightStarInn.Zhang_Yue_Lu: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Zhang_Yue_Lu,
        degreeStartAt: 136.4,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wu, 16.4),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Si, 1.4),
        totalDegree: 15),
    TwentyEightStarInn.Yi_Huo_She: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Yi_Huo_She,
        degreeStartAt: 151.4,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Si, 1.4),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Si, 20.1),
        totalDegree: 18.7),
    TwentyEightStarInn.Zhen_Shui_Yin: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Zhen_Shui_Yin,
        degreeStartAt: 170.1,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Si, 20.1),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chen, 7.2),
        totalDegree: 17.1),
    TwentyEightStarInn.Jiao_Mu_Jiao: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Jiao_Mu_Jiao,
        degreeStartAt: 187.2,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chen, 7.2),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chen, 20),
        totalDegree: 12.8),
    TwentyEightStarInn.Kang_Jin_Long: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Kang_Jin_Long,
        degreeStartAt: 200,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chen, 20),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chen, 28.9),
        totalDegree: 8.9),
    TwentyEightStarInn.Di_Tu_Lu: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Di_Tu_Lu,
        degreeStartAt: 208.9,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chen, 28.9),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Mao, 15.2),
        totalDegree: 16.3),
    TwentyEightStarInn.Fang_Ri_Tu: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Fang_Ri_Tu,
        degreeStartAt: 225.2,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Mao, 15.2),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Mao, 20.6),
        totalDegree: 5.4),
    TwentyEightStarInn.Xin_Yue_Hu: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Xin_Yue_Hu,
        degreeStartAt: 230.6,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Mao, 20.6),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Mao, 27),
        totalDegree: 6.4),
    TwentyEightStarInn.Wei_Huo_Hu: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Wei_Huo_Hu,
        degreeStartAt: 237,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Mao, 27),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Yin, 15.6),
        totalDegree: 18.6),
    TwentyEightStarInn.Ji_Shui_Bao: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Ji_Shui_Bao,
        degreeStartAt: 255.6,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Yin, 15.6),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Yin, 26.3),
        totalDegree: 10.7),
    TwentyEightStarInn.Dou_Mu_Jiao: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Dou_Mu_Jiao,
        degreeStartAt: 266.3,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Yin, 26.3),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chou, 20.1),
        totalDegree: 23.8),
    TwentyEightStarInn.Niu_Jin_Niu: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Niu_Jin_Niu,
        degreeStartAt: 290.1,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chou, 20.1),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chou, 28),
        totalDegree: 7.9),
    TwentyEightStarInn.Nv_Tu_Fu: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Nv_Tu_Fu,
        degreeStartAt: 298,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chou, 28),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Zi, 8.9),
        totalDegree: 10.9),
    TwentyEightStarInn.Xu_Ri_Shu: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Xu_Ri_Shu,
        degreeStartAt: 308.9,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Zi, 8.9),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Zi, 18.3),
        totalDegree: 9.4),
    TwentyEightStarInn.Wei_Yue_Yan: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Wei_Yue_Yan,
        degreeStartAt: 318.3,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Zi, 18.3),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Hai, 3.6),
        totalDegree: 15.3),
    TwentyEightStarInn.Shi_Huo_Zhu: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Shi_Huo_Zhu,
        degreeStartAt: 333.6,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Hai, 3.6),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Hai, 19.4),
        totalDegree: 15.8),
    TwentyEightStarInn.Bi_Shui_Yu: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Bi_Shui_Yu,
        degreeStartAt: 349.4,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Hai, 19.4),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Hai, 28.3),
        totalDegree: 8.9),
    TwentyEightStarInn.Kui_Mu_Lang: StarXiuType(
        starType: StarPanelType.ZodiacalSiderealOldStars,
        starXiu: TwentyEightStarInn.Kui_Mu_Lang,
        degreeStartAt: 358.3,
        insideGongStartAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Hai, 28.3),
        insideGongEndAtDegree:
            const Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Xu, 15.9),
        totalDegree: 17.6),
  };

  // 古宿，矫正，黄道回归制，相比较 原始《郑氏星案》偏移14.098° 这里取 14°
  // 然后就是校正古宿制，在古宿下面，勾选岁差校正，即得此制。采用黄道回归制（七政四余制）下，以太阳春分点为坐标零点（戌宫0点，黄经0度）
  static final Map<TwentyEightStarInn, StarXiuType>
      ZodiacalCorrectedOldStarsMapper = {
    TwentyEightStarInn.Bi_Shui_Yu: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Bi_Shui_Yu,
        degreeStartAt: 3.50,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Xu, 3.50),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Xu, 12.40),
        totalDegree: 8.90),
    TwentyEightStarInn.Kui_Mu_Lang: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Kui_Mu_Lang,
        degreeStartAt: 12.40,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Xu, 12.40),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 0.00),
        totalDegree: 17.60),
    TwentyEightStarInn.Lou_Jin_Gou: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Lou_Jin_Gou,
        degreeStartAt: 30.00,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 0.00),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 10.40),
        totalDegree: 10.40),
    TwentyEightStarInn.Wei_Tu_Zhi: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Wei_Tu_Zhi,
        degreeStartAt: 40.40,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 10.40),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 25.20),
        totalDegree: 14.80),
    TwentyEightStarInn.Mao_Ri_Ji: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Mao_Ri_Ji,
        degreeStartAt: 55.20,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 25.20),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 7.30),
        totalDegree: 12.10),
    TwentyEightStarInn.Bi_Yue_Wu: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Bi_Yue_Wu,
        degreeStartAt: 67.30,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 7.30),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 23.10),
        totalDegree: 15.80),
    TwentyEightStarInn.Zi_Huo_Hou: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Zi_Huo_Hou,
        degreeStartAt: 83.10,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 23.10),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 24.10),
        totalDegree: 1.00),
    TwentyEightStarInn.Shen_Shui_Yuan: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Shen_Shui_Yuan,
        degreeStartAt: 84.10,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 24.10),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wei, 5.90),
        totalDegree: 11.80),
    TwentyEightStarInn.Jing_Mu_Han: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Jing_Mu_Han,
        degreeStartAt: 95.90,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wei, 5.90),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wu, 6.40),
        totalDegree: 30.50),
    TwentyEightStarInn.Gui_Jin_Yang: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Gui_Jin_Yang,
        degreeStartAt: 126.40,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wu, 6.40),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wu, 9.30),
        totalDegree: 2.90),
    TwentyEightStarInn.Liu_Tu_Zhang: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Liu_Tu_Zhang,
        degreeStartAt: 129.30,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wu, 9.30),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wu, 24.60),
        totalDegree: 15.30),
    TwentyEightStarInn.Xing_Ri_Ma: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Xing_Ri_Ma,
        degreeStartAt: 144.60,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wu, 24.60),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Si, 0.50),
        totalDegree: 5.90),
    TwentyEightStarInn.Zhang_Yue_Lu: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Zhang_Yue_Lu,
        degreeStartAt: 150.50,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Si, 0.50),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Si, 15.50),
        totalDegree: 15.00),
    TwentyEightStarInn.Yi_Huo_She: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Yi_Huo_She,
        degreeStartAt: 165.50,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Si, 15.50),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chen, 4.20),
        totalDegree: 18.70),
    TwentyEightStarInn.Zhen_Shui_Yin: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Zhen_Shui_Yin,
        degreeStartAt: 184.20,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chen, 4.20),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chen, 21.30),
        totalDegree: 17.10),
    TwentyEightStarInn.Jiao_Mu_Jiao: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Jiao_Mu_Jiao,
        degreeStartAt: 201.30,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chen, 21.30),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Mao, 4.10),
        totalDegree: 12.80),
    TwentyEightStarInn.Kang_Jin_Long: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Kang_Jin_Long,
        degreeStartAt: 214.10,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Mao, 4.10),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Mao, 13.00),
        totalDegree: 8.90),
    TwentyEightStarInn.Di_Tu_Lu: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Di_Tu_Lu,
        degreeStartAt: 223.00,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Mao, 13.00),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Mao, 29.30),
        totalDegree: 16.30),
    TwentyEightStarInn.Fang_Ri_Tu: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Fang_Ri_Tu,
        degreeStartAt: 239.30,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Mao, 29.30),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Yin, 4.70),
        totalDegree: 5.40),
    TwentyEightStarInn.Xin_Yue_Hu: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Xin_Yue_Hu,
        degreeStartAt: 244.70,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Yin, 4.70),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Yin, 11.10),
        totalDegree: 6.40),
    TwentyEightStarInn.Wei_Huo_Hu: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Wei_Huo_Hu,
        degreeStartAt: 251.10,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Yin, 11.10),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Yin, 29.70),
        totalDegree: 18.60),
    TwentyEightStarInn.Ji_Shui_Bao: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Ji_Shui_Bao,
        degreeStartAt: 269.70,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Yin, 29.70),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chou, 10.40),
        totalDegree: 10.70),
    TwentyEightStarInn.Dou_Mu_Jiao: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Dou_Mu_Jiao,
        degreeStartAt: 280.40,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chou, 10.40),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Zi, 4.20),
        totalDegree: 23.80),
    TwentyEightStarInn.Niu_Jin_Niu: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Niu_Jin_Niu,
        degreeStartAt: 304.20,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Zi, 4.20),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Zi, 12.10),
        totalDegree: 7.90),
    TwentyEightStarInn.Nv_Tu_Fu: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Nv_Tu_Fu,
        degreeStartAt: 312.10,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Zi, 12.10),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Zi, 23.00),
        totalDegree: 10.90),
    TwentyEightStarInn.Xu_Ri_Shu: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Xu_Ri_Shu,
        degreeStartAt: 323.00,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Zi, 23.00),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Hai, 2.40),
        totalDegree: 9.40),
    TwentyEightStarInn.Wei_Yue_Yan: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Wei_Yue_Yan,
        degreeStartAt: 332.40,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Hai, 2.40),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Hai, 17.70),
        totalDegree: 15.30),
    TwentyEightStarInn.Shi_Huo_Zhu: StarXiuType(
        starType: StarPanelType.ZodiacalCorrectedOldStars,
        starXiu: TwentyEightStarInn.Shi_Huo_Zhu,
        degreeStartAt: 347.70,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Hai, 17.70),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Xu, 3.50),
        totalDegree: 15.80),
  };

  // 今宿 2024-01-01 为基准时间
  // 此为黄道回归今制A
  static final Map<TwentyEightStarInn, StarXiuType> TodayStarsSystemMapper = {
    TwentyEightStarInn.Bi_Shui_Yu: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Bi_Shui_Yu,
        degreeStartAt: 10.59,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Xu, 10.59),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Xu, 22.81),
        totalDegree: 12.22),
    TwentyEightStarInn.Kui_Mu_Lang: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Kui_Mu_Lang,
        degreeStartAt: 22.81,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Xu, 22.81),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 4.33),
        totalDegree: 11.52),
    TwentyEightStarInn.Lou_Jin_Gou: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Lou_Jin_Gou,
        degreeStartAt: 34.33,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 4.33),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 17.30),
        totalDegree: 12.97),
    TwentyEightStarInn.Wei_Tu_Zhi: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Wei_Tu_Zhi,
        degreeStartAt: 47.30,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 17.30),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 29.78),
        totalDegree: 12.48),
    TwentyEightStarInn.Mao_Ri_Ji: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Mao_Ri_Ji,
        degreeStartAt: 59.78,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.You, 29.78),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 8.85),
        totalDegree: 9.07),
    TwentyEightStarInn.Bi_Yue_Wu: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Bi_Yue_Wu,
        degreeStartAt: 68.85,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 8.85),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 24.05),
        totalDegree: 15.20),
    TwentyEightStarInn.Zi_Huo_Hou: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Zi_Huo_Hou,
        degreeStartAt: 84.05,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 24.05),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 25.05),
        totalDegree: 1.00),
    TwentyEightStarInn.Shen_Shui_Yuan: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Shen_Shui_Yuan,
        degreeStartAt: 85.05,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Shen, 25.05),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wei, 5.66),
        totalDegree: 10.62),
    TwentyEightStarInn.Jing_Mu_Han: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Jing_Mu_Han,
        degreeStartAt: 95.66,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wei, 5.66),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wu, 6.11),
        totalDegree: 30.45),
    TwentyEightStarInn.Gui_Jin_Yang: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Gui_Jin_Yang,
        degreeStartAt: 126.11,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wu, 6.11),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wu, 11.10),
        totalDegree: 4.99),
    TwentyEightStarInn.Liu_Tu_Zhang: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Liu_Tu_Zhang,
        degreeStartAt: 131.10,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wu, 11.10),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wu, 27.08),
        totalDegree: 15.98),
    TwentyEightStarInn.Xing_Ri_Ma: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Xing_Ri_Ma,
        degreeStartAt: 147.08,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Wu, 27.08),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Si, 5.08),
        totalDegree: 7.99),
    TwentyEightStarInn.Zhang_Yue_Lu: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Zhang_Yue_Lu,
        degreeStartAt: 155.08,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Si, 5.08),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Si, 24.15),
        totalDegree: 19.07),
    TwentyEightStarInn.Yi_Huo_She: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Yi_Huo_She,
        degreeStartAt: 174.15,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Si, 24.15),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chen, 11.08),
        totalDegree: 16.93),
    TwentyEightStarInn.Zhen_Shui_Yin: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Zhen_Shui_Yin,
        degreeStartAt: 191.08,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chen, 11.08),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chen, 23.89),
        totalDegree: 12.81),
    TwentyEightStarInn.Jiao_Mu_Jiao: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Jiao_Mu_Jiao,
        degreeStartAt: 203.89,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chen, 23.89),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Mao, 4.87),
        totalDegree: 10.99),
    TwentyEightStarInn.Kang_Jin_Long: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Kang_Jin_Long,
        degreeStartAt: 214.87,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Mao, 4.87),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Mao, 15.46),
        totalDegree: 10.59),
    TwentyEightStarInn.Di_Tu_Lu: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Di_Tu_Lu,
        degreeStartAt: 225.46,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Mao, 15.46),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Yin, 3.31),
        totalDegree: 17.85),
    TwentyEightStarInn.Fang_Ri_Tu: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Fang_Ri_Tu,
        degreeStartAt: 243.31,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Yin, 3.31),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Yin, 8.16),
        totalDegree: 4.85),
    TwentyEightStarInn.Xin_Yue_Hu: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Xin_Yue_Hu,
        degreeStartAt: 248.16,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Yin, 8.16),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Yin, 16.41),
        totalDegree: 8.25),
    TwentyEightStarInn.Wei_Huo_Hu: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Wei_Huo_Hu,
        degreeStartAt: 256.41,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Yin, 16.41),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chou, 1.61),
        totalDegree: 15.20),
    TwentyEightStarInn.Ji_Shui_Bao: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Ji_Shui_Bao,
        degreeStartAt: 271.61,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chou, 1.61),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chou, 10.55),
        totalDegree: 8.94),
    TwentyEightStarInn.Dou_Mu_Jiao: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Dou_Mu_Jiao,
        degreeStartAt: 280.55,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Chou, 10.55),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Zi, 4.46),
        totalDegree: 23.92),
    TwentyEightStarInn.Niu_Jin_Niu: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Niu_Jin_Niu,
        degreeStartAt: 304.46,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Zi, 4.46),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Zi, 12.13),
        totalDegree: 7.67),
    TwentyEightStarInn.Nv_Tu_Fu: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Nv_Tu_Fu,
        degreeStartAt: 312.13,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Zi, 12.13),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Zi, 23.80),
        totalDegree: 11.67),
    TwentyEightStarInn.Xu_Ri_Shu: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Xu_Ri_Shu,
        degreeStartAt: 323.80,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Zi, 23.80),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Hai, 3.77),
        totalDegree: 9.97),
    TwentyEightStarInn.Wei_Yue_Yan: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Wei_Yue_Yan,
        degreeStartAt: 333.77,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Hai, 3.77),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Hai, 23.84),
        totalDegree: 20.07),
    TwentyEightStarInn.Shi_Huo_Zhu: StarXiuType(
        starType: StarPanelType.TodayStarsSystem,
        starXiu: TwentyEightStarInn.Shi_Huo_Zhu,
        degreeStartAt: 353.84,
        insideGongStartAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Hai, 23.84),
        insideGongEndAtDegree:
            Tuple2<EnumTwelveGong, double>(EnumTwelveGong.Xu, 10.59),
        totalDegree: 16.75),
  };
}

enum StarPanelType {
  ZodiacalSiderealOldStars("黄道恒星制", 0, []),
  ZodiacalCorrectedOldStars("黄道回归矫正古宿", 0, []),
  // 角木蛟 6.5° 为 戌宫0°
  TodayStarsSystem("黄道回归今宿", 6.5, [
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
    TwentyEightStarInn.Dou_Mu_Jiao,
    TwentyEightStarInn.Niu_Jin_Niu,
    TwentyEightStarInn.Nv_Tu_Fu,
    TwentyEightStarInn.Xu_Ri_Shu,
    TwentyEightStarInn.Wei_Yue_Yan,
  ]);

  final String name;
  final List<TwentyEightStarInn> starInnOrder;
  final double firstAtZeroDegree;
  const StarPanelType(this.name, this.firstAtZeroDegree, this.starInnOrder);
  Map<TwentyEightStarInn, StarXiuType> get mapper {
    switch (this) {
      case StarPanelType.ZodiacalSiderealOldStars:
        return QiZhengSiYuConstantResources.ZodiacalSiderealOldStarsMapper;
      case StarPanelType.ZodiacalCorrectedOldStars:
        return QiZhengSiYuConstantResources.ZodiacalCorrectedOldStarsMapper;
      case StarPanelType.TodayStarsSystem:
        return QiZhengSiYuConstantResources.TodayStarsSystemMapper;
    }
  }
}
