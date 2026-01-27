import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/four_zhu.dart';
import 'package:tiebanshenshu/service/real_case_7.dart';

void main() {
  group('Real Case 7 Tests', () {
    test('TiaoWenNumberCalculationStrategy calculation test', () {
      final fourZhu = FourZhu(
        yearGanzhi: '癸巳',
        monthGanzhi: '甲子',
        dayGanzhi: '丁酉',
        timeGanzhi: '癸卯',
      );

      final strategy = TiaoWenNumberCalculationStrategy(fourZhu);

      expect(strategy.yuanHuiNumber, equals(9018));
      expect(strategy.yunShiNumber, equals(2111));
      expect(strategy.originalPrimaryNumber, equals(2018));

      expect(strategy.tiaowenNumber1, equals(2918));
      expect(strategy.tiaowenNumber2, equals(2918));
      expect(strategy.tiaowenNumber3, equals(2084));
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

    test('previousTiaowenNumberList test', () {
      final fourZhu = FourZhu(
        yearGanzhi: '癸巳',
        monthGanzhi: '甲子',
        dayGanzhi: '丁酉',
        timeGanzhi: '癸卯',
      );

      final strategy = TiaoWenNumberCalculationStrategy(fourZhu);
      final previousNumbers = strategy.previousTiaowenNumberList(1000, 3);

      expect(previousNumbers, hasLength(3));
      expect(previousNumbers[0], equals(1000));
      expect(previousNumbers[1], equals(969));
      expect(previousNumbers[2], equals(938));
    });

    test('nextTiaowenNumberList test', () {
      final fourZhu = FourZhu(
        yearGanzhi: '癸巳',
        monthGanzhi: '甲子',
        dayGanzhi: '丁酉',
        timeGanzhi: '癸卯',
      );

      final strategy = TiaoWenNumberCalculationStrategy(fourZhu);
      final nextNumbers = strategy.nextTiaowenNumberList(1000, 3);

      expect(nextNumbers, hasLength(3));
      expect(nextNumbers[0], equals(1000));
      expect(nextNumbers[1], equals(1031));
      expect(nextNumbers[2], equals(1062));
    });

    test('setPrimaryBaseNumber test', () {
      final fourZhu = FourZhu(
        yearGanzhi: '癸巳',
        monthGanzhi: '甲子',
        dayGanzhi: '丁酉',
        timeGanzhi: '癸卯',
      );

      final strategy = TiaoWenNumberCalculationStrategy(fourZhu);
      strategy.setPrimaryBaseNumber(2111, 3);

      expect(strategy.primaryBaseNumber, equals(2111));
      expect(strategy.primaryBaseTimes, equals(3));
    });

    test('setSecondaryBaseNumber test', () {
      final fourZhu = FourZhu(
        yearGanzhi: '癸巳',
        monthGanzhi: '甲子',
        dayGanzhi: '丁酉',
        timeGanzhi: '癸卯',
      );

      final strategy = TiaoWenNumberCalculationStrategy(fourZhu);
      strategy.setSecondaryBaseNumber(1500, 2);

      expect(strategy.secondaryBaseNumber, equals(1500));
      expect(strategy.secondaryBaseTimes, equals(2));
    });
  });
}
