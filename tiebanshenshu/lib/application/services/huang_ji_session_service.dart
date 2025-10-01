/// 皇极取数法会话服务
///
/// 负责管理皇极取数法会话的业务逻辑，包括会话创建、步骤管理、状态恢复等
library;

import 'package:flutter/foundation.dart';
import 'package:common/models/eight_chars.dart';

import '../../domain/models/huang_ji_session.dart';
import '../../domain/models/huang_ji_formula_v2.dart';
import '../../domain/models/huang_ji_formula_data_v2.dart';
import '../../domain/models/huang_ji_number.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import '../../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../../repository/tiao_wen_repository.dart';
import '../../service/strategy/huang_ji_calculation_strategy.dart';

/// 皇极取数法会话服务
class HuangJiSessionService {
  /// 皇极计算策略
  final HuangJiCalculationStrategy _calculationStrategy;

  /// 条文数据仓库
  final TiaoWenRepository _repository;

  /// 内存中的会话存储
  final Map<String, HuangJiSession> _sessions = {};

  /// 构造函数
  HuangJiSessionService(this._calculationStrategy, this._repository);

  /// 创建新的皇极取数会话
  Future<HuangJiSession> createSession({
    required String sessionName,
    required HuangJiCalculationFormula formulaTemplate,
    required EightChars eightChars,
    Map<String, dynamic>? sessionConfig,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (kDebugMode) {
        print('🚀 HuangJiSessionService: 创建新会话');
        print('📊 会话名称: $sessionName');
        print('📊 公式模板: ${formulaTemplate.name}');
        print('📊 八字: ${eightChars.toString()}');
      }

      // 生成会话ID
      final sessionId = _generateSessionId();

      // 创建会话
      final session = HuangJiSessionManager.createFromTemplate(
        sessionId: sessionId,
        sessionName: sessionName,
        formulaTemplate: formulaTemplate,
        eightChars: eightChars,
        metadata: metadata,
      );

      // 初始化公式步骤
      final initializedSession =
          HuangJiSessionManager.initializeAllFormulaSteps(session);

      // 存储会话
      _sessions[sessionId] = initializedSession;

      if (kDebugMode) {
        print('✅ HuangJiSessionService: 会话创建成功');
        print('🆔 会话ID: ${initializedSession.sessionId}');
      }

      return initializedSession;
    } catch (e) {
      if (kDebugMode) {
        print('❌ HuangJiSessionService: 创建会话失败');
        print('❌ 错误: $e');
      }
      throw SessionCreationException(
        message: '创建皇极取数会话失败: ${e.toString()}',
        originalException: e,
      );
    }
  }

  /// 执行下一步计算
  Future<HuangJiSession> executeNextStep(String sessionId) async {
    try {
      final session = _getSessionOrThrow(sessionId);

      if (session.isCompleted) {
        throw SessionStateException('会话已完成，无法执行下一步');
      }

      if (!session.canMoveNext) {
        throw SessionStateException('没有下一步可执行');
      }

      final currentInstance = session.currentFormulaInstance;
      if (currentInstance == null) {
        throw SessionStateException('当前公式实例不存在');
      }

      // 移动到下一步
      final updatedInstance = currentInstance.copyWith(
        currentStepIndex: currentInstance.currentStepIndex + 1,
      );

      // 更新会话中的公式实例
      final updatedInstances = List<FormulaInstance>.from(session.formulaInstances);
      updatedInstances[session.currentFormulaIndex] = updatedInstance;

      final updatedSession = session.copyWith(
        formulaInstances: updatedInstances,
        lastActivityAt: DateTime.now(),
      );

      _sessions[sessionId] = updatedSession;

      if (kDebugMode) {
        print('✅ HuangJiSessionService: 移动到下一步');
        print('🔢 当前步骤索引: ${updatedInstance.currentStepIndex}');
      }

      return updatedSession;
    } catch (e) {
      if (kDebugMode) {
        print('❌ HuangJiSessionService: 执行下一步失败');
        print('❌ 错误: $e');
      }
      rethrow;
    }
  }

