/// 太玄四柱交互式Provider
///
/// 负责管理太玄四柱交互式计算的UI状态和业务逻辑调用
library;

import 'package:common/models/eight_chars.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/interactive_session.dart';
import '../../domain/models/interactive_strategy_config.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import '../../domain/models/multi_base_number_result.dart';
import '../../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../../usecases/tai_xuan_four_zhu_interactive_use_case.dart';

/// 交互式Provider状态枚举
enum InteractiveProviderState {
  /// 初始状态
  initial,

  /// 正在启动会话
  startingSession,

  /// 会话已启动，等待用户交互
  sessionActive,

  /// 正在加载候选项
  loadingCandidates,

  /// 候选项已加载
  candidatesLoaded,

  /// 正在处理用户选择
  processingSelection,

  /// 正在计算最终结果
  calculating,

  /// 计算完成
  completed,

  /// 发生错误
  error,

  /// 会话已取消
  cancelled,
}

/// 太玄四柱交互式Provider
///
/// 负责管理交互式计算的完整流程状态
class TaiXuanFourZhuInteractiveViewModel extends ChangeNotifier {
  final TaiXuanFourZhuInteractiveUseCase _useCase;

  /// 构造函数
  TaiXuanFourZhuInteractiveViewModel(this._useCase);

  // 状态管理
  InteractiveProviderState _state = InteractiveProviderState.initial;
  InteractiveSession? _currentSession;
  List<TiaoWenCandidate> _currentCandidates = [];
  MultiBaseNumberResult? _finalResult;
  String? _errorMessage;
  Exception? _lastException;

  // 用户输入参数
  EightChars? _inputEightChars;
  InteractiveStrategyConfig? _sessionConfig;

  /// 当前状态
  InteractiveProviderState get state => _state;

  /// 当前会话
  InteractiveSession? get currentSession => _currentSession;

  /// 当前候选项列表
  List<TiaoWenCandidate> get currentCandidates =>
      List.unmodifiable(_currentCandidates);

  /// 最终计算结果
  MultiBaseNumberResult? get finalResult => _finalResult;

  /// 错误消息
  String? get errorMessage => _errorMessage;

  /// 最后一次异常
  Exception? get lastException => _lastException;

  /// 输入的八字
  EightChars? get inputEightChars => _inputEightChars;

  /// 会话配置
  InteractiveStrategyConfig? get sessionConfig => _sessionConfig;

  // 状态判断
  /// 是否为初始状态
  bool get isInitial => _state == InteractiveProviderState.initial;

  /// 是否正在启动会话
  bool get isStartingSession =>
      _state == InteractiveProviderState.startingSession;

  /// 会话是否活跃
  bool get isSessionActive => _state == InteractiveProviderState.sessionActive;

  /// 是否正在加载候选项
  bool get isLoadingCandidates =>
      _state == InteractiveProviderState.loadingCandidates;

  /// 候选项是否已加载
  bool get areCandidatesLoaded =>
      _state == InteractiveProviderState.candidatesLoaded;

  /// 是否正在处理选择
  bool get isProcessingSelection =>
      _state == InteractiveProviderState.processingSelection;

  /// 是否正在计算
  bool get isCalculating => _state == InteractiveProviderState.calculating;

  /// 是否已完成
  bool get isCompleted => _state == InteractiveProviderState.completed;

  /// 是否有错误
  bool get hasError => _state == InteractiveProviderState.error;

  /// 是否已取消
  bool get isCancelled => _state == InteractiveProviderState.cancelled;

  /// 是否正在加载（任何加载状态）
  bool get isLoading =>
      isStartingSession ||
      isLoadingCandidates ||
      isProcessingSelection ||
      isCalculating;

  /// 是否可以交互
  bool get canInteract => isSessionActive || areCandidatesLoaded;

  /// 是否有会话
  bool get hasSession => _currentSession != null;

  /// 是否有候选项
  bool get hasCandidates => _currentCandidates.isNotEmpty;

  /// 是否有结果
  bool get hasResult => _finalResult != null;

  /// 会话是否可以完成
  bool get canComplete => _currentSession?.isCompleted ?? false;

  /// 会话是否可以撤销
  bool get canUndo => _currentSession?.canUndo ?? false;

  /// 会话是否可以跳转
  bool get canJump => _currentSession?.steps.isNotEmpty ?? false;

  // 会话信息
  /// 当前步骤索引
  int get currentStepIndex => _currentSession?.currentStepIndex ?? -1;

  /// 总步骤数
  int get totalSteps => _currentSession?.steps.length ?? 0;

  /// 当前步骤名称
  String get currentStepName => _currentSession?.currentStep?.stepName ?? '';

  /// 当前步骤描述
  String get currentStepDescription =>
      _currentSession?.currentStep?.description ?? '';

  /// 会话进度百分比
  double get sessionProgress {
    if (_currentSession == null || _currentSession!.steps.isEmpty) return 0.0;
    return (_currentSession!.currentStepIndex + 1) /
        _currentSession!.steps.length;
  }

