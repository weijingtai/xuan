import 'package:flutter/foundation.dart';
import 'package:common/enums.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/models/liuqinkaoke_models.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/usecase/liuqinkaoke_use_case.dart';

class LiuQinKaoKeViewModel extends ChangeNotifier {
  final LiuQinKaoKeUseCase _useCase;

  LiuQinKaoKeViewModel(this._useCase);

  LiuQinKaoKeSession? _session;
  LiuQinKaoKeSession? get session => _session;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// 初始化 ViewModel，尝试恢复会话或创建新会话
  Future<void> initialize({required Gender gender}) async {
    _setLoading(true);
    try {
      // 1. 尝试恢复会话
      final resumedSession = await _useCase.resumeMostRecentSession();
      if (resumedSession != null) {
        _session = resumedSession;
      } else {
        // 2. 如果没有可恢复的会話，则创建新会话
        _session = await _useCase.startSessionAndCalculateCandidates(gender: gender);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      _session = null;
    } finally {
      _setLoading(false);
    }
  }

  /// 开始一个新的流程
  Future<void> startNewSession({required Gender gender}) async {
    _setLoading(true);
    try {
      _session = await _useCase.startSessionAndCalculateCandidates(gender: gender);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _session = null;
    } finally {
      _setLoading(false);
    }
  }

  /// 用户选择先天和后天候选项
  Future<void> selectNumbers({
    required LiuQinKaoKeSelectionItem innateItem,
    required LiuQinKaoKeSelectionItem acquiredItem,
  }) async {
    if (_session == null) {
      _error = "Session is not initialized.";
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      _session = await _useCase.selectBaseNumbersAndGetFinalList(
        sessionId: _session!.id,
        selectedInnate: innateItem,
        selectedAcquired: acquiredItem,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// 回滚到上一个阶段
  Future<void> rollback() async {
    if (_session == null) {
      _error = "Session is not initialized.";
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      _session = await _useCase.rollback(sessionId: _session!.id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}