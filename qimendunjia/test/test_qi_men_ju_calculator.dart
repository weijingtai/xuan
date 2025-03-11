import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qimendunjia/model/shi_jia_ju.dart';
import 'package:qimendunjia/utils/qi_men_ju_calculator.dart';

void main() {
  group('时家奇门 拆补法', () {
    test("2004/09/01 处暑 阴遁 上元 一局", () {
      ShiJiaQiMenJuCalculator calculator = ChaiBuCalculator(
        dateTime: DateTime(2004, 9, 1),
        // arrangeType:ArrangeType.CHAI_BU,
        // dayJiaZi: JiaZi.getFromGanZhiValue("癸未")!,
        // dayJiaZi: JiaZi.getFromGanZhiValue("壬午")!,
        // jieQi:TwentyFourJieQi.CHU_SHU,
      );
      ShiJiaJu ju = calculator.calculate();
      // expect(null, ju.jieQiStartAt);
      expect("上元", ju.atThreeYuan.name);
      expect(1, ju.juNumber);
      expect("己卯", ju.fuTouJiaZi.name);
    });

    test("2024/08/06 8:22 处暑 阴遁 上元 一局", () {
      ShiJiaQiMenJuCalculator calculator = ChaiBuCalculator(
        dateTime: DateTime(2024, 8, 6, 8, 22),
        // arrangeType:ArrangeType.CHAI_BU,
        // dayJiaZi: JiaZi.getFromGanZhiValue("壬寅")!,
        // jieQi:TwentyFourJieQi.DA_SHU,
      );
      ShiJiaJu ju = calculator.calculate();
      // expect(null, ju.jieQiStartAt);
      expect("中元", ju.atThreeYuan.name);
      expect(1, ju.juNumber);
      expect(YinYang.YIN, ju.yinYangDun);
      // expect("己亥", ju.fuTouJiaZi.name);
    });

    test("2024/08/06 8:22 立夏 阴遁 下元 七局", () {
      ShiJiaQiMenJuCalculator calculator = ChaiBuCalculator(
        dateTime: DateTime(2025, 5, 6, 8, 22),
        // arrangeType:ArrangeType.CHAI_BU,
        // dayJiaZi: JiaZi.getFromGanZhiValue("乙亥")!,
        // jieQi:TwentyFourJieQi.LI_XIA,
      );
      ShiJiaJu ju = calculator.calculate();
      // expect(null, ju.jieQiStartAt);
      expect("下元", ju.atThreeYuan.name);
      // expect(7, ju.juNumber);
      // expect(YinYang.YANG, ju.yinYangDun);
      expect("立夏", ju.jieQiAt.name);
      // expect("己亥", ju.fuTouJiaZi.name);
      expect("", ju.fourZhuEightChar);
    });
  });

  // group('时家奇门 置润法', ()
  // {
  //   test("2004/09/01 处暑 阴遁 上元 一局", () {
  //     ShiJiaQiMenJuCalculator calculator = ZhiRunCalculator(
  //       dateTime: DateTime(2004, 9, 1),
  //       arrangeType: ArrangeType.CHAI_BU,
  //       // dayJiaZi: JiaZi.getFromGanZhiValue("癸未")!,
  //       // dayJiaZi: JiaZi.getFromGanZhiValue("壬午")!,
  //       jieQi: TwentyFourJieQi.CHU_SHU,
  //     );
  //     ShiJiaJu ju = calculator.calculate();
  //     // expect(null, ju.jieQiStartAt);
  //     // expect("上元", ju.atThreeYuan.name);
  //     // expect(1, ju.juNumber);
  //     // expect("己卯", ju.fuTouJiaZi.name);
  //   });
  // });
}
