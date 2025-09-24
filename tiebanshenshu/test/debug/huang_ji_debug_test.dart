/// 皇极交互调试测试
///
/// 用于验证调试日志和问题诊断
library;

import 'package:common/dev_constant.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/domain/models/huang_ji_calculation_params.dart';
import 'package:tiebanshenshu/service/strategy/huang_ji_calculation_strategy.dart';
import 'package:tiebanshenshu/service/strategy/huang_ji_interactive_strategy.dart';
import 'package:tiebanshenshu/application/usecases/huang_ji_interactive_use_case.dart';
import 'package:tiebanshenshu/presentation/viewmodels/huang_ji_interactive_view_model.dart';

void main() {
  group('皇极交互调试测试', () {
    late HuangJiCalculationStrategy calculationStrategy;
    late HuangJiInteractiveStrategy interactiveStrategy;
    late HuangJiInteractiveUseCase useCase;
    late HuangJiInteractiveViewModel viewModel;

    setUp(() {
      // 初始化测试组件
      calculationStrategy = HuangJiCalculationStrategy();
      // 注意：这里需要根据实际的依赖注入方式来初始化
      // interactiveStrategy = HuangJiInteractiveStrategy(calculationStrategy, repository);
      // useCase = HuangJiInteractiveUseCase(interactiveStrategy);
      // viewModel = HuangJiInteractiveViewModel(useCase);
    });

    testWidgets('测试皇极计算策略调试日志', (WidgetTester tester) async {
      // 创建测试八字
      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      final params = HuangJiCalculationParams(eightChars: eightChars);

      // 执行计算并观察调试日志
      expect(() => calculationStrategy.calculate(params), returnsNormally);
    });

    // test('测试八字参数创建', () {
    //   final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

    //   expect(eightChars.year, equals('甲子'));
    //   expect(eightChars.month, equals('乙丑'));
    //   expect(eightChars.day, equals('丙寅'));
    //   expect(eightChars.hour, equals('丁卯'));
    // });

    test('测试计算参数创建', () {
      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      final params = HuangJiCalculationParams(eightChars: eightChars);
      expect(params.eightChars, equals(eightChars));
    });
  });
}
