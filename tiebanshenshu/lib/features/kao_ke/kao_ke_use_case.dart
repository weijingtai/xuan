import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import '../../constant/kao_ke_constants.dart';
import 'kao_ke_session_manager.dart';
import 'kao_ke_session_models.dart';
import 'kao_ke_calculation_strategy.dart';

/// 考刻UseCase
///
/// 业务逻辑编排,负责协调SessionManager、CalculationStrategy等
class KaoKeUseCase {
  final KaoKeSessionManager _sessionManager;
  final KaoKeCalculationStrategy _calculationStrategy;
  final KaoKeConstants _kaoKeConstants;

  KaoKeUseCase({
    required KaoKeSessionManager sessionManager,
    required KaoKeCalculationStrategy calculationStrategy,
    required KaoKeConstants kaoKeConstants,
  })  : _sessionManager = sessionManager,
        _calculationStrategy = calculationStrategy,
        _kaoKeConstants = kaoKeConstants;

  /// 1. 初始化会话
  ///
  /// [eightChars] 用户八字
  /// [sessionName] 会话名称(可选)
  ///
  /// 返回初始化后的会话
  Future<KaoKeSession> initializeSession({
    required EightChars eightChars,
    String? sessionName,
  }) async {
    // 创建新会话
    final session = await _sessionManager.createSession(
      eightChars: eightChars,
      sessionName: sessionName,
    );

    // 推进到刻选择准备阶段
    final updatedSession = await _sessionManager.advanceToPhase(
      session: session,
      targetPhase: KaoKeSessionPhase.keSelectionReady,
    );

    return updatedSession;
  }

  /// 2. 准备刻选择数据
  ///
  /// 返回12时辰×8刻的完整数据
  Map<DiZhi, List<KaoEigthKeNumber>> prepareKeSelectionData() {
    return _kaoKeConstants.keNumbers;
  }

  /// 2a. 准备斗甲乙宫刻选择数据（按出生时辰确定宫）
  ///
  /// 例如：出生子时 -> 斗宫（子午卯酉），返回该宫的四支 × 每支 1-5 条目
  Map<DiZhi, List<DouJiaYiNumber>>
      prepareDouJiaYiSelectionDataForBirthShiChen(DiZhi birthShiChen) {
    final palace = _palaceTypeForShiChen(birthShiChen);
    final mapper = _kaoKeConstants.eightKeNumberMapper[palace];
    if (mapper == null) {
      return {};
    }
    return mapper;
  }

  /// 斗甲乙宫：由出生时辰判定所属宫
  DouJiaYiType _palaceTypeForShiChen(DiZhi zhi) {
    // 斗: 子午卯酉；甲: 辰戌丑未；乙: 寅申巳亥
    const douSet = {
      DiZhi.ZI,
      DiZhi.WU,
      DiZhi.MAO,
      DiZhi.YOU,
    };
    const jiaSet = {
      DiZhi.CHEN,
      DiZhi.XU,
      DiZhi.CHOU,
      DiZhi.WEI,
    };
    const yiSet = {
      DiZhi.YIN,
      DiZhi.SHEN,
      DiZhi.SI,
      DiZhi.HAI,
    };
    if (douSet.contains(zhi)) return DouJiaYiType.dou;
    if (jiaSet.contains(zhi)) return DouJiaYiType.jia;
    return DouJiaYiType.yi;
  }

  /// 3a. 提交斗甲乙宫选择（按条文编号匹配）
  ///
  /// 例如：出生子时，选择条文 7298 -> 匹配到 斗宫 午刻 序 2，生成 "子时午刻"
  Future<KaoKeSession> submitDouJiaYiSelection({
    required KaoKeSession session,
    required int selectedTiaoWenNumber,
  }) async {
    final birthShiChen = session.birthShiChen;
    final palace = _palaceTypeForShiChen(birthShiChen);
    final mapper = _kaoKeConstants.eightKeNumberMapper[palace];
    if (mapper == null) {
      throw Exception('未配置三宫映射: $palace');
    }

    DouJiaYiNumber? matched;
    for (final entry in mapper.entries) {
      for (final item in entry.value) {
        if (item.tiaoWenNumber == selectedTiaoWenNumber) {
          matched = item;
          break;
        }
      }
      if (matched != null) break;
    }

    if (matched == null) {
      throw Exception('未找到对应三宫之数: $selectedTiaoWenNumber');
    }

    final record = DouJiaYiSelectionRecord.fromDouJiaYiNumber(
      birthShiChen: birthShiChen,
      palaceType: palace,
      number: matched,
      selectedAt: DateTime.now(),
    );

    final updatedSession = session.copyWith(
      douJiaYiSelection: record,
    );

    // 使用同一阶段语义：刻已选择
    final finalSession = await _sessionManager.advanceToPhase(
      session: updatedSession,
      targetPhase: KaoKeSessionPhase.keSelected,
    );
    return finalSession;
  }

