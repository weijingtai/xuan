import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:qimendunjia/enums/enum_arrange_plate_type.dart';
import 'package:qimendunjia/enums/enum_eight_door.dart';
import 'package:qimendunjia/enums/enum_eight_gods.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';
import 'package:qimendunjia/model/shi_jia_ju.dart';
import 'package:qimendunjia/model/each_gong.dart';
import 'package:qimendunjia/model/each_gong_wang_shuai.dart';
import 'package:qimendunjia/model/pan_arrange_settings.dart';
import 'package:qimendunjia/model/shi_jia_qi_men.dart';
import 'package:qimendunjia/utils/qi_men_ju_calculator.dart';

void main() {
  group('时家转盘奇门', () {
    DateTime panDatetime =
        DateFormat("yyyy-MM-dd HH:mm:ss").parse("2009-3-26 20:49:00");
    String ganZhiList = "己丑 丁卯 庚午 丙戌";
    YinYang yinYangDun = YinYang.YANG;
    int juNumber = 9;
    TwentyFourJieQi jieQi = TwentyFourJieQi.CHUN_FEN;

    ShiJiaQiMenJuCalculator calculator =
        ChaiBuCalculator(dateTime: panDatetime);
    ShiJiaJu shiJiaJu = calculator.calculate();
    var panSettings = PanArrangeSettings(
      arrangeType: ArrangeType.CHAI_BU,
      jiGong: CenterGongJiGongType.ONLY_KUN_GONG,
      starMonthTokenType: MonthTokenTypeEnum.ZHU_QI_NA_GUA,
      starFourWeiGongType: GongTypeEnum.YIN_YANG_DUN,
      doorFourWeiGongType: GongTypeEnum.GONG_GUA,
      godWithGongTypeEnum: GodWithGongTypeEnum.DI_PAN_GAN_NA_GUA,
      ganGongType: GanGongTypeEnum.WANG_MU,
    );
    var shiJiaQiMen = ShiJiaQiMen(
      plateType: PlateType.ZHUAN_PAN,
      // panDateTime:panDatetime,
      shiJiaJu: shiJiaJu,
      settings: panSettings,
    );
    print(shiJiaQiMen.gongMapper.values
        .firstWhere((g) => g.tianPanJiGan != null)
        .gongGua);
    print(shiJiaQiMen.gongMapper.values
        .firstWhere((g) => g.diPanJiGan != null)
        .gongGua);
    test("值符星 值使门 旬首", () {
      expect(NineStarsEnum.RUI, shiJiaQiMen.zhiFuStar);
      expect(EightDoorEnum.SI, shiJiaQiMen.zhiShiDoor);
      expect(JiaZi.JIA_SHEN, shiJiaQiMen.xunShou);
      expect(TianGan.GENG, shiJiaQiMen.xunHeaderTianGan);
    });
    test("坎宫旺衰", () {
      EachGong kanGong = shiJiaQiMen.gongMapper[HouTianGua.Kan]!;
      expect(EightDoorEnum.SHANG, kanGong.door);
      expect(NineStarsEnum.XIN, kanGong.star);
      expect(TianGan.DING, kanGong.tianPan);
      expect(TianGan.JI, kanGong.diPan);
      // expect(EightGodsEnum.BAI_HU, kanGong.god);
      EachGongWangShuai kanGongWangShuai =
          shiJiaQiMen.gongWangShuaiMapper[HouTianGua.Kan]!;
      expect(FiveEnergyStatus.WANG, kanGongWangShuai.doorMonthWangShuai);
      expect(FiveEnergyStatus.XIANG, kanGongWangShuai.doorGongWangShuai);
      expect(NineStarStatusEnum.FEI, kanGongWangShuai.starMonthWangShuai);
      expect(NineStarStatusEnum.WANG, kanGongWangShuai.starGongWangShuai);
      expect(TwelveZhangSheng.BING, kanGongWangShuai.tianPanMonthZhangSheng);
      expect(
          FiveXingRelationship.XIE, kanGongWangShuai.tianDiPanGanRelationship);
      expect(3, kanGongWangShuai.gongWangShuaiCounter);
    });

    test("艮宫旺衰", () {
      EachGong kanGong = shiJiaQiMen.gongMapper[HouTianGua.Gen]!;
      expect(EightDoorEnum.DU, kanGong.door);
      expect(NineStarsEnum.PENG, kanGong.star);
      expect(TianGan.JI, kanGong.tianPan);
      expect(TianGan.YI, kanGong.diPan);
      // expect(EightGodsEnum.BAI_HU, kanGong.god);
      EachGongWangShuai kanGongWangShuai =
          shiJiaQiMen.gongWangShuaiMapper[HouTianGua.Gen]!;
      expect(FiveEnergyStatus.WANG, kanGongWangShuai.doorMonthWangShuai);
      expect(FiveEnergyStatus.QIU, kanGongWangShuai.doorGongWangShuai);
      expect(NineStarStatusEnum.QIU, kanGongWangShuai.starMonthWangShuai);
      expect(NineStarStatusEnum.WANG, kanGongWangShuai.starGongWangShuai);
      expect(TwelveZhangSheng.BING, kanGongWangShuai.tianPanMonthZhangSheng);
      expect(
          FiveXingRelationship.KE, kanGongWangShuai.tianDiPanGanRelationship);
      expect(2, kanGongWangShuai.gongWangShuaiCounter);
    });

    test("坤宫旺衰，天盘干被地盘干庚（旬首天干）克", () {
      HouTianGua gongGua = HouTianGua.Kun;
      EachGong kanGong = shiJiaQiMen.gongMapper[gongGua]!;
      expect(EightDoorEnum.KAI, kanGong.door);
      expect(NineStarsEnum.YING, kanGong.star);
      expect(TianGan.WU, kanGong.tianPan);
      expect(TianGan.GENG, kanGong.diPan);
      // expect(EightGodsEnum.JIU_DI, kanGong.god);
      EachGongWangShuai kanGongWangShuai =
          shiJiaQiMen.gongWangShuaiMapper[gongGua]!;
      expect(FiveEnergyStatus.QIU, kanGongWangShuai.doorMonthWangShuai);
      expect(FiveEnergyStatus.XIANG, kanGongWangShuai.doorGongWangShuai);
      expect(NineStarStatusEnum.WANG, kanGongWangShuai.starMonthWangShuai);
      expect(NineStarStatusEnum.WANG, kanGongWangShuai.starGongWangShuai);
      expect(TwelveZhangSheng.MU_YU, kanGongWangShuai.tianPanMonthZhangSheng);
      expect(
          FiveXingRelationship.KE, kanGongWangShuai.tianDiPanGanRelationship);
      // expect(3, kanGongWangShuai.gongWangShuaiCounter);
    });

    test("兑宫旺衰，天盘干为庚（旬首天干）", () {
      HouTianGua gongGua = HouTianGua.Dui;
      EachGong kanGong = shiJiaQiMen.gongMapper[gongGua]!;
      expect(EightDoorEnum.XIU, kanGong.door);
      expect(NineStarsEnum.RUI, kanGong.star);
      expect(TianGan.GENG, kanGong.tianPan);
      expect(TianGan.BING, kanGong.diPan);
      expect(EightGodsEnum.ZHI_FU, kanGong.god);
      EachGongWangShuai kanGongWangShuai =
          shiJiaQiMen.gongWangShuaiMapper[gongGua]!;
      expect(FiveEnergyStatus.XIU, kanGongWangShuai.doorMonthWangShuai);
      expect(FiveEnergyStatus.XIANG, kanGongWangShuai.doorGongWangShuai);
      expect(NineStarStatusEnum.XIANG, kanGongWangShuai.starMonthWangShuai);
      expect(NineStarStatusEnum.WANG, kanGongWangShuai.starGongWangShuai);
      expect(TwelveZhangSheng.DI_WANG, kanGongWangShuai.tianPanMonthZhangSheng);
      expect(
          FiveXingRelationship.XIE, kanGongWangShuai.tianDiPanGanRelationship);
      expect(4, kanGongWangShuai.gongWangShuaiCounter);
    });
  });

  group("时家飞盘奇门", () {
    DateTime panDatetime =
        DateFormat("yyyy-MM-dd HH:mm:ss").parse("2024-9-7 6:22:00");
    // String ganZhiList = "己丑 丁卯 庚午 丙戌";
    // YinYang yinYangDun = YinYang.YANG;
    // int juNumber = 9;
    // TwentyFourJieQi jieQi = TwentyFourJieQi.CHUN_FEN;

    ShiJiaQiMenJuCalculator calculator =
        ChaiBuCalculator(dateTime: panDatetime);
    ShiJiaJu shiJiaJu = calculator.calculate();
    print(shiJiaJu.juNumber);
    print(shiJiaJu.yinYangDun.name);
    print(shiJiaJu.jieQiAt.name);
    var panSettings = PanArrangeSettings(
      arrangeType: ArrangeType.CHAI_BU,
      jiGong: CenterGongJiGongType.ONLY_KUN_GONG,
      starMonthTokenType: MonthTokenTypeEnum.ZHU_QI_NA_GUA,
      starFourWeiGongType: GongTypeEnum.YIN_YANG_DUN,
      doorFourWeiGongType: GongTypeEnum.GONG_GUA,
      godWithGongTypeEnum: GodWithGongTypeEnum.DI_PAN_GAN_NA_GUA,
      ganGongType: GanGongTypeEnum.WANG_MU,
    );
    var shiJiaQiMen = ShiJiaQiMen(
      plateType: PlateType.FEI_PAN,
      // panDateTime:panDatetime,
      shiJiaJu: shiJiaJu,
      settings: panSettings,
    );
  });
}
