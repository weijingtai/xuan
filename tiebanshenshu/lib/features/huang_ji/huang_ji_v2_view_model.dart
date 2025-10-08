import 'package:flutter/foundation.dart';
import 'package:common/models/eight_chars.dart';
import 'huang_ji_formula_v2.dart';
import '../../domain/models/base_number_selection_batch.dart';
import './huang_ji_v2_session_models.dart';
import './huang_ji_v2_use_case.dart';

/// ViewModel for HuangJi V2 Session Management
///
/// Manages the complete workflow:
/// 1. Initialize session with EightChars
/// 2. Prepare base number selection (with deduplication)
/// 3. Submit user selections
/// 4. Calculate final TiaoWen list
/// 5. Support rollback
class HuangJiV2ViewModel extends ChangeNotifier {
  final HuangJiV2UseCase _useCase;

  HuangJiSession? _currentSession;
  BaseNumberSelectionBatch? _selectionBatch;
  bool _isLoading = false;
  String? _errorMessage;

  HuangJiV2ViewModel({required HuangJiV2UseCase useCase}) : _useCase = useCase;

  // Getters
  HuangJiSession? get currentSession => _currentSession;
  BaseNumberSelectionBatch? get selectionBatch => _selectionBatch;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SessionPhase? get currentPhase => _currentSession?.currentPhase;
  bool get canProceedToSelection =>
      _currentSession?.currentPhase == SessionPhase.yuanHuiYunShiCalculated;
  bool get canSubmitSelections =>
      _currentSession?.currentPhase == SessionPhase.baseNumberSelectionReady;
  bool get canCalculateFinal =>
      _currentSession?.currentPhase == SessionPhase.baseNumberSelected;
  bool get isCompleted =>
      _currentSession?.currentPhase == SessionPhase.finalCalculationComplete;

  /// 1. Initialize session with EightChars and formula
  Future<void> initializeSession({
    required EightChars eightChars,
    required List<HuangJiCalculationFormula> formulas,
    String? sessionName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final session = await _useCase.initializeSession(
        eightChars: eightChars,
        formulas: formulas,
        sessionName: sessionName,
      );

      _currentSession = session;
      notifyListeners();
    } catch (e) {
      _setError('初始化会话失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 2. Prepare base number selection (deduplication logic)
  Future<void> prepareBaseNumberSelection() async {
    if (_currentSession == null) {
      _setError('会话未初始化');
      return;
    }

    print('🔍 prepareBaseNumberSelection 开始');
    print('🔍 当前阶段: ${_currentSession!.currentPhase}');

    _setLoading(true);
    _clearError();

    try {
      final session = await _useCase.prepareBaseNumberSelection(
        _currentSession!,
      );
      _currentSession = session;

      // Get selection batch for UI
      _selectionBatch = _useCase.getSelectionBatch(session);

      print('✅ 准备完成');
      print('📊 选择批次: ${_selectionBatch != null ? "已生成" : "null"}');
      print('📊 批次项数: ${_selectionBatch?.items.length ?? 0}');

      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ 准备基础数选择失败: $e');
      print('📊 堆栈: $stackTrace');
      _setError('准备基础数选择失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 3. Submit user selections
  Future<void> submitSelections(Map<String, int> selections) async {
    if (_currentSession == null) {
      _setError('会话未初始化');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final session = await _useCase.submitBaseNumberSelections(
        session: _currentSession!,
        selections: selections,
      );

      _currentSession = session;
      notifyListeners();
    } catch (e) {
      _setError('提交选择失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 4. Calculate final TiaoWen list
  Future<void> calculateFinalTiaoWenList() async {
    if (_currentSession == null) {
      _setError('会话未初始化');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final session = await _useCase.calculateFinalTiaoWenList(
        _currentSession!,
      );
      _currentSession = session;
      notifyListeners();
    } catch (e) {
      _setError('计算最终条文失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 5. Rollback to a specific phase
  Future<void> rollbackToPhase(SessionPhase targetPhase) async {
    if (_currentSession == null) {
      _setError('会话未初始化');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final session = await _useCase.rollbackToPhase(
        session: _currentSession!,
        targetPhase: targetPhase,
      );

      _currentSession = session;

      // Update selection batch if rolling back to selection phase
      if (targetPhase == SessionPhase.baseNumberSelectionReady) {
        _selectionBatch = _useCase.getSelectionBatch(session);
      }

      notifyListeners();
    } catch (e) {
      _setError('回滚失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Reset the session
  void resetSession() {
    _currentSession = null;
    _selectionBatch = null;
    _clearError();
    notifyListeners();
  }

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