  /// 会话持续时间
  Duration get sessionDuration => _currentSession?.duration ?? Duration.zero;

  /// 开始交互式会话
  ///
  /// [eightChars] 八字信息
  /// [config] 交互式配置（可选）
  /// [allowFourZhuModification] 是否允许修改四柱
  /// [allowCalculationMethodSelection] 是否允许选择计算方法
  /// [allowGuaMappingSelection] 是否允许选择卦象映射
  Future<void> startSession(
    EightChars eightChars, {
    InteractiveStrategyConfig? config,
    bool allowFourZhuModification = true,
    bool allowCalculationMethodSelection = true,
    bool allowGuaMappingSelection = false,
  }) async {
    try {
      _setState(InteractiveProviderState.startingSession);
      _clearError();

      // 保存输入参数
      _inputEightChars = eightChars;
      _sessionConfig = config;

      // 创建UseCase参数
      final params = TaiXuanFourZhuInteractiveUseCaseParams(
        eightChars: eightChars,
        allowFourZhuModification: allowFourZhuModification,
        allowCalculationMethodSelection: allowCalculationMethodSelection,
        allowGuaMappingSelection: allowGuaMappingSelection,
      );

      // 启动会话
      _currentSession = await _useCase.startSession(params, config: config);
      _setState(InteractiveProviderState.sessionActive);

      // 自动加载第一步的候选项
      await loadCandidates();
    } catch (e) {
      _setError('启动会话失败: ${e.toString()}', _convertToException(e));
    }
  }

  /// 加载当前步骤的候选项
  Future<void> loadCandidates() async {
    if (_currentSession == null) {
      _setError('会话不存在', null);
      return;
    }

    try {
      _setState(InteractiveProviderState.loadingCandidates);
      _clearError();

      _currentCandidates = await _useCase.getCandidates(_currentSession!);
      _setState(InteractiveProviderState.candidatesLoaded);
    } catch (e) {
      _setError('加载候选项失败: ${e.toString()}', _convertToException(e));
    }
  }

  /// 选择候选项
  ///
  /// [candidateId] 候选项ID
  Future<void> selectCandidate(String candidateId) async {
    if (_currentSession == null) {
      _setError('会话不存在', null);
      return;
    }

    try {
      _setState(InteractiveProviderState.processingSelection);
      _clearError();

      _currentSession = await _useCase.selectCandidate(
        _currentSession!,
        candidateId,
      );

      // 检查是否已完成
      if (_currentSession!.isCompleted) {
        await _completeCalculation();
      } else {
        // 加载下一步的候选项
        await loadCandidates();
      }
    } catch (e) {
      _setError('选择候选项失败: ${e.toString()}', _convertToException(e));
    }
  }

  /// 调整当前步骤
  ///
  /// [adjustments] 调整参数
  Future<void> adjustStep(Map<String, dynamic> adjustments) async {
    if (_currentSession == null) {
      _setError('会话不存在', null);
      return;
    }

    try {
      _setState(InteractiveProviderState.processingSelection);
      _clearError();

      _currentSession = await _useCase.adjustStep(
        _currentSession!,
        adjustments,
      );

      // 重新加载候选项
      await loadCandidates();
    } catch (e) {
      _setError('调整步骤失败: ${e.toString()}', _convertToException(e));
    }
  }

  /// 跳转到指定步骤
  ///
  /// [stepIndex] 步骤索引
  Future<void> jumpToStep(int stepIndex) async {
    if (_currentSession == null) {
      _setError('会话不存在', null);
      return;
    }

    try {
      _setState(InteractiveProviderState.processingSelection);
      _clearError();

      _currentSession = await _useCase.jumpTo(_currentSession!, stepIndex);

      // 重新加载候选项
      await loadCandidates();
    } catch (e) {
      _setError('跳转步骤失败: ${e.toString()}', _convertToException(e));
    }
  }

  /// 撤销到上一步
  Future<void> undoStep() async {
    if (_currentSession == null) {
      _setError('会话不存在', null);
      return;
    }

    try {
      _setState(InteractiveProviderState.processingSelection);
      _clearError();

      _currentSession = await _useCase.undo(_currentSession!);

      // 重新加载候选项
      await loadCandidates();
    } catch (e) {
      _setError('撤销失败: ${e.toString()}', _convertToException(e));
    }
  }

  /// 获取无限列表数据
  ///
  /// [offset] 偏移量
  /// [limit] 限制数量
  Future<List<dynamic>> getInfiniteList(int offset, int limit) async {
    if (_currentSession == null) {
      throw Exception('会话不存在');
    }

    try {
      return await _useCase.getInfiniteList(_currentSession!, offset, limit);
    } catch (e) {
      _setError('获取无限列表失败: ${e.toString()}', _convertToException(e));
      return [];
    }
  }

  /// 完成计算
  Future<void> completeCalculation() async {
    if (_currentSession == null) {
      _setError('会话不存在', null);
      return;
    }

    if (!_currentSession!.isCompleted) {
      _setError('会话尚未完成', null);
      return;
    }

    await _completeCalculation();
  }

