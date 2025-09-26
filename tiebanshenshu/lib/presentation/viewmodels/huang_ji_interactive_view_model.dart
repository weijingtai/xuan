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
  bool get needsUserSelection {
    final result = _currentStep == HuangJiInteractiveStep.userSelection;
    if (kDebugMode) {
      print('🔍 needsUserSelection 检查:');
      print('   - _currentStep: $_currentStep');
      print('   - HuangJiInteractiveStep.userSelection: ${HuangJiInteractiveStep.userSelection}');
      print('   - 结果: $result');
    }
    return result;
  }

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
        print('🔍 最终状态检查:');
        print('   - hasSession: $hasSession');
        print('   - needsUserSelection: $needsUserSelection');
        print('   - currentCandidates.length: ${_currentCandidates.length}');
        print('   - currentStep: $_currentStep');
        print('   - state: $_state');
        if (_currentSession?.currentStep != null) {
          print('   - session.currentStep.stepName: ${_currentSession!.currentStep!.stepName}');
          print('   - session.currentStep.candidates.length: ${_currentSession!.currentStep!.candidates.length}');
        }
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

        // 显示前10个候选项
        for (int i = 0; i < candidates.length && i < 10; i++) {
          print(
            '📋 候选项${i + 1}: ${candidates[i].displayName} (ID: ${candidates[i].id})',
          );
        }

        // 如果候选项数量异常，显示更多信息
        if (candidates.length < 100) {
          print('⚠️ 警告：候选项数量异常少，预期应该有384个');
          print('🔍 显示所有候选项:');
          for (int i = 0; i < candidates.length; i++) {
            print(
              '📋 候选项${i + 1}: ${candidates[i].displayName} (ID: ${candidates[i].id}, Type: ${candidates[i].type})',
            );
          }
        } else {
          // 显示最后几个候选项以验证范围
          print('📋 最后几个候选项:');
          for (int i = candidates.length - 3; i < candidates.length; i++) {
            print(
              '📋 候选项${i + 1}: ${candidates[i].displayName} (ID: ${candidates[i].id})',
            );
          }
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
  /// [stepIndex] 目标步骤索引（HuangJiInteractiveStep的枚举索引）
  Future<void> jumpToStep(int stepIndex) async {
    if (!hasSession || !canJump) {
      _handleError('跳转失败', Exception('当前状态不支持跳转'));
      return;
    }

    try {
      if (kDebugMode) {
        print('🔄 HuangJiInteractiveViewModel: 跳转到步骤');
        print('📊 请求的枚举步骤索引: $stepIndex');
        print('📊 当前会话步骤数: ${_currentSession!.steps.length}');
        print('📊 当前会话步骤索引: ${_currentSession!.currentStepIndex}');
        print('📊 当前步骤: ${_currentStep.name}');
      }

      _setState(HuangJiInteractiveProviderState.processingSelection);
      _clearError();

      // 根据请求的步骤索引和当前会话状态决定如何处理
      final targetStep = HuangJiInteractiveStep.values[stepIndex];

      if (kDebugMode) {
        print('📊 目标步骤: ${targetStep.name}');
      }

      // 检查是否可以跳转到目标步骤
      if (!_canJumpToStep(targetStep)) {
        if (kDebugMode) {
          print('⚠️ 无法跳转到步骤: ${targetStep.name}');
        }
        _setState(HuangJiInteractiveProviderState.sessionActive);
        return;
      }

      // 如果目标步骤是当前步骤，直接返回
      if (targetStep == _currentStep) {
        if (kDebugMode) {
          print('ℹ️ 已在目标步骤: ${targetStep.name}');
        }
        _setState(HuangJiInteractiveProviderState.sessionActive);
        return;
      }

      // 对于皇极取数法，目前只有一个会话步骤（基础数选择）
      // 所有UI步骤都对应这个会话步骤，只是显示不同的状态
      final sessionStepIndex = 0; // 始终跳转到第一个（也是唯一的）会话步骤

      // 验证会话步骤索引是否有效
      if (sessionStepIndex >= _currentSession!.steps.length) {
        if (kDebugMode) {
          print(
            '❌ 无效的会话步骤索引: $sessionStepIndex，有效范围: 0-${_currentSession!.steps.length - 1}',
          );
        }
        _handleError('跳转失败', Exception('会话步骤不存在'));
        return;
      }

      if (kDebugMode) {
        print('📊 会话步骤索引: $sessionStepIndex');
      }

      final updatedSession = await _useCase.jumpTo(
        _currentSession!,
        sessionStepIndex,
      );

      _currentSession = updatedSession;

      // 手动设置当前步骤为目标步骤
      _currentStep = targetStep;

      _updateSessionData(updatedSession);
      _setState(HuangJiInteractiveProviderState.sessionActive);

      // 重新加载候选项
      if (needsUserSelection) {
        await loadCandidates();
      }

      if (kDebugMode) {
        print('✅ 跳转成功到步骤: ${targetStep.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 跳转失败: $e');
      }
      _handleError('跳转失败', e);
    }
  }

  /// 检查是否可以跳转到指定步骤
  ///
  /// [targetStep] 目标步骤
  bool _canJumpToStep(HuangJiInteractiveStep targetStep) {
    // 如果没有会话，不能跳转
    if (!hasSession) return false;

    // 根据当前会话状态和步骤进度判断
    switch (targetStep) {
      case HuangJiInteractiveStep.initialization:
        // 总是可以回到初始化步骤
        return true;

      case HuangJiInteractiveStep.secondaryCalculation:
        // 如果已经有会话，可以跳转到次条文数计算
        return hasSession;

      case HuangJiInteractiveStep.userSelection:
        // 如果有候选项或已经选择了基础数，可以跳转到用户选择
        return hasSession &&
            (_currentCandidates.isNotEmpty || _selectedBaseNumber != null);

      case HuangJiInteractiveStep.finalCalculation:
        // 如果已经选择了基础数，可以跳转到最终计算
        return _selectedBaseNumber != null;

      case HuangJiInteractiveStep.completed:
        // 如果有最终结果，可以跳转到完成步骤
        return _finalNumbers.isNotEmpty;
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
    _initialNumber =
        resultData['initialNumber'] as int? ??
        configData['initialNumber'] as int?;
    _secondaryNumber =
        resultData['secondaryNumber'] as int? ??
        configData['secondaryNumber'] as int?;
    _selectedBaseNumber =
        resultData['selectedBaseNumber'] as int? ??
        configData['selectedBaseNumber'] as int?;

    // 如果还没有selectedBaseNumber，尝试从当前步骤的stepData中读取
    if (_selectedBaseNumber == null && session.currentStep?.stepData != null) {
      _selectedBaseNumber = session.currentStep!.stepData!['selectedBaseNumber'] as int?;
      if (kDebugMode && _selectedBaseNumber != null) {
        print('📊 从当前步骤stepData中读取selectedBaseNumber: $_selectedBaseNumber');
      }
    }

    final finalNumbersData =
        resultData['finalNumbers'] ?? configData['finalNumbers'];
    if (finalNumbersData is List) {
      _finalNumbers = finalNumbersData.cast<int>();
    }

    // currentStep优先从resultData读取，如果没有则从configData读取
    final currentStepId =
        resultData['currentStep'] as String? ??
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
      // 根据会话状态推断当前步骤
      if (session.steps.isNotEmpty) {
        final currentStep = session.currentStep;
        if (currentStep != null) {
          if (kDebugMode) {
            print('🔍 步骤映射分析:');
            print('   - 步骤名称: ${currentStep.stepName}');
            print('   - 步骤状态: ${currentStep.status}');
            print('   - 候选项数量: ${currentStep.candidates.length}');
          }
          
          // 根据步骤名称推断HuangJiInteractiveStep
          if (currentStep.stepName == 'base_number_selection') {
            _currentStep = HuangJiInteractiveStep.userSelection;
            if (kDebugMode) {
              print('✅ 步骤映射: base_number_selection -> userSelection');
            }
          } else if (currentStep.stepName == 'user_selection') {
            _currentStep = HuangJiInteractiveStep.userSelection;
            if (kDebugMode) {
              print('✅ 步骤映射: user_selection -> userSelection');
            }
          } else if (currentStep.stepName == 'final_confirmation') {
            _currentStep = HuangJiInteractiveStep.finalCalculation;
            if (kDebugMode) {
              print('✅ 步骤映射: final_confirmation -> finalCalculation');
            }
          } else {
            _currentStep = HuangJiInteractiveStep.initialization;
            if (kDebugMode) {
              print('⚠️ 未知步骤名称，映射到: initialization');
            }
          }
        } else {
          _currentStep = HuangJiInteractiveStep.initialization;
          if (kDebugMode) {
            print('⚠️ 当前步骤为null，设置为: initialization');
          }
        }
      } else {
        _currentStep = HuangJiInteractiveStep.initialization;
        if (kDebugMode) {
          print('⚠️ 没有步骤，设置为: initialization');
        }
      }

      if (kDebugMode) {
        print('📊 步骤推断结果: $_currentStep');
        print('📊 会话步骤数: ${session.steps.length}');
        print('📊 当前步骤索引: ${session.currentStepIndex}');
        if (session.currentStep != null) {
          print('📊 当前步骤名称: ${session.currentStep!.stepName}');
        }
      }
    }

    // 更新候选项数据
    if (session.currentStep != null) {
      _currentCandidates = List.from(session.currentStep!.candidates);
      
      if (kDebugMode) {
        print('📊 候选项数据更新完成');
        print('📊 候选项数量: ${_currentCandidates.length}');
        if (_currentCandidates.isNotEmpty) {
          print('📊 第一个候选项: ${_currentCandidates.first.displayName}');
        }
      }
    } else {
      _currentCandidates.clear();
      
      if (kDebugMode) {
        print('⚠️ 没有当前步骤，清空候选项');
      }
    }

    // 如果步骤变为final_calculation且有选择的基础数，自动触发最终计算
    if (_currentStep == HuangJiInteractiveStep.finalCalculation && 
        _selectedBaseNumber != null && 
        _state != HuangJiInteractiveProviderState.calculating &&
        _state != HuangJiInteractiveProviderState.completed) {
      if (kDebugMode) {
        print('🚀 HuangJiInteractiveViewModel: 检测到final_calculation步骤，自动触发最终计算');
        print('📊 选择的基础数: $_selectedBaseNumber');
      }
      
      // 异步触发计算，避免在setState期间调用
      Future.microtask(() => _completeCalculation());
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
