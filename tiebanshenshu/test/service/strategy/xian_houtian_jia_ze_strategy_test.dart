import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/xian_houtian_jia_ze_strategy.dart';
import 'package:tiebanshenshu/domain/models/xian_houtian_gua_base_number_model.dart';

/// 先后天八卦加则法单元测试 - 癸巳甲子丁酉癸卯
///
/// 基于修正后算法的完整验证测试
/// 测试数据：阴男 癸巳 甲子 丁酉 癸卯
///
/// 验证内容：
/// - 干支配数: 2[2,7] 6[1,6] 7[4,9] 2[3,8]
/// - 天地数: 天:27%25=2 地:30%30=3
/// - 先天卦: 震坤 (雷地豫，上震下坤)
/// - 后天卦: 震坤 (在先后天八卦加则法中，后天卦与先天卦相同)
/// - 条文扩展: 先天卦递增96四次，后天卦递减96四次
void main() {
  late XianHoutianJiaZeStrategy strategy;
  late EightChars testEightChars;
  late XianHoutianJiaZeStrategyParams testParams;
  late XianHoutianGuaBaseNumberModel model;

  setUp(() {
    strategy = XianHoutianJiaZeStrategy();

    testEightChars = EightChars(
      year: JiaZi.getFromGanZhiValue("癸巳")!,
      month: JiaZi.getFromGanZhiValue("甲子")!,
      day: JiaZi.getFromGanZhiValue("丁酉")!,
      time: JiaZi.getFromGanZhiValue("癸卯")!,
    );

    testParams = XianHoutianJiaZeStrategyParams(
      eightChars: testEightChars,
      gender: Gender.male,
      threeYuan: YuanYunOrder.upper,
      birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
    );

    final result = strategy.calculate(testParams);
    model = result.baseNumbers.first as XianHoutianGuaBaseNumberModel;
  });

  group('步骤1：生成天地卦 - 癸巳甲子丁酉癸卯', () {
    test('应该正确提取天干配数: 癸=2, 甲=6, 丁=7, 癸=2', () {
      expect(
        model.ganNumList,
        equals([2, 6, 7, 2]),
        reason: '天干配数应该按照 癸=2, 甲=6, 丁=7, 癸=2',
      );
    });

    test('应该正确提取地支配数: 巳=[2,7], 子=[1,6], 酉=[4,9], 卯=[3,8]', () {
      // 验证地支配数，忽略每个地支内部的数字顺序
      expect(model.zhiNumList.length, equals(4), reason: '应该有4个地支');

      // 巳: [2,7] 或 [7,2]
      expect(model.zhiNumList[0], containsAll([2, 7]), reason: '巳应该包含2和7');
      expect(model.zhiNumList[0].length, equals(2), reason: '巳应该有2个数');

      // 子: [1,6] 或 [6,1]
      expect(model.zhiNumList[1], containsAll([1, 6]), reason: '子应该包含1和6');
      expect(model.zhiNumList[1].length, equals(2), reason: '子应该有2个数');

      // 酉: [4,9] 或 [9,4]
      expect(model.zhiNumList[2], containsAll([4, 9]), reason: '酉应该包含4和9');
      expect(model.zhiNumList[2].length, equals(2), reason: '酉应该有2个数');

      // 卯: [3,8] 或 [8,3]
      expect(model.zhiNumList[3], containsAll([3, 8]), reason: '卯应该包含3和8');
      expect(model.zhiNumList[3].length, equals(2), reason: '卯应该有2个数');
    });

    test('应该计算奇数总和=27', () {
      // 根据修正后的数据计算奇数和
      // 天干奇数：7(丁)
      // 地支奇数：7(巳2) + 1(子1) + 9(酉2) + 3(卯1) = 20
      // 奇数总和 = 7 + 20 = 27
      expect(model.oddNumTotal, equals(27), reason: '所有奇数之和应该是27');
    });

    test('应该计算偶数总和=30', () {
      // 根据修正后的数据计算偶数和
      // 天干偶数：2(癸) + 6(甲) + 2(癸) = 10
      // 地支偶数：2(巳1) + 6(子2) + 4(酉1) + 8(卯2) = 20
      // 偶数总和 = 10 + 20 = 30
      expect(model.evenNumTotal, equals(30), reason: '所有偶数之和应该是30');
    });

    test('天数应该=2，天卦=坤', () {
      // 天数：27 % 25 = 2
      expect(model.tianGuaNum, equals(2), reason: '奇数和27对25取模应该得2');
      expect(model.tianGua, equals('坤'), reason: '天数2对应坤卦');
    });

    test('地数应该=3，地卦=震', () {
      // 地数：30 % 30 = 3（特殊处理）
      expect(model.diGuaNum, equals(3), reason: '偶数和30对30取模特殊处理为3');
      expect(model.diGua, equals('震'), reason: '地数3对应震卦');
    });

    test('应该未使用三元五宫', () {
      expect(model.usedThreeYuanWuGong, isFalse, reason: '天数和地数都不是5，不需要使用三元五宫');
    });
  });

  group('步骤2：生成先后天卦 - 癸巳甲子丁酉癸卯', () {
    test('应该判断癸年为阴年', () {
      // 癸为阴干
      expect(model.yearYinYang, equals('阴'), reason: '癸为阴干，应该判断为阴年');
    });

    test('阴年男性应该地卦在上、天卦在下', () {
      // 阴年男性：地卦在上，天卦在下
      expect(model.upperGua, equals(model.diGua), reason: '阴年男性，地卦应该在上');
      expect(model.lowerGua, equals(model.tianGua), reason: '阴年男性，天卦应该在下');
    });

    test('先天卦应该是震坤（雷地豫）', () {
      // 天数2对应坤卦，地数3对应震卦
      // 阴年男性：地卦在上，天卦在下 -> 震坤
      expect(model.xiantianGua, equals('震坤'), reason: '先天卦应该是震坤（雷地豫）');
      expect(model.upperGua, equals('震'), reason: '上卦应该是震');
      expect(model.lowerGua, equals('坤'), reason: '下卦应该是坤');
    });

    test('上下卦后天数应该正确', () {
      // 震卦后天数为3, 坤卦后天数为2
      expect(model.xiantianUpperGuaNumber, equals(3), reason: '震卦的后天数是3');
      expect(model.xiantianLowerGuaNumber, equals(2), reason: '坤卦的后天数是2');
    });

    test('后天卦应该与先天卦相同', () {
      // 在先后天八卦加则法中，后天卦与先天卦相同（不涉及爻变）
      expect(
        model.houtianGua,
        equals(model.xiantianGua),
        reason: '在先后天八卦加则法中，后天卦应该与先天卦相同',
      );
      expect(model.houtianGua, equals('震坤'), reason: '后天卦应该是震坤');
      expect(model.houtianUpperGuaNumber, equals(3), reason: '后天卦上卦后天数应该是3');
      expect(model.houtianLowerGuaNumber, equals(2), reason: '后天卦下卦后天数应该是2');
    });
  });

  group('步骤3-4：互卦计算 - 癸巳甲子丁酉癸卯', () {
    test('先天卦互卦应该已计算', () {
      expect(model.xiantianGuaHu, isNotEmpty, reason: '先天卦互卦应该已计算');
      // expect(model.xiantianGuaHu.length, equals(2), reason: '互卦应该是两个卦的组合');
    });

    test('后天卦互卦应该已计算', () {
      expect(model.houtianGuaHu, isNotEmpty, reason: '后天卦互卦应该已计算');
    });

    test('先后天卦互卦应该相同', () {
      // 因为先后天卦相同，所以互卦也应该相同
      expect(
        model.houtianGuaHu,
        equals(model.xiantianGuaHu),
        reason: '先后天卦相同，互卦也应该相同',
      );
    });
  });

  group('步骤5-6：加则法计算基础数 - 癸巳甲子丁酉癸卯', () {
    test('先天卦基础数应该已计算', () {
      expect(model.xiantianBaseNumber, isPositive, reason: '先天卦基础数应该是正数');
      expect(model.xiantianBaseNumber, greaterThan(0), reason: '先天卦基础数应该大于0');
    });

    test('后天卦基础数应该已计算', () {
      expect(model.houtianBaseNumber, isPositive, reason: '后天卦基础数应该是正数');
      expect(model.houtianBaseNumber, greaterThan(0), reason: '后天卦基础数应该大于0');
    });

    test('先后天卦基础数应该相同', () {
      // 因为先后天卦相同，所以基础数也应该相同
      expect(
        model.houtianBaseNumber,
        equals(model.xiantianBaseNumber),
        reason: '先后天卦相同，基础数也应该相同',
      );
    });
  });

  group('步骤7：条文扩展 - 癸巳甲子丁酉癸卯', () {
    test('先天卦条文列表应该有5个编号（递增96四次）', () {
      expect(
        model.xiantianTiaoWenNumbers.length,
        equals(5),
        reason: '先天卦应该生成5个条文编号（基础数+4次递增）',
      );
    });

    test('先天卦条文列表应该递增96', () {
      final baseNumber = model.xiantianBaseNumber;
      expect(model.xiantianTiaoWenNumbers, [
        baseNumber,
        baseNumber + 96,
        baseNumber + 192,
        baseNumber + 288,
        baseNumber + 384,
      ], reason: '先天卦条文列表应该是递增96四次');
    });

    test('后天卦条文列表应该有5个编号（递减96四次）', () {
      expect(
        model.houtianTiaoWenNumbers.length,
        equals(5),
        reason: '后天卦应该生成5个条文编号（基础数+4次递减）',
      );
    });

    test('后天卦条文列表应该递减96', () {
      final baseNumber = model.houtianBaseNumber;
      expect(model.houtianTiaoWenNumbers, [
        baseNumber,
        baseNumber - 96,
        baseNumber - 192,
        baseNumber - 288,
        baseNumber - 384,
      ], reason: '后天卦条文列表应该是递减96四次');
    });

    test('先天卦计算公式应该正确', () {
      expect(
        model.xiantianCalculationFormula,
        contains('先天卦基础数'),
        reason: '先天卦公式应该包含"先天卦基础数"',
      );
      expect(
        model.xiantianCalculationFormula,
        contains('[0, 96, 192, 288, 384]'),
        reason: '先天卦公式应该包含递增偏移量',
      );
    });

    test('后天卦计算公式应该正确', () {
      expect(
        model.houtianCalculationFormula,
        contains('后天卦基础数'),
        reason: '后天卦公式应该包含"后天卦基础数"',
      );
      expect(
        model.houtianCalculationFormula,
        contains('[0, -96, -192, -288, -384]'),
        reason: '后天卦公式应该包含递减偏移量',
      );
    });
  });

  group('完整计算流程验证 - 癸巳甲子丁酉癸卯', () {
    test('应该返回成功结果', () {
      final result = strategy.calculate(testParams);
      expect(result.hasError, isFalse, reason: '计算应该成功，无错误');
      expect(result.baseNumbers.length, equals(1), reason: '应该返回1个基础数结果');
    });

    test('所有关键字段应该已填充', () {
      expect(model.tianGua, equals('坤'), reason: '天卦应该是坤');
      expect(model.diGua, equals('震'), reason: '地卦应该是震');
      expect(model.xiantianGua, equals('震坤'), reason: '先天卦应该是震坤');
      expect(model.houtianGua, equals('震坤'), reason: '后天卦应该是震坤');
      expect(model.xiantianGuaHu, isNotEmpty, reason: '先天卦互卦应该已计算');
      expect(model.houtianGuaHu, isNotEmpty, reason: '后天卦互卦应该已计算');
      expect(model.xiantianTiaoWenNumbers, isNotEmpty, reason: '先天卦条文列表应该已生成');
      expect(model.houtianTiaoWenNumbers, isNotEmpty, reason: '后天卦条文列表应该已生成');
    });
  });

  group('Strategy 配置验证', () {
    test('默认条文计算配置应该是递增96四次', () {
      final config = strategy.defaultTiaoWenCalculationConfig;
      expect(config.name, contains('递增'), reason: '默认配置应该是递增配置');
    });

    test('应该支持3种条文计算配置', () {
      final configs = strategy.supportedTiaoWenCalculationConfigs;
      expect(configs.length, equals(3), reason: '应该支持3种配置：递增、递减、自定义');
    });

    test('策略名称应该正确', () {
      expect(strategy.name, equals('先后天八卦加则法'), reason: '策略名称应该是"先后天八卦加则法"');
    });

    test('策略描述应该包含关键信息', () {
      expect(strategy.description, contains('先后天卦'), reason: '描述应该包含"先后天卦"');
      expect(strategy.description, contains('加则法'), reason: '描述应该包含"加则法"');
    });

    test('详细步骤应该有7个', () {
      expect(strategy.detailSteps.length, equals(7), reason: '应该有7个详细步骤');
    });
  });
}
