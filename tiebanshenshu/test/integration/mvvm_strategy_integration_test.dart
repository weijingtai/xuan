import 'package:flutter_test/flutter_test.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/dev_constant.dart';
import 'package:tiebanshenshu/domain/models/tiao_wen_list_state.dart';
import 'package:tiebanshenshu/usecases/day_gan_zhi_gua_tiao_wen_list_use_case.dart';
import 'package:tiebanshenshu/usecases/four_zhu_tian_gan_tiao_wen_list_use_case.dart';

import '../../lib/service/strategy/day_gan_zhi_gua_strategy.dart';
import '../../lib/service/strategy/four_zhu_tian_gan_strategy.dart';
import '../../lib/service/strategy/tai_xuan_four_zhu_strategy.dart';
import '../../lib/usecases/tai_xuan_four_zhu_tiao_wen_list_use_case.dart';
import '../../lib/presentation/viewmodels/day_gan_zhi_gua_view_model.dart';
import '../../lib/presentation/viewmodels/four_zhu_tian_gan_view_model.dart';
import '../../lib/presentation/viewmodels/tai_xuan_four_zhu_view_model.dart';

/// MVVM+UseCase Strategy架构集成测试
///
/// 测试完整的数据流：ViewModel → UseCase → Strategy
void main() {
  group('MVVM+UseCase Strategy Integration Tests', () {
    late EightChars testEightChars;

    setUpAll(() {
      // 使用DevConstant.dev_usa的八字数据
      testEightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;
      print('集成测试数据 - 八字: ${testEightChars.toString()}');
      print('日柱: ${testEightChars.day.name}');
    });

    group('日干支卦完整流程测试', () {
      late DayGanZhiGuaViewModel viewModel;

      setUp(() {
        final strategy = DayGanZhiGuaStrategy();
        final useCase = DayGanZhiGuaTiaoWenListUseCase(strategy);
        viewModel = DayGanZhiGuaViewModel(useCase);
      });

      tearDown(() {
        viewModel.dispose();
      });

      test('完整数据流测试', () async {
        // Act - 执行完整流程
        await viewModel.setFromEightChars(testEightChars);

        // Assert - 验证结果
        expect(viewModel.state, equals(TiaoWenListState.success));
        expect(viewModel.hasResult, isTrue);
        expect(viewModel.selectedDayGanZhi, equals(testEightChars.day));
        expect(viewModel.result?.calculationMethod, equals('日干支卦'));
        expect(viewModel.tiaoWenCount, greaterThan(0));

        print('✓ 日干支卦完整流程测试通过');
        print('✓ 条文数量: ${viewModel.tiaoWenCount}');
        print('✓ 条文编号: ${viewModel.result?.tiaoWenNumbers}');
      });
    });

    group('四柱天干完整流程测试', () {
      late FourZhuTianGanViewModel viewModel;

      setUp(() {
        final strategy = FourZhuTianGanStrategy();
        final useCase = FourZhuTianGanTiaoWenListUseCase(strategy);
        viewModel = FourZhuTianGanViewModel(useCase);
      });

      tearDown(() {
        viewModel.dispose();
      });

      test('完整数据流测试', () async {
        // Act - 执行完整流程
        await viewModel.setEightChars(testEightChars);

        // Assert - 验证结果
        expect(viewModel.state, equals(TiaoWenListState.success));
        expect(viewModel.hasResult, isTrue);
        expect(viewModel.selectedEightChars, equals(testEightChars));
        expect(viewModel.result?.calculationMethod, equals('四柱天干'));
        expect(viewModel.tiaoWenCount, greaterThan(0));

        print('✓ 四柱天干完整流程测试通过');
        print('✓ 条文数量: ${viewModel.tiaoWenCount}');
        print('✓ 天干列表: ${viewModel.allTianGanTexts}');
      });
    });

    group('太玄四柱完整流程测试', () {
      late TaiXuanFourZhuViewModel viewModel;

      setUp(() {
        final strategy = TaiXuanFourZhuStrategy();
        final useCase = TaiXuanFourZhuTiaoWenListUseCase(strategy);
        viewModel = TaiXuanFourZhuViewModel(useCase);
      });

      tearDown(() {
        viewModel.dispose();
      });

      test('完整数据流测试', () async {
        // Act - 执行完整流程
        await viewModel.setEightChars(testEightChars);

        // Assert - 验证结果
        expect(viewModel.state, equals(TiaoWenListState.success));
        expect(viewModel.hasResult, isTrue);
        expect(viewModel.selectedEightChars, equals(testEightChars));
        expect(viewModel.result?.calculationMethod, equals('太玄四柱'));
        expect(viewModel.tiaoWenCount, greaterThan(0));

        print('✓ 太玄四柱完整流程测试通过');
        print('✓ 条文数量: ${viewModel.tiaoWenCount}');
        print('✓ 柱列表: ${viewModel.allPillarTexts}');
        print('✓ 是否有多个结果: ${viewModel.hasMultipleResults}');
      });
    });

    group('性能测试', () {
      test('并发执行多个ViewModel', () async {
        // Arrange
        final dayGanZhiViewModel = DayGanZhiGuaViewModel(
          DayGanZhiGuaTiaoWenListUseCase(DayGanZhiGuaStrategy()),
        );
        final fourZhuTianGanViewModel = FourZhuTianGanViewModel(
          FourZhuTianGanTiaoWenListUseCase(FourZhuTianGanStrategy()),
        );
        final taiXuanFourZhuViewModel = TaiXuanFourZhuViewModel(
          TaiXuanFourZhuTiaoWenListUseCase(TaiXuanFourZhuStrategy()),
        );

        final stopwatch = Stopwatch()..start();

        // Act - 并发执行
        await Future.wait([
          dayGanZhiViewModel.setFromEightChars(testEightChars),
          fourZhuTianGanViewModel.setEightChars(testEightChars),
          taiXuanFourZhuViewModel.setEightChars(testEightChars),
        ]);

        stopwatch.stop();

        // Assert
        expect(dayGanZhiViewModel.state, equals(TiaoWenListState.success));
        expect(fourZhuTianGanViewModel.state, equals(TiaoWenListState.success));
        expect(taiXuanFourZhuViewModel.state, equals(TiaoWenListState.success));

        print('✓ 并发执行测试通过');
        print('✓ 执行时间: ${stopwatch.elapsedMilliseconds}ms');

        // Cleanup
        dayGanZhiViewModel.dispose();
        fourZhuTianGanViewModel.dispose();
        taiXuanFourZhuViewModel.dispose();
      });
    });
  });
}
