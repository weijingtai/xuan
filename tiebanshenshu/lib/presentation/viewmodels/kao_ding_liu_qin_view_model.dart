import 'package:flutter/foundation.dart';
import 'package:common/models/eight_chars.dart';
import '../../features/kao_ding_liu_qin/models/liu_qin_type.dart';
import '../../features/kao_ding_liu_qin/models/liu_du_table.dart';
import '../../features/kao_ding_liu_qin/usecases/kao_ding_liu_qin_use_case.dart';
import '../../features/kao_ding_liu_qin/services/kao_ding_liu_qin_strategy.dart';
import '../../features/kao_ding_liu_qin/models/session_manager.dart';
import '../../features/kao_ke/kao_ke_session_models.dart';
import '../../features/six_yao_gua/pure_six_yao_gua.dart';
import '../../features/kao_ding_liu_qin/models/spouse_ordinal.dart';

/// 考订六亲状态
enum KaoDingLiuQinState {
  /// 初始状态
  initial,

  /// 加载中
  loading,

  /// 成功
  success,

  /// 错误
  error,
}

/// 考订六亲ViewModel
///
/// 管理考订六亲功能的UI状态，包括Session历史管理
class KaoDingLiuQinViewModel extends ChangeNotifier {
  final KaoDingLiuQinUseCase _useCase;

  // 状态变量
  KaoDingLiuQinState _state = KaoDingLiuQinState.initial;
  KaoDingLiuQinResult? _currentResult;
  String? _errorMessage;
  EightChars? _currentEightChars;

  /// 所有六亲类型的计算结果
  Map<LiuQinType, KaoDingLiuQinResult> _allResults = {};

  /// 所有六亲类型的流度表条目（带条文内容）
  Map<LiuQinType, List<LiuDuEntryWithTiaoWen>> _allEntriesWithTiaoWen = {};

  /// 兄弟乙表的流度表条目（带条文内容）
  List<LiuDuEntryWithTiaoWen> _siblingYiEntriesWithTiaoWen = [];

  /// 用户选择的条文（每个六亲类型对应一个条文编号）
  Map<LiuQinType, int> _selectedTiaoWenNumbers = {};

  /// 化卦结果（每个六亲类型对应一个化卦结果）
  Map<LiuQinType, GuaCalculationResult>? _huaGuaResults;

  /// 64卦结果（每个六亲类型对应一个64卦）
  Map<LiuQinType, Enum64Gua?>? _gua64Results;

  /// 夫妻任次（仅对夫/妻有效）
  final Map<LiuQinType, SpouseOrdinal> _spouseOrdinals = {
    LiuQinType.husband: SpouseOrdinal.first,
    LiuQinType.wife: SpouseOrdinal.first,
  };

  KaoDingLiuQinViewModel(this._useCase);

  /// 当前状态
  KaoDingLiuQinState get state => _state;

  /// 当前计算结果
  KaoDingLiuQinResult? get currentResult => _currentResult;

  /// 错误消息
  String? get errorMessage => _errorMessage;

  /// 当前八字
  EightChars? get currentEightChars => _currentEightChars;

  /// 是否正在加载
  bool get isLoading => _state == KaoDingLiuQinState.loading;

  /// 是否成功
  bool get isSuccess => _state == KaoDingLiuQinState.success;

  /// 是否有错误
  bool get hasError => _state == KaoDingLiuQinState.error;

  /// 是否为初始状态
  bool get isInitial => _state == KaoDingLiuQinState.initial;

  /// 是否有结果
  bool get hasResult => _currentResult != null;

  /// 所有六亲类型的计算结果
  Map<LiuQinType, KaoDingLiuQinResult> get allResults => _allResults;

  /// 所有六亲类型的流度表条目（带条文内容）
  Map<LiuQinType, List<LiuDuEntryWithTiaoWen>> get allEntriesWithTiaoWen =>
      _allEntriesWithTiaoWen;

  /// 兄弟乙表的流度表条目（带条文内容）
  List<LiuDuEntryWithTiaoWen> get siblingYiEntriesWithTiaoWen => _siblingYiEntriesWithTiaoWen;

  /// 用户选择的条文
  Map<LiuQinType, int> get selectedTiaoWenNumbers => _selectedTiaoWenNumbers;

  /// 化卦结果
  Map<LiuQinType, GuaCalculationResult>? get huaGuaResults => _huaGuaResults;

  /// 64卦结果
  Map<LiuQinType, Enum64Gua?>? get gua64Results => _gua64Results;

  /// Session管理器
  KaoDingLiuQinSessionManager get sessionManager => _useCase.sessionManager;

