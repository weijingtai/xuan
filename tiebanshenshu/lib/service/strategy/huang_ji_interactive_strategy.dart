/// 皇极取数法交互式策略
///
/// 支持用户参与式的皇极取数法计算
library;

import 'package:flutter/foundation.dart';

import '../../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../../domain/models/huang_ji_calculation_params.dart';
import '../../domain/models/huang_ji_calculation_result.dart';
import '../../domain/models/huang_ji_candidate.dart';
import '../../domain/models/huang_ji_interactive_step.dart';
import '../../domain/models/interactive_session.dart';
import '../../domain/models/interactive_strategy_config.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import '../../repository/tiao_wen_repository.dart';
import '../../repository/datamodels/tiao_wen_datamodel.dart';
import 'base_interactive_strategy.dart';
import 'huang_ji_calculation_strategy.dart';

/// 皇极取数法交互式策略
///
/// 继承自BaseInteractiveStrategy，实现皇极取数法的交互式计算流程
class HuangJiInteractiveStrategy
    extends
        BaseInteractiveStrategy<
          HuangJiCalculationParams,
          HuangJiCalculationResult
        > {
  /// 标准计算策略
  final HuangJiCalculationStrategy _standardStrategy;

  /// 条文数据仓库
  final TiaoWenRepository _tiaoWenRepository;

  /// 会话存储
  final Map<String, InteractiveSession> _sessions = {};

  /// 构造函数
  HuangJiInteractiveStrategy(this._standardStrategy, this._tiaoWenRepository);

  @override
  String get name => '皇极取数法交互式';

  @override
  String get description => '支持用户参与式选择的皇极取数法计算';

  @override
  InteractiveStrategyConfig get config => const InteractiveStrategyConfig(
    stepSize: 30,
    candidateCount: 10,
    allowUndo: true,
    allowJump: true,
    maxSteps: 5,
  );

  @override
  HuangJiCalculationResult calculate(HuangJiCalculationParams params) {
    // 对于非交互式调用，直接使用标准策略
    return _standardStrategy.calculate(params);
  }

  @override
  void validateParams(HuangJiCalculationParams params) {
    _standardStrategy.validateParams(params);
  }

  @override
  Future<InteractiveSession> startSession(
    HuangJiCalculationParams params, {
    InteractiveStrategyConfig? config,
  }) async {
    try {
      if (kDebugMode) {
        print('🚀 HuangJiInteractiveStrategy: 开始启动会话');
        print('📊 输入参数: ${params.eightChars.toString()}');
      }

      // 验证参数
      validateParams(params);

      if (kDebugMode) {
        print('✅ HuangJiInteractiveStrategy: 参数验证完成');
      }

      // 生成会话ID
      final sessionId = _generateSessionId();

      if (kDebugMode) {
        print('🆔 HuangJiInteractiveStrategy: 会话ID生成: $sessionId');
        print('🔧 HuangJiInteractiveStrategy: 开始标准策略计算');
      }

      // 使用标准策略计算初始数据
      final standardResult = _standardStrategy.calculate(params);

      if (kDebugMode) {
        print('✅ HuangJiInteractiveStrategy: 标准策略计算完成');
        print('📊 初刻数: ${standardResult.initialNumber}');
        print('📊 次条文数: ${standardResult.secondaryNumber}');
        print('🔧 HuangJiInteractiveStrategy: 创建会话对象');
      }

      // 创建会话
      final session = InteractiveSession.create(
        sessionId: sessionId,
        strategyName: name,
        sessionConfig: {
          'originalParams': params.toJson(),
          'config': config ?? this.config,
          'initialNumber': standardResult.initialNumber,
          'secondaryNumber': standardResult.secondaryNumber,
          'currentStep':
              HuangJiInteractiveStep.userSelection.id, // 初始化计算已完成，进入用户选择阶段
          'standardResult': standardResult.toJson(),
        },
      );

      if (kDebugMode) {
        print('✅ HuangJiInteractiveStrategy: 会话对象创建完成');
        print('📊 会话状态: ${session.status}');
        print('🔧 HuangJiInteractiveStrategy: 存储会话');
      }

      // 存储会话
      _sessions[sessionId] = session;

      if (kDebugMode) {
        print('✅ HuangJiInteractiveStrategy: 会话存储完成');
        print('📊 当前会话数量: ${_sessions.length}');
        print('🎉 HuangJiInteractiveStrategy: 会话启动成功');
      }

      return session;
    } catch (e) {
      if (kDebugMode) {
        print('❌ HuangJiInteractiveStrategy: 启动会话失败');
        print('❌ 错误类型: ${e.runtimeType}');
        print('❌ 错误信息: $e');
      }

      throw HuangJiInteractiveSessionException(
        message: '启动交互式会话失败: ${e.toString()}',
        fourZhuInfo: params.eightChars.toString(),
        originalException: e,
      );
    }
  }

  @override
  Future<List<TiaoWenCandidate>> getCandidates(
    InteractiveSession session,
  ) async {
    try {
      final sessionData = session.sessionConfig ?? {};
      final currentStepId = sessionData['currentStep'] as String;
      final currentStep = HuangJiInteractiveStep.fromString(currentStepId);

      if (currentStep == null) {
        throw HuangJiInteractiveSessionException(
          sessionId: session.sessionId,
          currentStep: currentStepId,
          message: '无效的当前步骤',
        );
      }

      switch (currentStep) {
        case HuangJiInteractiveStep.userSelection:
          return _generateUserSelectionCandidates(session);

        default:
          throw HuangJiInteractiveSessionException(
            sessionId: session.sessionId,
            currentStep: currentStepId,
            message: '当前步骤不需要候选项选择',
          );
      }
    } catch (e) {
      if (e is TiaoWenCalculationException) {
        rethrow;
      }
      throw HuangJiInteractiveSessionException(
        sessionId: session.sessionId,
        message: '获取候选项失败: ${e.toString()}',
        originalException: e,
      );
    }
  }

  @override
  Future<InteractiveSession> selectCandidate(
    InteractiveSession session,
    String candidateId,
  ) async {
    try {
      final sessionData = session.sessionConfig ?? {};
      final currentStepId = sessionData['currentStep'] as String;
      final currentStep = HuangJiInteractiveStep.fromString(currentStepId);

      if (currentStep != HuangJiInteractiveStep.userSelection) {
        throw HuangJiInteractiveSessionException(
          sessionId: session.sessionId,
          currentStep: currentStepId,
          expectedStep: HuangJiInteractiveStep.userSelection.id,
          message: '当前步骤不支持候选项选择',
        );
      }

      // 解析候选项ID获取选择的基础数
      final selectedBaseNumber = _parseCandidateId(candidateId);

      // 更新会话配置数据
      final updatedSessionConfig = Map<String, dynamic>.from(sessionData);
      updatedSessionConfig['selectedBaseNumber'] = selectedBaseNumber;
      updatedSessionConfig['currentStep'] =
          HuangJiInteractiveStep.finalCalculation.id;

      // 计算最终结果
      final paramsData = sessionData['originalParams'] as Map<String, dynamic>;
      final params = HuangJiCalculationParams.fromJson(paramsData);
      // 使用标准策略计算最终数字
      final standardParams = HuangJiCalculationParams(
        eightChars: params.eightChars,
      );
      final standardResult = _standardStrategy.calculate(standardParams);
      final finalNumbers =
          standardResult.calculationSteps['finalNumbers'] as List<int>;

      // 准备结果数据
      final resultData = {
        'selectedBaseNumber': selectedBaseNumber,
        'finalNumbers': finalNumbers,
        'completedAt': DateTime.now().toIso8601String(),
      };

      // 创建更新后的会话
      final updatedSession = session.copyWith(
        sessionConfig: updatedSessionConfig,
        resultData: resultData,
        status: InteractiveSessionStatus.completed,
        endTime: DateTime.now(),
      );

      // 更新存储
      _sessions[session.sessionId] = updatedSession;

      return updatedSession;
    } catch (e) {
      if (e is TiaoWenCalculationException) {
        rethrow;
      }
      throw HuangJiInteractiveSessionException(
        sessionId: session.sessionId,
        message: '选择候选项失败: ${e.toString()}',
        originalException: e,
      );
    }
  }

  @override
  Future<InteractiveSession> adjustStep(
    InteractiveSession session,
    Map<String, dynamic> adjustments,
  ) async {
    try {
      // 实现步骤调整逻辑
      final sessionData = session.sessionConfig ?? {};
      final updatedSessionConfig = Map<String, dynamic>.from(sessionData);
      updatedSessionConfig.addAll(adjustments);

      final updatedSession = session.copyWith(
        sessionConfig: updatedSessionConfig,
      );

      _sessions[session.sessionId] = updatedSession;

      return updatedSession;
    } catch (e) {
      throw HuangJiInteractiveSessionException(
        sessionId: session.sessionId,
        message: '调整步骤失败: ${e.toString()}',
        originalException: e,
      );
    }
  }

  @override
  Future<InteractiveSession> jumpTo(
    InteractiveSession session,
    int stepIndex,
  ) async {
    try {
      if (stepIndex < 0 || stepIndex >= HuangJiInteractiveStep.values.length) {
        throw InvalidStepIndexException(
          '无效的步骤索引',
          stepIndex: stepIndex,
          maxIndex: HuangJiInteractiveStep.values.length - 1,
        );
      }

      final targetStep = HuangJiInteractiveStep.values[stepIndex];
      final sessionData = session.sessionConfig ?? {};
      final updatedSessionConfig = Map<String, dynamic>.from(sessionData);
      updatedSessionConfig['currentStep'] = targetStep.id;

      final updatedSession = session.copyWith(
        currentStepIndex: stepIndex,
        sessionConfig: updatedSessionConfig,
      );

      _sessions[session.sessionId] = updatedSession;

      return updatedSession;
    } catch (e) {
      if (e is TiaoWenCalculationException) {
        rethrow;
      }
      throw HuangJiInteractiveSessionException(
        sessionId: session.sessionId,
        message: '跳转步骤失败: ${e.toString()}',
        originalException: e,
      );
    }
  }

  @override
  Future<InteractiveSession> undo(InteractiveSession session) async {
    try {
      final currentStep =
          HuangJiInteractiveStep.values[session.currentStepIndex];

      if (!currentStep.canUndo) {
        throw HuangJiInteractiveSessionException(
          sessionId: session.sessionId,
          currentStep: currentStep.id,
          message: '当前步骤不支持撤销操作',
        );
      }

      final previousStep = currentStep.previous!;
      final sessionData = session.sessionConfig ?? {};
      final updatedSessionConfig = Map<String, dynamic>.from(sessionData);
      updatedSessionConfig['currentStep'] = previousStep.id;

      final updatedSession = session.copyWith(
        currentStepIndex: previousStep.index,
        sessionConfig: updatedSessionConfig,
      );

      _sessions[session.sessionId] = updatedSession;

      return updatedSession;
    } catch (e) {
      if (e is TiaoWenCalculationException) {
        rethrow;
      }
      throw HuangJiInteractiveSessionException(
        sessionId: session.sessionId,
        message: '撤销操作失败: ${e.toString()}',
        originalException: e,
      );
    }
  }

  @override
  Future<List<dynamic>> getInfiniteList(
    InteractiveSession session,
    int offset,
    int limit,
  ) async {
    try {
      final sessionData = session.sessionConfig ?? {};
      final secondaryNumber = sessionData['secondaryNumber'] as int;
      final candidates = <TiaoWenCandidate>[];

      // 生成指定范围的候选项
      for (int i = offset; i < offset + limit; i++) {
        final adjustmentDirection = i % 2 == 0 ? 1 : -1;
        final adjustmentCount = (i + 1) ~/ 2;
        final candidateNumber =
            secondaryNumber + (adjustmentDirection * 30 * adjustmentCount);

        if (_standardStrategy.isValidCandidateNumber(candidateNumber)) {
          candidates.add(
            HuangJiCandidate.createAdjusted(
              baseNumber: secondaryNumber,
              adjustmentDirection: adjustmentDirection,
              adjustmentCount: adjustmentCount,
            ),
          );
        }
      }

      return candidates;
    } catch (e) {
      throw HuangJiInteractiveSessionException(
        sessionId: session.sessionId,
        message: '获取无限列表失败: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// 生成用户选择步骤的候选项
  List<TiaoWenCandidate> _generateUserSelectionCandidates(
    InteractiveSession session,
  ) {
    final sessionData = session.sessionConfig ?? {};
    final secondaryNumber = sessionData['secondaryNumber'] as int;
    final candidates = <TiaoWenCandidate>[];

    // 添加初始次条文数
    candidates.add(
      HuangJiCandidate.createInitialSecondary(number: secondaryNumber),
    );

    // 添加递减候选项
    for (int i = 1; i <= config.candidateCount; i++) {
      final candidateNumber = secondaryNumber - i * config.stepSize;
      if (_standardStrategy.isValidCandidateNumber(candidateNumber)) {
        candidates.add(
          HuangJiCandidate.createAdjusted(
            baseNumber: secondaryNumber,
            adjustmentDirection: -1,
            adjustmentCount: i,
          ),
        );
      }
    }

    // 添加递增候选项
    for (int i = 1; i <= config.candidateCount; i++) {
      final candidateNumber = secondaryNumber + i * config.stepSize;
      if (_standardStrategy.isValidCandidateNumber(candidateNumber)) {
        candidates.add(
          HuangJiCandidate.createAdjusted(
            baseNumber: secondaryNumber,
            adjustmentDirection: 1,
            adjustmentCount: i,
          ),
        );
      }
    }

    return candidates;
  }

  /// 生成会话ID
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'huang_ji_interactive_$timestamp';
  }

  /// 解析候选项ID获取基础数
  int _parseCandidateId(String candidateId) {
    try {
      // 候选项ID格式: "standard_123" 或 "variant_0_123"
      final parts = candidateId.split('_');
      if (parts.length >= 2) {
        // 取最后一部分作为数字
        return int.parse(parts.last);
      }

      // 如果格式不符合预期，尝试直接解析整个ID
      return int.parse(candidateId);
    } catch (e) {
      throw HuangJiInteractiveSessionException(
        message: '无效的候选项ID格式: $candidateId',
        originalException: e,
      );
    }
  }

  @override
  Future<HuangJiCalculationResult> completeCalculation(
    InteractiveSession session,
  ) async {
    try {
      validateSession(session);

      if (!session.isCompleted) {
        throw HuangJiInteractiveSessionException(
          sessionId: session.sessionId,
          message: '会话尚未完成，无法生成最终结果',
        );
      }

      // 从会话配置中提取原始参数
      final sessionConfig = session.sessionConfig ?? {};
      final paramsJson =
          sessionConfig['originalParams'] as Map<String, dynamic>?;
      final originalParams = paramsJson != null
          ? HuangJiCalculationParams.fromJson(paramsJson)
          : null;

      if (originalParams == null) {
        throw HuangJiInteractiveSessionException(
          sessionId: session.sessionId,
          message: '会话配置中缺少原始参数',
        );
      }

      // 从会话结果中提取用户选择的基础数
      final resultData = session.resultData ?? {};
      final selectedBaseNumber = resultData['selectedBaseNumber'] as int?;

      if (selectedBaseNumber == null) {
        throw HuangJiInteractiveSessionException(
          sessionId: session.sessionId,
          message: '会话结果中缺少选择的基础数',
        );
      }

      // 使用标准策略计算，但使用用户选择的基础数
      final standardResult = _standardStrategy.calculate(originalParams);

      // 获取最终条文数列表
      final finalNumbers =
          standardResult.calculationSteps['finalNumbers'] as List<int>;

      // 从repository获取条文数据
      List<TiaoWenDataModel>? tiaoWenDataList;
      try {
        tiaoWenDataList = await _tiaoWenRepository.getByIdList(
          queryList: finalNumbers,
          preserveOrder: true,
          skipNotFound: true,
        );
      } catch (e) {
        // 如果获取条文数据失败，记录错误但不中断计算
        tiaoWenDataList = null;
        // 可以在这里添加日志记录
      }

      // 创建交互式结果，包含用户的选择历史和条文数据
      return HuangJiCalculationResult.success(
        initialNumber: standardResult.calculationSteps['initialNumber'] as int,
        secondaryNumber:
            standardResult.calculationSteps['secondaryNumber'] as int,
        baseNumber: selectedBaseNumber,
        finalNumbers: finalNumbers,
        tiaoWenDataList: tiaoWenDataList,
        calculationSteps: {
          ...standardResult.calculationSteps,
          'interactiveSession': {
            'sessionId': session.sessionId,
            'selectedBaseNumber': selectedBaseNumber,
            'selectionHistory': _extractSelectionHistory(session),
          },
          'tiaoWenDataStatus': {
            'requested': finalNumbers.length,
            'retrieved': tiaoWenDataList?.length ?? 0,
            'success': tiaoWenDataList != null,
          },
        },
      );
    } catch (e) {
      if (e is HuangJiInteractiveSessionException) {
        rethrow;
      }
      throw HuangJiInteractiveSessionException(
        sessionId: session.sessionId,
        message: '完成交互式计算失败: ${e.toString()}',
        originalException: e,
      );
    }
  }

  @override
  Future<InteractiveSessionStep?> getNextStep(
    InteractiveSession session,
  ) async {
    try {
      validateSession(session);

      // 如果会话已完成，没有下一步
      if (session.isCompleted) {
        return null;
      }

      // 获取当前步骤
      final currentStep = session.currentStep;

      // 如果没有当前步骤，返回第一步（基础数选择）
      if (currentStep == null) {
        return await _createBaseNumberSelectionStep(session);
      }

      // 根据当前步骤类型确定下一步
      switch (currentStep.stepName) {
        case 'baseNumberSelection':
          // 基础数选择完成后，可以进行最终确认或继续调整
          if (currentStep.isCompleted) {
            return await _createFinalConfirmationStep(session);
          }
          break;
        case 'finalConfirmation':
          // 最终确认完成后，没有下一步
          return null;
        default:
          // 未知步骤类型，返回基础数选择
          return await _createBaseNumberSelectionStep(session);
      }

      return null;
    } catch (e) {
      throw HuangJiInteractiveSessionException(
        sessionId: session.sessionId,
        message: '获取下一步失败: ${e.toString()}',
        originalException: e,
      );
    }
  }

  @override
  bool isLastStep(InteractiveSession session) {
    try {
      validateSession(session);

      // 如果会话已完成，当前步骤就是最后一步
      if (session.isCompleted) {
        return true;
      }

      final currentStep = session.currentStep;

      // 如果没有当前步骤，不是最后一步
      if (currentStep == null) {
        return false;
      }

      // 最终确认步骤是最后一步
      return currentStep.stepName == 'finalConfirmation';
    } catch (e) {
      // 发生错误时，保守地返回false
      return false;
    }
  }

  @override
  String get school => '皇极取数流派（交互式）';

  @override
  void validateCandidateSelection(
    InteractiveSession session,
    String candidateId,
  ) {
    // 验证会话状态
    validateSession(session);

    // 验证候选项ID不为空
    if (candidateId.isEmpty) {
      throw HuangJiInteractiveSessionException(
        sessionId: session.sessionId,
        message: '候选项ID不能为空',
      );
    }

    // 获取当前步骤
    final currentStep = session.currentStep;
    if (currentStep == null) {
      throw HuangJiInteractiveSessionException(
        sessionId: session.sessionId,
        message: '当前没有活动步骤，无法选择候选项',
      );
    }

    // 验证候选项是否存在于当前步骤中
    final candidates = currentStep.candidates ?? [];
    final candidateExists = candidates.any(
      (candidate) => candidate.id == candidateId,
    );

    if (!candidateExists) {
      throw HuangJiInteractiveSessionException(
        sessionId: session.sessionId,
        message: '候选项ID "$candidateId" 在当前步骤中不存在',
      );
    }

    // 验证当前步骤是否允许选择
    if (currentStep.isCompleted) {
      throw HuangJiInteractiveSessionException(
        sessionId: session.sessionId,
        message: '当前步骤已完成，无法重新选择候选项',
      );
    }
  }

  /// 验证会话的有效性
  void validateSession(InteractiveSession session) {
    if (session.sessionId.isEmpty) {
      throw HuangJiInteractiveSessionException(
        sessionId: session.sessionId,
        message: '会话ID不能为空',
      );
    }

    if (session.strategyName != name) {
      throw HuangJiInteractiveSessionException(
        sessionId: session.sessionId,
        message: '会话策略类型不匹配，期望: $name，实际: ${session.strategyName}',
      );
    }
  }

  @override
  @override
  List<String> get detailSteps => [
    '1. 初始化交互式会话',
    '2. 生成基础数候选项',
    '3. 用户选择基础数',
    '4. 最终确认选择',
    '5. 完成交互式计算',
  ];

  /// 创建基础数选择步骤
  Future<InteractiveSessionStep> _createBaseNumberSelectionStep(
    InteractiveSession session,
  ) async {
    final sessionConfig = session.sessionConfig ?? {};
    final paramsJson = sessionConfig['originalParams'] as Map<String, dynamic>?;
    final originalParams = paramsJson != null
        ? HuangJiCalculationParams.fromJson(paramsJson)
        : null;

    if (originalParams == null) {
      throw HuangJiInteractiveSessionException(
        sessionId: session.sessionId,
        message: '会话配置中缺少原始参数',
      );
    }

    // 生成基础数候选项
    final candidates = await _generateBaseNumberCandidates(originalParams);

    return InteractiveSessionStep(
      stepNumber: 0,
      stepName: 'baseNumberSelection',
      description: '请从以下候选数字中选择一个作为计算的基础数',
      candidates: candidates,
      startTime: DateTime.now(),
      status: InteractiveSessionStatus.waitingForSelection,
      stepData: {'stepIndex': 0, 'totalSteps': 2},
    );
  }

  /// 创建最终确认步骤
  Future<InteractiveSessionStep> _createFinalConfirmationStep(
    InteractiveSession session,
  ) async {
    final resultData = session.resultData ?? {};
    final selectedBaseNumber = resultData['selectedBaseNumber'] as int?;

    return InteractiveSessionStep(
      stepNumber: 1,
      stepName: 'finalConfirmation',
      description: '您选择的基础数是：$selectedBaseNumber，请确认是否继续计算',
      candidates: [
        TiaoWenCandidate(
          id: 'confirm',
          value: true,
          metadata: {'action': 'confirm'},
          displayName: '确定',
          description: '确认并完成计算',
          type: TiaoWenCandidateType.confirmation,
        ),
        TiaoWenCandidate(
          id: 'back',
          displayName: '重选',
          description: '返回上一步重新选择基础数',
          value: false,
          metadata: {'action': 'back'},
          type: TiaoWenCandidateType.calculationMethod,
        ),
      ],
      startTime: DateTime.now(),
      status: InteractiveSessionStatus.waitingForSelection,
      stepData: {
        'stepIndex': 1,
        'totalSteps': 2,
        'selectedBaseNumber': selectedBaseNumber,
      },
    );
  }

  /// 从会话中提取选择历史
  Map<String, dynamic> _extractSelectionHistory(InteractiveSession session) {
    final history = <String, dynamic>{};

    // 提取步骤历史
    final steps = <Map<String, dynamic>>[];
    if (session.currentStep != null) {
      steps.add({
        'stepNumber': session.currentStep!.stepNumber,
        'stepName': session.currentStep!.stepName,
        'isCompleted': session.currentStep!.isCompleted,
        'selectedCandidateId': session.currentStep!.selectedCandidateId,
      });
    }

    history['steps'] = steps;
    history['totalSteps'] = steps.length;
    history['completedAt'] = session.endTime?.toIso8601String();

    return history;
  }

  /// 生成基础数候选项
  Future<List<TiaoWenCandidate>> _generateBaseNumberCandidates(
    HuangJiCalculationParams params,
  ) async {
    try {
      // 使用标准策略计算初始数据
      final standardResult = _standardStrategy.calculate(params);

      // 获取初始数和次数
      final initialNumber =
          standardResult.calculationSteps['initialNumber'] as int;
      final secondaryNumber =
          standardResult.calculationSteps['secondaryNumber'] as int;

      // 生成候选基础数（通常是初始数和次数的组合变化）
      final candidates = <TiaoWenCandidate>[];

      // 添加标准计算的基础数
      final standardBaseNumber =
          standardResult.calculationSteps['baseNumber'] as int;
      candidates.add(
        TiaoWenCandidate(
          id: 'standard_$standardBaseNumber',
          displayName: '标准计算: $standardBaseNumber',
          value: standardBaseNumber,
          metadata: {
            'type': 'standard',
            'calculation': '初始数($initialNumber) + 次数($secondaryNumber)',
          },
          description: '标准计算: $standardBaseNumber',
          type: TiaoWenCandidateType.calculationMethod,
        ),
      );

      // 添加其他可选的基础数变化
      final baseVariations = [
        initialNumber, // 仅使用初始数
        secondaryNumber, // 仅使用次数
        initialNumber * 2, // 初始数的倍数
        (initialNumber + secondaryNumber) * 2, // 总和的倍数
        initialNumber + secondaryNumber + 1, // 总和加一
        initialNumber + secondaryNumber - 1, // 总和减一
      ];

      for (int i = 0; i < baseVariations.length; i++) {
        final baseNumber = baseVariations[i];
        if (baseNumber > 0 && baseNumber != standardBaseNumber) {
          String description;
          switch (i) {
            case 0:
              description = '仅初始数: $baseNumber';
              break;
            case 1:
              description = '仅次数: $baseNumber';
              break;
            case 2:
              description = '初始数倍增: $baseNumber';
              break;
            case 3:
              description = '总和倍增: $baseNumber';
              break;
            case 4:
              description = '总和加一: $baseNumber';
              break;
            case 5:
              description = '总和减一: $baseNumber';
              break;
            default:
              description = '变化数: $baseNumber';
          }

          candidates.add(
            TiaoWenCandidate(
              id: 'variant_${i}_$baseNumber',
              displayName: '变化数: $baseNumber',
              description: description,
              value: baseNumber,
              metadata: {'type': 'variant', 'index': i},
              type: TiaoWenCandidateType.calculationMethod,
            ),
          );
        }
      }

      // 限制候选项数量
      final maxCandidates = config.candidateCount;
      if (candidates.length > maxCandidates) {
        return candidates.take(maxCandidates).toList();
      }

      return candidates;
    } catch (e) {
      throw HuangJiInteractiveSessionException(
        message: '生成基础数候选项失败: ${e.toString()}',
        originalException: e,
      );
    }
  }
  // /// 生成基础数候选项
  // Future<List<TiaoWenCandidate>> _generateBaseNumberCandidates(
  //   HuangJiCalculationParams params,
  // ) async {
  //   final candidates = <TiaoWenCandidate>[];

  //   try {
  //     // 使用标准策略计算基础数
  //     final standardResult = _standardStrategy.calculate(params);
  //     final baseNumber = standardResult.primaryBaseNumber;

  //     // 添加标准计算结果作为默认候选项
  //     candidates.add(HuangJiCandidate(
  //       id: 'standard_$baseNumber',
  //       displayName: '标准计算结果',
  //       description: '基于四柱信息计算得出的标准基础数：$baseNumber',
  //       type: TiaoWenCandidateType.baseNumber,
  //       value: baseNumber,
  //       number: baseNumber,
  //       offset: 0,
  //       stepCount: 0,
  //       isBase: true,
  //       isInitialSecondary: false,
  //       adjustmentDirection: 0,
  //       adjustmentCount: 0,
  //       isDefault: true,
  //     ));

  //     // 生成基于基础数的变化候选项
  //     final variations = <int>[];

  //     // 添加递增变化（+30, +60, +90等）
  //     for (int i = 1; i <= 3; i++) {
  //       final adjustedNumber = baseNumber + (30 * i);
  //       if (_standardStrategy.isValidCandidateNumber(adjustedNumber)) {
  //         variations.add(adjustedNumber);
  //         candidates.add(HuangJiCandidate(
  //           id: 'variant_${i}_$adjustedNumber',
  //           displayName: '递增${i}次',
  //           description: '基础数递增${i}次（+${30 * i}）：$adjustedNumber',
  //           type: TiaoWenCandidateType.baseNumber,
  //           value: adjustedNumber,
  //           number: adjustedNumber,
  //           offset: 30 * i,
  //           stepCount: i,
  //           isBase: false,
  //           isInitialSecondary: false,
  //           adjustmentDirection: 1,
  //           adjustmentCount: i,
  //         ));
  //       }
  //     }

  //     // 添加递减变化（-30, -60, -90等）
  //     for (int i = 1; i <= 3; i++) {
  //       final adjustedNumber = baseNumber - (30 * i);
  //       if (_standardStrategy.isValidCandidateNumber(adjustedNumber)) {
  //         variations.add(adjustedNumber);
  //         candidates.add(HuangJiCandidate(
  //           id: 'variant_-${i}_$adjustedNumber',
  //           displayName: '递减${i}次',
  //           description: '基础数递减${i}次（-${30 * i}）：$adjustedNumber',
  //           type: TiaoWenCandidateType.baseNumber,
  //           value: adjustedNumber,
  //           number: adjustedNumber,
  //           offset: -30 * i,
  //           stepCount: i,
  //           isBase: false,
  //           isInitialSecondary: false,
  //           adjustmentDirection: -1,
  //           adjustmentCount: i,
  //         ));
  //       }
  //     }

  //     // 限制候选项数量，避免过多选择
  //     if (candidates.length > 7) {
  //       return candidates.take(7).toList();
  //     }

  //     return candidates;
  //   } catch (e) {
  //     throw HuangJiInteractiveSessionException(
  //       message: '生成基础数候选项时发生错误：$e',
  //     );
  //   }
  // }

  Future<InteractiveSession> cancelSession(
    InteractiveSession interactiveSession,
  ) async {
    return interactiveSession.cancel();
  }

  Future<InteractiveSession?> getSession(String sessionId) async {
    final session = _sessions[sessionId];
    if (session == null) {
      throw SessionNotFoundException('会话不存在: $sessionId');
    }
    return session;
  }
}
