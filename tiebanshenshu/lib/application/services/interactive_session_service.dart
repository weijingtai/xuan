/// 交互式会话服务
///
/// 负责管理交互式会话的生命周期，包括会话创建、存储、状态管理等
library;

import 'dart:math';
import '../../domain/models/interactive_session.dart';
import '../../domain/models/tiao_wen_candidate.dart';

/// 交互式会话服务接口
abstract class InteractiveSessionService {
  /// 创建新会话
  Future<InteractiveSession> createSession({
    required String strategyName,
    Map<String, dynamic>? sessionConfig,
  });

  /// 获取会话
  Future<InteractiveSession?> getSession(String sessionId);

  /// 保存会话
  Future<void> saveSession(InteractiveSession session);

  /// 删除会话
  Future<void> deleteSession(String sessionId);

  /// 获取所有活跃会话
  Future<List<InteractiveSession>> getActiveSessions();

  /// 清理过期会话
  Future<void> cleanupExpiredSessions();

  /// 添加步骤到会话
  Future<InteractiveSession> addStepToSession(
    String sessionId,
    InteractiveSessionStep step,
  );

  /// 更新会话步骤
  Future<InteractiveSession> updateSessionStep(
    String sessionId,
    int stepIndex,
    InteractiveSessionStep updatedStep,
  );

  /// 完成会话
  Future<InteractiveSession> completeSession(
    String sessionId, {
    Map<String, dynamic>? resultData,
  });

  /// 取消会话
  ///
  /// [sessionId] 会话ID
  /// 返回取消后的会话
  ///
  /// 抛出异常：
  /// - [SessionNotFoundException] 会话不存在
  Future<InteractiveSession> cancelSession(String sessionId);

  /// 生成会话ID
  String generateSessionId();
}

/// 交互式会话服务实现
class InteractiveSessionServiceImpl implements InteractiveSessionService {
  /// 内存中的会话存储
  final Map<String, InteractiveSession> _sessions = {};

  /// 会话过期时间（小时）
  final int _sessionExpirationHours;

  /// 构造函数
  InteractiveSessionServiceImpl({int sessionExpirationHours = 24})
    : _sessionExpirationHours = sessionExpirationHours;

  @override
  Future<InteractiveSession> createSession({
    required String strategyName,
    Map<String, dynamic>? sessionConfig,
  }) async {
    final sessionId = generateSessionId();
    final session = InteractiveSession.create(
      sessionId: sessionId,
      strategyName: strategyName,
      sessionConfig: sessionConfig,
    );

    await saveSession(session);
    return session;
  }

  @override
  Future<InteractiveSession?> getSession(String sessionId) async {
    return _sessions[sessionId];
  }

  @override
  Future<void> saveSession(InteractiveSession session) async {
    _sessions[session.sessionId] = session;
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _sessions.remove(sessionId);
  }

  @override
  Future<List<InteractiveSession>> getActiveSessions() async {
    final now = DateTime.now();
    final activeSessions = _sessions.values.where((session) {
      // 检查会话是否未过期
      final sessionAge = now.difference(session.startTime);
      return sessionAge.inHours < _sessionExpirationHours &&
          session.status != InteractiveSessionStatus.completed &&
          session.status != InteractiveSessionStatus.cancelled;
    }).toList();

    return activeSessions;
  }

  @override
  Future<void> cleanupExpiredSessions() async {
    final now = DateTime.now();
    final expiredSessionIds = <String>[];

    for (final entry in _sessions.entries) {
      final session = entry.value;
      final sessionAge = now.difference(session.startTime);

      // 标记过期或已完成的会话
      if (sessionAge.inHours >= _sessionExpirationHours ||
          session.status == InteractiveSessionStatus.completed ||
          session.status == InteractiveSessionStatus.cancelled) {
        expiredSessionIds.add(entry.key);
      }
    }

    // 删除过期会话
    for (final sessionId in expiredSessionIds) {
      _sessions.remove(sessionId);
    }
  }

  @override
  Future<InteractiveSession> addStepToSession(
    String sessionId,
    InteractiveSessionStep step,
  ) async {
    final session = await getSession(sessionId);
    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }

    final updatedSession = session.addStep(step);
    await saveSession(updatedSession);
    return updatedSession;
  }

  @override
  Future<InteractiveSession> updateSessionStep(
    String sessionId,
    int stepIndex,
    InteractiveSessionStep updatedStep,
  ) async {
    final session = await getSession(sessionId);
    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }

    if (stepIndex < 0 || stepIndex >= session.steps.length) {
      throw Exception('Invalid step index: $stepIndex');
    }

    final newSteps = List<InteractiveSessionStep>.from(session.steps);
    newSteps[stepIndex] = updatedStep;

    final updatedSession = session.copyWith(steps: newSteps);
    await saveSession(updatedSession);
    return updatedSession;
  }

  @override
  Future<InteractiveSession> completeSession(
    String sessionId, {
    Map<String, dynamic>? resultData,
  }) async {
    final session = await getSession(sessionId);
    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }

    final completedSession = session.complete(resultData: resultData);
    await saveSession(completedSession);
    return completedSession;
  }

  @override
  Future<InteractiveSession> cancelSession(String sessionId) async {
    final session = await getSession(sessionId);
    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }

    final cancelledSession = session.cancel();
    await saveSession(cancelledSession);
    return cancelledSession;
  }

  @override
  String generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'session_${timestamp}_$random';
  }

  /// 获取会话统计信息
  Future<Map<String, dynamic>> getSessionStats() async {
    final activeSessions = await getActiveSessions();
    final totalSessions = _sessions.length;

    final statusCounts = <InteractiveSessionStatus, int>{};
    for (final session in _sessions.values) {
      statusCounts[session.status] = (statusCounts[session.status] ?? 0) + 1;
    }

    return {
      'totalSessions': totalSessions,
      'activeSessions': activeSessions.length,
      'statusCounts': statusCounts.map((k, v) => MapEntry(k.toString(), v)),
    };
  }

  /// 清理所有会话（用于测试）
  Future<void> clearAllSessions() async {
    _sessions.clear();
  }
}
