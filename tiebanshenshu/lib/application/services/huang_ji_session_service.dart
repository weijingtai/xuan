/// 皇极取数法会话服务
///
/// 职责：
/// - 基于公式模板与八字创建皇极取数会话，初始化全部公式步骤
/// - 管理会话状态流转：执行下一步、恢复到指定步骤、暂停/恢复/完成/取消
/// - 管理用户交互：生成候选项、创建用户选择步骤、处理用户选择
/// - 与 `TiaoWenRepository` 交互，按基础数读取条文内容用于候选显示
/// - 提供当前步骤的候选与选择状态查询，供 UI 判断是否需要交互
///
/// 设计要点：
/// - 通过内存 Map `_sessions` 管理多个并行会话，Key 为会话 ID
/// - 使用 `HuangJiSessionManager` 完成会话公式实例的复制/推进/选择写入
/// - 所有公开方法尽量保持幂等或抛出明确的业务异常，便于上层容错
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
  ///
  /// 入参：
  /// - `sessionName` 会话名称（用于展示/日志）
  /// - `formulaTemplate` 皇极计算公式模板（用于初始化步骤）
  /// - `eightChars` 八字数据（供策略/公式计算使用）
  /// - `sessionConfig` 会话级配置（可选）
  /// - `metadata` 额外元信息（可选）
  /// 返回：已初始化的会话对象，包含公式实例与初始步骤状态
  /// 错误：抛出 `SessionCreationException`，包含原始异常
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
  ///
  /// 行为：将当前公式实例的步骤索引 +1 并回写至会话；若已完成或无下一步则抛出状态异常
  /// 入参：`sessionId` 会话标识
  /// 返回：更新后的会话对象
  /// 错误：`SessionStateException`（完成/无下一步/当前实例不存在）
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
  ///
  /// 行为：在指定公式步骤中选中候选项，将其映射为 `SelectionCandidate` 写入会话
  /// 入参：
  /// - `sessionId` 当前会话 ID
  /// - `formulaName` 目标公式名称
  /// - `stepId` 目标步骤 ID
  /// - `candidateId` 待选择的候选项 ID
  /// 返回：更新后的会话对象
  /// 错误：入参不存在时抛 `ArgumentError`；其他错误原样抛出
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
  ///
  /// 行为：基于 `baseNumber` 生成 [原数, +30, -30] 三个候选项，标注默认推荐项
  /// 入参：`sessionId`（校验存在）、`groupId`（候选分组标识）、`baseNumber`（原数）
  /// 返回：候选项列表，不访问条文仓库
  /// 错误：会话不存在时抛异常
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
  ///
  /// 行为：构造一个需要用户选择的计算步骤，附带候选项与分组信息
  /// 入参：
  /// - `session` 会话对象（用于生成默认 stepId）
  /// - `stepType` 步骤类型
  /// - `stepName` 步骤显示名称
  /// - `description` 步骤描述
  /// - `stepNumber` 步骤序号
  /// - `candidates` 候选项列表
  /// - `inputData` 输入数据字典
  /// - `groupId`/`stepId` 可选，未提供则自动生成
  /// 返回：`HuangJiCalculationStep` 对象，`requiresUserSelection=true`
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
  ///
  /// 行为：在会话中记录用户对某一步骤的候选选择，推进步骤状态
  /// 入参：同 `selectCandidate`，另含 `selectionReason`（可选）
  /// 返回：更新后的会话对象
  /// 错误：入参不存在抛 `ArgumentError`；其他错误原样抛出
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
  ///
  /// 行为：判断当前步骤存在、未完成且候选非空
  /// 返回：布尔值；异常时返回 `false`
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
  ///
  /// 行为：返回当前步骤未完成时的候选项列表；异常或不满足条件返回 `null`
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
  ///
  /// 行为：基于 `baseNumber` 生成 [原数, +30, -30] 候选，并尝试从仓库读取对应条文内容作为描述
  /// 返回：候选项列表（条文内容缺失时使用占位描述）
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
  /// 返回：候选项列表或 `null`
  List<TiaoWenCandidate>? getCurrentStepCandidates(String sessionId) {
    final session = getSession(sessionId);
    return session?.currentStep?.candidates;
  }

  /// 检查当前步骤是否需要用户选择
  /// 返回：布尔值
  bool isCurrentStepWaitingForSelection(String sessionId) {
    final session = getSession(sessionId);
    final currentStep = session?.currentStep;

    if (currentStep == null) return false;

    return !currentStep.isCompleted &&
        (currentStep.candidates?.isNotEmpty ?? false) &&
        currentStep.selectedCandidateId == null;
  }

  /// 获取当前步骤的选择状态
  /// 返回：包含步骤存在、是否需选择、是否完成、候选数量、已选候选ID、步骤类型与名称的字典
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
  ///
  /// 行为：将当前公式实例的 `currentStepIndex` 更新为指定索引
  /// 入参：`sessionId`、`stepIndex`
  /// 返回：更新后的会话对象
  /// 错误：索引越界或无实例时抛出异常
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
  /// 返回：状态置为 `paused` 的会话对象
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
  /// 返回：状态置为 `inProgress` 的会话对象
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
  /// 返回：状态置为 `completed` 并写入结果数据的会话对象
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
  /// 返回：状态置为 `cancelled` 的会话对象
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
  /// 返回：会话或 `null`
  HuangJiSession? getSession(String sessionId) {
    return _sessions[sessionId];
  }

  /// 获取所有活跃会话
  /// 返回：状态为进行中/暂停/等待选择的会话列表
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
  /// 返回：删除成功与否
  bool deleteSession(String sessionId) {
    return _sessions.remove(sessionId) != null;
  }

  // 私有辅助方法

  /// 获取会话或抛出异常
  /// 错误：`SessionNotFoundException`
  HuangJiSession _getSessionOrThrow(String sessionId) {
    final session = _sessions[sessionId];
    if (session == null) {
      throw SessionNotFoundException('会话不存在: $sessionId');
    }
    return session;
  }

  /// 生成会话ID
  /// 组成：时间戳 + 模 999999 的随机部分
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
