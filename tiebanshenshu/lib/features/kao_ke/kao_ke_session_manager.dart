import 'package:common/models/eight_chars.dart';
import 'kao_ke_session_models.dart';

/// 异常类 - 无效的阶段转换
class InvalidPhaseTransitionException implements Exception {
  final KaoKeSessionPhase currentPhase;
  final KaoKeSessionPhase targetPhase;

  const InvalidPhaseTransitionException(this.currentPhase, this.targetPhase);

  @override
  String toString() =>
      'Invalid phase transition: $currentPhase -> $targetPhase';
}

/// 考刻会话管理器
///
/// 负责会话的生命周期管理和状态转换
/// 使用内存存储会话数据
class KaoKeSessionManager {
  // 内存存储
  final Map<String, KaoKeSession> _sessions = {};

  KaoKeSessionManager();

  /// 创建新会话
  Future<KaoKeSession> createSession({
    required EightChars eightChars,
    String? sessionName,
  }) async {
    final sessionId = _generateSessionId();
    final name =
        sessionName ?? 'KaoKe_Session_${DateTime.now().millisecondsSinceEpoch}';

    final session = KaoKeSession.create(
      sessionId: sessionId,
      sessionName: name,
      eightChars: eightChars,
    );

    _sessions[session.sessionId] = session;
    return session;
  }

  /// 恢复会话
  Future<KaoKeSession?> restoreSession(String sessionId) async {
    return _sessions[sessionId];
  }

  /// 保存会话
  Future<void> saveSession(KaoKeSession session) async {
    _sessions[session.sessionId] = session;
  }

  /// 推进到下一阶段
  Future<KaoKeSession> advanceToPhase({
    required KaoKeSession session,
    required KaoKeSessionPhase targetPhase,
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
      status: KaoKeSessionStatus.inProgress,
    );

    _sessions[updatedSession.sessionId] = updatedSession;
    return updatedSession;
  }

  /// 创建当前阶段快照
  KaoKeSessionSnapshot createSnapshot(KaoKeSession session) {
    return KaoKeSessionSnapshot(
      snapshotId: 'snapshot_${DateTime.now().millisecondsSinceEpoch}',
      phase: session.currentPhase,
      timestamp: DateTime.now(),
      state: session.toJson(),
    );
  }

  /// 回滚到指定快照
  Future<KaoKeSession> rollbackToSnapshot({
    required KaoKeSession session,
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
    final restoredSession = KaoKeSession.fromJson(snapshot.state);

    // 截断历史到该快照
    final truncatedHistory = session.phaseHistory.sublist(0, snapshotIndex + 1);

    final finalSession = restoredSession.copyWith(
      phaseHistory: truncatedHistory,
      lastActivityAt: DateTime.now(),
    );

    _sessions[finalSession.sessionId] = finalSession;
    return finalSession;
  }

  /// 回滚到上一阶段
  Future<KaoKeSession> rollbackToPreviousPhase(KaoKeSession session) async {
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
  void _validatePhaseTransition(
    KaoKeSessionPhase current,
    KaoKeSessionPhase target,
  ) {
    final validTransitions = <KaoKeSessionPhase, List<KaoKeSessionPhase>>{
      KaoKeSessionPhase.initialized: [KaoKeSessionPhase.keSelectionReady],
      KaoKeSessionPhase.keSelectionReady: [KaoKeSessionPhase.keSelected],
      KaoKeSessionPhase.keSelected: [KaoKeSessionPhase.baseNumberCalculated],
      KaoKeSessionPhase.baseNumberCalculated: [
        KaoKeSessionPhase.finalCalculationComplete,
      ],
    };

    final allowed = validTransitions[current];
    if (allowed == null || !allowed.contains(target)) {
      throw InvalidPhaseTransitionException(current, target);
    }
  }

  /// 生成会话ID
  String _generateSessionId() {
    return 'kao_ke_session_${DateTime.now().millisecondsSinceEpoch}';
  }
}
