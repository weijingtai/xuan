/// 皇极取数法交互式Provider
///
/// 负责管理皇极取数法交互式计算的UI状态和业务逻辑调用
/// 通过UseCase层与业务逻辑交互，实现ViewModel->UseCase->Strategy的架构
library;

import 'package:common/models/eight_chars.dart';
import 'package:flutter/foundation.dart';
import 'package:tiebanshenshu/repository/datamodels/tiao_wen_datamodel.dart';

import '../../application/usecases/huang_ji_interactive_use_case.dart';
import '../../domain/models/huang_ji_calculation_params.dart';
import '../../domain/models/huang_ji_calculation_result.dart';
import '../../domain/models/huang_ji_interactive_step.dart';
import '../../domain/models/interactive_session.dart';
import '../../domain/models/interactive_strategy_config.dart';
import '../../domain/models/tiao_wen_candidate.dart';
import '../../domain/models/multi_base_number_result.dart';
import '../../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../../domain/four_zhu.dart';
import '../../domain/models/tiao_wen_list_state.dart';

/// 交互式Provider状态枚举
enum HuangJiInteractiveProviderState {
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

/// 皇极取数法交互式Provider
///
/// 负责管理皇极取数法交互式计算的完整流程状态
/// 通过UseCase层处理业务逻辑，实现UI状态管理与业务逻辑的分离
class HuangJiInteractiveViewModel extends ChangeNotifier {
  final HuangJiInteractiveUseCase _useCase;

  /// 构造函数
  HuangJiInteractiveViewModel(this._useCase);

  // 状态管理
  HuangJiInteractiveProviderState _state =
      HuangJiInteractiveProviderState.initial;
  InteractiveSession? _currentSession;
  List<TiaoWenCandidate> _currentCandidates = [];
  MultiBaseNumberResult? _finalResult;
  String? _errorMessage;
  Exception? _lastException;

  // 用户输入参数
  EightChars? _inputEightChars;
  InteractiveStrategyConfig? _sessionConfig;

  // 皇极取数法特有状态
  int? _initialNumber;
  int? _secondaryNumber;
  int? _selectedBaseNumber;
  List<int> _finalNumbers = [];
  HuangJiInteractiveStep _currentStep = HuangJiInteractiveStep.initialization;

  /// 当前状态
  HuangJiInteractiveProviderState get state => _state;

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

  /// 输入的四柱
  EightChars? get inputEightChars => _inputEightChars;

  /// 会话配置
  InteractiveStrategyConfig? get sessionConfig => _sessionConfig;

  /// 初刻数
  int? get initialNumber => _initialNumber;

  /// 次条文数
  int? get secondaryNumber => _secondaryNumber;

  /// 选择的基础数
  int? get selectedBaseNumber => _selectedBaseNumber;

  /// 最终条文数列表
  List<int> get finalNumbers => List.unmodifiable(_finalNumbers);

  /// 当前步骤
  HuangJiInteractiveStep get currentStep => _currentStep;

  // 状态判断
  /// 是否为初始状态
  bool get isInitial => _state == HuangJiInteractiveProviderState.initial;

  /// 是否正在启动会话
  bool get isStartingSession =>
      _state == HuangJiInteractiveProviderState.startingSession;

  /// 是否有活跃会话
  bool get hasSession => _currentSession != null;

  /// 是否正在加载候选项
  bool get isLoadingCandidates =>
      _state == HuangJiInteractiveProviderState.loadingCandidates;

  /// 是否正在处理选择
  bool get isProcessingSelection =>
      _state == HuangJiInteractiveProviderState.processingSelection;

  /// 是否正在计算
  bool get isCalculating =>
      _state == HuangJiInteractiveProviderState.calculating;

  /// 是否已完成
  bool get isCompleted => _state == HuangJiInteractiveProviderState.completed;

  /// 是否有错误
  bool get hasError => _state == HuangJiInteractiveProviderState.error;

  /// 是否已取消
  bool get isCancelled => _state == HuangJiInteractiveProviderState.cancelled;

  /// 是否正在加载
  bool get isLoading =>
      isStartingSession ||
      isLoadingCandidates ||
      isProcessingSelection ||
      isCalculating;

  /// 是否可以撤销
  bool get canUndo => hasSession && _currentStep.canUndo;

  /// 是否可以跳转
  bool get canJump => hasSession && !isLoading;

