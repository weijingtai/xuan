import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/qian_hou_gua_strategy.dart';
import 'package:tiebanshenshu/domain/models/qian_hou_gua_base_number_model.dart';

/// 前后卦取数法单元测试 - 人工规格测试
///
/// 测试数据来源：用户提供的规格
/// 测试用例：男 癸亥 甲子 己丑 癸酉
///
/// 预期结果：
/// 1. 干支太玄数（摘要）：5、4 / 9、9 / 9、8 / 5、6
/// 2. 年干支 -> 坎，月干支 -> 坤，日干支 -> 坎，时干支 -> 震
/// 3. 前卦基础数：1478，前卦条文：1478 1574 1670 1766 1862
/// 4. 后卦基础数：1387，后卦条文：1387 1291 1195 1099 1003
void main() {
  late QianHouGuaStrategy strategy;
  late EightChars testFourZhu;
  late QianHouGuaStrategyParams testParams;
  late QianHouGuaBaseNumberModel model;

  setUp(() {
    strategy = QianHouGuaStrategy();

    testFourZhu = EightChars(
      year: JiaZi.getFromGanZhiValue("癸亥")!,
      month: JiaZi.getFromGanZhiValue("甲子")!,
      day: JiaZi.getFromGanZhiValue("己丑")!,
      time: JiaZi.getFromGanZhiValue("癸酉")!,
    );

    testParams = QianHouGuaStrategyParams(
      eightChars: testFourZhu,
      gender: Gender.male,
      threeYuan: YuanYunOrder.upper,
      birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
    );

    final result = strategy.calculate(testParams);
    expect(result.hasError, false, reason: '计算不应该出错');
    model = result.baseNumbers.first as QianHouGuaBaseNumberModel;
  });

  group('步骤1：验证四柱干支太玄数（摘要）', () {
    test('干支太玄数组成应与摘要一致', () {
      // 干太玄数：年/月/日/时 → [5, 9, 9, 5]
      // 支太玄数：仅一位列表包装 → [[4], [9], [8], [6]]
      print('\n实际干太玄数: ${model.ganNumList}');
      print('实际支太玄数: ${model.zhiNumList}');

      expect(model.ganNumList, equals([5, 9, 9, 5]));
      expect(
        model.zhiNumList,
        equals([
          [4],
          [9],
          [8],
          [6],
        ]),
      );
    });
  });

  group('步骤2：验证前后卦的上下卦（按人规）', () {
    test('前卦（由年、月）应为坎坤', () {
      print('\n前卦名称: ${model.qianGuaName}');
      print('前卦上卦后天数(年): ${model.qianGuaUpperNumber}');
      print('前卦下卦后天数(月): ${model.qianGuaLowerNumber}');
      // 人规指定：年干支->坎，月干支->坤
      expect(model.qianGuaName, equals('坎坤'));
    });

    test('后卦（由日、时）应为坎震', () {
      print('\n后卦名称: ${model.houGuaName}');
      print('后卦上卦后天数(日): ${model.houGuaUpperNumber}');
      print('后卦下卦后天数(时): ${model.houGuaLowerNumber}');
      // 人规指定：日干支->坎，时干支->震
      expect(model.houGuaName, equals('坎震'));
    });
  });

  group('步骤3：验证前卦加则法与条文递增96四次', () {
    test('前卦基础数应为1478', () {
      print('\n前卦基础数: ${model.qianGuaBaseNumber}');
      expect(model.qianGuaBaseNumber, equals(1478));
    });

    test('前卦条文应为 [1478, 1574, 1670, 1766, 1862]', () {
      print('前卦条文: ${model.qianGuaTiaoWenNumbers}');
      expect(
        model.qianGuaTiaoWenNumbers,
        equals([1478, 1574, 1670, 1766, 1862]),
      );
    });
  });

  group('步骤4：验证后卦加则法与条文递减96四次', () {
    test('后卦基础数应为1387', () {
      print('\n后卦基础数: ${model.houGuaBaseNumber}');
      expect(model.houGuaBaseNumber, equals(1387));
    });

    test('后卦条文应为 [1387, 1291, 1195, 1099, 1003]', () {
      print('后卦条文: ${model.houGuaTiaoWenNumbers}');
      expect(
        model.houGuaTiaoWenNumbers,
        equals([1387, 1291, 1195, 1099, 1003]),
      );
    });
  });

  group('完整流程验证 - 男 癸亥 甲子 己丑 癸酉', () {
    test('应该成功计算并返回结果', () {
      final result = strategy.calculate(testParams);
      expect(result.hasError, false, reason: '计算应该成功');
      expect(result.baseNumbers.length, equals(1), reason: '应该返回1个基础数结果');
    });

    test('汇总并打印关键结果以便人工核对', () {
      final summary = {
        '四柱':
            '${testFourZhu.year.ganZhiStr} ${testFourZhu.month.ganZhiStr} ${testFourZhu.day.ganZhiStr} ${testFourZhu.time.ganZhiStr}',
        '干太玄数': model.ganNumList,
        '支太玄数': model.zhiNumList,
        '前卦名称': model.qianGuaName,
        '后卦名称': model.houGuaName,
        '前卦基础数': model.qianGuaBaseNumber,
        '后卦基础数': model.houGuaBaseNumber,
        '前卦条文': model.qianGuaTiaoWenNumbers,
        '后卦条文': model.houGuaTiaoWenNumbers,
      };

      print('\n========== 前后卦取数法 - 完整结果汇总 ==========');
      summary.forEach((key, value) {
        print('$key: $value');
      });
      print('============================================\n');

      // 核心断言（与人规一致）
      expect(model.qianGuaName, equals('坎坤'));
      expect(model.houGuaName, equals('坎震'));
      expect(model.qianGuaBaseNumber, equals(1478));
      expect(
        model.qianGuaTiaoWenNumbers,
        equals([1478, 1574, 1670, 1766, 1862]),
      );
      expect(model.houGuaBaseNumber, equals(1387));
      expect(
        model.houGuaTiaoWenNumbers,
        equals([1387, 1291, 1195, 1099, 1003]),
      );
    });
  });
}
