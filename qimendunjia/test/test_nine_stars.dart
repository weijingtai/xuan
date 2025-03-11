import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qimendunjia/enums/enum_nine_stars.dart';

void main() {
  group('测试‘九星’与‘宫’的 ‘旺相休囚废’', () {
    test("天蓬 相于 坎一宫", () {
      expect(NineStarsEnum.PENG.checkWithGongGua(HouTianGua.Kan),
          NineStarStatusEnum.XIANG);
    });
    test("天蓬 休于 午宫", () {
      expect(NineStarsEnum.PENG.checkWithGongGua(HouTianGua.Li),
          NineStarStatusEnum.XIU);
    });
    test("天蓬 旺于 震巽宫", () {
      expect(NineStarsEnum.PENG.checkWithGongGua(HouTianGua.Zhen),
          NineStarStatusEnum.WANG);
      expect(NineStarsEnum.PENG.checkWithGongGua(HouTianGua.Xun),
          NineStarStatusEnum.WANG);
    });
    test("天蓬 废于 兑乾宫", () {
      expect(NineStarsEnum.PENG.checkWithGongGua(HouTianGua.Dui),
          NineStarStatusEnum.FEI);
      expect(NineStarsEnum.PENG.checkWithGongGua(HouTianGua.Qian),
          NineStarStatusEnum.FEI);
    });
    test("天蓬 囚于 艮坤宫", () {
      expect(NineStarsEnum.PENG.checkWithGongGua(HouTianGua.Gen),
          NineStarStatusEnum.QIU);
      expect(NineStarsEnum.PENG.checkWithGongGua(HouTianGua.Kun),
          NineStarStatusEnum.QIU);
    });
  });

  group('测试‘九星’与‘月令’的 ‘旺相休囚废’', () {
    test("天蓬 旺于 亥子月", () {
      expect(NineStarsEnum.PENG.checkWithMonthToken(MonthToken.HAI),
          NineStarStatusEnum.XIANG);
      expect(NineStarsEnum.PENG.checkWithMonthToken(MonthToken.ZI),
          NineStarStatusEnum.XIANG);
    });

    test("天蓬 相于 申酉月", () {
      expect(NineStarsEnum.PENG.checkWithMonthToken(MonthToken.SHEN),
          NineStarStatusEnum.FEI);
      expect(NineStarsEnum.PENG.checkWithMonthToken(MonthToken.YOU),
          NineStarStatusEnum.FEI);
    });
    test("天蓬 休于 寅卯月", () {
      expect(NineStarsEnum.PENG.checkWithMonthToken(MonthToken.MAO),
          NineStarStatusEnum.WANG);
      expect(NineStarsEnum.PENG.checkWithMonthToken(MonthToken.YIN),
          NineStarStatusEnum.WANG);
    });
    test("天蓬 囚于 巳午月", () {
      expect(NineStarsEnum.PENG.checkWithMonthToken(MonthToken.SI),
          NineStarStatusEnum.XIU);
      expect(NineStarsEnum.PENG.checkWithMonthToken(MonthToken.WU),
          NineStarStatusEnum.XIU);
    });
    test("天蓬 死于 辰戌丑未月", () {
      expect(NineStarsEnum.PENG.checkWithMonthToken(MonthToken.CHEN),
          NineStarStatusEnum.QIU);
      expect(NineStarsEnum.PENG.checkWithMonthToken(MonthToken.XU),
          NineStarStatusEnum.QIU);
      expect(NineStarsEnum.PENG.checkWithMonthToken(MonthToken.WEI),
          NineStarStatusEnum.QIU);
      expect(NineStarsEnum.PENG.checkWithMonthToken(MonthToken.CHOU),
          NineStarStatusEnum.QIU);
    });
  });
}
