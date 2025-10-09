import 'package:common/enums.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/models/liuqinkaoke_models.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/repository/liuqinkaoke_session_repository.dart';
import 'package:tiebanshenshu/features/liuqinkaoke/strategy/liuqinkaoke_calculation_strategy.dart';
import 'package:tiebanshenshu/repository/tiao_wen_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:common/dev_constant.dart';
import 'package:tiebanshenshu/constant/constants.dart';

import 'package:tiebanshenshu/service/strategy/tiao_wen_list_calculation.dart';

/// 负责处理 LiuQinKaoKeSession 的所有状态转换和业务逻辑
class LiuQinKaoKeSessionManager {
  final LiuQinKaoKeSessionRepository _sessionRepository;
  final LiuQinKaoKeCalculationStrategy _calculationStrategy;
  final TiaoWenRepository _tiaoWenRepository;
  final TiaoWenListCalculationConfig _config;

  LiuQinKaoKeSessionManager(
    this._sessionRepository,
    this._calculationStrategy,
    this._tiaoWenRepository,
    this._config,
  );

  /// 开始一个新会话
  Future<LiuQinKaoKeSession> start({required Gender gender}) async {
    final devData = DevConstant.dev_usa;
    final eightChars = devData.standeredChineseInfo.eightChars;
    final isYangNianGan = tianGanYinYangMapper[eightChars.year.gan.value] ?? false;
    final era = devData.standeredChineseInfo.threeYuan;

    final candidates = _calculationStrategy.calculateCandidates(
      eightChars: eightChars,
      gender: gender,
      isYangNianGan: isYangNianGan,
      era: era,
    );

    final numbersToQuery = candidates.map((c) => c.number).toList();
    final contents = await _tiaoWenRepository.getTiaoWenContentByNumbers(numbersToQuery);

    final selectionItems = candidates.map((c) {
      return LiuQinKaoKeSelectionItem(
        candidate: c,
        tiaoWenContent: contents[c.number],
      );
    }).toList();

    final now = DateTime.now();
    final session = LiuQinKaoKeSession(
      id: Uuid().v4(),
      stage: LiuQinKaoKeStage.baseNumberSelectionReady,
      eightChars: eightChars,
      gender: gender,
      isYangGan: isYangNianGan,
      candidateSet: selectionItems,
      createdAt: now,
      updatedAt: now,
    );

    await _sessionRepository.save(session);
    return session;
  }

  /// 完成基础数字选择并计算最终列表
  Future<LiuQinKaoKeSession> completeSelection({
    required String sessionId,
    required LiuQinKaoKeSelectionItem innateItem,
    required LiuQinKaoKeSelectionItem acquiredItem,
  }) async {
    final currentSession = await _sessionRepository.findById(sessionId);
    if (currentSession == null || currentSession.stage != LiuQinKaoKeStage.baseNumberSelectionReady) {
      throw Exception('Invalid session or stage for this operation.');
    }

    // 3. 计算派生条文
    final List<int> numbersToQuery = [];
    final List<Map<String, dynamic>> derivationInfo = [];

    for (final selected in [innateItem, acquiredItem]) {
      final baseNum = selected.candidate.number;
      // 添加本身
      numbersToQuery.add(baseNum);
      derivationInfo.add({
        'number': baseNum,
        'origin': selected.candidate.originKind,
        'offset': 0
      });

      // 使用配置计算派生条文
      for (final offsetValue in _config.calculationList) {
        final derivedNum = baseNum + offsetValue;
        numbersToQuery.add(derivedNum);
        derivationInfo.add({
          'number': derivedNum,
          'origin': selected.candidate.originKind,
          'offset': offsetValue
        });
      }
    }

    final contents = await _tiaoWenRepository.getTiaoWenContentByNumbers(numbersToQuery.where((n) => n > 0).toList());

    final finalItems = derivationInfo.map((info) {
      final num = info['number'] as int;
      if (contents.containsKey(num)) {
        return FinalTiaoWenItem(number: num, content: contents[num]!, originKind: info['origin'] as OriginKind, offset: info['offset'] as int);
      }
      return null;
    }).whereType<FinalTiaoWenItem>().toList();

    final finalSession = LiuQinKaoKeSession(
      id: currentSession.id,
      version: currentSession.version + 1,
      stage: LiuQinKaoKeStage.finalTiaoWenListReady,
      eightChars: currentSession.eightChars,
      gender: currentSession.gender,
      isYangGan: currentSession.isYangGan,
      candidateSet: currentSession.candidateSet,
      selectedInnate: innateItem.candidate,
      selectedAcquired: acquiredItem.candidate,
      finalTiaoWenList: finalItems,
      createdAt: currentSession.createdAt,
      updatedAt: DateTime.now(),
    );

    await _sessionRepository.save(finalSession);
    return finalSession;
  }

  /// 回滚到上一个阶段
  Future<LiuQinKaoKeSession> rollback({required String sessionId}) async {
    final currentSession = await _sessionRepository.findById(sessionId);
    if (currentSession == null) throw Exception('Session not found.');

    LiuQinKaoKeStage targetStage;
    switch (currentSession.stage) {
      case LiuQinKaoKeStage.finalTiaoWenListReady:
        targetStage = LiuQinKaoKeStage.baseNumberSelectionReady;
        break;
      case LiuQinKaoKeStage.baseNumberSelectionCompleted:
        targetStage = LiuQinKaoKeStage.baseNumberSelectionReady;
        break;
      default:
        return currentSession; // 无法回滚
    }

    final rolledBackSession = LiuQinKaoKeSession(
      id: currentSession.id,
      version: currentSession.version + 1,
      stage: targetStage,
      eightChars: currentSession.eightChars,
      gender: currentSession.gender,
      isYangGan: currentSession.isYangGan,
      candidateSet: currentSession.candidateSet, // 保留候选项
      selectedInnate: null, // 清空选择
      selectedAcquired: null,
      finalTiaoWenList: null, // 清空最终列表
      createdAt: currentSession.createdAt,
      updatedAt: DateTime.now(),
    );

    await _sessionRepository.save(rolledBackSession);
    return rolledBackSession;
  }

  /// 尝试恢复最近一次的会话
  Future<LiuQinKaoKeSession?> resumeMostRecentSession() async {
    final sessionId = await _sessionRepository.getMostRecentSessionId();
    if (sessionId != null) {
      return await _sessionRepository.findById(sessionId);
    }
    return null;
  }
}
