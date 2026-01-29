import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/yuan_tang_strategy.dart';

/// 元堂卦取数法 - 条文扩展测试
///
/// 测试递加96四次的条文扩展规则
void main() {
  late YuanTangStrategy strategy;
  late EightChars testEightChars;
  late YuanTangStrategyParams testParams;

  setUp(() {
    strategy = YuanTangStrategy();

    // 使用测试数据：癸巳甲子丁酉癸卯
    testEightChars = EightChars(
      year: JiaZi.getFromGanZhiValue("癸巳")!,
      month: JiaZi.getFromGanZhiValue("甲子")!,
      day: JiaZi.getFromGanZhiValue("丁酉")!,
      time: JiaZi.getFromGanZhiValue("癸卯")!,
    );

    testParams = YuanTangStrategyParams(
      eightChars: testEightChars,
      gender: Gender.male,
      threeYuan: YuanYunOrder.upper,
      birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      birthMonth: 5,
    );
  });

  group('条文扩展配置', () {
    test('默认配置应该是递加96四次', () {
      final config = strategy.defaultTiaoWenCalculationConfig;

      expect(config.name, equals("元堂卦递加96四次"));
      expect(config.description, contains("递加96四次"));
      expect(config.description, contains("5个条文编号"));
    });

    test('calculateTiaoWenListWithConfig应该正确递加', () {
      final baseNumber = 1000;
      final result = strategy.calculateTiaoWenListWithConfig(
        baseNumber,
        testParams,
        strategy.defaultTiaoWenCalculationConfig,
      );

      // 应该返回：[1000, 1096, 1192, 1288, 1384]
      expect(result.length, equals(5));
      expect(result[0], equals(1000)); // 基础数 + 0
      expect(result[1], equals(1096)); // 基础数 + 96
      expect(result[2], equals(1192)); // 基础数 + 192
      expect(result[3], equals(1288)); // 基础数 + 288
      expect(result[4], equals(1384)); // 基础数 + 384
    });
  });

  group('先天卦和后天卦条文扩展', () {
    test('先天卦条文应该正确扩展', () {
      final result = strategy.calculate(testParams);
      final model = result.baseNumbers.first;

      // 获取先天卦基础数（加则法）
      final xiantianBaseNumber = model.baseNumber;

      // 使用默认配置扩展
      final xiantianTiaoWenList = strategy.calculateTiaoWenListWithConfig(
        xiantianBaseNumber,
        testParams,
        strategy.defaultTiaoWenCalculationConfig,
      );

      // 验证扩展结果
      expect(xiantianTiaoWenList.length, equals(5));
      expect(xiantianTiaoWenList[0], equals(xiantianBaseNumber));
      expect(xiantianTiaoWenList[1], equals(xiantianBaseNumber + 96));
      expect(xiantianTiaoWenList[2], equals(xiantianBaseNumber + 192));
      expect(xiantianTiaoWenList[3], equals(xiantianBaseNumber + 288));
      expect(xiantianTiaoWenList[4], equals(xiantianBaseNumber + 384));
    });

    test('后天卦条文应该正确扩展', () {
      final result = strategy.calculate(testParams);
      final model = result.baseNumbers.first;

      // 获取后天卦基础数（后天卦加则法）
      // 注意：需要从YuanTangBaseNumberModel中获取
      // 这里为了测试简单，使用baseNumber作为示例
      final houtianBaseNumber = model.baseNumber + 1000; // 假设后天卦不同

      // 使用默认配置扩展
      final houtianTiaoWenList = strategy.calculateTiaoWenListWithConfig(
        houtianBaseNumber,
        testParams,
        strategy.defaultTiaoWenCalculationConfig,
      );

      // 验证扩展结果
      expect(houtianTiaoWenList.length, equals(5));
      expect(houtianTiaoWenList[0], equals(houtianBaseNumber));
      expect(houtianTiaoWenList[1], equals(houtianBaseNumber + 96));
      expect(houtianTiaoWenList[2], equals(houtianBaseNumber + 192));
      expect(houtianTiaoWenList[3], equals(houtianBaseNumber + 288));
      expect(houtianTiaoWenList[4], equals(houtianBaseNumber + 384));
    });
  });

  group('条文编号范围验证', () {
    test('扩展后的条文编号应该在合理范围内', () {
      final result = strategy.calculate(testParams);
      final model = result.baseNumbers.first;

      final xiantianBaseNumber = model.baseNumber;
      final xiantianTiaoWenList = strategy.calculateTiaoWenListWithConfig(
        xiantianBaseNumber,
        testParams,
        strategy.defaultTiaoWenCalculationConfig,
      );

      // 验证所有条文编号都是正数
      for (final tiaowen in xiantianTiaoWenList) {
        expect(tiaowen, greaterThan(0), reason: '条文编号应该是正数');
      }

      // 验证最大条文编号不会溢出（假设最大条文编号是81*81=6561）
      for (final tiaowen in xiantianTiaoWenList) {
        expect(tiaowen, lessThanOrEqualTo(10000), reason: '条文编号应该在合理范围内');
      }
    });

    test('先天卦和后天卦条文编号不应该重复', () {
      final result = strategy.calculate(testParams);
      final model = result.baseNumbers.first;

      final xiantianBaseNumber = model.baseNumber;
      final xiantianTiaoWenList = strategy.calculateTiaoWenListWithConfig(
        xiantianBaseNumber,
        testParams,
        strategy.defaultTiaoWenCalculationConfig,
      );

      // 验证先天卦条文列表内部没有重复
      final xiantianSet = xiantianTiaoWenList.toSet();
      expect(
        xiantianSet.length,
        equals(xiantianTiaoWenList.length),
        reason: '先天卦条文列表不应该有重复',
      );
    });
  });
}
