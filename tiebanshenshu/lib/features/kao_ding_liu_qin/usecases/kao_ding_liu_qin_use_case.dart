import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import '../../../repository/tiao_wen_repository.dart';
import '../../../repository/tiao_wen_repository_impl.dart';
import '../../../features/kao_ke/gua_calculation_helper.dart';
import '../../../features/kao_ke/kao_ke_session_models.dart';
import '../../../features/six_yao_gua/pure_six_yao_gua.dart';
import '../repositories/liu_du_table_repository.dart';
import '../services/kao_ding_liu_qin_strategy.dart';
import '../models/liu_qin_type.dart';
import '../models/liu_du_table.dart';
import '../models/session_manager.dart';
import '../models/spouse_ordinal.dart';

/// UseCase参数
class KaoDingLiuQinUseCaseParams {
  /// 八字
  final EightChars eightChars;

  /// 六亲类型
  final LiuQinType liuQinType;

  /// 夫妻继任（仅考订夫妻时生效）
  final SpouseOrdinal? spouseOrdinal;

  const KaoDingLiuQinUseCaseParams({
    required this.eightChars,
    required this.liuQinType,
    this.spouseOrdinal,
  });

  /// 根据六亲类型获取对应的柱
  JiaZi get correspondingPillar {
    switch (liuQinType) {
      case LiuQinType.father:
      case LiuQinType.mother:
        return eightChars.year; // 年柱
      case LiuQinType.wife:
      case LiuQinType.husband:
        return eightChars.day; // 日柱
      case LiuQinType.sibling:
        return eightChars.month; // 月柱
      case LiuQinType.son:
      case LiuQinType.daughter:
        return eightChars.time; // 时柱
    }
  }

  /// 日干（用于定六亲）
  TianGan get dayGan => eightChars.day.gan;
}

/// 考订六亲UseCase
///
/// 编排考订六亲功能的业务逻辑，管理Session状态
class KaoDingLiuQinUseCase {
  final LiuDuTableRepository _liuDuTableRepository;
  final TiaoWenRepository _tiaoWenRepository;
  final KaoDingLiuQinStrategy _strategy;
  final KaoDingLiuQinSessionManager _sessionManager;

  KaoDingLiuQinUseCase({
    LiuDuTableRepository? liuDuTableRepository,
    TiaoWenRepository? tiaoWenRepository,
    KaoDingLiuQinSessionManager? sessionManager,
  })  : _liuDuTableRepository = liuDuTableRepository ?? LiuDuTableRepository(),
        _tiaoWenRepository = tiaoWenRepository ?? TiaoWenRepositoryImpl(dataPath: 'assets/tiao_wen_data.csv'),
        _sessionManager = sessionManager ?? KaoDingLiuQinSessionManager(),
        _strategy = KaoDingLiuQinStrategy(liuDuTableRepository ?? LiuDuTableRepository());

  /// 获取Session管理器（用于ViewModel访问）
  KaoDingLiuQinSessionManager get sessionManager => _sessionManager;

  /// 执行考订六亲计算
  ///
  /// 计算结果会自动添加到Session历史中
  Future<KaoDingLiuQinResult> execute(
    KaoDingLiuQinUseCaseParams params,
  ) async {
    // 1. 执行核心策略计算
    final result = await _strategy.calculate(
      liuQinType: params.liuQinType,
      pillar: params.correspondingPillar,
      dayGan: params.dayGan,
      spouseOrdinal: params.spouseOrdinal,
    );

    // 2. 创建Session状态
    final sessionState = KaoDingLiuQinSessionState(
      result: result,
      timestamp: DateTime.now(),
    );

    // 3. 添加到历史记录
    _sessionManager.addState(sessionState);

    return result;
  }

