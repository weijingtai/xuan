import '../services/kao_ding_liu_qin_strategy.dart';
import '../models/liu_qin_type.dart';

/// Session状态
///
/// 记录单次计算的完整状态，用于历史记录和回滚
class KaoDingLiuQinSessionState {
  /// 计算结果
  final KaoDingLiuQinResult result;

  /// 用户选择的条文编号（如果已选择）
  final int? selectedTiaoWenNumber;

  /// 用户选择的计算方法（如果已选择）
  final String? selectedMethod;

  /// 时间戳
  final DateTime timestamp;

  /// 备注
  final String? note;

  const KaoDingLiuQinSessionState({
    required this.result,
    this.selectedTiaoWenNumber,
    this.selectedMethod,
    required this.timestamp,
    this.note,
  });

  /// 创建副本
  KaoDingLiuQinSessionState copyWith({
    KaoDingLiuQinResult? result,
    int? selectedTiaoWenNumber,
    String? selectedMethod,
    DateTime? timestamp,
    String? note,
  }) {
    return KaoDingLiuQinSessionState(
      result: result ?? this.result,
      selectedTiaoWenNumber: selectedTiaoWenNumber ?? this.selectedTiaoWenNumber,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  /// 是否已选择条文
  bool get hasSelection => selectedTiaoWenNumber != null;

  /// 获取简短描述
  String get shortDescription {
    return '${result.liuQinType.displayName} - ${result.pillar.name}';
  }

  @override
  String toString() {
    return 'SessionState($shortDescription, 时间:$timestamp, 已选择:$hasSelection)';
  }
}

/// Session管理器
///
/// 管理考订六亲的计算历史，支持回滚和重做
class KaoDingLiuQinSessionManager {
  /// 历史记录栈（用于回滚）
  final List<KaoDingLiuQinSessionState> _history = [];

  /// 当前索引（指向_history中的位置）
  int _currentIndex = -1;

  /// 最大历史记录数
  final int maxHistorySize;

  KaoDingLiuQinSessionManager({this.maxHistorySize = 50});

  /// 获取当前状态
  KaoDingLiuQinSessionState? get currentState {
    if (_currentIndex >= 0 && _currentIndex < _history.length) {
      return _history[_currentIndex];
    }
    return null;
  }

  /// 获取所有历史记录
  List<KaoDingLiuQinSessionState> get allHistory {
    return List.unmodifiable(_history);
  }

  /// 获取当前可见的历史（从头到当前索引）
  List<KaoDingLiuQinSessionState> get visibleHistory {
    if (_currentIndex < 0) return [];
    return List.unmodifiable(_history.sublist(0, _currentIndex + 1));
  }

  /// 是否可以回滚
  bool get canUndo => _currentIndex > 0;

  /// 是否可以重做
  bool get canRedo => _currentIndex < _history.length - 1;

  /// 历史记录数量
  int get historyCount => _history.length;

  /// 当前索引
  int get currentIndex => _currentIndex;

  /// 添加新状态
  ///
  /// 如果当前不在历史记录末尾，会删除后续的历史记录
  void addState(KaoDingLiuQinSessionState state) {
    // 如果当前不在末尾，删除后续记录
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    // 添加新状态
    _history.add(state);
    _currentIndex = _history.length - 1;

    // 如果超过最大历史记录数，删除最早的记录
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
      _currentIndex--;
    }
  }

  /// 回滚到上一个状态
  ///
  /// 返回回滚后的状态，如果无法回滚返回null
  KaoDingLiuQinSessionState? undo() {
    if (!canUndo) return null;

    _currentIndex--;
    return currentState;
  }

  /// 重做到下一个状态
  ///
  /// 返回重做后的状态，如果无法重做返回null
  KaoDingLiuQinSessionState? redo() {
    if (!canRedo) return null;

    _currentIndex++;
    return currentState;
  }

  /// 更新当前状态的选择
  ///
  /// 不创建新的历史记录，只更新当前记录
  void updateCurrentSelection({
    int? selectedTiaoWenNumber,
    String? selectedMethod,
  }) {
    if (currentState == null) return;

    final updatedState = currentState!.copyWith(
      selectedTiaoWenNumber: selectedTiaoWenNumber,
      selectedMethod: selectedMethod,
    );

    _history[_currentIndex] = updatedState;
  }

  /// 回滚到指定索引
  ///
  /// 返回指定索引的状态，如果索引无效返回null
  KaoDingLiuQinSessionState? jumpToIndex(int index) {
    if (index < 0 || index >= _history.length) return null;

    _currentIndex = index;
    return currentState;
  }

  /// 清空所有历史
  void clear() {
    _history.clear();
    _currentIndex = -1;
  }

  /// 删除指定索引的历史记录
  ///
  /// 如果删除的是当前或之前的记录，会调整currentIndex
  bool removeAt(int index) {
    if (index < 0 || index >= _history.length) return false;

    _history.removeAt(index);

    // 调整currentIndex
    if (_currentIndex >= _history.length) {
      _currentIndex = _history.length - 1;
    } else if (_currentIndex >= index) {
      _currentIndex--;
    }

    return true;
  }

  /// 获取指定六亲类型的历史记录
  List<KaoDingLiuQinSessionState> getHistoryByLiuQinType(LiuQinType type) {
    return _history.where((state) => state.result.liuQinType == type).toList();
  }

  /// 获取统计信息
  Map<String, dynamic> getStatistics() {
    final stats = <String, dynamic>{
      'totalCount': _history.length,
      'currentIndex': _currentIndex,
      'canUndo': canUndo,
      'canRedo': canRedo,
    };

    // 按六亲类型统计
    final countByType = <LiuQinType, int>{};
    for (final state in _history) {
      countByType[state.result.liuQinType] =
          (countByType[state.result.liuQinType] ?? 0) + 1;
    }
    stats['countByType'] = countByType;

    // 选择率
    final selectedCount = _history.where((s) => s.hasSelection).length;
    stats['selectedCount'] = selectedCount;
    stats['selectionRate'] =
        _history.isEmpty ? 0.0 : selectedCount / _history.length;

    return stats;
  }

  @override
  String toString() {
    return 'SessionManager(历史:$historyCount, 当前:$_currentIndex, 可撤销:$canUndo, 可重做:$canRedo)';
  }
}