  /// 3. 提交用户选择
  ///
  /// [session] 当前会话
  /// [selectedKe] 用户选择的刻
  ///
  /// 返回更新后的会话(已更新到 keSelected 阶段)
  Future<KaoKeSession> submitKeSelection({
    required KaoKeSession session,
    required KaoEigthKeNumber selectedKe,
  }) async {
    // 创建选择记录
    final keSelection = KeSelectionRecord.fromKaoEigthKeNumber(
      selectedKe,
      DateTime.now(),
    );

    // 更新会话
    final updatedSession = session.copyWith(
      keSelection: keSelection,
    );

    // 推进到已选择刻阶段
    final finalSession = await _sessionManager.advanceToPhase(
      session: updatedSession,
      targetPhase: KaoKeSessionPhase.keSelected,
    );

    return finalSession;
  }

  /// 4. 计算卦象
  ///
  /// [session] 当前会话(优先使用普通八刻；否则使用斗甲乙宫基础数)
  ///
  /// 返回更新后的会话(已更新到 baseNumberCalculated 阶段)
  Future<KaoKeSession> calculateGua(KaoKeSession session) async {
    // 基础数优先来源：八刻选择；若无则斗甲乙宫选择
    int? baseNumber;
    if (session.keSelection != null) {
      baseNumber = session.keSelection!.tiaoWenNumber;
    } else if (session.douJiaYiSelection != null) {
      baseNumber = session.douJiaYiSelection!.tiaoWenNumber;
    }

    if (baseNumber == null) {
      throw Exception('必须先选择刻才能计算卦象');
    }

    // 计算卦象
    final guaResult = _calculationStrategy.calculateGua(baseNumber);

    // 更新会话
    final updatedSession = session.copyWith(
      guaResult: guaResult,
    );

    // 推进到基础数已计算阶段
    final finalSession = await _sessionManager.advanceToPhase(
      session: updatedSession,
      targetPhase: KaoKeSessionPhase.baseNumberCalculated,
    );

    return finalSession;
  }

  /// 5. 更新计算方法选择
  ///
  /// [session] 当前会话
  /// [methods] 选择的计算方法集合
  ///
  /// 返回更新后的会话
  Future<KaoKeSession> updateCalculationMethods({
    required KaoKeSession session,
    required Set<KaoKeCalculationMethod> methods,
  }) async {
    // 验证至少选择一个方法
    if (methods.isEmpty) {
      throw Exception('必须至少选择一个计算方法');
    }

    // 更新会话
    final updatedSession = session.copyWith(
      selectedMethods: methods,
      lastActivityAt: DateTime.now(),
    );

    // 保存会话
    await _sessionManager.saveSession(updatedSession);

    return updatedSession;
  }

  /// 6. 计算最终条文
  ///
  /// [session] 当前会话(必须已经有guaResult和selectedMethods)
  ///
  /// 返回更新后的会话(已更新到 finalCalculationComplete 阶段)
  Future<KaoKeSession> calculateFinalTiaoWen(KaoKeSession session) async {
    // 验证前置条件
    if (session.guaResult == null) {
      throw Exception('必须先计算卦象才能计算最终条文');
    }

    if (session.selectedMethods.isEmpty) {
      throw Exception('必须选择至少一个计算方法');
    }

    // 获取基础数：支持八刻或斗甲乙宫
    int? baseNumber;
    if (session.keSelection != null) {
      baseNumber = session.keSelection!.tiaoWenNumber;
    } else if (session.douJiaYiSelection != null) {
      baseNumber = session.douJiaYiSelection!.tiaoWenNumber;
    }

    if (baseNumber == null) {
      throw Exception('必须先选择刻才能计算最终条文');
    }

    // 计算所有选择方法的条文
    final finalResults = await _calculationStrategy.calculateAllMethods(
      baseNumber: baseNumber,
      guaResult: session.guaResult!,
      methods: session.selectedMethods,
      eightChars: session.eightChars,
    );

    // 更新会话
    final updatedSession = session.copyWith(
      finalResults: finalResults,
      status: KaoKeSessionStatus.completed,
      endTime: DateTime.now(),
    );

    // 推进到最终计算完成阶段
    final finalSession = await _sessionManager.advanceToPhase(
      session: updatedSession,
      targetPhase: KaoKeSessionPhase.finalCalculationComplete,
    );

    return finalSession;
  }

  /// 7. 回滚到指定阶段
  ///
  /// [session] 当前会话
  /// [targetPhase] 目标阶段(必须是历史中的阶段)
  ///
  /// 返回回滚后的会话
  Future<KaoKeSession> rollbackToPhase({
    required KaoKeSession session,
    required KaoKeSessionPhase targetPhase,
  }) async {
    // 查找目标阶段的快照
    final targetSnapshot = session.phaseHistory.lastWhere(
      (snapshot) => snapshot.phase == targetPhase,
      orElse: () => throw Exception('未找到目标阶段的快照: $targetPhase'),
    );

    // 回滚到快照
    final rolledBackSession = await _sessionManager.rollbackToSnapshot(
      session: session,
      snapshotId: targetSnapshot.snapshotId,
    );

    return rolledBackSession;
  }

  /// 回滚到上一阶段
  ///
  /// [session] 当前会话
  ///
  /// 返回回滚后的会话
  Future<KaoKeSession> rollbackToPreviousPhase(KaoKeSession session) async {
    return await _sessionManager.rollbackToPreviousPhase(session);
  }

  /// 获取会话
  ///
  /// [sessionId] 会话ID
  ///
  /// 返回会话,如果不存在则返回null
  Future<KaoKeSession?> getSession(String sessionId) async {
    return await _sessionManager.restoreSession(sessionId);
  }
}
