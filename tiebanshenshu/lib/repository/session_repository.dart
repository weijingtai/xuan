import '../features/huang_ji/huang_ji_v2_session_models.dart';

/// Session 仓库接口
abstract class SessionRepository {
  /// 保存 Session
  Future<void> saveSession(HuangJiSession session);

  /// 加载 Session
  Future<HuangJiSession?> loadSession(String sessionId);

  /// 获取所有 Session
  Future<List<HuangJiSession>> getAllSessions();

  /// 删除 Session
  Future<void> deleteSession(String sessionId);

  /// 保存快照
  Future<void> saveSnapshot(String sessionId, SessionSnapshot snapshot);

  /// 加载最新快照
  Future<SessionSnapshot?> loadLatestSnapshot(String sessionId);

  /// 加载所有快照
  Future<List<SessionSnapshot>> loadAllSnapshots(String sessionId);
}