  /// 当前Session状态
  KaoDingLiuQinSessionState? get currentSessionState => _useCase.currentState;

  /// 历史记录
  List<KaoDingLiuQinSessionState> get history => _useCase.history;

  /// 是否可以回滚
  bool get canUndo => _useCase.canUndo;

  /// 是否可以重做
  bool get canRedo => _useCase.canRedo;

  /// 计算考订六亲
  ///
  /// [eightChars] 八字
  /// [liuQinType] 六亲类型
  Future<void> calculate({
    required EightChars eightChars,
    required LiuQinType liuQinType,
  }) async {
    try {
      _state = KaoDingLiuQinState.loading;
      _errorMessage = null;
      _currentEightChars = eightChars;
      notifyListeners();

      final params = KaoDingLiuQinUseCaseParams(
        eightChars: eightChars,
        liuQinType: liuQinType,
      );

      final result = await _useCase.execute(params);

      _currentResult = result;
      _state = KaoDingLiuQinState.success;
      notifyListeners();
    } catch (e) {
      _errorMessage = '计算失败: $e';
      _state = KaoDingLiuQinState.error;
      notifyListeners();
    }
  }

  /// 批量计算多个六亲类型
  Future<Map<LiuQinType, KaoDingLiuQinResult>> calculateMultiple({
    required EightChars eightChars,
    required List<LiuQinType> liuQinTypes,
  }) async {
    try {
      _state = KaoDingLiuQinState.loading;
      _errorMessage = null;
      _currentEightChars = eightChars;
      notifyListeners();

      final results = await _useCase.executeMultiple(eightChars, liuQinTypes, spouseOrdinals: _spouseOrdinals);

      // 设置最后一个结果为当前结果
      if (results.isNotEmpty) {
        _currentResult = results.values.last;
      }

      _state = KaoDingLiuQinState.success;
      notifyListeners();

      return results;
    } catch (e) {
      _errorMessage = '批量计算失败: $e';
      _state = KaoDingLiuQinState.error;
      notifyListeners();
      rethrow;
    }
  }

  /// 计算所有六亲类型
  Future<Map<LiuQinType, KaoDingLiuQinResult>> calculateAll({
    required EightChars eightChars,
  }) async {
    try {
      _state = KaoDingLiuQinState.loading;
      _errorMessage = null;
      _currentEightChars = eightChars;
      notifyListeners();

      // 计算所有六亲类型
      final results = await _useCase.executeMultiple(
        eightChars,
        LiuQinType.values,
        spouseOrdinals: _spouseOrdinals,
      );

      _allResults = results;

      // 为每个六亲类型加载流度表条目（带条文内容）
      for (final entry in results.entries) {
        final liuQinType = entry.key;
        final result = entry.value;

        final entriesWithTiaoWen =
            await _useCase.getLiuDuEntriesWithTiaoWen(result);
        _allEntriesWithTiaoWen[liuQinType] = entriesWithTiaoWen;

        // 如果有目标条目，自动选择它
        if (result.targetEntry != null) {
          _selectedTiaoWenNumbers[liuQinType] =
              result.targetEntry!.tiaoWenNumber;
        }
      }

      // 额外加载兄弟乙表（纳比卦乙表）
      _siblingYiEntriesWithTiaoWen = [];
      final siblingTables = await _useCase.getSiblingTables();
      final yiTable = siblingTables.firstWhere(
        (t) => t.type == LiuDuTableType.naBiGuaYi,
        orElse: () => siblingTables.last,
      );
      _siblingYiEntriesWithTiaoWen =
          await _useCase.getLiuDuEntriesWithTiaoWenForTable(yiTable);

      // 设置最后一个结果为当前结果
      if (results.isNotEmpty) {
        _currentResult = results.values.last;
      }

      _state = KaoDingLiuQinState.success;
      notifyListeners();

      return results;
    } catch (e) {
      _errorMessage = '计算所有六亲失败: $e';
      _state = KaoDingLiuQinState.error;
      notifyListeners();
      rethrow;
    }
  }

  /// 选择条文
  ///
  /// [liuQinType] 六亲类型
  /// [tiaoWenNumber] 条文编号
  void selectTiaoWenForType(LiuQinType liuQinType, int tiaoWenNumber) {
    _selectedTiaoWenNumbers[liuQinType] = tiaoWenNumber;
    notifyListeners();
  }

  /// 获取指定六亲类型选择的条文编号
  int? getSelectedTiaoWenNumber(LiuQinType liuQinType) {
    return _selectedTiaoWenNumbers[liuQinType];
  }

