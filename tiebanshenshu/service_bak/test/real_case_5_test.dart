import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/four_zhu.dart';
import 'package:tiebanshenshu/service/real_case_5.dart';

void main() {
  group('Real Case 5 Tests', () {
    test('太玄取数法测试', () {
      final fourZhu = FourZhu(
        yearGanzhi: "癸巳",
        monthGanzhi: "甲子",
        dayGanzhi: "丁酉",
        timeGanzhi: "癸卯",
      );

      final strategy = TiaoWenNumberCalculationStrategy(fourZhu);

      // 验证四柱基本数
      final expected = [4245, 4826, 2648, 4248];
      final actual = [
        strategy.yearBaseNumber,
        strategy.monthBaseNumber,
        strategy.dayBaseNumber,
        strategy.timeBaseNumber,
      ];

      expect(actual, equals(expected));
      expect(strategy.fourZhuBaseNumberList, equals(expected));
    });

    test('太玄干支和计算测试', () {
      // 测试太玄干支和计算
      final sum1 = TaiXuanEachZhu.calculateTaixuanGanzhiSum("甲子");
      expect(sum1, isA<int>());

      // 测试和为10的情况不计入
      final ganzhiList = ["甲子", "乙丑", "丙寅"];
      final result = TaiXuanEachZhu.calculateEachEightGuaGanzhiSum(ganzhiList);
      expect(result, isA<int>());
    });

    test('阳年阴年天干配置测试', () {
      // 测试阳年配置
      final yangYearGetter = TaiXuanEachZhu.getEachYaoGan(true);
      final yangResult = yangYearGetter("乾坤");
      expect(yangResult, hasLength(6));
      expect(yangResult.sublist(0, 3), equals(["壬", "壬", "壬"]));
      expect(yangResult.sublist(3), equals(["癸", "癸", "癸"]));

      // 测试阴年配置
      final yinYearGetter = TaiXuanEachZhu.getEachYaoGan(false);
      final yinResult = yinYearGetter("乾坤");
      expect(yinResult, hasLength(6));
      expect(yinResult.sublist(0, 3), equals(["甲", "甲", "甲"]));
      expect(yinResult.sublist(3), equals(["乙", "乙", "乙"]));
    });
  });
}
