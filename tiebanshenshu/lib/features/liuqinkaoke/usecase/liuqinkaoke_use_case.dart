import 'package:common/enums.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/models/liuqinkaoke_models.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/usecase/liuqinkaoke_session_manager.dart';

/// UseCase 层，作为 ViewModel 和 SessionManager 之间的协调器
class LiuQinKaoKeUseCase {
  final LiuQinKaoKeSessionManager _sessionManager;

  LiuQinKaoKeUseCase(this._sessionManager);

  Future<LiuQinKaoKeSession> startSessionAndCalculateCandidates(
      {required Gender gender}) {
    return _sessionManager.start(gender: gender);
  }

  Future<LiuQinKaoKeSession> selectBaseNumbersAndGetFinalList({
    required String sessionId,
    required LiuQinKaoKeSelectionItem selectedInnate,
    required LiuQinKaoKeSelectionItem selectedAcquired,
  }) {
    return _sessionManager.completeSelection(
      sessionId: sessionId,
      innateItem: selectedInnate,
      acquiredItem: selectedAcquired,
    );
  }

  Future<LiuQinKaoKeSession> rollback({required String sessionId}) {
    return _sessionManager.rollback(sessionId: sessionId);
  }

  Future<LiuQinKaoKeSession?> resumeMostRecentSession() {
    return _sessionManager.resumeMostRecentSession();
  }
}
