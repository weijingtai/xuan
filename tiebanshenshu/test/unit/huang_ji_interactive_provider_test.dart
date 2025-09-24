/// 皇极取数法交互式Provider单元测试
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/dev_constant.dart';

import '../../lib/domain/four_zhu.dart';
import '../../lib/domain/models/huang_ji_calculation_params.dart';
import '../../lib/domain/models/huang_ji_interactive_step.dart';
import '../../lib/domain/models/interactive_session.dart';
import '../../lib/domain/models/interactive_strategy_config.dart';
import '../../lib/domain/models/tiao_wen_candidate.dart';
import '../../lib/domain/models/tiao_wen_list_result.dart';
import '../../lib/domain/models/tiao_wen_list_state.dart';
import '../../lib/application/usecases/huang_ji_interactive_use_case.dart';
import '../../lib/presentation/viewmodels/huang_ji_interactive_view_model.dart';

// 生成Mock类
@GenerateMocks([HuangJiInteractiveUseCase])
import 'huang_ji_interactive_provider_test.mocks.dart';

void main() {
  group('HuangJiInteractiveProvider', () {
    late HuangJiInteractiveViewModel provider;
    late MockHuangJiInteractiveUseCase mockUseCase;
    late FourZhu testFourZhu;

    setUpAll(() {
      final testEightChars =
          DevConstant.dev_usa.standeredChineseInfo.eightChars;
      testFourZhu = FourZhu.fromEightChars(testEightChars);
    });

    setUp(() {
      mockUseCase = MockHuangJiInteractiveUseCase();
      provider = HuangJiInteractiveViewModel(mockUseCase);
    });

    tearDown(() {
      provider.dispose();
    });

    group('初始状态', () {
      test('初始状态正确', () {
        expect(provider.isInitial, isTrue);
        expect(provider.hasSession, isFalse);
        expect(provider.currentCandidates, isEmpty);
        expect(provider.finalResult, isNull);
        expect(provider.errorMessage, isNull);
        expect(provider.inputFourZhu, isNull);
        expect(
          provider.currentStep,
          equals(HuangJiInteractiveStep.initialization),
        );

        print('✓ 初始状态测试通过');
      });

      test('状态显示文本', () {
        expect(provider.getStateDisplayText(), equals('未开始'));
        expect(provider.getCurrentStepDisplayText(), equals('初始化'));
        expect(provider.getSessionDurationText(), equals('--'));

        print('✓ 状态显示文本测试通过');
      });
    });

    group('会话管理', () {
      test('启动会话成功', () async {
        // Arrange
        final mockSession = InteractiveSession(
          sessionId: 'test-session-id',
          strategyName: 'huang_ji',
          startTime: DateTime.now(),
          status: InteractiveSessionStatus.inProgress,
          steps: [],
          currentStepIndex: 0,
          sessionConfig: {
            'currentStep': 'userSelection',
            'initialNumber': 123,
            'secondaryNumber': 456,
            'params': HuangJiCalculationParams(fourZhu: testFourZhu).toJson(),
          },
        );

        when(
          mockUseCase.startSession(any, config: anyNamed('config')),
        ).thenAnswer((_) async => mockSession);

        // Act
        await provider.startSession(testFourZhu);

        // Assert
        expect(provider.hasSession, isTrue);
        expect(provider.currentSession, equals(mockSession));
        expect(provider.inputFourZhu, equals(testFourZhu));
        expect(provider.initialNumber, equals(123));
        expect(provider.secondaryNumber, equals(456));
        expect(
          provider.currentStep,
          equals(HuangJiInteractiveStep.userSelection),
        );

        verify(
          mockUseCase.startSession(any, config: anyNamed('config')),
        ).called(1);

        print('✓ 启动会话成功测试通过');
      });

      test('启动会话失败', () async {
        // Arrange
        when(
          mockUseCase.startSession(any, config: anyNamed('config')),
        ).thenThrow(Exception('启动会话失败'));

        // Act
        await provider.startSession(testFourZhu);

        // Assert
        expect(provider.hasError, isTrue);
        expect(provider.errorMessage, equals('启动会话失败'));
        expect(provider.hasSession, isFalse);

        print('✓ 启动会话失败测试通过');
      });

      test('取消会话', () async {
        // Arrange
        final mockSession = InteractiveSession(
          sessionId: 'test-session-id',
          strategyName: 'huang_ji',
          startTime: DateTime.now(),
          status: InteractiveSessionStatus.inProgress,
          steps: [],
          currentStepIndex: 0,
          sessionConfig: {
            'params': HuangJiCalculationParams(fourZhu: testFourZhu).toJson(),
          },
        );

        when(
          mockUseCase.startSession(any, config: anyNamed('config')),
        ).thenAnswer((_) async => mockSession);
        when(mockUseCase.cancelSession(any)).thenAnswer((_) async {});

        // Act
        await provider.startSession(testFourZhu);
        await provider.cancelSession();

        // Assert
        expect(provider.isCancelled, isTrue);
        expect(provider.hasSession, isFalse);

        verify(mockUseCase.cancelSession('test-session-id')).called(1);

        print('✓ 取消会话测试通过');
      });
    });

    group('候选项管理', () {
      test('加载候选项成功', () async {
        // Arrange
        final mockSession = InteractiveSession(
          sessionId: 'test-session-id',
          params: HuangJiCalculationParams(fourZhu: testFourZhu),
          currentStepIndex: 0,
          state: InteractiveSessionState.active,
          data: {'currentStep': 'userSelection'},
          createdAt: DateTime.now(),
        );

        final mockCandidates = [
          TiaoWenCandidate(
            id: 'candidate-1',
            displayText: '候选项1',
            value: 123,
            description: '描述1',
          ),
          TiaoWenCandidate(
            id: 'candidate-2',
            displayText: '候选项2',
            value: 456,
            description: '描述2',
          ),
        ];

        when(
          mockUseCase.startSession(any, config: anyNamed('config')),
        ).thenAnswer((_) async => mockSession);
        when(
          mockUseCase.getCandidates(any),
        ).thenAnswer((_) async => mockCandidates);

        // Act
        await provider.startSession(testFourZhu);

        // Assert
        expect(provider.currentCandidates, equals(mockCandidates));
        expect(provider.currentCandidates.length, equals(2));

        verify(mockUseCase.getCandidates('test-session-id')).called(1);

        print('✓ 加载候选项成功测试通过');
      });

      test('选择候选项', () async {
        // Arrange
        final mockSession = InteractiveSession(
          sessionId: 'test-session-id',
          params: HuangJiCalculationParams(fourZhu: testFourZhu),
          currentStepIndex: 0,
          state: InteractiveSessionState.active,
          data: {'currentStep': 'userSelection'},
          createdAt: DateTime.now(),
        );

        final updatedSession = InteractiveSession(
          sessionId: 'test-session-id',
          params: HuangJiCalculationParams(fourZhu: testFourZhu),
          currentStepIndex: 1,
          state: InteractiveSessionState.completed,
          data: {'currentStep': 'completed', 'selectedBaseNumber': 123},
          createdAt: DateTime.now(),
        );

        final mockCandidate = TiaoWenCandidate(
          id: 'candidate-1',
          displayText: '候选项1',
          value: 123,
          description: '描述1',
        );

        final mockResult = TiaoWenListResult.success(
          tiaoWenNumbers: [1001, 1002, 1003],
          tiaoWenEntities: [],
          calculationMethod: '皇极取数法',
          sourceData: {},
        );

        when(
          mockUseCase.startSession(any, config: anyNamed('config')),
        ).thenAnswer((_) async => mockSession);
        when(
          mockUseCase.getCandidates(any),
        ).thenAnswer((_) async => [mockCandidate]);
        when(
          mockUseCase.selectCandidate(any, any),
        ).thenAnswer((_) async => updatedSession);
        when(
          mockUseCase.completeCalculation(any),
        ).thenAnswer((_) async => mockResult);

        // Act
        await provider.startSession(testFourZhu);
        await provider.selectCandidate(mockCandidate);

        // Assert
        expect(provider.isCompleted, isTrue);
        expect(provider.selectedBaseNumber, equals(123));
        expect(provider.finalResult, equals(mockResult));

        verify(
          mockUseCase.selectCandidate('test-session-id', 'candidate-1'),
        ).called(1);
        verify(mockUseCase.completeCalculation('test-session-id')).called(1);

        print('✓ 选择候选项测试通过');
      });
    });

    group('操作功能', () {
      test('撤销操作', () async {
        // Arrange
        final mockSession = InteractiveSession(
          sessionId: 'test-session-id',
          params: HuangJiCalculationParams(fourZhu: testFourZhu),
          currentStepIndex: 1,
          state: InteractiveSessionState.active,
          data: {'currentStep': 'userSelection'},
          createdAt: DateTime.now(),
        );

        final undoSession = InteractiveSession(
          sessionId: 'test-session-id',
          params: HuangJiCalculationParams(fourZhu: testFourZhu),
          currentStepIndex: 0,
          state: InteractiveSessionState.active,
          data: {'currentStep': 'initialization'},
          createdAt: DateTime.now(),
        );

        when(
          mockUseCase.startSession(any, config: anyNamed('config')),
        ).thenAnswer((_) async => mockSession);
        when(mockUseCase.undo(any)).thenAnswer((_) async => undoSession);
        when(mockUseCase.getCandidates(any)).thenAnswer((_) async => []);

        // Act
        await provider.startSession(testFourZhu);
        await provider.undo();

        // Assert
        expect(provider.currentSession!.currentStepIndex, equals(0));

        verify(mockUseCase.undo('test-session-id')).called(1);

        print('✓ 撤销操作测试通过');
      });

      test('跳转操作', () async {
        // Arrange
        final mockSession = InteractiveSession(
          sessionId: 'test-session-id',
          strategyName: 'huang_ji',
          startTime: DateTime.now(),
          status: InteractiveSessionStatus.inProgress,
          steps: [],
          currentStepIndex: 2,
          sessionConfig: {
            'currentStep': 'userSelection',
            'params': HuangJiCalculationParams(fourZhu: testFourZhu).toJson(),
          },
        );

        final jumpSession = InteractiveSession(
          sessionId: 'test-session-id',
          strategyName: 'huang_ji',
          startTime: DateTime.now(),
          status: InteractiveSessionStatus.inProgress,
          steps: [],
          currentStepIndex: 0,
          sessionConfig: {
            'currentStep': 'initialization',
            'params': HuangJiCalculationParams(fourZhu: testFourZhu).toJson(),
          },
        );

        when(
          mockUseCase.startSession(any, config: anyNamed('config')),
        ).thenAnswer((_) async => mockSession);
        when(mockUseCase.jumpTo(any, any)).thenAnswer((_) async => jumpSession);
        when(mockUseCase.getCandidates(any)).thenAnswer((_) async => []);

        // Act
        await provider.startSession(testFourZhu);
        await provider.jumpToStep(0);

        // Assert
        expect(provider.currentSession!.currentStepIndex, equals(0));

        verify(mockUseCase.jumpTo('test-session-id', 0)).called(1);

        print('✓ 跳转操作测试通过');
      });
    });

    group('状态管理', () {
      test('重置状态', () async {
        // Arrange
        final mockSession = InteractiveSession(
          sessionId: 'test-session-id',
          strategyName: 'huang_ji',
          startTime: DateTime.now(),
          status: InteractiveSessionStatus.inProgress,
          steps: [],
          currentStepIndex: 0,
          sessionConfig: {
            'params': HuangJiCalculationParams(fourZhu: testFourZhu).toJson(),
          },
        );

        when(
          mockUseCase.startSession(any, config: anyNamed('config')),
        ).thenAnswer((_) async => mockSession);

        // Act
        await provider.startSession(testFourZhu);
        provider.reset();

        // Assert
        expect(provider.isInitial, isTrue);
        expect(provider.hasSession, isFalse);
        expect(provider.currentCandidates, isEmpty);
        expect(provider.finalResult, isNull);
        expect(provider.inputFourZhu, isNull);

        print('✓ 重置状态测试通过');
      });

      test('状态判断方法', () async {
        // 测试各种状态判断
        expect(provider.isInitial, isTrue);
        expect(provider.isLoading, isFalse);
        expect(provider.hasError, isFalse);
        expect(provider.canUndo, isFalse);
        expect(provider.canJump, isFalse);
        expect(provider.needsUserSelection, isFalse);

        print('✓ 状态判断方法测试通过');
      });
    });

    group('错误处理', () {
      test('UseCase异常处理', () async {
        // Arrange
        when(
          mockUseCase.startSession(any, config: anyNamed('config')),
        ).thenThrow(Exception('网络错误'));

        // Act
        await provider.startSession(testFourZhu);

        // Assert
        expect(provider.hasError, isTrue);
        expect(provider.errorMessage, contains('启动会话失败'));
        expect(provider.lastException, isA<Exception>());

        print('✓ UseCase异常处理测试通过');
      });

      test('用户友好错误消息', () async {
        // Arrange
        when(
          mockUseCase.startSession(any, config: anyNamed('config')),
        ).thenThrow(Exception('详细的技术错误信息'));

        // Act
        await provider.startSession(testFourZhu);

        // Assert
        final friendlyMessage = provider.getUserFriendlyErrorMessage();
        expect(friendlyMessage, isNotEmpty);
        expect(friendlyMessage, contains('启动会话失败'));

        print('✓ 用户友好错误消息测试通过');
        print('✓ 错误消息: $friendlyMessage');
      });
    });

    group('配置管理', () {
      test('会话配置', () async {
        // Arrange
        final config = InteractiveStrategyConfig(
          maxSteps: 5,
          allowUndo: true,
          allowJump: true,
          customSettings: {'test': 'value'},
        );

        final mockSession = InteractiveSession(
          sessionId: 'test-session-id',
          strategyName: 'huang_ji',
          startTime: DateTime.now(),
          status: InteractiveSessionStatus.inProgress,
          steps: [],
          currentStepIndex: 0,
          sessionConfig: {
            'params': HuangJiCalculationParams(fourZhu: testFourZhu).toJson(),
          },
        );

        when(
          mockUseCase.startSession(any, config: anyNamed('config')),
        ).thenAnswer((_) async => mockSession);

        // Act
        await provider.startSession(testFourZhu, config: config);

        // Assert
        expect(provider.sessionConfig, equals(config));

        verify(mockUseCase.startSession(any, config: config)).called(1);

        print('✓ 会话配置测试通过');
      });
    });

    group('数据更新', () {
      test('会话数据更新', () async {
        // Arrange
        final mockSession = InteractiveSession(
          sessionId: 'test-session-id',
          strategyName: 'huang_ji',
          startTime: DateTime.now(),
          status: InteractiveSessionStatus.inProgress,
          steps: [],
          currentStepIndex: 0,
          sessionConfig: {
            'currentStep': 'userSelection',
            'initialNumber': 123,
            'secondaryNumber': 456,
            'selectedBaseNumber': 789,
            'finalNumbers': [1, 2, 3],
            'params': HuangJiCalculationParams(fourZhu: testFourZhu).toJson(),
          },
        );

        when(
          mockUseCase.startSession(any, config: anyNamed('config')),
        ).thenAnswer((_) async => mockSession);

        // Act
        await provider.startSession(testFourZhu);

        // Assert
        expect(provider.initialNumber, equals(123));
        expect(provider.secondaryNumber, equals(456));
        expect(provider.selectedBaseNumber, equals(789));
        expect(provider.finalNumbers, equals([1, 2, 3]));
        expect(
          provider.currentStep,
          equals(HuangJiInteractiveStep.userSelection),
        );

        print('✓ 会话数据更新测试通过');
      });
    });
  });
}
