/// 交互式会话模型
///
/// 定义交互式策略的会话状态和历史记录
library;

import 'tiao_wen_candidate.dart';

/// 会话状态枚举
enum InteractiveSessionStatus {
  /// 未开始
  notStarted,
  
  /// 进行中
  inProgress,
  
  /// 等待用户选择
  waitingForSelection,
  
  /// 已完成
  completed,
  
  /// 已取消
  cancelled,
  
  /// 出错
  error,
}

/// 会话步骤
///
/// 记录交互式会话中的每一步操作
class InteractiveSessionStep {
  /// 步骤序号
  final int stepNumber;

  /// 步骤名称
  final String stepName;

  /// 步骤描述
  final String description;

  /// 可选的候选项列表
  final List<TiaoWenCandidate> candidates;

  /// 用户选择的候选项ID
  final String? selectedCandidateId;

  /// 步骤开始时间
  final DateTime startTime;

  /// 步骤完成时间
  final DateTime? completedTime;

  /// 步骤状态
  final InteractiveSessionStatus status;

  /// 额外的步骤数据
  final Map<String, dynamic>? stepData;

  /// 构造函数
  const InteractiveSessionStep({
    required this.stepNumber,
    required this.stepName,
    required this.description,
    required this.candidates,
    this.selectedCandidateId,
    required this.startTime,
    this.completedTime,
    required this.status,
    this.stepData,
  });

  /// 获取选中的候选项
  TiaoWenCandidate? get selectedCandidate {
    if (selectedCandidateId == null) return null;
    try {
      return candidates.firstWhere((c) => c.id == selectedCandidateId);
    } catch (e) {
      return null;
    }
  }

  /// 是否已完成
  bool get isCompleted => status == InteractiveSessionStatus.completed;

  /// 复制并修改步骤
  InteractiveSessionStep copyWith({
    int? stepNumber,
    String? stepName,
    String? description,
    List<TiaoWenCandidate>? candidates,
    String? selectedCandidateId,
    DateTime? startTime,
    DateTime? completedTime,
    InteractiveSessionStatus? status,
    Map<String, dynamic>? stepData,
  }) {
    return InteractiveSessionStep(
      stepNumber: stepNumber ?? this.stepNumber,
      stepName: stepName ?? this.stepName,
      description: description ?? this.description,
      candidates: candidates ?? this.candidates,
      selectedCandidateId: selectedCandidateId ?? this.selectedCandidateId,
      startTime: startTime ?? this.startTime,
      completedTime: completedTime ?? this.completedTime,
      status: status ?? this.status,
      stepData: stepData ?? this.stepData,
    );
  }

  @override
  String toString() {
    return 'InteractiveSessionStep('
        'stepNumber: $stepNumber, '
        'stepName: $stepName, '
        'status: $status, '
        'selectedCandidateId: $selectedCandidateId)';
  }
}

/// 交互式会话
///
/// 管理整个交互式策略的会话状态
class InteractiveSession {
  /// 会话唯一标识
  final String sessionId;

  /// 策略名称
  final String strategyName;

  /// 会话开始时间
  final DateTime startTime;

  /// 会话结束时间
  final DateTime? endTime;

  /// 会话状态
  final InteractiveSessionStatus status;

  /// 会话步骤列表
  final List<InteractiveSessionStep> steps;

  /// 当前步骤索引
  final int currentStepIndex;

  /// 会话配置
  final Map<String, dynamic>? sessionConfig;

  /// 会话结果数据
  final Map<String, dynamic>? resultData;

  /// 错误信息
  final String? errorMessage;

  /// 构造函数
  const InteractiveSession({
    required this.sessionId,
    required this.strategyName,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.steps,
    required this.currentStepIndex,
    this.sessionConfig,
    this.resultData,
    this.errorMessage,
  });

  /// 创建新会话
  factory InteractiveSession.create({
    required String sessionId,
    required String strategyName,
    Map<String, dynamic>? sessionConfig,
  }) {
    return InteractiveSession(
      sessionId: sessionId,
      strategyName: strategyName,
      startTime: DateTime.now(),
      status: InteractiveSessionStatus.notStarted,
      steps: [],
      currentStepIndex: -1,
      sessionConfig: sessionConfig,
    );
  }

