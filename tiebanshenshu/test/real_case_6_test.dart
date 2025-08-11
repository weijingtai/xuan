import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/four_zhu.dart';
import 'package:tiebanshenshu/service/real_case_6.dart';
import 'package:tiebanshenshu/utils/tiao_wen_calculator.dart';

void main() {
  group('Real Case 6 Tests', () {
    test('TiaoWenNumberCalculationStrategy calculation test', () {
      final fourZhu = FourZhu(
        yearGanzhi: '癸巳',
        monthGanzhi: '甲子',
        dayGanzhi: '丁酉',
        timeGanzhi: '癸卯',
      );

      final strategy = TiaoWenNumberCalculationStrategy(
        fourZhu: fourZhu,
        correctionKeNumber: 9193,
      );

      final res1 = TiaowenCalculator.calculateTiaowenNumberList96(
        strategy.firstNumber,
        4,
        withBaseNumber: true,
      ).toSet();

      final res2 = TiaowenCalculator.calculateTiaowenNumberList96(
        strategy.secondNumber,
        4,
        withBaseNumber: true,
      ).toSet();

      expect(
        res1,
        equals({11371, 11467, 11563, 11659, 11755, 11275, 11179, 11083, 10987}),
      );
      expect(
        res2,
        equals({10489, 10585, 10681, 10777, 10873, 10393, 10297, 10201, 10105}),
      );
    });

    test('TaiXuanEachZhu calculateTaixuanGanzhiSum test', () {
      // Test the static method for calculating taixuan ganzhi sum
      final sum = TaiXuanEachZhu.calculateTaixuanGanzhiSum('甲子');
      expect(sum, isA<int>());
    });

    test('TaiXuanEachZhu calculateEachEightGuaGanzhiSum test', () {
      // Test the static method for calculating eight gua ganzhi sum
      final ganzhiList = ['甲子', '乙丑', '丙寅'];
      final sum = TaiXuanEachZhu.calculateEachEightGuaGanzhiSum(ganzhiList);
      expect(sum, isA<int>());
    });

    test('getEachYaoGan function test for Yang year', () {
      final getEachYaoGan = TaiXuanEachZhu.getEachYaoGan(true);
      final result = getEachYaoGan('乾坤');
      expect(result, hasLength(6));
      expect(result.sublist(0, 3), equals(['壬', '壬', '壬']));
      expect(result.sublist(3, 6), equals(['癸', '癸', '癸']));
    });

    test('getEachYaoGan function test for Yin year', () {
      final getEachYaoGan = TaiXuanEachZhu.getEachYaoGan(false);
      final result = getEachYaoGan('乾坤');
      expect(result, hasLength(6));
      expect(result.sublist(0, 3), equals(['甲', '甲', '甲']));
      expect(result.sublist(3, 6), equals(['乙', '乙', '乙']));
    });
  });
}
