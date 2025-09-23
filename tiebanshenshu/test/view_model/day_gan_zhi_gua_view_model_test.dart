import 'package:flutter_test/flutter_test.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/shared/enums/enum_jia_zi.dart';
import 'package:common/dev_constant.dart';
import 'package:tiebanshenshu/domain/models/tiao_wen_list_state.dart';

import '../../lib/service/strategy/day_gan_zhi_gua_strategy.dart';
import '../../lib/usecases/day_gan_zhi_gua_tiao_wen_list_use_case.dart';
import '../../lib/presentation/viewmodels/day_gan_zhi_gua_view_model.dart';

/// 日干支卦ViewModel测试
void main() {
  group('DayGanZhiGuaViewModel Tests', () {
    late DayGanZhiGuaViewModel viewModel;
    late DayGanZhiGuaTiaoWenListUseCase useCase;
    late DayGanZhiGuaStrategy strategy;

    setUp(() {
      strategy = DayGanZhiGuaStrategy();
      useCase = DayGanZhiGuaTiaoWenListUseCase(strategy);
      viewModel = DayGanZhiGuaViewModel(useCase);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('初始状态验证', () {
      // Assert
      expect(viewModel.state, equals(TiaoWenListState.initial));
      expect(viewModel.selectedDayGanZhi, isNull);
      expect(viewModel.hasSelection, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.hasResult, isFalse);
      expect(viewModel.dayGanZhiDisplayText, equals('未选择'));

      print('✓ 初始状态正确');
    });

    test('设置日干支并计算条文列表', () async {
      // Arrange
      final dayGanZhi = DevConstant.dev_usa.standeredChineseInfo.eightChars.day;
      bool stateChanged = false;

      viewModel.addListener(() {
        stateChanged = true;
      });

      print('测试数据 - 日柱: ${dayGanZhi.name}');

      // Act
      await viewModel.setDayGanZhi(dayGanZhi);

      // Assert
      expect(stateChanged, isTrue);
      expect(viewModel.selectedDayGanZhi, equals(dayGanZhi));
      expect(viewModel.hasSelection, isTrue);
      expect(viewModel.dayGanZhiDisplayText, equals(dayGanZhi.name));
      expect(viewModel.state, equals(TiaoWenListState.success));
      expect(viewModel.hasResult, isTrue);
      expect(viewModel.tiaoWenCount, greaterThan(0));

      print('✓ 设置日干支成功');
      print('✓ 计算结果: ${viewModel.result?.tiaoWenNumbers}');
    });

    test('从八字设置日干支', () async {
      // Arrange
      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      print('测试数据 - 八字: ${eightChars.toString()}');

      // Act
      await viewModel.setFromEightChars(eightChars);

      // Assert
      expect(viewModel.selectedDayGanZhi, equals(eightChars.day));
      expect(viewModel.hasSelection, isTrue);
      expect(viewModel.state, equals(TiaoWenListState.success));

      print('✓ 从八字设置日干支成功');
      print('✓ 提取的日柱: ${viewModel.selectedDayGanZhi?.name}');
    });

    test('清除选择', () async {
      // Arrange - 先设置一个日干支
      final dayGanZhi = JiaZi.JIA_ZI;
      await viewModel.setDayGanZhi(dayGanZhi);

      expect(viewModel.hasSelection, isTrue);
      expect(viewModel.hasResult, isTrue);

      // Act
      viewModel.clearSelection();

      // Assert
      expect(viewModel.selectedDayGanZhi, isNull);
      expect(viewModel.hasSelection, isFalse);
      expect(viewModel.state, equals(TiaoWenListState.initial));
      expect(viewModel.hasResult, isFalse);
      expect(viewModel.dayGanZhiDisplayText, equals('未选择'));

      print('✓ 清除选择成功');
    });

    test('刷新功能', () async {
      // Arrange
      final dayGanZhi = JiaZi.YI_CHOU;
      await viewModel.setDayGanZhi(dayGanZhi);

      final originalResult = viewModel.result;
      expect(originalResult, isNotNull);

      // Act
      await viewModel.refresh();

      // Assert
      expect(viewModel.state, equals(TiaoWenListState.success));
      expect(viewModel.hasResult, isTrue);
      expect(
        viewModel.result?.tiaoWenNumbers,
        equals(originalResult?.tiaoWenNumbers),
      );

      print('✓ 刷新功能正常');
    });

    test('状态变化监听', () async {
      // Arrange
      final states = <TiaoWenListState>[];
      viewModel.addListener(() {
        states.add(viewModel.state);
      });

      // Act
      await viewModel.setDayGanZhi(JiaZi.BING_YIN);

      // Assert
      expect(states, contains(TiaoWenListState.loading));
      expect(states, contains(TiaoWenListState.success));
      expect(states.last, equals(TiaoWenListState.success));

      print('✓ 状态变化监听正常');
      print('✓ 状态变化序列: ${states}');
    });

    test('toString方法', () {
      // Act
      final stringRepresentation = viewModel.toString();

      // Assert
      expect(stringRepresentation, contains('DayGanZhiGuaViewModel'));
      expect(stringRepresentation, contains('selectedDayGanZhi'));
      expect(stringRepresentation, contains('hasSelection'));

      print('✓ toString方法正常: $stringRepresentation');
    });
  });
}
