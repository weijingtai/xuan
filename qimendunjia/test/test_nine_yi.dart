import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qimendunjia/utils/nine_yi_utils.dart';

void main() {
  group('九仪落宫旺衰（十二长生）', () {
    test("乙落[离宫] 长生", () {
      expect(NineYiUtils.checkWithGong(TianGan.YI, HouTianGua.Li),
          TwelveZhangSheng.ZHANG_SHEN);
    });
    test("乙落[乾宫] 死、墓 论【墓】", () {
      expect(NineYiUtils.checkWithGong(TianGan.YI, HouTianGua.Qian),
          TwelveZhangSheng.MU);
    });
    test("乙落[艮宫] 帝旺、衰 论【帝旺】", () {
      expect(NineYiUtils.checkWithGong(TianGan.YI, HouTianGua.Gen),
          TwelveZhangSheng.DI_WANG);
    });
    test("乙落[巽宫] 有沐浴、冠带 论【沐浴】", () {
      expect(NineYiUtils.checkWithGong(TianGan.YI, HouTianGua.Xun),
          TwelveZhangSheng.MU_YU);
    });
    test("丙落[巽宫] 冠带、临官 论【临官】", () {
      expect(NineYiUtils.checkWithGong(TianGan.BING, HouTianGua.Xun),
          TwelveZhangSheng.LIN_GUAN);
    });
    test("丙落[坤宫] 衰、病 论【病】", () {
      expect(NineYiUtils.checkWithGong(TianGan.BING, HouTianGua.Kun),
          TwelveZhangSheng.BING);
    });
    test("丙落[艮宫] 养、长生 论【长生】", () {
      expect(NineYiUtils.checkWithGong(TianGan.BING, HouTianGua.Gen),
          TwelveZhangSheng.ZHANG_SHEN);
    });

    test("丁落[乾宫] 胎、养 论【胎】", () {
      expect(NineYiUtils.checkWithGong(TianGan.DING, HouTianGua.Qian),
          TwelveZhangSheng.TAI);
    });

    // 以下诸家说法不一
    // test("乙落[坤宫] 胎、养 但木在‘未土’为【入门】",(){
    //   expect(NineQiUtils.checkWithGong(TianGan.YI, HouTianGua.Kun), TwelveZhangSheng.MU);
    // });
  });
}
