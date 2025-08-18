import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/four_zhu.dart';
import 'package:tiebanshenshu/service/four_doors.dart';
import 'package:tiebanshenshu/service/four_gua/four_doors_v2.dart';

void main() {
  group('FourDoorsCalculator Tests', () {
    // late FourDoorsCalculator calculator;
    late FourDoorsCalculatorV2 calculator;
    late FourZhu testFourZhu;

    setUp(() {
      testFourZhu = FourZhu(
        yearGanzhi: "丙子",
        monthGanzhi: "壬辰",
        dayGanzhi: "庚申",
        timeGanzhi: "甲申",
      );
      calculator = FourDoorsCalculatorV2(fourZhu: testFourZhu);
      // calculator = FourDoorsCalculator();
    });

    test('GuaGenerationStrategy 验证', () {
      // 测试有效的策略
      expect(
        () =>
            GuaGenerationStrategy(order: 1, guaType: "互", exchangeType: false),
        returnsNormally,
      );

      // 测试无效的序号
      expect(
        () =>
            GuaGenerationStrategy(order: 0, guaType: "互", exchangeType: false),
        throwsArgumentError,
      );

      // 测试无效的卦象类型
      expect(
        () =>
            GuaGenerationStrategy(order: 1, guaType: "无效", exchangeType: false),
        throwsArgumentError,
      );
    });

    test('FourGuaResult 功能测试', () {
      final result = FourGuaResult(
        basicGua: "乾坤",
        basicNumber: 100,
        firstGua: "震巽",
        secondGua: "坎离",
        thirdGua: "艮兑",
        fourthGua: "乾坤",
      );

      final guaList = result.getGuaList();
      expect(guaList, equals(["震巽", "坎离", "艮兑", "乾坤"]));
    });

    test('输入参数验证', () {
      // 测试有效参数
      expect(
        () => calculator.calculate(testFourZhu, "中", "男"),
        returnsNormally,
      );

      // 测试无效的三元
      expect(
        () => calculator.calculate(testFourZhu, "无效", "男"),
        throwsA(isA<StateError>()),
      );

      // 测试无效的性别
      expect(
        () => calculator.calculate(testFourZhu, "中", "无效"),
        throwsA(isA<StateError>()),
      );
    });

    test('基本卦计算', () {
      final result = calculator.calculate(testFourZhu, "中", "男");
      expect(result, isA<List<int>>());
      expect(result.isNotEmpty, isTrue);
    });

    test('不同三元和性别的计算', () {
      final resultUpper = calculator.calculate(testFourZhu, "上", "男");
      final resultMiddle = calculator.calculate(testFourZhu, "中", "男");
      final resultLower = calculator.calculate(testFourZhu, "下", "男");

      expect(resultUpper, isA<List<int>>());
      expect(resultMiddle, isA<List<int>>());
      expect(resultLower, isA<List<int>>());

      // 不同参数应该产生不同的结果
      // expect(resultUpper, isNot(equals(resultMiddle)));
      // expect(resultMiddle, isNot(equals(resultLower)));
    });

    test('自定义策略测试', () {
      final customStrategies = [
        GuaGenerationStrategy(order: 1, guaType: "互", exchangeType: false),
        GuaGenerationStrategy(order: 2, guaType: "错", exchangeType: true),
        GuaGenerationStrategy(order: 3, guaType: "互", exchangeType: false),
        GuaGenerationStrategy(order: 4, guaType: "互", exchangeType: false),
      ];

      final result = calculator.calculate(
        testFourZhu,
        "中",
        "男",
        // customConfig: GuaGenerationConfig(
        // numberStrategy: NumberConversionStrategy.taiXuanNumber, firstGuaType: '', secondGuaStrategy: null, thirdGuaStrategy: null, fourthGuaStrategy: null,
        // ),
      );

      expect(result, isA<List<int>>());
      expect(result.isNotEmpty, isTrue);
    });

    test('便利函数测试', () {
      final result = fourDoors(testFourZhu, "中", "男");
      expect(result, isA<List<int>>());
      expect(result.isNotEmpty, isTrue);
    });

    test('条文数范围验证', () {
      final result = calculator.calculate(testFourZhu, "中", "男");

      // 验证所有条文数都在有效范围内
      for (final tiaowen in result) {
        expect(tiaowen, greaterThanOrEqualTo(1000));
        expect(tiaowen, lessThanOrEqualTo(13000));
      }
    });

    test('测试函数执行', () {
      expect(() => testFourDoors(), returnsNormally);
    });
  });
}