  /// 批量计算多个六亲类型
  ///
  /// 例如：同时计算父母、夫妻、兄弟、子女
  Future<Map<LiuQinType, KaoDingLiuQinResult>> executeMultiple(
    EightChars eightChars,
    List<LiuQinType> liuQinTypes,
    {Map<LiuQinType, SpouseOrdinal>? spouseOrdinals}
  ) async {
    final results = <LiuQinType, KaoDingLiuQinResult>{};

    for (final liuQinType in liuQinTypes) {
      final params = KaoDingLiuQinUseCaseParams(
        eightChars: eightChars,
        liuQinType: liuQinType,
        spouseOrdinal: liuQinType.isSpouse
            ? (spouseOrdinals?[liuQinType] ?? SpouseOrdinal.first)
            : null,
      );

      final result = await execute(params);
      results[liuQinType] = result;
    }

    return results;
  }

  /// 计算所有六亲类型
  Future<Map<LiuQinType, KaoDingLiuQinResult>> executeAll(
    EightChars eightChars,
    {Map<LiuQinType, SpouseOrdinal>? spouseOrdinals}
  ) async {
    return executeMultiple(eightChars, LiuQinType.values, spouseOrdinals: spouseOrdinals);
  }

  /// 更新当前选择的条文
  ///
  /// [tiaoWenNumber] 选择的条文编号
  /// [method] 选择的计算方法
  void selectTiaoWen(int tiaoWenNumber, String method) {
    _sessionManager.updateCurrentSelection(
      selectedTiaoWenNumber: tiaoWenNumber,
      selectedMethod: method,
    );
  }

  /// 回滚到上一个状态
  KaoDingLiuQinSessionState? undo() {
    return _sessionManager.undo();
  }

  /// 重做到下一个状态
  KaoDingLiuQinSessionState? redo() {
    return _sessionManager.redo();
  }

  /// 跳转到指定历史记录
  KaoDingLiuQinSessionState? jumpToHistory(int index) {
    return _sessionManager.jumpToIndex(index);
  }

  /// 清空历史记录
  void clearHistory() {
    _sessionManager.clear();
  }

  /// 获取当前状态
  KaoDingLiuQinSessionState? get currentState {
    return _sessionManager.currentState;
  }

  /// 获取历史记录
  List<KaoDingLiuQinSessionState> get history {
    return _sessionManager.visibleHistory;
  }

  /// 获取指定六亲类型的历史记录
  List<KaoDingLiuQinSessionState> getHistoryByType(LiuQinType type) {
    return _sessionManager.getHistoryByLiuQinType(type);
  }

  /// 是否可以回滚
  bool get canUndo => _sessionManager.canUndo;

  /// 是否可以重做
  bool get canRedo => _sessionManager.canRedo;

  /// 获取统计信息
  Map<String, dynamic> getStatistics() {
    return _sessionManager.getStatistics();
  }

  /// 预加载流度表（可选，用于优化首次加载速度）
  Future<void> preloadTables() async {
    await _liuDuTableRepository.getAllTables();
  }

  /// 获取流度表的所有条目（带条文内容）
  ///
  /// [result] 考订六亲计算结果
  /// 返回带条文内容的流度表条目列表，供UI展示
  Future<List<LiuDuEntryWithTiaoWen>> getLiuDuEntriesWithTiaoWen(
    KaoDingLiuQinResult result,
  ) async {
    if (result.liuDuTable == null) {
      return [];
    }

    final table = result.liuDuTable!;
    final entries = table.getAllEntries();
    final entriesWithTiaoWen = <LiuDuEntryWithTiaoWen>[];

    // 如果是按地支索引的表，需要保留地支信息
    if (table.hasZhiMapper && table.zhiMapper != null) {
      for (final zhi in DiZhi.values) {
        final entry = table.zhiMapper![zhi];
        if (entry != null) {
          // 获取条文内容
          final tiaoWen = await _tiaoWenRepository.getById(entry.tiaoWenNumber);

          // 判断是否是目标条目
          final isTarget = result.targetEntry != null &&
                          result.targetEntry!.chiperNumber == entry.chiperNumber;

          entriesWithTiaoWen.add(LiuDuEntryWithTiaoWen(
            entry: entry,
            tiaoWen: tiaoWen,
            isTarget: isTarget,
            zhi: zhi,
          ));
        }
      }
    } else {
      // 固定列表表
      for (final entry in entries) {
        final tiaoWen = await _tiaoWenRepository.getById(entry.tiaoWenNumber);

        final isTarget = result.targetEntry != null &&
                        result.targetEntry!.chiperNumber == entry.chiperNumber;

        entriesWithTiaoWen.add(LiuDuEntryWithTiaoWen(
          entry: entry,
          tiaoWen: tiaoWen,
          isTarget: isTarget,
        ));
      }
    }

    return entriesWithTiaoWen;
  }

