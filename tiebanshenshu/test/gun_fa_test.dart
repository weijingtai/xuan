import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/four_zhu.dart';
import 'package:tiebanshenshu/service/gun_fa.dart';
import 'package:tiebanshenshu/service/four_gua/gun_fa_v2.dart';

void main() {
  group('八卦滚法计算器测试', () {
    late EightGuaGunFaCalculatorV2 calculator;
    late FourZhu testFourZhu;

    setUp(() {
      calculator = EightGuaGunFaCalculatorV2();
      testFourZhu = FourZhu(
        yearGanzhi: "丙戌",
        monthGanzhi: "庚寅",
        dayGanzhi: "丁亥",
        timeGanzhi: "辛亥",
      );
    });

    group('输入验证测试', () {
      test('应该拒绝无效的性别参数', () {
        expect(
          () => calculator.calculate(testFourZhu, "无效", "上"),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('应该拒绝无效的三元参数', () {
        expect(
          () => calculator.calculate(testFourZhu, "男", "无效"),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('应该接受有效的参数', () {
        expect(
          () => calculator.calculate(testFourZhu, "女", "下"),
          returnsNormally,
        );
      });
    });

    group('卦象转换器测试', () {
      late GuaConverter converter;

      setUp(() {
        converter = GuaConverter();
      });

      test('卦名转二进制列表', () {
        final result = converter.toBinaryList("乾坤");
        expect(result, equals([1, 1, 1, 0, 0, 0]));
      });

      test('二进制列表转卦名', () {
        final result = converter.fromBinaryList([1, 1, 1, 0, 0, 0]);
        expect(result, equals("乾坤"));
      });

      test('爻变功能', () {
        final original = [1, 1, 1, 0, 0, 0];
        final result = converter.changeYao(original, [0, 5]);
        expect(result, equals([0, 1, 1, 0, 0, 1]));
      });

      test('互卦计算', () {
        final result = converter.toHuGua("乾坤");
        // 乾坤的互卦应该是根据2、3、4爻和3、4、5爻计算
        expect(result.length, equals(2));
      });

      test('错卦计算', () {
        final result = converter.toCuoGua("乾坤");
        expect(result, equals("坤乾"));
      });
    });

    group('数字计算器测试', () {
      late NumberCalculator numberCalc;

      setUp(() {
        numberCalc = NumberCalculator();
      });

      test('变爻位置计算', () {
        expect(numberCalc.getBianYaoPositions(1), equals([5]));
        expect(numberCalc.getBianYaoPositions(7), equals([5, 2]));
        expect(numberCalc.getBianYaoPositions(0), equals([3, 0]));
      });

      test('卦的三个基本数计算', () {
        final (a, b, c) = numberCalc.getGuaThreeNumbers("巽艮");
        expect(a, equals(57));
        expect(b, equals(26));
        expect(c, equals(48));
      });

      test('条文列表计算', () {
        final result = numberCalc.calculateGuaTiaowenList(12, 34, 56);
        expect(result, equals([1234, 1256, 3412, 3456, 5612, 5634]));
      });

      test('基础变数计算', () {
        // 测试上元
        final (gan1, zhi1) = numberCalc.calculateBaseBianNumbers(
          9,
          8,
          true,
          "上",
          "男",
        );
        expect(gan1, equals(90));
        expect(zhi1, equals(8));

        // 测试下元
        final (gan2, zhi2) = numberCalc.calculateBaseBianNumbers(
          9,
          8,
          true,
          "下",
          "男",
        );
        expect(gan2, equals(9));
        expect(zhi2, equals(80));

        // 测试中元阳年男
        final (gan3, zhi3) = numberCalc.calculateBaseBianNumbers(
          9,
          8,
          true,
          "中",
          "男",
        );
        expect(gan3, equals(900));
        expect(zhi3, equals(80));
      });
    });

    group('卦生成器测试', () {
      late GuaGenerator generator;
      late GuaConverter converter;

      setUp(() {
        converter = GuaConverter();
        generator = GuaGenerator(converter);
      });

      test('应该生成八个卦', () {
        final result = generator.generateEightGua("乾坤", 123);
        expect(result.length, equals(8));
        for (final gua in result) {
          expect(gua.length, equals(2));
        }
      });
    });

    group('完整计算流程测试', () {
      test('应该返回正确数量的卦和条文数', () {
        final (guaList, tiaowenNumbers) = calculator.calculate(
          testFourZhu,
          "女",
          "下",
        );

        expect(guaList.length, equals(8));
        expect(tiaowenNumbers.length, equals(48)); // 8个卦 * 6个条文数

        // 验证每个卦都是有效的
        for (final gua in guaList) {
          expect(gua.length, equals(2));
        }
      });

      test('不同参数应该产生不同结果', () {
        final (guaList1, _) = calculator.calculate(testFourZhu, "男", "上");
        final (guaList2, _) = calculator.calculate(testFourZhu, "女", "下");
        expect(guaList1, isNot(equals(guaList2)));
      });
    });

    group('便利函数测试', () {
      test('eightGuaGunfa函数', () {
        final (guaList, tiaowenNumbers) = eightGuaGunfa(testFourZhu, "女", "下");
        expect(guaList.length, equals(8));
        expect(tiaowenNumbers.length, equals(48));
      });

      test('gunFaEachGuaThreeNumber函数', () {
        final (a, b, c) = gunFaEachGuaThreeNumber("坤坎");
        expect(a, equals(86));
        expect(b, equals(17));
        expect(c, equals(21));
      });
    });

    group('GuaGenerationStrategy测试', () {
      test('应该正确初始化策略', () {
        final strategy = GuaGenerationStrategy(1, "互", true);
        expect(strategy.order, equals(1));
        expect(strategy.guaType, equals("互"));
        expect(strategy.exchangeType, isTrue);
      });
    });
  });

  group('集成测试', () {
    test('测试函数应该正常运行', () {
      expect(() => testEightGuaGunFa(), returnsNormally);
    });
  });
}
