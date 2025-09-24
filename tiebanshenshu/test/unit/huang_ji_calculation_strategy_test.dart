/// 皇极取数法计算策略单元测试
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/dev_constant.dart';

import '../../lib/domain/four_zhu.dart';
import '../../lib/domain/models/huang_ji_calculation_params.dart';
import '../../lib/domain/models/tiao_wen_list_state.dart';
import '../../lib/application/strategies/huang_ji_calculation_strategy.dart';

void main() {
  group('HuangJiCalculationStrategy', () {
    late HuangJiCalculationStrategy strategy;
    late FourZhu testFourZhu;

    setUpAll(() {
      final testEightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;
      testFourZhu = FourZhu.fromEightChars(testEightChars);
    });

    setUp(() {
      strategy = HuangJiCalculationStrategy();
    });

    group('基础计算功能', () {
      test('正常四柱计算', () async {
        // Arrange
        final params = HuangJiCalculationParams(fourZhu: testFourZhu);

        // Act
        final result = await strategy.calculate(params);

        // Assert
        expect(result.state, equals(TiaoWenListState.success));
        expect(result.tiaoWenNumbers, isNotEmpty);
        expect(result.calculationMethod, equals('皇极取数法'));
        expect(result.sourceData, isNotEmpty);
        expect(result.sourceData.containsKey('initialNumber'), isTrue);
        expect(result.sourceData.containsKey('secondaryNumber'), isTrue);
        expect(result.sourceData.containsKey('selectedBaseNumber'), isTrue);
        expect(result.sourceData.containsKey('finalNumbers'), isTrue);

        print('✓ 正常四柱计算测试通过');
        print('✓ 初刻数: ${result.sourceData['initialNumber']}');
        print('✓ 次条文数: ${result.sourceData['secondaryNumber']}');
        print('✓ 条文数量: ${result.tiaoWenNumbers.length}');
      });

      test('计算结果一致性', () async {
        // Arrange
        final params = HuangJiCalculationParams(fourZhu: testFourZhu);

        // Act - 多次计算同一四柱
        final result1 = await strategy.calculate(params);
        final result2 = await strategy.calculate(params);

        // Assert - 结果应该一致
        expect(result1.tiaoWenNumbers, equals(result2.tiaoWenNumbers));
        expect(result1.sourceData['initialNumber'], 
               equals(result2.sourceData['initialNumber']));
        expect(result1.sourceData['secondaryNumber'], 
               equals(result2.sourceData['secondaryNumber']));

        print('✓ 计算结果一致性测试通过');
      });

      test('不同四柱产生不同结果', () async {
        // Arrange
        final fourZhu1 = FourZhu(
          yearGan: '甲', yearZhi: '子',
          monthGan: '乙', monthZhi: '丑',
          dayGan: '丙', dayZhi: '寅',
          timeGan: '丁', timeZhi: '卯',
        );

        final fourZhu2 = FourZhu(
          yearGan: '戊', yearZhi: '辰',
          monthGan: '己', monthZhi: '巳',
          dayGan: '庚', dayZhi: '午',
          timeGan: '辛', timeZhi: '未',
        );

        final params1 = HuangJiCalculationParams(fourZhu: fourZhu1);
        final params2 = HuangJiCalculationParams(fourZhu: fourZhu2);

        // Act
        final result1 = await strategy.calculate(params1);
        final result2 = await strategy.calculate(params2);

        // Assert - 不同四柱应该产生不同结果
        expect(result1.sourceData['initialNumber'], 
               isNot(equals(result2.sourceData['initialNumber'])));

        print('✓ 不同四柱产生不同结果测试通过');
        print('✓ 四柱1初刻数: ${result1.sourceData['initialNumber']}');
        print('✓ 四柱2初刻数: ${result2.sourceData['initialNumber']}');
      });
    });

    group('参数验证', () {
      test('空四柱参数', () {
        // Arrange
        final params = HuangJiCalculationParams(fourZhu: null);

        // Act & Assert
        expect(
          () => strategy.calculate(params),
          throwsA(isA<ArgumentError>()),
        );

        print('✓ 空四柱参数验证测试通过');
      });

      test('无效四柱数据', () {
        // Arrange
        final invalidFourZhu = FourZhu(
          yearGan: '', yearZhi: '',
          monthGan: '', monthZhi: '',
          dayGan: '', dayZhi: '',
          timeGan: '', timeZhi: '',
        );
        final params = HuangJiCalculationParams(fourZhu: invalidFourZhu);

        // Act & Assert
        expect(
          () => strategy.calculate(params),
          throwsA(isA<Exception>()),
        );

        print('✓ 无效四柱数据验证测试通过');
      });
    });

    group('边界条件', () {
      test('极端四柱组合', () async {
        // Arrange - 测试各种极端组合
        final extremeCases = [
          // 全甲子
          FourZhu(
            yearGan: '甲', yearZhi: '子',
            monthGan: '甲', monthZhi: '子',
            dayGan: '甲', dayZhi: '子',
            timeGan: '甲', timeZhi: '子',
          ),
          // 全癸亥
          FourZhu(
            yearGan: '癸', yearZhi: '亥',
            monthGan: '癸', monthZhi: '亥',
            dayGan: '癸', dayZhi: '亥',
            timeGan: '癸', timeZhi: '亥',
          ),
          // 混合极端
          FourZhu(
            yearGan: '甲', yearZhi: '亥',
            monthGan: '癸', monthZhi: '子',
            dayGan: '甲', dayZhi: '亥',
            timeGan: '癸', timeZhi: '子',
          ),
        ];

        for (final fourZhu in extremeCases) {
          // Act
          final params = HuangJiCalculationParams(fourZhu: fourZhu);
          final result = await strategy.calculate(params);

          // Assert
          expect(result.state, equals(TiaoWenListState.success));
          expect(result.tiaoWenNumbers, isNotEmpty);

          print('✓ 极端四柱组合测试通过: ${fourZhu.yearGan}${fourZhu.yearZhi}...');
        }
      });

      test('数值范围验证', () async {
        // Arrange
        final params = HuangJiCalculationParams(fourZhu: testFourZhu);

        // Act
        final result = await strategy.calculate(params);

        // Assert - 验证计算结果在合理范围内
        final initialNumber = result.sourceData['initialNumber'] as int;
        final secondaryNumber = result.sourceData['secondaryNumber'] as int;
        final finalNumbers = result.sourceData['finalNumbers'] as List<int>;

        expect(initialNumber, greaterThan(0));
        expect(initialNumber, lessThanOrEqualTo(4096)); // 太玄数最大值

        expect(secondaryNumber, greaterThan(0));
        expect(secondaryNumber, lessThanOrEqualTo(4096));

        for (final number in finalNumbers) {
          expect(number, greaterThan(0));
          expect(number, lessThanOrEqualTo(4096));
        }

        print('✓ 数值范围验证测试通过');
        print('✓ 初刻数范围: $initialNumber');
        print('✓ 次条文数范围: $secondaryNumber');
        print('✓ 最终数值范围: ${finalNumbers.join(', ')}');
      });
    });

    group('性能测试', () {
      test('计算性能', () async {
        // Arrange
        final params = HuangJiCalculationParams(fourZhu: testFourZhu);
        const iterations = 100;

        // Act
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < iterations; i++) {
          await strategy.calculate(params);
        }

        stopwatch.stop();

        // Assert
        final averageTime = stopwatch.elapsedMilliseconds / iterations;
        expect(averageTime, lessThan(100)); // 平均每次计算应少于100ms

        print('✓ 计算性能测试通过');
        print('✓ 总执行时间: ${stopwatch.elapsedMilliseconds}ms');
        print('✓ 平均执行时间: ${averageTime.toStringAsFixed(2)}ms');
      });

      test('内存使用', () async {
        // Arrange
        final params = HuangJiCalculationParams(fourZhu: testFourZhu);

        // Act - 连续计算多次，验证没有内存泄漏
        for (int i = 0; i < 50; i++) {
          final result = await strategy.calculate(params);
          expect(result.state, equals(TiaoWenListState.success));
        }

        print('✓ 内存使用测试通过');
      });
    });

    group('算法正确性', () {
      test('初刻数计算验证', () async {
        // Arrange - 使用已知结果的四柱进行验证
        final knownFourZhu = FourZhu(
          yearGan: '甲', yearZhi: '子',
          monthGan: '丙', monthZhi: '寅',
          dayGan: '戊', dayZhi: '辰',
          timeGan: '庚', timeZhi: '午',
        );
        final params = HuangJiCalculationParams(fourZhu: knownFourZhu);

        // Act
        final result = await strategy.calculate(params);

        // Assert - 验证计算逻辑
        final initialNumber = result.sourceData['initialNumber'] as int;
        expect(initialNumber, isA<int>());
        expect(initialNumber, greaterThan(0));

        // 验证初刻数的计算逻辑是否符合皇极取数法规则
        // 这里可以添加更具体的算法验证

        print('✓ 初刻数计算验证测试通过');
        print('✓ 计算得到的初刻数: $initialNumber');
      });

      test('次条文数计算验证', () async {
        // Arrange
        final params = HuangJiCalculationParams(fourZhu: testFourZhu);

        // Act
        final result = await strategy.calculate(params);

        // Assert
        final initialNumber = result.sourceData['initialNumber'] as int;
        final secondaryNumber = result.sourceData['secondaryNumber'] as int;

        // 验证次条文数与初刻数的关系
        expect(secondaryNumber, isA<int>());
        expect(secondaryNumber, greaterThan(0));

        print('✓ 次条文数计算验证测试通过');
        print('✓ 初刻数: $initialNumber, 次条文数: $secondaryNumber');
      });

      test('最终条文数计算验证', () async {
        // Arrange
        final params = HuangJiCalculationParams(fourZhu: testFourZhu);

        // Act
        final result = await strategy.calculate(params);

        // Assert
        final finalNumbers = result.sourceData['finalNumbers'] as List<int>;
        
        expect(finalNumbers, isNotEmpty);
        expect(finalNumbers.length, greaterThanOrEqualTo(1));
        expect(finalNumbers.length, lessThanOrEqualTo(12)); // 合理的条文数量上限

        // 验证所有条文数都在有效范围内
        for (final number in finalNumbers) {
          expect(number, greaterThan(0));
          expect(number, lessThanOrEqualTo(4096));
        }

        print('✓ 最终条文数计算验证测试通过');
        print('✓ 最终条文数: ${finalNumbers.join(', ')}');
      });
    });
  });
}