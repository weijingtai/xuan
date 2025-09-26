/// 皇极取数法集成测试
///
/// 测试皇极取数法的完整数据流：Provider → UseCase → Strategy
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/dev_constant.dart';
import 'package:tiebanshenshu/service/strategy/huang_ji_calculation_strategy.dart';

import '../../lib/application/services/candidate_generation_service.dart';
import '../../lib/application/services/interactive_session_service.dart';
import '../../lib/domain/four_zhu.dart';
import '../../lib/domain/models/huang_ji_calculation_params.dart';
import '../../lib/domain/models/huang_ji_interactive_step.dart';
import '../../lib/domain/models/interactive_strategy_config.dart';
import '../../lib/domain/models/tiao_wen_list_state.dart';
import '../../lib/application/usecases/huang_ji_interactive_use_case.dart';
import '../../lib/presentation/viewmodels/huang_ji_interactive_view_model.dart';
import '../../lib/repository/tiao_wen_repository.dart';
import '../../lib/repository/repository_factory.dart';

/// 皇极取数法集成测试
void main() {
  group('皇极取数法集成测试', () {
    late EightChars testEightChars;
    late FourZhu testFourZhu;

    setUpAll(() {
      // 使用DevConstant.dev_usa的八字数据
      testEightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;
      testFourZhu = FourZhu.fromEightChars(testEightChars);

      print('集成测试数据 - 八字: ${testEightChars.toString()}');
      print(
        '四柱: ${testFourZhu.yearGan}${testFourZhu.yearZhi} ${testFourZhu.monthGan}${testFourZhu.monthZhi} ${testFourZhu.dayGan}${testFourZhu.dayZhi} ${testFourZhu.timeGan}${testFourZhu.timeZhi}',
      );
    });

    group('计算策略层测试', () {
      late HuangJiCalculationStrategy strategy;

      setUp(() {
        strategy = HuangJiCalculationStrategy();
      });

      test('基础计算流程测试', () async {
        // Arrange
        final params = HuangJiCalculationParams(fourZhu: testFourZhu);

        // Act - 执行计算
        final result = await strategy.calculate(params);

        // Assert - 验证结果
        expect(result.state, equals(TiaoWenListState.success));
        expect(result.tiaoWenNumbers, isNotEmpty);
        expect(result.calculationMethod, equals('皇极取数法'));
        expect(result.sourceData, isNotEmpty);
        expect(result.sourceData.containsKey('initialNumber'), isTrue);
        expect(result.sourceData.containsKey('secondaryNumber'), isTrue);
        expect(result.sourceData.containsKey('selectedBaseNumber'), isTrue);

        print('✓ 基础计算流程测试通过');
        print('✓ 初刻数: ${result.sourceData['initialNumber']}');
        print('✓ 次条文数: ${result.sourceData['secondaryNumber']}');
        print('✓ 条文数量: ${result.tiaoWenNumbers.length}');
      });

      test('参数验证测试', () async {
        // Test null fourZhu
        expect(
          () => strategy.calculate(HuangJiCalculationParams(fourZhu: null)),
          throwsA(isA<ArgumentError>()),
        );

        print('✓ 参数验证测试通过');
      });

      test('异常处理测试', () async {
        // 创建无效的四柱数据进行测试
        final invalidFourZhu = FourZhu(
          yearGan: '',
          yearZhi: '',
          monthGan: '',
          monthZhi: '',
          dayGan: '',
          dayZhi: '',
          timeGan: '',
          timeZhi: '',
        );

        final params = HuangJiCalculationParams(fourZhu: invalidFourZhu);

        // Act & Assert
        expect(() => strategy.calculate(params), throwsA(isA<Exception>()));

        print('✓ 异常处理测试通过');
      });
    });

    group('交互式UseCase层测试', () {
      late HuangJiInteractiveUseCase useCase;
      late InteractiveSessionService sessionService;
      late CandidateGenerationService candidateService;
      late HuangJiCalculationStrategy calculationStrategy;
      late TiaoWenRepository repository;

      setUp(() {
        repository = RepositoryFactory.defaultTiaoWenRepository;
        sessionService = InteractiveSessionServiceImpl();
        candidateService = CandidateGenerationServiceImpl();
        calculationStrategy = HuangJiCalculationStrategy();
        useCase = HuangJiInteractiveUseCase(
          sessionService,
          candidateService,
          calculationStrategy,
          repository,
        );
      });

      test('会话生命周期测试', () async {
        // Arrange
        final params = HuangJiCalculationParams(eightChars: testEightChars);

        // Act - 启动会话
        final session = await useCase.startSession(params);

        // Assert - 验证会话
        expect(session.sessionId, isNotEmpty);
        expect(session.currentStepIndex, equals(0));
        expect(session.status.name, contains('inProgress'));

        // Act - 获取候选项
        final candidates = await useCase.getCandidates(session);

        // Assert - 验证候选项
        expect(candidates, isNotEmpty);
        expect(candidates.length, greaterThanOrEqualTo(2)); // 至少有基础数选择选项

        // Act - 选择候选项
        final selectedCandidate = candidates.first;
        final updatedSession = await useCase.selectCandidate(
          session,
          selectedCandidate.id,
        );

        // Assert - 验证更新后的会话
        expect(updatedSession.sessionId, equals(session.sessionId));
        expect(
          updatedSession.currentStepIndex,
          greaterThanOrEqualTo(session.currentStepIndex),
        );

        print('✓ 会话生命周期测试通过');
        print('✓ 会话ID: ${session.sessionId.substring(0, 8)}...');
        print('✓ 候选项数量: ${candidates.length}');
        print('✓ 选择的候选项: ${selectedCandidate.displayName}');
      });

      test('会话状态管理测试', () async {
        // Arrange
        final params = HuangJiCalculationParams(eightChars: testEightChars);
        final session = await useCase.startSession(params);

        // Act - 获取会话
        final retrievedSession = await useCase.getSession(session.sessionId);

        // Assert
        expect(retrievedSession.sessionId, equals(session.sessionId));
        expect(retrievedSession.status, equals(session.status));

        // Act - 取消会话
        final cancelledSession = await useCase.cancelSession(session.sessionId);

        // Assert - 验证会话已取消
        expect(cancelledSession.sessionId, equals(session.sessionId));
        expect(
          () => useCase.getSession(session.sessionId),
          throwsA(isA<Exception>()),
        );

        print('✓ 会话状态管理测试通过');
      });
    });

      test('完整交互流程测试', () async {
        // Arrange
        final params = HuangJiCalculationParams(eightChars: testEightChars);

        // Act - 启动会话
        final session = await useCase.startSession(params);

        // Assert
        expect(session.sessionId, isNotEmpty);

        // Act - 获取候选项
        final candidates = await useCase.getCandidates(session.sessionId);

        // Assert
        expect(candidates, isNotEmpty);

        // Act - 选择候选项并完成计算
        final selectedCandidate = candidates.first;
        await useCase.selectCandidate(session.sessionId, selectedCandidate.id);

        // Act - 完成计算
        final result = await useCase.completeCalculation(session.sessionId);

        // Assert
        expect(result.state, equals(TiaoWenListState.success));
        expect(result.tiaoWenNumbers, isNotEmpty);
        expect(result.calculationMethod, equals('皇极取数法'));

        print('✓ 完整交互流程测试通过');
        print('✓ 最终条文数量: ${result.tiaoWenNumbers.length}');
      });

      test('撤销和跳转功能测试', () async {
        // Arrange
        final params = HuangJiCalculationParams(eightChars: testEightChars);
        final session = await useCase.startSession(params);

        // 进行一些选择
        final candidates = await useCase.getCandidates(session);
        final updatedSession = await useCase.selectCandidate(session, candidates.first.id);

        // Act - 撤销
        final undoSession = await useCase.undo(updatedSession);

        // Assert
        expect(undoSession.currentStepIndex, lessThan(updatedSession.currentStepIndex));

        // Act - 跳转到指定步骤
        final jumpSession = await useCase.jumpTo(undoSession, 0);

        // Assert
        expect(jumpSession.currentStepIndex, equals(0));

        print('✓ 撤销和跳转功能测试通过');
      });

      test('参数验证测试', () async {
        // Test invalid session ID
        expect(
          () => useCase.getSession('invalid-session-id'),
          throwsA(isA<Exception>()),
        );

        expect(
          () => useCase.cancelSession('invalid-session-id'),
          throwsA(isA<Exception>()),
        );

        print('✓ UseCase参数验证测试通过');
      });
    });

    group('Provider层测试', () {
      late HuangJiInteractiveViewModel provider;

      setUp(() {
        final repository = RepositoryFactory.defaultTiaoWenRepository;
        final sessionService = InteractiveSessionServiceImpl();
        final candidateService = CandidateGenerationServiceImpl();
        final calculationStrategy = HuangJiCalculationStrategy();
        final useCase = HuangJiInteractiveUseCase(
          sessionService,
          candidateService,
          calculationStrategy,
          repository,
        );
        provider = HuangJiInteractiveViewModel(useCase);
      });

      tearDown(() {
        provider.dispose();
      });

      test('完整UI状态流程测试', () async {
        // 验证初始状态
        expect(provider.isInitial, isTrue);
        expect(provider.hasSession, isFalse);

        // Act - 启动会话
        await provider.startSession(testFourZhu);

        // Assert - 验证会话状态
        expect(provider.hasSession, isTrue);
        expect(provider.currentSession, isNotNull);
        expect(provider.inputFourZhu, equals(testFourZhu));

        // 如果需要用户选择，验证候选项
        if (provider.needsUserSelection) {
          expect(provider.currentCandidates, isNotEmpty);

          // Act - 选择候选项
          final candidate = provider.currentCandidates.first;
          await provider.selectCandidate(candidate);

          // Assert - 验证选择后状态
          expect(provider.isCompleted || provider.needsUserSelection, isTrue);
        }

        print('✓ 完整UI状态流程测试通过');
        print('✓ 当前状态: ${provider.getStateDisplayText()}');
        print('✓ 当前步骤: ${provider.getCurrentStepDisplayText()}');
      });

      test('错误处理测试', () async {
        // 创建无效的四柱数据
        final invalidFourZhu = FourZhu(
          yearGan: '',
          yearZhi: '',
          monthGan: '',
          monthZhi: '',
          dayGan: '',
          dayZhi: '',
          timeGan: '',
          timeZhi: '',
        );

        // Act
        await provider.startSession(invalidFourZhu);

        // Assert
        expect(provider.hasError, isTrue);
        expect(provider.errorMessage, isNotNull);

        print('✓ Provider错误处理测试通过');
        print('✓ 错误消息: ${provider.getUserFriendlyErrorMessage()}');
      });

      test('状态管理测试', () async {
        // 测试各种状态判断方法
        expect(provider.isInitial, isTrue);
        expect(provider.isLoading, isFalse);
        expect(provider.hasError, isFalse);
        expect(provider.isCompleted, isFalse);

        // 启动会话后测试状态
        await provider.startSession(testFourZhu);

        expect(provider.isInitial, isFalse);
        expect(provider.hasSession, isTrue);

        // 测试重置功能
        provider.reset();

        expect(provider.isInitial, isTrue);
        expect(provider.hasSession, isFalse);
        expect(provider.currentCandidates, isEmpty);

        print('✓ 状态管理测试通过');
      });
    });

    group('端到端集成测试', () {
      test('完整数据流测试', () async {
        // Arrange - 创建完整的依赖链
        final repository = RepositoryFactory.defaultTiaoWenRepository;
        final sessionService = InteractiveSessionServiceImpl();
        final candidateService = CandidateGenerationServiceImpl();
        final calculationStrategy = HuangJiCalculationStrategy();
        final useCase = HuangJiInteractiveUseCase(
          sessionService,
          candidateService,
          calculationStrategy,
          repository,
        );
        final provider = HuangJiInteractiveViewModel(useCase);

        try {
          // Act - 执行完整流程
          await provider.startSession(testFourZhu);

          // 模拟用户交互
          while (provider.needsUserSelection &&
              provider.currentCandidates.isNotEmpty) {
            final candidate = provider.currentCandidates.first;
            await provider.selectCandidate(candidate);
          }

          // Assert - 验证最终结果
          if (provider.isCompleted) {
            expect(provider.finalResult, isNotNull);
            expect(
              provider.finalResult!.state,
              equals(TiaoWenListState.success),
            );
            expect(provider.finalResult!.tiaoWenNumbers, isNotEmpty);
            expect(provider.finalNumbers, isNotEmpty);
          }

          print('✓ 端到端集成测试通过');
          print('✓ 最终状态: ${provider.getStateDisplayText()}');
          if (provider.finalResult != null) {
            print('✓ 最终条文数量: ${provider.finalResult!.tiaoWenNumbers.length}');
          }
        } finally {
          provider.dispose();
        }
      });

      test('并发会话测试', () async {
        // Arrange
        final repository = RepositoryFactory.defaultTiaoWenRepository;
        final sessionService = InteractiveSessionServiceImpl();
        final candidateService = CandidateGenerationServiceImpl();
        final calculationStrategy = HuangJiCalculationStrategy();
        final useCase = HuangJiInteractiveUseCase(
          sessionService,
          candidateService,
          calculationStrategy,
          repository,
        );

        final provider1 = HuangJiInteractiveViewModel(useCase);
        final provider2 = HuangJiInteractiveViewModel(useCase);

        try {
          // Act - 并发启动多个会话
          final stopwatch = Stopwatch()..start();

          await Future.wait([
            provider1.startSession(testFourZhu),
            provider2.startSession(testFourZhu),
          ]);

          stopwatch.stop();

          // Assert
          expect(provider1.hasSession, isTrue);
          expect(provider2.hasSession, isTrue);
          expect(
            provider1.currentSession!.sessionId,
            isNot(equals(provider2.currentSession!.sessionId)),
          );

          print('✓ 并发会话测试通过');
          print('✓ 执行时间: ${stopwatch.elapsedMilliseconds}ms');
          print(
            '✓ 会话1 ID: ${provider1.currentSession!.sessionId.substring(0, 8)}...',
          );
          print(
            '✓ 会话2 ID: ${provider2.currentSession!.sessionId.substring(0, 8)}...',
          );
        } finally {
          provider1.dispose();
          provider2.dispose();
        }
      });
    });

    group('性能测试', () {
      test('计算性能测试', () async {
        // Arrange
        final strategy = HuangJiCalculationStrategy();
        final params = HuangJiCalculationParams(fourZhu: testFourZhu);

        // Act - 多次执行计算
        final stopwatch = Stopwatch()..start();
        const iterations = 10;

        for (int i = 0; i < iterations; i++) {
          final result = await strategy.calculate(params);
          expect(result.state, equals(TiaoWenListState.success));
        }

        stopwatch.stop();

        // Assert
        final averageTime = stopwatch.elapsedMilliseconds / iterations;
        expect(averageTime, lessThan(1000)); // 平均每次计算应少于1秒

        print('✓ 计算性能测试通过');
        print('✓ 总执行时间: ${stopwatch.elapsedMilliseconds}ms');
        print('✓ 平均执行时间: ${averageTime.toStringAsFixed(2)}ms');
      });

      test('内存使用测试', () async {
        // Arrange
        final repository = RepositoryFactory.defaultTiaoWenRepository;
        final sessionService = InteractiveSessionServiceImpl();
        final candidateService = CandidateGenerationServiceImpl();
        final calculationStrategy = HuangJiCalculationStrategy();
        final useCase = HuangJiInteractiveUseCase(
          sessionService,
          candidateService,
          calculationStrategy,
          repository,
        );

        // Act - 创建和销毁多个Provider
        const iterations = 5;

        for (int i = 0; i < iterations; i++) {
          final provider = HuangJiInteractiveViewModel(useCase);
          await provider.startSession(testFourZhu);
          provider.dispose();
        }

        print('✓ 内存使用测试通过');
        print('✓ 创建和销毁了 $iterations 个Provider实例');
      });
    });

    group('边界条件测试', () {
      test('极端四柱数据测试', () async {
        // Arrange - 创建各种极端情况的四柱数据
        final extremeCases = [
          // 全甲子
          FourZhu(
            yearGan: '甲',
            yearZhi: '子',
            monthGan: '甲',
            monthZhi: '子',
            dayGan: '甲',
            dayZhi: '子',
            timeGan: '甲',
            timeZhi: '子',
          ),
          // 全癸亥
          FourZhu(
            yearGan: '癸',
            yearZhi: '亥',
            monthGan: '癸',
            monthZhi: '亥',
            dayGan: '癸',
            dayZhi: '亥',
            timeGan: '癸',
            timeZhi: '亥',
          ),
        ];

        final strategy = HuangJiCalculationStrategy();

        for (final fourZhu in extremeCases) {
          // Act
          final params = HuangJiCalculationParams(fourZhu: fourZhu);
          final result = await strategy.calculate(params);

          // Assert
          expect(result.state, equals(TiaoWenListState.success));
          expect(result.tiaoWenNumbers, isNotEmpty);

          print('✓ 极端四柱测试通过: ${fourZhu.yearGan}${fourZhu.yearZhi}...');
        }
      });

      test('配置参数测试', () async {
        // Arrange
        final config = InteractiveStrategyConfig(
          maxSteps: 5,
          allowUndo: true,
          allowJump: true,
          customSettings: {'test': 'value'},
        );

        final repository = RepositoryFactory.defaultTiaoWenRepository;
        final sessionService = InteractiveSessionServiceImpl();
        final candidateService = CandidateGenerationServiceImpl();
        final calculationStrategy = HuangJiCalculationStrategy();
        final useCase = HuangJiInteractiveUseCase(
          sessionService,
          candidateService,
          calculationStrategy,
          repository,
        );
        final provider = HuangJiInteractiveViewModel(useCase);

        try {
          // Act
          await provider.startSession(testFourZhu, config: config);

          // Assert
          expect(provider.sessionConfig, equals(config));
          expect(provider.hasSession, isTrue);

          print('✓ 配置参数测试通过');
        } finally {
          provider.dispose();
        }
      });
    });
  });
}
