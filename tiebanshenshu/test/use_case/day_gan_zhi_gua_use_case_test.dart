import 'package:flutter_test/flutter_test.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/shared/enums/enum_jia_zi.dart';
import 'package:common/dev_constant.dart';
import 'package:tiebanshenshu/domain/models/tiao_wen_list_state.dart';

import '../../lib/service/strategy/day_gan_zhi_gua_strategy.dart';
import '../../lib/usecases/day_gan_zhi_gua_tiao_wen_list_use_case.dart';

/// 日干支卦UseCase测试
void main() {
  group('DayGanZhiGuaTiaoWenListUseCase Tests', () {
    late DayGanZhiGuaTiaoWenListUseCase useCase;
    late DayGanZhiGuaStrategy strategy;

    setUp(() {
      strategy = DayGanZhiGuaStrategy();
      useCase = DayGanZhiGuaTiaoWenListUseCase(strategy);
    });

    test('使用DevConstant.dev_usa的日柱数据执行UseCase', () async {
      // Arrange - 从DevConstant.dev_usa提取日柱
      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;
      final dayGanZhi = eightChars.day;
      final params = DayGanZhiGuaUseCaseParams(dayGanZhi: dayGanZhi);

      print('测试数据 - 日柱: ${dayGanZhi.name}');

      // Act
      final result = await useCase.execute(params);

      // Assert
      expect(result.state, equals(TiaoWenListState.success));
      expect(result.tiaoWenNumbers, isNotEmpty);
      expect(result.calculationMethod, equals('日干支卦'));
      expect(result.sourceData['dayGanZhi'], equals(dayGanZhi.name));

      print('✓ 计算成功');
      print('✓ 条文编号: ${result.tiaoWenNumbers}');
      print('✓ 计算方法: ${result.calculationMethod}');
      print('✓ 源数据: ${result.sourceData}');
    });

    test('参数验证 - 空日干支应该抛出异常', () async {
      // Arrange
      final params = DayGanZhiGuaUseCaseParams(dayGanZhi: null);

      // Act & Assert
      final result = await useCase.execute(params);
      expect(result.state, equals(TiaoWenListState.error));
      expect(result.errorMessage, contains('日干支不能为空'));

      print('✓ 空参数验证通过');
    });

    test('测试不同日干支的计算结果', () async {
      // Arrange - 测试多个不同的日干支
      final testCases = [
        JiaZi.JIA_ZI,
        JiaZi.YI_CHOU,
        JiaZi.BING_YIN,
        JiaZi.DING_MAO,
        JiaZi.WU_CHEN,
      ];

      for (final dayGanZhi in testCases) {
        // Act
        final params = DayGanZhiGuaUseCaseParams(dayGanZhi: dayGanZhi);
        final result = await useCase.execute(params);

        // Assert
        expect(result.state, equals(TiaoWenListState.success));
        expect(result.tiaoWenNumbers, isNotEmpty);
        expect(result.sourceData['dayGanZhi'], equals(dayGanZhi.name));

        print('✓ ${dayGanZhi.name} -> 条文编号: ${result.tiaoWenNumbers}');
      }
    });

    test('验证结果数据结构完整性', () async {
      // Arrange
      final dayGanZhi = DevConstant.dev_usa.standeredChineseInfo.eightChars.day;
      final params = DayGanZhiGuaUseCaseParams(dayGanZhi: dayGanZhi);

      // Act
      final result = await useCase.execute(params);

      // Assert
      expect(result.state, isNotNull);
      expect(result.tiaoWenNumbers, isNotNull);
      expect(result.calculationMethod, isNotNull);
      expect(result.sourceData, isNotNull);
      expect(result.sourceData, isNotEmpty);
      expect(result.sourceData.containsKey('dayGanZhi'), isTrue);
      expect(result.sourceData.containsKey('tiaoWenNumber'), isTrue);

      print('✓ 结果数据结构完整');
      print('✓ 源数据键: ${result.sourceData.keys.toList()}');
    });
  });
}