  /// 内部完成计算方法
  Future<void> _completeCalculation() async {
    try {
      _setState(InteractiveProviderState.calculating);
      _clearError();

      _finalResult = await _useCase.completeCalculation(_currentSession!);
      _setState(InteractiveProviderState.completed);
    } catch (e) {
      _setError('完成计算失败: ${e.toString()}', _convertToException(e));
    }
  }

  /// 取消会话
  Future<void> cancelSession() async {
    if (_currentSession == null) {
      _setError('会话不存在', null);
      return;
    }

    try {
      _currentSession = await _useCase.cancelSession(
        _currentSession!.sessionId,
      );
      _setState(InteractiveProviderState.cancelled);
      _clearData();
    } catch (e) {
      _setError('取消会话失败: ${e.toString()}', _convertToException(e));
    }
  }

  /// 重置Provider状态
  void reset() {
    _setState(InteractiveProviderState.initial);
    _clearData();
    _clearError();
  }

  /// 重新开始（使用相同参数）
  Future<void> restart() async {
    if (_inputEightChars == null) {
      _setError('没有保存的输入参数', null);
      return;
    }

    reset();
    await startSession(_inputEightChars!, config: _sessionConfig);
  }

  /// 设置状态
  void _setState(InteractiveProviderState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// 将捕获的异常转换为Exception类型
  ///
  /// [error] 捕获的异常对象
  /// 返回Exception类型的异常
  Exception _convertToException(Object error) {
    if (error is Exception) {
      return error;
    } else if (error is Error) {
      return ErrorException(error);
    } else {
      return Exception(error.toString());
    }
  }

  /// 设置错误
  void _setError(String message, Exception? exception) {
    _errorMessage = message;
    _lastException = exception;
    _setState(InteractiveProviderState.error);
  }

  /// 清除错误
  void _clearError() {
    _errorMessage = null;
    _lastException = null;
  }

  /// 清除数据
  void _clearData() {
    _currentSession = null;
    _currentCandidates.clear();
    _finalResult = null;
  }

  // 便利方法

  /// 获取候选项显示文本
  String getCandidateDisplayText(TiaoWenCandidate candidate) {
    final parts = <String>[];

    if (candidate.displayName.isNotEmpty) {
      parts.add(candidate.displayName);
    }

    if (candidate.description.isNotEmpty) {
      parts.add('(${candidate.description})');
    }

    return parts.join(' ');
  }

  /// 获取候选项类型显示文本
  String getCandidateTypeDisplayText(TiaoWenCandidateType type) {
    switch (type) {
      case TiaoWenCandidateType.fourZhu:
        return '四柱';
      case TiaoWenCandidateType.calculationMethod:
        return '计算方法';
      case TiaoWenCandidateType.guaMapping:
        return '卦象映射';
      case TiaoWenCandidateType.confirmation:
        return '确认';
      case TiaoWenCandidateType.custom:
        return '自定义';
      case TiaoWenCandidateType.baseNumber:
        return '数字';
      case TiaoWenCandidateType.gua:
        return '卦象';
      case TiaoWenCandidateType.ganzhi:
        return '干支';
    }
  }

  /// 获取会话状态显示文本
  String getSessionStatusDisplayText() {
    if (_currentSession == null) return '无会话';

    switch (_currentSession!.status) {
      case InteractiveSessionStatus.inProgress:
        return '进行中';
      case InteractiveSessionStatus.completed:
        return '已完成';
      case InteractiveSessionStatus.cancelled:
        return '已取消';
      case InteractiveSessionStatus.error:
        return '错误';
      case InteractiveSessionStatus.notStarted:
        return '未开始';
      case InteractiveSessionStatus.waitingForSelection:
        return '等待用户选择';
    }
  }

  /// 获取Provider状态显示文本
  String getProviderStateDisplayText() {
    switch (_state) {
      case InteractiveProviderState.initial:
        return '初始状态';
      case InteractiveProviderState.startingSession:
        return '启动会话中...';
      case InteractiveProviderState.sessionActive:
        return '会话活跃';
      case InteractiveProviderState.loadingCandidates:
        return '加载候选项中...';
      case InteractiveProviderState.candidatesLoaded:
        return '候选项已加载';
      case InteractiveProviderState.processingSelection:
        return '处理选择中...';
      case InteractiveProviderState.calculating:
        return '计算中...';
      case InteractiveProviderState.completed:
        return '计算完成';
      case InteractiveProviderState.error:
        return '错误';
      case InteractiveProviderState.cancelled:
        return '已取消';
    }
  }

  /// 获取步骤进度文本
  String getStepProgressText() {
    if (_currentSession == null) return '0/0';
    return '${_currentSession!.currentStepIndex + 1}/${_currentSession!.steps.length}';
  }

  /// 获取会话持续时间文本
  String getSessionDurationText() {
    final duration = sessionDuration;
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}分${duration.inSeconds % 60}秒';
    } else {
      return '${duration.inSeconds}秒';
    }
  }

  @override
  void dispose() {
    // 清理资源
    _clearData();
    super.dispose();
  }
}
