/// 太玄四柱交互式UseCase实现
///
/// 负责处理基于太玄四柱交互式策略的业务逻辑
library;

import 'package:common/models/eight_chars.dart';

import '../application/usecases/base_interactive_use_case.dart';
import '../domain/exceptions/tiao_wen_calculation_exceptions.dart';
import '../domain/models/interactive_session.dart';
import '../domain/models/interactive_strategy_config.dart';
import '../domain/models/tiao_wen_candidate.dart';
import '../domain/models/tiao_wen_list_result.dart';
import '../repository/tiao_wen_repository.dart';
import '../service/strategy/tai_xuan_four_zhu_interactive_strategy.dart';
import '../service/strategy/tiao_wen_list_calculation.dart';

/// 太玄四柱交互式UseCase参数
///
/// 包含交互式计算所需的参数
class TaiXuanFourZhuInteractiveUseCaseParams {
  /// 八字信息
  final EightChars eightChars;

  /// 是否允许用户修改四柱
  final bool allowFourZhuModification;

  /// 是否允许用户选择计算方法
  final bool allowCalculationMethodSelection;

  /// 是否允许用户选择卦象映射
  final bool allowGuaMappingSelection;

  const TaiXuanFourZhuInteractiveUseCaseParams({
    required this.eightChars,
    this.allowFourZhuModification = true,
    this.allowCalculationMethodSelection = true,
    this.allowGuaMappingSelection = false,
  });

  @override
  String toString() {
    return 'TaiXuanFourZhuInteractiveUseCaseParams('
        'eightChars: ${eightChars.toString()}, '
        'allowFourZhuModification: $allowFourZhuModification, '
        'allowCalculationMethodSelection: $allowCalculationMethodSelection, '
        'allowGuaMappingSelection: $allowGuaMappingSelection)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaiXuanFourZhuInteractiveUseCaseParams &&
        other.eightChars == eightChars &&
        other.allowFourZhuModification == allowFourZhuModification &&
        other.allowCalculationMethodSelection ==
            allowCalculationMethodSelection &&
        other.allowGuaMappingSelection == allowGuaMappingSelection;
  }

  @override
  int get hashCode => Object.hash(
    eightChars,
    allowFourZhuModification,
    allowCalculationMethodSelection,
    allowGuaMappingSelection,
  );
}