  /// 选择候选项
  Future<HuangJiSession> selectCandidate(
    String sessionId,
    String formulaName,
    String stepId,
    String candidateId,
  ) async {
    try {
      final session = _getSessionOrThrow(sessionId);
      
      // 获取公式实例
      final instance = session.getFormulaInstance(formulaName);
      if (instance == null) {
        throw ArgumentError('Formula instance not found: $formulaName');
      }
      
      // 找到对应的步骤
      final step = instance.calculationSteps.firstWhere(
        (s) => s.stepId == stepId,
        orElse: () => throw ArgumentError('Step not found: $stepId'),
      );
      
      // 找到对应的候选项
      final candidate = step.candidates?.firstWhere(
        (c) => c.id == candidateId,
        orElse: () => throw ArgumentError('Candidate not found: $candidateId'),
      );
      
      if (candidate == null) {
        throw ArgumentError('No candidates available for step: $stepId');
      }
      
      // 创建SelectionCandidate
      final selectionCandidate = SelectionCandidate.fromBaseNumberDefinition(
        DataPredefinedBaseNumber(
          rawNumber: candidate.value is int ? candidate.value : 0,
          name: candidate.displayName,
          description: candidate.description,
          source: NumberSource.yunShi,
        ),
      );
      
      // 使用HuangJiSessionManager来处理用户选择
      final updatedSession = HuangJiSessionManager.makeUserSelection(
        session: session,
        formulaName: formulaName,
        stepId: stepId,
        selectedCandidate: selectionCandidate,
      );

      _sessions[sessionId] = updatedSession;

      if (kDebugMode) {
        print('✅ HuangJiSessionService: 用户选择候选项');
        print('🔢 公式名称: $formulaName');
        print('🔢 步骤ID: $stepId');
        print('🔢 候选项ID: $candidateId');
      }

      return updatedSession;
    } catch (e) {
      if (kDebugMode) {
        print('❌ HuangJiSessionService: 选择候选项失败');
        print('❌ 错误: $e');
      }
      rethrow;
    }
  }

  /// 生成基础数候选项
  Future<List<TiaoWenCandidate>> generateBaseNumberCandidates(
    String sessionId,
    String groupId,
    int baseNumber,
  ) async {
    try {
      final session = _getSessionOrThrow(sessionId);
      final candidates = <TiaoWenCandidate>[];

      // 生成基础数、基础数+30、基础数-30的候选项
      final numbers = [baseNumber, baseNumber + 30, baseNumber - 30];

      for (int i = 0; i < numbers.length; i++) {
        final number = numbers[i];

        String name;
        String description;
        bool isRecommended = false;

        if (i == 0) {
          name = '原数 ($number)';
          description = '使用原始计算的基础数';
          isRecommended = true;
        } else if (i == 1) {
          name = '加30 ($number)';
          description = '基础数加30的调整值';
        } else {
          name = '减30 ($number)';
          description = '基础数减30的调整值';
        }

        candidates.add(
          TiaoWenCandidate(
            id: '${groupId}_candidate_$i',
            displayName: name,
            description: description,
            type: TiaoWenCandidateType.baseNumber,
            value: number,
            isDefault: isRecommended,
            metadata: {
              'operation': i == 0
                  ? 'original'
                  : (i == 1 ? 'add30' : 'subtract30'),
              'baseNumber': baseNumber,
              'groupId': groupId,
            },
          ),
        );
      }

      return candidates;
    } catch (e) {
      if (kDebugMode) {
        print('❌ HuangJiSessionService: 生成候选项失败');
        print('❌ 错误: $e');
      }
      rethrow;
    }
  }

