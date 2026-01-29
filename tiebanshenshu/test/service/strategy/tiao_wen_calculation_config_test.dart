/// TiaoWenCalculationConfig 工具方法测试
///
/// 测试新添加的条文计算配置工厂方法
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/base_calculation_strategy.dart';

void main() {
  group('GenericTiaoWenCalculationConfig.increment96x4 测试', () {
    late GenericTiaoWenCalculationConfig config;

    setUp(() {
      config = GenericTiaoWenCalculationConfig.increment96x4();
    });

    test('配置名称和描述正确', () {
      expect(config.name, '递增96四次');
      expect(config.description, contains('递增96四次'));
    });

    test('calculationList 包含正确的偏移量', () {
      expect(config.calculationList, [0, 96, 192, 288, 384]);
    });

    test('withSub 应该为 false', () {
      expect(config.withSub, false);
    });

    test('计算条文列表应该递增96', () {
      final baseNumber = 3387;
      final result = config.calculateTiaoWenList(baseNumber, {});

      // 期望结果：[3387, 3483, 3579, 3675, 3771]
      expect(result, [3387, 3483, 3579, 3675, 3771]);
      expect(result.length, 5, reason: '应该生成5个条文编号');
    });

    test('不同基础数计算结果正确', () {
      final baseNumber = 2000;
      final result = config.calculateTiaoWenList(baseNumber, {});

      expect(result, [2000, 2096, 2192, 2288, 2384]);
    });
  });

  group('GenericTiaoWenCalculationConfig.decrement96x4 测试', () {
    late GenericTiaoWenCalculationConfig config;

    setUp(() {
      config = GenericTiaoWenCalculationConfig.decrement96x4();
    });

    test('配置名称和描述正确', () {
      expect(config.name, '递减96四次');
      expect(config.description, contains('递减96四次'));
    });

    test('calculationList 包含正确的负偏移量', () {
      expect(config.calculationList, [0, -96, -192, -288, -384]);
    });

    test('withSub 应该为 false', () {
      expect(config.withSub, false);
    });

    test('计算条文列表应该递减96', () {
      final baseNumber = 2477;
      final result = config.calculateTiaoWenList(baseNumber, {});

      // 期望结果：[2477, 2381, 2285, 2189, 2093]
      expect(result, [2477, 2381, 2285, 2189, 2093]);
      expect(result.length, 5, reason: '应该生成5个条文编号');
    });

    test('不同基础数计算结果正确', () {
      final baseNumber = 3000;
      final result = config.calculateTiaoWenList(baseNumber, {});

      expect(result, [3000, 2904, 2808, 2712, 2616]);
    });
  });

  group('GenericTiaoWenCalculationConfig.addSub48x 测试', () {
    test('默认配置参数正确', () {
      final config = GenericTiaoWenCalculationConfig.addSub48x();

      expect(config.name, '加减48倍数');
      expect(config.description, contains('48×倍数'));
      expect(config.withSub, true, reason: 'withSub应该为true以实现加减');
    });

    test('默认倍数 [2,4,8,16] 生成正确的calculationList', () {
      final config = GenericTiaoWenCalculationConfig.addSub48x();

      // 默认：includeBase=true, multiples=[2,4,8,16]
      // calculationList = [0, 48*2, 48*4, 48*8, 48*16]
      //                = [0, 96, 192, 384, 768]
      expect(config.calculationList, [0, 96, 192, 384, 768]);
    });

    test('计算条文列表应该包含加减48倍数', () {
      final config = GenericTiaoWenCalculationConfig.addSub48x();
      final baseNumber = 3198;
      final result = config.calculateTiaoWenList(baseNumber, {});

      // withSub=true，所以会生成：
      // calculationList = [0, 96, 192, 384, 768]
      // 加法: [3198+0, 3198+96, 3198+192, 3198+384, 3198+768]
      //     = [3198, 3294, 3390, 3582, 3966]
      // 减法: [3198-0, 3198-96, 3198-192, 3198-384, 3198-768]
      //     = [3198, 3102, 3006, 2814, 2430]
      // 合并：[3198, 3294, 3390, 3582, 3966, 3198, 3102, 3006, 2814, 2430]
      // 注意：3198出现两次（offset=0时，加法和减法结果相同）

      expect(result.length, 10, reason: '应该生成10个条文编号（包含重复的基础数）');
      expect(result, containsAll([3198, 3294, 3390, 3582, 3966]),
          reason: '应该包含所有加法结果');
      expect(result, containsAll([3102, 3006, 2814, 2430]),
          reason: '应该包含所有减法结果');

      // 验证基础数出现了2次
      expect(result.where((n) => n == 3198).length, 2,
          reason: '基础数3198应该出现2次');
    });

    test('includeBase=false 时不包含基础数', () {
      final config = GenericTiaoWenCalculationConfig.addSub48x(
        includeBase: false,
      );
      final baseNumber = 3000;
      final result = config.calculateTiaoWenList(baseNumber, {});

      // calculationList = [96, 192, 384, 768] (不包含0)
      // withSub=true，所以结果包含加减
      expect(result, isNot(contains(3000)), reason: 'includeBase=false时不应包含基础数');
      expect(result.length, 8, reason: '应该生成8个条文编号（4个减法+4个加法）');
    });

    test('自定义倍数计算正确', () {
      final config = GenericTiaoWenCalculationConfig.addSub48x(
        multiples: [1, 3, 5],
        includeBase: true,
      );

      // calculationList = [0, 48*1, 48*3, 48*5]
      //                = [0, 48, 144, 240]
      expect(config.calculationList, [0, 48, 144, 240]);

      final baseNumber = 1000;
      final result = config.calculateTiaoWenList(baseNumber, {});

      // 加法：[1000+0, 1000+48, 1000+144, 1000+240] = [1000, 1048, 1144, 1240]
      // 减法：[1000-0, 1000-48, 1000-144, 1000-240] = [1000, 952, 856, 760]
      // 合并：[1000, 1048, 1144, 1240, 1000, 952, 856, 760]
      // 注意：1000出现两次
      expect(result.length, 8, reason: '应该生成8个条文编号（包含重复的基础数）');
      expect(result, containsAll([1000, 1048, 1144, 1240, 952, 856, 760]));

      // 验证基础数出现了2次
      expect(result.where((n) => n == 1000).length, 2,
          reason: '基础数1000应该出现2次');
    });
  });

  group('GenericTiaoWenCalculationConfig 集成测试', () {
    test('increment96x4 和 decrement96x4 可以组合使用', () {
      final incrementConfig = GenericTiaoWenCalculationConfig.increment96x4();
      final decrementConfig = GenericTiaoWenCalculationConfig.decrement96x4();

      final baseNumber = 2500;

      final incrementResult = incrementConfig.calculateTiaoWenList(baseNumber, {});
      final decrementResult = decrementConfig.calculateTiaoWenList(baseNumber, {});

      // 两个结果应该不重复（除了基础数）
      final combined = {...incrementResult, ...decrementResult};
      expect(combined.length, 9, reason: '组合后应该有9个唯一条文编号');
      expect(combined, contains(2500), reason: '都包含基础数');
    });

    test('三种配置都能正常工作', () {
      final configs = [
        GenericTiaoWenCalculationConfig.increment96x4(),
        GenericTiaoWenCalculationConfig.decrement96x4(),
        GenericTiaoWenCalculationConfig.addSub48x(),
      ];

      for (final config in configs) {
        final result = config.calculateTiaoWenList(3000, {});
        expect(result, isNotEmpty, reason: '${config.name} 应该生成条文列表');
        expect(result, everyElement(isA<int>()), reason: '所有元素应该是整数');
      }
    });
  });
}
