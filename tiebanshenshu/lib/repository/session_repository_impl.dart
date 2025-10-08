import '../features/huang_ji/huang_ji_v2_session_models.dart';
import 'session_repository.dart';

/// Session 仓库内存实现
class InMemorySessionRepository implements SessionRepository {
  final Map<String, HuangJiSession> _sessions = {};
  final Map<String, List<SessionSnapshot>> _snapshots = {};

  @override
  Future<void> saveSession(HuangJiSession session) async {
    _sessions[session.sessionId] = session;
    // 同时保存快照历史
    if (session.phaseHistory.isNotEmpty) {
      _snapshots[session.sessionId] = List.from(session.phaseHistory);
    }
  }

  @override
  Future<HuangJiSession?> loadSession(String sessionId) async {
    return _sessions[sessionId];
  }

  @override
  Future<List<HuangJiSession>> getAllSessions() async {
    return _sessions.values.toList();
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _sessions.remove(sessionId);
    _snapshots.remove(sessionId);
  }

  @override
  Future<void> saveSnapshot(String sessionId, SessionSnapshot snapshot) async {
    final snapshots = _snapshots[sessionId] ?? [];
    snapshots.add(snapshot);
    _snapshots[sessionId] = snapshots;

    // 同时更新 session 的 phaseHistory
    final session = _sessions[sessionId];
    if (session != null) {
      _sessions[sessionId] = session.copyWith(
        phaseHistory: List.from(snapshots),
      );
    }
  }

  @override
  Future<SessionSnapshot?> loadLatestSnapshot(String sessionId) async {
    final snapshots = _snapshots[sessionId];
    if (snapshots == null || snapshots.isEmpty) {
      return null;
    }
    return snapshots.last;
  }

  @override
  Future<List<SessionSnapshot>> loadAllSnapshots(String sessionId) async {
    return _snapshots[sessionId] ?? [];
  }

  /// 清除所有数据 (用于测试)
  void clearAll() {
    _sessions.clear();
    _snapshots.clear();
  }
}
