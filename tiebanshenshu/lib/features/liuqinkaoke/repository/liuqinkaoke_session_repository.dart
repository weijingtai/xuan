import '../models/liuqinkaoke_models.dart';

/// 六亲考刻 Session 仓库接口
abstract class LiuQinKaoKeSessionRepository {
  Future<void> save(LiuQinKaoKeSession session);
  Future<LiuQinKaoKeSession?> findById(String id);
  Future<void> delete(String id);
  Future<String?> getMostRecentSessionId();
}

/// Session 仓库内存实现
class InMemoryLiuQinKaoKeSessionRepository implements LiuQinKaoKeSessionRepository {
  final Map<String, LiuQinKaoKeSession> _sessions = {};
  String? _lastSessionId;

  @override
  Future<void> save(LiuQinKaoKeSession session) async {
    _sessions[session.id] = session;
    _lastSessionId = session.id;
  }

  @override
  Future<LiuQinKaoKeSession?> findById(String id) async {
    return _sessions[id];
  }

  @override
  Future<void> delete(String id) async {
    _sessions.remove(id);
    if (_lastSessionId == id) {
      _lastSessionId = null;
    }
  }

  @override
  Future<String?> getMostRecentSessionId() async {
    return _lastSessionId;
  }

  void clear() {
    _sessions.clear();
    _lastSessionId = null;
  }
}
