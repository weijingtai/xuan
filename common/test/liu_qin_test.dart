import 'package:common/enums/enum_di_zhi.dart';
import 'package:common/enums/enum_liu_qin.dart';
import 'package:common/enums/enum_tian_gan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("六亲", () {
    test("甲 子 父母", () {
      LiuQin result = LiuQin.getLiuQinByForTianGanDiZhi(TianGan.JIA, DiZhi.ZI);
      expect(result, LiuQin.FU_MU);
    });
    test("甲 丑 妻财", () {
      LiuQin result =
          LiuQin.getLiuQinByForTianGanDiZhi(TianGan.JIA, DiZhi.CHOU);
      expect(result, LiuQin.QI_CAI);
    });
    test("甲 巳 子孙", () {
      LiuQin result = LiuQin.getLiuQinByForTianGanDiZhi(TianGan.JIA, DiZhi.SI);
      expect(result, LiuQin.ZI_SUN);
    });
    test("甲 酉 官鬼", () {
      LiuQin result = LiuQin.getLiuQinByForTianGanDiZhi(TianGan.JIA, DiZhi.YOU);
      expect(result, LiuQin.GUAN_GUI);
    });
    test("甲 卯 兄弟", () {
      LiuQin result = LiuQin.getLiuQinByForTianGanDiZhi(TianGan.JIA, DiZhi.MAO);
      expect(result, LiuQin.XIONG_DI);
    });
  });
}