  /// 直接根据流度表生成带条文的条目列表（可选目标高亮）
  Future<List<LiuDuEntryWithTiaoWen>> getLiuDuEntriesWithTiaoWenForTable(
    LiuDuTable table, {
    LiuDuEntry? targetEntry,
  }) async {
    final entriesWithTiaoWen = <LiuDuEntryWithTiaoWen>[];

    if (table.hasZhiMapper && table.zhiMapper != null) {
      for (final zhi in DiZhi.values) {
        final entry = table.zhiMapper![zhi];
        if (entry != null) {
          final tiaoWen = await _tiaoWenRepository.getById(entry.tiaoWenNumber);
          final isTarget = targetEntry != null &&
              targetEntry.chiperNumber == entry.chiperNumber;
          entriesWithTiaoWen.add(LiuDuEntryWithTiaoWen(
            entry: entry,
            tiaoWen: tiaoWen,
            isTarget: isTarget,
            zhi: zhi,
          ));
        }
      }
    } else {
      for (final entry in table.getAllEntries()) {
        final tiaoWen = await _tiaoWenRepository.getById(entry.tiaoWenNumber);
        final isTarget = targetEntry != null &&
            targetEntry.chiperNumber == entry.chiperNumber;
        entriesWithTiaoWen.add(LiuDuEntryWithTiaoWen(
          entry: entry,
          tiaoWen: tiaoWen,
          isTarget: isTarget,
        ));
      }
    }

    return entriesWithTiaoWen;
  }

  /// 获取兄弟姐妹的甲/乙双表
  Future<List<LiuDuTable>> getSiblingTables() async {
    return _liuDuTableRepository.getSiblingTables();
  }

  /// 化卦 - 根据选择的条文编号进行化卦
  ///
  /// [selectedTiaoWenNumbers] 用户选择的条文编号（每个六亲类型对应一个）
  /// 返回每个六亲类型的化卦结果
  Map<LiuQinType, GuaCalculationResult> performHuaGua(
    Map<LiuQinType, int> selectedTiaoWenNumbers,
  ) {
    final results = <LiuQinType, GuaCalculationResult>{};

    for (final entry in selectedTiaoWenNumbers.entries) {
      final liuQinType = entry.key;
      final tiaoWenNumber = entry.value;

      // 使用 GuaCalculationHelper 进行化卦
      final guaResult = GuaCalculationHelper.calculateGua(tiaoWenNumber);
      results[liuQinType] = guaResult;
    }

    return results;
  }

  /// 获取化卦后的64卦
  ///
  /// [selectedTiaoWenNumbers] 用户选择的条文编号
  /// 返回每个六亲类型的64卦
  Map<LiuQinType, Enum64Gua?> getHuaGua64(
    Map<LiuQinType, int> selectedTiaoWenNumbers,
  ) {
    final results = <LiuQinType, Enum64Gua?>{};

    for (final entry in selectedTiaoWenNumbers.entries) {
      final liuQinType = entry.key;
      final tiaoWenNumber = entry.value;

      // 化卦
      final guaResult = GuaCalculationHelper.calculateGua(tiaoWenNumber);

      // 获取64卦
      final gua64 = GuaCalculationHelper.getEnum64Gua(
        guaResult.shangGuaNumber,
        guaResult.xiaGuaNumber,
      );

      results[liuQinType] = gua64;
    }

    return results;
  }
}
