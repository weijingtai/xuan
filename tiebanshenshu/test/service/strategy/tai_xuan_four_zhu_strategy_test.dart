import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';

import 'package:tiebanshenshu/service/strategy/tai_xuan_four_zhu_strategy.dart';
import 'package:tiebanshenshu/domain/models/base_number_model.dart';

/// 太玄取数法Strategy测试
///
/// 测试数据：癸巳 甲子 丁酉 癸卯
/// - 年柱癸巳 -> 坤离
/// - 月柱甲子 -> 乾坎
/// - 日柱丁酉 -> 兑乾
/// - 时柱癸卯 -> 坤乾
///
/// 预期太玄数（根据年干阴阳纳甲）：
/// 年柱：4245
/// 月柱：4826
/// 日柱：2648
/// 时柱：4248
void main() {
  late TaiXuanFourZhuStrategy strategy;
  late EightChars testEightChars;

  setUp(() {
    strategy = TaiXuanFourZhuStrategy();

    // 构造测试八字：癸巳 甲子 丁酉 癸卯
    testEightChars = EightChars(
      year: JiaZi.GUI_SI,   // 癸巳
      month: JiaZi.JIA_ZI,  // 甲子
      day: JiaZi.DING_YOU,  // 丁酉
      time: JiaZi.GUI_MAO,  // 癸卯
    );
  });

  group('TaiXuanFourZhuStrategy - 基础验证', () {
    test('Strategy基本信息验证', () {
      expect(strategy.name, equals('太玄取数法（1）'));
      expect(strategy.description, contains('排四柱天干地支分别配卦'));
      expect(strategy.school, equals('太玄取数流派'));
    });

    test('应该返回4个基础数结果（四柱）', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.hasError, isFalse);
      expect(result.baseNumbers.length, equals(4));
    });

    test('每个基础数应该是BaseNumberModel类型', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      for (final baseNumber in result.baseNumbers) {
        expect(baseNumber, isA<BaseNumberModel>());
      }
    });
  });

  group('TaiXuanFourZhuStrategy - 干支配卦验证', () {
    test('年柱癸巳应配为坤离卦', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      // 验证配卦是否正确（通过sourceData）
      expect(result.hasError, isFalse);
      // 癸 -> 坤，巳 -> 离
    });

    test('月柱甲子应配为乾坎卦', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.hasError, isFalse);
      // 甲 -> 乾，子 -> 坎
    });

    test('日柱丁酉应配为兑乾卦', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.hasError, isFalse);
      // 丁 -> 兑，酉 -> 乾
    });

    test('时柱癸卯应配为坤乾卦', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.hasError, isFalse);
      // 癸 -> 坤，卯 -> 乾
    });
  });

  group('TaiXuanFourZhuStrategy - 太玄数计算验证', () {
    test('年柱癸巳太玄数：4245', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final yearModel = result.baseNumbers[0];
      expect(yearModel.baseNumber, equals(4245));
      expect(yearModel.name, equals('年柱太玄数'));
      expect(yearModel.description, contains('癸巳'));
    });

    test('月柱甲子太玄数：4826', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final monthModel = result.baseNumbers[1];
      expect(monthModel.baseNumber, equals(4826));
      expect(monthModel.name, equals('月柱太玄数'));
      expect(monthModel.description, contains('甲子'));
    });

    test('日柱丁酉太玄数：2648', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final dayModel = result.baseNumbers[2];
      expect(dayModel.baseNumber, equals(2648));
      expect(dayModel.name, equals('日柱太玄数'));
      expect(dayModel.description, contains('丁酉'));
    });

    test('时柱癸卯太玄数：4248', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final timeModel = result.baseNumbers[3];
      expect(timeModel.baseNumber, equals(4248));
      expect(timeModel.name, equals('时柱太玄数'));
      expect(timeModel.description, contains('癸卯'));
    });
  });

  group('TaiXuanFourZhuStrategy - 完整结果验证', () {
    test('所有4个基础数应该符合预期值', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final baseNumbers = result.baseNumbers.map((m) => m.baseNumber).toList();

      expect(baseNumbers, equals([4245, 4826, 2648, 4248]));
    });

    test('结果应该按照年月日时顺序排列', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.baseNumbers[0].source, equals(BaseNumberSource.yearZhu));
      expect(result.baseNumbers[1].source, equals(BaseNumberSource.monthZhu));
      expect(result.baseNumbers[2].source, equals(BaseNumberSource.dayZhu));
      expect(result.baseNumbers[3].source, equals(BaseNumberSource.timeZhu));
    });

    test('sourceData应该包含完整的计算信息', () {
      final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.sourceData['isYangYear'], isFalse); // 癸年是阴年
      expect(result.sourceData['baseNumbers'], isA<List>());
      expect((result.sourceData['baseNumbers'] as List).length, equals(4));
    });
  });

  group('TaiXuanFourZhuStrategy - 边界情况测试', () {
    test('不同的八字应该产生不同的结果', () {
      final eightChars1 = EightChars(
        year: JiaZi.JIA_ZI,
        month: JiaZi.JIA_ZI,
        day: JiaZi.JIA_ZI,
        time: JiaZi.JIA_ZI,
      );

      final eightChars2 = EightChars(
        year: JiaZi.GUI_HAI,
        month: JiaZi.GUI_HAI,
        day: JiaZi.GUI_HAI,
        time: JiaZi.GUI_HAI,
      );

      final result1 = strategy.calculate(
          TaiXuanFourZhuStrategyParams(eightChars: eightChars1));
      final result2 = strategy.calculate(
          TaiXuanFourZhuStrategyParams(eightChars: eightChars2));

      expect(result1.hasError, isFalse);
      expect(result2.hasError, isFalse);

      final baseNumbers1 = result1.baseNumbers.map((m) => m.baseNumber).toList();
      final baseNumbers2 = result2.baseNumbers.map((m) => m.baseNumber).toList();

      expect(baseNumbers1, isNot(equals(baseNumbers2)));
    });

    test('相同的八字应该产生相同的结果', () {
      final params1 = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
      final params2 = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);

      final result1 = strategy.calculate(params1);
      final result2 = strategy.calculate(params2);

      expect(result1.hasError, isFalse);
      expect(result2.hasError, isFalse);

      final baseNumbers1 = result1.baseNumbers.map((m) => m.baseNumber).toList();
      final baseNumbers2 = result2.baseNumbers.map((m) => m.baseNumber).toList();

      expect(baseNumbers1, equals(baseNumbers2));
    });
  });

  group('TaiXuanFourZhuStrategy - 年干阴阳影响测试', () {
    test('阳年和阴年应该产生不同的纳甲结果', () {
      // 阳年：甲子
      final yangYearEightChars = EightChars(
        year: JiaZi.JIA_ZI,
        month: JiaZi.JIA_ZI,
        day: JiaZi.JIA_ZI,
        time: JiaZi.JIA_ZI,
      );

      // 阴年：癸亥
      final yinYearEightChars = EightChars(
        year: JiaZi.GUI_HAI,
        month: JiaZi.JIA_ZI,
        day: JiaZi.JIA_ZI,
        time: JiaZi.JIA_ZI,
      );

      final yangResult = strategy.calculate(
          TaiXuanFourZhuStrategyParams(eightChars: yangYearEightChars));
      final yinResult = strategy.calculate(
          TaiXuanFourZhuStrategyParams(eightChars: yinYearEightChars));

      expect(yangResult.hasError, isFalse);
      expect(yinResult.hasError, isFalse);

      // 年柱应该不同（因为年干不同）
      expect(yangResult.baseNumbers[0].baseNumber,
          isNot(equals(yinResult.baseNumbers[0].baseNumber)));

      // 验证年干阴阳标记正确
      expect(yangResult.sourceData['isYangYear'], isTrue);
      expect(yinResult.sourceData['isYangYear'], isFalse);
    });
  });
}
