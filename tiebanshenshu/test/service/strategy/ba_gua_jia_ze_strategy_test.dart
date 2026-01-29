import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';

import 'package:tiebanshenshu/service/strategy/ba_gua_jia_ze_strategy.dart';
import 'package:tiebanshenshu/domain/models/ba_gua_jia_ze_base_number_model.dart';

/// 八卦加则Strategy测试
///
/// 测试数据：癸未 庚申 丁未 丙午
/// - 年柱癸未 -> 坤艮
/// - 月柱庚申 -> 震乾
/// - 日柱丁未 -> 兑艮
/// - 时柱丙午 -> 艮离
///
/// 实际测试结果（基于代码实际输出）：
/// 爻序法：2472, 3384, 7352, 8351
/// 纳甲法：2712, 3624, 7802, 8531
void main() {
  late BaGuaJiaZeStrategy strategy;
  late EightChars testEightChars;

  setUp(() {
    strategy = BaGuaJiaZeStrategy();

    // 构造测试八字：癸未 庚申 丁未 丙午
    testEightChars = EightChars(
      year: JiaZi.GUI_WEI,    // 癸未
      month: JiaZi.GENG_SHEN, // 庚申
      day: JiaZi.DING_WEI,    // 丁未
      time: JiaZi.BING_WU,    // 丙午
    );
  });

  group('BaGuaJiaZeStrategy - 基础验证', () {
    test('Strategy基本信息验证', () {
      expect(strategy.name, equals('八卦加则取数法'));
      expect(strategy.description, contains('排四柱天干地支分别配卦'));
      expect(strategy.school, equals('八卦加则流派'));
    });

    test('应该返回8个基础数结果（4柱 × 2方法）', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.hasError, isFalse);
      expect(result.baseNumbers.length, equals(8));
    });

    test('每个基础数应该是BaGuaJiaZeBaseNumberModel类型', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      for (final baseNumber in result.baseNumbers) {
        expect(baseNumber, isA<BaGuaJiaZeBaseNumberModel>());
      }
    });
  });

  group('BaGuaJiaZeStrategy - 干支配卦验证', () {
    test('年柱癸未应配为坤艮卦', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      // 找到年柱的结果
      final yearResults = result.baseNumbers
          .where((model) => (model as BaGuaJiaZeBaseNumberModel).pillarName == '年柱')
          .cast<BaGuaJiaZeBaseNumberModel>()
          .toList();

      expect(yearResults.length, equals(2)); // 爻序法 + 纳甲法

      for (final yearModel in yearResults) {
        expect(yearModel.upperGua, equals(Enum8Gua.Kun));  // 癸 -> 坤
        expect(yearModel.lowerGua, equals(Enum8Gua.Gen));  // 未 -> 艮
        expect(yearModel.upperGuaNumber, equals(2));       // 坤后天数=2
        expect(yearModel.lowerGuaNumber, equals(8));       // 艮后天数=8
      }
    });

    test('月柱庚申应配为震乾卦', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final monthResults = result.baseNumbers
          .where((model) => (model as BaGuaJiaZeBaseNumberModel).pillarName == '月柱')
          .cast<BaGuaJiaZeBaseNumberModel>()
          .toList();

      expect(monthResults.length, equals(2));

      for (final monthModel in monthResults) {
        expect(monthModel.upperGua, equals(Enum8Gua.Zhen)); // 庚 -> 震
        expect(monthModel.lowerGua, equals(Enum8Gua.Qian)); // 申 -> 乾
        expect(monthModel.upperGuaNumber, equals(3));       // 震后天数=3
        expect(monthModel.lowerGuaNumber, equals(6));       // 乾后天数=6
      }
    });

    test('日柱丁未应配为兑艮卦', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final dayResults = result.baseNumbers
          .where((model) => (model as BaGuaJiaZeBaseNumberModel).pillarName == '日柱')
          .cast<BaGuaJiaZeBaseNumberModel>()
          .toList();

      expect(dayResults.length, equals(2));

      for (final dayModel in dayResults) {
        expect(dayModel.upperGua, equals(Enum8Gua.Dui));  // 丁 -> 兑
        expect(dayModel.lowerGua, equals(Enum8Gua.Gen));  // 未 -> 艮
        expect(dayModel.upperGuaNumber, equals(7));       // 兑后天数=7
        expect(dayModel.lowerGuaNumber, equals(8));       // 艮后天数=8
      }
    });

    test('时柱丙午应配为艮离卦', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final timeResults = result.baseNumbers
          .where((model) => (model as BaGuaJiaZeBaseNumberModel).pillarName == '时柱')
          .cast<BaGuaJiaZeBaseNumberModel>()
          .toList();

      expect(timeResults.length, equals(2));

      for (final timeModel in timeResults) {
        expect(timeModel.upperGua, equals(Enum8Gua.Gen));  // 丙 -> 艮
        expect(timeModel.lowerGua, equals(Enum8Gua.Li));   // 午 -> 离
        expect(timeModel.upperGuaNumber, equals(8));       // 艮后天数=8
        expect(timeModel.lowerGuaNumber, equals(9));       // 离后天数=9
      }
    });
  });

  group('BaGuaJiaZeStrategy - 爻序法测试', () {
    test('年柱癸未爻序法：2000+480-8=2472', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final yearYaoSeq = result.baseNumbers
          .cast<BaGuaJiaZeBaseNumberModel>()
          .firstWhere((model) =>
              model.pillarName == '年柱' && model.method == '爻序法');

      expect(yearYaoSeq.baseNumber, equals(2472));
      expect(yearYaoSeq.yaoSum, equals(480));
      expect(yearYaoSeq.upperGuaNumber, equals(2));
      expect(yearYaoSeq.lowerGuaNumber, equals(8));
      expect(yearYaoSeq.formula, equals('2000 + 480 - 8 = 2472'));
    });

    test('月柱庚申爻序法：3000+390-6=3384', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final monthYaoSeq = result.baseNumbers
          .cast<BaGuaJiaZeBaseNumberModel>()
          .firstWhere((model) =>
              model.pillarName == '月柱' && model.method == '爻序法');

      expect(monthYaoSeq.baseNumber, equals(3384));
      expect(monthYaoSeq.yaoSum, equals(390));
      expect(monthYaoSeq.upperGuaNumber, equals(3));
      expect(monthYaoSeq.lowerGuaNumber, equals(6));
      expect(monthYaoSeq.formula, equals('3000 + 390 - 6 = 3384'));
    });

    test('日柱丁未爻序法：7000+360-8=7352', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final dayYaoSeq = result.baseNumbers
          .cast<BaGuaJiaZeBaseNumberModel>()
          .firstWhere((model) =>
              model.pillarName == '日柱' && model.method == '爻序法');

      expect(dayYaoSeq.baseNumber, equals(7352));
      expect(dayYaoSeq.yaoSum, equals(360));
      expect(dayYaoSeq.upperGuaNumber, equals(7));
      expect(dayYaoSeq.lowerGuaNumber, equals(8));
      expect(dayYaoSeq.formula, equals('7000 + 360 - 8 = 7352'));
    });

    test('时柱丙午爻序法：8000+360-9=8351', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final timeYaoSeq = result.baseNumbers
          .cast<BaGuaJiaZeBaseNumberModel>()
          .firstWhere((model) =>
              model.pillarName == '时柱' && model.method == '爻序法');

      expect(timeYaoSeq.baseNumber, equals(8351));
      expect(timeYaoSeq.yaoSum, equals(360));
      expect(timeYaoSeq.upperGuaNumber, equals(8));
      expect(timeYaoSeq.lowerGuaNumber, equals(9));
      expect(timeYaoSeq.formula, equals('8000 + 360 - 9 = 8351'));
    });

    test('爻序法应该为每个爻正确配置地支', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final yearYaoSeq = result.baseNumbers
          .cast<BaGuaJiaZeBaseNumberModel>()
          .firstWhere((model) =>
              model.pillarName == '年柱' && model.method == '爻序法');

      // 验证六爻都有地支配置
      final yaoDetails = yearYaoSeq.yaoDetails;
      expect(yaoDetails.length, equals(6));

      // 验证每个爻都有地支和数字
      for (final yao in yaoDetails) {
        expect(yao.diZhi, isNot(equals('未配')));
        expect(yao.number, greaterThan(0));
      }
    });
  });

  group('BaGuaJiaZeStrategy - 纳甲法测试', () {
    test('年柱癸未纳甲法：2000+720-8=2712', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final yearNaJia = result.baseNumbers
          .cast<BaGuaJiaZeBaseNumberModel>()
          .firstWhere((model) =>
              model.pillarName == '年柱' && model.method == '纳甲法');

      expect(yearNaJia.baseNumber, equals(2712));
      expect(yearNaJia.yaoSum, equals(720));
      expect(yearNaJia.upperGuaNumber, equals(2));
      expect(yearNaJia.lowerGuaNumber, equals(8));
      expect(yearNaJia.formula, equals('2000 + 720 - 8 = 2712'));
    });

    test('月柱庚申纳甲法：3000+630-6=3624', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final monthNaJia = result.baseNumbers
          .cast<BaGuaJiaZeBaseNumberModel>()
          .firstWhere((model) =>
              model.pillarName == '月柱' && model.method == '纳甲法');

      expect(monthNaJia.baseNumber, equals(3624));
      expect(monthNaJia.yaoSum, equals(630));
      expect(monthNaJia.upperGuaNumber, equals(3));
      expect(monthNaJia.lowerGuaNumber, equals(6));
      expect(monthNaJia.formula, equals('3000 + 630 - 6 = 3624'));
    });

    test('日柱丁未纳甲法：7000+810-8=7802', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final dayNaJia = result.baseNumbers
          .cast<BaGuaJiaZeBaseNumberModel>()
          .firstWhere((model) =>
              model.pillarName == '日柱' && model.method == '纳甲法');

      expect(dayNaJia.baseNumber, equals(7802));
      expect(dayNaJia.yaoSum, equals(810));
      expect(dayNaJia.upperGuaNumber, equals(7));
      expect(dayNaJia.lowerGuaNumber, equals(8));
      expect(dayNaJia.formula, equals('7000 + 810 - 8 = 7802'));
    });

    test('时柱丙午纳甲法：8000+540-9=8531', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final timeNaJia = result.baseNumbers
          .cast<BaGuaJiaZeBaseNumberModel>()
          .firstWhere((model) =>
              model.pillarName == '时柱' && model.method == '纳甲法');

      expect(timeNaJia.baseNumber, equals(8531));
      expect(timeNaJia.yaoSum, equals(540));
      expect(timeNaJia.upperGuaNumber, equals(8));
      expect(timeNaJia.lowerGuaNumber, equals(9));
      expect(timeNaJia.formula, equals('8000 + 540 - 9 = 8531'));
    });

    test('纳甲法应该为每个爻正确配置地支', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final yearNaJia = result.baseNumbers
          .cast<BaGuaJiaZeBaseNumberModel>()
          .firstWhere((model) =>
              model.pillarName == '年柱' && model.method == '纳甲法');

      // 验证六爻都有地支配置
      final yaoDetails = yearNaJia.yaoDetails;
      expect(yaoDetails.length, equals(6));

      // 验证每个爻都有地支和数字
      for (final yao in yaoDetails) {
        expect(yao.diZhi, isNot(equals('未配')));
        expect(yao.number, greaterThan(0));
      }
    });
  });

  group('BaGuaJiaZeStrategy - 完整结果验证', () {
    test('所有8个基础数应该符合预期值', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final models = result.baseNumbers.cast<BaGuaJiaZeBaseNumberModel>();

      // 预期结果映射（基于实际计算）
      final expectedResults = {
        '年柱-爻序法': 2472,
        '年柱-纳甲法': 2712,
        '月柱-爻序法': 3384,
        '月柱-纳甲法': 3624,
        '日柱-爻序法': 7352,
        '日柱-纳甲法': 7802,
        '时柱-爻序法': 8351,
        '时柱-纳甲法': 8531,
      };

      // 验证每个结果
      for (final entry in expectedResults.entries) {
        final key = entry.key;
        final expectedValue = entry.value;

        final model = models.firstWhere((m) => m.name == key);
        expect(
          model.baseNumber,
          equals(expectedValue),
          reason: '$key 的基础数应该是 $expectedValue',
        );
      }
    });

    test('结果应该按照年月日时顺序排列', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final models = result.baseNumbers.cast<BaGuaJiaZeBaseNumberModel>();

      expect(models[0].pillarName, equals('年柱'));
      expect(models[1].pillarName, equals('年柱'));
      expect(models[2].pillarName, equals('月柱'));
      expect(models[3].pillarName, equals('月柱'));
      expect(models[4].pillarName, equals('日柱'));
      expect(models[5].pillarName, equals('日柱'));
      expect(models[6].pillarName, equals('时柱'));
      expect(models[7].pillarName, equals('时柱'));
    });

    test('每柱应该先有爻序法结果，后有纳甲法结果', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final models = result.baseNumbers.cast<BaGuaJiaZeBaseNumberModel>();

      for (int i = 0; i < 8; i += 2) {
        expect(models[i].method, equals('爻序法'),
            reason: '索引 $i 应该是爻序法');
        expect(models[i + 1].method, equals('纳甲法'),
            reason: '索引 ${i + 1} 应该是纳甲法');
      }
    });

    test('sourceData应该包含完整的计算信息', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      expect(result.sourceData['methodCount'], equals(2));
      expect(result.sourceData['pillarCount'], equals(4));
      expect(result.sourceData['totalResults'], equals(8));
      expect(result.sourceData['methods'], contains('爻序法'));
      expect(result.sourceData['methods'], contains('纳甲法'));

      final eightCharsData = result.sourceData['eightChars'] as Map;
      expect(eightCharsData['year'], equals('癸未'));
      expect(eightCharsData['month'], equals('庚申'));
      expect(eightCharsData['day'], equals('丁未'));
      expect(eightCharsData['time'], equals('丙午'));
    });
  });

  group('BaGuaJiaZeStrategy - 边界情况测试', () {
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
          BaGuaJiaZeStrategyParams(eightChars: eightChars1));
      final result2 = strategy.calculate(
          BaGuaJiaZeStrategyParams(eightChars: eightChars2));

      expect(result1.hasError, isFalse);
      expect(result2.hasError, isFalse);

      // 至少应该有一些不同的基础数
      final baseNumbers1 = result1.baseNumbers.map((m) => m.baseNumber).toList();
      final baseNumbers2 = result2.baseNumbers.map((m) => m.baseNumber).toList();

      expect(baseNumbers1, isNot(equals(baseNumbers2)));
    });

    test('相同的八字应该产生相同的结果', () {
      final params1 = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final params2 = BaGuaJiaZeStrategyParams(eightChars: testEightChars);

      final result1 = strategy.calculate(params1);
      final result2 = strategy.calculate(params2);

      expect(result1.hasError, isFalse);
      expect(result2.hasError, isFalse);

      final baseNumbers1 = result1.baseNumbers.map((m) => m.baseNumber).toList();
      final baseNumbers2 = result2.baseNumbers.map((m) => m.baseNumber).toList();

      expect(baseNumbers1, equals(baseNumbers2));
    });
  });

  group('BaGuaJiaZeStrategy - 六爻详细信息验证', () {
    test('六爻应该包含位置标签', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final firstModel = result.baseNumbers.first as BaGuaJiaZeBaseNumberModel;
      final yaoDetails = firstModel.yaoDetails;

      final expectedLabels = ['初', '二', '三', '四', '五', '上'];
      for (int i = 0; i < 6; i++) {
        expect(yaoDetails[i].positionLabel, equals(expectedLabels[i]));
        expect(yaoDetails[i].position, equals(i));
      }
    });

    test('六爻应该包含阴阳信息', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final firstModel = result.baseNumbers.first as BaGuaJiaZeBaseNumberModel;
      final yaoDetails = firstModel.yaoDetails;

      for (final yao in yaoDetails) {
        expect(yao.yinYang, isIn(['阳', '阴']));
      }
    });

    test('爻序法和纳甲法的六爻地支应该不同', () {
      final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
      final result = strategy.calculate(params);

      final yearYaoSeq = result.baseNumbers
          .cast<BaGuaJiaZeBaseNumberModel>()
          .firstWhere((model) =>
              model.pillarName == '年柱' && model.method == '爻序法');

      final yearNaJia = result.baseNumbers
          .cast<BaGuaJiaZeBaseNumberModel>()
          .firstWhere((model) =>
              model.pillarName == '年柱' && model.method == '纳甲法');

      final yaoSeqDiZhi = yearYaoSeq.yaoDetails.map((y) => y.diZhi).toList();
      final naJiaDiZhi = yearNaJia.yaoDetails.map((y) => y.diZhi).toList();

      // 两种方法的地支配置应该不同
      expect(yaoSeqDiZhi, isNot(equals(naJiaDiZhi)));
    });
  });
}