  /// 获取当前步骤
  InteractiveSessionStep? get currentStep {
    if (currentStepIndex < 0 || currentStepIndex >= steps.length) {
      return null;
    }
    return steps[currentStepIndex];
  }

  /// 获取已完成的步骤
  List<InteractiveSessionStep> get completedSteps {
    return steps.where((step) => step.isCompleted).toList();
  }

  /// 是否可以撤销
  bool get canUndo => currentStepIndex > 0;

  /// 是否可以跳转
  bool get canJumpTo => steps.isNotEmpty;

  /// 是否已完成
  bool get isCompleted => status == InteractiveSessionStatus.completed;

  /// 是否进行中
  bool get isInProgress => status == InteractiveSessionStatus.inProgress ||
      status == InteractiveSessionStatus.waitingForSelection;

  /// 会话持续时间
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// 添加步骤
  InteractiveSession addStep(InteractiveSessionStep step) {
    final newSteps = List<InteractiveSessionStep>.from(steps)..add(step);
    return copyWith(
      steps: newSteps,
      currentStepIndex: newSteps.length - 1,
      status: InteractiveSessionStatus.inProgress,
    );
  }

  /// 更新当前步骤
  InteractiveSession updateCurrentStep(InteractiveSessionStep updatedStep) {
    if (currentStepIndex < 0 || currentStepIndex >= steps.length) {
      return this;
    }
    
    final newSteps = List<InteractiveSessionStep>.from(steps);
    newSteps[currentStepIndex] = updatedStep;
    
    return copyWith(steps: newSteps);
  }

  /// 移动到下一步
  InteractiveSession moveToNextStep() {
    if (currentStepIndex < steps.length - 1) {
      return copyWith(currentStepIndex: currentStepIndex + 1);
    }
    return this;
  }

  /// 撤销到上一步
  InteractiveSession undoToPreviousStep() {
    if (canUndo) {
      return copyWith(currentStepIndex: currentStepIndex - 1);
    }
    return this;
  }

  /// 跳转到指定步骤
  InteractiveSession jumpToStep(int stepIndex) {
    if (stepIndex >= 0 && stepIndex < steps.length) {
      return copyWith(currentStepIndex: stepIndex);
    }
    return this;
  }

  /// 完成会话
  InteractiveSession complete({Map<String, dynamic>? resultData}) {
    return copyWith(
      status: InteractiveSessionStatus.completed,
      endTime: DateTime.now(),
      resultData: resultData,
    );
  }

  /// 取消会话
  InteractiveSession cancel() {
    return copyWith(
      status: InteractiveSessionStatus.cancelled,
      endTime: DateTime.now(),
    );
  }

  /// 设置错误状态
  InteractiveSession setError(String errorMessage) {
    return copyWith(
      status: InteractiveSessionStatus.error,
      endTime: DateTime.now(),
      errorMessage: errorMessage,
    );
  }

  /// 复制并修改会话
  InteractiveSession copyWith({
    String? sessionId,
    String? strategyName,
    DateTime? startTime,
    DateTime? endTime,
    InteractiveSessionStatus? status,
    List<InteractiveSessionStep>? steps,
    int? currentStepIndex,
    Map<String, dynamic>? sessionConfig,
    Map<String, dynamic>? resultData,
    String? errorMessage,
  }) {
    return InteractiveSession(
      sessionId: sessionId ?? this.sessionId,
      strategyName: strategyName ?? this.strategyName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      steps: steps ?? this.steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      sessionConfig: sessionConfig ?? this.sessionConfig,
      resultData: resultData ?? this.resultData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'InteractiveSession('
        'sessionId: $sessionId, '
        'strategyName: $strategyName, '
        'status: $status, '
        'currentStepIndex: $currentStepIndex, '
        'stepsCount: ${steps.length})';
  }
}