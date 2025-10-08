import 'package:common/models/eight_chars.dart';
import 'huang_ji_formula_v2.dart';
import './huang_ji_v2_session_models.dart';
import '../../repository/session_repository.dart';
import './huang_ji_v2_calculation_strategy.dart';

/// 异常类
class InvalidPhaseTransitionException implements Exception {
  final SessionPhase currentPhase;
  final SessionPhase targetPhase;

  const InvalidPhaseTransitionException(this.currentPhase, this.targetPhase);

  @override
  String toString() =>
      'Invalid phase transition: $currentPhase -> $targetPhase';
}

/// SessionManager - 负责 Session 生命周期和状态管理
class HuangJiSessionManager {
  final SessionRepository _sessionRepository;
  final HuangJiV2CalculationStrategy _calculationStrategy;

  HuangJiSessionManager({
    required SessionRepository sessionRepository,
    required HuangJiV2CalculationStrategy calculationStrategy,
  }) : _sessionRepository = sessionRepository,
       _calculationStrategy = calculationStrategy;

  /// 创建新 Session
  Future<HuangJiSession> createSession({
    required EightChars eightChars,
    required List<HuangJiCalculationFormula> formulas,
    String? sessionName,
  }) async {
    final sessionId = _generateSessionId();
    final name =
        sessionName ?? 'Session_${DateTime.now().millisecondsSinceEpoch}';

    final session = HuangJiSession.create(
      sessionId: sessionId,
      sessionName: name,
      eightChars: eightChars,
      formulas: formulas,
    );

    await _sessionRepository.saveSession(session);
    return session;
  }

  /// 恢复 Session
  Future<HuangJiSession?> restoreSession(String sessionId) async {
    return await _sessionRepository.loadSession(sessionId);
  }

  /// 保存 Session
  Future<void> saveSession(HuangJiSession session) async {
    await _sessionRepository.saveSession(session);
  }

  /// 推进到下一阶段
  Future<HuangJiSession> advanceToPhase({
    required HuangJiSession session,
    required SessionPhase targetPhase,
  }) async {
    // 验证阶段转换
    _validatePhaseTransition(session.currentPhase, targetPhase);

    // 创建快照
    final snapshot = createSnapshot(session);

    // 更新 session
    final updatedSession = session.copyWith(
      currentPhase: targetPhase,
      phaseHistory: [...session.phaseHistory, snapshot],
      lastActivityAt: DateTime.now(),
      status: HuangJiSessionStatus.inProgress,
    );

    await _sessionRepository.saveSession(updatedSession);
    return updatedSession;
  }

  /// 创建当前阶段快照
  SessionSnapshot createSnapshot(HuangJiSession session) {
    return SessionSnapshot(
      snapshotId: 'snapshot_${DateTime.now().millisecondsSinceEpoch}',
      phase: session.currentPhase,
      timestamp: DateTime.now(),
      state: session.toJson(),
    );
  }

  /// 回滚到指定快照
  Future<HuangJiSession> rollbackToSnapshot({
    required HuangJiSession session,
    required String snapshotId,
  }) async {
    // 查找快照
    final snapshotIndex = session.phaseHistory.indexWhere(
      (s) => s.snapshotId == snapshotId,
    );

    if (snapshotIndex == -1) {
      throw Exception('Snapshot not found: $snapshotId');
    }

    final snapshot = session.phaseHistory[snapshotIndex];

    // 从快照恢复
    final restoredSession = HuangJiSession.fromJson(snapshot.state);

    // 截断历史到该快照
    final truncatedHistory = session.phaseHistory.sublist(0, snapshotIndex + 1);

    final finalSession = restoredSession.copyWith(
      phaseHistory: truncatedHistory,
      lastActivityAt: DateTime.now(),
    );

    await _sessionRepository.saveSession(finalSession);
    return finalSession;
  }

  /// 回滚到上一阶段
  Future<HuangJiSession> rollbackToPreviousPhase(HuangJiSession session) async {
    if (!session.canRollback) {
      throw Exception('No previous phase to rollback to');
    }

    final lastSnapshot = session.phaseHistory.last;
    return await rollbackToSnapshot(
      session: session,
      snapshotId: lastSnapshot.snapshotId,
    );
  }

  /// 验证阶段转换合法性
  void _validatePhaseTransition(SessionPhase current, SessionPhase target) {
    final validTransitions = <SessionPhase, List<SessionPhase>>{
      SessionPhase.initialized: [SessionPhase.yuanHuiYunShiCalculated],
      SessionPhase.yuanHuiYunShiCalculated: [
        SessionPhase.baseNumberSelectionReady,
      ],
      SessionPhase.baseNumberSelectionReady: [SessionPhase.baseNumberSelected],
      SessionPhase.baseNumberSelected: [SessionPhase.finalCalculationComplete],
    };

    final allowed = validTransitions[current];
    if (allowed == null || !allowed.contains(target)) {
      throw InvalidPhaseTransitionException(current, target);
    }
  }

  /// 生成 Session ID
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }
}
