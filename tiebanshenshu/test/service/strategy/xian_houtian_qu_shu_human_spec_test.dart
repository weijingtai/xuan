import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/xian_houtian_qu_shu_strategy.dart';
import 'package:tiebanshenshu/domain/models/xian_houtian_qu_shu_base_number_model.dart';

/// 先后天卦取数法单元测试 - 人工规格测试
///
/// 测试数据来源：用户提供的规格
/// 测试用例：男 甲戌 己巳 辛丑 丁酉
///
/// 预期结果：
/// 1. 先天卦：泽天夬[兑上乾下]
/// 2. 先天基本数：2111
/// 3. 后天卦：火泽睽[离上兑下]
/// 4. 后天基本数：9719
void main() {
  late XianHoutianQuShuStrategy strategy;
  late EightChars testEightChars;
  late XianHoutianQuShuStrategyParams testParams;
  late XianHoutianQuShuBaseNumberModel model;

  setUp(() {
    strategy = XianHoutianQuShuStrategy();

    testEightChars = EightChars(
      year: JiaZi.getFromGanZhiValue("甲戌")!,
      month: JiaZi.getFromGanZhiValue("己巳")!,
      day: JiaZi.getFromGanZhiValue("辛丑")!,
      time: JiaZi.getFromGanZhiValue("丁酉")!,
    );

    testParams = XianHoutianQuShuStrategyParams(
      eightChars: testEightChars,
      gender: Gender.male,
      threeYuan: YuanYunOrder.upper,
      birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
    );

    final result = strategy.calculate(testParams);
    expect(result.hasError, false, reason: '计算不应该出错');
    model = result.baseNumbers.first as XianHoutianQuShuBaseNumberModel;
  });

  group('步骤1：验证先天卦 - 泽天夬', () {
    test('先天卦应该是泽天夬（兑上乾下）', () {
      print('\n实际先天卦: ${model.xiantianGua}');
      print('先天卦上卦: ${model.upperGua}');
      print('先天卦下卦: ${model.lowerGua}');

      expect(model.xiantianGua, equals('兑乾'), reason: '先天卦应该是兑乾（泽天夬）');
    });

    test('先天基本数应该=2111', () {
      print('实际先天基本数: ${model.xiantianBaseNumber}');
      expect(model.xiantianBaseNumber, equals(2111), reason: '先天基本数应该是2111');
    });
  });

  group('步骤2：验证后天卦 - 火泽睽', () {
    test('后天卦应该是火泽睽（离上兑下）', () {
      print('\n实际后天卦: ${model.houtianGua}');
      // 注意：upperGua/lowerGua是先天卦的上下卦，后天卦没有单独的字段
      // 只能通过houtianGua字符串来判断

      expect(model.houtianGua, equals('离兑'), reason: '后天卦应该是离兑（火泽睽）');
    });

    test('后天基本数应该=9719', () {
      print('实际后天基本数: ${model.houtianBaseNumber}');
      expect(model.houtianBaseNumber, equals(9719), reason: '后天基本数应该是9719');
    });
  });

  group('完整流程验证 - 甲戌己巳辛丑丁酉', () {
    test('应该成功计算并返回结果', () {
      final result = strategy.calculate(testParams);
      expect(result.hasError, false, reason: '计算应该成功');
      expect(result.baseNumbers.length, equals(1), reason: '应该返回1个基础数结果');
    });

    test('所有关键字段应该符合人工规格', () {
      final summary = {
        '四柱':
            '${testEightChars.year} ${testEightChars.month} ${testEightChars.day} ${testEightChars.time}',
        '先天卦': model.xiantianGua,
        '先天基本数': model.xiantianBaseNumber,
        '后天卦': model.houtianGua,
        '后天基本数': model.houtianBaseNumber,
      };

      print('\n========== 完整结果汇总 ==========');
      summary.forEach((key, value) {
        print('$key: $value');
      });
      print('====================================\n');

      // 验证核心字段
      expect(model.xiantianGua, equals('兑乾'));
      expect(model.xiantianBaseNumber, equals(2111));
      expect(model.houtianGua, equals('离兑'));
      expect(model.houtianBaseNumber, equals(9719));
    });
  });
}