  /// 创建用户选择步骤
  Future<HuangJiCalculationStep> createUserSelectionStep(
    HuangJiSession session,
    HuangJiStepType stepType,
    String stepName,
    String description,
    int stepNumber,
    List<TiaoWenCandidate> candidates,
    Map<String, dynamic> inputData, {
    String? groupId,
    String? stepId,
  }) async {
    // 生成默认的stepId和groupId如果没有提供
    final finalStepId = stepId ?? '${session.sessionId}_user_selection_${DateTime.now().millisecondsSinceEpoch}';
    final finalGroupId = groupId ?? 'user_selection_group';
    
    return HuangJiCalculationStep(
      stepId: finalStepId,
      stepType: stepType,
      stepName: stepName,
      description: description,
      stepNumber: stepNumber,
      inputData: inputData,
      outputData: {},
      formula: '用户选择步骤',
      groupId: finalGroupId,
      candidates: candidates,
      startTime: DateTime.now(),
      requiresUserSelection: true,
      selectionType: SelectionType.selectableBaseNumber, // 默认选择类型
    );
  }

  /// 处理用户选择
  Future<HuangJiSession> makeUserSelection(
    String sessionId,
    String formulaName,
    String stepId,
    String candidateId, {
    String? selectionReason,
  }) async {
    try {
      final session = _getSessionOrThrow(sessionId);
      
      // 获取公式实例
      final instance = session.getFormulaInstance(formulaName);
      if (instance == null) {
        throw ArgumentError('Formula instance not found: $formulaName');
      }
      
      // 找到对应的步骤
      final step = instance.calculationSteps.firstWhere(
        (s) => s.stepId == stepId,
        orElse: () => throw ArgumentError('Step not found: $stepId'),
      );
      
      // 找到对应的候选项
      final candidate = step.candidates?.firstWhere(
        (c) => c.id == candidateId,
        orElse: () => throw ArgumentError('Candidate not found: $candidateId'),
      );
      
      if (candidate == null) {
        throw ArgumentError('No candidates available for step: $stepId');
      }
      
      // 创建SelectionCandidate
      final selectionCandidate = SelectionCandidate.fromBaseNumberDefinition(
        DataPredefinedBaseNumber(
          rawNumber: candidate.value is int ? candidate.value : 0,
          name: candidate.displayName,
          description: candidate.description,
          source: NumberSource.yunShi,
        ),
      );
      
      // 使用HuangJiSessionManager来处理用户选择
      final updatedSession = HuangJiSessionManager.makeUserSelection(
        session: session,
        formulaName: formulaName,
        stepId: stepId,
        selectedCandidate: selectionCandidate,
      );

      _sessions[sessionId] = updatedSession;

      if (kDebugMode) {
        print('✅ HuangJiSessionService: 用户选择完成');
        print('🔢 公式名称: $formulaName');
        print('🔢 步骤ID: $stepId');
        print('🔢 选择的候选项: $candidateId');
      }

      return updatedSession;
    } catch (e) {
      if (kDebugMode) {
        print('❌ HuangJiSessionService: 处理用户选择失败');
        print('❌ 错误: $e');
      }
      rethrow;
    }
  }

  /// 检查是否需要用户选择
  bool requiresUserSelection(String sessionId) {
    try {
      final session = _getSessionOrThrow(sessionId);
      final currentStep = session.currentStep;

      if (currentStep == null) {
        return false;
      }

      return !currentStep.isCompleted &&
          (currentStep.candidates?.isNotEmpty ?? false);
    } catch (e) {
      return false;
    }
  }

  /// 获取当前待选择的候选项
  List<TiaoWenCandidate>? getPendingCandidates(String sessionId) {
    try {
      final session = _getSessionOrThrow(sessionId);
      final currentStep = session.currentStep;

      if (currentStep == null || currentStep.isCompleted) {
        return null;
      }

      return currentStep.candidates;
    } catch (e) {
      return null;
    }
  }