  /// 确认所有选择，进行后续计算
  ///
  /// 返回所有选择的条文编号
  Map<LiuQinType, int> confirmSelections() {
    // 执行化卦计算
    performHuaGua();
    return Map.from(_selectedTiaoWenNumbers);
  }

  /// 执行化卦计算
  ///
  /// 使用用户选择的条文编号进行化卦，计算出每个六亲类型对应的64卦
  void performHuaGua() {
    if (_selectedTiaoWenNumbers.isEmpty) {
      return;
    }

    try {
      // 执行化卦计算
      _huaGuaResults = _useCase.performHuaGua(_selectedTiaoWenNumbers);

      // 获取64卦结果
      _gua64Results = _useCase.getHuaGua64(_selectedTiaoWenNumbers);

      notifyListeners();
    } catch (e) {
      _errorMessage = '化卦计算失败: $e';
      _state = KaoDingLiuQinState.error;
      notifyListeners();
    }
  }

  /// 获取指定六亲类型的化卦结果
  GuaCalculationResult? getHuaGuaResult(LiuQinType liuQinType) {
    return _huaGuaResults?[liuQinType];
  }

  /// 获取指定六亲类型的64卦
  Enum64Gua? getGua64(LiuQinType liuQinType) {
    return _gua64Results?[liuQinType];
  }

  /// 选择条文（旧版本，保持向后兼容）
  ///
  /// [tiaoWenNumber] 条文编号
  /// [method] 计算方法
  @Deprecated('使用 selectTiaoWenForType 代替')
  void selectTiaoWen(int tiaoWenNumber, String method) {
    _useCase.selectTiaoWen(tiaoWenNumber, method);
    notifyListeners();
  }

  /// 回滚到上一个状态
  void undo() {
    final previousState = _useCase.undo();
    if (previousState != null) {
      _currentResult = previousState.result;
      _state = KaoDingLiuQinState.success;
      notifyListeners();
    }
  }

  /// 重做到下一个状态
  void redo() {
    final nextState = _useCase.redo();
    if (nextState != null) {
      _currentResult = nextState.result;
      _state = KaoDingLiuQinState.success;
      notifyListeners();
    }
  }

  /// 跳转到指定历史记录
  void jumpToHistory(int index) {
    final targetState = _useCase.jumpToHistory(index);
    if (targetState != null) {
      _currentResult = targetState.result;
      _state = KaoDingLiuQinState.success;
      notifyListeners();
    }
  }

  /// 清空历史记录
  void clearHistory() {
    _useCase.clearHistory();
    _currentResult = null;
    _state = KaoDingLiuQinState.initial;
    notifyListeners();
  }

  /// 获取指定六亲类型的历史记录
  List<KaoDingLiuQinSessionState> getHistoryByType(LiuQinType type) {
    return _useCase.getHistoryByType(type);
  }

  /// 获取统计信息
  Map<String, dynamic> getStatistics() {
    return _useCase.getStatistics();
  }

  /// 重置状态
  void reset() {
    _state = KaoDingLiuQinState.initial;
    _currentResult = null;
    _errorMessage = null;
    _currentEightChars = null;
    notifyListeners();
  }

  /// 预加载流度表
  Future<void> preloadTables() async {
    await _useCase.preloadTables();
  }

  /// 获取当前夫妻任次（默认为第一任）
  SpouseOrdinal getSpouseOrdinal(LiuQinType type) {
    return _spouseOrdinals[type] ?? SpouseOrdinal.first;
  }

  /// 设置夫妻任次并重算该类型
  Future<void> setSpouseOrdinal(LiuQinType type, SpouseOrdinal ordinal) async {
    if (!type.isSpouse) return;
    _spouseOrdinals[type] = ordinal;

    if (_currentEightChars == null) return;

    try {
      _state = KaoDingLiuQinState.loading;
      notifyListeners();

      final params = KaoDingLiuQinUseCaseParams(
        eightChars: _currentEightChars!,
        liuQinType: type,
        spouseOrdinal: ordinal,
      );
      final result = await _useCase.execute(params);
      _allResults[type] = result;

      final entriesWithTiaoWen =
          await _useCase.getLiuDuEntriesWithTiaoWen(result);
      _allEntriesWithTiaoWen[type] = entriesWithTiaoWen;

      if (result.targetEntry != null) {
        _selectedTiaoWenNumbers[type] = result.targetEntry!.tiaoWenNumber;
      }

      _currentResult = result;
      _state = KaoDingLiuQinState.success;
      notifyListeners();
    } catch (e) {
      _errorMessage = '重算${type.displayName}失败: $e';
      _state = KaoDingLiuQinState.error;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