  /// 是否需要用户选择
  bool get needsUserSelection =>
      _currentStep == HuangJiInteractiveStep.userSelection;

  /// 启动交互式会话
  ///
  /// [fourZhu] 四柱信息
  /// [config] 可选的会话配置
  Future<void> startSession(
    EightChars eightChars, {
    InteractiveStrategyConfig? config,
  }) async {
    try {
      if (kDebugMode) {
        print('🚀 HuangJiInteractiveViewModel: 开始启动会话');
        print('📊 输入八字: ${eightChars.toString()}');
      }

      _setState(HuangJiInteractiveProviderState.startingSession);
      _clearError();

      // 保存输入参数
      _inputEightChars = eightChars;
      _sessionConfig = config;

      if (kDebugMode) {
        print('✅ HuangJiInteractiveViewModel: 参数保存完成');
      }

      // 创建计算参数
      final params = HuangJiCalculationParams(eightChars: eightChars);

      if (kDebugMode) {
        print('🔧 HuangJiInteractiveViewModel: 计算参数创建完成');
        print('📞 HuangJiInteractiveViewModel: 调用UseCase.startSession');
      }

      // 启动会话
      final session = await _useCase.startSession(params, config: config);

      if (kDebugMode) {
        print('✅ HuangJiInteractiveViewModel: UseCase.startSession 完成');
        print('🆔 会话ID: ${session.sessionId}');
        print('📊 会话状态: ${session.status}');
      }

      // 更新状态
      _currentSession = session;
      _updateSessionData(session);
      _setState(HuangJiInteractiveProviderState.sessionActive);

      if (kDebugMode) {
        print('✅ HuangJiInteractiveViewModel: 会话状态更新完成');
        print('🔍 needsUserSelection: $needsUserSelection');
        print('📋 currentStep: $_currentStep');
      }

      // 如果需要用户选择，自动加载候选项
      if (needsUserSelection) {
        if (kDebugMode) {
          print('📋 HuangJiInteractiveViewModel: 开始加载候选项');
        }
        await loadCandidates();
      }

      if (kDebugMode) {
        print('🎉 HuangJiInteractiveViewModel: 会话启动完成');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ HuangJiInteractiveViewModel: 启动会话失败');
        print('❌ 错误类型: ${e.runtimeType}');
        print('❌ 错误信息: $e');
        if (e is Exception) {
          print('❌ 异常堆栈: ${StackTrace.current}');
        }
      }
      _handleError('启动会话失败', e);
    }
  }

  /// 加载候选项
  Future<void> loadCandidates() async {
    if (kDebugMode) {
      print('🚀 HuangJiInteractiveViewModel: 开始加载候选项');
      print('🔍 hasSession: $hasSession');
    }

    if (!hasSession) {
      if (kDebugMode) {
        print('❌ HuangJiInteractiveViewModel: 没有活跃的会话');
      }
      _handleError('加载候选项失败', Exception('没有活跃的会话'));
      return;
    }

    try {
      if (kDebugMode) {
        print('🔧 HuangJiInteractiveViewModel: 设置加载候选项状态');
      }

      _setState(HuangJiInteractiveProviderState.loadingCandidates);
      _clearError();

      if (kDebugMode) {
        print('📞 HuangJiInteractiveViewModel: 调用UseCase.getCandidates');
        print('🆔 会话ID: ${_currentSession!.sessionId}');
      }

      final candidates = await _useCase.getCandidates(_currentSession!);

      if (kDebugMode) {
        print('✅ HuangJiInteractiveViewModel: UseCase.getCandidates 完成');
        print('📊 候选项数量: ${candidates.length}');
        for (int i = 0; i < candidates.length && i < 3; i++) {
          print('📋 候选项${i + 1}: ${candidates[i].displayName}');
        }
      }

      _currentCandidates = candidates;
      _setState(HuangJiInteractiveProviderState.candidatesLoaded);

      if (kDebugMode) {
        print('✅ HuangJiInteractiveViewModel: 候选项状态更新完成');
        print('🎉 HuangJiInteractiveViewModel: 候选项加载完成');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ HuangJiInteractiveViewModel: 加载候选项失败');
        print('❌ 错误类型: ${e.runtimeType}');
        print('❌ 错误信息: $e');
      }
      _handleError('加载候选项失败', e);
    }
  }

