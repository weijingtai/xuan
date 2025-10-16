import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/four_zhu.dart';
import 'package:tiebanshenshu/service/real_case_8.dart';

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

    test('基础数一的条文数计算', () {
      // 测试基础数一 + 月干(百位数)
      expect(
        strategy.tiaowenNumber1,
        equals(strategy.primaryBaseNumber + fourZhu.monthGanTaixuanNum * 100),
      );

      // 测试基础数一 + 日干(十位数)
      expect(
        strategy.tiaowenNumber2,
        equals(strategy.primaryBaseNumber + fourZhu.dayGanTaixuanNum * 10),
      );

      // 测试基础数一 + 时干(个位数)
      expect(
        strategy.tiaowenNumber3,
        equals(strategy.primaryBaseNumber + fourZhu.timeGanTaixuanNum),
      );

      // 测试基础数一 + 时支(个位数)
      expect(
        strategy.tiaowenNumber4,
        equals(strategy.primaryBaseNumber + fourZhu.timeZhiTaixuanNum),
      );
    });

    test('基础数二的条文数计算', () {
      // 测试基础数二 + 月干(百位数)
      expect(
        strategy.tiaowenNumber5,
        equals(strategy.secondaryBaseNumber + fourZhu.monthGanTaixuanNum * 100),
      );

      // 测试基础数二 + 日干(十位数)
      expect(
        strategy.tiaowenNumber6,
        equals(strategy.secondaryBaseNumber + fourZhu.dayGanTaixuanNum * 10),
      );

      // 测试基础数二 + 时干(个位数)
      expect(
        strategy.tiaowenNumber7,
        equals(strategy.secondaryBaseNumber + fourZhu.timeGanTaixuanNum),
      );

      // 测试基础数二 + 日干(个位数)
      expect(
        strategy.tiaowenNumber8,
        equals(strategy.secondaryBaseNumber + fourZhu.dayGanTaixuanNum),
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
  });

  // 新增测试组：基于用户提供的测试数据 "乙亥 丁亥 壬子 辛亥"
  group('TiaoWenNumberCalculationStrategy - 乙亥丁亥壬子辛亥 测试', () {
    late TiaoWenNumberCalculationStrategy strategy;
    late FourZhu fourZhu;

    setUp(() {
      // 使用用户提供的测试数据：乙亥 丁亥 壬子 辛亥
      fourZhu = FourZhu(
        yearGanzhi: "乙亥",
        monthGanzhi: "丁亥",
        dayGanzhi: "壬子",
        timeGanzhi: "辛亥",
      );
      strategy = TiaoWenNumberCalculationStrategy(fourZhu);
    });

    test('基本数值验证 - 乙亥丁亥壬子辛亥', () {
      // 验证元数、会数、运数、世数
      expect(strategy.yuanNumber, equals(12), reason: '元数应为12');
      expect(strategy.monthNumber, equals(10), reason: '会数应为10');
      expect(strategy.dayNumber, equals(15), reason: '运数应为15');
      expect(strategy.timeNumber, equals(11), reason: '世数应为11');

      // 验证元会基本数和运世基本数
      expect(strategy.yuanHuiNumber, equals(1210), reason: '元会基本数应为1210');
      expect(strategy.yunShiNumber, equals(5111), reason: '运世基本数应为5111');

      // 验证基本数一和基本数二
      expect(
        strategy.originalPrimaryNumber,
        equals(9210),
        reason: '基本数一应为9210',
      );
      expect(
        strategy.originalSecondaryNumber,
        equals(1111),
        reason: '基本数二应为1111',
      );
    });

    test('基础数一条文数计算验证 - 乙亥丁亥壬子辛亥', () {
      // 基础数一 + 月干(百位数) = 条文数
      expect(
        strategy.tiaowenNumber1,
        equals(9810),
        reason: '基础数一 + 百位月干太玄 = 9210 + 600 = 9810',
      );

      // 基础数一 + 日干(十位数) = 条文数
      expect(
        strategy.tiaowenNumber2,
        equals(9270),
        reason: '基础数一 + 十位日干太玄 = 9210 + 60 = 9270',
      );

      // 基础数一 + 时干(个位数) = 条文数
      expect(
        strategy.tiaowenNumber3,
        equals(9217),
        reason: '基础数一 + 个位时干太玄 = 9210 + 7 = 9217',
      );

      // 基础数一 + 时支(个位数) = 条文数
      expect(
        strategy.tiaowenNumber4,
        equals(9214),
        reason: '基础数一 + 个位时支太玄 = 9210 + 4 = 9214',
      );
    });

    test('基础数二条文数计算验证 - 乙亥丁亥壬子辛亥', () {
      // 基础数二 + 月干(百位数) = 条文数
      expect(
        strategy.tiaowenNumber5,
        equals(1711),
        reason: '基础数二 + 百位月干太玄 = 1111 + 600 = 1711',
      );

      // 基础数二 + 日干(十位数) = 条文数
      expect(
        strategy.tiaowenNumber6,
        equals(1171),
        reason: '基础数二 + 十位日干太玄 = 1111 + 60 = 1171',
      );

      // 基础数二 + 时干(个位数) = 条文数
      expect(
        strategy.tiaowenNumber7,
        equals(1118),
        reason: '基础数二 + 个位时干太玄 = 1111 + 7 = 1118',
      );

      // 基础数二 + 日干(个位数) = 条文数
      expect(
        strategy.tiaowenNumber8,
        equals(1117),
        reason: '基础数二 + 个位日干太玄 = 1111 + 6 = 1117',
      );
    });

    test('四柱太玄数验证 - 乙亥丁亥壬子辛亥', () {
      // 验证各干支的太玄数
      expect(fourZhu.yearGanTaixuanNum, equals(8), reason: '乙干太玄数应为8');
      expect(fourZhu.yearZhiTaixuanNum, equals(4), reason: '亥支太玄数应为4');
      expect(fourZhu.monthGanTaixuanNum, equals(6), reason: '丁干太玄数应为6');
      expect(fourZhu.monthZhiTaixuanNum, equals(4), reason: '亥支太玄数应为4');
      expect(fourZhu.dayGanTaixuanNum, equals(6), reason: '壬干太玄数应为6');
      expect(fourZhu.dayZhiTaixuanNum, equals(9), reason: '子支太玄数应为9');
      expect(fourZhu.timeGanTaixuanNum, equals(7), reason: '辛干太玄数应为7');
      expect(fourZhu.timeZhiTaixuanNum, equals(4), reason: '亥支太玄数应为4');
    });

    test('完整条文数列表验证 - 乙亥丁亥壬子辛亥', () {
      List<int> expectedTiaowenNumbers = [
        9810, // 基础数一 + 百位月干太玄
        9270, // 基础数一 + 十位日干太玄
        9217, // 基础数一 + 个位时干太玄
        9214, // 基础数一 + 个位时支太玄
        1711, // 基础数二 + 百位月干太玄
        1171, // 基础数二 + 十位日干太玄
        1118, // 基础数二 + 个位时干太玄
        1117, // 基础数二 + 个位日干太玄
      ];

      List<int> actualTiaowenNumbers = strategy.allTiaowenNumbers;
      expect(
        actualTiaowenNumbers,
        equals(expectedTiaowenNumbers),
        reason: '所有条文数应与预期值匹配',
      );
    });
  });
}