  /// 生成条文内容选择候选项
  Future<List<TiaoWenCandidate>> generateTiaoWenSelectionCandidates(
    int baseNumber,
    String groupId,
  ) async {
    try {
      final candidates = <TiaoWenCandidate>[];

      // 生成基础数、基础数+30、基础数-30的候选项
      final numbers = [baseNumber, baseNumber + 30, baseNumber - 30];

      for (int i = 0; i < numbers.length; i++) {
        final number = numbers[i];

        // 尝试获取条文内容
        String? tiaoWenContent;
        try {
          final tiaoWen = await _repository.getById(number);
          tiaoWenContent = tiaoWen?.content1;
        } catch (e) {
          // 忽略获取条文失败的错误
        }

        String name;
        String description;
        bool isRecommended = false;

        if (i == 0) {
          name = '原数 ($number)';
          description = tiaoWenContent ?? '原始计算数值';
          isRecommended = true;
        } else if (i == 1) {
          name = '加30 ($number)';
          description = tiaoWenContent ?? '基础数加30的调整值';
        } else {
          name = '减30 ($number)';
          description = tiaoWenContent ?? '基础数减30的调整值';
        }

        candidates.add(
          TiaoWenCandidate(
            id: '${groupId}_tiao_wen_$i',
            displayName: name,
            description: description,
            type: TiaoWenCandidateType.baseNumber,
            value: number,
            isDefault: isRecommended,
            metadata: {
              'operation': i == 0
                  ? 'original'
                  : (i == 1 ? 'add30' : 'subtract30'),
              'baseNumber': baseNumber,
              'groupId': groupId,
              'tiaoWenContent': tiaoWenContent,
            },
          ),
        );
      }

      return candidates;
    } catch (e) {
      if (kDebugMode) {
        print('❌ HuangJiSessionService: 生成条文选择候选项失败');
        print('❌ 错误: $e');
      }
      rethrow;
    }
  }

  /// 获取当前步骤的候选项列表
  List<TiaoWenCandidate>? getCurrentStepCandidates(String sessionId) {
    final session = getSession(sessionId);
    return session?.currentStep?.candidates;
  }

  /// 检查当前步骤是否需要用户选择
  bool isCurrentStepWaitingForSelection(String sessionId) {
    final session = getSession(sessionId);
    final currentStep = session?.currentStep;

    if (currentStep == null) return false;

    return !currentStep.isCompleted &&
        (currentStep.candidates?.isNotEmpty ?? false) &&
        currentStep.selectedCandidateId == null;
  }

  /// 获取当前步骤的选择状态
  Map<String, dynamic> getCurrentStepSelectionStatus(String sessionId) {
    final session = getSession(sessionId);
    final currentStep = session?.currentStep;

    if (currentStep == null) {
      return {
        'hasStep': false,
        'needsSelection': false,
        'isCompleted': false,
        'candidatesCount': 0,
      };
    }

    final candidates = currentStep.candidates ?? [];
    final needsSelection =
        !currentStep.isCompleted &&
        candidates.isNotEmpty &&
        currentStep.selectedCandidateId == null;

    return {
      'hasStep': true,
      'needsSelection': needsSelection,
      'isCompleted': currentStep.isCompleted,
      'candidatesCount': candidates.length,
      'selectedCandidateId': currentStep.selectedCandidateId,
      'stepType': currentStep.stepType.toString(),
      'stepName': currentStep.stepName,
    };
  }