  /// 选择候选项
  ///
  /// [candidate] 选择的候选项
  Future<void> selectCandidate(TiaoWenCandidate candidate) async {
    if (!hasSession) {
      _handleError('选择候选项失败', Exception('没有活跃的会话'));
      return;
    }

    try {
      _setState(HuangJiInteractiveProviderState.processingSelection);
      _clearError();

      final updatedSession = await _useCase.selectCandidate(
        _currentSession!,
        candidate.id,
      );

      _currentSession = updatedSession;
      _updateSessionData(updatedSession);

      // 检查是否完成
      if (updatedSession.status == InteractiveSessionStatus.completed) {
        await _completeCalculation();
      } else {
        _setState(HuangJiInteractiveProviderState.sessionActive);

        // 如果需要继续选择，加载下一步候选项
        if (needsUserSelection) {
          await loadCandidates();
        }
      }
    } catch (e) {
      _handleError('选择候选项失败', e);
    }
  }

  /// 撤销到上一步
  Future<void> undo() async {
    if (!hasSession || !canUndo) {
      _handleError('撤销失败', Exception('当前状态不支持撤销'));
      return;
    }

    try {
      _setState(HuangJiInteractiveProviderState.processingSelection);
      _clearError();

      final updatedSession = await _useCase.undo(_currentSession!);

      _currentSession = updatedSession;
      _updateSessionData(updatedSession);
      _setState(HuangJiInteractiveProviderState.sessionActive);

      // 重新加载候选项
      if (needsUserSelection) {
        await loadCandidates();
      }
    } catch (e) {
      _handleError('撤销失败', e);
    }
  }

  /// 跳转到指定步骤
  ///
  /// [stepIndex] 目标步骤索引
  Future<void> jumpToStep(int stepIndex) async {
    if (!hasSession || !canJump) {
      _handleError('跳转失败', Exception('当前状态不支持跳转'));
      return;
    }

    try {
      _setState(HuangJiInteractiveProviderState.processingSelection);
      _clearError();

      final updatedSession = await _useCase.jumpTo(_currentSession!, stepIndex);

      _currentSession = updatedSession;
      _updateSessionData(updatedSession);
      _setState(HuangJiInteractiveProviderState.sessionActive);

      // 重新加载候选项
      if (needsUserSelection) {
        await loadCandidates();
      }
    } catch (e) {
      _handleError('跳转失败', e);
    }
  }

  /// 取消会话
  Future<void> cancelSession() async {
    if (!hasSession) {
      return;
    }

    try {
      await _useCase.cancelSession(_currentSession!.sessionId);
      _setState(HuangJiInteractiveProviderState.cancelled);
      _clearSession();
    } catch (e) {
      _handleError('取消会话失败', e);
    }
  }

  /// 重置Provider状态
  void reset() {
    _setState(HuangJiInteractiveProviderState.initial);
    _clearSession();
    _clearError();
  }

  /// 完成计算并获取最终结果
  Future<void> _completeCalculation() async {
    try {
      _setState(HuangJiInteractiveProviderState.calculating);

      final result = await _useCase.completeCalculation(_currentSession!);
      _finalResult = result;
      _setState(HuangJiInteractiveProviderState.completed);
    } catch (e) {
      _handleError('完成计算失败', e);
    }
  }

  /// 更新会话数据
  void _updateSessionData(InteractiveSession session) {
    // 从sessionConfig中读取配置数据
    final configData = session.sessionConfig ?? {};
    // 从resultData中读取结果数据
    final resultData = session.resultData ?? {};

    if (kDebugMode) {
      print('🔄 HuangJiInteractiveViewModel: 更新会话数据');
      print('📊 sessionConfig: $configData');
      print('📊 resultData: $resultData');
    }

    // 优先从resultData读取，如果没有则从configData读取
    _initialNumber = resultData['initialNumber'] as int? ?? 
                    configData['initialNumber'] as int?;
    _secondaryNumber = resultData['secondaryNumber'] as int? ?? 
                      configData['secondaryNumber'] as int?;
    _selectedBaseNumber = resultData['selectedBaseNumber'] as int? ?? 
                         configData['selectedBaseNumber'] as int?;

    final finalNumbersData = resultData['finalNumbers'] ?? configData['finalNumbers'];
    if (finalNumbersData is List) {
      _finalNumbers = finalNumbersData.cast<int>();
    }

    // currentStep优先从resultData读取，如果没有则从configData读取
    final currentStepId = resultData['currentStep'] as String? ?? 
                         configData['currentStep'] as String?;
    if (currentStepId != null) {
      _currentStep =
          HuangJiInteractiveStep.fromString(currentStepId) ??
          HuangJiInteractiveStep.initialization;
      
      if (kDebugMode) {
        print('📊 currentStepId: $currentStepId');
        print('📊 解析后的currentStep: $_currentStep');
      }
    } else {
      if (kDebugMode) {
        print('⚠️ 未找到currentStep，使用默认值: initialization');
      }
    }
  }