/// 太玄四柱交互式UseCase实现
///
/// 负责处理基于太玄四柱交互式策略计算条文列表的业务逻辑
/// 完整流程：开始交互式会话 -> 用户选择 -> Strategy计算 -> Repository获取条文实体
class TaiXuanFourZhuInteractiveUseCase
    extends BaseInteractiveUseCase<TaiXuanFourZhuInteractiveUseCaseParams> {
  /// 交互式策略
  final TaiXuanFourZhuInteractiveStrategy _strategy;

  /// 条文仓库
  final TiaoWenRepository _repository;

  /// 默认计算配置
  final TiaoWenListCalculationConfig _defaultCalculationConfig;

  /// 会话存储
  final Map<String, InteractiveSession> _sessions = {};

  /// 构造函数
  TaiXuanFourZhuInteractiveUseCase(
    this._strategy,
    this._repository,
    this._defaultCalculationConfig,
  );

  @override
  String get name => '太玄四柱交互式UseCase';

  @override
  String get description => '基于太玄四柱交互式策略计算条文列表的UseCase，支持用户参与式选择';

  @override
  Future<InteractiveSession> startSession(
    TaiXuanFourZhuInteractiveUseCaseParams params, {
    InteractiveStrategyConfig? config,
  }) async {
    try {
      // 1. 验证参数
      validateParams(params);

      // 2. 创建策略参数
      final strategyParams = TaiXuanFourZhuInteractiveStrategyParams(
        eightChars: params.eightChars,
        interactiveConfig: config,
        allowFourZhuModification: params.allowFourZhuModification,
        allowCalculationMethodSelection: params.allowCalculationMethodSelection,
        allowGuaMappingSelection: params.allowGuaMappingSelection,
      );

      // 3. 启动策略会话
      final session = await _strategy.startSession(
        strategyParams,
        config: config,
      );

      // 4. 存储会话
      _sessions[session.sessionId] = session;

      return session;
    } catch (e) {
      throw UseCaseExecutionException(
        message: '启动交互式会话失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  @override
  Future<List<TiaoWenCandidate>> getCandidates(String sessionId) async {
    try {
      // 1. 验证会话ID
      validateSessionId(sessionId);

      // 2. 获取会话
      final session = await getSession(sessionId);

      // 3. 获取候选项
      final candidates = await _strategy.getCandidates(session);

      return candidates;
    } catch (e) {
      if (e is SessionNotFoundException ||
          e is SessionStateException ||
          e is InputValidationException) {
        rethrow;
      }
      throw UseCaseExecutionException(
        message: '获取候选项失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  @override
  Future<InteractiveSession> selectCandidate(
    String sessionId,
    String candidateId,
  ) async {
    try {
      // 1. 验证参数
      validateSessionId(sessionId);
      validateCandidateId(candidateId);

      // 2. 获取会话
      final session = await getSession(sessionId);

      // 3. 选择候选项
      final updatedSession = await _strategy.selectCandidate(
        session,
        candidateId,
      );

      // 4. 更新会话存储
      _sessions[sessionId] = updatedSession;

      return updatedSession;
    } catch (e) {
      if (e is SessionNotFoundException ||
          e is InvalidCandidateException ||
          e is SessionStateException ||
          e is InputValidationException) {
        rethrow;
      }
      throw UseCaseExecutionException(
        message: '选择候选项失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  @override
  Future<InteractiveSession> adjustStep(
    String sessionId,
    Map<String, dynamic> adjustments,
  ) async {
    try {
      // 1. 验证会话ID
      validateSessionId(sessionId);

      // 2. 获取会话
      final session = await getSession(sessionId);

      // 3. 调整步骤
      final updatedSession = await _strategy.adjustStep(session, adjustments);

      // 4. 更新会话存储
      _sessions[sessionId] = updatedSession;

      return updatedSession;
    } catch (e) {
      if (e is SessionNotFoundException ||
          e is SessionStateException ||
          e is InputValidationException) {
        rethrow;
      }
      throw UseCaseExecutionException(
        message: '调整步骤失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  @override
  Future<InteractiveSession> jumpTo(String sessionId, int stepIndex) async {
    try {
      // 1. 验证参数
      validateSessionId(sessionId);

      // 2. 获取会话
      final session = await getSession(sessionId);

      // 3. 验证步骤索引
      validateStepIndex(stepIndex, session.steps.length - 1);

      // 4. 跳转到指定步骤
      final updatedSession = await _strategy.jumpTo(session, stepIndex);

      // 5. 更新会话存储
      _sessions[sessionId] = updatedSession;

      return updatedSession;
    } catch (e) {
      if (e is SessionNotFoundException ||
          e is InvalidStepIndexException ||
          e is SessionStateException ||
          e is InputValidationException) {
        rethrow;
      }
      throw UseCaseExecutionException(
        message: '跳转步骤失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  @override
  Future<InteractiveSession> undo(String sessionId) async {
    try {
      // 1. 验证会话ID
      validateSessionId(sessionId);

      // 2. 获取会话
      final session = await getSession(sessionId);

      // 3. 撤销到上一步
      final updatedSession = await _strategy.undo(session);

      // 4. 更新会话存储
      _sessions[sessionId] = updatedSession;

      return updatedSession;
    } catch (e) {
      if (e is SessionNotFoundException ||
          e is SessionStateException ||
          e is InputValidationException) {
        rethrow;
      }
      throw UseCaseExecutionException(
        message: '撤销操作失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  @override
  Future<List<dynamic>> getInfiniteList(
    String sessionId,
    int offset,
    int limit,
  ) async {
    try {
      // 1. 验证会话ID
      validateSessionId(sessionId);

      // 2. 获取会话
      final session = await getSession(sessionId);

      // 3. 获取无限列表数据
      final data = await _strategy.getInfiniteList(session, offset, limit);

      return data;
    } catch (e) {
      if (e is SessionNotFoundException ||
          e is SessionStateException ||
          e is InputValidationException) {
        rethrow;
      }
      throw UseCaseExecutionException(
        message: '获取无限列表失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  @override
  Future<TiaoWenListResult> completeCalculation(String sessionId) async {
    try {
      // 1. 验证会话ID
      validateSessionId(sessionId);

      // 2. 获取会话
      final session = await getSession(sessionId);

      // 3. 检查会话是否已完成
      if (!session.isCompleted) {
        throw SessionNotCompletedException('会话尚未完成: $sessionId');
      }

      // 4. 完成策略计算
      final strategyResult = await _strategy.completeCalculation(session);
      final baseTiaoWenList = strategyResult.baseTiaoWenList;

      // 5. 根据配置扩展条文列表
      final allTiaoWenNumbers = <int>[];
      for (final baseNumber in baseTiaoWenList) {
        final calculator = TiaoWenListCalculator(_defaultCalculationConfig);
        final calculationResult = calculator.calculate(baseNumber);
        allTiaoWenNumbers.addAll(calculationResult.tiaoWenNumbers);
      }

      // 6. 调用Repository获取条文实体
      final tiaoWenEntities = await _repository.getByIdList(
        queryList: allTiaoWenNumbers,
      );

      // 7. 转换为UseCase结果
      return TiaoWenListResult.success(
        tiaoWenNumbers: allTiaoWenNumbers,
        tiaoWenEntities: tiaoWenEntities,
        calculationMethod: '太玄四柱交互式',
        sourceData: {
          'sessionId': sessionId,
          'selectedEightChars': strategyResult.selectedEightChars.toString(),
          'selectedCalculationMethod': strategyResult.selectedCalculationMethod,
          'selectionHistory': strategyResult.selectionHistory,
          'baseTiaoWenList': baseTiaoWenList,
          'allTiaoWenNumbers': allTiaoWenNumbers,
          'calculationConfig': _defaultCalculationConfig.desc ?? 'N/A',
          'tiaoWenCount': allTiaoWenNumbers.length,
          'tiaoWenEntities': tiaoWenEntities.map((e) => e.toJson()).toList(),
          'sessionDuration': session.duration.inSeconds,
          'stepsCount': session.steps.length,
        },
      );
    } catch (e) {
      if (e is SessionNotFoundException ||
          e is SessionNotCompletedException ||
          e is StrategyCalculationException ||
          e is TiaoWenListCalculationException ||
          e is TiaoWenDataException ||
          e is InputValidationException) {
        rethrow;
      }
      throw UseCaseExecutionException(
        message: '完成计算失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  @override
  Future<InteractiveSession> getSession(String sessionId) async {
    validateSessionId(sessionId);

    final session = _sessions[sessionId];
    if (session == null) {
      throw SessionNotFoundException('会话不存在: $sessionId');
    }

    return session;
  }

  @override
  Future<InteractiveSession> cancelSession(String sessionId) async {
    try {
      // 1. 验证会话ID
      validateSessionId(sessionId);

      // 2. 获取会话
      final session = await getSession(sessionId);

      // 3. 取消会话
      final cancelledSession = session.cancel();

      // 4. 更新会话存储
      _sessions[sessionId] = cancelledSession;

      return cancelledSession;
    } catch (e) {
      if (e is SessionNotFoundException || e is InputValidationException) {
        rethrow;
      }
      throw UseCaseExecutionException(
        message: '取消会话失败: ${e.toString()}',
        useCaseName: name,
        originalException: e,
      );
    }
  }

  @override
  void validateParams(TaiXuanFourZhuInteractiveUseCaseParams params) {
    if (params.eightChars.year.name.isEmpty ||
        params.eightChars.month.name.isEmpty ||
        params.eightChars.day.name.isEmpty ||
        params.eightChars.time.name.isEmpty) {
      throw InputValidationException(
        "四柱不完整",
        message: '四柱信息不完整',
        parameterName: '太玄四柱交互式',
      );
    }
  }

  @override
  void validateSessionId(String sessionId) {
    if (sessionId.isEmpty) {
      throw InputValidationException(
        "会话id为空",
        message: '会话ID不能为空',
        parameterName: 'sessionId',
      );
    }
  }

  @override
  void validateCandidateId(String candidateId) {
    if (candidateId.isEmpty) {
      throw InputValidationException(
        "候选项id为空",
        message: '候选项ID不能为空',
        parameterName: 'candidateId',
      );
    }
  }

  @override
  void validateStepIndex(int stepIndex, int maxStepIndex) {
    if (stepIndex < 0 || stepIndex > maxStepIndex) {
      throw InvalidStepIndexException(
        '无效的步骤索引: $stepIndex，有效范围: 0-$maxStepIndex',
      );
    }
  }

  /// 清理过期会话
  ///
  /// 清理超时的会话以释放内存
  void cleanupExpiredSessions() {
    final now = DateTime.now();
    final expiredSessionIds = <String>[];

    for (final entry in _sessions.entries) {
      final session = entry.value;
      final sessionAge = now.difference(session.startTime);

      // 如果会话超过配置的超时时间，标记为过期
      final timeoutMinutes =
          session.sessionConfig?['config']?.sessionTimeoutMinutes ?? 30;
      if (sessionAge.inMinutes > timeoutMinutes) {
        expiredSessionIds.add(entry.key);
      }
    }

    // 移除过期会话
    for (final sessionId in expiredSessionIds) {
      _sessions.remove(sessionId);
    }
  }

  /// 获取活跃会话数量
  int get activeSessionCount => _sessions.length;

  /// 获取所有会话ID
  List<String> get allSessionIds => _sessions.keys.toList();
}
