import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/four_zhu.dart';
import 'package:tiebanshenshu/service/real_cast_9.dart';

void main() {
  group('TiaoWenNumberCalculationStrategy Tests', () {
    late TiaoWenNumberCalculationStrategy strategy;
    late FourZhu fourZhu;

    setUp(() {
      // 使用测试数据：癸巳 甲子 丁酉 癸卯
      fourZhu = FourZhu(
        yearGanzhi: "癸巳",
        monthGanzhi: "甲子",
        dayGanzhi: "丁酉",
        timeGanzhi: "癸卯",
      );
      strategy = TiaoWenNumberCalculationStrategy(fourZhu);
    });

    test('基本数值计算', () {
      expect(strategy.yuanHuiNumber, equals(9018));
      expect(strategy.yunShiNumber, equals(2111));
      expect(strategy.originalPrimaryNumber, equals(2018));
    });

    test('四个基础数计算', () {
      // 基础数一
      expect(
        strategy.primaryBaseNumber,
        equals(strategy.originalPrimaryNumber),
      );

      // 基础数二 = 基础数一 + 日干支合数
      int expectedBaseNumber2 =
          strategy.primaryBaseNumber +
          (fourZhu.dayGanTaixuanNum * 10 + fourZhu.dayZhiTaixuanNum);
      expect(strategy.baseNumber2, equals(expectedBaseNumber2));

      // 基础数三 = 运世基本数 + 年干太玄千位
      int expectedBaseNumber3 =
          strategy.yunShiNumber + fourZhu.yearGanTaixuanNum * 1000;
      expect(strategy.baseNumber3, equals(expectedBaseNumber3));

      // 基础数四 = 基础数三 + 日干支合数
      int expectedBaseNumber4 =
          strategy.baseNumber3 +
          (fourZhu.dayGanTaixuanNum * 10 + fourZhu.dayZhiTaixuanNum);
      expect(strategy.baseNumber4, equals(expectedBaseNumber4));
    });

    test('基础数一的条文数计算', () {
      // 基础数一 + 月干(百位数)
      expect(
        strategy.tiaowenNumber1,
        equals(strategy.primaryBaseNumber + fourZhu.monthGanTaixuanNum * 100),
      );

      // 基础数一 + 月支(百位数)
      expect(
        strategy.tiaowenNumber2,
        equals(strategy.primaryBaseNumber + fourZhu.monthZhiTaixuanNum * 100),
      );
    });

    test('基础数二的条文数计算', () {
      // 基础数二 + 时干个位
      expect(
        strategy.tiaowenNumber3,
        equals(strategy.baseNumber2 + fourZhu.timeGanTaixuanNum),
      );

      // 基础数二 + 时支个位
      expect(
        strategy.tiaowenNumber4,
        equals(strategy.baseNumber2 + fourZhu.timeZhiTaixuanNum),
      );
    });

    test('基础数三的条文数计算', () {
      // 基础数三 + 月干百位
      expect(
        strategy.tiaowenNumber5,
        equals(strategy.baseNumber3 + fourZhu.monthGanTaixuanNum * 100),
      );

      // 基础数三 + 月支百位
      expect(
        strategy.tiaowenNumber6,
        equals(strategy.baseNumber3 + fourZhu.monthZhiTaixuanNum * 100),
      );
    });

    test('基础数四的条文数计算', () {
      // 基础数四 + 时干(个位数)
      expect(
        strategy.tiaowenNumber7,
        equals(strategy.baseNumber4 + fourZhu.timeGanTaixuanNum),
      );

      // 基础数四 + 时支(个位数)
      expect(
        strategy.tiaowenNumber8,
        equals(strategy.baseNumber4 + fourZhu.timeZhiTaixuanNum),
      );
    });

    test('设置自定义基础数', () {
      strategy.setPrimaryBaseNumber(2111, 3);
      strategy.setSecondaryBaseNumber(1500, 2);

      expect(strategy.primaryBaseNumber, equals(2111));
      expect(strategy.primaryBaseTimes, equals(3));
      expect(strategy.secondaryBaseNumber, equals(1500));
      expect(strategy.secondaryBaseTimes, equals(2));
    });

    test('条文数列表生成', () {
      List<int> previousList = strategy.previousTiaowenNumberList(1000, 3, 30);
      expect(previousList, equals([1000, 970, 940]));

      List<int> nextList = strategy.nextTiaowenNumberList(1000, 3, 30);
      expect(nextList, equals([1000, 1030, 1060]));
    });

    test('获取所有条文数', () {
      List<int> allNumbers = strategy.allTiaowenNumbers;
      expect(allNumbers.length, equals(8));
      expect(allNumbers[0], equals(strategy.tiaowenNumber1));
      expect(allNumbers[7], equals(strategy.tiaowenNumber8));
    });

    test('四柱基础数列表', () {
      List<int> baseNumbers = strategy.fourZhuBaseNumberList;
      expect(baseNumbers.length, equals(4));
      expect(baseNumbers[0], equals(strategy.yuanNumber));
      expect(baseNumbers[1], equals(strategy.monthNumber));
      expect(baseNumbers[2], equals(strategy.dayNumber));
      expect(baseNumbers[3], equals(strategy.timeNumber));
    });

    test('所有基础数列表', () {
      List<int> allBaseNumbers = strategy.allBaseNumbers;
      expect(allBaseNumbers.length, equals(4));
      expect(allBaseNumbers[0], equals(strategy.primaryBaseNumber));
      expect(allBaseNumbers[1], equals(strategy.baseNumber2));
      expect(allBaseNumbers[2], equals(strategy.baseNumber3));
      expect(allBaseNumbers[3], equals(strategy.baseNumber4));
    });

    group('增量测试 - 乙亥 丁亥 壬子 辛亥', () {
      late TiaoWenNumberCalculationStrategy strategy;
      late FourZhu fourZhu;

      setUp(() {
        // 使用测试数据：乙亥 丁亥 壬子 辛亥
        fourZhu = FourZhu(
          yearGanzhi: "乙亥",
          monthGanzhi: "丁亥",
          dayGanzhi: "壬子",
          timeGanzhi: "辛亥",
        );
        strategy = TiaoWenNumberCalculationStrategy(fourZhu);
      });

      test('基本数值验证', () {
        // 元数12，运数15，会数10，世数11
        expect(strategy.yuanNumber, equals(12), reason: '元数应为12');
        expect(strategy.monthNumber, equals(10), reason: '会数应为10');
        expect(strategy.dayNumber, equals(15), reason: '运数应为15');
        expect(strategy.timeNumber, equals(11), reason: '世数应为11');
      });

      test('元会基本数和运世基本数验证', () {
        // 元会基本数 1210 运世基本数5111
        expect(strategy.yuanHuiNumber, equals(1210), reason: '元会基本数应为1210');
        expect(strategy.yunShiNumber, equals(5111), reason: '运世基本数应为5111');
      });

      test('基本数一验证', () {
        // 基本数一 9210
        expect(strategy.primaryBaseNumber, equals(9210), reason: '基本数一应为9210');

        // 基本数一 + 百位月干 = 9810
        expect(
          strategy.tiaowenNumber1,
          equals(9810),
          reason: '基本数一 + 百位月干应为9810',
        );

        // 基本数一 + 百位月支 = 9610
        expect(
          strategy.tiaowenNumber2,
          equals(9610),
          reason: '基本数一 + 百位月支应为9610',
        );
      });

      test('基本数二验证', () {
        // 基本数二 9279（基本数一 + 十位日干+个位日支）
        expect(strategy.baseNumber2, equals(9279), reason: '基本数二应为9279');

        // 基本数二 + 个位时干 = 9286
        expect(
          strategy.tiaowenNumber3,
          equals(9286),
          reason: '基本数二 + 个位时干应为9286',
        );

        // 基本数二 + 个位时支 = 9283
        expect(
          strategy.tiaowenNumber4,
          equals(9283),
          reason: '基本数二 + 个位时支应为9283',
        );
      });

      test('基本数三验证', () {
        // 基本数三 1111
        expect(strategy.baseNumber3, equals(1111), reason: '基本数三应为1111');

        // 基本数三 + 百位月干 = 1711
        expect(
          strategy.tiaowenNumber5,
          equals(1711),
          reason: '基本数三 + 百位月干应为1711',
        );

        // 基本数三 + 百位月支 = 1511
        expect(
          strategy.tiaowenNumber6,
          equals(1511),
          reason: '基本数三 + 百位月支应为1511',
        );
      });

      test('基本数四验证', () {
        // 基本数四 1180 （基本数三+十位日干+个位日支）
        expect(strategy.baseNumber4, equals(1180), reason: '基本数四应为1180');

        // 基本数四 + 个位时干 = 1187
        expect(
          strategy.tiaowenNumber7,
          equals(1187),
          reason: '基本数四 + 个位时干应为1187',
        );

        // 基本数四 + 个位时支 = 1184
        expect(
          strategy.tiaowenNumber8,
          equals(1184),
          reason: '基本数四 + 个位时支应为1184',
        );
      });

      test('四柱太玄数验证', () {
        // 验证四柱的太玄数是否正确
        List<int> baseNumbers = strategy.fourZhuBaseNumberList;
        expect(
          baseNumbers,
          equals([12, 10, 15, 11]),
          reason: '四柱基础数列表应为[12, 10, 15, 11]',
        );
      });

      test('完整条文数列表验证', () {
        List<int> allNumbers = strategy.allTiaowenNumbers;
        List<int> expected = [9810, 9610, 9286, 9283, 1711, 1511, 1187, 1184];
        expect(allNumbers, equals(expected), reason: '所有条文数应匹配预期值');
      });
    });
  });
}