  /// 设置状态
  void _setState(HuangJiInteractiveProviderState newState) {
    if (_state != newState) {
      if (kDebugMode) {
        print('🔄 HuangJiInteractiveViewModel: 状态变化');
        print('📊 旧状态: $_state');
        print('📊 新状态: $newState');
      }

      _state = newState;

      if (kDebugMode) {
        print('📢 HuangJiInteractiveViewModel: 调用notifyListeners()');
        print('🔍 当前状态属性:');
        print('   - isLoading: $isLoading');
        print('   - hasError: $hasError');
        print('   - isCompleted: $isCompleted');
        print('   - needsUserSelection: $needsUserSelection');
        print('   - hasSession: $hasSession');
      }

      notifyListeners();

      if (kDebugMode) {
        print('✅ HuangJiInteractiveViewModel: notifyListeners() 完成');
      }
    } else {
      if (kDebugMode) {
        print('⚠️ HuangJiInteractiveViewModel: 状态未变化，跳过通知');
        print('📊 当前状态: $_state');
      }
    }
  }

  /// 处理错误
  void _handleError(String message, dynamic error) {
    _errorMessage = message;
    _lastException = error is Exception ? error : Exception(error.toString());
    _setState(HuangJiInteractiveProviderState.error);

    if (kDebugMode) {
      print('HuangJiInteractiveProvider Error: $message');
      print('Exception: $error');
    }
  }

  /// 清除错误
  void _clearError() {
    _errorMessage = null;
    _lastException = null;
  }

  /// 清除会话
  void _clearSession() {
    _currentSession = null;
    _currentCandidates.clear();
    _finalResult = null;
    _inputEightChars = null;
    _sessionConfig = null;
    _initialNumber = null;
    _secondaryNumber = null;
    _selectedBaseNumber = null;
    _finalNumbers.clear();
    _currentStep = HuangJiInteractiveStep.initialization;
  }

  /// 获取状态显示文本
  String getStateDisplayText() {
    switch (_state) {
      case HuangJiInteractiveProviderState.initial:
        return '未开始';
      case HuangJiInteractiveProviderState.startingSession:
        return '启动中';
      case HuangJiInteractiveProviderState.sessionActive:
        return '进行中';
      case HuangJiInteractiveProviderState.loadingCandidates:
        return '加载选项';
      case HuangJiInteractiveProviderState.candidatesLoaded:
        return '等待选择';
      case HuangJiInteractiveProviderState.processingSelection:
        return '处理选择';
      case HuangJiInteractiveProviderState.calculating:
        return '计算中';
      case HuangJiInteractiveProviderState.completed:
        return '已完成';
      case HuangJiInteractiveProviderState.error:
        return '出错';
      case HuangJiInteractiveProviderState.cancelled:
        return '已取消';
    }
  }

  /// 获取当前步骤显示文本
  String getCurrentStepDisplayText() {
    return _currentStep.name;
  }

  /// 获取会话持续时间文本
  String getSessionDurationText() {
    if (!hasSession) return '--';

    final duration = DateTime.now().difference(_currentSession!.startTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}分${seconds}秒';
    } else {
      return '${seconds}秒';
    }
  }

  /// 获取用户友好的错误消息
  String getUserFriendlyErrorMessage() {
    if (_lastException == null) return _errorMessage ?? '未知错误';

    if (_lastException is TiaoWenCalculationException) {
      final exception = _lastException as TiaoWenCalculationException;
      return exception.message;
    }

    return _errorMessage ?? _lastException!.toString();
  }

  @override
  void dispose() {
    // 清理资源
    _clearSession();
    super.dispose();
  }
}