  /// 恢复会话到指定步骤
  Future<HuangJiSession> restoreToStep(String sessionId, int stepIndex) async {
    try {
      final session = _getSessionOrThrow(sessionId);
      final currentInstance = session.currentFormulaInstance;
      
      if (currentInstance == null) {
        throw ArgumentError('当前没有活跃的公式实例');
      }

      if (stepIndex < 0 || stepIndex >= currentInstance.calculationSteps.length) {
        throw ArgumentError('步骤索引超出范围: $stepIndex');
      }

      // 更新当前公式实例的步骤索引
      final updatedInstance = currentInstance.copyWith(
        currentStepIndex: stepIndex,
      );

      // 更新会话中的公式实例
      final updatedInstances = List<FormulaInstance>.from(session.formulaInstances);
      updatedInstances[session.currentFormulaIndex] = updatedInstance;

      final restoredSession = session.copyWith(
        formulaInstances: updatedInstances,
        lastActivityAt: DateTime.now(),
      );
      
      _sessions[sessionId] = restoredSession;

      if (kDebugMode) {
        print('✅ HuangJiSessionService: 会话已恢复到步骤 $stepIndex');
      }

      return restoredSession;
    } catch (e) {
      if (kDebugMode) {
        print('❌ HuangJiSessionService: 恢复会话失败');
        print('❌ 错误: $e');
      }
      rethrow;
    }
  }

  /// 暂停会话
  Future<HuangJiSession> pauseSession(String sessionId) async {
    final session = _getSessionOrThrow(sessionId);
    final pausedSession = session.copyWith(
      status: HuangJiSessionStatus.paused,
      lastActivityAt: DateTime.now(),
    );
    _sessions[sessionId] = pausedSession;
    return pausedSession;
  }

  /// 恢复会话
  Future<HuangJiSession> resumeSession(String sessionId) async {
    final session = _getSessionOrThrow(sessionId);
    final resumedSession = session.copyWith(
      status: HuangJiSessionStatus.inProgress,
      lastActivityAt: DateTime.now(),
    );
    _sessions[sessionId] = resumedSession;
    return resumedSession;
  }

  /// 完成会话
  Future<HuangJiSession> completeSession(
    String sessionId, {
    Map<String, dynamic>? resultData,
  }) async {
    final session = _getSessionOrThrow(sessionId);
    final completedSession = session.copyWith(
      status: HuangJiSessionStatus.completed,
      endTime: DateTime.now(),
      lastActivityAt: DateTime.now(),
      resultData: resultData,
    );
    _sessions[sessionId] = completedSession;
    return completedSession;
  }

  /// 取消会话
  Future<HuangJiSession> cancelSession(String sessionId) async {
    final session = _getSessionOrThrow(sessionId);
    final cancelledSession = session.copyWith(
      status: HuangJiSessionStatus.cancelled,
      endTime: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );
    _sessions[sessionId] = cancelledSession;
    return cancelledSession;
  }

  /// 获取会话
  HuangJiSession? getSession(String sessionId) {
    return _sessions[sessionId];
  }

  /// 获取所有活跃会话
  List<HuangJiSession> getActiveSessions() {
    return _sessions.values
        .where(
          (session) =>
              session.status == HuangJiSessionStatus.inProgress ||
              session.status == HuangJiSessionStatus.paused ||
              session.status == HuangJiSessionStatus.waitingForSelection,
        )
        .toList();
  }

  /// 删除会话
  bool deleteSession(String sessionId) {
    return _sessions.remove(sessionId) != null;
  }

  // 私有辅助方法

  /// 获取会话或抛出异常
  HuangJiSession _getSessionOrThrow(String sessionId) {
    final session = _sessions[sessionId];
    if (session == null) {
      throw SessionNotFoundException('会话不存在: $sessionId');
    }
    return session;
  }

  /// 生成会话ID
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 999999);
    return 'huang_ji_session_${timestamp}_$random';
  }

}

/// 会话相关异常
class SessionCreationException extends TiaoWenCalculationException {
  SessionCreationException({required String message, Object? originalException})
    : super(
        message: message,
        code: 'SESSION_CREATION_ERROR',
        originalException: originalException,
      );
}

class SessionNotFoundException extends TiaoWenCalculationException {
  SessionNotFoundException(String message)
    : super(message: message, code: 'SESSION_NOT_FOUND');
}

class SessionStateException extends TiaoWenCalculationException {
  SessionStateException(String message)
    : super(message: message, code: 'SESSION_STATE_ERROR');
}
